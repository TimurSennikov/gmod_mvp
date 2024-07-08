local MaxKills = 0
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

function GetMVP() -- функция для вычисления мвп
    local playersList = player.GetAll() -- все игроки сервера
    local isNewMVP = false -- отвечает за то, найден ли новый мвп

    for _, v in ipairs(playersList) do -- перебираем всех игроков
        local Frags = v:Frags() -- получаем фраги игрока

        if Frags > MaxKills then -- если фрагов больше чем макс. фрагов
            MaxKills = Frags -- устанавливаем в макс. фраги число фрагов игрока
            MVP = v -- делаем игрока мвп

            isNewMVP = true -- устанавливаем флажок мвп (сверху прописано)
        end
    end

    if isNewMVP then -- если у нас новый мвп
        Obj:ChangeMVP(MVP) -- меняем мвп на нового игрока

        PrintMessage(HUD_PRINTTALK, "У нас новый МВП, " .. MVP:Name() .. ", убейте его уже!") -- пишем в чат
    end
end

Obj:EntitySetup() -- при загрузке плагина создаем энтити мвп игрока

hook.Add("PlayerDeath", "PlayerDeathHook", GetMVP) -- при смерти игрока перепроверяем, не появился ли новый мвп

hook.Add("PlayerDisconnected", "PlayerDisconnectHook", function(ply) -- при отключении игрока
    if MVP:Name() == ply:Name() then -- если это был мвп
        MaxKills = 0 -- устанавливаем макс. фраги на 0
        Obj:EntityReset() -- закапываем проп в землю
        GetMVP() -- заново вычисляем мвп
    end

    if not player.GetAll()[1] then -- если нет игроков
        MaxKills = 0 -- устанавливаем макс. фраги в 0
        Obj:EntityReset() -- закапываем проп в землю (на самом деле нет особого смысла, ведь игроков нет, значит и проп видеть некому, но по мне так лучше)
    end
end)
