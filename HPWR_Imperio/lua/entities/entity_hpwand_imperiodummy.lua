AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

if SERVER then

function ENT:Initialize()
    self:AddFlags(FL_OBJECT)
    self:SetPos(self.Player:GetPos())
    self:SetAngles(self.Player:GetAngles())
    self:SetCollisionBounds(self:OBBMins(),self:OBBMaxs())
    -- self:SetModel(self.Player:GetModel())
    self:PhysicsInitBox(self:OBBMins(),self:OBBMaxs())
    self:SetCollisionGroup(COLLISION_GROUP_NPC)
    self:PhysicsInitStatic(SOLID_BBOX)

    for i,npc in pairs(ents.FindByClass("npc_*")) do
        if npc.HpwRewriteDefRel then
            npc:AddEntityRelationship(self,npc.HpwRewriteDefRel,99)
        end
    end
end

function ENT:Think()
    self:PointAtEntity(self.Player)
    self:SetEyeTarget(self.Player:GetPos())
    --self:AddGesture(ACT_HL2MP_IDLE_MAGIC)
    self:SetSequence("idle_magic")

    self:NextThink(CurTime())
    return true
end

function ENT:ImperioEnd(victimDead,noremove,dmg)
    timer.Simple(0,function()
        local hookName = "hpwrewrite_imperioend_"..self.Player:EntIndex()
        hook.Remove("DoPlayerDeath",hookName)
        hook.Remove("EntityTakeDamage",hookName)
        hook.Remove("CanPlayerSuicide",hookName)
        hook.Remove("PlayerButtonDown",hookName)
        --hook.Remove("PreCleanupMap",hookName)

        sound.Play("ambient/wind/wind_snippet2.wav",self.Player:GetPos(),75,255)

        if self.TargetTbl["IsNPC"] then
            local ent = ents.Create(self.TargetTbl["Class"])
            ent:SetPos(self.Player:GetPos())
            ent:SetAngles(self.Player:GetAngles())
            ent:SetTable(self.TargetTbl)
            ent:SetModel(self.TargetTbl["Model"])
            ent:SetSkin(self.TargetTbl["Skin"])
            for k,v in pairs(self.TargetTbl["Flags"]) do
                ent:SetKeyValue(k,tostring(v))
            end
            ent:Spawn()
            ent:Activate()

            local wep = self.Player:GetActiveWeapon()
            if IsValid(wep) then
                ent:Give(wep:GetClass())
                if wep.ArcCW then
                    ent:GetActiveWeapon().Attachments = wep.Attachments
                end
            end

            if !victimDead then
                ent:SetHealth(self.Player:Health())
            else
                local dmg = DamageInfo()
                dmg:SetDamage(ent:Health())
                dmg:SetAttacker(self.Player)
                ent:TakeDamageInfo(dmg)
            end
            undo.ReplaceEntity(self.Player,ent)
        end

        self.Player:Spawn()
        self.Player:SetPos(self:GetPos())
        self.Player:SetEyeAngles(self:GetAngles())
        self.Player:SetModel(self:GetModel())
        self.Player:SetupHands()

        self.Player:StripWeapons()

        for i,wep in pairs(self.Player.HpwRewriteOldSweps or {}) do
            self.Player:Give(wep)
        end
        for typ,ammo in pairs(self.Player.HpwRewriteOldAmmo or {}) do
            self.Player:GiveAmmo(ammo,typ)
        end
        self.Player:SelectWeapon("weapon_hpwr_stick")

        self.Player:SetMaxHealth(100) -- does not account for the niche cases where the player's max health would not be 100
        self.Player:SetHealth(self.PlyTbl["OldHP"] - (dmg or 0))
        self.Player:SetArmor(self.PlyTbl["OldArmor"])

        for i,npc in pairs(ents.FindByClass("npc_*")) do
            if npc:IsNPC() and npc.HpwRewriteDefRel then
                npc:AddEntityRelationship(self.Player,npc.HpwRewriteDefRel,99)
            end
        end
        
        if !noremove then
            self:Remove()
        end
    end)
end

function ENT:OnTakeDamage(dmg)
    self:ImperioEnd(false,false,dmg:GetDamage())
end

function ENT:OnRemove()
    self:ImperioEnd()
end

end