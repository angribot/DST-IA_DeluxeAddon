local MODROOT = MODROOT
local GetModConfigData = GetModConfigData
GLOBAL.setfenv(1, GLOBAL)

local strings = {
	NAMES = {
		BOAT_OBSIDIAN = "Obsidian Boat",
		SPICE_JELLYFISH = "Zappy Powder",
		SPICE_JELLYFISH_FOOD = "Zappy {food}",
		MOONGLASSMACHETE = "Moon Glass Machete",
	},
	RECIPE_DESC = {
		BOAT_OBSIDIAN = "A boat fueled with special material.",
		SPICE_JELLYFISH = "The feeling of volt jelly.",
		MOONGLASSMACHETE = STRINGS.RECIPE_DESC.MOONGLASSAXE,
		ROCK_AVOCADO_FRUIT = "The strength of the moon makes it reborn.",
		ARMORSKELETON = STRINGS.CHARACTERS.GENERIC.DESCRIBE.ARMORSKELETON,
		SKELETONHAT = STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKELETONHAT,
		THURIBLE = STRINGS.CHARACTERS.GENERIC.DESCRIBE.THURIBLE,
	},
	CHARACTERS = {
		GENERIC = {
			DESCRIBE = {
				BOAT_OBSIDIAN = {
					GENERIC = "I need something to boost it.",
					ACTIVE = "Amazing volcanic science!",
				},
				SPICE_JELLYFISH = "Zap left.",
				MOONGLASSMACHETE = STRINGS.CHARACTERS.GENERIC.DESCRIBE.MOONGLASSAXE,
			},
		},
	},
	SKIN_NAMES = {
		cutlass_malbatross = STRINGS.NAMES.MALBATROSS_BEAK,
		double_umbrellahat_summer = "Summerella",
		aerodynamichat_shark = "Sharkness",
		aerodynamichat_tigershark = "Tiger Shark",
		spear_obsidian_spinner = "Spinner",
	},
}

GlassicAPI.MergeStringsToGLOBAL(strings)
GlassicAPI.MergeTranslationFromPO(MODROOT .. "languages")

if GetModConfigData("e_yu") then
	GlassicAPI.MergeTranslationFromPO(MODROOT .. "languages/e_yu")
end

function UpdateIADStrings()
	local file, errormsg = io.open(MODROOT .. "languages/strings.pot", "w")
	if not file then
		print("Can't generate " .. MODROOT .. "languages/strings.pot" .. "\n" .. tostring(errormsg))
		return
	end
	GlassicAPI.MakePOTFromStrings(file, strings)
end
