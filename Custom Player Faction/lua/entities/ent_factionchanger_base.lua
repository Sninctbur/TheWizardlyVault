AddCSLuaFile()
include("autorun/server/cpf_main.lua")

ENT.PrintName = "Faction Changer Base"
ENT.Type = "anim"
ENT.Author = "Sninctbur"
ENT.Category = "Change Faction"
ENT.Spawnable = false
ENT.AdminOnly = false

ENT.Faction = -1

function ENT:SpawnFunction(ply,tr,class)
    local mode = GetConVar("cpf_mode"):GetInt()
    if mode == 0 or (mode == 1 and not ply:IsAdmin()) then
        ply:EmitSound("items/medshotno1.wav")
        ply:PrintMessage(HUD_PRINTCENTER,"You currently don't have permission to do that.")
        return
    elseif ply.Faction == self.Faction then
        ply:EmitSound("items/medshotno1.wav")
    else
        ply:EmitSound("items/suitchargeok1.wav",50,150)
        if self.PrintName == "Neutral" then
            ply:PrintMessage(HUD_PRINTCENTER,"You are now neutral to all NPCs!")
        else
            ply:PrintMessage(HUD_PRINTCENTER,"You are now a member of the "..self.PrintName.."!")
        end
    end
    
    ply.Faction = self.Faction
    for i,npc in pairs(ents.FindByClass("npc_*")) do 
        if npc:IsNPC() then -- need to make sure so the game stays happy
            changeFaction(ply,self.Faction,npc)
        end
    end
end