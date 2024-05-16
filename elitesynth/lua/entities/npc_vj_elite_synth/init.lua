AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/elite_synth.mdl" -- Leave empty if using more than one model
ENT.StartHealth = GetConVarNumber("vj_elite_synth_h")
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_MEDIUM_TALL
ENT.HasHull = true -- Set to false to disable HULL
ENT.HullSizeNormal = false -- set to false to cancel out the self:SetHullSizeNormal()
ENT.HasSetSolid = true -- set to false to disable SetSolid
ENT.SightDistance = 10000 -- How far it can see
ENT.SightAngle = 80 -- The sight angle | Example: 180 would make the it see all around it | Measured in degrees and then converted to radians
ENT.TurningSpeed = 20 -- How fast it can turn
ENT.VJ_IsHugeMonster = false -- Is this a huge monster?
ENT.VJ_IsStationary = false -- Is this a stationary SNPC?
	-- Blood & Damages ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.GodMode = false -- Immune to everything
ENT.Bleeds = true -- Does the SNPC bleed? (Blood decal, particle and etc.)
ENT.HasBloodParticle = true -- Does it spawn a particle when damaged?
ENT.HasBloodPool = true -- Does it have a blood pool?
ENT.HasBloodDecal = true -- Does it spawn a decal when damaged?
ENT.BloodParticle = {"blood_impact_yellow_01"} -- Particle that the SNPC spawns when it's damaged
ENT.BloodPoolParticle = {} -- Leave empty for the base to decide which pool blood it should use
ENT.BloodDecal = {"YellowBlood"} -- Leave blank for none | Commonly used: Red = Blood, Yellow Blood = YellowBlood
ENT.BloodDecalRate = 1000 -- The bigger the number, the more chance it has of spawning the decal | Remember to use 5 or 10 when using big decals (Ex: Antlion Splat)
ENT.BloodDecalDistance = 300 -- How far the decal can spawn
ENT.GetDamageFromIsHugeMonster = false -- Should it get damaged no matter what by SNPCs that are tagged as VJ_IsHugeMonster?
ENT.AllowIgnition = true -- Can this SNPC be set on fire?
ENT.Immune_CombineBall = true -- Immune to Combine Ball
ENT.Immune_AcidPoisonRadiation = true -- Immune to Acid, Poison and Radiation
ENT.Immune_Bullet = true -- Immune to Bullets
ENT.Immune_Blast = false -- Immune to Explosives
ENT.Immune_Electricity = false -- Immune to Electrical
ENT.Immune_Freeze = false -- Immune to Freezing
ENT.Immune_Physics = true -- Immune to Physics
ENT.CallForBackUpOnDamage = true -- Should the SNPC call for help when damaged? (Only happens if the SNPC hasn't seen a self.enemy)
ENT.CallForBackUpOnDamageDistance = 800 -- How far away the SNPC's call for help goes | Counted in World Units
ENT.CallForBackUpOnDamageUseCertainAmount = true -- Should the SNPC only call certain amount of people?
ENT.CallForBackUpOnDamageUseCertainAmountNumber = 5 -- How many people should it call if certain amount is enabled?
	-- Relationships ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.HasAllies = true -- Put to false if you want it not to have any allies
ENT.VJ_NPC_Class = {CLASS_COMBINE} -- NPCs with the same class will be friendly to each other | Combine: CLASS_COMBINE, Zombie: CLASS_ZOMBIE, Antlions = CLASS_ANTLION
ENT.NextChaseTimeOnSetEnemy = 0.1 -- Time until it starts chasing, after seeing an self.enemy
ENT.PlayerFriendly = false -- Makes the SNPC friendly to the player and HL2 Resistance
ENT.FriendsWithAllPlayerAllies = false -- Should this SNPC be friends with all other player allies that are running on VJ Base?
ENT.NextEntityCheckTime = 0.05 -- Time until it runs the NPC check
ENT.NextHardEntityCheck1 = 80 -- Next time it will do hard entity check | The first # in math.random
ENT.NextHardEntityCheck2 = 100 -- Next time it will do hard entity check | The second # in math.random
ENT.NextFindEnemyTime = 1 -- Time until it runs FindEnemy again
ENT.CombineFriendly = true
	-- Death ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.HasDeathRagdoll = true -- If set to false, it will not spawn the regular ragdoll of the SNPC
ENT.DeathEntityType = "prop_ragdoll" -- Type entity the death ragdoll uses
ENT.CorpseAlwaysCollide = false -- Should the corpse always collide?
ENT.HasDeathBodyGroup = true -- Set to true if you want to put a bodygroup when it dies
	-- Melee Attack ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDamage = 50
ENT.MeleeAttackDamageType = DMG_CRUSH -- Type of Damage
ENT.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1} -- Melee Attack Animations
ENT.MeleeAttackAnimationDelay = 0.5 -- It will wait certain amount of time before playing the animation
ENT.MeleeAttackAnimationFaceEnemy = false -- Should it face the self.enemy while playing the melee attack animation?
ENT.MeleeAttackAnimationDecreaseLengthAmount = 0.5 -- This will decrease the time until starts chasing again. Use it to fix animation pauses until it chases the self.enemy.
ENT.MeleeAttackDistance = 30 -- How close does it have to be until it attacks?
ENT.MeleeAttackAngleRadius = 100 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
ENT.MeleeAttackDamageDistance = 80 -- How far does the damage go?
ENT.MeleeAttackDamageAngleRadius = 100 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
ENT.TimeUntilMeleeAttackDamage = 0.6 -- This counted in seconds | This calculates the time until it hits something
ENT.NextMeleeAttackTime = 0.2 -- How much time until it can use a melee attack?
ENT.NextAnyAttackTime_Melee = 0.2 -- How much time until it can use a attack again? | Counted in Seconds
ENT.MeleeAttackReps = 1 -- How many times does it run the melee attack code?
ENT.StopMeleeAttackAfterFirstHit = false -- Should it stop the melee attack from running rest of timers when it hits an self.enemy?
ENT.HasMeleeAttackKnockBack = true -- If true, it will cause a knockback to its self.enemy
ENT.MeleeAttackKnockBack_Forward1 = 350 -- How far it will push you forward | First in math.random
ENT.MeleeAttackKnockBack_Forward2 = 350 -- How far it will push you forward | Second in math.random
ENT.MeleeAttackKnockBack_Up1 = 200 -- How far it will push you up | First in math.random
ENT.MeleeAttackKnockBack_Up2 = 200 -- How far it will push you up | Second in math.random
ENT.MeleeAttackKnockBack_Right1 = 0 -- How far it will push you right | First in math.random
ENT.MeleeAttackKnockBack_Right2 = 0 -- How far it will push you right | Second in math.random
	-- Range Attack ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.NoChaseWhenAbleToRangeAttack = false -- When set to true, the SNPC will not chase the self.enemy when its distance is good for range attack, instead it will keep standing there and range attacking
ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.AnimTbl_RangeAttack = {ACT_RANGE_ATTACK1} -- Range Attack Animations
ENT.RangeAttackAnimationDelay = 1.5 -- It will wait certain amount of time before playing the animation
ENT.RangeAttackAnimationFaceEnemy = true -- Should it face the self.enemy while playing the range attack animation?
ENT.RangeAttackAnimationDecreaseLengthAmount = 0.2 -- This will decrease the time until starts chasing again. Use it to fix animation pauses until it chases the self.enemy.
ENT.RangeDistance = 2500 -- This is how far away it can shoot
ENT.RangeToMeleeDistance = 250 -- How close does it have to be until it uses melee?
ENT.RangeUseAttachmentForPos = false -- Should the projectile spawn on a attachment?
ENT.RangeUseAttachmentForPosID = "muzzle" -- The attachment used on the range attack if RangeUseAttachmentForPos is set to true
ENT.RangeUpPos = 20 -- Spawning Position for range attack | + = up, - = down
ENT.TimeUntilRangeAttackProjectileRelease = 1.5 -- How much time until the projectile code is ran?
ENT.NextRangeAttackTime = 2 -- How much time until it can use a range attack?
ENT.NextAnyAttackTime_Range = 1 -- How much time until it can use a attack again? | Counted in Seconds
ENT.RangeAttackReps = 1 -- How many times does it run the projectile code?
ENT.RangeAttackExtraTimers = {} -- Extra range attack timers | it will run the projectile code after the given amount of seconds
ENT.DisableDefaultRangeAttackCode = true -- When true, it won't spawn the range attack entity, allowing you to make your own
ENT.DisableRangeAttackAnimation = false -- if true, it will disable the animation code
	-- Sounds ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.HasSounds = true -- Put to false to disable ALL sounds
ENT.HasImpactSounds = true -- If set to false, it won't play the impact sounds
ENT.HasAlertSounds = true -- If set to false, it won't play the alert sounds
ENT.HasMeleeAttackSounds = true -- If set to false, it won't play the melee attack sound
ENT.HasExtraMeleeAttackSounds = false -- Set to true to use the extra melee attack sounds
ENT.HasMeleeAttackMissSounds = true -- If set to false, it won't play the melee attack miss sound
ENT.HasLeapAttackSound = true -- If set to false, it won't play the leaping sounds
ENT.HasRangeAttackSound = true -- If set to false, it won't play the range attack sounds
ENT.HasIdleSounds = true -- If set to false, it won't play the idle sounds
ENT.PlayNothingWhenCombatIdleSoundTableEmpty = false -- TRUE will disable: the base plays the regular idle sounds when the combat idle sound table is empty while the SNPC is in combat
ENT.HasPainSounds = true -- If set to false, it won't play the pain sounds
ENT.HasDeathSounds = true -- If set to false, it won't play the death sounds
ENT.HasFootStepSound = true -- Should the SNPC make a footstep sound when it's moving?
ENT.FootStepTimeRun = 0.9 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 0.9 -- Next foot step sound when it is walking
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"esynth/step1.wav"}
ENT.SoundTbl_Breath = {}
ENT.SoundTbl_Idle = {}
ENT.SoundTbl_CombatIdle = {}
ENT.SoundTbl_FollowPlayer = {}
ENT.SoundTbl_UnFollowPlayer = {}
ENT.SoundTbl_MedicBeforeHeal = {}
ENT.SoundTbl_MedicAfterHeal = {}
ENT.SoundTbl_OnPlayerSight = {}
ENT.SoundTbl_Alert = {"esynth/alert.wav"}
ENT.SoundTbl_BecomeEnemyToPlayer = {}
ENT.SoundTbl_BeforeMeleeAttack = {}
ENT.SoundTbl_MeleeAttack = {"esynth/melee.wav"}
ENT.SoundTbl_MeleeAttackExtra = {}
ENT.SoundTbl_MeleeAttackMiss = {"npc/zombie/claw_miss1.wav","npc/zombie/claw_miss2.wav"}
ENT.SoundTbl_RangeAttack = {}
ENT.SoundTbl_LeapAttack = {}
ENT.SoundTbl_Pain = {"esynth/pain1.wav","esynth/pain2.wav"}
ENT.SoundTbl_Death = {"esynth/cs_pissed01.wav"}

ENT.MeleeAttackSoundChance = 1

function ENT:CustomRangeAttackCode()
	if !self:IsValid() then return end
	if not self:Visible(self:GetEnemy()) then return end
	self.IsShooting = true
		local att = self:GetAttachment(1)
		self.enemy = self:GetEnemy()
		self:SetEyeTarget(self.enemy:GetPos())
		self.GuardGunTrace = nil
		
		self.GuardGunTrace = util.TraceLine({
			start = att.Pos,
			endpos = (self.enemy:GetPos()) + (self.enemy:GetPos() - self:GetPos() + Vector(0,0,-60)) * 10000 + (self.enemy:GetVelocity() * 10000) + VectorRand() * 2,
			filter = function(v)
				if v:GetClass() == "prop_physics" then
					return true
				end
				return false
			end
		})

		if not self.enemy:VisibleVec(self.GuardGunTrace.HitPos) then
			self.GuardGunTrace = util.TraceLine({
				start = att.Pos,
				endpos = (self.enemy:GetPos()) + (self.enemy:GetPos() - self:GetPos()) * 10000 + (self.enemy:GetVelocity() * 10000) + VectorRand() * 2,
				filter = function(v)
					if v:GetClass() == "prop_physics" then
						return true
					end
					return false
				end
			})
		end
		if not self.enemy:VisibleVec(self.GuardGunTrace.HitPos) then
			self.IsShooting = false
			return
		end

		self:EmitSound("weapons/cguard/charging.wav",400,100)
		local effectdata = EffectData()
		effectdata:SetEntity(self)
		effectdata:SetOrigin(self.GuardGunTrace.HitPos)
		util.Effect("cguard_cannon",effectdata,true,true)
		timer.Simple(1, function()
			if self:IsValid() and IsValid(self.enemy) then
				self:EmitSound("npc/vort/attack_shoot.wav",511,100)
				sound.Play("weapons/mortar/mortar_explode"..math.random(1,3)..".wav",self.GuardGunTrace.HitPos)
				local fx1 = EffectData()
				fx1:SetEntity(self)
				fx1:SetOrigin(self.GuardGunTrace.HitPos)
				util.Effect("cguard_cannon_fire",fx1)
				util.Effect("cguard_cannon_mzlflash",fx1)

				local fx = EffectData()
				fx:SetOrigin(self.GuardGunTrace.HitPos)
				fx:SetNormal(self.GuardGunTrace.HitPos)
				util.Effect("cguard_cannon_explode",fx)
				util.ScreenShake(self.GuardGunTrace.HitPos,2000,5,.5,1000)
				util.Decal("Scorch",self.GuardGunTrace.HitPos - self.GuardGunTrace.HitNormal,self.GuardGunTrace.HitPos + self.GuardGunTrace.HitNormal,nil)


				self.GuardGunTrace = util.TraceLine({
					start = att.Pos,
					endpos = self.GuardGunTrace.HitPos,
					filter = table.Merge(ents.FindByClass("player"),ents.FindByClass("npc_*"))
				})

				local hitEnts = {}
				for i,v in pairs(ents.FindAlongRay(att.Pos,self.GuardGunTrace.HitPos)) do
					if IsValid(v) and not (v:IsPlayer() and GetConVar("ai_ignoreplayers"):GetBool()) and (not v:IsNPC() or self:Disposition(v) == D_HT) then

						local dmg = DamageInfo()
						dmg:SetDamageType(bit.bor(DMG_DISSOLVE,DMG_BLAST,DMG_BULLET))
						dmg:SetAttacker(self)
						
						if v:IsPlayer() then
							dmg:SetDamage(125)
						else
							dmg:SetDamage(250)
						end
						dmg:SetDamageForce((v:GetPos() - self:GetPos()):GetNormalized() * 9000)
						
						timer.Simple(.0001,function()
							if IsValid(v) and IsValid(v:GetPhysicsObject()) then
								local hit = util.QuickTrace(att.Pos,self.GuardGunTrace.HitPos).HitPos
								v:GetPhysicsObject():ApplyForceOffset(dmg:GetDamageForce(),v:GetPos() - hit)
							end
						end)

						table.Add(hitEnts,v)
						v:TakeDamageInfo(dmg)
					end
				end

				for i,v in pairs(ents.FindInSphere(self.GuardGunTrace.HitPos,2000)) do
					local visibleVec = util.TraceLine({
						start = self.GuardGunTrace.HitPos - self.GuardGunTrace.HitNormal,
						endpos = v:GetPos(),
						filter = ents.GetAll()
					})
					if IsValid(v) and not table.HasValue(hitEnts,v) and not (v:IsPlayer() and GetConVar("ai_ignoreplayers"):GetBool()) 
					and (not v:IsNPC() or self:Disposition(v) == D_HT) and not visibleVec.HitWorld then
						local dmg = DamageInfo()
						dmg:SetDamageType(bit.bor(DMG_BLAST,DMG_CRUSH))
						dmg:SetAttacker(self)

						dmg:SetDamageForce((v:GetPos() - self.GuardGunTrace.HitPos):GetNormalized() * (30000 / (1 + v:GetPos():Distance(self.GuardGunTrace.HitPos - self.GuardGunTrace.HitNormal) / 500))
							* Vector(1,1,2.5))
						dmg:SetDamage(200 - (v:GetPos():Distance(self.GuardGunTrace.HitPos)))
						if v:IsPlayer() then
							dmg:SetDamage(dmg:GetDamage() / 2)
						end

						v:TakeDamageInfo(dmg)
						timer.Simple(.0001,function()
							if IsValid(v) and IsValid(v:GetPhysicsObject()) then
								v:GetPhysicsObject():ApplyForceCenter(dmg:GetDamageForce())
							end
						end)
					end
				end

				-- local vaporizer = ents.Create("point_hurt")
				-- if !vaporizer:IsValid() then return end
				-- vaporizer:SetKeyValue("Damage", 500)
				-- vaporizer:SetKeyValue("DamageRadius", 250)
				-- vaporizer:SetKeyValue("DamageType",DMG_DISSOLVE)
				-- vaporizer:SetPos(self.GuardGunTrace.HitPos)
				-- vaporizer:SetOwner(self)
				-- vaporizer:Spawn()
				-- vaporizer:Fire("hurt","",0)
				-- vaporizer:Fire("kill","",0.1)				
			end
		end)
	self.IsShooting = false
end

-- function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo,hitgroup)
-- 	if dmginfo:GetDamageType() == DMG_CRUSH then
-- 		dmginfo:SetDamage(dmginfo:GetDamage() / 5)
-- 	end
-- end

-- To add rest of the SNPC and get full list of the function, you need to decompile VJ Base.

/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/