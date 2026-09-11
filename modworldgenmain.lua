if not GetModConfigData("dragoonfly") then
	return
end
local AddTaskSetPreInit = AddTaskSetPreInit
local StaticLayout = require("map/static_layout")
local AllLayouts = require("map/layouts").Layouts
GLOBAL.setfenv(1, GLOBAL)

AllLayouts["VolcanoDragonflyArena"] = StaticLayout.Get("map/static_layouts/volcano_dragonfly", {
	start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
	fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
	layout_position = LAYOUT_POSITION.CENTER,
	disable_transform = true,
})
AllLayouts["VolcanoDragonflyArena"].ground_types = { WORLD_TILES.BRICK_GLOW }

AddTaskSetPreInit("volcano", function(taskset)
	taskset.set_pieces = taskset.set_pieces or {}
	taskset.required_prefabs = taskset.required_prefabs or {}

	taskset.set_pieces.VolcanoDragonflyArena = { count = 1, tasks = { "Volcano" } }
	table.insert(taskset.required_prefabs, "dragonfly_spawner")
end)
