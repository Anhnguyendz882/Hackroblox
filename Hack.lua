local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "💀 DA HOOD V8 | STICKY KEO DINH CHUOT",
   LoadingTitle = "Đang khởi động hệ thống Khóa Chết...",
   ConfigurationSaving = {Enabled = false}
})

-- BIẾN HỆ THỐNG
local Client = game.Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local StickyLock = false
local SilentAim = false
local SpeedValue = 16
local FlyEnabled = false
local ESPEnabled = false
local AutoKill = false
local CurrentTarget = nil

-- HÀM TÌM MỤC TIÊU (ƯU TIÊN THẰNG GẦN CHUỘT NHẤT)
local function GetBestTarget()
    local target = nil
    local maxDist = math.huge
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Client and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if mag < maxDist then
                    target = v
                    maxDist = mag
                end
            end
        end
    end
    return target
end

-- TABS
local CombatTab = Window:CreateTab("🔫 Combat", 4483362458)
local MoveTab = Window:CreateTab("🚀 Movement", 4483362458)
local VisualTab = Window:CreateTab("👁️ Visuals", 4483362458)

-- COMBAT
CombatTab:CreateToggle({
   Name = "Sticky Lock (Khóa cứng Camera)",
   CurrentValue = false,
   Callback = function(v) StickyLock = v end,
})

CombatTab:CreateToggle({
   Name = "Silent Aim (Bắn là nát)",
   CurrentValue = false,
   Callback = function(v) SilentAim = v end,
})

CombatTab:CreateToggle({
   Name = "Auto Kill (Bám đuôi + Kill)",
   CurrentValue = false,
   Callback = function(v) AutoKill = v end,
})

-- MOVEMENT
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

-- VISUALS (ESP NAME + LINE)
VisualTab:CreateToggle({
   Name = "Bật ESP",
   CurrentValue = false,
   Callback = function(v) ESPEnabled = v end,
})

-- VÒNG LẶP XỬ LÝ CHÍNH
RS.RenderStepped:Connect(function()
    CurrentTarget = GetBestTarget()

    -- 1. LOCK ON SIÊU DÍNH
    if StickyLock and CurrentTarget and CurrentTarget.Character then
        local targetPos = CurrentTarget.Character.HumanoidRootPart.Position
        -- Ép Camera nhìn thẳng vào mục tiêu
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
    end

    -- 2. AUTO KILL
    if AutoKill and CurrentTarget and CurrentTarget.Character then
        local hrp = CurrentTarget.Character.HumanoidRootPart
        Client.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 7, 2)
        Client.Character.HumanoidRootPart.CFrame = CFrame.new(Client.Character.HumanoidRootPart.Position, hrp.Position)
    end
    
    -- 3. SPEED & FLY
    if Client.Character and Client.Character:FindFirstChild("HumanoidRootPart") then
        if SpeedValue > 16 then
            Client.Character.HumanoidRootPart.CFrame = Client.Character.HumanoidRootPart.CFrame + (Client.Character.Humanoid.MoveDirection * (SpeedValue/65))
        end
        if FlyEnabled then
            Client.Character.HumanoidRootPart.Velocity = Vector3.new(0, 1.5, 0)
            if UIS:IsKeyDown(Enum.KeyCode.Space) then Client.Character.HumanoidRootPart.Velocity = Vector3.new(0, 60, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then Client.Character.HumanoidRootPart.Velocity = Vector3.new(0, -60, 0) end
        end
    end
end)

-- 4. SILENT AIM (HOOK METATABLE - DÍNH NHƯ KEO)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if SilentAim and method == "FireServer" and self.Name == "MainEvent" then
        if args[1] == "UpdateMousePos" or args[1] == "MOUSE" then
            if CurrentTarget and CurrentTarget.Character then
                -- Prediction 0.145 dành cho Da Hood
                args[2] = CurrentTarget.Character.HumanoidRootPart.Position + (CurrentTarget.Character.HumanoidRootPart.Velocity * 0.145)
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- THÔNG BÁO
Rayfield:Notify({Title = "V8 READY", Content = "Dính như keo dính chuột! Lock-on đã kích hoạt.", Duration = 5})
