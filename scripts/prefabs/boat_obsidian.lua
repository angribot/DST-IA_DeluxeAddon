local obsidianboatassets = {
    Asset("ANIM", "anim/rowboat_basic.zip"),
    Asset("ANIM", "anim/rowboat_obsidian_build.zip"),
    Asset("ANIM", "anim/rowboat_idles.zip"),
    Asset("ANIM", "anim/rowboat_paddle.zip"),
    Asset("ANIM", "anim/rowboat_trawl.zip"),
    -- Asset("ANIM", "anim/swap_sail.zip"),
    -- Asset("ANIM", "anim/swap_lantern_boat.zip"),
    Asset("ANIM", "anim/boat_hud_raft.zip"),
    Asset("ANIM", "anim/boat_inspect_raft.zip"),
  -- TODO: add obsidian flotsam
    Asset("ANIM", "anim/flotsam_rowboat_build.zip"),
}

local prefabs = {
    "rowboat_wake",
    "boat_hit_fx",
    "boat_hit_fx_raft_log",
    "boat_hit_fx_raft_bamboo",
    "boat_hit_fx_rowboat",
    "boat_hit_fx_cargoboat",
    "boat_hit_fx_armoured",
    -- "flotsam_armoured",
    -- "flotsam_bamboo",
    -- "flotsam_cargo",
    -- "flotsam_lograft",
    "flotsam_rowboat",
    "firepit_firebird_puff_fx",
    -- "flotsam_surfboard",
}

local function sink(inst)
    local sailor = inst.components.sailable:GetSailor()
    if sailor then
        if sailor.components.health then
            sailor.components.health:Drown(true)
        end
        --moved to after drown call because of double drown for wurt and because otherwise when you drown too close to shore you can get put back onto shore due to keeponland
        sailor.components.sailor:Disembark()

        --im pretty sure its here because otherwise it will play twice due to keeponland, plus it needs the boats sinksound -Half
        inst.SoundEmitter:PlaySound(inst.sinksound) --Not sure why this is here and not in the SG -M
    end
    if inst.components.container then
        inst.components.container:DropEverything()
    end

    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("run_loop", true)
end

local function onworked(inst, worker)
    inst.components.lootdropper:DropLoot()
    if inst.components.container then
        inst.components.container:DropEverything()
    end
    SpawnAt("collapse_small", inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:Remove()
end

local function onrepaired(inst, doer, repair_item)
    inst.SoundEmitter:PlaySound("ia/common/boatrepairkit")
end

local function ondisembarked(inst)
    inst.components.workable:SetWorkable(true)
end

local function onembarked(inst)
    inst.components.workable:SetWorkable(false)
end

local function onopen(inst)
    if inst.components.sailable.sailor == nil then
        inst.SoundEmitter:PlaySound("ia/common/boat/inventory_open")
    end
end

local function onclose(inst)
    if inst.components.sailable.sailor == nil then
        inst.SoundEmitter:PlaySound("ia/common/boat/inventory_close")
    end
end

local function common()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddPhysics()
    inst.entity:AddMiniMapEntity()

    inst:AddTag("boat")
    inst:AddTag("sailable")

    inst.Transform:SetFourFaced()
    inst.MiniMapEntity:SetPriority(5)

    inst.AnimState:SetFinalOffset(FINALOFFSET_MIN) --has some visual glitches but looks much better than the boat being infront of the player on a disembark

    inst.Physics:SetCylinder(0.25,2)

    inst.no_wet_prefix = true

    inst.sailmusic = "sailing"

    inst.boatvisuals = {}

    inst:AddComponent("rowboatwakespawner")
    inst.components.rowboatwakespawner:SetFacingOffset({
        [FACING_RIGHT] = {0.85, -0.5},
        [FACING_UP] = {0.75, 0.075},
        [FACING_LEFT] = {0.475, 0.5},
        [FACING_DOWN] = {-0.75, -0.125},
        [FACING_NONE] = {0, 0},
    })

    inst.boatname = net_string(inst.GUID, "boatname")

    inst.displaynamefn = function(_inst)
        local name = _inst.boatname:value()
        return name ~= "" and name or STRINGS.NAMES[string.upper(_inst.prefab)]
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("writeable")
    inst:RemoveEventCallback("onbuilt", inst.event_listening.onbuilt[inst][1])
    inst.components.writeable:SetDefaultWriteable(false)
    inst.components.writeable:SetAutomaticDescriptionEnabled(false)

    local _Write = inst.components.writeable.Write
    inst.components.writeable.Write = function(self, doer, text, ...)
        if not text then
            text = self.text
            if doer.tool_prefab then
                doer.components.inventory:GiveItem(SpawnPrefab(doer.tool_prefab), nil, inst:GetPosition())
            end
        else
            inst.SoundEmitter:PlaySound("dontstarve/common/together/draw")
        end

        inst.boatname:set(text and text ~= "" and text or "")
        _Write(self, doer, text, ...)
    end

    local _OnLoad = inst.components.writeable.OnLoad
    inst.components.writeable.OnLoad = function(self, ...)
        _OnLoad(self, ...)
        local text = self.text
        inst.boatname:set(text and text ~= "" and text or "")
    end

    inst:AddComponent("sailable")
    inst.components.sailable.sanitydrain = TUNING.RAFT_SANITY_DRAIN
    inst.components.sailable.movementbonus = TUNING.RAFT_SPEED
    inst.components.sailable.flotsambuild = "flotsam_bamboo_build"
    inst.components.sailable.maprevealbonus = TUNING.MAPREVEAL_RAFT_BONUS

    inst.landsound = "ia/common/boatjump_land_bamboo"
    inst.sinksound = "ia/common/boat/sinking/bamboo"

    inst.waveboost = TUNING.WAVEBOOST

    inst:AddComponent("boathealth")
    inst.components.boathealth:SetDepletedFn(sink)
    inst.components.boathealth:SetHealth(TUNING.RAFT_HEALTH, TUNING.RAFT_PERISHTIME)
    inst.components.boathealth.leakinghealth = TUNING.RAFT_LEAKING_HEALTH
    inst.components.boathealth.damagesound = "ia/common/boat/damage/bamboo"
    inst.components.boathealth.hitfx = "boat_hit_fx_raft_bamboo"

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onworked)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("lootdropper")

    inst:AddComponent("repairable")
    inst.components.repairable.repairmaterial = "boat"
    inst.components.repairable.onrepaired = onrepaired

    inst:ListenForEvent("sailable_occupied", onembarked)
    inst:ListenForEvent("sailable_unoccupied", ondisembarked)

    inst.onworked = onworked

    inst:AddComponent("flotsamspawner")

    inst.components.flotsamspawner.flotsamprefab = "flotsam_bamboo"

    inst:AddComponent("container")

    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst.components.container.stay_open_on_hide = true

    inst:AddComponent("boatvisualmanager")

    return inst
end

local function item_ondropped(inst)
    --If this is a valid place to be deployed, auto deploy yourself.
    local x, y, z = inst.Transform:GetWorldPosition()
    local pt = Vector3(x, 0, z)
    if inst.components.deployable and inst._custom_candeploy_fn and inst:_custom_candeploy_fn(pt) then
        inst.components.deployable.forcedeploy = true
        inst.components.deployable:Deploy(pt, inst)
        inst.components.deployable.forcedeploy = false
    end
end

local function item_ondeploy(inst, pt, deployer)
    local boat = inst.components.pocket:RemoveItem(inst.boat) or SpawnPrefab(inst.boat)
    if boat then
        local value = inst.boatname:value()
        local name = value and value ~= "" and value or ""
        boat.components.writeable:SetText(name)
        boat.boatname:set(name)

        local x, y, z = pt:Get()
        boat.components.flotsamspawner.inpocket = false
        boat.Physics:SetCollides(false)
        boat.Physics:Teleport(x, y, z)
        boat.Physics:SetCollides(true)
        inst:Remove()
    end
end

local function item_common()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()

    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)

    inst:AddTag("boat")

    inst.boatname = net_string(inst.GUID, "boatname")

    inst.displaynamefn = function(_inst)
        local name = _inst.boatname:value()
        return name ~= "" and name or STRINGS.NAMES[string.upper(_inst.prefab)]
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.boat = nil

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(item_ondropped)

    inst:AddComponent("pocket")

    inst:AddComponent("deployable")
    inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM)
    inst._custom_candeploy_fn = function(_inst, pt)
        local tile = TheWorld.Map:GetTileAtPoint(pt:Get())
        local IsWaterMode = IA_CONFIG.aquaticplacedstwater and IsWaterAny or IsWater
        return IsWaterMode(tile)
    end
    inst.components.deployable.ondeploy = item_ondeploy
    inst.components.deployable.candeployonland = false
    inst.components.deployable.candeployonbuildableocean = true
    inst.components.deployable.candeployonunbuildableocean = true
    inst.components.deployable.deploydistance = 3

    inst:AddComponent("writeable")
    inst.components.writeable:SetDefaultWriteable(false)
    inst.components.writeable:SetAutomaticDescriptionEnabled(false)
    local _Write = inst.components.writeable.Write
    inst.components.writeable.Write = function(self, doer, text, ...)
        if not text then
            text = self.text
            if doer and doer.tool_prefab then
                doer.components.inventory:GiveItem(SpawnPrefab(doer.tool_prefab), nil, inst:GetPosition())
            end
        else
            inst.SoundEmitter:PlaySound("dontstarve/common/together/draw")
        end

        inst.boatname:set(text and text ~= "" and text or "")
        _Write(self, doer, text, ...)
    end

    local _OnLoad = inst.components.writeable.OnLoad
    inst.components.writeable.OnLoad = function(self, ...)
        _OnLoad(self, ...)
        local text = self.text
        inst.boatname:set(text and text ~= "" and text or "")
    end

    return inst
end



local function EquipSail(inst)
    local sailitem = inst.components.container:GetBoatEquippedItem(BOATEQUIPSLOTS.BOAT_SAIL)
    if sailitem then
        sailitem:Remove()
    end
    inst.components.container:Equip(SpawnPrefab("sail_obsidian"))
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")

    local fx = SpawnPrefab("firepit_firebird_puff_fx")
    local scale = 0.6
    fx.Transform:SetScale(scale, scale, scale)
    fx.entity:SetParent(inst.entity)
    fx.level:set(3)

end

local function get_status(inst)
    local sailitem = inst.components.container:GetBoatEquippedItem(BOATEQUIPSLOTS.BOAT_SAIL)
    return sailitem and sailitem.prefab == "sail_obsidian" and "ACTIVE"
end

local function update_colour(inst)
    if get_status(inst) == "ACTIVE" then
        local cc = 1
        inst.AnimState:SetMultColour(cc, cc, cc, 1)
    else
        local cc = 0.4
        inst.AnimState:SetMultColour(cc, cc, cc, 1)
    end
end

local function obsidianboatfn()
    local inst = common()

    inst.AnimState:SetBank("rowboat")
    inst.AnimState:SetBuild("rowboat_obsidian_build")
    inst.AnimState:PlayAnimation("run_loop", true)
    inst.MiniMapEntity:SetIcon("boat_obsidian.tex")
    -- inst.AnimState:SetMultColour(0.4, 0.4, 0.4, 1)

    inst:AddTag("obsidianboat")

    if not TheWorld.ismastersim then
        function inst.OnEntityReplicated(inst)
            inst.replica.sailable.creaksound = "ia/common/boat/creaks/encrusted"
        end
        return inst
    end

    inst.EquipSail = EquipSail

    inst.waveboost = TUNING.OBSIDIANBOAT_WAVEBOOST

    inst.components.inspectable.getstatus = get_status

    -- inst.components.container:WidgetSetup("boat_encrusted")
    inst.components.container:WidgetSetup("boat_obsidian")

    inst.components.boathealth:SetHealth(TUNING.OBSIDIANBOAT_HEALTH, TUNING.OBSIDIANBOAT_PERISHTIME)
    inst.components.boathealth.leakinghealth = TUNING.OBSIDIANBOAT_LEAKING_HEALTH
    inst.components.boathealth.damagesound = "ia/common/boat/damage/encrusted"
    inst.components.boathealth.hitfx = "boat_hit_fx_armoured"

    inst.landsound = "ia/common/boatjump_land_shell"
    inst.sinksound = "ia/common/boat/sinking/row"

    inst.components.sailable.sanitydrain = TUNING.OBSIDIANBOAT_SANITY_DRAIN
    inst.components.sailable.movementbonus = TUNING.OBSIDIANBOAT_SPEED
    inst.components.sailable.flotsambuild = "flotsam_armoured_build"
    inst.components.sailable.maprevealbonus = TUNING.MAPREVEAL_OBSIDIANBOAT_BONUS
    inst.components.sailable:SetHitImmunity(TUNING.OBSIDIANBOAT_HIT_IMMUNITY)

    inst.replica.sailable.creaksound = "ia/common/boat/creaks/encrusted"

    inst.components.flotsamspawner.flotsamprefab = "flotsam_armoured"

    -- inst:DoTaskInTime(0.1, function(inst)
    --     local sailitem = inst.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_SAIL)
    --     if sailitem == nil then
    --         local sail = SpawnPrefab("sail_woodlegs")
    --         inst.components.container:Equip(sail)
    --     end
    --     local torchitem = inst.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_LAMP)
    --     if torchitem == nil then
    --         local cannon = SpawnPrefab("woodlegs_boatcannon")
    --         inst.components.container:Equip(cannon)
    --     end
    -- end)
    -- inst:ListenForEvent("itemget", update_colour)
    -- inst:ListenForEvent("itemlose", update_colour)
    inst:DoPeriodicTask(FRAMES, update_colour)

    return inst
end

return Prefab("boat_obsidian", obsidianboatfn, obsidianboatassets, prefabs),
--the 2 is offset for controller users (Bullkelp from basegame also uses 2)
MakePlacer("boat_obsidian_placer", "rowboat", "rowboat_obsidian_build", "run_loop", nil, nil, nil, nil, nil, nil, nil, 2)
