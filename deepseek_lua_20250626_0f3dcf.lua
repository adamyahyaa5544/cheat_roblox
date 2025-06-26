-- [START OUTPUT]
-- 🔥 PHANTOM RIVALS ULTIMATE v3.0 🔥
-- The definitive ESP + Aimbot + Menu solution for Roblox Rivals

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Configuration
local AIM_KEY = Enum.KeyCode.X
local MENU_KEY = Enum.KeyCode.RightShift
local MAX_DISTANCE = 1200
local SMOOTHING = 0.28
local FOV_CIRCLE_RADIUS = 130
local AIM_OFFSET = Vector3.new(0, 0.3, 0)  -- Headshot adjustment

-- State variables
local AimEnabled = false
local EspEnabled = true
local MenuVisible = false
local Target
local EspObjects = {}
local menuFrame
local FovCircle

-- Create FOV visualization
local function CreateFovCircle()
    FovCircle = Drawing.new("Circle")
    FovCircle.Visible = true
    FovCircle.Radius = FOV_CIRCLE_RADIUS
    FovCircle.Color = Color3.fromRGB(255, 50, 50)
    FovCircle.Thickness = 1.5
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FovCircle.Transparency = 1
    FovCircle.Filled = false
end

-- ESP functions
local function CreateEsp(player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.new(1, 0.15, 0.15)
    Box.Thickness = 1.8
    Box.Filled = false
    
    local NameTag = Drawing.new("Text")
    NameTag.Visible = false
    NameTag.Color = Color3.new(1, 1, 1)
    NameTag.Size = 16
    NameTag.Center = true
    NameTag.Outline = true
    NameTag.OutlineColor = Color3.new(0, 0, 0)
    
    local HealthBar = Drawing.new("Square")
    HealthBar.Visible = false
    HealthBar.Filled = true
    HealthBar.Thickness = 1
    
    EspObjects[player] = {
        Box = Box,
        NameTag = NameTag,
        HealthBar = HealthBar
    }
end

local function UpdateEsp()
    for player, drawings in pairs(EspObjects) do
        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local head = player.Character:FindFirstChild("Head")
            
            if rootPart and head then
                local rootPos, rootVis = Camera:WorldToViewportPoint(rootPart.Position)
                local headPos, headVis = Camera:WorldToViewportPoint(head.Position)
                
                if rootVis then
                    -- Calculate box dimensions
                    local height = (headPos.Y - rootPos.Y) * 2.2
                    local width = height * 0.6
                    
                    -- Update box
                    drawings.Box.Size = Vector2.new(width, height)
                    drawings.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
                    drawings.Box.Visible = EspEnabled
                    
                    -- Update name tag
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                    drawings.NameTag.Text = string.format("%s [%d]", player.Name, math.floor(distance))
                    drawings.NameTag.Position = Vector2.new(headPos.X, headPos.Y - 25)
                    drawings.NameTag.Visible = EspEnabled
                    
                    -- Update health bar
                    local healthPercent = player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth
                    local barHeight = height * healthPercent
                    drawings.HealthBar.Size = Vector2.new(3, barHeight)
                    drawings.HealthBar.Position = Vector2.new(rootPos.X - width/2 - 6, rootPos.Y - height/2 + (height - barHeight))
                    drawings.HealthBar.Color = Color3.new(1 - healthPercent, healthPercent, 0)
                    drawings.HealthBar.Visible = EspEnabled
                else
                    drawings.Box.Visible = false
                    drawings.NameTag.Visible = false
                    drawings.HealthBar.Visible = false
                end
            end
        else
            drawings.Box.Visible = false
            drawings.NameTag.Visible = false
            drawings.HealthBar.Visible = false
        end
    end
end

-- Aimbot functions
local function GetClosestTarget()
    local closestPlayer = nil
    local closestDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        -- Skip invalid targets
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        if not player.Character:FindFirstChild("Humanoid") then continue end
        if player.Character.Humanoid.Health <= 0 then continue end
        
        -- Check for team (skip teammates)
        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            continue
        end
        
        local head = player.Character:FindFirstChild("Head")
        if head then
            local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local screenPos = Vector2.new(headPos.X, headPos.Y)
                local distance = (screenCenter - screenPos).Magnitude
                
                if distance < FOV_CIRCLE_RADIUS and distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

local function AimAtTarget()
    Target = GetClosestTarget()
    
    if Target and Target.Character then
        local head = Target.Character:FindFirstChild("Head")
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

-- Menu System
local function CreateMenu()
    if menuFrame then 
        menuFrame.Enabled = MenuVisible
        return menuFrame
    end
    
    menuFrame = Instance.new("ScreenGui")
    menuFrame.Name = "PhantomMenu"
    menuFrame.ResetOnSpawn = false
    menuFrame.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    menuFrame.Parent = game:GetService("CoreGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = menuFrame
    
    -- Gradient top bar
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 35)
    topBar.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 2
    topBar.Parent = mainFrame
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 0))
    })
    gradient.Rotation = 90
    gradient.Parent = topBar
    
    local title = Instance.new("TextLabel")
    title.Text = "PHANTOM RIVALS v3.0"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = topBar
    
    -- Menu content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -35)
    content.Position = UDim2.new(0, 0, 0, 35)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Aimbot toggle
    local aimbotFrame = CreateToggle("Aimbot", "X", AimEnabled, UDim2.new(0.05, 0, 0.05, 0), content)
    aimbotFrame.Button.MouseButton1Click:Connect(function()
        AimEnabled = not AimEnabled
        UpdateToggle(aimbotFrame, AimEnabled)
    end)
    
    -- ESP toggle
    local espFrame = CreateToggle("ESP", "Always On", EspEnabled, UDim2.new(0.05, 0, 0.25, 0), content)
    espFrame.Button.MouseButton1Click:Connect(function()
        EspEnabled = not EspEnabled
        UpdateToggle(espFrame, EspEnabled)
    end)
    
    -- Smoothing slider
    local sliderFrame = CreateSlider("Smoothness", SMOOTHING, 0.1, 0.5, UDim2.new(0.05, 0, 0.45, 0), content)
    sliderFrame.Slider:GetPropertyChangedSignal("Value"):Connect(function()
        SMOOTHING = sliderFrame.Slider.Value
    end)
    
    -- FOV slider
    local fovFrame = CreateSlider("FOV Radius", FOV_CIRCLE_RADIUS, 50, 200, UDim2.new(0.05, 0, 0.65, 0), content)
    fovFrame.Slider:GetPropertyChangedSignal("Value"):Connect(function()
        FOV_CIRCLE_RADIUS = fovFrame.Slider.Value
        if FovCircle then
            FovCircle.Radius = FOV_CIRCLE_RADIUS
        end
    end)
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "CLOSE (RightShift)"
    closeButton.Size = UDim2.new(0.9, 0, 0.12, 0)
    closeButton.Position = UDim2.new(0.05, 0, 0.85, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.Parent = content
    
    closeButton.MouseButton1Click:Connect(function()
        MenuVisible = false
        menuFrame.Enabled = false
    end)
    
    return menuFrame
end

function CreateToggle(name, hotkey, state, position, parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0.15, 0)
    frame.Position = position
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Text = name .. "  [" .. hotkey .. "]"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Text = state and "ON" or "OFF"
    button.Size = UDim2.new(0.25, 0, 0.8, 0)
    button.Position = UDim2.new(0.75, 0, 0.1, 0)
    button.BackgroundColor3 = state and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 16
    button.Parent = frame
    
    return {
        Frame = frame,
        Label = label,
        Button = button
    }
end

function UpdateToggle(toggleFrame, state)
    toggleFrame.Button.Text = state and "ON" or "OFF"
    toggleFrame.Button.BackgroundColor3 = state and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
end

function CreateSlider(name, value, min, max, position, parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0.15, 0)
    frame.Position = position
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local slider = Instance.new("Slider")
    slider.Size = UDim2.new(1, 0, 0.4, 0)
    slider.Position = UDim2.new(0, 0, 0.6, 0)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    slider.BorderSizePixel = 0
    slider.MinValue = min
    slider.MaxValue = max
    slider.Value = value
    slider.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = string.format("%.2f", value)
    valueLabel.Size = UDim2.new(0.2, 0, 0.5, 0)
    valueLabel.Position = UDim2.new(0.8, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.new(1, 1, 1)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 16
    valueLabel.Parent = frame
    
    slider:GetPropertyChangedSignal("Value"):Connect(function()
        valueLabel.Text = string.format("%.2f", slider.Value)
    end)
    
    return {
        Frame = frame,
        Slider = slider,
        ValueLabel = valueLabel
    }
end

local function ToggleMenu()
    MenuVisible = not MenuVisible
    
    if MenuVisible then
        local menu = CreateMenu()
        menu.Enabled = true
    else
        if menuFrame then
            menuFrame.Enabled = false
        end
    end
end

-- Keybind handlers
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == MENU_KEY then
        ToggleMenu()
    elseif input.KeyCode == AIM_KEY then
        AimEnabled = not AimEnabled
        -- Update menu if visible
        if menuFrame and menuFrame.Enabled then
            for _, child in ipairs(menuFrame:GetDescendants()) do
                if child.Name == "Aimbot" then
                    UpdateToggle(child, AimEnabled)
                    break
                end
            end
        end
    end
end)

-- Initialize ESP
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateEsp(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateEsp(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if EspObjects[player] then
        EspObjects[player].Box:Remove()
        EspObjects[player].NameTag:Remove()
        EspObjects[player].HealthBar:Remove()
        EspObjects[player] = nil
    end
end)

-- Create FOV circle
CreateFovCircle()

-- Main loop
RunService.RenderStepped:Connect(function()
    -- Update FOV circle position
    if FovCircle then
        FovCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
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

print("🔥 PHANTOM RIVALS ULTIMATE v3.0 LOADED 🔥")
print("Press RIGHT SHIFT to toggle menu")
print("Press X to toggle aimbot")
-- [END OUTPUT]
