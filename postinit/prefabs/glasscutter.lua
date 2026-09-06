local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("glasscutter", function(inst)
	if not TheWorld.ismastersim then
		return
	end

	if inst.components.tool then
		inst:RemoveComponent("tool")
	end
end)
