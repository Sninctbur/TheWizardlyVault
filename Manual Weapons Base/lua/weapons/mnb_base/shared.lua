SWEP.PrintName = "Manual Weapons Base"

-- Technical variables
local ActionState = {
    CLOSED = 0,
    OPEN = 1,
    JAMMED = 2
}

local ReloadStates = {
    EJECT_MAG = 0,
    LOAD_MAG = 1,
    CYCLE = 2
}

local ReloadStateKey = "gtw_mnb_reloadstate"

-- Functional states
SWEP.RoundChambered = true
SWEP.MagIn = true

SWEP.ActionState = ActionState.CLOSED
SWEP.MagCount = 17


-- Weapon attributes
SWEP.Primary.ClipSize = 17
SWEP.Damage = 25
SWEP.Spread = 2

SWEP.BoltCatch = true -- If true, the bolt will be kept open after the last round was fired.
SWEP.OpenBolt = false
SWEP.ManualAction = false
SWEP.TubeFed = false -- Presently unused


-- The meat and potatoes
function SWEP:CycleAction()
    if self.RoundChambered then
        if self:Clip1() <= 0 then
            self.RoundChambered = false
        else
            self:TakePrimaryAmmo(1)
        end
    elseif self:Clip1() > 0 then
        self:TakePrimaryAmmo(1)
        self.RoundChambered = true
    end

    if !self.ManualAction && self.BoltCatch && self.MagIn && self:Clip1() == 0 then
        self.ActionState = ActionState.OPEN
    else
        self.ActionState = ActionState.CLOSED
    end
end

function SWEP:PrimaryAttack()
    if self.Owner:KeyDown(IN_RELOAD) then return end

    if self.RoundChambered then
        self.Owner:FireBullets({
            Damage = self.Damage,
            Src = self.Owner:EyePos(),
            Dir = self.Owner:GetAimVector(),
            Attacker = self.Owner
        })
        self:CycleAction()
    else
        self.Owner:ChatPrint("There is no round chambered!")
    end
end

function SWEP:SecondaryAttack()
    -- Eventually ironsights will go here
end

function SWEP:EjectMagazine(retain)
    if self.MagIn then
        if SERVER and retain then
            self.Owner:GiveAmmo(self:Clip1(), self:GetPrimaryAmmoType())
        end
        self.MagIn = false
        self:SetClip1(0)
    else
        self.Owner:ChatPrint("There is no magazine in!")
    end
end

function SWEP:LoadMagazine(count)
    self.MagIn = true
    self:SetClip1(count)
end

-- Overriding defaults for what we don't need
function SWEP:Reload() end
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"


-- SHARED
local ReloadMenuPanel = nil
local CenterActionTolerance = 30000

local function Distance2DSqr(x1, y1, x2, y2)
    return math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2)
end

function SWEP:Think()
    local owner = self:GetOwner()
    if !(IsValid(owner) && owner:IsPlayer()) then return end

    if SERVER then
        local ReloadState = owner:GetNWInt(ReloadStateKey)

        if ReloadState != -1 then
            owner:ChatPrint("Reload state received: " .. ReloadState)
            if ReloadState == ReloadStates.EJECT_MAG && self.MagIn then
                self:EjectMagazine(true)
            elseif ReloadState == ReloadStates.LOAD_MAG then
                self:LoadMagazine(self:GetMaxClip1())
            elseif ReloadState == ReloadStates.CYCLE then
                self:CycleAction()
            end
            
            owner:SetNWInt(ReloadStateKey, -1)
        end
    end

    if CLIENT then
        local ReloadKeyDown = owner:KeyDown(IN_RELOAD)
        if ReloadKeyDown && !IsValid(ReloadMenuPanel) then
            ReloadMenuPanel = vgui.Create("gtw_mnb_reloadmenu")
        end

        if IsValid(ReloadMenuPanel) and !ReloadKeyDown then
            local mouseX, mouseY = input.GetCursorPos()
            local centerX = ScrW() / 2
            local centerY = ScrH() / 2

            if Distance2DSqr(mouseX, mouseY, centerX, centerY) < CenterActionTolerance then
                LocalPlayer():SetNWInt(ReloadStateKey, 0)
            elseif centerY - mouseY < 0 and math.abs(mouseY - centerY) > math.abs(mouseX - centerX) then
                LocalPlayer():SetNWInt(ReloadStateKey, 1)
            elseif centerY - mouseY > 0 and math.abs(mouseY - centerY) > math.abs(mouseX - centerX) then
                LocalPlayer():SetNWInt(ReloadStateKey, 2)
            end

            LocalPlayer():ChatPrint("Reload state sending: " .. LocalPlayer():GetNWInt(ReloadStateKey))

            ReloadMenuPanel:Remove()
        end

        gui.EnableScreenClicker(ReloadKeyDown)
    end
end


include("cl_reloadmenu.lua")

-- It's been a long time, hasn't it? Long enough for us to change as people. -GaussTheWizard
--[[
    Day 1: Formulating and setup
    Day 2: It shoots!
    Day 3: Found a way to free the mouse cursor, still need to send reload functions to server from client
]]