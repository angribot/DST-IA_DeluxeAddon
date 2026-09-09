local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("spear_obsidian", function(inst)
	if not TheWorld.ismastersim then
		return
	end

	local obsidiantool = inst.components.obsidiantool
	local onchargedelta = obsidiantool.onchargedelta
	obsidiantool.onchargedelta = function(inst, old, new)
		if onchargedelta then
			onchargedelta(inst, old, new)
		end

		local skin_build = inst:GetSkinBuild()
		if not skin_build then
			return
		end

		local suffix = obsidiantool:GetAnimSuffix()
		if inst.components.floater then
			inst.components.floater:UpdateAnimations("spear_water" .. suffix, "idle" .. suffix)
		end
		local equipper = inst.components.equippable and inst.components.equippable:IsEquipped() and inst.components.inventoryitem and inst.components.inventoryitem:GetGrandOwner()
		if equipper then
			equipper.AnimState:OverrideSymbol("swap_object", skin_build, "swap_spear" .. suffix)
		end
	end
end)
