local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("rocks", function(inst)
	if not TheWorld.ismastersim then
		return
	end

	inst:AddComponent("halloweenmoonmutable")
	inst.components.halloweenmoonmutable:SetPrefabMutated("rock_avocado_fruit")
end)
