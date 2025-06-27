-- Roblox Rivals ESP & Aimbot - Optimized and Fixed
-- Press RightShift to toggle menu
-- Fixed aimbot for in-match gameplay

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local ESP_COLOR = Color3.fromRGB(255, 50, 50)
local TEAM_CHECK = true
local AIMBOT_KEY = Enum.UserInputType.MouseButton2
local HEADSHOT_MODE = true
local AIM_SMOOTHNESS = 0.25
local MAX_DISTANCE = 1000
local ESP_ENABLED = true
local AIMBOT_ENABLED = true
local MENU_OPEN = false
local WALL_PENETRATION = true

-- ESP Storage
local ESPBoxes = {}
local ESPHealthBars = {}

-- Simple UI Elements
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "RIVALS CHEAT v1.0"
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(220, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Text = "X"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = TitleBar

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -40)
ContentFrame.Position = UDim2.new(0, 10, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Create toggle buttons
local function createToggle(label, initialState, yPos, callback, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = ContentFrame
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Size = UDim2.new(0.6, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Color3.fromRGB(220, 220, 240)
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 14
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 24)
    toggleButton.Position = UDim2.new(1, -50, 0.5, -12)
    toggleButton.BackgroundColor3 = initialState and color or Color3.fromRGB(80, 80, 100)
    toggleButton.Text = initialState and "ON" or "OFF"
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 14
    toggleButton.Parent = frame
    
    toggleButton.MouseButton1Click:Connect(function()
        local newState = not initialState
        initialState = newState
        toggleButton.Text = newState and "ON" or "OFF"
        toggleButton.BackgroundColor3 = newState and color or Color3.fromRGB(80, 80, 100)
        callback(newState)
    end)
end

-- Create color picker
local function createColorPicker(yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = ContentFrame
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = "ESP Color"
    labelText.Size = UDim2.new(0.4, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Color3.fromRGB(220, 220, 240)
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 14
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame
    
    local colors = {
        {Name = "❤️", Color = Color3.new(1, 0, 0)},
        {Name = "💚", Color = Color3.new(0, 1, 0)},
        {Name = "💙", Color = Color3.new(0, 0.5, 1)},
        {Name = "💛", Color = Color3.new(1, 1, 0)},
        {Name = "💜", Color = Color3.new(0.7, 0, 1)}
    }
    
    for i, colorInfo in ipairs(colors) do
        local colorButton = Instance.new("TextButton")
        colorButton.Text = colorInfo.Name
        colorButton.Size = UDim2.new(0, 30, 0, 30)
        colorButton.Position = UDim2.new(0.4 + (i-1)*0.15, 0, 0, 0)
        colorButton.BackgroundColor3 = colorInfo.Color
        colorButton.TextColor3 = Color3.new(1, 1, 1)
        colorButton.Font = Enum.Font.GothamBold
        colorButton.TextSize = 14
        colorButton.Parent = frame
        
        colorButton.MouseButton1Click:Connect(function()
            ESP_COLOR = colorInfo.Color
        end)
    end
end

-- Initialize UI
createToggle("Aimbot", AIMBOT_ENABLED, 0, function(state)
    AIMBOT_ENABLED = state
end, Color3.fromRGB(220, 100, 100))

createToggle("Headshot", HEADSHOT_MODE, 30, function(state)
    HEADSHOT_MODE = state
end, Color3.fromRGB(100, 180, 220))

createToggle("Team Check", TEAM_CHECK, 60, function(state)
    TEAM_CHECK = state
end, Color3.fromRGB(100, 220, 140))

createToggle("Wall Pen", WALL_PENETRATION, 90, function(state)
    WALL_PENETRATION = state
end, Color3.fromRGB(220, 180, 80))

createToggle("ESP", ESP_ENABLED, 120, function(state)
    ESP_ENABLED = state
end, Color3.fromRGB(100, 220, 140))

createColorPicker(150)

-- Create ESP box with health bar
local function createESP(player)
    if ESPBoxes[player] then return end
    
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = ESP_COLOR
    Box.Thickness = 2
    Box.Filled = false
    
    local HealthBarOutline = Drawing.new("Square")
    HealthBarOutline.Visible = false
    HealthBarOutline.Color = Color3.new(0, 0, 0)
    HealthBarOutline.Thickness = 1
    HealthBarOutline.Filled = true
    
    local HealthBar = Drawing.new("Square")
    HealthBar.Visible = false
    HealthBar.Color = Color3.new(0, 1, 0)
    HealthBar.Thickness = 1
    HealthBar.Filled = true
    
    ESPBoxes[player] = Box
    ESPHealthBars[player] = {Outline = HealthBarOutline, Fill = HealthBar}
end

-- Optimized ESP update
local function updateESP()
    if not ESP_ENABLED or MENU_OPEN then return end
    
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    
    for player, box in pairs(ESPBoxes) do
        local char = player.Character
        if char then
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChild("Humanoid")
            local head = char:FindFirstChild("Head")
            
            if rootPart and humanoid and humanoid.Health > 0 and head then
                -- Distance check
                local distance = (localRoot.Position - rootPart.Position).Magnitude
                if distance > 500 then
                    box.Visible = false
                    ESPHealthBars[player].Outline.Visible = false
                    ESPHealthBars[player].Fill.Visible = false
                    goto continue
                end
                
                local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local headPos = Camera:WorldToViewportPoint(head.Position)
                    local scale = (rootPos - headPos).Magnitude * 2
                    
                    -- Update ESP Box
                    box.Size = Vector2.new(scale, scale * 1.5)
                    box.Position = Vector2.new(rootPos.X - scale/2, rootPos.Y - scale/2)
                    box.Visible = true
                    box.Color = ESP_COLOR
                    
                    -- Update Health Bar
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local barWidth = 4
                    local barHeight = scale * 1.5 * healthPercent
                    local barX = rootPos.X - scale/2 - 8
                    local barY = rootPos.Y + scale/2 * 0.5 - barHeight
                    
                    local healthBar = ESPHealthBars[player]
                    healthBar.Outline.Visible = true
                    healthBar.Outline.Size = Vector2.new(barWidth + 2, scale * 1.5 + 2)
                    healthBar.Outline.Position = Vector2.new(barX - 1, barY - 1)
                    
                    healthBar.Fill.Visible = true
                    healthBar.Fill.Size = Vector2.new(barWidth, barHeight)
                    healthBar.Fill.Position = Vector2.new(barX, barY + (scale * 1.5 - barHeight))
                    
                    -- Health bar color
                    if healthPercent > 0.6 then
                        healthBar.Fill.Color = Color3.new(0, 1, 0)
                    elseif healthPercent > 0.3 then
                        healthBar.Fill.Color = Color3.new(1, 1, 0)
                    else
                        healthBar.Fill.Color = Color3.new(1, 0, 0)
                    end
                else
                    box.Visible = false
                    healthBar.Outline.Visible = false
                    healthBar.Fill.Visible = false
                end
            else
                box.Visible = false
                ESPHealthBars[player].Outline.Visible = false
                ESPHealthBars[player].Fill.Visible = false
            end
        else
            box.Visible = false
            ESPHealthBars[player].Outline.Visible = false
            ESPHealthBars[player].Fill.Visible = false
        end
        
        ::continue::
    end
end

-- Fixed aimbot for in-match gameplay
local function smoothAim(target)
    if not target or not target.Character or MENU_OPEN then return end
    
    local targetPart = HEADSHOT_MODE and target.Character.Head or target.Character.HumanoidRootPart
    if not targetPart then return end
    
    -- Get target position in world space
    local targetPos = targetPart.Position
    
    -- Calculate direction to target
    local cameraPos = Camera.CFrame.Position
    local direction = (targetPos - cameraPos).Unit
    
    -- Create new CFrame looking at target
    local newCFrame = CFrame.new(cameraPos, cameraPos + direction)
    
    -- Apply smoothing
    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, AIM_SMOOTHNESS)
end

-- Optimized target finding
local currentTarget = nil
local function findTarget()
    if not AIMBOT_ENABLED or MENU_OPEN then return nil end
    
    local closestPlayer = nil
    local closestDistance = math.huge
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not localRoot then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if TEAM_CHECK and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                -- Skip teammates
            else
                local char = player.Character
                local humanoid = char:FindFirstChild("Humanoid")
                local head = char:FindFirstChild("Head")
                
                if humanoid and humanoid.Health > 0 and head then
                    -- Check distance
                    local distance = (localRoot.Position - head.Position).Magnitude
                    if distance > MAX_DISTANCE then goto continue end
                    
                    local screenPos = Camera:WorldToViewportPoint(head.Position)
                    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    local screenPoint = Vector2.new(screenPos.X, screenPos.Y)
                    local distance = (screenPoint - center).Magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
        ::continue::
    end
    
    currentTarget = closestPlayer
    return closestPlayer
end

-- Connect UI Events
CloseButton.MouseButton1Click:Connect(function()
    MENU_OPEN = false
    MainFrame.Visible = false
end)

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

-- Player added event
Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

-- Player removed event
Players.PlayerRemoving:Connect(function(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Remove()
        ESPBoxes[player] = nil
    end
    
    if ESPHealthBars[player] then
        ESPHealthBars[player].Outline:Remove()
        ESPHealthBars[player].Fill:Remove()
        ESPHealthBars[player] = nil
    end
end)

-- Input handling
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MENU_OPEN = not MainFrame.Visible
        MainFrame.Visible = MENU_OPEN
    end
end)

-- Main game loop
RunService.RenderStepped:Connect(function()
    -- Update ESP
    updateESP()
    
    -- Update target
    local target = findTarget()
    
    -- Apply aimbot if needed
    if UserInputService:IsMouseButtonPressed(AIMBOT_KEY) and target then
        smoothAim(target)
    end
end)

print("FIXED CHEAT LOADED! Press RightShift to toggle menu")
