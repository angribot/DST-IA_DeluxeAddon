local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function fn(inst)
	if not TheWorld.ismastersim then
		return
	end

	inst.disable_charcoal = true
end

local disable_charcoal_list = {
	"chiminea",
	"sea_chiminea",
	"obsidianfirepit",
}

for _, prefab in ipairs(disable_charcoal_list) do
	AddPrefabPostInit(prefab, fn)
end
