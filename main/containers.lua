GLOBAL.setfenv(1, GLOBAL)
local params = require("containers").params

local boat_obsidian = {
	widget = {
		slotpos = {},
		animbank = "boat_hud_raft",
		animbuild = "boat_hud_raft",
		pos = Vector3(0, 0, 0),
		badgepos = Vector3(0, 40, 0),
		equipslotroot = Vector3(-80, 40, 0),
		--side_align_tip = -500,
	},
	inspectwidget = {
		slotpos = {},
		animbank = "boat_inspect_raft",
		animbuild = "boat_inspect_raft",
		pos = Vector3(200, 0, 0),
		badgepos = Vector3(0, 5, 0),
		equipslotroot = Vector3(40, -45, 0),
	},
	type = "boat",
	side_align_tip = -500,
	canbeopened = false,
	hasboatequipslots = true,
	hideboatequipslots = true,
}

params["boat_obsidian"] = boat_obsidian
