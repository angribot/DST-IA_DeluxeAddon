GLOBAL.setfenv(1, GLOBAL)

local writeables = require("writeables")

local boat_weight = {
	prompt = "", -- Unused
	animbank = "ui_board_5x3",
	animbuild = "ui_board_5x3",
	menuoffset = Vector3(6, -70, 0),

	cancelbtn = {
		text = STRINGS.BEEFALONAMING.MENU.CANCEL,
		cb = nil,
		control = CONTROL_CANCEL,
	},

	acceptbtn = {
		text = STRINGS.BEEFALONAMING.MENU.ACCEPT,
		cb = nil,
		control = CONTROL_ACCEPT,
	},
}

writeables.AddLayout("boat_obsidian", boat_weight)
writeables.AddLayout("player_boat_obsidian", boat_weight)
