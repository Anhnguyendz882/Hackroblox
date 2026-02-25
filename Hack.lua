local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "💀 GOD MODE V10 | SUPER HITBOX FIX DAME",
   LoadingTitle = "Đang tối ưu hóa sát thương cực đại...",
   ConfigurationSaving = {Enabled = false}
})

-- BIẾN HỆ THỐNG
local Client = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local BringEnabled = false
local HitboxEnabled = false
local AutoHitEnabled = false
local HitboxSize = 15
local BringDistance = 7

-- TABS
local CombatTab = Window:CreateTab("🗡️ Combat God", 4483362458)
local MoveTab = Window:CreateTab("🚀 Movement", 4483362458)

-- TÍNH NĂNG CHIẾN ĐẤU
CombatTab:CreateSection("Hệ Thống Hitbox & Gom Người")

CombatTab:CreateToggle({
   Name = "Gom Player (Bring All)",
   CurrentValue = false,
   Callback = function(v) BringEnabled = v end,
})

CombatTab:CreateToggle({
   Name = "Bật Super Hitbox (Dính Dame 100%)",
   CurrentValue = false,
   Callback = function(v) HitboxEnabled = v end,
})

CombatTab:CreateSlider({
   Name = "Kích thước Hitbox",
   Range = {2, 30},
   Increment = 1,
   CurrentValue = 15,
   Callback = function(v) HitboxSize = v end,
})

CombatTab:CreateSection("Tự Động Tấn Công")

CombatTab:CreateToggle({
   Name = "Auto Hit (Spam Click)",
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

            -- 1. LOGIC GOM PLAYER (CHỈ HIỆN TRÊN MÁY BẠN)
            if BringEnabled and hum and hum.Health > 0 then
                targetHRP.CFrame = gatherPoint
                targetHRP.Velocity = Vector3.new(0, 0, 0)
            end

            -- 2. LOGIC SUPER HITBOX (GIÚP VŨ KHÍ CHẠM LÀ TÍNH DAME)
            if HitboxEnabled and hum and hum.Health > 0 then
                targetHRP.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                targetHRP.Transparency = 0.8 -- Hiện màu đỏ mờ để dễ nhìn mục tiêu
                targetHRP.Color = Color3.fromRGB(255, 0, 0)
                targetHRP.CanCollide = false
            else
                -- Trả về kích thước mặc định khi tắt
                targetHRP.Size = Vector3.new(2, 2, 1)
                targetHRP.Transparency = 1
            end

            -- 3. LOGIC AUTO HIT (DÀNH CHO CÁC GAME CẬN CHIẾN)
            if AutoHitEnabled and hum and hum.Health > 0 then
                local weapon = Client.Character:FindFirstChildOfClass("Tool")
                if weapon then
                    local handle = weapon:FindFirstChild("Handle") or weapon:FindFirstChildOfClass("Part")
                    if handle then
                        -- Giả lập va chạm thực tế (Touch)
                        firetouchinterest(targetHRP, handle, 0)
                        firetouchinterest(targetHRP, handle, 1)
                    end
                    -- QUAN TRỌNG: Kích hoạt đòn đánh của vũ khí
                    weapon:Activate()
                end
            end
        end
    end
end)

-- HỆ THỐNG DI CHUYỂN (SPEED BYPASS)
local SpeedVal = 16
MoveTab:CreateSlider({
   Name = "Speed Bypass",
   Range = {16, 150},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) SpeedVal = v end,
})

RS.Heartbeat:Connect(function()
    if Client.Character and Client.Character:FindFirstChild("HumanoidRootPart") and SpeedVal > 16 then
        local moveDir = Client.Character.Humanoid.MoveDirection
        Client.Character.HumanoidRootPart.CFrame = Client.Character.HumanoidRootPart.CFrame + (moveDir * (SpeedVal/85))
    end
end)

Rayfield:Notify({Title = "V10 LOADED", Content = "Đã fix lỗi Dame! Hãy bật Hitbox và Gom người để làm trùm.", Duration = 5})
