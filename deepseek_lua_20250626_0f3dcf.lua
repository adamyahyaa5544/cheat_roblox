local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local aimbotEnabled = false
local espEnabled = false
local aiming = false
local menuVisible = false

local Drawing = Drawing

-- القائمة الخلفية
local menuBox = Drawing.new("Square")
menuBox.Size = Vector2.new(240, 130)
menuBox.Position = Vector2.new(10, 10)
menuBox.Filled = true
menuBox.Transparency = 0.7
menuBox.Color = Color3.fromRGB(40, 40, 40)
menuBox.Visible = false
menuBox.ZIndex = 10

-- نص عنوان القائمة
local titleText = Drawing.new("Text")
titleText.Position = Vector2.new(20, 15)
titleText.Size = 22
titleText.Color = Color3.fromRGB(255, 255, 255)
titleText.Outline = true
titleText.Text = "Rivals Script Menu"
titleText.Visible = false
titleText.ZIndex = 11

-- زر تفعيل وتعطيل ESP
local espButton = Drawing.new("Square")
espButton.Size = Vector2.new(90, 30)
espButton.Position = Vector2.new(20, 50)
espButton.Filled = true
espButton.Transparency = 0.9
espButton.Color = Color3.fromRGB(200, 0, 0)
espButton.Visible = false
espButton.ZIndex = 11

local espText = Drawing.new("Text")
espText.Position = Vector2.new(55, 55)
espText.Size = 18
espText.Color = Color3.fromRGB(255, 255, 255)
espText.Outline = true
espText.Text = "ESP: OFF"
espText.Visible = false
espText.ZIndex = 12

-- زر تفعيل وتعطيل Aimbot
local aimbotButton = Drawing.new("Square")
aimbotButton.Size = Vector2.new(90, 30)
aimbotButton.Position = Vector2.new(130, 50)
aimbotButton.Filled = true
aimbotButton.Transparency = 0.9
aimbotButton.Color = Color3.fromRGB(200, 0, 0)
aimbotButton.Visible = false
aimbotButton.ZIndex = 11

local aimbotText = Drawing.new("Text")
aimbotText.Position = Vector2.new(170, 55)
aimbotText.Size = 18
aimbotText.Color = Color3.fromRGB(255, 255, 255)
aimbotText.Outline = true
aimbotText.Text = "Aimbot: OFF"
aimbotText.Visible = false
aimbotText.ZIndex = 12

local espBoxes = {}

local function updateUI()
    if espEnabled then
        espText.Text = "ESP: ON"
        espButton.Color = Color3.fromRGB(0, 150, 0)
    else
        espText.Text = "ESP: OFF"
        espButton.Color = Color3.fromRGB(200, 0, 0)
    end

    if aimbotEnabled then
        aimbotText.Text = "Aimbot: ON"
        aimbotButton.Color = Color3.fromRGB(0, 150, 0)
    else
        aimbotText.Text = "Aimbot: OFF"
        aimbotButton.Color = Color3.fromRGB(200, 0, 0)
    end
end

updateUI()

local function setMenuVisible(visible)
    menuBox.Visible = visible
    titleText.Visible = visible
    espButton.Visible = visible
    espText.Visible = visible
    aimbotButton.Visible = visible
    aimbotText.Visible = visible
    menuVisible = visible
end

-- فتح وإغلاق القائمة بالضغط على Right Shift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setMenuVisible(not menuVisible)
    end
end)

-- التعامل مع ضغط الماوس على أزرار القائمة
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and menuVisible then
        local mousePos = UserInputService:GetMouseLocation()

        -- تحقق زر ESP
        local btnPos = espButton.Position
        local btnSize = espButton.Size
        if mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and
           mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y then
            espEnabled = not espEnabled
            updateUI()
            print("ESP toggled:", espEnabled and "ON" or "OFF")
            return
        end

        -- تحقق زر Aimbot
        btnPos = aimbotButton.Position
        btnSize = aimbotButton.Size
        if mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and
           mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y then
            aimbotEnabled = not aimbotEnabled
            updateUI()
            print("Aimbot toggled:", aimbotEnabled and "ON" or "OFF")
            return
        end
    end
end)

-- تفعيل التصويب بالزر الأيمن للماوس فقط لو Aimbot مفعل
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
    -- تنظيف صناديق ESP القديمة
    for _, box in pairs(espBoxes) do
        box.Visible = false
        box:Remove()
    end
    espBoxes = {}

    if espEnabled then
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
    end

    -- التصويب (aimbot)
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
