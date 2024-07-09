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

    self.MVP = ply

    self.crown:SetParent(ply)
    self.crown:Fire("SetParentAttachmentMaintainOffset", "eyes")
    self.crown:SetLocalPos(Vector(-15,-15,90))
    self.crown:SetAngles(ply:GetAngles())

    PrintMessage(HUD_PRINTTALK, ply:Name() .. " is the new King!")
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
    if not Crown.MVP then
        Crown:ChangeMVP(attacker)
    else
        if victim == Crown.MVP then
            Crown:ExplodeNextToPlayer(victim)
            Crown:BreakWatermelonNextToPlayer(victim)

            Crown:ChangeMVP(attacker)
        end
    end
end

function OnPlayerDisconnect(ply)
    if ply == Crown.MVP then
        Crown.MVP = nil
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
        Crown.MVP = nil
        Crown:Setup()

        ply:PrintMessage(HUD_PRINTTALK, "You entered build mode, MVP star will be deleted :/")
    elseif string.Explode('"', text)[1] == "!setmvp " then
        local expolodedString = string.Explode('"', text)

        for k, v in ipairs(player.GetAll()) do
            if v:Name() == expolodedString[2] then
                Crown.MVP = v

                Crown:ChangeMVP(v)
            end
        end
    end
end
Crown:Setup()

hook.Add("PlayerDeath", "PlayerDeathHook", OnKill)
hook.Add("PlayerDisconnected", "PlayerDisconnectHook", OnPlayerDisconnect)
hook.Add("PlayerSay", "PlayerSayHook", OnPlayerSay)