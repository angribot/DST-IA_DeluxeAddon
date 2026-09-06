local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("dragoonheart", function(inst)
	if not TheWorld.ismastersim then
		return
	end
	inst:AddComponent("dragoonfuel")
end)
