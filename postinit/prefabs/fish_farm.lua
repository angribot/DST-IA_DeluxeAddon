if not GetModConfigData("fish_farm_no_predators") then
	return
end

local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("fish_farm", function(inst)
	if not TheWorld.ismastersim then
		return
	end

	if inst.components.breeder then
		inst.components.breeder.haspredators = false
	end
end)
