if not GetModConfigData("wet_quacken") then
	return
end

local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("kraken", function(inst)
	if not inst:HasTag("wet") then
		inst:AddTag("wet")
	end
end)
