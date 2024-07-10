Crown = {}

function Crown:Setup()
    self.MVP = nil

    if IsValid(self.crown) then
        self.crown:Remove()
    end

    self.crown = ents.Create("prop_dynamic")

    self.crown:SetModel("models/balloons/balloon_star.mdl")

    self.crown:Spawn()
end

function Crown:ChangeMVP(ply)
    self:Setup()

    if IsValid(ply) and ply:IsPlayer() then
        self.MVP = ply

        self.crown:SetParent(ply)
        self.crown:Fire("SetParentAttachmentMaintainOffset", "eyes")
        self.crown:SetLocalPos(Vector(-15,-15,90))
        self.crown:SetAngles(ply:GetAngles())

        PrintMessage(HUD_PRINTTALK, ply:Name() .. " is the new King!")
    end
end

function Crown:ExplodeNextToPlayer(ply)
    local can = ents.Create("prop_physics")

    can:SetModel("models/props_junk/gascan001a.mdl")
    can:SetParent(ply)
    can:SetLocalPos(Vector(0,0,0))
    can:Spawn()

    can:Fire("break")
end

function Crown:BreakWatermelonNextToPlayer(ply)
    local watermelon = ents.Create("prop_dynamic")

    watermelon:SetModel("models/props_junk/watermelon01.mdl")
    watermelon:SetParent(ply)
    watermelon:SetLocalPos(Vector(0,0,50))

    watermelon:Spawn()

    watermelon:Fire("break")
end

function OnKill(victim, inflictor, attacker)
    if not Crown.MVP and victim == attacker == false then
        Crown:ChangeMVP(attacker)
    elseif victim == attacker == false then
        if victim == Crown.MVP then
            if IsValid(attacker) and attacker:IsPlayer() then
                Crown:ExplodeNextToPlayer(victim)
                Crown:BreakWatermelonNextToPlayer(victim)

                Crown:ChangeMVP(attacker)
            else
                Crown:ChangeMVP(nil)
                PrintMessage(HUD_PRINTTALK, "MVP is dead, be the first to take the crown!")
            end
        end
    else
        if victim == Crown.MVP and victim == attacker == true then
            Crown:Setup()

            PrintMessage(HUD_PRINTTALK, "MVP preferred to DIE, take his crown!")
        end
    end
end

function OnPlayerDisconnect(ply)
    if ply == Crown.MVP then
        Crown:ChangeMVP(nil)
    end
end

function OnPlayerSay(ply, text)
    if text == "!mvp" then
        if Crown.MVP then
            ply:PrintMessage(HUD_PRINTTALK, "The mvp now is " .. Crown.MVP:Name() .. "!")
        else
            ply:PrintMessage(HUD_PRINTTALK, "There is no MVP now, be first to take to crown!")
        end
    elseif text == "!build" and ply == Crown.MVP then
        Crown:Setup()

        ply:PrintMessage(HUD_PRINTTALK, "You entered build mode, MVP star will be deleted :/")
    elseif string.Explode('"', text)[1] == "!setmvp " and ply:IsAdmin() then
        local explodedString = string.Explode('"', text)

        if explodedString[2] == "noone" then
            Crown.MVP = nil
            Crown:Setup()
        else
            local playerFound = false
            for k, v in ipairs(player.GetAll()) do
                if v:Name() == explodedString[2] then
                    Crown.MVP = v

                    Crown:ChangeMVP(v)

                    playerFound = true
                end
            end

            if not playerFound then
                ply:PrintMessage(HUD_PRINTTALK, "Can`t find player on server!")
            end
        end
    end
end
Crown:Setup()

hook.Add("PlayerDeath", "PlayerDeathHook", OnKill)
hook.Add("PlayerDisconnected", "PlayerDisconnectHook", OnPlayerDisconnect)
hook.Add("PlayerSay", "PlayerSayHook", OnPlayerSay)