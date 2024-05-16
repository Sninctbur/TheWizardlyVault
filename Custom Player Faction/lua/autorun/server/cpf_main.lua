testNpcs = {"npc_citizen","npc_stalker","npc_headcrab","npc_antlion"}
vjFacs = {"CLASS_CITIZEN","CLASS_COMBINE","CLASS_ZOMBIE","CLASS_ANTLION"}

function changeFaction(ply,fac,npc) -- usage: player to change faction, faction to change to (1 = citizens, 2 = combine, 3 = zombies, 4 = antlions), NPC to affect relation with
    if fac == nil or fac > #testNpcs + 1 then return end
    hook.Remove("OnEntityCreated","cpf_npcspawn")
    local ent = ents.Create(testNpcs[fac])
    ent:SetNoDraw(true)
    ent:SetPos(ply:GetPos() + Vector(0,0,100))
    ent:Spawn()
    hook.Add("OnEntityCreated","cpf_npcspawn",OnEntityCreated)
    ent:Fire("Kill","",.10001) -- so zombies don't fall from the sky if the code breaks

    if not IsValid(ent) or not IsValid(npc) then return end
    npc:AddEntityRelationship(ply,D_NU,2)
    timer.Simple(.1,function()
        if IsValid(npc) then
            npc:AddEntityRelationship(ply,npc:Disposition(ent),2)
        end
    end)
end

function OnEntityCreated(npc)
    timer.Simple(.1,function()
        if npc:IsNPC() then
            pcall(function()
                for i,ply in pairs(player.GetAll()) do
                    if ply.Faction > 1 then -- NPCs treat players as resistance by default, so if they're already resistance we can save some processing time
                        changeFaction(ply,ply.Faction,npc)
                    end
                end
            end)
        end
    end)
end
hook.Add("OnEntityCreated","cpf_npcspawn",OnEntityCreated)

hook.Add("PlayerInitialSpawn","cpf_plyspawn",function(ply)
    ply.Faction = 1
end)

CreateConVar("cpf_mode","2",{FCVAR_ARCHIVE,FCVAR_NOTIFY},[[Determines which players are allowed to change which groups of NPCs attack them using the entities under the Change Faction category.
0: Faction changing is disabled. Players will remain in the faction they changed to before this value is set.
1: Only server admins can change their faction.
2: Every player can change their faction.
]])
-- Code by Sninctbur

print("Custom Player Faction loaded!")