local mainfiles = {
	"assets",
	"tuning",
	"strings",
	"prefabskin",

	"actions",
	"containers",
	"writeables",

	"recipes",
	"spices",
}

local postinits = {
	-- components
	"components/container",
	-- prefabs
	"prefabs/book_toggledownfall",
	"prefabs/dragoonfly",
	"prefabs/dragoonheart",
	"prefabs/firepit",
	"prefabs/fish_farm",
	"prefabs/glasscutter",
	"prefabs/kraken",
	"prefabs/octopusking",
	"prefabs/opalpreciousgem",
	"prefabs/rocks",
	"prefabs/spear_obsidian",

	-- root
	"buff_oneaten",
}

for _, file in ipairs(mainfiles) do
	modimport("main/" .. file)
end

for _, file in ipairs(postinits) do
	modimport("postinit/" .. file)
end
