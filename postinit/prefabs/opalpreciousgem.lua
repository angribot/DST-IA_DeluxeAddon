if not GetModConfigData("moonglass_octopusking") then
	return
end

local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function get_random_value(inst)
	inst.components.tradable.dubloonvalue = math.random(20, 40)
end

AddPrefabPostInit("opalpreciousgem", function(inst)
	if not TheWorld.ismastersim then
		return
	end

	inst:AddTag("trinket")

	if not inst.components.tradable then
		inst:AddComponent("tradable")
	end
	get_random_value(inst)
	inst:ListenForEvent("stacksizechange", get_random_value)
end)
