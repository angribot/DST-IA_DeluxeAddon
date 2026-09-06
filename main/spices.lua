local env = env
GLOBAL.setfenv(1, GLOBAL)

local function oneaten_jellyfish(inst, eater)
	eater:AddDebuff("buff_electricattack", "buff_electricattack")
end

IA_SPICES = {
	SPICE_JELLYFISH = {
		oneatenfn = oneaten_jellyfish,
		prefabs = { "buff_electricattack" },
	},
}

require("cooking")
local spicedfoods = require("spicedfoods")
local UpvalueUtil = GlassicAPI.UpvalueUtil
local wx78_chargable = env.GetModConfigData("wx78_charge_via_zappy_food") and 1 or nil

local SPICES = UpvalueUtil.GetUpvalue(GenerateSpicedFoods, "SPICES")
if not SPICES then
	return
end
shallowcopy(IA_SPICES, SPICES)

GenerateSpicedFoods(require("preparedfoods"))
GenerateSpicedFoods(require("preparedfoods_warly"))

for name, recipe in pairs(spicedfoods) do
	if IA_SPICES[recipe.spice] then
		AddCookerRecipe("portablespicer", recipe)
		if recipe.spice == "SPICE_JELLYFISH" then
			TUNING.WX78_CHARGING_FOODS[name] = wx78_chargable or TUNING.WX78_CHARGING_FOODS[name]
		end
	end
end

local ia_spicedfoods = ia_require("main/ia_spicedfoods")
local _spicedfoods = shallowcopy(spicedfoods)
GenerateSpicedFoods(ia_require("main/ia_preparedfoods"))
GenerateSpicedFoods(ia_require("main/ia_preparedfoods_warly"))
local ia_spiced = {}
for name, recipe in pairs(spicedfoods) do
	if not _spicedfoods[name] then
		ia_spiced[name] = recipe
	end
end
for name, recipe in pairs(ia_spiced) do
	env.AddCookerRecipe("portablespicer", recipe)
	if recipe.spice == "SPICE_JELLYFISH" then
		TUNING.WX78_CHARGING_FOODS[name] = wx78_chargable or TUNING.WX78_CHARGING_FOODS[name]
	end
	ia_spicedfoods[name] = recipe
	-- IA creates these prefabs; keep them out of the vanilla prefab list.
	spicedfoods[name] = nil
end

------------------------------------------------

local anim_state_override_symbol = AnimState.OverrideSymbol
function AnimState:OverrideSymbol(symbol, override_build, override_symbol, ...)
	if symbol == "swap_garnish" and override_build == "spices" and IA_SPICES[override_symbol:upper()] then
		override_build = "ia_spices"
	end
	return anim_state_override_symbol(self, symbol, override_build, override_symbol, ...)
end
