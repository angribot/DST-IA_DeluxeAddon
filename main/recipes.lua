local env = env
local AddRecipe = GlassicAPI.AddRecipe
local SortAfter = GlassicAPI.RecipeSortAfter
GLOBAL.setfenv(1, GLOBAL)

AddRecipe(
	"spice_jellyfish",
	{ Ingredient("jellyfish_dead", 2), Ingredient("jellyfish", 1) },
	TECH.FOODPROCESSING_ONE,
	{ nounlock = true, numtogive = 2, nochar = true, builder_tag = "professionalchef" }
)
SortAfter("spice_jellyfish", "spice_salt")

AddRecipe("moonglassmachete", { Ingredient("twigs", 2), Ingredient("moonglass", 3) }, TECH.CELESTIAL_THREE, { nounlock = true, nomods = true })
SortAfter("moonglassmachete", "moonglassaxe")

AddRecipe(
	"rock_avocado_fruit",
	{ Ingredient("rocks", 1), Ingredient("seeds", 1) },
	TECH.CELESTIAL_ONE,
	{ nounlock = true, nomods = true, image = "rock_avocado_fruit_rockhard.tex" }
)

local function AquaticRecipe(name, data)
	if AllRecipes[name] then
		--data = {distance=, shore_distance=, platform_distance=, shore_buffer_max=, shore_buffer_min=, platform_buffer_max=, platform_buffer_min=, aquatic_buffer_min=, noshore=}
		data = data or {}
		data.platform_buffer_max = data.platform_buffer_max or (data.platform_distance and math.sqrt(data.platform_distance)) or (data.distance and math.sqrt(data.distance)) or nil
		data.shore_buffer_max = data.shore_buffer_max or (data.shore_distance and ((data.shore_distance + 1) / 2)) or nil
		AllRecipes[name].aquatic = data
		AllRecipes[name].build_mode = BUILDMODE.WATER
	end
end

AddRecipe(
	"boat_obsidian",
	{ Ingredient("obsidian", 4), Ingredient("boards", 6), Ingredient("rope", 3) },
	TECH.OBSIDIAN_TWO,
	{ nounlock = true, placer = "boat_obsidian_placer" },
	{ "SEAFARING" }
)
AquaticRecipe("boat_obsidian", { distance = 4, platform_buffer_min = 2 })
SortAfter("boat_obsidian", "boat_woodlegs")

if env.GetModConfigData("eyebrella_second_recipe") then
	env.AddRecipePostInit("eyebrellahat", function(recipe)
		recipe.ingredient_sets = recipe.ingredient_sets or {}
		recipe.ingredient_sets[RECIPE_GAME_TYPE.SW] = {
			Ingredient("tigereye", 1),
			Ingredient("twigs", 15),
			Ingredient("boneshard", 4),
		}
	end)
end

if env.GetModConfigData("ancient_obsidian_workbench") then
	GlassicAPI.MergeTechBonus("OBSIDIAN_BENCH", "ANCIENT", 4)
end

-----------------------------------------------------------------------------------------------------

local function set_altar_by_type(recname, ingredient_type, worldfn, ingredientfn)
	if FunctionOrValue(worldfn, TheWorld) then
		local recipe = AllRecipes[recname]
		if recipe then
			for _, ingredient in ipairs(recipe.ingredients) do
				if ingredient.type == ingredient_type then
					FunctionOrValue(ingredientfn, ingredient)
				end
			end
		end
	end
end

-- Night Stories compatible
local MOONROCK_TO_OBSIDIAN = {
	"friendshipring",
	"friendshiptotem_dark",
	"friendshiptotem_light",
}

local function world_is_sw(world)
	return world:HasTag("island") or world:HasTag("volcano")
end

local function world_is_volcano(world)
	return world:HasTag("volcano")
end

local function set_type(ingredienttype)
	return function(ing)
		ing.type = ingredienttype
	end
end

local function set_amount(amount)
	return function(ing)
		ing.amount = amount
	end
end

env.AddSimPostInit(function()
	for _, prefab in ipairs(MOONROCK_TO_OBSIDIAN) do
		set_altar_by_type(prefab, "moonrocknugget", world_is_volcano, set_type("obsidian"))
	end
	set_altar_by_type("alterguardianhatshard", "moonglass", world_is_sw, set_amount(40))
	set_altar_by_type("book_wetness", "malbatross_feather", world_is_sw, function(ingredient)
		ingredient.type = "magic_seal"
		ingredient.amount = 1
	end)

	if world_is_sw(TheWorld) and env.GetModConfigData("craftable_atrium_loots") then
		AddRecipe(
			"armorskeleton",
			{ Ingredient("magic_seal", 1), Ingredient("boneshard", 10), Ingredient("nightmarefuel", 6) },
			TECH.LOST,
			{ nounlock = true, nomods = true },
			{ "ARMOUR" }
		)
		AddRecipe(
			"skeletonhat",
			{ Ingredient("magic_seal", 1), Ingredient("boneshard", 10), Ingredient("nightmarefuel", 4) },
			TECH.LOST,
			{ nounlock = true, nomods = true },
			{ "ARMOUR" }
		)
		AddRecipe(
			"thurible",
			{ Ingredient("magic_seal", 1), Ingredient("cutstone", 2), Ingredient("nightmarefuel", 6), Ingredient("ash", 1) },
			TECH.LOST,
			{ nounlock = true, nomods = true },
			{ "TOOLS" }
		)
	end
end)
