
AddCSLuaFile()

if SERVER then

util.AddNetworkString("SendSoundData")
print("Enhanced Soundscape loaded!")
hook.Add("EntityEmitSound","servertoclient",function(sound)
	if sound.Ambient == true or sound.Channel == 6 or sound.Channel == 3 or string.find(sound.SoundName,"loop") ~= nil then return nil end
	for i,v in pairs(player.GetAll()) do
		net.Start("SendSoundData")
		net.WriteTable(sound)
		net.Send(v)
	end
	return false
end)

elseif CLIENT then

net.Receive("SendSoundData",function(len,p)
	local sound = net.ReadTable()

	for i,v in pairs(sound) do
		print(i..": "..tostring(v))
	end
	print()
	
	if IsValid(sound.Entity) then
		sound.Entity:EmitSound(sound.SoundName,sound.SoundLevel,sound.Pitch,sound.Volume,sound.Channel)
	elseif IsValid(sound.Pos) then
		EmitSound(sound.SoundName,sound.Pos,0,sound.Channel,sound.Volume,sound.SoundLevel,sound.Flags,sound.Pitch)
	else
		EmitSound(sound.SoundName,Vector(0,0,0),0,sound.Channel,sound.Volume,sound.SoundLevel,sound.Flags,sound.Pitch)
	end
end)


hook.Add("EntityEmitSound","soundscape",function(sound)
	local playerPos = LocalPlayer():GetPos()
	
	local trace = util.TraceLine({
		start = playerPos,
		endpos = sound.Pos,
		filter = ents.GetAll()
	})
	if trace == nil then return end
	-- if trace.Hit and (sound.Pos ~= nil and playerPos:Distance(sound.Pos) >= (sound.SoundLevel * sound.Volume) * 20) then
	-- 	sound.DSP = 30
	-- 	LocalPlayer():ChatPrint(30)
	-- 	return true
	-- end


	local traceinfo = {
		start = playerPos
	}
	local pos
	if sound.Pos == nil then
		pos = playerPos
	else
		pos = sound.Pos
	end

	traceinfo.endpos = pos + Vector(99999999,0,0)
	local trace1 = util.TraceLine(traceinfo) --positive x
	local roomLenX = pos:Distance(trace1.HitPos)
	traceinfo.endpos = pos + Vector(-99999999,0,0) --negative x
	local trace2 = util.TraceLine(traceinfo)
	roomLenX = roomLenX + pos:Distance(trace2.HitPos)
	traceinfo.endpos = pos + Vector(0,99999999,0) --positive z
	local trace3 = util.TraceLine(traceinfo)
	local roomLenY = pos:Distance(trace3.HitPos)
	traceinfo.endpos = pos + Vector(0,-99999999,0) --negative z
	local trace4 = util.TraceLine(traceinfo)
	roomLenY = roomLenY + pos:Distance(trace4.HitPos)

	local roomArea = roomLenX * roomLenY

	local mat = (trace1.MatType + trace2.MatType + trace3.MatType + trace4.MatType) / 4

	if mat == MAT_CONCRETE then
		sound.DSP = 17
	elseif mat == MAT_METAL or mat == MAT_VENT then
		sound.DSP = 2
	end
	if roomArea > 10000000 then
		sound.Volume = sound.Volume * .8
		if sound.DSP == 0 then
			sound.DSP = 20
		end
	-- elseif roomArea < 100000 and sound.DSP == 0 then
	-- 	sound.DSP = 11
	end

	if sound.DSP ~= 0 then
		sound.DSP = sound.DSP + math.min(2,math.floor(roomArea / 10000000))
	end
	return true
end)
end
-- Code by Sninctbur