local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "💀 GOD MODE V9 | BRING ALL EDITION",
   LoadingTitle = "Đang khởi tạo hệ thống gom mục tiêu...",
   ConfigurationSaving = {Enabled = false}
})

-- BIẾN HỆ THỐNG
local Client = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local BringEnabled = false
local AutoHitEnabled = false
local BringDistance = 7 -- Khoảng cách gom trước mặt

-- TABS
local MainTab = Window:CreateTab("🗡️ Combat God", 4483362458)
local VisualTab = Window:CreateTab("👁️ Visuals", 4483362458)

-- TÍNH NĂNG COMBAT
MainTab:CreateSection("Gom mục tiêu")

MainTab:CreateToggle({
   Name = "Gom Player (Bring All)",
   CurrentValue = false,
   Callback = function(v) 
      BringEnabled = v 
      if v then
         Rayfield:Notify({Title = "Kích hoạt", Content = "Đang hút tất cả Player về phía bạn!", Duration = 3})
      end
   end,
})

MainTab:CreateSlider({
   Name = "Khoảng cách gom",
   Range = {2, 20},
   Increment = 1,
   CurrentValue = 7,
   Callback = function(v) BringDistance = v end,
})

MainTab:CreateSection("Tự động đánh")

MainTab:CreateToggle({
   Name = "Auto Hit (Đánh tập thể)",
   CurrentValue = false,
   Callback = function(v) AutoHitEnabled = v end,
})

-- HỆ THỐNG ESP (Để biết tụi nó đang ở đâu trước khi gom)
local ESPEnabled = false
VisualTab:CreateToggle({
   Name = "Bật ESP Player",
   CurrentValue = false,
   Callback = function(v) ESPEnabled = v end,
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

            -- 1. LOGIC GOM PLAYER (CHỈ HIỆN TRÊN MÁY BẠN)
            if BringEnabled and hum and hum.Health > 0 then
                targetHRP.CFrame = gatherPoint
                targetHRP.Velocity = Vector3.new(0, 0, 0) -- Giữ cho tụi nó không bị văng
            end

            -- 2. LOGIC AUTO HIT (KHI GOM LẠI THÌ ĐÁNH)
            if AutoHitEnabled and hum and hum.Health > 0 then
                local weapon = Client.Character:FindFirstChildOfClass("Tool")
                if weapon then
                    local handle = weapon:FindFirstChild("Handle") or weapon:FindFirstChildOfClass("Part")
                    if handle then
                        firetouchinterest(targetHRP, handle, 0)
                        firetouchinterest(targetHRP, handle, 1)
                    end
                end
            end
            
            -- 3. LOGIC ESP (HIGHLIGHT)
            if ESPEnabled and hum and hum.Health > 0 then
                if not player.Character:FindFirstChild("GeminiHighlight") then
                    local hl = Instance.new("Highlight", player.Character)
                    hl.Name = "GeminiHighlight"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            else
                if player.Character:FindFirstChild("GeminiHighlight") then
                    player.Character.GeminiHighlight:Destroy()
                end
            end
        end
    end
end)

-- THÊM SPEED ĐỂ TIẾP CẬN ĐÁM ĐÔNG NHANH HƠN
local MoveTab = Window:CreateTab("🚀 Movement", 4483362458)
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
        Client.Character.HumanoidRootPart.CFrame = Client.Character.HumanoidRootPart.CFrame + (moveDir * (SpeedVal/80))
    end
end)

Rayfield:Notify({Title = "V9 BRING ALL", Content = "Script đã sẵn sàng để dọn dẹp Server!", Duration = 5})
