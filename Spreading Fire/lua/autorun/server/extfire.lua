local delay = math.random(5,8)

local function ignite(obj)
    if(obj:GetClass() == "prop_physics" and obj.CanBurn == nil and math.random(1,3) == 3) then
        local dur = math.random(10,15)
        obj:Ignite(dur)

        local mat = ""
        if obj:GetPhysicsObject() ~= nil then
            mat = obj:GetPhysicsObject():GetMaterial()
        end
        if mat == "metal" or mat == "solidmetal" or mat == "concrete" then return end

        obj.CanBurn = false
        timer.Simple(dur * .75,function()
            if(IsValid(obj) and obj:IsOnFire()) then
                if math.random(1,2) == 2 then
                    constraint.RemoveAll(obj)
                    obj:GetPhysicsObject():EnableMotion(true)
                else
                    obj.CanBurn = nil
                end
            end
        end)
    end
end

hook.Add("Think","firespread",function()
    if(GetConVar("firespread_enabled"):GetBool() == false) then return end
    if(CurTime() < delay) then return end
    delay = CurTime() + math.random(5,8)

    for i,v in pairs(ents.GetAll()) do
        if(v:IsOnFire()) then
            ignite(v)
            local phys = v:GetPhysicsObject()
            if phys:IsValid() and v:IsValid() then
                for i,w in pairs(ents.FindInSphere(v:GetPos(),v:GetModelRadius() * 1.02)) do
                    ignite(w)
                end
            elseif v:IsValid() then
                for i,w in pairs(ents.FindInSphere(v:GetPos(),10)) do
                    ignite(w)
                end
            end
        end
    end
end)

hook.Add("AllowPlayerPickup","burnholder",function(p,e)
    if(e:IsOnFire()) then
        local dmg = DamageInfo()
        p:Ignite(.2)

        return false
    end
end)

CreateConVar("firespread_enabled","1",{FCVAR_ARCHIVE,FCVAR_NOTIFY},"If enabled, burning props will ignite nearby props.")
CreateConVar("firespread_collapse","1",{FCVAR_ARCHIVE,FCVAR_NOTIFY},"If enabled, most burning props may eventually become unfrozen and break their constraints.")
--Code by Sninctbur