local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local Mouse = localPlayer:GetMouse()
local Drawing = Drawing

local aimbotEnabled = false
local aiming = false
local menuVisible = false

-- قائمة التحكم
local menuBox = Drawing.new("Square")
menuBox.Size = Vector2.new(220, 100)
menuBox.Position = Vector2.new(10, 10)
menuBox.Filled = true
menuBox.Transparency = 0.7
menuBox.Color = Color3.fromRGB(40, 40, 40)
menuBox.Visible = false
menuBox.ZIndex = 10

local statusText = Drawing.new("Text")
statusText.Position = Vector2.new(20, 25)
statusText.Size = 20
statusText.Color = Color3.fromRGB(255, 255, 255)
statusText.Outline = true
statusText.Text = "Aimbot: OFF"
statusText.Visible = false
statusText.ZIndex = 11

local toggleButton = Drawing.new("Square")
toggleButton.Size = Vector2.new(80, 30)
toggleButton.Position = Vector2.new(20, 60)
toggleButton.Filled = true
toggleButton.Transparency = 0.9
toggleButton.Color = Color3.fromRGB(200, 0, 0)
toggleButton.Visible = false
toggleButton.ZIndex = 11

local toggleText = Drawing.new("Text")
toggleText.Position = Vector2.new(50, 65)
toggleText.Size = 18
toggleText.Color = Color3.fromRGB(255, 255, 255)
toggleText.Outline = true
toggleText.Text = "Toggle"
toggleText.Visible = false
toggleText.ZIndex = 12

local espBoxes = {}

local function updateUI()
    if aimbotEnabled then
        statusText.Text = "Aimbot: ON"
        statusText.Color = Color3.fromRGB(0, 255, 0)
        toggleButton.Color = Color3.fromRGB(0, 150, 0)
    else
        statusText.Text = "Aimbot: OFF"
        statusText.Color = Color3.fromRGB(255, 0, 0)
        toggleButton.Color = Color3.fromRGB(200, 0, 0)
    end
end

updateUI()

local function setMenuVisible(visible)
    menuBox.Visible = visible
    statusText.Visible = visible
    toggleButton.Visible = visible
    toggleText.Visible = visible
    menuVisible = visible
end

-- زر فتح/إغلاق القائمة بالـ Right Shift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setMenuVisible(not menuVisible)
    end
end)

-- زر تفعيل وتعطيل الـ Aimbot داخل القائمة
local Mouse = Players.LocalPlayer:GetMouse()
Mouse.Button1Down:Connect(function()
    if not menuVisible then return end
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local btnPos = toggleButton.Position
    local btnSize = toggleButton.Size

    if mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and
       mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y then
        aimbotEnabled = not aimbotEnabled
        updateUI()
        print("Aimbot toggled: ", aimbotEnabled and "ON" or "OFF")
    end
end)

-- تفعيل التصويب عند ضغط زر الماوس الأيمن
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if aimbotEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

local function getHitbox(part)
    local size = part.Size * Vector3.new(3, 3, 3)
    return CFrame.new(part.Position), size
end

RunService.RenderStepped:Connect(function()
    -- تحديث ESP: نظف أولاً كل الصناديق القديمة
    for _, box in pairs(espBoxes) do
        box.Visible = false
        box:Remove()
    end
    espBoxes = {}

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local rootPart = player.Character.HumanoidRootPart
            local pos, onScreen = camera:WorldToViewportPoint(rootPart.Position)

            if onScreen then
                local size = Vector2.new(60, 80)
                local box = Drawing.new("Square")
                box.Size = size
                box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                box.Color = Color3.fromRGB(255, 0, 0)
                box.Filled = false
                box.Thickness = 2
                box.Visible = true
                box.ZIndex = 100
                table.insert(espBoxes, box)
            end
        end
    end

    -- تصويب aimbot
    if aimbotEnabled and aiming then
        local closestPlayer = nil
        local shortestDistance = math.huge
        local mousePos = UserInputService:GetMouseLocation()

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
                local rootPart = player.Character.HumanoidRootPart
                local pos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestPlayer = player
                    end
                end
            end
        end

        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = closestPlayer.Character.HumanoidRootPart
            local hitboxCFrame, hitboxSize = getHitbox(rootPart)
            camera.CFrame = CFrame.new(camera.CFrame.Position, hitboxCFrame.Position)
        end
    end
end)
