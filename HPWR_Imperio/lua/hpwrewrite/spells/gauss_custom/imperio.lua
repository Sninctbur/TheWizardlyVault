local Spell = {}

Spell.Name = "Imperio"
Spell.LearnTime = 1200
Spell.Description = [[
The Imperius Curse, one of
the three Unforgivable Curses.
Allows the caster total control
over the target's actions.
The curse can be lifted
by pressing the self-cast key or
interrupting the caster's
concentration.
Only works on NPCs.
]]
Spell.Category = HpwRewrite.CategoryNames.Unforgivable
Spell.FlyEffect = "hpw_avadaked_main"
Spell.ImpactEffect = "hpw_avadaked_impact"
Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.3
Spell.Unforgivable = true
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_1, ACT_VM_PRIMARYATTACK_2 }
Spell.SpriteColor = Color(137, 235, 57)
Spell.CanSelfCast = false


function Spell:OnFire(wand)
    if IsValid(self.Owner.HpwRewriteImperio) then
        self.Owner.HpwRewriteImperio:ImperioEnd()
        return false
    end

	return true
end

function Spell:OnCollide(spell,data)
    local ent = data.HitEntity
    if ent == self.Owner then return end

    if ent.HPWRagdolledEnt then
        ent = ent.HPWRagdolledEnt
    end
    if !(ent:IsNPC() or ent:IsPlayer()) then return end

    self.Owner.HpwRewriteOldSweps = {}
    for i,wep in pairs(self.Owner:GetWeapons()) do
        table.insert(self.Owner.HpwRewriteOldSweps,wep:GetClass())
    end
    self.Owner.HpwRewriteOldAmmo = self.Owner:GetAmmo()
   
    self.Owner:StripWeapons()
    self.Owner:RemoveAllAmmo()

    if ent:IsNPC() and !HpwRewrite.BlockedNPCs[ent:GetClass()] then
        for i,npc in pairs(ents.FindByClass("npc_*")) do
            if npc:IsNPC() then
                npc.HpwRewriteDefRel = npc:Disposition(self.Owner)
                npc:AddEntityRelationship(self.Owner,npc:Disposition(ent),99)
            end
        end

        if ent:GetActiveWeapon() ~= NULL then
            local wep = ent:GetActiveWeapon()
            self.Owner:Give(wep:GetClass())
            self.Owner:SelectWeapon(wep:GetClass())
            if wep.ArcCW then
                self.Owner:GetActiveWeapon().Attachments = wep.Attachments
            end
            self.Owner:GiveAmmo(wep:Clip1() * 3, wep:GetPrimaryAmmoType())

            if ent:GetClass() == "npc_combine_s" then
                if ent:GetModel() == "models/combine_super_soldier.mdl" then
                    self.Owner:GiveAmmo(2,"AR2AltFire")
                else
                    self.Owner:Give("weapon_frag")
                end
            end
        end
    -- elseif ent:IsPlayer() then
    --     for i,wep in pairs(ent:GetWeapons()) do
    --         self.Owner:Give(wep:GetClass())
    --     end
    --     self.Owner:SelectWeapon(ent:GetActiveWeapon():GetClass() or nil)
    end
    
    local dummy = ents.Create("entity_hpwand_imperiodummy")
    dummy.Player = self.Owner
    dummy:SetModel(self.Owner:GetModel())
    dummy:SetSkin(self.Owner:GetSkin())
    for i = 1,#self.Owner:GetBodyGroups() do
        dummy:SetBodygroup(i,self.Owner:GetBodygroup(i))
    end

    dummy.PlyTbl = self.Owner:GetTable()
    dummy.PlyTbl["OldHP"] = self.Owner:Health()
    dummy.PlyTbl["OldArmor"] = self.Owner:Armor()

    dummy.TargetTbl = ent:GetTable()
    dummy.TargetTbl["Class"] = ent:GetClass()
    dummy.TargetTbl["Model"] = ent:GetModel()
    dummy.TargetTbl["Skin"] = ent:GetSkin()
    dummy.TargetTbl["IsNPC"] = ent:IsNPC()
    dummy.TargetTbl["Flags"] = ent:GetKeyValues()
    if ent:GetActiveWeapon() ~= NULL then
        dummy.TargetTbl["ActiveWep"] = ent:GetActiveWeapon():GetClass()
    end

    dummy:Spawn()
    dummy:Activate()

    self.Owner.HpwRewriteImperio = dummy
    
    timer.Simple(0,function()
        local pmCheck = string.Replace(ent:GetModel(),"models/","models/player/")
        if util.IsValidModel(pmCheck) then
            self.Owner:SetModel(pmCheck)
        else
            self.Owner:SetModel(ent:GetModel())
        end
        
        self.Owner:SetPos(ent:GetPos())
        self.Owner:SetEyeAngles(ent:GetAngles())
        self.Owner:SetHealth(ent:Health())
        self.Owner:SetMaxHealth(ent:GetMaxHealth())
        undo.ReplaceEntity(ent,self.Owner)
        ent:Remove()

        local hookName = "hpwrewrite_imperioend_"..self.Owner:EntIndex()

        hook.Add("DoPlayerDeath",hookName,function(ply,dmg)
            if !self.Owner.HpwRewriteImperio then return end
            if ply == self.Owner then
                self.Owner.HpwRewriteImperio:ImperioEnd()
            end
        end)

        hook.Add("EntityTakeDamage",hookName,function(ply,dmg)
            if !self.Owner.HpwRewriteImperio then return end
            if ply == self.Owner and dmg:GetDamage() >= ply:Health() then
                self.Owner.HpwRewriteImperio:ImperioEnd(true)
                return true
            elseif dmg:GetAttacker() == self.Owner and ply:IsNPC() then
                for i,npc in pairs(ents.FindByClass("npc_*")) do
                    if npc:IsNPC() and npc.HpwRewriteDefRel and npc:Disposition(ply) ~= D_HT then
                        npc:AddEntityRelationship(self.Owner,npc.HpwRewriteDefRel,99)
                    end
                end
                ply:AddEntityRelationship(self.Owner,D_HT,99)
            end
        end)

        hook.Add("CanPlayerSuicide",hookName,function(ply)
            if !self.Owner.HpwRewriteImperio then return end
            if ply == self.Owner then
                return false
            end
        end)

        hook.Add("PlayerButtonDown",hookName,function(ply,key)
            if !self.Owner.HpwRewriteImperio then return end
            if ply == self.Owner and HpwRewrite:IsHoldingSelfCast(self.Owner) then
                self.Owner.HpwRewriteImperio:ImperioEnd()
            end
        end)

        -- hook.Add("PreCleanupMap",hookName,function()
        --     if !self.Owner.HpwRewriteImperio then return end
        --     self.Owner.HpwRewriteImperio:ImperioEnd()
        -- end)
    end)
end

HpwRewrite:AddSpell(Spell.Name,Spell)

// Code by GaussTheWizard