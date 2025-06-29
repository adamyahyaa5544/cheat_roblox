local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Drawing = Drawing

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local aimbotEnabled = false
local aiming = false

-- واجهة حالة التفعيل (UI) باستخدام Drawing
local statusBox = Drawing.new("Square")
statusBox.Size = Vector2.new(140, 30)
statusBox.Position = Vector2.new(10, 10)
statusBox.Filled = true
statusBox.Transparency = 0.7
statusBox.Color = Color3.fromRGB(30, 30, 30)
statusBox.Visible = true
statusBox.ZIndex = 10

local statusText = Drawing.new("Text")
statusText.Position = Vector2.new(20, 18)
statusText.Size = 18
statusText.Color = Color3.fromRGB(255, 255, 255)
statusText.Center = false
statusText.Outline = true
statusText.Text = "Aimbot: OFF"
statusText.Visible = true
statusText.ZIndex = 11

-- تحديث نص الحالة
local function updateStatusText()
    if aimbotEnabled then
        statusText.Text = "Aimbot: ON"
        statusText.Color = Color3.fromRGB(0, 255, 0)
        statusBox.Color = Color3.fromRGB(20, 50, 20)
    else
        statusText.Text = "Aimbot: OFF"
        statusText.Color = Color3.fromRGB(255, 0, 0)
        statusBox.Color = Color3.fromRGB(50, 20, 20)
    end
end

updateStatusText()

-- إعداد هيب بوكس بسيط (توسيع حجم التصويب على اللاعب)
local function getHitbox(part)
    -- توسيع الـHitbox حوالي 3 أضعاف (يمكن تعديل الرقم حسب الحاجة)
    local size = part.Size * Vector3.new(3, 3, 3)
    return CFrame.new(part.Position), size
end

-- تبديل تفعيل/تعطيل السكربت بالضغط على Right Shift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        aimbotEnabled = not aimbotEnabled
        updateStatusText()
        print("Aimbot toggled: ", aimbotEnabled and "ON" or "OFF")
    end

    if aimbotEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end

    -- ESP (مثال مبسط لطباعة أسماء اللاعبين في الـ Console فقط)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local screenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                -- ممكن تستبدل print برسم أسماء على الشاشة باستخدام Drawing API
                print("ESP: " .. player.Name .. " at " .. tostring(screenPos))
            end
        end
    end

    -- Aimbot - التصويب التلقائي فقط بدون إطلاق
    if aiming then
        local closestPlayer = nil
        local shortestDistance = math.huge
        local mousePos = UserInputService:GetMouseLocation()

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local rootPart = player.Character.HumanoidRootPart
                local screenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestPlayer = player
                    end
                end
            end
        end

        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- استخدم الهيتبكس لتسهيل التصويب
            local rootPart = closestPlayer.Character.HumanoidRootPart
            local hitboxCFrame, hitboxSize = getHitbox(rootPart)

            -- تحريك الكاميرا للتصويب على مركز الهيتبكس
            camera.CFrame = CFrame.new(camera.CFrame.Position, hitboxCFrame.Position)
        end
    end
end)
