local MakeVisualBoatEquip = require("prefabs/visualboatequip")

local obsidian_assets = {
    -- Asset("ANIM", "anim/swap_sail_pirate.zip"),
}

local function GetObsidianHeat(inst, observer)
    local charge, maxcharge = inst.components.obsidiantool:GetCharge()
    local heat = Lerp(0, TUNING.OBSIDIAN_TOOL_MAXHEAT, charge / maxcharge)
    return heat
end

local function GetObsidianEquippedHeat(inst, observer)
    local heat = GetObsidianHeat(inst, observer)
    heat = math.clamp(heat, 0, TUNING.OBSIDIAN_TOOL_MAXHEAT)
    --awkward/hacky but safer
    if inst.components.temperature then
        local current = inst.components.temperature:GetCurrent()
        if heat > current then
            heat = heat + current
        elseif heat < current then
            heat = current --cancel out heat so tools don't cool you down
        end
    end
    return heat
end

local function SpawnObsidianLight(inst)
    local owner = inst.components.inventoryitem.owner
    inst._obsidianlight = inst._obsidianlight or SpawnPrefab("obsidiantoollight")
    inst._obsidianlight.entity:SetParent((owner or inst).entity)
end

local function RemoveObsidianLight(inst)
    if inst._obsidianlight ~= nil then
        inst._obsidianlight:Remove()
        inst._obsidianlight = nil
    end
end

local function ChangeObsidianLight(inst, old, new)
    -- print("charge: ", old, new)
    local percentage = new / inst.components.obsidiantool.maxcharge
    local rad = Lerp(0.8, 3.2, percentage)

    if percentage >= inst.components.obsidiantool.yellow_threshold then
        SpawnObsidianLight(inst)

        if percentage >= inst.components.obsidiantool.red_threshold then
            inst._obsidianlight.Light:SetColour(254/255, 98/255, 75/255)
            inst._obsidianlight.Light:SetRadius(rad)
        elseif percentage >= inst.components.obsidiantool.orange_threshold then
            inst._obsidianlight.Light:SetColour(255/255, 159/255, 102/255)
            inst._obsidianlight.Light:SetRadius(rad)
        else
            inst._obsidianlight.Light:SetColour(255/255, 223/255, 125/255)
            inst._obsidianlight.Light:SetRadius(rad)
        end
    else
        RemoveObsidianLight(inst)
    end
end

local function obsidian_charge_task(inst)
    local charge, maxcharge = inst.components.obsidiantool:GetCharge()
    inst.components.obsidiantool:SetCharge(math.min(charge + 5 * FRAMES, maxcharge))
    inst.components.obsidiantool.cooltimer = 0
end

local function startconsuming(inst)
    if inst.components.fueled and not inst.components.fueled.consuming then
        inst.components.fueled:StartConsuming()
    end
    if not inst.obsidian_charge_task then
        inst.obsidian_charge_task = inst:DoPeriodicTask(FRAMES, obsidian_charge_task)
    end
end

local function stopconsuming(inst)
    if inst.components.fueled and inst.components.fueled.consuming then
        inst.components.fueled:StopConsuming()
    end
    if inst.obsidian_charge_task then
        inst.obsidian_charge_task:Cancel()
        inst.obsidian_charge_task = nil
    end
end

local function onembarked(boat, data)
    local item = boat.components.container:GetBoatEquippedItem(BOATEQUIPSLOTS.BOAT_SAIL)

    if data.sailor.components.locomotor then
        data.sailor.components.locomotor:SetExternalSpeedMultiplier(item, "SAIL", item.sail_speed_mult)
        data.sailor.components.locomotor:SetExternalAccelerationMultiplier(item, "SAIL", item.sail_accel_mult)
        data.sailor.components.locomotor:SetExternalDecelerationMultiplier(item, "SAIL", item.sail_accel_mult)
    end
end

local function ondisembarked(boat, data)
    local item = boat.components.container:GetBoatEquippedItem(BOATEQUIPSLOTS.BOAT_SAIL)
    stopconsuming(item)

    if data.sailor.components.locomotor then
        data.sailor.components.locomotor:RemoveExternalSpeedMultiplier(item, "SAIL")
        data.sailor.components.locomotor:RemoveExternalAccelerationMultiplier(item, "SAIL")
        data.sailor.components.locomotor:RemoveExternalDecelerationMultiplier(item, "SAIL")
    end
end


local function onstartmoving(boat, data)
    local item = boat.components.container:GetBoatEquippedItem(BOATEQUIPSLOTS.BOAT_SAIL)
    startconsuming(item)
end

local function onstopmoving(boat, data)
    local item = boat.components.container:GetBoatEquippedItem(BOATEQUIPSLOTS.BOAT_SAIL)
    stopconsuming(item)
end

local function onequip(inst, owner)
    if not owner or not owner.components.sailable then
        print("WARNING: Equipped sail (",inst,") without valid boat: ", owner)
        return false
    end

    if owner.components.boatvisualmanager then
        owner.components.boatvisualmanager:SpawnBoatEquipVisuals(inst, inst.visualprefab)
    end

    if owner.components.sailable.sailor then
        local sailor = owner.components.sailable.sailor
        sailor:PushEvent("sailequipped")
        inst.sailquipped:set_local(true)
        inst.sailquipped:set(true)
        if inst.flapsound then
            sailor.SoundEmitter:PlaySound(inst.flapsound)
        end
        if sailor.components.locomotor then
            sailor.components.locomotor:SetExternalSpeedMultiplier(inst, "SAIL", inst.sail_speed_mult)
            sailor.components.locomotor:SetExternalAccelerationMultiplier(inst, "SAIL", inst.sail_accel_mult)
            sailor.components.locomotor:SetExternalDecelerationMultiplier(inst, "SAIL", inst.sail_accel_mult)
        end
    end

    inst:ListenForEvent("embarked", onembarked, owner)
    inst:ListenForEvent("disembarked", ondisembarked, owner)
    inst:ListenForEvent("boatstartmoving", onstartmoving, owner)
    inst:ListenForEvent("boatstopmoving", onstopmoving, owner)

    if inst.RemoveTask then
        inst.RemoveTask:Cancel()
        inst.RemoveTask = nil
    end
end

local function onunequip(inst, owner)
    if owner then
        if owner.components.boatvisualmanager then
            owner.components.boatvisualmanager:RemoveBoatEquipVisuals(inst)
        end
        if owner.components.sailable and owner.components.sailable.sailor then
            local sailor = owner.components.sailable.sailor
            sailor:PushEvent("sailunequipped")
            inst.sailquipped:set_local(false)
            inst.sailquipped:set(false)
            if inst.flapsound then
                sailor.SoundEmitter:PlaySound(inst.flapsound)
            end

            if sailor.components.locomotor then
                sailor.components.locomotor:RemoveExternalSpeedMultiplier(inst, "SAIL")
                sailor.components.locomotor:RemoveExternalAccelerationMultiplier(inst, "SAIL")
                sailor.components.locomotor:RemoveExternalDecelerationMultiplier(inst, "SAIL")
            end
        end

        inst:RemoveEventCallback("embarked", onembarked, owner)
        inst:RemoveEventCallback("disembarked", ondisembarked, owner)
        inst:RemoveEventCallback("boatstartmoving", onstartmoving, owner)
        inst:RemoveEventCallback("boatstopmoving", onstopmoving, owner)
    end

    stopconsuming(inst)

    if inst.RemoveOnUnequip then
        if not inst.RemoveTask then
            inst.RemoveTask = inst:DoTaskInTime(2 * FRAMES, inst.Remove)
        end
    end
end

local function sail_perish(inst)
    onunequip(inst, inst.components.inventoryitem.owner)
    inst:Remove()
end

local function common_pristine()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    inst:AddTag("sail")

    --networking the equip/unequip event
    inst.sailquipped = net_bool(inst.GUID, "sailquipped", not TheWorld.ismastersim and "sailquipped" or nil)

    if not TheWorld.ismastersim then
        inst:ListenForEvent("sailquipped", function(inst)
            if inst.sailquipped:value() then
                TheLocalPlayer:PushEvent("sailequipped")
            else
               TheLocalPlayer:PushEvent("sailunequipped")
            end
        end)
    end

    MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations("idle_water", "idle")

    return inst
end

local function common_master(inst)
    inst:AddComponent("inspectable")

    MakeHauntableLaunch(inst)

    inst:AddComponent("inventoryitem")

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
    inst.components.fueled:SetDepletedFn(sail_perish)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("equippable")
    inst.components.equippable.boatequipslot = BOATEQUIPSLOTS.BOAT_SAIL
    inst.components.equippable.equipslot = nil
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst.onembarked = onembarked
    inst.ondisembarked = ondisembarked

    return inst
end

local function obsidian_fn()
    local inst = common_pristine()

    inst.AnimState:SetBank("sail")
    inst.AnimState:SetBuild("swap_sail_pirate")
    inst.AnimState:PlayAnimation("idle")

    inst.loopsound = "ia/common/boatpropellor_lp"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    common_master(inst)

    inst:AddComponent("obsidiantool")
    inst.components.obsidiantool.onchargedelta = ChangeObsidianLight
    inst.components.obsidiantool.cooldowntime = 15 / inst.components.obsidiantool.maxcharge

    -- inst:AddComponent("heater")
    -- inst.components.heater.show_heat = true

    -- inst.components.heater.heatfn = GetObsidianHeat
    -- inst.components.heater.minheat = 0
    -- inst.components.heater.maxheat = TUNING.OBSIDIAN_TOOL_MAXHEAT

    -- inst.components.heater.equippedheatfn = GetObsidianEquippedHeat

    -- inst.components.heater.carriedheatfn = GetObsidianHeat
    -- inst.components.heater.mincarriedheat = 0
    -- inst.components.heater.maxcarriedheat = TUNING.OBSIDIAN_TOOL_MAXHEAT

    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")

    inst.visualprefab = "sail_obsidian"

    -- inst:RemoveComponent("fueled")
    inst.components.fueled:InitializeFuelLevel(TUNING.SAIL_OBSIDIAN_PERISH_TIME)
    inst.sail_speed_mult = TUNING.SAIL_OBSIDIAN_SPEED_MULT
    inst.sail_accel_mult = TUNING.SAIL_OBSIDIAN_ACCEL_MULT

    inst.RemoveOnUnequip = true

    inst.RemoveTask = inst:DoTaskInTime(1, inst.Remove)
    -- inst.components.fueled.fueltype = FUELTYPE.MECHANICAL
    -- inst.components.fueled.accepting = true

    local OnRemoveEntity = inst.OnRemoveEntity
    function inst:OnRemoveEntity(...)
        RemoveObsidianLight(self)
        if OnRemoveEntity then
            OnRemoveEntity(self, ...)
        end
    end

    return inst
end

local function obsidian_visual_common(inst)
    -- inst.AnimState:SetBank("sail_visual")
    -- inst.AnimState:SetBuild("swap_propeller")
    -- inst.AnimState:PlayAnimation("idle_loop")
    -- inst.AnimState:SetSortWorldOffset(0, -0.05, 0) --below the boat

    -- function inst.components.boatvisualanims.update(inst, dt)
    --     if inst.AnimState:GetCurrentFacing() == FACING_UP then
    --         inst.AnimState:SetSortWorldOffset(0, 0.05, 0) --above the boat
    --     else
    --         inst.AnimState:SetSortWorldOffset(0, -0.05, 0) --below the boat
    --     end
    -- end
end

return Prefab("sail_obsidian", obsidian_fn, obsidian_assets),
    MakeVisualBoatEquip("sail_obsidian", obsidian_assets, nil, obsidian_visual_common)
