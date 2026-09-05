local env = env
local AddRecipe = GlassicAPI.AddRecipe
local SortAfter = GlassicAPI.RecipeSortAfter
GLOBAL.setfenv(1, GLOBAL)

AddRecipe("spice_jellyfish", {Ingredient("jellyfish_dead", 2), Ingredient("jellyfish", 1)}, TECH.FOODPROCESSING_ONE, {nounlock = true, numtogive = 2, nochar = true, builder_tag = "professionalchef"})
SortAfter("spice_jellyfish", "spice_salt")

AddRecipe("moonglassmachete", {Ingredient("twigs", 2), Ingredient("moonglass", 3)}, TECH.CELESTIAL_THREE, {nounlock = true, nomods = true})
SortAfter("moonglassmachete", "moonglassaxe")

AddRecipe("rock_avocado_fruit", {Ingredient("rocks", 1), Ingredient("seeds", 1)}, TECH.CELESTIAL_ONE, {nounlock = true, nomods = true, image = "rock_avocado_fruit_rockhard.tex"})

local function AquaticRecipe(name, data)
    if AllRecipes[name] then
        --data = {distance=, shore_distance=, platform_distance=, shore_buffer_max=, shore_buffer_min=, platform_buffer_max=, platform_buffer_min=, aquatic_buffer_min=, noshore=}
        data = data or {}
        data.platform_buffer_max = data.platform_buffer_max or (data.platform_distance and math.sqrt(data.platform_distance)) or (data.distance and math.sqrt(data.distance)) or nil
        data.shore_buffer_max = data.shore_buffer_max or (data.shore_distance and ((data.shore_distance+1)/2)) or nil
        AllRecipes[name].aquatic = data
    end
end

AddRecipe("boat_obsidian", {Ingredient("obsidian", 4), Ingredient("boards", 6), Ingredient("rope", 3)}, TECH.OBSIDIAN_TWO, {nounlock = true, placer="boat_obsidian_placer"}, {"SEAFARING"})
AquaticRecipe("boat_obsidian", {distance=4, platform_buffer_min=2})
SortAfter("boat_obsidian", "boat_woodlegs")

if env.GetModConfigData("eyebrella_second_recipe") then
    AddRecipePostInit("eyebrellahat", function(recipe)
        recipe.ingredient_sets = recipe.ingredient_sets or {}
        recipe.ingredient_sets[RECIPE_GAME_TYPE.SW] =
        {
            Ingredient("tigereye", 1),
            Ingredient("twigs", 15),
            Ingredient("boneshard", 4),
        }
    end)
end

if env.GetModConfigData("ancient_obsidian_workbench") then
    GlassicAPI.MergeTechBonus("OBSIDIAN_BENCH", "ANCIENT", 4)
end

if env.GetModConfigData("wx78_jellyfishbrain") then
    TECH.LOST.ROBOTMODULECRAFT = 10
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

local function set_altar_by_index(recname, index, worldfn, ingredientfn)
    if FunctionOrValue(worldfn, TheWorld) then
        local recipe = AllRecipes[recname]
        if recipe then
            local ingredient = recipe.ingredients and recipe.ingredients[index]
            if ingredient then
                FunctionOrValue(ingredientfn, ingredient)
            end
        end
    end
end

-- Night Stories compatible
local MOONROCK_TO_OBSIDIAN =
{
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

local function set_ingredients(recname, ingredients)
    local recipe = AllRecipes[recname]
    if recipe then
        recipe.ingredients = ingredients
        recipe.gemdict_ingredients = {}
    end
end

local function set_and_hide_ingredients(recname, ingredients, worldfn, ...)
    set_ingredients(recname, ingredients)
    if FunctionOrValue(worldfn, ...) then
        AllRecipes[recname] = nil
    end
end

env.AddSimPostInit(function()
    for _, prefab in ipairs(MOONROCK_TO_OBSIDIAN) do
        set_altar_by_type(prefab, "moonrocknugget", world_is_volcano, set_type("obsidian"))
    end
    set_altar_by_type("alterguardianhatshard", "moonglass", world_is_sw, set_amount(40))

    if not env.GetModConfigData("nope_gem_ingredients") then return end
    -- anti-nope
    local sw = world_is_sw(TheWorld)
    -- local function set_sw_ingredients(recname, ingredients)
    --     set_and_hide_ingredients(recname, ingredients, not sw)
    -- end

    set_ingredients("bottlelantern",                {Ingredient("ia_messagebottleempty", 1), Ingredient("bioluminescence", 2)})
    set_ingredients("gashat",                       {Ingredient("ia_messagebottleempty", 2), Ingredient("coral", 3), Ingredient("jellyfish", 1)})
    set_ingredients("boat_lantern",                 {Ingredient("ia_messagebottleempty", 1), Ingredient("twigs", 2), Ingredient("fireflies", 1)})
    set_ingredients("seatrap",                      {Ingredient("palmleaf", 4), Ingredient("ia_messagebottleempty", 3), Ingredient("jellyfish", 1)})
    set_ingredients("telescope",                    {Ingredient("ia_messagebottleempty", 1), Ingredient("pigskin", 1), Ingredient("goldnugget", 1)})
    set_ingredients("armor_lifejacket",             {Ingredient("fabric", 2), Ingredient("vine", 2), Ingredient("ia_messagebottleempty", 3)})
    set_ingredients("buoy",                         {Ingredient("ia_messagebottleempty", 1), Ingredient("bioluminescence", 2), Ingredient("bamboo", 4)})

    set_ingredients("wintersfeastoven",             {Ingredient("cutstone", 1), Ingredient(sw and "limestonenugget" or "marble", 1), Ingredient("log", 1)})
    set_ingredients("wintersfeastoven",             {Ingredient("boards", 1), Ingredient(sw and "fabric" or "beefalowool", 1)})
    set_ingredients("turf_carpetfloor",             {Ingredient("boards", 1), Ingredient(sw and "fabric" or "beefalowool", 1)})
    set_ingredients("turf_shellbeach",              {Ingredient("rocks", 1), Ingredient(sw and "seashell" or "slurtle_shellpieces", 1)})
    set_ingredients("endtable",                     {Ingredient(sw and "limestonenugget" or "marble", 2), Ingredient("boards", 2), Ingredient("turf_carpetfloor", 2)})
    set_ingredients("cookbook",                     {Ingredient("papyrus", 1), Ingredient(sw and "sweet_potato" or "carrot", 1)})
    set_ingredients("soil_amender",                 {Ingredient(sw and "ia_messagebottleempty" or "messagebottleempty", 1), Ingredient(sw and "seaweed" or "kelp", 1), Ingredient("ash", 1)})
    set_ingredients("waterballoon",                 {Ingredient(sw and "mosquitosack_yellow" or "mosquitosack", 2), Ingredient("ice", 1)})
    set_ingredients("seedpouch",                    {Ingredient(sw and "seashell" or "slurtle_shellpieces", 2), Ingredient("cutgrass", 4), Ingredient("seeds", 2)})
    set_ingredients("kelphat",                      {Ingredient(sw and "seaweed" or "kelp", 6)})
    set_ingredients("bushhat",                      {Ingredient("strawhat", 1),Ingredient("rope", 1),Ingredient(sw and "dug_berrybush2" or "dug_berrybush", 1)})
    set_ingredients("hawaiianshirt",                {Ingredient("papyrus", 3), Ingredient("silk", 3), Ingredient("cactus_flower", 5)})
    set_ingredients("wintercooking_berrysauce",     {Ingredient("wintersfeastfuel", 1), Ingredient(sw and "mosquitosack_yellow" or "mosquitosack", 2)})
    set_ingredients("wintercooking_bibingka",       {Ingredient("wintersfeastfuel", 1), Ingredient(sw and "jungletreeseed" or "foliage", 2)})
    set_ingredients("wintercooking_lutefisk",       {Ingredient("wintersfeastfuel", 1), Ingredient("spoiled_fish", 1), Ingredient("palmleaf", 1)})
    set_ingredients("wintercooking_pavlova",        {Ingredient("wintersfeastfuel", 1), Ingredient(sw and "hail_ice" or "moon_tree_blossom", 2)})
    set_ingredients("wintercooking_pumpkinpie",     {Ingredient("wintersfeastfuel", 1), Ingredient("ash", 1), Ingredient(sw and "venomgland" or "phlegm", 1)})
    set_ingredients("wintercooking_tourtiere",      {Ingredient("wintersfeastfuel", 1), Ingredient(sw and "coconut" or "acorn", 1), Ingredient(sw and "jungletreeseed" or "pinecone", 1)})
    set_ingredients("halloween_experiment_bravery", {Ingredient(sw and "snakeskin" or "froglegs", 1), Ingredient("goldnugget", 1)})
    set_ingredients("halloween_experiment_health",  {Ingredient(sw and "mosquito_yellow" or "mosquito", 1), Ingredient("red_cap", 1)})
    set_ingredients("halloween_experiment_sanity",  {Ingredient(sw and "toucan" or "crow", 1), Ingredient("petals_evil", 1)})
    set_ingredients("halloween_experiment_root",    {Ingredient(sw and "petals_evil" or "batwing", 1), Ingredient("livinglog", 1)})
    set_ingredients("bernie_inactive",              {Ingredient("beardhair", 2), Ingredient(sw and "fabric" or "beefalowool", 2), Ingredient("silk", 2)})
    set_ingredients("dumbbell_marble",              {Ingredient("marble", 4), Ingredient("twigs", 1)})
    set_ingredients("dumbbell_gem",                 {Ingredient("thulecite", 2), Ingredient("purplegem", 1), Ingredient("twigs", 1)})
    set_ingredients("mermhouse_crafted",            {Ingredient("boards", 4), Ingredient("cutreeds", 3), Ingredient(sw and "fish_tropical" or "pondfish", 2)})
    set_ingredients("mermhat",                      {Ingredient(sw and "fish_tropical" or "pondfish", 1), Ingredient("cutreeds", 1), Ingredient("twigs", 2)})
    -- Battle Songs
    set_ingredients("battlesong_sanitygain",        {Ingredient("papyrus", 1), Ingredient("featherpencil", 1), Ingredient(sw and "coral_brain" or "moonbutterflywings", 1)})
    set_ingredients("battlesong_sanityaura",        {Ingredient("papyrus", 1), Ingredient("featherpencil", 1), Ingredient(sw and "doydoybaby" or "nightmare_timepiece", 1)})
    set_ingredients("battlesong_fireresistance",    {Ingredient("papyrus", 1), Ingredient("featherpencil", 1), Ingredient(sw and "neon_quattro" or "oceanfish_small_9_inv", 1)})
    -- Slingshot and Ammo
    set_ingredients("slingshotammo_marble",         {Ingredient("marble", 1)})
    set_ingredients("slingshotammo_freeze",         {Ingredient("moonrocknugget", 1), Ingredient("bluegem", 1)})
    set_ingredients("slingshotammo_slow",           {Ingredient("moonrocknugget", 1), Ingredient("purplegem", 1)})
    set_ingredients("slingshotammo_thulecite",      {Ingredient("thulecite_pieces", 1), Ingredient("nightmarefuel", 1)})
    set_ingredients("slingshot",                    {Ingredient("twigs", 1), Ingredient(sw and "mosquitosack_yellow" or "mosquitosack", 2)})
    -- Pocket Watches
    set_ingredients("pocketwatch_parts",            {Ingredient("pocketwatch_dismantler", 0), Ingredient(sw and "dubloon" or "thulecite_pieces", 8),Ingredient("nightmarefuel", 2)})
    set_ingredients("pocketwatch_heal",             {Ingredient("pocketwatch_parts", 1), Ingredient(sw and "limestonenugget" or "marble", 2), Ingredient("redgem", 1)})
    set_ingredients("pocketwatch_recall",           {Ingredient("pocketwatch_parts", 2), Ingredient("goldnugget", 2), Ingredient(sw and "ox_horn" or "walrus_tusk", 1)})
    set_ingredients("pocketwatch_weapon",           {Ingredient("pocketwatch_parts", 3), Ingredient(sw and "limestonenugget" or "marble", 4), Ingredient("nightmarefuel", 8)})
    -- WX78
    set_ingredients("wx78module_light",             {Ingredient("scandata", 6), Ingredient(sw and "rainbowjellyfish" or "lightbulb", 1)})
    set_ingredients("wx78module_nightvision",       {Ingredient("scandata", 4), Ingredient(sw and "blowdart_flup" or "mole", 1), Ingredient("fireflies", 1)})
    set_ingredients("wx78module_movespeed",         {Ingredient("scandata", 2), Ingredient(sw and "crab" or "rabbit", 1)})
    set_ingredients("wx78module_maxhunger",         {Ingredient("scandata", 3), Ingredient(sw and "doydoyfeather" or "slurper_pelt", 1), Ingredient("wx78module_maxhunger1", 1)})
    set_ingredients("wx78module_music",             {Ingredient("scandata", 4), sw and Ingredient("seashell", 1) or Ingredient("singingshell_octave3", 1, nil, nil, "singingshell_octave3_3.tex")})
    set_ingredients("wx78module_taser",             {Ingredient("scandata", 5), Ingredient(sw and "jellyfish" or "goatmilk", 1)})
    -- Wickerbottom
    set_ingredients("book_light",                   {Ingredient("papyrus", 2), Ingredient(sw and "rainbowjellyfish_dead" or "lightbulb", 2)})
    set_ingredients("book_fish",                    {Ingredient("papyrus", 2), Ingredient(sw and "roe" or "oceanfishingbobber_ball", 2)})
    set_ingredients("book_rain",                    {Ingredient("papyrus", 2), Ingredient(sw and "doydoyfeather" or "goose_feather", 2)})
    set_ingredients("book_moon",                    {Ingredient("papyrus", 2), Ingredient((sw and not env.GetModConfigData("starstuff_octopusking")) and "magic_seal" or "opalpreciousgem", 1), Ingredient("moonbutterflywings", 2)})
    -- Night Stories
    set_ingredients("book_wetness",                 {Ingredient("book_rain", 1), Ingredient("book_temperature", 1), Ingredient(sw and "magic_seal" or "malbatross_feather", sw and 1 or 10)})

    if sw and env.GetModConfigData("craftable_atrium_loots") then
        AddRecipe("armorskeleton", {Ingredient("magic_seal", 1), Ingredient("boneshard", 10), Ingredient("nightmarefuel", 6)}, TECH.LOST, {nounlock = true, nomods = true}, {"ARMOUR"})
        AddRecipe("skeletonhat", {Ingredient("magic_seal", 1), Ingredient("boneshard", 10), Ingredient("nightmarefuel", 4)}, TECH.LOST, {nounlock = true, nomods = true}, {"ARMOUR"})
        AddRecipe("thurible", {Ingredient("magic_seal", 1), Ingredient("cutstone", 2), Ingredient("nightmarefuel", 6), Ingredient("ash", 1)}, TECH.LOST, {nounlock = true, nomods = true}, {"TOOLS"})
    end
end)
