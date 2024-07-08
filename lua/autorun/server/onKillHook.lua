local MaxKills = -100
local MVP

local obj

Obj = {}

function Obj:EntitySetup()
    obj = ents.Create("prop_physics") -- создание
    obj:SetModel("models/props_combine/combine_emitter01.mdl") -- устанавливаем модельку
    obj:SetPos(Vector(0,0,-10)) -- позиция (закопана в земле, ведь мвп пока нет)
    obj:SetCollisionGroup(COLLISION_GROUP_DEBRIS) -- установка группы колиизий (чтоб не билась о пропы и прочее)

    obj:Spawn() -- спавн
end

function Obj:EntityReset() -- вызывается когда игроков нет на сервере / нет мвп
    obj:SetParent(nil) -- убираем родителя у пропа
    obj:SetPos(Vector(0,0,-10)) -- закапываем проп в землю
end

function Obj:ChangeMVP(parent) -- вызывается при появлении нового мвп
    obj:SetParent(parent) -- устанавливаем родителя
    obj:SetPos(parent:GetPos() + Vector(0,0,100)) -- устанавливаем проп над головой игрока
end

function GetMVP()
    local playersList = player.GetAll()
    local isNewMVP = false

    for k, v in ipairs(playersList) do
        local Frags = v:Frags()

        if Frags > MaxKills then
            MaxKills = Frags
            MVP = v

            isNewMVP = true
        end
    end

    if isNewMVP then
        Obj:ChangeMVP(MVP)

        PrintMessage(HUD_PRINTTALK, "У нас новый МВП, " .. MVP:Name() .. ", убейте его уже!")
    end
end

Obj:EntitySetup() -- при загрузке плагина создаем энтити мвп игрока

hook.Add("PlayerDeath", "PlayerDeathHook", GetMVP)

hook.Add("PlayerDisconnected", "PlayerDisconnectHook", function(ply)
    if MVP:Name() == ply:Name() then
        MaxKills = 0
        Obj:EntityReset()
        GetMVP()
    end

    if not player.GetAll()[1] then
        Obj:EntityReset()
    end
end)