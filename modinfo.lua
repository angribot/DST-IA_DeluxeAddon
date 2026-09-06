local function zheng(zh, en)
	local LOC = {
		zh = zh,
		zht = zh,
	}
	return LOC[locale] or en
end

version = "1.14.2"
name = zheng("岛屿冒险：豪华补充包", "Island Adventures: Deluxe Addon")
author = "Civi, Tony, Jerry, Yulong"
changelog = zheng(
	[[
- 移除机器人用睿智帽制作模块、吃死水母充电的补丁（IA 已自带）

最近更新：
- 修复驾驶黑曜石船时手上物品消失
- 适配兼容岛屿冒险最新本体(2026-09-06)
]],
	[[
- Remove patches for crafting WX78 modules with Brain of Thought and charging from dead jellyfish (now included in IA)

Recent Changes:
- Fix held item visibility while sailing the obsidian boat
- Make compatible with IA (2026-09-06)
]]
)
description = zheng("版本: ", "Version: ")
	.. version
	.. zheng("\n\n更新内容:\n", "\n\nChanges:\n")
	.. changelog
	.. zheng("\n“让你的岛屿冒险更加丰富！”", '\n"Make IA great L again."')
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
	{ description = zheng("启用", "Yes"), data = true },
	{ description = zheng("禁用", "No"), data = false },
}

configuration_options = {
	AddTitle(zheng("- 世界相关 -", "- The World -")),
	{
		name = "dragoonfly",
		label = zheng("龙蝇震撼回归火山", "Dragonfly"),
		hover = zheng("龙蝇会刷新在火山区域\n仅在世界生成时启用才会生效", "Dragonfly spawns in the Volcano.\nOnly available at worldgen stage."),
		options = boolean,
		default = true,
	},
	{
		name = "starstuff_octopusking",
		label = zheng("用星杖交易换取月杖", "Star Stuff Trading"),
		hover = zheng("满月时可以与章鱼王交易换取", "Trade with Octopus King, only available during full moon"),
		options = boolean,
		default = true,
	},
	{
		name = "moonglass_octopusking",
		label = zheng("满月时交易月亮碎片", "Moon Glass Trading"),
		hover = zheng("满月时可以与章鱼王交易换取月亮碎片而非金币", "Trade for Moon Glass with Octopus King during full moon instead of Dubloon"),
		options = boolean,
		default = true,
	},
	{
		name = "wet_quacken",
		label = zheng("海妖常驻潮湿", "Quacken always wet"),
		options = boolean,
		default = true,
	},
	{
		name = "fish_farm_no_predators",
		label = zheng("鱼农场不刷狗", "Ban predators for fish farm"),
		options = boolean,
		default = true,
	},
	AddTitle(zheng("- 玩家相关 -", "- The Player -")),
	{
		name = "wx78_charge_via_zappy_food",
		label = zheng("机器人吃水母调味料理充电", "WX78 charge via Zappy Powder dishes"),
		options = boolean,
		default = true,
	},
	AddTitle(zheng("- 配方相关 -", "- The Crafting -")),
	{
		name = "nope_gem_ingredients",
		label = zheng("移除宝石核心的多配方支持", "Nope Gem Core Ingredients"),
		hover = zheng("配方材料会根据世界类型自动判断", "Ingredients are judged by world type automatically."),
		options = boolean,
		default = true,
	},
	{
		name = "eyebrella_second_recipe",
		label = zheng("虎鲨眼作为眼球伞的第二配方", "Tiger Eye as Eyebrella's ingredient"),
		options = boolean,
		default = true,
	},
	{
		name = "ancient_obsidian_workbench",
		label = zheng("远古黑曜石工作台", "Ancient Obsidian Workbench"),
		hover = zheng("黑曜石工作台可以合成远古科技", "Enable crafting ancient tech at obsidian workbench."),
		options = boolean,
		default = true,
	},
	{
		name = "craftable_atrium_loots",
		label = zheng("睿智帽可以制作骨三件套", "Craftable Atrium Loots"),
		hover = zheng("远古织影者的战利品三件套可以在睿智帽里制作", "Loots from Ancient Fuelweaver can be crafted via Brain of Thought."),
		options = boolean,
		default = true,
	},
	AddTitle(zheng("- 语言相关 -", "- The Translator -")),
	{
		name = "e_yu",
		label = zheng("使用鹅语", "Enable 'e_yu'"),
		hover = zheng("启用一些奇怪的翻译", "Enable some strange zh translations"),
		options = boolean,
		default = false,
	},
}
