GLOBAL.setfenv(1, GLOBAL)

local function ia_basic_clear_fn(inst, def_build)
	inst.AnimState:SetBuild(def_build)
	if inst.components.inventoryitem then
		inst.components.inventoryitem:ChangeImageName()
	end
	-- if inst.components.floater ~= nil then               -- IA doesn't use this to update water anim, so basic_clear_fn sucks.
	--     if inst.components.floater:IsFloating() then
	--         inst.components.floater:SwitchToDefaultAnim(true)
	--         inst.components.floater:SwitchToFloatAnim()
	--     end
	-- end
end

cutlass_init_fn = function(inst)
	GlassicAPI.BasicInitFn(inst)
	inst.components.floater:UpdateAnimations("idle_water_malbatross", "idle")
end

cutlass_clear_fn = function(inst)
	ia_basic_clear_fn(inst, "cutlass")
	inst.components.floater:UpdateAnimations("idle_water", "idle")
end

-- Upstream clear resets floating hats to prefab-name banks instead of their hat banks.
local double_umbrellahat_clear = double_umbrellahat_clear_fn
double_umbrellahat_clear_fn = function(inst, ...)
	double_umbrellahat_clear(inst, ...)
	inst.AnimState:SetBank("hat_double_umbrella")
end

local aerodynamichat_clear = aerodynamichat_clear_fn
aerodynamichat_clear_fn = function(inst, ...)
	aerodynamichat_clear(inst, ...)
	inst.AnimState:SetBank("hat_aerodynamic")
end

local function refresh_spear_skin(inst, skin_build)
	local obsidiantool = inst.components.obsidiantool
	local suffix = obsidiantool and obsidiantool:GetAnimSuffix() or ""
	inst.components.floater:UpdateAnimations((skin_build and "spear_water" or "idle_water") .. suffix, "idle" .. suffix)

	local equipper = inst.components.equippable and inst.components.equippable:IsEquipped() and inst.components.inventoryitem and inst.components.inventoryitem:GetGrandOwner()
	if equipper then
		equipper.AnimState:OverrideSymbol("swap_object", skin_build or "swap_spear_obsidian", "swap_spear" .. suffix)
	end
end

spear_obsidian_init_fn = function(inst)
	GlassicAPI.BasicInitFn(inst)
	refresh_spear_skin(inst, inst:GetSkinBuild())
end

spear_obsidian_clear_fn = function(inst)
	ia_basic_clear_fn(inst, "spear_obsidian")
	refresh_spear_skin(inst)
end

GlassicAPI.SetOnequipSkinItem("cutlass", { "swap_object", "swap_cutlass", "swap_cutlass" })
GlassicAPI.SetOnequipSkinItem("spear_obsidian", { "swap_object", "swap_spear", "swap_spear" })

GlassicAPI.SkinHandler.AddModSkins({
	cutlass = { "cutlass_malbatross" },
	double_umbrellahat = { "double_umbrellahat_summer" },
	aerodynamichat = { "aerodynamichat_shark", "aerodynamichat_tigershark" },
	spear_obsidian = { "spear_obsidian_spinner" },
})
