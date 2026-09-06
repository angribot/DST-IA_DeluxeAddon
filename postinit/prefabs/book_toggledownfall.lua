local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local _OnRead = nil
local function OnRead(inst, reader, ...)
    if IsShipwreckedWorld() then
        if TheWorld.state.hurricane then
            TheWorld:PushEvent("ms_forcehurricane",  false)
        elseif TheWorld.state.iswetseason then
            TheWorld:PushEvent("ms_forcehurricane",  true)
        end
    end

    return _OnRead ~= nil and _OnRead(inst, reader, ...) or nil
end

local function fn(inst)
    if not TheWorld.ismastersim then return end

    if not _OnRead then
        _OnRead = inst.components.book.onread
    end
    inst.components.book.onread = OnRead

end

AddPrefabPostInit("book_toggledownfall", fn)
