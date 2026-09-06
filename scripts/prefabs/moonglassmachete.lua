local assets = {
	Asset("ANIM", "anim/glassmachete.zip"),
}

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "glassmachete", "swap_glassmachete")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

local function pristinefn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("glassmachete")
	inst.AnimState:SetBuild("glassmachete")
	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("sharp")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

	return inst
end

local function masterfn(inst)
	inst:AddComponent("inventoryitem")

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.MOONGLASSMACHETE.DAMAGE)

	-----
	inst:AddComponent("tool")
	inst.components.tool:SetAction(ACTIONS.HACK)
	inst.components.tool:SetAction(ACTIONS.HACK, TUNING.MOONGLASSMACHETE.EFFECTIVENESS)
	-------
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.MACHETE_USES)
	inst.components.finiteuses:SetUses(TUNING.MACHETE_USES)
	inst.components.finiteuses:SetOnFinished(inst.Remove)
	inst.components.finiteuses:SetConsumption(ACTIONS.HACK, TUNING.MOONGLASSMACHETE.CONSUMPTION)
	-------
	inst:AddComponent("equippable")

	inst:AddComponent("inspectable")

	inst.components.equippable:SetOnEquip(onequip)

	inst.components.equippable:SetOnUnequip(onunequip)

	MakeHauntableLaunch(inst)

	return inst
end

local function fn()
	local inst = pristinefn()

	inst:AddComponent("symbolswapdata")
	inst.components.symbolswapdata:SetData("glassmachete", "swap_glassmachete")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	masterfn(inst)

	return inst
end

return Prefab("moonglassmachete", fn, assets)
