if SERVER then return end


local PANEL = {}

function PANEL:Think()
    -- if !LocalPlayer():GetNWBool("MNB_ReloadMenu") then
    --     gui.EnableScreenClicker(false)
    --     self:Remove()
    -- end
end


vgui.Register("gtw_mnb_reloadmenu", PANEL)