local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🎯 DA HOOD V3 | GEMINI ELITE",
   LoadingTitle = "Đang khởi chạy hệ thống Da Hood...",
   ConfigurationSaving = {Enabled = false}
})

-- BIẾN HỆ THỐNG
local Client = game.Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera
local SilentAimEnabled = false
local FOVVisible = false
local FOVRadius = 120
local SpeedValue = 16
local FlyEnabled = false
local ESPLineEnabled = false

-- VÒNG TRÒN FOV
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 1
FOV_Circle.Color = Color3.fromRGB(0, 255, 255)
FOV_Circle.Visible = false

-- HÀM TẠO ESP LINE (TRACERS)
local Tracers = {}
local function CreateTracer(player)
    local line = Drawing.new("Line")
    line.Thickness = 1
    line.Color = Color3.fromRGB(255, 0, 0)
    line.Transparency = 1
    Tracers[player] = line
end

-- TAB CHIẾN ĐẤU
local CombatTab = Window:CreateTab("🔫 Combat", 4483362458)
CombatTab:CreateToggle({
   Name = "Silent Aim (MainEvent)",
   CurrentValue = false,
   Callback = function(Value) SilentAimEnabled = Value end,
})
CombatTab:CreateToggle({
   Name = "Hiện vòng FOV",
   CurrentValue = false,
   Callback = function(Value) 
      FOVVisible = Value 
      FOV_Circle.Visible = Value
   end,
})
CombatTab:CreateSlider({
   Name = "FOV Radius",
   Range = {50, 500},
   Increment = 1,
   CurrentValue = 120,
   Callback = function(Value) 
      FOVRadius = Value
      FOV_Circle.Radius = Value
   end,
})

-- TAB HIỂN THỊ (ESP LINE)
local VisualTab = Window:CreateTab("👁️ Visuals", 4483362458)
VisualTab:CreateToggle({
   Name = "Bật ESP Line (Tracers)",
   CurrentValue = false,
   Callback = function(Value) ESPLineEnabled = Value end,
})

-- TAB DI CHUYỂN (SPEED BYPASS)
local MoveTab = Window:CreateTab("🚀 Movement", 4483362458)
MoveTab:CreateSlider({
   Name = "Speed Bypass (CFrame)",
   Range = {16, 150},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value) SpeedValue = Value end,
})
MoveTab:CreateToggle({
   Name = "Fly (Bay lơ lửng)",
   CurrentValue = false,
   Callback = function(Value) FlyEnabled = Value end,
})

-- LOGIC SILENT AIM
local function GetClosestToMouse()
    local target = nil
    local dist = FOVRadius
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Client and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - game:GetService("UserInputService"):GetMouseLocation()).Magnitude
                if mag < dist then
                    target = v
                    dist = mag
                end
            end
        end
    end
    return target
end

-- HOOK GAME ĐỂ SILENT AIM HOẠT ĐỘNG
local old; old = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if SilentAimEnabled and getnamecallmethod() == "FireServer" and self.Name == "MainEvent" and args[1] == "UpdateMousePos" then
        local t = GetClosestToMouse()
        if t then
            args[2] = t.Character.HumanoidRootPart.Position
            return old(self, unpack(args))
        end
    end
    return old(self, ...)
end)

-- VÒNG LẶP RENDER (ESP LINE & MOVEMENT)
game:GetService("RunService").RenderStepped:Connect(function()
    FOV_Circle.Position = game:GetService("UserInputService"):GetMouseLocation()
    
    -- Xử lý ESP Line
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= Client and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not Tracers[player] then CreateTracer(player) end
            local line = Tracers[player]
            local hrpPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            
            if ESPLineEnabled and onScreen then
                line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                line.To = Vector2.new(hrpPos.X, hrpPos.Y)
                line.Visible = true
            else
                line.Visible = false
            end
        elseif Tracers[player] then
            Tracers[player].Visible = false
        end
    end

    -- Xử lý Speed & Fly
    if Client.Character and Client.Character:FindFirstChild("HumanoidRootPart") then
        if SpeedValue > 16 then
            local moveDir = Client.Character.Humanoid.MoveDirection
            Client.Character.HumanoidRootPart.CFrame = Client.Character.HumanoidRootPart.CFrame + (moveDir * (SpeedValue/70))
        end
        if FlyEnabled then
            Client.Character.HumanoidRootPart.Velocity = Vector3.new(0, 1.8, 0)
        end
    end
end)

Rayfield:Notify({Title = "Gemini VIP V3", Content = "ESP Line & Silent Aim Ready!", Duration = 5})
