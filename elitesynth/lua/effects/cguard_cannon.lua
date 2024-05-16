local flashMat = Material("sprites/strider_blackball")
local pinchMat = Material("effects/strider_pinch_dudv")
local beamMat = Material("Effects/blueblacklargebeam")

function EFFECT:Init(effectdata)
	self.ent = effectdata:GetEntity()
	self.hitPos = effectdata:GetOrigin()
	self.startTime = CurTime()
	self.cycle=0
	self.KillTime = CurTime() + 1.35
	self.RefractScale = 0.16
	self.SizeScale = 1
	self.RefractSize = 280
	self.SpriteSize = 55
	self.BeamWidth = 8
end

function EFFECT:Think()
	if !IsValid(self.ent) then return false end
	local attachment = self.ent:GetAttachment(1)
	self:SetPos(attachment.Pos)
	self:SetRenderBoundsWS(self:GetPos(),self.hitPos)

	if CurTime() > self.KillTime then return false end
	return true
end

function EFFECT:Render()
	local MuzzleAng = Angle(0,0,0)
	local RenderPos = self:GetPos()
	self:SetRenderBoundsWS(RenderPos + Vector()*self.RefractSize,self.hitPos - Vector()*self.RefractSize)
	
	local invintrplt = (self.KillTime - CurTime())/1.35
	local intrplt = 1 - invintrplt
	
	render.SetMaterial(beamMat)
	render.DrawBeam(RenderPos,self.hitPos,intrplt*self.BeamWidth,0,0,Color(255, 255, 255, intrplt*100))

	pinchMat:SetFloat("$refractamount", math.sin(0.5*intrplt*math.pi)*self.RefractScale)
	render.SetMaterial(pinchMat)
	render.UpdateRefractTexture()
	render.DrawSprite(RenderPos,self.RefractSize,self.RefractSize,Color(255,255,255,150))
	
	render.SetMaterial(flashMat)
	if intrplt < 0.5 then
	
		local size = 2*self.SpriteSize*intrplt
		render.DrawSprite(RenderPos,size,size,Color(0,0,0,100))
		
	else
	
		local clr = 255*(2*intrplt - 1)
		render.DrawSprite(RenderPos,self.SpriteSize,self.SpriteSize,Color(clr,clr,clr,100))
		
	end


end

-- function EFFECT:Render()
	-- local cycleF= (CurTime()-self.startTime)/1.2

	-- //flash
	-- if cycleF<.5 then
		-- render.DrawSprite(self:GetPos(),cycleF*100,cycleF*100,Color(0,0,0,255))
	-- elseif cycleF<1 then
		-- render.DrawSprite(self:GetPos(),cycleF*100,cycleF*100,Color(cycleF*255,cycleF*255,cycleF*255,255))
	-- else
		-- render.DrawSprite(self:GetPos(),50,50,Color(255,255,255,255))
	-- end

	-- if cycleF<1 then
		-- //pinch
		-- -- pinchMat:SetFloat("$refractamount",cycleF)
		-- local invintrplt = (self.KillTime - CurTime())/1.3
		-- local intrplt = 1 - invintrplt
		-- pinchMat:SetFloat("$refractamount", math.sin(0.5*intrplt*math.pi)*self.RefractScale)
		-- render.SetMaterial(pinchMat)
		-- render.UpdateRefractTexture()
		-- render.DrawSprite(self:GetPos(),cycleF*150,cycleF*150)

		-- //Beam
		-- if cycleF>.5 then
			-- render.SetMaterial(beamMat)
			-- render.DrawBeam(self:GetPos(),self.hitPos,cycleF*2,0,0,Color(255,255,255,(cycleF-.5)*255))
		-- end
	-- elseif cycleF<1.1 then
		-- //fired beam
		-- render.SetMaterial(beamMat)
		-- render.DrawBeam(LerpVector((cycleF-1)*10,self:GetPos(),self.hitPos),self.hitPos,(cycleF-1)*500,0,0)
	-- end
-- end