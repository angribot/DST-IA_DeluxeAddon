local function loc(t)
	t.zht = t.zht or t.zh
	return t[locale] or t.en
end

local function zh_en(a, b)
	return loc({
		zh = a,
		en = b,
	})
end

version = "1.14.0"
name = zh_en("岛屿冒险：豪华补充包", "Island Adventures: Deluxe Addon")
author = "Civi, Tony, Jerry, Yulong"
changelog = zh_en(
	[[
- 适配兼容岛屿冒险最新本体(2026-09-06)
]],
	[[
- Make compatible with IA (2026-09-06)
]]
)
description = zh_en("版本: ", "Version: ")
	.. version
	.. zh_en("\n\n更新内容:\n", "\n\nChangelog:\n")
	.. changelog
	.. zh_en("\n“让你的岛屿冒险更加丰富！”", '\n"Make IA great L again."')
api_version = 10
dst_compatible = true
all_clients_require_mod = true

icon_atlas = "images/modicon.xml"
icon = "modicon.tex"

server_filter_tags = {
	"island_adventures",
	"island adventures",
	"island",
	"adventures",
	"shipwrecked",
}

folder_name = folder_name or "workshop-"
if not folder_name:find("workshop-") then
	name = name .. " - DEV"
end

mod_dependencies = {
	{ -- Glassic API
		workshop = "workshop-2521851770",
		["GlassicAPI"] = false,
		["Glassic API - DEV"] = true,
	},
	{ -- Island Adventures
		workshop = "workshop-1467214795",
		["IslandAdventures"] = false,
		["Island Adventures - GitLab Ver."] = true,
	},
}

local function AddTitle(title, hover)
	return {
		name = title,
		hover = hover,
		options = { { description = "", data = false } },
		default = false,
	}
end

local boolean = {
	{ description = zh_en("启用", "Yes"), data = true },
	{ description = zh_en("禁用", "No"), data = false },
}

configuration_options = {
	AddTitle(zh_en("- 世界相关 -", "- The World -")),
	{
		name = "dragoonfly",
		label = zh_en("龙蝇震撼回归火山", "Dragonfly"),
		hover = zh_en("龙蝇会刷新在火山区域\n仅在世界生成时启用才会生效", "Dragonfly spawns in the Volcano.\nOnly available at worldgen stage."),
		options = boolean,
		default = true,
	},
	{
		name = "starstuff_octopusking",
		label = zh_en("用星杖交易换取月杖", "Star Stuff Trading"),
		hover = zh_en("满月时可以与章鱼王交易换取", "Trade with Octopus King, only available during full moon"),
		options = boolean,
		default = true,
	},
	{
		name = "moonglass_octopusking",
		label = zh_en("满月时交易月亮碎片", "Moon Glass Trading"),
		hover = zh_en("满月时可以与章鱼王交易换取月亮碎片而非金币", "Trade for Moon Glass with Octopus King during full moon instead of Dubloon"),
		options = boolean,
		default = true,
	},
	{
		name = "wet_quacken",
		label = zh_en("海妖常驻潮湿", "Quacken always wet"),
		options = boolean,
		default = true,
	},
	{
		name = "fish_farm_no_predators",
		label = zh_en("鱼农场不刷狗", "Ban predators for fish farm"),
		options = boolean,
		default = true,
	},
	AddTitle(zh_en("- 玩家相关 -", "- The Player -")),
	{
		name = "wx78_charge_via_zappy_food",
		label = zh_en("机器人吃电料理充电", "WX78 charge via zappy food"),
		options = boolean,
		default = true,
	},
	AddTitle(zh_en("- 配方相关 -", "- The Crafting -")),
	{
		name = "nope_gem_ingredients",
		label = zh_en("移除宝石核心的多配方支持", "Nope Gem Core Ingredients"),
		hover = zh_en("配方材料会根据世界类型自动判断", "Ingredients are judged by world type automatically."),
		options = boolean,
		default = true,
	},
	{
		name = "eyebrella_second_recipe",
		label = zh_en("虎鲨眼作为眼球伞的第二配方", "Tiger Eye as Eyebrella's ingredient"),
		options = boolean,
		default = true,
	},
	{
		name = "ancient_obsidian_workbench",
		label = zh_en("远古黑曜石工作台", "Ancient Obsidian Workbench"),
		hover = zh_en("黑曜石工作台可以合成远古科技", "Enable crafting ancient tech at obsidian workbench."),
		options = boolean,
		default = true,
	},
	{
		name = "wx78_jellyfishbrain",
		label = zh_en("睿智帽可以制作机器人模块", "WX Modules in Brain of Thought"),
		options = boolean,
		default = true,
	},
	{
		name = "craftable_atrium_loots",
		label = zh_en("睿智帽可以制作骨三件套", "Craftable Atrium Loots"),
		hover = zh_en("远古织影者的战利品三件套可以在睿智帽里制作", "Loots from Ancient Fuelweaver can be crafted via Brain of Thought."),
		options = boolean,
		default = true,
	},
	AddTitle(zh_en("- 语言相关 -", "- The Translator -")),
	{
		name = "e_yu",
		label = zh_en("使用鹅语", "Enable 'e_yu'"),
		hover = zh_en("启用一些奇怪的翻译", "Enable some strange zh translations"),
		options = boolean,
		default = false,
	},
}
