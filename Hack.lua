local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local VirtualInputManager = game:GetService("VirtualInputManager") -- Giả lập chuột trái thật sự

local Window = Rayfield:CreateWindow({
   Name = "💀 GOD MODE V12 | FINAL DAMAGE FIX",
   LoadingTitle = "Đang bẻ khóa hệ thống sát thương...",
   ConfigurationSaving = {Enabled = false}
})

-- BIẾN HỆ THỐNG
local Client = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local BringEnabled = false
local HitboxEnabled = false
local AutoHitEnabled = false
local HitboxSize = 20
local BringDistance = 4 -- Khoảng cách gom sát để dính dame 100%

-- TABS
local CombatTab = Window:CreateTab("🗡️ Hardcore Combat", 4483362458)
local MoveTab = Window:CreateTab("🚀 Movement", 4483362458)

-- TÍNH NĂNG COMBAT
CombatTab:CreateSection("Hệ Thống Hút & Khóa")

CombatTab:CreateToggle({
   Name = "Hút Player (Bring)",
   CurrentValue = false,
   Callback = function(v) BringEnabled = v end,
})

CombatTab:CreateToggle({
   Name = "Phóng To Hitbox",
   CurrentValue = false,
   Callback = function(v) HitboxEnabled = v end,
})

CombatTab:CreateSlider({
   Name = "Size Hitbox",
   Range = {2, 50},
   Increment = 1,
   CurrentValue = 20,
   Callback = function(v) HitboxSize = v end,
})

CombatTab:CreateSection("Sát Thương Tuyệt Đối")

CombatTab:CreateToggle({
   Name = "KILL AURA (FIX DAME)",
   CurrentValue = false,
   Callback = function(v) AutoHitEnabled = v end,
})

-- VÒNG LẶP XỬ LÝ CHÍNH
RS.RenderStepped:Connect(function()
    if not Client.Character or not Client.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local myHRP = Client.Character.HumanoidRootPart
    local gatherPoint = myHRP.CFrame * CFrame.new(0, 0, -BringDistance)

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= Client and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = player.Character.HumanoidRootPart
            local hum = player.Character:FindFirstChildOfClass("Humanoid")

            if hum and hum.Health > 0 then
                -- 1. GOM NGƯỜI SÁT NÚT
                if BringEnabled then
                    targetHRP.CFrame = gatherPoint
                    targetHRP.Velocity = Vector3.new(0, 0, 0)
                end

                -- 2. HITBOX CỰC ĐẠI
                if HitboxEnabled then
                    targetHRP.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    targetHRP.Transparency = 0.8
                    targetHRP.Color = Color3.fromRGB(255, 0, 0)
                    targetHRP.CanCollide = false
                else
                    targetHRP.Size = Vector3.new(2, 2, 1)
                    targetHRP.Transparency = 1
                end

                -- 3. SIÊU CẤP KILL AURA (FIX LỖI KHÔNG BẤM)
                if AutoHitEnabled then
                    local weapon = Client.Character:FindFirstChildOfClass("Tool")
                    if weapon then
                        -- GIẢ LẬP NHẤN CHUỘT THẬT (MouseButton1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)

                        -- ÉP VŨ KHÍ CHẠM VÀO ĐỊCH
                        local handle = weapon:FindFirstChild("Handle") or weapon:FindFirstChildOfClass("Part")
                        if handle then
                            handle.CFrame = targetHRP.CFrame
                            firetouchinterest(targetHRP, handle, 0)
                            firetouchinterest(targetHRP, handle, 1)
                        end
                    end
                end
            end
        end
    end
end)

-- TÍNH NĂNG DI CHUYỂN
local SpeedVal = 16
MoveTab:CreateSlider({
   Name = "Speed Bypass",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) SpeedVal = v end,
})

RS.Heartbeat:Connect(function()
    if Client.Character and Client.Character:FindFirstChild("HumanoidRootPart") and SpeedVal > 16 then
        local moveDir = Client.Character.Humanoid.MoveDirection
        Client.Character.HumanoidRootPart.CFrame = Client.Character.HumanoidRootPart.CFrame + (moveDir * (SpeedVal/90))
    end
end)

Rayfield:Notify({Title = "V12 FINAL READY", Content = "Đã fix lỗi Dame và Tự động đánh! Chúc bạn quẩy vui vẻ.", Duration = 5})
