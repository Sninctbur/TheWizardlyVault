if CLIENT then

CreateClientConVar("topdown_enabled","1",true,false,"If enabled, you will see and control your character from above.")

function util.IsInWorld( pos )
    local tr = { collisiongroup = COLLISION_GROUP_WORLD, output = {} }
	tr.start = pos
	tr.endpos = pos

	return not util.TraceLine( tr ).HitWorld
end -- Thanks Facepunch for not actually including this in the API

local camHeight = 700
local camAng = 90
local sensitivity = .5

hook.Add("CalcView","gtw_topdown_cam",function(ply,pos,ang,fov)
    if !GetConVar("topdown_enabled"):GetBool() then return end
    local maxTr = util.QuickTrace(pos,Vector(0,0,camHeight),ply)

    local origin
    local camPos = pos + Vector(0,0,camHeight)
    if util.IsInWorld(camPos) and maxTr.Hit then
        origin = maxTr.HitPos
    else
        origin = camPos
    end

    return {
        drawviewer = true,
        origin = origin,
        angles = Angle(camAng,0,0),
        fov = fov,
    }
end)

local cursor = nil

local function setupCursor()
    cursor = {
        x = ScrW() / 2,
        y = ScrH() / 2,
    }
end

local color_red = Color(255,0,0,255)


hook.Add("HUDPaint","gtw_topDownDrawCrosshair",function()
    if !GetConVar("topdown_enabled"):GetBool() then return end
    if cursor then
        surface.SetDrawColor(255,255,255,255)
        surface.DrawRect(cursor.x,cursor.y - 20,2,40)
        surface.DrawRect(cursor.x - 20,cursor.y,40,2)
    end
end)

hook.Add("CreateMove","gtw_topDownCursorFunc",function(cmd)
    if !GetConVar("topdown_enabled"):GetBool() then return end
    if !cursor then setupCursor() end

    cursor.x = math.Clamp(cursor.x + cmd:GetMouseX() * sensitivity,0,ScrW())
    cursor.y = math.Clamp(cursor.y + cmd:GetMouseY() * sensitivity,0,ScrH())
    local vec = gui.ScreenToVector(cursor.x,cursor.y) + Vector(0,0,.7)

    -- print(vec)

    debugoverlay.Line(LocalPlayer():EyePos(),LocalPlayer():EyePos() + vec * 128,.001,color_red)
    debugoverlay.Cross(LocalPlayer():GetEyeTrace().HitPos,15,.001,color_red)
    cmd:SetViewAngles(vec:Angle())
end)

-- -- Scrapped panel-based control solution
-- local PANEL = {}

-- function PANEL:Init()
--     self:SetWorldClicker(true)
--     self:Dock(FILL)
--     self:MakePopup()
--     self:SetKeyboardInputEnabled(false)
--     self:SetCursor("crosshair")
-- end

-- function PANEL:Think()
--     local x,y = input.GetCursorPos()
--     local localX,localY = self:ScreenToLocal(x,y)

--     local zTrace = util.TraceLine({
--         start = self:ScreenToLocal(ScrH() / 2,ScrW() / 2),
--         endpos = Vector(localX,localY,-9999),
--         filter = nil
--     })

--     local screenToLocalPos = (Vector(localY - ScrH() / 2,localX - ScrW() / 2,zTrace.HitPos.z))
--     LocalPlayer():SetEyeAngles((screenToLocalPos * Vector(-1,-1,1)):Angle())

--     debugoverlay.Line(LocalPlayer():GetPos(),LocalPlayer():GetPos() - screenToLocalPos,0.001)
--     debugoverlay.Cross(LocalPlayer():GetPos() - screenToLocalPos,10,.001)
--     debugoverlay.Cross(LocalPlayer():GetEyeTraceNoCursor().HitPos,20,.001)
-- end

-- vgui.Register("gtw_topdown_freecursor",PANEL)

-- function gtw_topDownFreeCursor()
--     if IsValid(gtw_topDownPanel) then
--         gtw_topDownPanel:Remove()
--         gtw_topDownPanel = nil
--     end
--     gtw_topDownPanel = vgui.Create("gtw_topdown_freecursor")
-- end

--hook.Add("PostGamemodeLoaded","gtw_topdown_freecursor",gtw_topDownFreeCursor)
end


function gtw_topDownSetupMove(ply,mv)
    if !GetConVar("topdown_enabled"):GetBool() then return end
    mv:SetMoveAngles(Angle(0,0,0))
end

if SERVER then
    hook.Add("SetupMove","gtw_topdown_move",gtw_topDownSetupMove)
    -- hook.Add("PlayerInitialSpawn","gtw_topdown_hidecrosshair",function(ply)
    --     ply:CrosshairDisable()
    -- end)
end

-- Hello from the past -GaussTheWizard