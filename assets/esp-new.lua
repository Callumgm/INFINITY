--[[------------------------------------------------
|
|    ESP Library Made for 1NF1N17Y (cookiesservices.xyz)
|    
--]]------------------------------------------------

-- Services
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Framework
local Framework = {}; Framework.__index = Framework; do
    function Framework:Round_V2(V2)
        return Vector2.new(math.floor(V2.X + 0.5), math.floor(V2.Y + 0.5))
    end
    function Framework:V3_To_V2(V3)
        return Vector2.new(V3.X, V3.Y)
    end
    function Framework:Draw(Object, Properties)
        Object = Drawing.new(Object)
        for Property, Value in pairs(Properties) do
            Object[Property] = Value
        end
        return Object
    end
    function Framework:Instance(Object, Properties)
        Object = Instance.new(Object)
        for Property, Value in pairs(Properties) do
            Object[Property] = Value
        end
        return Object
    end
    function Framework:Get_Bounding_Vectors(Part)
        local Part_CFrame, Part_Size = Part.CFrame, Part.Size 
        local X, Y, Z = Part_Size.X, Part_Size.Y, Part_Size.Z
        return {
            TBRC = Part_CFrame * CFrame.new(X, Y * 1.3, Z),
            TBLC = Part_CFrame * CFrame.new(-X, Y * 1.3, Z),
            TFRC = Part_CFrame * CFrame.new(X, Y * 1.3, -Z),
            TFLC = Part_CFrame * CFrame.new(-X, Y * 1.3, -Z),
            BBRC = Part_CFrame * CFrame.new(X, -Y * 1.6, Z),
            BBLC = Part_CFrame * CFrame.new(-X, -Y * 1.6, Z),
            BFRC = Part_CFrame * CFrame.new(X, -Y * 1.6, -Z),
            BFLC = Part_CFrame * CFrame.new(-X, -Y * 1.6, -Z),
        };
    end
    function Framework:Drawing_Transparency(Transparency)
        return 1 - Transparency
    end
    function Framework:Distance_Type_Change(Type, Distance)
        if Type == "Studs" then
            return math.floor(Distance + 0.5)
        elseif Type == "Meters" then
            return math.floor((Distance / 3.5714285714 + 0.5))
        end
    end
end

-- Main
local ESP; ESP = {
    Distance_Type = "Studs",

    Objects = {},
    Overrides = {}
}
ESP.__index = ESP

function ESP:GetObject(Object)
    return self.Objects[Object]
end

function ESP:Toggle(State)
    self.Settings.Enabled = State
end

local Object_Metatable = {}
do  -- Object Metatable
    Object_Metatable.__index = Object_Metatable
    function Object_Metatable:Destroy()
        for Index, Component in pairs(self.Components) do
            Component.Visible = false
            Component:Remove()
            self.Components[Index] = nil
        end
        ESP.Objects[self.Object] = nil
    end
    function Object_Metatable:Update()
        local Name = self.Components.Name
        local Addition = self.Components.Addition

        if not ESP.Settings.Objects_Enabled then
            Name.Visible = false
            Addition.Visible = false
            return
        end

        local Vector, On_Screen = Camera:WorldToViewportPoint(self.PrimaryPart.Position + Vector3.new(0, 1, 0))

        local Stud_Distance = (self.PrimaryPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        Stud_Distance = Framework:Distance_Type_Change(ESP.Distance_Type, Stud_Distance)

        if On_Screen and Stud_Distance < ESP.Settings.Object_Maximal_Distance then
            if self.PrimaryPart.Parent ~= nil then
                if self.PrimaryPart.Parent:FindFirstChild("Humanoid") then
                    if self.PrimaryPart.Parent.Humanoid.Health > 0 then
                        local Health = tostring(math.floor((self.PrimaryPart.Parent.Humanoid.Health / self.PrimaryPart.Parent.Humanoid.MaxHealth) * 100 + 0.5))
                        Name.Text = self.Name .. " [" .. math.floor((self.PrimaryPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude + 0.5) .. "m]" .. " [" .. Health .. "%]"
                    else
                        Name.Text = self.Name .. " [" .. math.floor((self.PrimaryPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude + 0.5) .. "m]"
                    end
                else
                    Name.Text = self.Name .. " [" .. math.floor((self.PrimaryPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude + 0.5) .. "m]"
                end
            else
                Name.Text = self.Name .. " [" .. math.floor((self.PrimaryPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude + 0.5) .. "m]"
            end

            Name.Position = Framework:V3_To_V2(Vector)
            Name.Visible = true
            Name.Outline = true

            -- Addition
            if self.Addition.Text ~= "" then
                Addition.Position = Name.Position + Vector2.new(0, Name.TextBounds.Y)
                Addition.Visible = true
            else
                Addition.Visible = false
            end
        else
            Name.Visible = false
            Addition.Visible = false
            return
        end
    end
end
do 
    function ESP:Object(Instance, Data)
        if Data == nil or type(Data) ~= "table" then
            return warn("error: function ESP.Object argument #2 expected table, got nil")
        end
        local Addition = Data.Addition or Data.addition or Data.add or Data.Add or {}
        if Addition.Text == nil then
            Addition.Text = ""
        end
        if Addition.Color == nil then
            Addition.Color = Addition.Color or Addition.color or Addition.col or Addition.Col or Color3.new(1, 1, 1)
        end
        local obj = Data.Object or Data.object or Data.Obj or Data.obj or Instance
        local col = Data.Color or Data.color or Data.col or Data.Col or Color3.new(1, 1, 1)
        local out = Data.outline or Data.Outline or false
        local trans = Data.trans or Data.Trans or Data.Transparency or Data.transparency or Data.Alpha or Data.alpha or 1
        local Object = setmetatable({
            Object = obj,
            PrimaryPart = Data.PrimaryPart or Data.primarypart or Data.pp or Data.PP or Data.primpart or Data.PrimPart or Data.PPart or Data.ppart or Data.pPart or Data.Ppart or obj:IsA("Model") and obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart") or obj:IsA("BasePart") and obj or nil,
            Addition = Addition,
            Components = {},
            Type = Data.Type,
            Name = (Data.Name ~= nil and Data.Name) or Instance.Name
        }, Object_Metatable)
        if Object.PrimaryPart == nil then
            return
        end
        if self:GetObject(Instance) then
            self:GetObject(Instance):Destroy()
        end
        local Components = Object.Components
        Components.Name = Framework:Draw("Text", {Text = Object.Name, Color = col, Font = 2, Size = 13, Outline = out, Center = true, Transparency = trans})
        Components.Addition = Framework:Draw("Text", {Text = Object.Addition.Text, Color = Object.Addition.Color, Font = 2, Size = 13, Outline = out, Center = true, Transparency = trans})
        self.Objects[Instance] = Object
        return Object
    end
end

-- Render Connection
local Connection = RunService.RenderStepped:Connect(function()
    if ESP.Distance_Type == "Studs" then
        ESP.Settings.Object_Maximal_Distance = ESP.Settings.Object_Maximal_Distance_Studs
    
    -- Object Updating
    for i, Object in pairs(ESP.Objects) do
        Object:Update()
    end
end)

return ESP, Connection, Framework


