AddCSLuaFile()

-- Blood decal/particle effects
function hitEffect(ent,dmginfo)
	if not GetConVar("veo_enabled"):GetBool() then return end
	if IsValid(ent) and dmginfo ~= nil and dmginfo:GetDamage() > 0 and ent.Base ~= "base_nextbot" and (ent:IsRagdoll() or ent:IsNPC() or ent:IsPlayer()) and (ent.IsSpawned == nil or GetConVar("veo_spawnedrags"):GetBool()) and (ent.DamagesInTick == nil or ent.DamagesInTick <= 3) then
		ent.EndHitEffect = nil
		if dmginfo:GetInflictor():IsRagdoll() then return end
		
		if ent.LastDamage == nil then
			ent.LastDamage = dmginfo
		elseif ent.LastDamage:GetDamage() == 0 then
			ent.LastDamage:SetDamageType(dmginfo:GetDamageType())
			ent.LastDamage:SetDamage(dmginfo:GetDamage())
		elseif GetConVar("veo_compensation"):GetBool() then
			if GetConVar("veo_debuginfo"):GetBool() and ent.DamagesInTick ~= nil then
				print("VEO: Compensation trigger x"..ent.DamagesInTick.." on ent "..ent:EntIndex())
			end
			ent.LastDamage:SetDamage(ent.LastDamage:GetDamage() + dmginfo:GetDamage() * 5)
		end

		if ent.DamagesInTick == nil then
			ent.DamagesInTick = 1
		else
			ent.DamagesInTick = ent.DamagesInTick + 1
		end

		local dmg = dmginfo:GetDamageType()
		local InflictorIsWorld = ((dmginfo:GetInflictor() == NULL or dmginfo:GetInflictor() == game:GetWorld() or IsEntity(dmginfo:GetInflictor())) and BitEq(dmg,DMG_CRUSH))
		-- if not InflictorIsWorld and IsValid(dmginfo:GetInflictor()) and IsValid(dmginfo:GetInflictor():GetPhysicsObject()) then
		-- 	InflictorIsWorld = not dmginfo:GetInflictor():GetPhysicsObject():IsMoveable()
		-- end

		local dmgTypes = {
			DMG_CRUSH,
			DMG_BULLET,
			DMG_CLUB,
			DMG_SLASH,
			DMG_BUCKSHOT,
			DMG_SNIPER,
			DMG_AIRBOAT
		}

		timer.Simple(.02,function()
			if IsValid(ent) then
				ent.LastDamage = DamageInfo()
				ent.LastDamage:SetDamage(0)
				ent.DamagesInTick = 0
			end
		end)

		local dmgCheck = false
		if (InflictorIsWorld and dmginfo:GetDamage() < 100) then return end
		for i,v in pairs(dmgTypes) do
			if BitEq(dmg,v) then
				dmgCheck = true
				break
			end
		end
		if dmgCheck == false then return end

		if GetConVar("veo_debuginfo"):GetBool() then
			print("VEO: event of damage "..ent.LastDamage:GetDamage().." type "..dmg.." on ent "..ent:EntIndex())
		end

		if dmginfo:GetDamagePosition() == Vector(0,0,0) then
			dmginfo:SetDamagePosition(ent:GetPos() + Vector(0,0,50))
		end

		local decal = "Blood"
		local eff = "BloodImpact"
        local b = ent.BloodCol
		local scale = math.Clamp(ent.LastDamage:GetDamage() / 400 * (math.random(8,15) / 10),.25,1.5)

		local effect = EffectData()
		local function setEffect()
			if b == nil then
				b = ent:GetBloodColor()
			end
			if ent:GetMaterialType() == MAT_METAL then
				ent.BloodCol = 3
				b = 3
				eff = "MetalSpark"
				decal = nil
			elseif b ~= nil then
				if b == 0 then
					eff = "BloodImpact"
					decal = "Blood"
				elseif b == 3 then
					eff = "MetalSpark"
					decal = nil
				elseif b >= 1 then
					eff = "BloodImpact"
					decal = "YellowBlood"
				else
					eff = nil
					decal = nil
				end
			else
				eff = nil
				decal = nil
			end

			if decal == nil then return
			elseif decal == "YellowBlood" then
				effect:SetColor(1)
			else
				effect:SetColor(0)
			end
            effect:SetScale(scale)
		end
		
		setEffect()
		if eff == nil then return end
		
		effect:SetOrigin(dmginfo:GetDamagePosition())
		util.Effect( eff, effect ) 

        --if b == 3 or BitEq(dmg,DMG_ENERGYBEAM) then return end --HERE WE GO

		-- Huge impact sound effect
		if (InflictorIsWorld and dmginfo:GetDamage() >= 200) or (not InflictorIsWorld and dmg == DMG_CRUSH and dmginfo:GetDamage() >= 50) then
			ent:EmitSound("physics/body/body_medium_break"..math.random(2,4)..".wav")
		end

		local hitBone = nil
		local hitDist = math.huge
		
		for i = 0,ent:GetBoneCount() do
			local bone = ent:GetBonePosition(i)
			if bone ~= nil and (hitBone == nil or bone:Distance(dmginfo:GetDamagePosition()) < hitDist) then
				hitBone = i
				hitDist = bone:Distance(dmginfo:GetDamagePosition())
			end
		end

		local traceinfo
		local normal
		function effectFunc() -- Nested function for decal effects; will be called a lot
			if traceinfo == nil or ent.EndHitEffect == true or decal == nil then return end
            local trace = util.TraceLine(traceinfo)
			normal = (trace.HitPos - trace.StartPos):GetNormalized() + ent:GetVelocity():GetNormalized() * math.Clamp(ent:GetVelocity():Length() / 1000,0,5)

			if trace.Hit and trace.HitSky == false then
				scale = math.Clamp(scale - (trace.HitPos:Distance(traceinfo.start) / 600),.1,2)
			else
				traceinfo.start = trace.HitPos
                traceinfo.endpos = trace.HitPos - Vector(0,0,999999) + VectorRand() * 20
				trace = util.TraceLine(traceinfo)
				
				debugoverlay.Line(traceinfo.start,traceinfo.endpos,5)

                scale = math.Clamp(scale - (trace.HitPos:Distance(traceinfo.start) / 2000),0,2)
            end

			if trace.Hit and trace.HitSky == false then
				effect:SetOrigin(trace.HitPos)

				-- if (ent:GetClass() == "npc_antlion" and ent.LastDamage:GetDamage() >= ent:GetMaxHealth()) or (ent:GetClass() == "npc_antlion_worker" and ent.LastDamage:GetDamage() >= ent:Health()) then
				-- 	scale = scale * 1.5
				-- end
				if ent:IsRagdoll() then -- Corpses have less blood in them
					if InflictorIsWorld or dmg == DMG_CRUSH then
						scale = scale / 3
						normal = normal / 4
					else
						scale = scale / 2
						normal = normal / 3
					end
				elseif ent.LastDamage:GetDamage() < ent:Health() then
					scale = scale * .75
				end
				if hitBone ~= nil then
					if ent:GetBoneName(hitBone) == "ValveBiped.Bip01_Head1" then
						scale = scale * .9
					elseif ent:GetBoneName(hitBone) == "ValveBiped.Bip01_Spine" then
						scale = scale * 1.1
					end
				end

				if scale >= 1 and trace.Hit then
					setEffect()
					util.Effect(eff, effect)
					sound.Play("physics/flesh/flesh_squishy_impact_hard"..math.random(1,4)..".wav",trace.HitPos,75,100,1)
				end
				
				if trace.Entity:IsPlayer() then
					if decal == "Blood" then
						trace.Entity:ScreenFade(SCREENFADE.IN,Color(100,0,0,64),.5,0)
					else
						trace.Entity:ScreenFade(SCREENFADE.IN,Color(100,100,0,128),.5,0)
					end
				end
				if scale <= 0 then return end
				
				if trace.HitWorld then
					DecalEx(decal,trace.Entity,trace.HitPos + normal,normal,scale + normal:Length(),scale + normal:Length() / 2)
				elseif trace.Entity == ent then
					DecalEx(decal,trace.Entity,trace.HitPos + normal,normal,scale * 6,scale * 6)
				elseif trace.Entity:IsNPC() or trace.Entity:IsPlayer() then
					DecalEx(decal,trace.Entity,trace.HitPos + normal,normal,scale * 2,scale * 2)
				elseif scale >= 1 then
					util.Decal(decal,dmginfo:GetDamagePosition(),trace.HitPos,traceinfo.filter)
				end
			end
		end
		local loopNum = math.random(3,5) + math.Clamp(ent.LastDamage:GetDamage() / 200,0,4)
		if ent:IsRagdoll() then
			loopNum = math.Clamp(loopNum,1,3)
		end
		local multNum = 1
		if InflictorIsWorld then
			multNum = 1/4
		end
		for i = 1,loopNum do
			traceinfo = {
				start = dmginfo:GetDamagePosition(),
				endpos = dmginfo:GetDamagePosition() + ((dmginfo:GetDamageForce():GetNormalized() * math.Clamp(ent.LastDamage:GetDamage(),1,20) * multNum) * 15 * math.random(-60,100) / 100),
				filter = ent
			}
			traceinfo.endpos = traceinfo.endpos + VectorRand() * (traceinfo.start:Distance(traceinfo.endpos) / 1.5)
			if GetConVar("veo_propdecals"):GetBool() == false then
				traceinfo.filter = ents.GetAll()
			end

			debugoverlay.Line(traceinfo.start,traceinfo.endpos,5)
			
			effectFunc()
			if math.random(1,5) == 5 then
				traceinfo.filter = NULL
				traceinfo.endpos = ent:GetPos() + (ent:GetPos() - dmginfo:GetDamagePosition())
				debugoverlay.Line(traceinfo.start,traceinfo.endpos,5,Color(255,0,0))
				effectFunc()
			end
		end
		

		effect:SetScale(.5)
		
		if hitBone == nil then return end

		if InflictorIsWorld then return end
		local timerName = "spray-"..ent:EntIndex().."-"..hitBone
		timer.Create(timerName,math.Clamp(math.floor(math.random(1,5) / ent.LastDamage:GetDamage()),.25,1.5),math.Clamp(ent.LastDamage:GetDamage() * math.random(20,140) / 500 - 2,1,12),function()
			local locTimer = timerName
			local locEnt = ent
			local locBone = hitBone
			if locEnt.EndHitEffect == true then timer.Remove(locTimer) end
			if locBone == nil then timer.Remove(locTimer) end
			if not IsValid(locEnt) or (locEnt:IsPlayer() and locEnt:Alive() == false) then
				if ent.pRag ~= nil then
					locEnt = locEnt.pRag
				else
					timer.Remove(locTimer)
					return
				end
			end
			if IsValid(locEnt) then
				effect:SetOrigin(locEnt:GetBonePosition(locBone))
				setEffect(locEnt)
				util.Effect(eff,effect)
			end
		end)
		timer.Start(timerName)


		if GetConVar("veo_pooling"):GetBool() and b ~= 3 then
			local timerName = "pool-"..ent:EntIndex().."-"..hitBone
			local loopNum = math.floor(ent.LastDamage:GetDamage() * math.random(0,25) / 150 - 2)
			if ent:IsRagdoll() then loopNum = loopNum * 2 end
			if loopNum > 0 then
				timer.Create(timerName,1.5,math.min(loopNum,15),function()
					local locTimer = timerName
					local locEnt = ent
					local locBone = hitBone
					if not IsValid(locEnt) then timer.Remove(locTimer) end
					if locEnt.EndHitEffect == true then timer.Remove(locTimer) end
					--if (locEnt:IsNPC() or (locEnt:IsPlayer() and locEnt:Alive())) and locEnt:Health() == locEnt:GetMaxHealth() then timer.Remove(locTimer) end
	
					if not IsValid(locEnt) or (locEnt:IsPlayer() and locEnt:Alive() == false) then
						if ent.pRag ~= nil then
							locEnt = locEnt.pRag
						else
							timer.Remove(locTimer)
							return
						end
					end
	
					local bonePos = locEnt:GetBonePosition(locBone)
					--if not IsValid(bonePos) then timer.Remove(locTimer) end
					local trace = util.TraceLine({
						start = bonePos,
						endpos = bonePos + Vector(0,0,-50) + VectorRand() * 16,
						filter = ent
					})
	
					if trace.Hit then
						local scale = math.random(25,75)/100
						local normal = ent:GetVelocity():GetNormalized() * math.Clamp(ent:GetVelocity():Length() / 100,0,5)
						DecalEx(decal,trace.Entity,trace.HitPos,normal,scale + normal:Length() / 4,scale)
					end

					if GetConVar("veo_bloodloss"):GetBool() and IsValid(locEnt) and (locEnt:IsNPC() or (locEnt:IsPlayer() and locEnt:Alive())) then
						locEnt:TakeDamage(1,dmginfo:GetAttacker(),dmginfo:GetInflictor())
					end
				end)
				timer.Start(timerName)
			end
		end
	end
end


if SERVER then -------------------------------------------------------------------------------
print("VEO loaded!")

CreateConVar("veo_enabled","1",FCVAR_ARCHIVE,"Enable or disable VEO without restarting the server.")
CreateConVar("veo_plyserverrags","1",FCVAR_ARCHIVE,[[If enabled, when ai_serverragdolls is enabled, player ragdolls become physical as well.
Turn this off if you are using another addon that creates physical player corpses.]])
CreateConVar("veo_pooling","1",FCVAR_ARCHIVE,[[If enabled, ragdolls will continue to bleed after getting damaged.]])
CreateConVar("veo_corpsechar","1",FCVAR_ARCHIVE,[[If enabled, burning ragdolls will gradually turn black.]])
CreateConVar("veo_spawnedrags","0",FCVAR_ARCHIVE,[[If enabled, ragdolls that are manually created by players using the spawnmenu will be affected by VEO.]])
CreateConVar("veo_compensation","1",FCVAR_ARCHIVE,[[If enabled, very quick consecutive hits will create bigger blood splatters.
This makes shotguns and hard impacts deliver a much stronger effect.]])
CreateConVar("veo_propdecals","1",FCVAR_ARCHIVE,[[If enabled, ragdolls, entities, and props can be stained with blood. If disabled, only the world will be stained with blood.
May fix a select few crashes.]])
CreateConVar("veo_bloodloss","0",FCVAR_ARCHIVE,[[If enabled, living entities who start bleeding take 1 damage each time they create a decal.
This mechanic is immersive, but inconsistent and highly random.
veo_pooling must be set to 1 in order for this to work.]])
CreateConVar("veo_debuginfo","0",FCVAR_ARCHIVE,[[If enabled, VEO will spam the console with information about what it's doing.]])


util.AddNetworkString("DecalEx")
util.AddNetworkString("RagdollMade")
util.AddNetworkString("ClientRag")

function DecalEx(d,e,p,n,w,h)
	if not GetConVar("veo_enabled"):GetBool() then return end
	if e == nil or e.BloodCol == 3 then return end
	if e:GetNoDraw() == true then return end
	if IsValid(e:GetBrushSurfaces()) then
		if e:GetBrushSurfaces():IsNoDraw() then return end
	end
	net.Start("DecalEx")
	net.WriteTable({decal = d,entity = e,pos = p,normal = n,width = w,height = h})
    net.Send(player.GetAll())
end

function BitEq(b1,b2)
	return bit.band(b1,b2) == b2
end


-- Corpse charring effect
timer.Create("veo_burneffect",.5,0,function()
	if not GetConVar("veo_enabled"):GetBool() or not GetConVar("veo_corpsechar"):GetBool() then return end
	for i,ent in pairs(ents.FindByClass("prop_ragdoll")) do
		if (ent.IsSpawned == nil or GetConVar("veo_spawnedrags"):GetBool()) and ent:IsOnFire() then
			local dmg
			if vFireInstalled then
				dmg = #vFireGetFires(ent) / 2
			else
				dmg = 5 
			end

			local lastColor = ent:GetColor()
			if lastColor.r > 25 then
				ent:SetColor(Color(lastColor.r - dmg,lastColor.g - dmg,lastColor.b - dmg))
			else
				ent:RemoveAllDecals()
				ent:SetColor(Color(25,25,25))
			end
		end
	end
end)
timer.Start("veo_burneffect")


-- Technical stuff
hook.Add("PostEntityTakeDamage","veo_dmg",function(e,dmg,t)
	if not t or not GetConVar("veo_enabled"):GetBool() then return end
	hitEffect(e,dmg)
end)

-- function StartHit(ent,_,dmginfo)
-- 	if dmginfo == nil then
-- 		dmginfo = DamageInfo()
-- 	end
-- 	if not IsValid(dmginfo:GetDamagePosition()) then
-- 		dmginfo:SetDamagePosition(ent:GetPos() + Vector(0,0,50))
-- 	end
-- 	if ent:IsRagdoll() or ent:IsNPC() or ent:IsPlayer() then
-- 		hitEffect(ent,dmginfo)
-- 	end
-- 	--dmginfo:ScaleDamage(1)
-- 	--return false
-- end

-- hook.Add("ScaleNPCDamage","veo_dmg1",StartHit)
-- hook.Add("ScalePlayerDamage","veo_dmg2",StartHit)

hook.Add("CreateEntityRagdoll","veo_rag",function(ent,r)
	if not GetConVar("veo_enabled"):GetBool() then return end
	ent.pRag = r
	local dmginfo = ent.LastDamage
	r.BloodCol = ent:GetBloodColor()
	hitEffect(r,dmginfo)

	if ent:IsOnFire() then
		r:Ignite(math.random(8,16))
	end
end)
hook.Add("OnEntityCreated","veo_makerags",function(e)
	if not GetConVar("veo_enabled"):GetBool() then return end
	if e:IsNPC() then
		e.LastDamage = DamageInfo()
		e.LastDamage:SetDamage(0)
	elseif e:IsRagdoll() and e.IsSpawned == nil then
		timer.Simple(0,function()
			if IsValid(e) and e.BloodCol == nil then
				local mat = e:GetMaterialType()
				if mat == MAT_FLESH then
					e.BloodCol = 0
				elseif mat == MAT_ALIENFLESH then
					e.BloodCol = 1
				else
					e.BloodCol = -1
				end
			end
		end)
	end
end)
hook.Add("PlayerSpawnedRagdoll","veo_spawnedrags",function(_,_,e)
	e.IsSpawned = true
	--e.BloodCol = -1
end)

hook.Add("PlayerSpawn","veo_plyspawn",function(p)
	p.LastDamage = DamageInfo()
	p.LastDamage:SetDamage(0)
end)

 -- Physical player ragdolls
hook.Add("PlayerDeath","veo_player",function(p)
	if GetConVar("veo_enabled"):GetBool() and GetConVar("ai_serverragdolls"):GetBool() and GetConVar("veo_plyserverrags"):GetBool() then
		if IsValid(p.pRag) then
			p.pRag:Remove()
		end

		if p.LastDamage == nil then
			p.LastDamage = DamageInfo()
		elseif BitEq(p.LastDamage:GetDamageType(),DMG_DISSOLVE) then
			return
		end

		p.pRag = ents.Create("prop_ragdoll")
		p.pRag:SetPos(p:GetPos())
		p.pRag:SetModel(p:GetModel())
		p.pRag:SetCreator(p)
		p.pRag:Spawn()
		p.pRag.BloodCol = 0

		for id = 1,p.pRag:GetPhysicsObjectCount() do
			local bone = p.pRag:GetPhysicsObjectNum(id - 1)
			if IsValid(bone) then
				local pos,angle = p:GetBonePosition(p.pRag:TranslatePhysBoneToBone(id - 1))
				bone:SetPos(pos)
				bone:SetAngles(angle)
				bone:AddVelocity(p:GetVelocity())
			end
		end

		p.pRag:SetSkin(p:GetSkin())
		p.pRag:SetBodyGroups(p:GetBodyGroups())

		if p.LastDamage:GetDamage() > 0 then
			if p.LastDamage:IsExplosionDamage() then
				p.pRag:GetPhysicsObject():ApplyForceCenter((p.pRag:GetPos() - p.LastDamage:GetReportedPosition()):GetNormalized() * p.LastDamage:GetDamage() * 5000)
			else
				p.pRag:GetPhysicsObject():ApplyForceCenter(p.LastDamage:GetDamageForce())
			end
		end
		
		
		timer.Simple(0,function()
			p:GetRagdollEntity():Remove()
			p.EndHitEffect = true
			net.Start("RagdollMade")
			net.WriteEntity(p.pRag)
			net.Send(p)
			--if p.LastDamage:GetDamage() == 0 then return end
			p.LastDamage:SetDamagePosition(p.pRag:GetPos())
			hitEffect(p.pRag,p.LastDamage)
		end)
	end
end)


elseif CLIENT then ---------------------------------------------------------------------------

CreateClientConVar("veo_decalsize","1",true,false,"Size multiplier for blood stains created by VEO.\nSet to 0 to disable VEO's blood stains (particles will still appear).")
CreateClientConVar("veo_decalmax","1.5",true,false,"The largest size in proportion to a standard decal that a VEO blood stain can reach.")
CreateClientConVar("veo_plyragview","1",true,false,"If enabled, the camera will follow your server ragdoll when you die.")

net.Receive("DecalEx",function()
	if not GetConVar("veo_enabled"):GetBool() then return end
	local t = net.ReadTable()
	if t.entity == NULL or t.decal == NULL then return end
	local decalSize = math.Clamp(GetConVar("veo_decalsize"):GetFloat(),0,GetConVar("veo_decalmax"):GetFloat())
	if decalSize == nil or decalSize == 0 then return end
	if t.width == nil or t.height == nil then return end
	t.width = t.width * decalSize
	t.height = t.height * decalSize
	--pcall(function() util.DecalEx(Material(util.DecalMaterial(t.decal)),t.entity,t.pos,t.normal,Color(255,255,255),t.width,t.height) end)
	util.DecalEx(Material(util.DecalMaterial(t.decal)),t.entity,t.pos,t.normal,Color(255,255,255),t.width,t.height)
end)

hook.Add("CalcView","veo_ragview",function(pl,p,a,f)
	if GetConVar("veo_plyserverrags"):GetBool() and GetConVar("veo_plyragview"):GetBool() and IsValid(ragdoll) and not pl:Alive() then
		return {
		origin = ragdoll:GetPos() - a:Forward() * 100
	}
	end
end)

net.Receive("RagdollMade",function()
	ragdoll = net.ReadEntity()
end)

-- hook.Add("Think","veo_clean",function() -- Water cleaning
-- 	if not GetConVar("veo_enabled"):GetBool() then return end
-- 	for i,v in pairs(ents.GetAll()) do
-- 		if v:WaterLevel() >= 2 then
-- 			v:RemoveAllDecals()
-- 		-- elseif (v:IsPlayer() or v:IsNPC()) and v:Health() == v:GetMaxHealth() then
-- 		-- 	v:RemoveAllDecals()
-- 		end
-- 	end
-- end)

end

--[[
	Changelog whenever/the/hell:
	- Metal ragdolls now spark more when damaged
	- Fixed decals not appearing at all
	- Most (but not all) crashes are fixed
	- Optimization: entities cannot bleed more than 3 times in less than 1/5 of a second

	Known bugs:
	- Entity blood particles are the wrong color after entities of two seperate colors are damaged
]]