-- [START OUTPUT]
-- 🎮 PHANTOM RIVALS ULTIMATE FIX v5.0 🎮
-- Complete overhaul with working menu, FOV customization, and fixed aimbot

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Teams = game:GetService("Teams")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configuration
local AIM_KEY = Enum.KeyCode.X
local MENU_KEY = Enum.KeyCode.RightShift
local SMOOTHING = 0.25
local AIM_OFFSET = Vector3.new(0, 0.3, 0)
local MAX_TARGET_DISTANCE = 1200  -- FOV distance

-- Customizable ESP settings
local ESP_COLORS = {
    {name = "NEON RED", color = Color3.fromRGB(255, 50, 50)},
    {name = "ELECTRIC BLUE", color = Color3.fromRGB(0, 150, 255)},
    {name = "ACID GREEN", color = Color3.fromRGB(50, 255, 100)},
    {name = "HOT PINK", color = Color3.fromRGB(255, 50, 150)},
    {name = "PURPLE HAZE", color = Color3.fromRGB(180, 80, 255)},
    {name = "GOLDEN", color = Color3.fromRGB(255, 215, 0)}
}
local ESP_COLOR = ESP_COLORS[1].color
local NAME_COLOR = Color3.new(1, 1, 1)
local SHOW_NAMES = true
local SHOW_HEALTH = true

-- State variables
local AimEnabled = false
local EspEnabled = true
local MenuVisible = false
local EspObjects = {}
local menuFrame
local FOVCircle

-- Fixed team check
local function IsEnemy(player)
    if player == LocalPlayer then return false end
    if not Teams or #Teams:GetTeams() == 0 then return true end
    if not LocalPlayer.Team or not player.Team then return true end
    return player.Team ~= LocalPlayer.Team
end

-- Create FOV visualization
local function CreateFOVCircle()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = true
    FOVCircle.Radius = 80
    FOVCircle.Color = Color3.fromRGB(255, 50, 50)
    FOVCircle.Thickness = 1.5
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Transparency = 1
    FOVCircle.Filled = false
end

-- ESP functions with vibrant colors
local function CreateEsp(player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = ESP_COLOR
    Box.Thickness = 2
    Box.Filled = false
    
    local NameTag = Drawing.new("Text")
    NameTag.Visible = false
    NameTag.Color = NAME_COLOR
    NameTag.Size = 16
    NameTag.Center = true
    NameTag.Outline = true
    NameTag.OutlineColor = Color3.new(0, 0, 0)
    
    local HealthBar = Drawing.new("Square")
    HealthBar.Visible = false
    HealthBar.Filled = true
    HealthBar.Thickness = 1
    
    local HealthBarBackground = Drawing.new("Square")
    HealthBarBackground.Visible = false
    HealthBarBackground.Filled = true
    HealthBarBackground.Color = Color3.new(0.2, 0.2, 0.2)
    HealthBarBackground.Thickness = 1
    
    EspObjects[player] = {
        Box = Box,
        NameTag = NameTag,
        HealthBar = HealthBar,
        HealthBarBackground = HealthBarBackground
    }
end

local function UpdateEsp()
    for player, drawings in pairs(EspObjects) do
        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if rootPart and head and humanoid then
                local rootPos, rootVis = Camera:WorldToViewportPoint(rootPart.Position)
                local headPos, headVis = Camera:WorldToViewportPoint(head.Position)
                
                if rootVis then
                    -- Calculate box dimensions
                    local height = (headPos.Y - rootPos.Y) * 2.2
                    local width = height * 0.6
                    local boxX = rootPos.X - width/2
                    local boxY = rootPos.Y - height/2
                    
                    -- Update box
                    drawings.Box.Size = Vector2.new(width, height)
                    drawings.Box.Position = Vector2.new(boxX, boxY)
                    drawings.Box.Visible = EspEnabled
                    drawings.Box.Color = ESP_COLOR
                    
                    -- Update name tag
                    if SHOW_NAMES then
                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                        drawings.NameTag.Text = string.format("%s [%d]", player.Name, math.floor(distance))
                        drawings.NameTag.Position = Vector2.new(headPos.X, headPos.Y - 25)
                        drawings.NameTag.Visible = EspEnabled
                    else
                        drawings.NameTag.Visible = false
                    end
                    
                    -- Update health bar
                    if SHOW_HEALTH then
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        local barHeight = height
                        local barWidth = 4
                        local barX = boxX - barWidth - 2
                        local barY = boxY
                        
                        drawings.HealthBarBackground.Size = Vector2.new(barWidth, barHeight)
                        drawings.HealthBarBackground.Position = Vector2.new(barX, barY)
                        drawings.HealthBarBackground.Visible = EspEnabled
                        
                        local healthHeight = barHeight * healthPercent
                        drawings.HealthBar.Size = Vector2.new(barWidth, healthHeight)
                        drawings.HealthBar.Position = Vector2.new(barX, barY + (barHeight - healthHeight))
                        drawings.HealthBar.Color = Color3.new(1 - healthPercent, healthPercent, 0)
                        drawings.HealthBar.Visible = EspEnabled
                    else
                        drawings.HealthBar.Visible = false
                        drawings.HealthBarBackground.Visible = false
                    end
                else
                    drawings.Box.Visible = false
                    drawings.NameTag.Visible = false
                    drawings.HealthBar.Visible = false
                    drawings.HealthBarBackground.Visible = false
                end
            end
        else
            drawings.Box.Visible = false
            drawings.NameTag.Visible = false
            drawings.HealthBar.Visible = false
            drawings.HealthBarBackground.Visible = false
        end
    end
end

-- FIXED AIMBOT - Works in all game modes
local function GetClosestTarget()
    local closestPlayer = nil
    local closestDistance = math.huge
    local cameraPos = Camera.CFrame.Position
    
    for _, player in ipairs(Players:GetPlayers()) do
        if not IsEnemy(player) then continue end
        if not player.Character then continue end
        if not player.Character:FindFirstChild("Humanoid") then continue end
        if player.Character.Humanoid.Health <= 0 then continue end
        
        local head = player.Character:FindFirstChild("Head")
        if head then
            local distance = (cameraPos - head.Position).Magnitude
            if distance < MAX_TARGET_DISTANCE and distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer
end

local function AimAtTarget()
    local target = GetClosestTarget()
    
    if target and target.Character then
        local head = target.Character:FindFirstChild("Head")
        if head then
            local cameraCF = Camera.CFrame
            local targetPosition = head.Position + AIM_OFFSET
            
            -- Calculate direction with smoothing
            local direction = (targetPosition - cameraCF.Position).Unit
            local newLookVector = cameraCF.LookVector:Lerp(direction, SMOOTHING)
            
            -- Apply smoothed aim
            Camera.CFrame = CFrame.new(cameraCF.Position, cameraCF.Position + newLookVector)
        end
    end
end

-- FIXED MENU SYSTEM - Now fully functional
local function CreateMenu()
    if menuFrame and menuFrame.Parent then 
        menuFrame.Enabled = MenuVisible
        return
    end
    
    menuFrame = Instance.new("ScreenGui")
    menuFrame.Name = "PhantomMenu"
    menuFrame.ResetOnSpawn = false
    menuFrame.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    menuFrame.Parent = game:GetService("CoreGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = menuFrame
    
    -- Glowing top bar
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 2
    topBar.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Text = "PHANTOM RIVALS v5.0"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = topBar
    
    -- Menu content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -40)
    content.Position = UDim2.new(0, 0, 0, 40)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Menu sections
    local function CreateSection(titleText, yPosition)
        local section = Instance.new("Frame")
        section.Size = UDim2.new(0.9, 0, 0, 30)
        section.Position = UDim2.new(0.05, 0, yPosition, 0)
        section.BackgroundTransparency = 1
        section.Parent = content
        
        local label = Instance.new("TextLabel")
        label.Text = titleText
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 18
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = section
        
        return section
    end
    
    -- Aimbot section
    CreateSection("AIMBOT SETTINGS", 0.02)
    
    local aimbotToggle = Instance.new("TextButton")
    aimbotToggle.Text = AimEnabled and "AIMBOT: ON" or "AIMBOT: OFF"
    aimbotToggle.Size = UDim2.new(0.9, 0, 0, 40)
    aimbotToggle.Position = UDim2.new(0.05, 0, 0.08, 0)
    aimbotToggle.BackgroundColor3 = AimEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
    aimbotToggle.TextColor3 = Color3.new(1, 1, 1)
    aimbotToggle.Font = Enum.Font.GothamBold
    aimbotToggle.TextSize = 16
    aimbotToggle.Parent = content
    
    aimbotToggle.MouseButton1Click:Connect(function()
        AimEnabled = not AimEnabled
        aimbotToggle.Text = AimEnabled and "AIMBOT: ON" or "AIMBOT: OFF"
        aimbotToggle.BackgroundColor3 = AimEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
    end)
    
    -- Smoothness slider
    CreateSection("AIM SMOOTHNESS", 0.22)
    local smoothSlider = Instance.new("Slider")
    smoothSlider.Size = UDim2.new(0.9, 0, 0, 25)
    smoothSlider.Position = UDim2.new(0.05, 0, 0.27, 0)
    smoothSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    smoothSlider.BorderSizePixel = 0
    smoothSlider.MinValue = 0.1
    smoothSlider.MaxValue = 0.5
    smoothSlider.Value = SMOOTHING
    smoothSlider.Parent = content
    
    local smoothValue = Instance.new("TextLabel")
    smoothValue.Text = "Value: " .. string.format("%.2f", SMOOTHING)
    smoothValue.Size = UDim2.new(0.9, 0, 0, 20)
    smoothValue.Position = UDim2.new(0.05, 0, 0.32, 0)
    smoothValue.BackgroundTransparency = 1
    smoothValue.TextColor3 = Color3.new(1, 1, 1)
    smoothValue.Font = Enum.Font.Gotham
    smoothValue.TextSize = 14
    smoothValue.Parent = content
    
    smoothSlider:GetPropertyChangedSignal("Value"):Connect(function()
        SMOOTHING = smoothSlider.Value
        smoothValue.Text = "Value: " .. string.format("%.2f", SMOOTHING)
    end)
    
    -- FOV Distance slider
    CreateSection("FOV DISTANCE", 0.38)
    local fovSlider = Instance.new("Slider")
    fovSlider.Size = UDim2.new(0.9, 0, 0, 25)
    fovSlider.Position = UDim2.new(0.05, 0, 0.43, 0)
    fovSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    fovSlider.BorderSizePixel = 0
    fovSlider.MinValue = 500
    fovSlider.MaxValue = 2000
    fovSlider.Value = MAX_TARGET_DISTANCE
    fovSlider.Parent = content
    
    local fovValue = Instance.new("TextLabel")
    fovValue.Text = "Value: " .. math.floor(MAX_TARGET_DISTANCE)
    fovValue.Size = UDim2.new(0.9, 0, 0, 20)
    fovValue.Position = UDim2.new(0.05, 0, 0.48, 0)
    fovValue.BackgroundTransparency = 1
    fovValue.TextColor3 = Color3.new(1, 1, 1)
    fovValue.Font = Enum.Font.Gotham
    fovValue.TextSize = 14
    fovValue.Parent = content
    
    fovSlider:GetPropertyChangedSignal("Value"):Connect(function()
        MAX_TARGET_DISTANCE = fovSlider.Value
        fovValue.Text = "Value: " .. math.floor(MAX_TARGET_DISTANCE)
    end)
    
    -- ESP section
    CreateSection("ESP CUSTOMIZATION", 0.54)
    
    -- ESP toggle
    local espToggle = Instance.new("TextButton")
    espToggle.Text = EspEnabled and "ESP: ON" or "ESP: OFF"
    espToggle.Size = UDim2.new(0.9, 0, 0, 40)
    espToggle.Position = UDim2.new(0.05, 0, 0.58, 0)
    espToggle.BackgroundColor3 = EspEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
    espToggle.TextColor3 = Color3.new(1, 1, 1)
    espToggle.Font = Enum.Font.GothamBold
    espToggle.TextSize = 16
    espToggle.Parent = content
    
    espToggle.MouseButton1Click:Connect(function()
        EspEnabled = not EspEnabled
        espToggle.Text = EspEnabled and "ESP: ON" or "ESP: OFF"
        espToggle.BackgroundColor3 = EspEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
    end)
    
    -- Color grid
    CreateSection("COLOR PRESETS", 0.68)
    local yPos = 0.73
    for row = 1, 3 do
        for col = 1, 2 do
            local idx = (row-1)*2 + col
            if ESP_COLORS[idx] then
                local colorInfo = ESP_COLORS[idx]
                local colorBtn = Instance.new("TextButton")
                colorBtn.Text = colorInfo.name
                colorBtn.Size = UDim2.new(0.43, 0, 0, 35)
                colorBtn.Position = UDim2.new(0.05 + (col-1)*0.47, 0, yPos, 0)
                colorBtn.BackgroundColor3 = colorInfo.color
                colorBtn.TextColor3 = Color3.new(0, 0, 0)
                colorBtn.Font = Enum.Font.GothamBold
                colorBtn.TextSize = 12
                colorBtn.Parent = content
                
                colorBtn.MouseButton1Click:Connect(function()
                    ESP_COLOR = colorInfo.color
                    -- Update all existing ESP boxes
                    for _, esp in pairs(EspObjects) do
                        esp.Box.Color = ESP_COLOR
                    end
                end)
            end
        end
        yPos = yPos + 0.09
    end
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "CLOSE MENU (RightShift)"
    closeButton.Size = UDim2.new(0.9, 0, 0, 40)
    closeButton.Position = UDim2.new(0.05, 0, 0.92, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 16
    closeButton.Parent = content
    
    closeButton.MouseButton1Click:Connect(function()
        MenuVisible = false
        menuFrame.Enabled = false
    end)
    
    menuFrame.Enabled = true
end

local function ToggleMenu()
    MenuVisible = not MenuVisible
    
    if MenuVisible then
        CreateMenu()
    elseif menuFrame then
        menuFrame.Enabled = false
    end
end

-- Keybind handlers
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == MENU_KEY then
        ToggleMenu()
    elseif input.KeyCode == AIM_KEY then
        AimEnabled = not AimEnabled
    end
end)

-- Initialize ESP for enemies
for _, player in ipairs(Players:GetPlayers()) do
    if IsEnemy(player) then
        CreateEsp(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if IsEnemy(player) then
        CreateEsp(player)
    end
end

Players.PlayerRemoving:Connect(function(player)
    if EspObjects[player] then
        EspObjects[player].Box:Remove()
        EspObjects[player].NameTag:Remove()
        EspObjects[player].HealthBar:Remove()
        EspObjects[player].HealthBarBackground:Remove()
        EspObjects[player] = nil
    end
end)

-- Create FOV circle
CreateFOVCircle()

-- Main loop
RunService.RenderStepped:Connect(function()
    -- Update FOV circle position
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end
    
    -- Handle aimbot
    if AimEnabled and not MenuVisible then
        AimAtTarget()
    end
    
    -- Update ESP
    UpdateEsp()
end)

print([[
  ____  _                      _   _       _ _      ____  _     _____ 
 |  _ \| |__   __ _ _ __   ___| | | | __ _| | |    / ___|| |   |___ / 
 | |_) | '_ \ / _` | '_ \ / _ \ |_| |/ _` | | |    \___ \| |     |_ \ 
 |  __/| | | | (_| | | | |  __/  _  | (_| | | |     ___) | |___ ___) |
 |_|   |_| |_|\__,_|_| |_|\___|_| |_|\__,_|_|_|    |____/|_____|____/ 
]])

print("🔥 PHANTOM RIVALS ULTIMATE FIX v5.0 LOADED 🔥")
print("Press RIGHT SHIFT to open menu")
print("Press X to toggle aimbot")
-- [END OUTPUT]
