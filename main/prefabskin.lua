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

-- double_umbrellahat_init_fn = function(inst, skinname)
--     GlassicAPI.BasicInitFn(inst, skinname)
-- end

double_umbrellahat_clear_fn = function(inst)
	ia_basic_clear_fn(inst, "hat_double_umbrella")
end

-- aerodynamichat_init_fn = function(inst, skinname)
--     GlassicAPI.BasicInitFn(inst, skinname)
-- end

aerodynamichat_clear_fn = function(inst)
	ia_basic_clear_fn(inst, "hat_aerodynamic")
end

spear_obsidian_init_fn = function(inst)
	GlassicAPI.BasicInitFn(inst)
	inst.components.floater:UpdateAnimations("spear_water", "idle")
end

spear_obsidian_clear_fn = function(inst)
	ia_basic_clear_fn(inst, "spear_obsidian")
	inst.components.floater:UpdateAnimations("idle_water", "idle")
end

GlassicAPI.SetOnequipSkinItem("cutlass", { "swap_object", "swap_cutlass", "swap_cutlass" })
GlassicAPI.SetOnequipSkinItem("spear_obsidian", { "swap_object", "swap_spear", "swap_spear" })

GlassicAPI.SkinHandler.AddModSkins({
	cutlass = { "cutlass_malbatross" },
	double_umbrellahat = { "double_umbrellahat_summer" },
	aerodynamichat = { "aerodynamichat_shark", "aerodynamichat_tigershark" },
	spear_obsidian = { "spear_obsidian_spinner" },
})
