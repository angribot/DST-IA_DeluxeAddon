local AddAction = AddAction
local AddComponentAction = AddComponentAction
local AddStategraphActionHandler = AddStategraphActionHandler
GLOBAL.setfenv(1, GLOBAL)

local IAA_ACTIONS = {
	FUEL_OBSIDIAN = Action({ distance = 2, mount_valid = true }),
}

IAA_ACTIONS.FUEL_OBSIDIAN.str = STRINGS.ACTIONS.ACTIVATE.GENERIC
IAA_ACTIONS.FUEL_OBSIDIAN.fn = function(act)
	--     local boat = nil
	-- if act.target and act.target:HasTag("boat") then
	--     boat = act.target
	-- elseif act.doer.components.sailor and act.doer.components.sailor.boat then
	--     boat = act.doer.components.sailor.boat
	-- end

	local item = act.doer and act.doer.components.inventory and act.doer.components.inventory:RemoveItem(act.invobject)
	if item then
		item:Remove()
		act.target:EquipSail()
		return true
	end
end

for _, k, v in sorted_pairs(IAA_ACTIONS) do
	v.id = k
	AddAction(v)
end

AddComponentAction("USEITEM", "dragoonfuel", function(inst, doer, target, actions, right)
	if target:HasTag("obsidianboat") then
		table.insert(actions, ACTIONS.FUEL_OBSIDIAN)
	end
end)

-- AddComponentAction("INVENTORY", "dragoonfuel", function(inst, doer, actions)
--     if doer and doer.replica.sailor and doer.replica.sailor:GetBoat() and doer.replica.sailor:GetBoat():HasTag("obsidianboat") then
--         table.insert(actions, ACTIONS.FUEL_OBSIDIAN)
--     end
-- end)
for _, sg in ipairs({ "wilson", "wilson_client" }) do
	AddStategraphActionHandler(sg, ActionHandler(IAA_ACTIONS.FUEL_OBSIDIAN, "doshortaction"))
end

-- local NAME_BOAT = Action({distance = 2, mount_valid = true})
-- NAME_BOAT.id = "NAME_BOAT"
-- NAME_BOAT.str = STRINGS.ACTIONS.NAME_BOAT
-- IAENV.AddAction(NAME_BOAT)

-- NAME_BOAT.fn = function(act)
--     local boat = nil
--     if act.target and act.target:HasTag("boat") then
--         boat = act.target
--     elseif act.doer.components.sailor and act.doer.components.sailor.boat then
--         boat = act.doer.components.sailor.boat
--     end

--     if boat and boat.components.writeable then
--         if boat.components.writeable:IsBeingWritten() then
--             return false, "INUSE"
--         end

--         act.doer.tool_prefab = act.invobject.prefab
--         if act.invobject.components.stackable then
--             act.invobject.components.stackable:Get():Remove()
--         else
--             act.invobject:Remove()
--         end
--         boat.components.writeable:BeginWriting(act.doer)
--         return true
--     end
-- end

-- IAENV.AddComponentAction("USEITEM", "drawingtool", function(inst, doer, target, actions, right)
--     if target:HasTag("boat") then
--         table.insert(actions, ACTIONS.NAME_BOAT)
--     end
-- end)

-- IAENV.AddComponentAction("INVENTORY", "drawingtool", function(inst, doer, actions)
--     if doer and doer.replica.sailor and doer.replica.sailor:GetBoat() then
--         table.insert(actions, ACTIONS.NAME_BOAT)
--     end
-- end)
