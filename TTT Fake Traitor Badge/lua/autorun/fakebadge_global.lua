if SERVER then
    util.AddNetworkString("FakeBadgeFound")
end

CreateConVar("ttt_fakebadge_unlimited",0,FCVAR_ARCHIVE,"If enabled, False Badges have infinite stock. If not, each Traitor can only buy one in a given round.")
CreateConVar("ttt_fakebadge_nodetect",0,FCVAR_ARCHIVE,"While enabled, Detectives cannot identify and call out your exquisitely crafted False Badges.")
CreateConVar("ttt_fakebadge_usetime",3,FCVAR_ARCHIVE,"The time in seconds it takes for a False Badge to be applied.")

hook.Add("TTTCanSearchCorpse","fakebadge_bodyfound",function(ply,rag)
    if GetConVar("ttt_fakebadge_nodetect"):GetBool() then return end
    if ply:GetRole() == ROLE_DETECTIVE and rag.IsFaked == true and rag.was_role == ROLE_TRAITOR then
        rag.IsFaked = nil
        if IsValid(deadply) then
            rag.was_role = deadply:GetRole()
        else
            rag.was_role = ROLE_INNOCENT
        end
        
        net.Start("FakeBadgeFound")
        net.WriteString(ply:Nick())
        net.WriteString(CORPSE.GetPlayerNick(rag,"an unknown Terrorist"))
        net.Broadcast()

        return true
    end
end)

if CLIENT then

hook.Add("HUDPaint","fakebadge_progressbar",function()
end)

net.Receive("FakeBadgeFound",function()
    local detName = net.ReadString()
    local deadName = net.ReadString()
    local baseColor = Color(255,255,255)

    chat.AddText(baseColor,"Detective ",Color(0,0,255),detName,baseColor," found a ",Color(255,0,0),"Fake Traitor Badge",
        baseColor," on the body of "..deadName..". Their identity was forged!")
        -- Detective so-and-so found a False Traitor Badge on the body of what's-his-face. Their identity was faked!
end)

end