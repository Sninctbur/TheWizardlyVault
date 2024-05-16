sound.Add({
    name = "cmbi_announcer",
    channel = CHAN_VOICE2,
    volume = 1,
    level = 90,
    pitch = 100,
    sound = {
        "npc/overwatch/cityvoice/f_anticitizenreport_spkr.wav",
        "npc/overwatch/cityvoice/f_anticivil1_5_spkr.wav",
        "npc/overwatch/cityvoice/f_anticivilevidence_3_spkr.wav",
        "npc/overwatch/cityvoice/f_capitalmalcompliance_spkr.wav",
        "npc/overwatch/cityvoice/f_ceaseevasionlevelfive_spkr.wav",
        "npc/overwatch/cityvoice/f_citizenshiprevoked_6_spkr.wav",
        "npc/overwatch/cityvoice/f_evasionbehavior_2_spkr.wav",
        "npc/overwatch/cityvoice/f_sociolevel1_4_spkr.wav",
        "npc/overwatch/cityvoice/f_protectionresponse_1_spkr.wav",
        "npc/overwatch/cityvoice/f_protectionresponse_4_spkr.wav",
        "npc/overwatch/cityvoice/f_protectionresponse_5_spkr.wav",
    }
})

--Credit to Nodegraph Editor (I presume since I in fact got it from ZINV+) for AI node parser
local SIZEOF_INT = 4
local SIZEOF_SHORT = 2
local AINET_VERSION_NUMBER = 37
local function toUShort(b)
	local i = {string.byte(b,1,SIZEOF_SHORT)}
	return i[1] +i[2] *256
end
local function toInt(b)
	local i = {string.byte(b,1,SIZEOF_INT)}
	i = i[1] +i[2] *256 +i[3] *65536 +i[4] *16777216
	if(i > 2147483647) then return i -4294967296 end
	return i
end
local function ReadInt(f) return toInt(f:Read(SIZEOF_INT)) end
local function ReadUShort(f) return toUShort(f:Read(SIZEOF_SHORT)) end

function cmbi_ParseFile()
    local Nodes = {}
	if foundain then
		return
	end

	f = file.Open("maps/graphs/"..game.GetMap()..".ain","rb","GAME")
	if(!f) then
		return
	end

	found_ain = true
	local ainet_ver = ReadInt(f)
	local map_ver = ReadInt(f)
	if(ainet_ver != AINET_VERSION_NUMBER) then
		MsgN("Unknown graph file")
		return
	end

	local numNodes = ReadInt(f)
	if(numNodes < 0) then
		MsgN("Graph file has an unexpected amount of nodes")
		return
	end

	for i = 1,numNodes do
		local v = Vector(f:ReadFloat(),f:ReadFloat(),f:ReadFloat())
		local yaw = f:ReadFloat()
		local flOffsets = {}
		for i = 1,NUM_HULLS do
			flOffsets[i] = f:ReadFloat()
		end
		local nodetype = f:ReadByte()
		local nodeinfo = ReadUShort(f)
		local zone = f:ReadShort()

		if nodetype == 4 then
			continue
		end
		
		local node = {
			pos = v,
			yaw = yaw,
			offset = flOffsets,
			type = nodetype,
			info = nodeinfo,
			zone = zone,
			neighbor = {},
			numneighbors = 0,
			link = {},
			numlinks = 0
		}

		table.insert(Nodes,node)
	end

    return Nodes
end
-- Stolen code ends here


if SERVER then -----------------------------------

util.AddNetworkString("cmbi_invAnnounce")

CreateConVar("cmbi_timer_min",180,FCVAR_ARCHIVE,"The minimum amount of time, in seconds, that can pass before an invasion.")
CreateConVar("cmbi_timer_max",480,FCVAR_ARCHIVE,"The maximum amount of time, in seconds, that can pass before an invasion.")
CreateConVar("cmbi_timer_cooldown",60,FCVAR_ARCHIVE,"Antiquate this later.")
CreateConVar("cmbi_paused",0,FCVAR_ARCHIVE,"If enabled, all invasion events caused by the system timer will be blocked.")

CreateConVar("cmbi_ship_overwatch",1,FCVAR_ARCHIVE,"If enabled, dropships containing Combine Soldier squads can appear in invasions.")
CreateConVar("cmbi_ship_elites",0,FCVAR_ARCHIVE,"If enabled, dropships containing Combine Elite squads can appear in invasions.")
CreateConVar("cmbi_ship_police",0,FCVAR_ARCHIVE,"If enabled, dropships containing Metropolice can appear in invasions.")
CreateConVar("cmbi_ship_striders",0,FCVAR_ARCHIVE,"If enabled, dropships carrying a Strider can appear in invasions.")
CreateConVar("cmbi_ship_apc",0,FCVAR_ARCHIVE,"If enabled, dropships carrying an armored patrol car can appear in invasions.")
CreateConVar("cmbi_ship_gunship",0,FCVAR_ARCHIVE,"If enabled, Combine Gunships can appear in invasions.")


local cmbi_nodes = nil
local cmbi_dropships = {}
local cmbi_badGuys = {}

function getDeployConfig()
    local deployTable = {
        ["npc_overwatch_squad_tier2_dropship"] = GetConVar("cmbi_ship_overwatch"):GetBool(),
        ["npc_elite_overwatch_dropship"] = GetConVar("cmbi_ship_elites"):GetBool(),
        ["npc_civil_protection_tier2_dropship"] = GetConVar("cmbi_ship_police"):GetBool(),
        ["npc_strider_dropship"] = GetConVar("cmbi_ship_striders"):GetBool(),
        ["npc_apc_dropship"] = GetConVar("cmbi_ship_apc"):GetBool(),
        ["npc_combinegunship"] = GetConVar("cmbi_ship_gunship"):GetBool(),
    }
end

function cmbi_throwError(msg)
    print("msg")
    Entity(1):ChatPrint("One or more dropships failed to spawn!")
    Entity(1):ChatPrint("Error: "..msg)
    return
end

function cmbi_startInvasion()
    cmbi_nodes = cmbi_ParseFile()
    if !cmbi_nodes or #cmbi_nodes == 0 then 
        print("Invasion failed: no AI nodes")
        return
    end

    timer.Remove("cmbi_schedule")
    timer.Create("cmbi_cooldown",GetConVar("cmbi_timer_cooldown"):GetInt(),1,function()
        cmbi_startTimer()
    end)
    net.Start("cmbi_invAnnounce")
    net.Broadcast()

    for i,v in pairs(ents.FindByClass("npc_*")) do
        if v:GetClass() == "npc_citizen" then
            v:SetNPCState(NPC_STATE_ALERT)
        end
    end

    local timeToSpawn = 2 -- math.random(5,9)
    timer.Create("cmbi_inv",timeToSpawn,1,function()
        for i = 1,2 do
            timer.Simple(2 * (i - 1),function()
                local pos = nil
                local hitSky = false
                local skyTrace
                local distAboveGround = 4000

                local targetPlayer

                if !GetConVar("ai_ignoreplayers"):GetBool() then
                    targetPlayer = Entity(math.random(1,player.GetCount())) -- Players always take the first indices
                else
                    local npcs = {}
                    for j,v in pairs(ents.GetAll()) do
                        if v:IsNPC() or v:IsNextBot() then
                            table.insert(npcs,v)
                        end
                    end

                    if #npcs > 0 then
                        targetPlayer = npcs[math.random(1,#npcs)]
                    else
                        targetPlayer = Entity(math.random(1,player.GetCount())) -- Fuck it, spawn them around a player anyway
                    end
                end

                local targetPos = util.QuickTrace(targetPlayer:GetPos(),Vector(0,0,-9999999)).HitPos
                local nodesInRange = {}
                local yWeights = {}
                local nodeThreshold = 8000
                local lastPointSpawnedAt = nil

                for j,v in pairs(cmbi_nodes) do
                    if v.pos:DistToSqr(targetPos) <= math.pow(nodeThreshold,2) and (!lastPointSpawnedAt or v.pos:DistToSqr(lastPointSpawnedAt) >= math.pow(200, 2)) then
                        local traceHull = util.TraceHull({
                            start = targetPos + Vector(0,0,distAboveGround),
                            endpos = targetPos + Vector(0,0,distAboveGround),
                            mins = Vector(-423,-183,-22), -- Dropship render box: (-423,-183,-22) to (179,189,217)
                            maxs = Vector(179,189,217),
                        })

                        -- if traceHull.Hit then
                        --     debugoverlay.Box(traceHull.StartPos,Vector(-423,-183,-22),Vector(179,189,217),15,Color(255,0,0))
                        --     debugoverlay.Sphere(v.pos,25,15,Color(255,0,0),true)
                        --     continue
                        -- end
                        table.insert(nodesInRange,v)
                        table.insert(yWeights,{
                            z = math.floor(math.abs((v.pos - targetPos).z)) + math.random(0,30), -- A little RNG spice will keep spawn points unpredictable
                            node = #nodesInRange
                        }) -- this is an unplanned fucking mess but it works (to my knowledge)
                    end
                end
                
                table.sort(yWeights,function(a,b)
                    return a.z < b.z
                end)

                if #nodesInRange == 0 then
                    print("Dropship creation failed: no ai_nodes in range of target")
                    return
                end
                

                for j,v in pairs(yWeights) do
                    node = nodesInRange[v.node]
                    if node then
                        pos = node.pos
                        skyTrace = util.TraceLine({
                            start = pos,
                            endpos = pos + Vector(0,0,99999999),
                        })

                        hitSky = skyTrace.HitSky -- and targetPlayer:VisibleVec(skyTrace.HitPos)
                        if hitSky then
                            debugoverlay.Sphere(pos,25,15,Color(0,0,255),true)
                            table.remove(yWeights,j)
                            break
                        else
                            debugoverlay.Sphere(pos,25,15,Color(255,255,0),true)
                        end
                    else
                        print("Nil node " .. j .. "," .. v)
                    end
                end

                if hitSky then
                    local skyPos
                    if skyTrace.StartPos:DistToSqr(skyTrace.HitPos) > math.pow(distAboveGround,2) then -- distance greater than 1000
                        skyPos = pos + Vector(0,0,distAboveGround)
                    else
                        skyPos = skyTrace.HitPos + Vector(0,0,-320) -- to prevent clipping with the sky
                    end

                    if !util.IsInWorld(pos) then
                        print("Dropship creation failed: spawnpoint outside map")
                        return
                    end

                    local ds = ents.Create("cmbi_dropship_mngr")
                    ds:SetPos(skyPos)
                    ds:SetAngles((targetPlayer:GetPos() - pos):Angle())
                    ds.targetPos = pos
                    ds.targetPlayer = targetPlayer
                    ds:Spawn()
                    ds:Activate()
                    
                    --ent:Fire("AddOutput","OnFinishedDropoff triggerhook:RunPassedCode:print('Hello world!'):0:-1")

                    print("Dropship created successfully")
                    lastPointSpawnedAt = pos

                    -- timer.Simple(180,function()
                    --     if IsValid(ds) then
                    --         ds:Remove()
                    --     end
                    -- end)
                else
                    print("Dropship creation failed: unable to find satisfactory position")
                end
            end)
        end
    end)
    
    timer.Start("cmbi_inv")
end

function cmbi_startTimer(min,max)
    if !min then min = GetConVar("cmbi_timer_min"):GetInt() end
    if !max then max = GetConVar("cmbi_timer_max"):GetInt() end
    assert(min <= max)

    if timer.Exists("cmbi_schedule") then
        timer.Remove("cmbi_schedule")
    end

    timer.Create("cmbi_schedule",math.random(min,max),0,function()
        if !GetConVar("cmbi_paused"):GetBool() then
            cmbi_startInvasion()
            --timer.Remove("cmbi_schedule")
        end
    end)
    timer.Start("cmbi_schedule")
    print("CMBI: Invasion timer initialized")
end


-- hook.Add("EntityRemoved","test",function(ent)
--     if ent:GetClass() == "npc_combine_s" or ent:GetClass() == "npc_metropolice" then
--         local tbl = table.Add(ents.FindByClass("npc_combine_s"),ents.FindByClass("npc_metropolice"))
--         if #tbl == 0 and !timer.Exists("cmbi_schedule") then
--             print("Invasion complete, restarting timer")
--             cmbi_startTimer(GetConVar("cmbi_timer_min"):GetInt(),GetConVar("cmbi_timer_min"):GetInt())
--         end
--     end
-- end)

hook.Add("Initialize","cmbi_init",function()
    cmbi_nodes = cmbi_ParseFile()

    if cmbi_nodes and #cmbi_nodes > 0 then
        cmbi_startTimer(GetConVar("cmbi_timer_min"):GetInt(),GetConVar("cmbi_timer_max"):GetInt())
    elseif #cmbi_nodes == 0 then
        timer.Simple(4,function()
            Entity(1):ChatPrint("There are no AI nodes on this map. Combine Invasions will not occur.")
        end)
    end
end)

hook.Add("PostCleanupMap","cmbi_cleanup",function()
    timer.Stop("cmbi_inv")
end)

concommand.Add("cmbi_force",cmbi_startInvasion,nil,"Immediately begins a Combine invasion, regardless of any unmet conditions.")


elseif CLIENT then -----------------------------------

CreateClientConVar("cmbi_chatmsg",0,true,false,"If enabled, a message will appear in chat when a Combine invasion has begun.")

net.Receive("cmbi_invAnnounce",function()
    EmitSound("cmbi_announcer",Vector(0,0,0),-2,CHAN_VOICE2,1,85,0,100,21)

    if GetConVar("cmbi_chatmsg"):GetBool() then
        chat.AddText(Color(255,255,255),"A synthetic voice blankets the land, threatening you and your colleagues with retribution. ",Color(200,0,0),"An attack is imminent...")
    end
end)

end

-- Hello from the past -GaussTheWizard