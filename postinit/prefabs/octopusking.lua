if not GetModConfigData("starstuff_octopusking") then
	return
end

local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("octopusking", function(inst)
	if not TheWorld.ismastersim then
		return
	end

	local accept_test_fn = inst.components.trader and inst.components.trader.test
	if accept_test_fn then
		inst.components.trader:SetAcceptTest(function(inst, item, giver)
			if item.prefab == "yellowstaff" and TheWorld.state.moonphase ~= "full" then
				return false
			end
			return accept_test_fn(inst, item, giver)
		end)
	end

	if not OCTOPUSKING_LOOT.chestloot["yellowstaff"] then
		OCTOPUSKING_LOOT.chestloot["yellowstaff"] = "opalstaff"
	end
end)
