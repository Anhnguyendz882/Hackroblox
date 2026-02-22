local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "💀 DA HOOD V7 | LOCK ON EDITION",
   LoadingTitle = "Đang tối ưu hóa hệ thống khóa...",
   ConfigurationSaving = {Enabled = false}
})

-- BIẾN HỆ THỐNG
local Client = game.Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LockOnEnabled = false
local SilentAimEnabled = false
local SpeedValue = 16
local FlyEnabled = false
local ESPEnabled = false
local AutoKillEnabled = false
local TargetPlayer = nil

-- HÀM TẠO ESP (LINE + NAME)
local ESP_Objects = {}
local function CreateESP(player)
    local line = Drawing.new("Line")
    line.Thickness = 1
    line.Color = Color3.fromRGB(255, 255, 255)
    
    local name = Drawing.new("Text")
    name.Size = 16
    name.Center = true
    name.Outline = true
    name.Color = Color3.fromRGB(255, 255, 255)

    ESP_Objects[player] = {Line = line, Name = name}
end

-- TABS
local CombatTab = Window:CreateTab("🔫 Combat", 4483362458)
local MoveTab = Window:CreateTab("🚀 Movement", 4483362458)
local VisualTab = Window:CreateTab("👁️ Visuals", 4483362458)

-- COMBAT FEATURES
CombatTab:CreateToggle({
   Name = "Lock On (Khóa Camera)",
   CurrentValue = false,
   Callback = function(v) LockOnEnabled = v end,
})

CombatTab:CreateToggle({
   Name = "Silent Aim (Bắn dính)",
   CurrentValue = false,
   Callback = function(v) SilentAimEnabled = v end,
})

CombatTab:CreateToggle({
   Name = "Auto Kill (Dính như keo)",
   CurrentValue = false,
   Callback = function(v) AutoKillEnabled = v end,
})

-- MOVEMENT FEATURES
MoveTab:CreateSlider({
   Name = "Speed Bypass",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) SpeedValue = v end,
})

MoveTab:CreateToggle({
   Name = "Fly Pro",
   CurrentValue = false,
   Callback = function(v) FlyEnabled = v end,
})

-- VISUAL FEATURES
VisualTab:CreateToggle({
   Name = "Bật ESP Line + Name",
   CurrentValue = false,
   Callback = function(v) ESPEnabled = v end,
})

-- HÀM TÌM NGƯỜI CHƠI GẦN CHUỘT NHẤT
local function GetClosestPlayer()
    local target = nil
    local shortestDistance = math.huge
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Client and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if magnitude < shortestDistance then
                    target = v
                    shortestDistance = magnitude
                end
            end
        end
    end
    return target
end

-- VÒNG LẶP XỬ LÝ CHÍNH
RunService.RenderStepped:Connect(function()
    TargetPlayer = GetClosestPlayer()

    -- 1. LOCK ON LOGIC (Khóa Camera vào đối thủ)
    if LockOnEnabled and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local lookPos = TargetPlayer.Character.HumanoidRootPart.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, lookPos)
    end

    -- 2. AUTO KILL LOGIC
    if AutoKillEnabled and TargetPlayer and TargetPlayer.Character then
        local targetHRP = TargetPlayer.Character.HumanoidRootPart
        Client.Character.HumanoidRootPart.CFrame = targetHRP.CFrame * CFrame.new(0, 6, 2)
        Client.Character.HumanoidRootPart.CFrame = CFrame.new(Client.Character.HumanoidRootPart.Position, targetHRP.Position)
    end

    -- 3. ESP LOGIC
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Client and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if not ESP_Objects[p] then CreateESP(p) end
            local obj = ESP_Objects[p]
            local hrpPos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if ESPEnabled and onScreen then
                obj.Line.Visible, obj.Name.Visible = true, true
                obj.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                obj.Line.To = Vector2.new(hrpPos.X, hrpPos.Y)
                obj.Name.Position = Vector2.new(hrpPos.X, hrpPos.Y - 35)
                obj.Name.Text = p.DisplayName .. " | HP: " .. math.floor(p.Character.Humanoid.Health)
            else
                obj.Line.Visible, obj.Name.Visible = false, false
            end
        elseif ESP_Objects[p] then
            ESP_Objects[p].Line.Visible = false
            ESP_Objects[p].Name.Visible = false
        end
    end

    -- 4. FLY & SPEED LOGIC
    if Client.Character and Client.Character:FindFirstChild("HumanoidRootPart") then
        if FlyEnabled then
            Client.Character.HumanoidRootPart.Velocity = Vector3.new(0, 1.2, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
                Client.Character.HumanoidRootPart.Velocity = Vector3.new(0, 60, 0) 
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then 
                Client.Character.HumanoidRootPart.Velocity = Vector3.new(0, -60, 0) 
            end
        end
        if SpeedValue > 16 then
            Client.Character.HumanoidRootPart.CFrame = Client.Character.HumanoidRootPart.CFrame + (Client.Character.Humanoid.MoveDirection * (SpeedValue/60))
        end
    end
end)

-- SILENT AIM HOOK (Prediction chuẩn hơn)
local old; old = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if SilentAimEnabled and getnamecallmethod() == "FireServer" and self.Name == "MainEvent" and args[1] == "UpdateMousePos" then
        local t = GetClosestPlayer()
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then 
            -- Tự động tính toán vị trí bắn dựa trên vận tốc chạy (Bypass Silent Aim Da Hood)
            args[2] = t.Character.HumanoidRootPart.Position + (t.Character.HumanoidRootPart.Velocity * 0.158)
            return old(self, unpack(args)) 
        end
    end
    return old(self, ...)
end)

Rayfield:Notify({Title = "V7 LOCK ON", Content = "Khóa mục tiêu đã bật. Bắn là phải dính!", Duration = 5})
