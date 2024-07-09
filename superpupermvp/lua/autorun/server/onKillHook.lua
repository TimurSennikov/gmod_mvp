local NULLVEC = Vector(0,0,-100)

local isThereMVP = false

Crown = {}

function Crown:Setup()
    self.MVP = 0

    self.crown = ents.Create("prop_physics")

    self.crown:SetModel("models/balloons/balloon_star.mdl")

    self.crown:SetCollisionGroup(1)

    self.crown:Fire("SetParentAttachmentMaintainOffset", "eyes")

    self.crown:Spawn()
end

function Crown:DeleteMVP()
    if self.crown then
        self.MVP = nil

        self.crown:SetParent(nil)
        self.crown:SetPos(NULLVEC)

        isThereMVP = false
    end  
end

function Crown:BaBaX(ply)
    local can = ents.Create("prop_physics")

    can:SetModel("models/props_junk/gascan001a.mdl")
    can:SetPos(ply:GetPos())

    can:Spawn()

    can:Fire("break")
end

function Crown:ChangeMVP(ply)
    if not IsValid(self.crown) then
        self:Setup()
    end

    self.MVP = ply

    self.crown:SetParent(ply)
    self.crown:SetLocalPos(Vector(0, 0, 80))

    PrintMessage(HUD_PRINTTALK, ply:Name() .. " is the new King!")
end

function CalcMVP(victim, inflictor, attacker)
    if not isThereMVP then
        Crown.MVP = attacker
        Crown:ChangeMVP(attacker)
        isThereMVP = true
    else
        if victim == Crown.MVP then
            if attacker:IsPlayer() then
                Crown:BaBaX(victim)
                Crown.MVP = attacker
                Crown:ChangeMVP(attacker)
            end
        end
    end
end

function ResetIfNotMVP(ply)
    if ply == Crown.MVP then
        Crown:DeleteMVP()
    end
end

Crown:Setup()

hook.Add("PlayerDeath", "PlayerDeathHook", CalcMVP)
hook.Add("PlayerDisconnected", "PlayerDisconnectHook", ResetIfNotMVP)