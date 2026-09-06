if not GetModConfigData("dragoonfly") then
	return
end

local AddSimPostInit = AddSimPostInit
GLOBAL.setfenv(1, GLOBAL)

AddSimPostInit(function()
	if not TheWorld:HasTag("volcano") then
		return
	end
	local loots = LootTables["dragonfly"]
	if loots then
		for _, v in ipairs(loots) do
			if v[1] == "lavae_egg" then
				v[1] = "dragoonheart"
				v[2] = 1
				break
			end
		end
		table.insert(loots, { "obsidian", 1 })
		table.insert(loots, { "obsidian", 1 })
		table.insert(loots, { "obsidian", 1 })
		table.insert(loots, { "obsidian", 0.50 })
		table.insert(loots, { "obsidian", 0.50 })
		table.insert(loots, { "obsidian", 0.33 })
		table.insert(loots, { "obsidian", 0.33 })
		table.insert(loots, { "obsidian", 0.25 })
	end
end)
