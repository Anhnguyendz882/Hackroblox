local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "💀 GOD MODE V11 | INSTANT KILL & REACH",
   LoadingTitle = "Đang phá bỏ giới hạn sát thương...",
   ConfigurationSaving = {Enabled = false}
})

-- BIẾN HỆ THỐNG
local Client = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local BringEnabled = false
local HitboxEnabled = false
local AutoHitEnabled = false
local HitboxSize = 25
local BringDistance = 3 -- Khoảng cách gom cực sát để dính dame 100%

-- TABS
local CombatTab = Window:CreateTab("🗡️ Ultimate Combat", 4483362458)
local MoveTab = Window:CreateTab("🚀 Movement", 4483362458)

-- TÍNH NĂNG CHIẾN ĐẤU
CombatTab:CreateSection("Hệ Thống Gom & Hút")

CombatTab:CreateToggle({
   Name = "Hút Player (Magnet Bring)",
   CurrentValue = false,
   Callback = function(v) BringEnabled = v end,
})

CombatTab:CreateToggle({
   Name = "Hitbox Extender (Khối va chạm)",
   CurrentValue = false,
   Callback = function(v) HitboxEnabled = v end,
})

CombatTab:CreateSlider({
   Name = "Kích thước Hitbox",
   Range = {2, 50},
   Increment = 1,
   CurrentValue = 25,
   Callback = function(v) HitboxSize = v end,
})

CombatTab:CreateSection("Sát Thương Tuyệt Đối")

CombatTab:CreateToggle({
   Name = "Auto Kill Aura (Hủy Diệt)",
   CurrentValue = false,
   Callback = function(v) AutoHitEnabled = v end,
})

-- VÒNG LẶP XỬ LÝ CHÍNH (RENDER STEPPED)
RS.RenderStepped:Connect(function()
    if not Client.Character or not Client.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local myHRP = Client.Character.HumanoidRootPart
    local gatherPoint = myHRP.CFrame * CFrame.new(0, 0, -BringDistance)

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= Client and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = player.Character.HumanoidRootPart
            local hum = player.Character:FindFirstChildOfClass("Humanoid")

            if hum and hum.Health > 0 then
                -- 1. LOGIC GOM PLAYER (Sát nút để Bypass Anti-cheat Distance)
                if BringEnabled then
                    targetHRP.CFrame = gatherPoint
                    targetHRP.Velocity = Vector3.new(0, 0, 0)
                end

                -- 2. LOGIC HITBOX (Phóng to để quẹt nhẹ là trúng)
                if HitboxEnabled then
                    targetHRP.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    targetHRP.Transparency = 0.8
                    targetHRP.Color = Color3.fromRGB(255, 0, 0)
                    targetHRP.CanCollide = false
                else
                    targetHRP.Size = Vector3.new(2, 2, 1)
                    targetHRP.Transparency = 1
                end

                -- 3. LOGIC ATTACK BYPASS (FIX LỖI KHÔNG DÍNH DAME)
                if AutoHitEnabled then
                    local weapon = Client.Character:FindFirstChildOfClass("Tool")
                    if weapon then
                        local handle = weapon:FindFirstChild("Handle") or weapon:FindFirstChildOfClass("Part")
                        if handle then
                            -- Gửi lệnh va chạm liên tục
                            firetouchinterest(targetHRP, handle, 0)
                            firetouchinterest(targetHRP, handle, 1)
                            
                            -- CỰC QUAN TRỌNG: Đưa Handle vũ khí sát vào mục tiêu để dính dame 100%
                            handle.CFrame = targetHRP.CFrame
                        end
                        -- Kích hoạt đòn đánh (Vung kiếm)
                        weapon:Activate()
                    end
                end
            end
        end
    end
end)

-- HỆ THỐNG DI CHUYỂN (SPEED BYPASS)
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

Rayfield:Notify({Title = "V11 READY", Content = "Đã fix lỗi Dame! Khoảng cách gom đã được tối ưu.", Duration = 5})
