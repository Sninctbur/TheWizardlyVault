AddCSLuaFile()
ENT.Base = "base_anim"
ENT.Type = "anim"

function ENT:Initialize()
    self:SetNoDraw(true)

    if !self.targetPlayer then return end

    local ent = ents.Create("npc_combinedropship")
    ent:SetPos(self:GetPos())
    ent:SetAngles(self:GetAngles()) -- (self.targetPlayer:GetPos() - self.targetPos):Angle()
    ent:SetKeyValue( "squadname", "overwatch" )
    ent:SetKeyValue( "GunRange", "3000" )
    ent:SetKeyValue( "CrateType", "1" )
    ent:Spawn()
    ent:Activate()
    ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
    -- ent:GetPhysicsObject():EnableCollisions(false)
    ent:AddEntityRelationship(self.targetPlayer,D_HT,1)
    ent:SetEnemy(self.targetPlayer)

    local pathName = "cmbi_dpoint_1_"..self:EntIndex()
    self.dPoint = ents.Create("path_track")
    self.dPoint:SetPos(self.targetPos + Vector(0,0,100))
    self.dPoint:SetAngles(self:GetAngles())
    self.dPoint:SetName(pathName)
    self.dPoint:Spawn()
    self.dPoint:Activate()
    self.dPoint:Fire("Kill","",60)
    --ent:Fire("SetTrack",pathName)
    ent:Fire("SetLandTarget",pathName)
    ent:Fire("StopWaitingForDropoff")
    ent:Fire("LandLeaveCrate",10)

    self.dship = ent -- Save me some typing
    self.crate = ent:GetChildren()[2]
    for i, v in pairs(ent:GetChildren()) do
        local physObj = v:GetPhysicsObject()
        if IsValid(physObj) then
            physObj:EnableCollisions(false)
        end
        v:SetCollisionGroup(COLLISION_GROUP_WORLD)
    end
end

if SERVER then

function ENT:FlyAway()
    if !IsValid(self.dPoint) or !IsValid(self.dship) then return end

    SafeRemoveEntity(self.dPoint)
    local pathName = "cmbi_dpoint_2_"..self:EntIndex()
    self.dPoint = ents.Create("path_track")
    local vals = {-9999,9999}
    self.dPoint:SetPos(self.dship:GetPos() + Vector(vals[math.random(1,2)],vals[math.random(1,2)],9999))
    self.dPoint:SetName(pathName)
    self.dPoint:Spawn()
    self.dPoint:Activate()
    self.dship:Fire("FlyToPathTrack",pathName)
end

function ENT:Think()
    local dship = self.dship
    if !IsValid(self.crate) and IsValid(self.dship) then
        self:FlyAway()
        return
    end
    if !self.cmbi_Deployed and !IsValid(self.crate:GetParent()) then -- The crate stops being the dropship's child when it separates
        self.cmbi_Deployed = CurTime()

        local maxIndex = 8

        SafeRemoveEntityDelayed(self.crate,maxIndex * 2.3 + 25) -- 25 seconds after the last NPC spawns
        local crate = self.crate

        for i = 1,maxIndex do
            local targetPlayer = self.targetPlayer
            timer.Simple(i * 2.3,function()
                if !IsValid(crate) then return end

                local weps = {"weapon_smg1","weapon_ar2","weapon_shotgun"}

                local npc = ents.Create("npc_combine_s")
                local npcName = "cmbi_soldier_"..npc:EntIndex()
                npc:SetPos(crate:LocalToWorld(Vector(150,0,55)))
                --npc:SetPos(self.crate:LocalToWorld(Vector(-26,0,-35))) -- For jump sequence
                npc:SetAngles(crate:GetAngles())
                npc:SetName(npcName)
                npc:Give(weps[math.random(1,3)])
                npc:SetKeyValue("tacticalvariant","1")
                npc:SetKeyValue("numgrenades","1")
                npc:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS) -- Prevents all the NPCs from polymerizing
                npc:Spawn()
                npc:Activate()

                npc:SetNPCState(NPC_STATE_COMBAT)
                if IsValid(targetPlayer) then
                    npc:SetEnemy(targetPlayer)
                    npc:NavSetGoalTarget(targetPlayer)
                    npc:SetSchedule(SCHED_CHASE_ENEMY)
                else
                    npc:SetSchedule(SCHED_PATROL_RUN)
                end

                -- self.seq = ents.Create("scripted_sequence")
                -- self.seq:SetKeyValue( "spawnflags", "624" )
                -- self.seq:SetKeyValue( "m_iszEntity",npcName)
                -- self.seq:SetKeyValue( "m_iszIdle", "idle1" )
                -- self.seq:SetKeyValue( "m_fMoveTo", "4" )
                -- self.seq:SetKeyValue( "m_iszPlay", "Dropship_Deploy" )
                -- self.seq:SetPos(self.crate:GetPos())
                -- self.seq:SetAngles(self.crate:GetAngles())
                -- self.seq:Spawn()
                -- self.seq:Activate()
                -- self.seq:SetParent(self.npc)
                -- self.seq:Fire( "BeginSequence", "", 0 )
            end)
        end

        self:FlyAway()

    elseif self.cmbi_Deployed then
        if util.QuickTrace( dship:GetPos(), dship:GetForward()*300, dship ).HitSky or CurTime() - self.cmbi_Deployed >= 30 then
            dship:Remove()
            self:Remove()
        end
    end

    self:NextThink(CurTime() + .5)
    return true
end

end