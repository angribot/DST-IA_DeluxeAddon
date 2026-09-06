GLOBAL.setfenv(1, GLOBAL)

local AddNetworkProxy = UpvalueHacker.GetUpvalue(Entity.AddNetwork, "AddNetworkProxy")
if not AddNetworkProxy then
	AddNetworkProxy = Entity.AddNetwork
	print("WARNING: IA could not find AddNetworkProxy, tides and flood are going to be very laggy!")
end

NO_PUDDLE_GROUNDS = {
	[WORLD_TILES.WOODFLOOR] = true,
	[WORLD_TILES.CARPET] = true,
	[WORLD_TILES.CHECKER] = true,
	[WORLD_TILES.SCALE] = true,
	[WORLD_TILES.SNAKESKIN] = true,
	[WORLD_TILES.ROAD] = true,
}

-- :muted:
local function set_tile_state(x, y, key, val, ...)
	local w, h = TheWorld.Map:GetSize()
	x = x / TILE_SCALE + w / 2
	y = y / TILE_SCALE + h / 2
	return SetTileState(x, y, key, val, ...)
end

local function OnRemove(inst)
	if not inst.flood_x then
		return
	end
	if not TheWorld.ismastersim then
		TheWorld.components.flooding:RemoveFloodTile(inst)
	end
	-- set_tile_state(inst.flood_x, inst.flood_z, "flood", nil)
	local x, _, z = inst.Transform:GetWorldPosition()
	set_tile_state(x, z, "flood", nil)
end

local function network_flood_fn()
	local inst = CreateEntity()

	AddNetworkProxy(inst.entity)
	inst.entity:AddTransform()

	inst:AddTag("CLASSIFIED")

	inst.persists = false

	if not TheNet:IsDedicated() then
		inst:DoTaskInTime(0, function(inst)
			local x, y, z = inst.Transform:GetWorldPosition()
			if not TheWorld.ismastersim then
				TheWorld.components.flooding:AddFloodTile(inst)
				inst.flood_x, inst.flood_z = TheWorld.components.flooding:WorldPosToFloodPoint(x, y, z)
			end
			-- set_tile_state(inst.flood_x, inst.flood_z, "flood", true)
			set_tile_state(x, z, "flood", true)
		end)
		inst.OnRemoveEntity = OnRemove
	end

	return inst
end

local prefab_ctor = Prefab._ctor
function Prefab._ctor(self, name, fn, ...)
	if name == "network_flood" then
		fn = network_flood_fn
	end
	return prefab_ctor(self, name, fn, ...)
end
