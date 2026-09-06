local prefabs = {}

table.insert(
	prefabs,
	CreatePrefabSkin("cutlass_malbatross", {
		base_prefab = "cutlass",
		type = "item",
		rarity = "Glassic",
		assets = {
			Asset("DYNAMIC_ANIM", "anim/dynamic/cutlass_malbatross.zip"),
			Asset("PKGREF", "anim/dynamic/cutlass_malbatross.dyn"),
		},
		init_fn = cutlass_init_fn,
		skin_tags = { "CUTLASS" },
	})
)

table.insert(
	prefabs,
	CreatePrefabSkin("double_umbrellahat_summer", {
		base_prefab = "double_umbrellahat",
		type = "item",
		rarity = "Glassic",
		assets = {
			Asset("DYNAMIC_ANIM", "anim/dynamic/double_umbrellahat_summer.zip"),
			Asset("PKGREF", "anim/dynamic/double_umbrellahat_summer.dyn"),
		},
		init_fn = GlassicAPI.BasicInitFn,
		skin_tags = { "DOUBLE_UMBRELLAHAT" },
	})
)

table.insert(
	prefabs,
	CreatePrefabSkin("aerodynamichat_shark", {
		base_prefab = "aerodynamichat",
		type = "item",
		rarity = "Glassic",
		assets = {
			Asset("DYNAMIC_ANIM", "anim/dynamic/aerodynamichat_shark.zip"),
			Asset("PKGREF", "anim/dynamic/aerodynamichat_shark.dyn"),
		},
		init_fn = GlassicAPI.BasicInitFn,
		skin_tags = { "AERODYNAMICHAT" },
	})
)

table.insert(
	prefabs,
	CreatePrefabSkin("aerodynamichat_tigershark", {
		base_prefab = "aerodynamichat",
		type = "item",
		rarity = "Glassic",
		assets = {
			Asset("DYNAMIC_ANIM", "anim/dynamic/aerodynamichat_tigershark.zip"),
			Asset("PKGREF", "anim/dynamic/aerodynamichat_tigershark.dyn"),
		},
		init_fn = GlassicAPI.BasicInitFn,
		skin_tags = { "AERODYNAMICHAT" },
	})
)

table.insert(
	prefabs,
	CreatePrefabSkin("spear_obsidian_spinner", {
		base_prefab = "spear_obsidian",
		type = "item",
		rarity = "Glassic",
		assets = {
			Asset("DYNAMIC_ANIM", "anim/dynamic/spear_obsidian_spinner.zip"),
			Asset("PKGREF", "anim/dynamic/spear_obsidian_spinner.dyn"),
		},
		init_fn = spear_obsidian_init_fn,
		skin_tags = { "SPEAR_OBSIDIAN" },
	})
)

return unpack(prefabs)
