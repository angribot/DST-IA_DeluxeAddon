local AddPrefabPostInitAny = AddPrefabPostInitAny
GLOBAL.setfenv(1, GLOBAL)

local function get_level_mult(inst)
	local mult = 1
	if inst and inst.prefab == "civi" then
		mult = 1 + inst.level * 0.25
	end
	return mult
end

local function edible_buff_postinit(inst)
	if not TheWorld.ismastersim then
		return
	end
	if not inst.components.edible then
		return
	end

	local edible = inst.components.edible
	if edible.caffeinedelta and edible.caffeinedelta ~= 0 and edible.caffeineduration and edible.caffeineduration ~= 0 then
		local _oneaten = edible.oneaten
		edible.oneaten = function(inst, eater)
			if _oneaten then
				_oneaten(inst, eater)
			end
			if eater and eater.components.locomotor then
				local level_mult = get_level_mult(eater)
				eater.components.locomotor:SetExternalSpeedAdder(eater, "CAFFEINE", edible.caffeinedelta, edible.caffeineduration * level_mult)
			end
		end
	end

	if edible.surferdelta and edible.surferdelta ~= 0 and edible.surferduration and edible.surferduration ~= 0 then
		local _oneaten = edible.oneaten
		edible.oneaten = function(inst, eater)
			if _oneaten then
				_oneaten(inst, eater)
			end
			if eater and eater.components.locomotor then
				local level_mult = get_level_mult(eater)
				eater.components.locomotor:SetExternalSpeedAdder(eater, "SURF", edible.surferdelta, edible.surferduration * level_mult)
			end
		end
	end

	if edible.autodrydelta and edible.autodrydelta ~= 0 and edible.autodryduration and edible.autodryduration ~= 0 then
		local _oneaten = edible.oneaten
		edible.oneaten = function(inst, eater)
			if _oneaten then
				_oneaten(inst, eater)
			end
			if eater and eater.components.locomotor then
				local level_mult = get_level_mult(eater)
				eater.components.locomotor:SetExternalSpeedAdder(eater, "AUTODRY", edible.autodrydelta, edible.autodryduration * level_mult)
			end
		end
	end

	if edible.autocooldelta and edible.autocooldelta ~= 0 then
		local _oneaten = edible.oneaten
		edible.oneaten = function(inst, eater)
			if _oneaten then
				_oneaten(inst, eater)
			end
			if eater and eater.components.temperature then
				local current_temp = eater.components.temperature:GetCurrent()
				local new_temp = math.max(current_temp - edible.autocooldelta, TUNING.STARTING_TEMP)
				eater.components.temperature:SetTemperature(new_temp)
			end
		end
	end

	if edible.naughtyvalue and edible.naughtyvalue > 0 then
		local _oneaten = edible.oneaten
		edible.oneaten = function(inst, eater)
			if _oneaten then
				_oneaten(inst, eater)
			end
			if TheWorld.components.kramped and eater:HasTag("player") then
				TheWorld.components.kramped:OnNaughtyAction(edible.naughtyvalue, eater)
			end
		end
	end
end

AddPrefabPostInitAny(edible_buff_postinit)
