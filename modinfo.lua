local function zheng(zh, en)
	local LOC = {
		zh = zh,
		zht = zh,
	}
	return LOC[locale] or en
end

version = "1.15.1"
name = zheng("岛屿冒险：豪华补充包", "Island Adventures: Deluxe Addon")
author = "Civi, Tony, Jerry, Yulong"
changelog = zheng(
	[[
- 清理了弃用的洪水代码

最近更新：
- 清理旧配方覆盖，材料交还游戏本体与 IA 管理
- 移除旧多配方设置项
- 修复 Civi 对四种 IA 食物增益的等级延时、重复食用和读档处理，移除重复食物效果（暗夜故事集兼容项）
- 月书材料不再受星杖交易设置影响
- 骨三件套制作仅受自身设置与海难世界条件控制
]],
	[[
- Remove deprecated flood component override

Recent Changes:
- Remove legacy ingredient overrides and the old multi-recipe option; defer ingredients to DST and IA
- Fix Civi's level-based duration scaling, refresh, and save-load handling for four IA food buffs; remove duplicate food effects (Night Stories compat)
- Decouple moon book ingredients from the star-staff trading option
- Control craftable Atrium loot only through its own option and SW world conditions
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
