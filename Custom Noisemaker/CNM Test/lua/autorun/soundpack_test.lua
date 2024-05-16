include("autorun/cnm.lua")

local sounds = 
{ ------------------------------- ADD SOUND PATHS HERE ---------------------------------------------------
    "vo/streetwar/rubble/ba_tellbreen.wav",
    "night_of_fire.wav"
} ------------------------------- ADD SOUND PATHS HERE ---------------------------------------------------

for i,v in pairs(sounds) do
    CNMLoadSound(v)
end