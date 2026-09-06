--------------------------------------------------------------------------
--[[ Flooding class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)
	-- Point means flood point/position
	-- Pos means world point/position

	--------------------------------------------------------------------------
	--[[ Constants ]]
	--------------------------------------------------------------------------

	-- Flood is a 2x2 square
	local FLOOD_SIZE = 2

	local SURROUNDING_OFFSETS = {
		{ x = 1, z = 0 },
		{ x = -1, z = 0 },
		{ x = 0, z = 1 },
		{ x = 0, z = -1 },
	}

	--------------------------------------------------------------------------
	--[[ Member variables ]]
	--------------------------------------------------------------------------
	--Private

	local _world = TheWorld
	local _map = _world.Map
	local _ismastersim = _world.ismastersim

	local w, h = _map:GetSize()
	local tile_flood_ratio = TILE_SCALE / FLOOD_SIZE
	local _floodrangex = math.floor(w / 2 * tile_flood_ratio)
	local _floodrangez = math.floor(h / 2 * tile_flood_ratio)
	local _totalfloodpoints = w * tile_flood_ratio * h * tile_flood_ratio

	local _israining = false
	local _isspring = false
	local _isfloodseason = false
	local _elapseddaysinseason = 0
	local _floodseasonlength = TUNING.SPRING_LENGTH * TUNING.TOTAL_DAY_TIME * 0.75

	local _maxTide = 0
	local _maxtidemod = 1 --settings modifier

	local _targetTide = 0
	local _currentTide = 0

	-- for puddles
	local _forcepuddlelevel
	local _minpuddlelevel = _ismastersim and 1
	local _maxpuddlelevel = _ismastersim and TUNING.MAX_FLOOD_LEVEL
	local _curmaxpuddlelevel = _ismastersim and 0
	-- local _floodgrowtime = _ismastersim and TUNING.FLOOD_GROW_TIME
	-- local _flooddrytime = _ismastersim and TUNING.FLOOD_DRY_TIME
	local _puddlegrowrate = _ismastersim and 1 / TUNING.FLOOD_GROW_TIME
	local _puddledryrate = _ismastersim and 1 / TUNING.FLOOD_DRY_TIME
	local _expectedpuddlenum = _totalfloodpoints * TUNING.FLOOD_FREQUENCY
	local _puddlechance = _ismastersim and _expectedpuddlenum / _floodseasonlength

	--Public

	self.inst = inst

	-- Key value tables, key type is Point (string)
	self.floods = {}
	self.puddles = _ismastersim and {}
	self.blockers = _ismastersim and {}

	--------------------------------------------------------------------------
	--[[ Private member functions ]]
	--------------------------------------------------------------------------

	local floodonremove = _ismastersim and function(inst)
		self.floods[inst.flood_key] = nil
	end
	local CreateFlood = _ismastersim
		and function(x, z, source, dist, key)
			if not key then
				key = self:GetPointKey(x, z)
			end
			local flood = self.floods[key]
			if not flood then
				flood = SpawnPrefab("network_flood")
				flood.Transform:SetPosition(self:FloodPointToWorldPos(x, z))
				flood.sources = {}
				flood.flood_x = x
				flood.flood_z = z
				flood.flood_key = key
				flood:ListenForEvent("onremove", floodonremove)
				self.floods[key] = flood
			end
			flood.sources[source] = dist
			return flood
		end

	local RemoveFlood = _ismastersim
		and function(flood, source)
			if source then
				flood.sources[source] = nil
				if IsTableEmpty(flood.sources) then
					flood:Remove()
				end
			else
				flood:Remove()
			end
		end

	local onlevelchange = _ismastersim
		and function(self, new_level, old_level)
			if new_level == 0 then
				self:RemoveSelf()
			elseif new_level ~= old_level then
				self:UpdateFloods(old_level)
			end
		end

	local Puddle = _ismastersim
		and Class(
			function(self, x, z, level, key)
				self.x = x
				self.z = z
				self.key = key
				self.floods = {}
				self.level = level or _minpuddlelevel

				self:InitLevelDelta()
			end,
			nil,
			{
				level = onlevelchange,
			}
		)

	local CreatePuddle = _ismastersim and function(x, z, level, key)
		local puddle = Puddle(x, z, level, key)
		self.puddles[key] = puddle
		return puddle
	end

	local RemovePuddle = _ismastersim
		and function(puddle)
			puddle:Remove()
			if puddle.mapicon_entity then -- Debug icon
				puddle.mapicon_entity:Remove()
			end
			self.puddles[puddle.key] = nil
		end

	if _ismastersim then
		function Puddle:InitLevelDelta()
			self.leveldelta = GetRandomWithVariance(0, 0.05)
		end

		local function IsCenterBlocked(puddle)
			return self.blockers[puddle.key]
		end

		local function Expand(puddle, x, z)
			local floods = puddle.floods
			for _, offset in ipairs(SURROUNDING_OFFSETS) do
				local new_x = x + offset.x
				local new_z = z + offset.z
				local dist = math.abs(new_x - puddle.x) + math.abs(new_z - puddle.z)
				if dist <= puddle.level then
					local key = self:GetPointKey(new_x, new_z)
					if not floods[key] and self:IsValidPointForFlood(new_x, new_z, nil, key) then
						floods[key] = CreateFlood(new_x, new_z, puddle, dist, key)
						Expand(puddle, new_x, new_z)
					end
				end
			end
		end

		function Puddle:ExpandFlood(flood)
			Expand(self, flood.flood_x, flood.flood_z)
		end

		function Puddle:RemoveFlood(flood)
			RemoveFlood(flood, self)
			self.floods[flood.flood_key] = nil
		end

		function Puddle:UpdateFloods(old_level)
			if old_level then
				if self.level < old_level then
					for _, flood in pairs(self.floods) do
						if flood.sources[self] > self.level then
							self:RemoveFlood(flood)
						end
					end
				else
					local max_dist = 0
					for _, flood in pairs(self.floods) do
						local dist = flood.sources[self]
						if dist > max_dist then
							max_dist = dist
						end
					end
					local floods = {}
					for _, flood in pairs(self.floods) do
						local dist = flood.sources[self]
						if dist == max_dist then
							table.insert(floods, flood)
						end
					end
					for _, flood in ipairs(floods) do
						self:ExpandFlood(flood)
					end
				end
			else
				-- Recalculate, and remove all mismatched floods
				local old_floods = self.floods
				self.floods = {}
				if not IsCenterBlocked(self) then
					self.floods[self.key] = CreateFlood(self.x, self.z, self, 0, self.key)
				end
				Expand(self, self.x, self.z)
				for k, flood in pairs(old_floods) do
					if not self.floods[k] then
						RemoveFlood(flood, self)
					end
				end
				if IsTableEmpty(self.floods) then
					self:RemoveSelf()
				end
			end
		end

		function Puddle:OnUpdate(dt)
			if _isfloodseason then
				if _israining then
					self.leveldelta = self.leveldelta + dt * _puddlegrowrate
					if self.leveldelta > 1 and self.level < _curmaxpuddlelevel then
						self.level = self.level + 1
						self:InitLevelDelta()
					end
				end
			elseif not _israining then
				self.leveldelta = self.leveldelta - dt * _puddledryrate
				if self.leveldelta < -1 then
					self.level = self.level - 1
					self:InitLevelDelta()
				end
			end
		end

		function Puddle:Remove()
			for _, flood in pairs(self.floods) do
				RemoveFlood(flood, self)
			end
		end

		function Puddle:RemoveSelf()
			RemovePuddle(self)
		end

		-- function Puddle:OnSave()
		--     return {
		--         level = self.level
		--     }
		-- end

		-- function Puddle:OnLoad(data)
		--     if data.level then
		--         self.level = data.level
		--     end
		-- end
	end

	--------------------------------------------------------------------------
	--[[ Member functions ]]
	--------------------------------------------------------------------------

	-- Convert world pos to flood point
	-- Vector3 / x, z / x, y, z  ->  flood_x, flood_z
	function self:WorldPosToFloodPoint(x, y, z)
		if not y then
			if z then
				z = y
			else
				x, y, z = x:Get()
			end
		end
		-- x = math.floor(x)
		-- z = math.floor(z)
		-- return (x + ((x + 1) % 2)) / TILE_SCALE + half_w, (z + ((z + 1) % 2)) / TILE_SCALE + half_h
		return math.floor(x / FLOOD_SIZE), math.floor(z / FLOOD_SIZE)
	end

	-- Convert flood point to world pos (flood center pos)
	-- flood_x, flood_z  ->  x, y, z
	function self:FloodPointToWorldPos(x, z)
		-- return (x - half_w) * TILE_SCALE, 0, (z - half_h) * TILE_SCALE
		return (x + 0.5) * FLOOD_SIZE, 0, (z + 0.5) * FLOOD_SIZE
	end

	function self:GetTileCenterPoint(x, y, z)
		return self:FloodPointToWorldPos(self:WorldPosToFloodPoint(x, y, z))
	end

	function self:GetPointKey(x, z)
		return tostring(x) .. "," .. tostring(z)
	end

	function self:IsPointOnFlood(x, y, z)
		return self.floods[self:GetPointKey(self:WorldPosToFloodPoint(x, y, z))] ~= nil
	end

	self.OnFlood = self.IsPointOnFlood -- For compatible with sw's function name

	if _ismastersim then
		function self:GetPuddleAtPoint(x, z)
			return self.puddles[self:GetPointKey(x, z)]
		end

		function self:IsValidPointForFlood(x, z, spawning, key)
			if not key then
				key = self:GetPointKey(x, z)
			end
			if self.blockers[key] then
				return false
			end
			local world_x, _, world_z = self:FloodPointToWorldPos(x, z)
			local ground = _map:GetTileAtPoint(world_x, 0, world_z)
			if ground == WORLD_TILES.IMPASSABLE or ground == WORLD_TILES.INVALID or not IsLand(ground) then
				return false
			end
			if spawning then
				return not NO_PUDDLE_GROUNDS[ground] and IsInIAClimate(Vector3(world_x, 0, world_z))
			end
			return true
		end

		function self:SpawnPuddleAtPoint(x, z, level)
			local key = self:GetPointKey(x, z)
			if not self.puddles[key] then
				return CreatePuddle(x, z, level, key)
			end
		end

		function self:RemovePuddleAtPoint(x, z)
			local key = self:GetPointKey(x, z)
			local puddle = self.puddles[key]
			if puddle then
				RemovePuddle(puddle)
			end
		end

		function self:SpawnPuddle(x, y, z, level)
			local tile_x, tile_z = self:WorldPosToFloodPoint(x, y, z)
			if self:IsValidPointForFlood(tile_x, tile_z, true) then
				self:SpawnPuddleAtPoint(tile_x, tile_z, level)
			end
		end

		self.SetPositionPuddleSource = self.SpawnPuddle -- For compatible with sw's function name

		local last_time = 0
		function self:SpawnRandomPuddle(level)
			local x, z = math.random(-_floodrangex, _floodrangex), math.random(-_floodrangez, _floodrangez)
			if self:IsValidPointForFlood(x, z, true) then
				local time = GetTime()
				-- print("new puddle", time - last_time)
				last_time = time
				self:SpawnPuddleAtPoint(x, z, level)
			end
		end

		-- Mostly there in case something still tries to use it
		function self:GetIsFloodSeason()
			return _isfloodseason
		end

		function self:SetFloodSettings(max_level, frequency)
			_maxpuddlelevel = math.min(max_level, TUNING.MAX_FLOOD_LEVEL)
			_expectedpuddlenum = _totalfloodpoints * frequency
			_puddlechance = _expectedpuddlenum / _floodseasonlength
		end

		function self:SetMaxTideModifier(mod)
			_maxtidemod = mod
		end
	end

	if not _ismastersim then
		function self:AddFloodTile(tile)
			self.floods[self:GetPointKey(self:WorldPosToFloodPoint(tile.Transform:GetWorldPosition()))] = tile
		end

		function self:RemoveFloodTile(tile)
			self.floods[self:GetPointKey(self:WorldPosToFloodPoint(tile.Transform:GetWorldPosition()))] = nil
		end
	end

	--------------------------------------------------------------------------
	--[[ Private event handlers ]]
	--------------------------------------------------------------------------

	local floodblockercreated = _ismastersim
		and function(src, data)
			local blocker = data.blocker
			local key = self:GetPointKey(self:WorldPosToFloodPoint(blocker.Transform:GetWorldPosition()))
			self.blockers[key] = blocker
			local flood = self.floods[key]
			if flood then
				for puddle in pairs(flood.sources) do
					puddle:RemoveFlood(flood)
				end
			end
		end

	local floodblockerremoved = _ismastersim
		and function(src, data)
			local x, z = self:WorldPosToFloodPoint(data.blocker.Transform:GetWorldPosition())
			self.blockers[self:GetPointKey(x, z)] = nil
			for _, offset in ipairs(SURROUNDING_OFFSETS) do
				local new_x = x + offset.x
				local new_z = z + offset.z
				local flood = self.floods[self:GetPointKey(new_x, new_z)]
				if flood then
					for puddle in pairs(flood.sources) do
						puddle:ExpandFlood(flood)
					end
				end
			end
		end

	local seasontick = _ismastersim
		and function(src, data)
			_elapseddaysinseason = data.elapseddaysinseason or 0
			if data.season == "spring" then
				_isspring = true
			else
				_isspring = false
				_isfloodseason = false
			end
		end

	local clocktick = _ismastersim
		and function(src, data)
			local total_progress = (_elapseddaysinseason + (data.time or 0)) / TheWorld.state[TheWorld.state.season .. "length"]
			if _isspring and not _isfloodseason then
				_isfloodseason = total_progress >= 0.25
			end
			if _forcepuddlelevel then
				_curmaxpuddlelevel = _forcepuddlelevel
			elseif _isfloodseason and _israining then
				_curmaxpuddlelevel = math.ceil(_maxpuddlelevel * math.max(0, (total_progress - 0.25) / 0.75))
			end
		end

	-- local moonphasechanged = _ismastersim and function(src, phase)
	--     assert(phase ~= nil)
	--     _maxTide = _moontideheights[phase] or 0
	-- end

	local precipitation_islandchanged = _ismastersim and function(src, precip_type)
		_israining = precip_type ~= "none"
	end

	local springlength = _ismastersim
		and function(src, length)
			_floodseasonlength = (length * TUNING.TOTAL_DAY_TIME * 0.75)
			_puddlechance = _expectedpuddlenum / _floodseasonlength
		end

	--------------------------------------------------------------------------
	--[[ Initialization ]]
	--------------------------------------------------------------------------

	if _ismastersim then
		inst:ListenForEvent("floodblockercreated", floodblockercreated, _world)
		inst:ListenForEvent("floodblockerremoved", floodblockerremoved, _world)
		inst:ListenForEvent("seasontick", seasontick, _world)
		inst:ListenForEvent("clocktick", clocktick, _world)
		-- inst:ListenForEvent("moonphasechanged", moonphasechanged, _world)
		inst:ListenForEvent("precipitation_islandchanged", precipitation_islandchanged, _world)
		inst:ListenForEvent("springlength", springlength, _world)
	end
	self.inst:StartUpdatingComponent(self)

	--------------------------------------------------------------------------
	--[[ Update ]]
	--------------------------------------------------------------------------

	function self:OnUpdate(dt)
		if _ismastersim then
			if _isfloodseason and _world.state.islandiswet and _israining then
				if math.random() < _puddlechance * dt then
					self:SpawnRandomPuddle()
				end
			end

			for _, puddle in pairs(self.puddles) do
				puddle:OnUpdate(dt)
			end
		end

		--Tides stuff
		-- local currentHeight = GetWorld().Flooding:GetTargetDepth()
		-- local newHeight = self:GetTideHeight()
		-- GetWorld().Flooding:SetTargetDepth(newHeight)

		-- if newHeight < currentHeight then
		-- --Flood receding
		-- end

		-- if newHeight == 0 and GetIsFloodSeason() then
		-- self:SwitchMode("flood")
		-- end

		-- self.inst:PushEvent("floodChange")
	end

	self.LongUpdate = self.OnUpdate

	--------------------------------------------------------------------------
	--[[ Save/Load ]]
	--------------------------------------------------------------------------

	if _ismastersim then
		function self:OnSave()
			local puddles_data = {}
			for key, puddle in pairs(self.puddles) do
				-- puddles_data[point] = puddle:OnSave()
				puddles_data[key] = {
					x = puddle.x,
					z = puddle.z,
					level = puddle.level,
					leveldelta = puddle.leveldelta,
				}
			end
			return {
				puddles = puddles_data,
				_puddles = {}, -- For compatible with old IA flooding component (zarknoope 👎)
			}
		end

		function self:OnLoad(data)
			if data then
				local time = os.clock()
				if data.puddles then
					for key, puddle_data in pairs(data.puddles) do
						if not self.puddles[key] then
							local puddle = CreatePuddle(puddle_data.x, puddle_data.z, puddle_data.level, key)
							puddle.leveldelta = puddle_data.leveldelta
						end
						-- self:SpawnPuddleAtPoint(k):OnLoad(v)
					end
				end
				-- print("flooding cmp loaded in:", os.clock() - time, "sec")
			end
		end
	end

	--------------------------------------------------------------------------
	--[[ Debug ]]
	--------------------------------------------------------------------------

	local function init_debug_icon(icon)
		icon.MiniMapEntity:SetPriority(22) -- Higher than blooonspeed
		icon.MiniMapEntity:SetIcon("rawling.tex")
	end
	function self:ShowPuddles()
		-- Shows all puddles on the map, as rawling
		for _, puddle in pairs(self.puddles) do
			if not puddle.mapicon_entity then
				local icon = SpawnPrefab("globalmapiconunderfog")
				init_debug_icon(icon)
				icon.MiniMapEntity:SetIsProxy(false)
				icon.Transform:SetPosition(self:FloodPointToWorldPos(puddle.x, puddle.z))

				local proxy_icon = SpawnPrefab("globalmapiconunderfog")
				init_debug_icon(proxy_icon)
				proxy_icon:TrackEntity(icon)

				puddle.mapicon_entity = icon
			end
		end
	end

	function self:CountPuddle()
		return GetTableSize(self.puddles)
	end

	function self:RecalculateFloodable() end

	function self:ForcePuddleHeight(level)
		_forcepuddlelevel = level
	end

	function self:RemoveAllPuddles()
		for _, puddle in pairs(self.puddles) do
			RemovePuddle(puddle)
		end
	end
end)
