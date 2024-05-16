local sounds = {}

function CNMLoadSound(s)
    if SERVER then
        print("Loading sound: "..s)
    end
    sound.Add({
        name = s,
        sound = s
    })
    table.insert(sounds,s)
end

if SERVER then
    util.AddNetworkString("PlaySound")
    util.AddNetworkString("PlayLast")
    util.AddNetworkString("StopLast")

    function StopLast(p)
        if p.LastSound ~= nil then
            p:StopSound(p.LastSound)
        end
    end

    net.Receive("PlaySound",function(_,p)
        local sound = net.ReadString()
        StopLast(p)
        p.LastSound = sound
        p:EmitSound(sound)
    end)
    net.Receive("PlayLast",function(_,p)
        StopLast(p)
        if p.LastSound ~= nil then
            p:EmitSound(p.LastSound)
        else
            p:ChatPrint("You haven't played any sounds yet!")
        end
    end)
    net.Receive("StopLast",function(_,p)
        StopLast(p)
    end)

elseif CLIENT then
    hook.Add("PopulateToolMenu","cnm_menu",function()
        spawnmenu.AddToolMenuOption("Utilities","Custom Noisemaker","cnm_noisemaker","Noisemaker","","",function(panel)
            local soundMenu = panel:ComboBox("Play Sound","")

            if #sounds == 0 then
                soundMenu:AddChoice("No sounds are installed! Please refer to the Instructional Video.")
            else
                for i,v in pairs(sounds) do
                    soundMenu:AddChoice(v)
                end
                soundMenu.OnSelect = function(index,value,data)
                    net.Start("PlaySound")
                    net.WriteString(soundMenu:GetOptionText(value))
                    net.SendToServer()
                end
            end
            
            local lastButton = panel:Button("Play Previous Sound","","")
            lastButton.DoClick = function()
                net.Start("PlayLast")
                net.SendToServer()
            end
            local stopButton = panel:Button("Stop Current Sound","","")
            stopButton.DoClick = function()
                net.Start("StopLast")
                net.SendToServer()
            end
        end)
    end)
end