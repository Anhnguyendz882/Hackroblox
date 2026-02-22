local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "💀 DA HOOD V6 | NO FOV EDITION",
   LoadingTitle = "Đang tối ưu hóa hệ thống...",
   ConfigurationSaving = {Enabled = false}
})

-- BIẾN HỆ THỐNG
local Client = game.Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local SilentAimEnabled = false
local SpeedValue = 16
local FlyEnabled = false
local ESPEnabled = false
local AutoKillEnabled = false

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

-- TÍNH NĂNG CHIẾN ĐẤU
CombatTab:CreateToggle({
   Name = "Silent Aim (Bắn là dính)",
   CurrentValue = false,
   Callback = function(v) SilentAimEnabled = v end,
})

CombatTab:CreateToggle({
   Name = "Auto Kill (Dính như keo)",
   CurrentValue = false,
   Callback = function(v) AutoKillEnabled = v end,
})

-- TÍNH NĂNG DI CHUYỂN
MoveTab:CreateSlider({
   Name = "Speed Bypass",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) SpeedValue = v end,
})

MoveTab:CreateToggle({
   Name = "Fly Pro (Space: Lên | Ctrl: Xuống)",
   CurrentValue = false,
   Callback = function(v) FlyEnabled = v end,
})

-- TÍNH NĂNG HIỂN THỊ
VisualTab:CreateToggle({
   Name = "Bật ESP Line + Name",
   CurrentValue = false,
   Callback = function(v) ESPEnabled = v end,
})

-- HÀM TÌM MỤC TIÊU GẦN CHUỘT NHẤT (Silent Aim)
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
    local Target = GetClosestPlayer()

    -- Logic Auto Kill: Bám đuổi sát nút
    if AutoKillEnabled and Target and Target.Character then
        local targetHRP = Target.Character.HumanoidRootPart
        -- Teleport đứng phía trên đối thủ 5 studs
        Client.Character.HumanoidRootPart.CFrame = targetHRP.CFrame * CFrame.new(0, 5, 2)
        -- Tự động quay mặt về phía đối thủ
        Client.Character.HumanoidRootPart.CFrame = CFrame.new(Client.Character.HumanoidRootPart.Position, targetHRP.Position)
    end

    -- Logic ESP Line (Nối từ dưới màn hình lên cho gọn)
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
                obj.Name.Text = p.DisplayName .. "\nHP: " .. math.floor(p.Character.Humanoid.Health)
            else
                obj.Line.Visible, obj.Name.Visible = false, false
            end
        elseif ESP_Objects[p] then
            ESP_Objects[p].Line.Visible = false
            ESP_Objects[p].Name.Visible = false
        end
    end

    -- Logic Fly & Speed
    if Client.Character and Client.Character:FindFirstChild("HumanoidRootPart") then
        if FlyEnabled then
            local flyVel = Vector3.new(0, 0.9, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then flyVel = Vector3.new(0, 50, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then flyVel = Vector3.new(0, -50, 0) end
            Client.Character.HumanoidRootPart.Velocity = flyVel
        end
        if SpeedValue > 16 then
            Client.Character.HumanoidRootPart.CFrame = Client.Character.HumanoidRootPart.CFrame + (Client.Character.Humanoid.MoveDirection * (SpeedValue/65))
        end
    end
end)

-- SILENT AIM HOOK (Với Prediction - Dự đoán vị trí địch)
local old; old = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if SilentAimEnabled and getnamecallmethod() == "FireServer" and self.Name == "MainEvent" and args[1] == "UpdateMousePos" then
        local t = GetClosestPlayer()
        if t then 
            -- Prediction: Tính toán hướng di chuyển của địch để bắn chặn đầu
            args[2] = t.Character.HumanoidRootPart.Position + (t.Character.HumanoidRootPart.Velocity * 0.165)
            return old(self, unpack(args)) 
        end
    end
    return old(self, ...)
end)

Rayfield:Notify({Title = "DA HOOD V6", Content = "Đã sẵn sàng! Không FOV, Aim siêu mượt.", Duration = 5})
