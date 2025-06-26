-- Roblox Rivals Premium ESP & Aimbot
-- Press RightShift to toggle beautiful menu
-- Wall-penetrating head tracking aimbot

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Configuration
local ESP_COLOR = Color3.fromRGB(255, 50, 50)  -- Premium red
local TEAM_CHECK = true
local AIMBOT_KEY = Enum.UserInputType.MouseButton2  -- Right mouse
local HEADSHOT_MODE = true
local FOV = 100  -- Aim field of view
local AIM_SMOOTHNESS = 0.25  -- Aim smoothing factor
local MAX_DISTANCE = 1000  -- Max targeting distance
local VISIBILITY_CHECK = false  -- Disabled for wall penetration
local AIMBOT_ENABLED = true
local ESP_ENABLED = true
local MENU_OPEN = false
local WALL_PENETRATION = true  -- Target through walls

-- ESP Storage
local ESPBoxes = {}
local ESPHealthBars = {}

-- Premium UI Elements
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local TabContainer = Instance.new("Frame")
local AimbotTab = Instance.new("TextButton")
local ESPTab = Instance.new("TextButton")
local ContentFrame = Instance.new("Frame")

-- FOV Visualization
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Transparency = 0.5
FOVCircle.Color = Color3.new(1, 0, 0)
FOVCircle.Thickness = 2
FOVCircle.NumSides = 64
FOVCircle.Radius = FOV
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- Initialize Premium UI
function initPremiumUI()
    -- Main GUI
    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = "PremiumCheatMenu"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    MainFrame.Size = UDim2.new(0, 400, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    MainFrame.Visible = false
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = MainFrame
    
    -- Title Bar
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = TitleBar
    
    -- Title
    Title.Text = "PREMIUM RIVALS CHEAT v3.0"
    Title.Size = UDim2.new(0.7, 0, 1, 0)
    Title.Position = UDim2.new(0.05, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(220, 220, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    -- Close Button
    CloseButton.Text = "X"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14
    CloseButton.Parent = TitleBar
    
    -- Tab Container
    TabContainer.Size = UDim2.new(1, 0, 0, 40)
    TabContainer.Position = UDim2.new(0, 0, 0, 30)
    TabContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    -- Aimbot Tab
    AimbotTab.Text = "🔫 AIMBOT"
    AimbotTab.Size = UDim2.new(0.5, 0, 1, 0)
    AimbotTab.Position = UDim2.new(0, 0, 0, 0)
    AimbotTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    AimbotTab.TextColor3 = Color3.fromRGB(220, 180, 100)
    AimbotTab.Font = Enum.Font.GothamBold
    AimbotTab.TextSize = 14
    AimbotTab.Parent = TabContainer
    
    -- ESP Tab
    ESPTab.Text = "👁️ ESP"
    ESPTab.Size = UDim2.new(0.5, 0, 1, 0)
    ESPTab.Position = UDim2.new(0.5, 0, 0, 0)
    ESPTab.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    ESPTab.TextColor3 = Color3.fromRGB(180, 220, 100)
    ESPTab.Font = Enum.Font.GothamBold
    ESPTab.TextSize = 14
    ESPTab.Parent = TabContainer
    
    -- Content Frame
    ContentFrame.Size = UDim2.new(1, -20, 1, -80)
    ContentFrame.Position = UDim2.new(0, 10, 0, 80)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame
    
    -- Initialize Tabs
    initAimbotTab()
    initESPTab()
    
    -- Connect UI Events
    CloseButton.MouseButton1Click:Connect(function()
        MENU_OPEN = false
        MainFrame.Visible = false
    end)
    
    AimbotTab.MouseButton1Click:Connect(function()
        AimbotTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        ESPTab.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        initAimbotTab()
    end)
    
    ESPTab.MouseButton1Click:Connect(function()
        AimbotTab.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        ESPTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        initESPTab()
    end)
end

function initAimbotTab()
    -- Clear previous content
    for _, child in ipairs(ContentFrame:GetChildren()) do
        child:Destroy()
    end

    -- Aimbot Toggle
    createToggle("Aimbot", AIMBOT_ENABLED, 0, function(state)
        AIMBOT_ENABLED = state
    end, Color3.fromRGB(220, 100, 100))
    
    -- Headshot Toggle
    createToggle("Headshot Mode", HEADSHOT_MODE, 40, function(state)
        HEADSHOT_MODE = state
    end, Color3.fromRGB(100, 180, 220))
    
    -- Team Check Toggle
    createToggle("Team Check", TEAM_CHECK, 80, function(state)
        TEAM_CHECK = state
    end, Color3.fromRGB(100, 220, 140))
    
    -- Wall Penetration Toggle
    createToggle("Wall Penetration", WALL_PENETRATION, 120, function(state)
        WALL_PENETRATION = state
    end, Color3.fromRGB(220, 180, 80))
    
    -- FOV Slider
    createSlider("FOV", FOV, 40, 200, 160, function(value)
        FOV = value
        FOVCircle.Radius = FOV
    end, Color3.fromRGB(180, 100, 220))
    
    -- Smoothness Slider
    createSlider("Smoothness", math.floor(AIM_SMOOTHNESS*100), 10, 90, 200, function(value)
        AIM_SMOOTHNESS = value/100
    end, Color3.fromRGB(80, 200, 220))
end

function initESPTab()
    -- Clear previous content
    for _, child in ipairs(ContentFrame:GetChildren()) do
        child:Destroy()
    end

    -- ESP Toggle
    createToggle("ESP", ESP_ENABLED, 0, function(state)
        ESP_ENABLED = state
    end, Color3.fromRGB(100, 220, 140))
    
    -- Color Palette
    createColorPicker("ESP Color", 40)
end

function createToggle(label, initialState, yPos, callback, color)
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
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 50, 0, 24)
    toggleFrame.Position = UDim2.new(1, -50, 0.5, -12)
    toggleFrame.BackgroundColor3 = initialState and color or Color3.fromRGB(80, 80, 100)
    toggleFrame.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 20, 0, 20)
    toggleButton.Position = UDim2.new(0, initialState and 26 or 4, 0.5, -10)
    toggleButton.BackgroundColor3 = Color3.new(1, 1, 1)
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = toggleButton
    
    toggleButton.MouseButton1Click:Connect(function()
        local newState = not initialState
        initialState = newState
        
        -- Animate toggle
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(toggleButton, tweenInfo, {
            Position = UDim2.new(0, newState and 26 or 4, 0.5, -10)
        })
        
        tween:Play()
        toggleFrame.BackgroundColor3 = newState and color or Color3.fromRGB(80, 80, 100)
        callback(newState)
    end)
end

function createSlider(label, value, min, max, yPos, callback, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = ContentFrame
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Size = UDim2.new(0.4, 0, 0, 20)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Color3.fromRGB(220, 220, 240)
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 14
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame
    
    local valueText = Instance.new("TextLabel")
    valueText.Text = tostring(value)
    valueText.Size = UDim2.new(0.2, 0, 0, 20)
    valueText.Position = UDim2.new(0.8, 0, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.TextColor3 = Color3.fromRGB(180, 220, 255)
    valueText.Font = Enum.Font.GothamBold
    valueText.TextSize = 14
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.Parent = frame
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, 0, 0, 6)
    sliderTrack.Position = UDim2.new(0, 0, 0, 30)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    sliderTrack.Parent = frame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = color
    sliderFill.Parent = sliderTrack
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.Position = UDim2.new((value - min)/(max - min), -8, 0.5, -8)
    sliderButton.BackgroundColor3 = Color3.new(1, 1, 1)
    sliderButton.Text = ""
    sliderButton.Parent = sliderTrack
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = sliderButton
    
    local dragging = false
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    sliderTrack.MouseMoved:Connect(function(x, y)
        if dragging then
            local relativeX = x - sliderTrack.AbsolutePosition.X
            local percent = math.clamp(relativeX / sliderTrack.AbsoluteSize.X, 0, 1)
            local newValue = math.floor(min + (max - min) * percent)
            
            if newValue ~= value then
                value = newValue
                valueText.Text = tostring(value)
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                sliderButton.Position = UDim2.new(percent, -8, 0.5, -8)
                callback(value)
            end
        end
    end)
end

function createColorPicker(label, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 80)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = ContentFrame
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Size = UDim2.new(0.4, 0, 0, 20)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Color3.fromRGB(220, 220, 240)
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 14
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame
    
    -- Color Preview Box
    local colorPreview = Instance.new("Frame")
    colorPreview.Size = UDim2.new(0, 80, 0, 30)
    colorPreview.Position = UDim2.new(0.6, 0, 0, 0)
    colorPreview.BackgroundColor3 = ESP_COLOR
    colorPreview.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = colorPreview
    
    -- Color Palette
    local colors = {
        {Name = "❤️ Red", Color = Color3.new(1, 0, 0)},
        {Name = "💚 Green", Color = Color3.new(0, 1, 0)},
        {Name = "💙 Blue", Color = Color3.new(0, 0.5, 1)},
        {Name = "💛 Yellow", Color = Color3.new(1, 1, 0)},
        {Name = "💜 Purple", Color = Color3.new(0.7, 0, 1)},
        {Name = "🧡 Orange", Color = Color3.new(1, 0.5, 0)},
        {Name = "💖 Pink", Color = Color3.new(1, 0.3, 0.7)},
        {Name = "💠 Cyan", Color = Color3.new(0, 1, 1)}
    }
    
    for i, colorInfo in ipairs(colors) do
        local xPos = ((i-1) % 4) * 0.25
        local yPos = math.floor((i-1)/4) * 0.5 + 0.5
        
        local colorButton = Instance.new("TextButton")
        colorButton.Size = UDim2.new(0, 25, 0, 25)
        colorButton.Position = UDim2.new(xPos, 5, yPos, 0)
        colorButton.BackgroundColor3 = colorInfo.Color
        colorButton.Text = ""
        colorButton.Parent = frame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 4)
        buttonCorner.Parent = colorButton
        
        -- Tooltip
        local tooltip = Instance.new("TextLabel")
        tooltip.Text = colorInfo.Name
        tooltip.Size = UDim2.new(0, 70, 0, 20)
        tooltip.Position = UDim2.new(0, 0, -1, 0)
        tooltip.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        tooltip.TextColor3 = Color3.new(1, 1, 1)
        tooltip.Font = Enum.Font.Gotham
        tooltip.TextSize = 12
        tooltip.Visible = false
        tooltip.Parent = colorButton
        
        local tipCorner = Instance.new("UICorner")
        tipCorner.CornerRadius = UDim.new(0, 4)
        tipCorner.Parent = tooltip
        
        colorButton.MouseEnter:Connect(function()
            tooltip.Visible = true
        end)
        
        colorButton.MouseLeave:Connect(function()
            tooltip.Visible = false
        end)
        
        colorButton.MouseButton1Click:Connect(function()
            ESP_COLOR = colorInfo.Color
            colorPreview.BackgroundColor3 = colorInfo.Color
        end)
    end
end

-- Create ESP box with health bar
function createESP(player)
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

-- Update ESP with health bars
function updateESP()
    if not ESP_ENABLED or MENU_OPEN then return end
    
    for player, box in pairs(ESPBoxes) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local rootPart = player.Character.HumanoidRootPart
            local humanoid = player.Character.Humanoid
            local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                local headPos = Camera:WorldToViewportPoint(player.Character.Head.Position)
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
                
                -- Health bar color based on health
                if healthPercent > 0.6 then
                    healthBar.Fill.Color = Color3.new(0, 1, 0)
                elseif healthPercent > 0.3 then
                    healthBar.Fill.Color = Color3.new(1, 1, 0)
                else
                    healthBar.Fill.Color = Color3.new(1, 0, 0)
                end
            else
                box.Visible = false
                ESPHealthBars[player].Outline.Visible = false
                ESPHealthBars[player].Fill.Visible = false
            end
        else
            box.Visible = false
            if ESPHealthBars[player] then
                ESPHealthBars[player].Outline.Visible = false
                ESPHealthBars[player].Fill.Visible = false
            end
        end
    end
end

-- Head tracking aimbot with wall penetration
function smoothAim(target)
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

-- Find target for aimbot (with wall penetration)
function findTarget()
    if not AIMBOT_ENABLED or MENU_OPEN then return nil end
    
    local closestPlayer = nil
    local closestDistance = FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if TEAM_CHECK and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                -- Skip teammates
            else
                local humanoid = player.Character:FindFirstChild("Humanoid")
                local head = player.Character:FindFirstChild("Head")
                
                if humanoid and humanoid.Health > 0 and head then
                    -- Check distance
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
                    if distance > MAX_DISTANCE then
                        -- Skip if too far
                    else
                        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                        
                        if onScreen then
                            local screenPoint = Vector2.new(screenPos.X, screenPos.Y)
                            local distance = (screenPoint - center).Magnitude
                            
                            if distance < closestDistance then
                                closestDistance = distance
                                closestPlayer = player
                            end
                        elseif WALL_PENETRATION then
                            -- Calculate screen position for off-screen targets
                            local relativePos = Camera.CFrame:PointToObjectSpace(head.Position)
                            local screenPoint = Vector2.new(
                                center.X + (relativePos.X/relativePos.Z) * center.X,
                                center.Y - (relativePos.Y/relativePos.Z) * center.Y
                            )
                            
                            local distance = (screenPoint - center).Magnitude
                            
                            if distance < closestDistance then
                                closestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Input handling
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MENU_OPEN = not MainFrame.Visible
        MainFrame.Visible = MENU_OPEN
        FOVCircle.Visible = MENU_OPEN
    end
end)

-- Main loop
initPremiumUI()

RunService.RenderStepped:Connect(function()
    -- Update FOV circle position
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    -- ESP Handling
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not ESPBoxes[player] then
            createESP(player)
        end
    end
    
    updateESP()
    
    -- Aimbot Handling with wall penetration
    if UserInputService:IsMouseButtonPressed(AIMBOT_KEY) and AIMBOT_ENABLED and not MENU_OPEN then
        local target = findTarget()
        if target then
            smoothAim(target)
        end
    end
end)

-- Cleanup when player leaves
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

print("ULTIMATE WALL-PENETRATION CHEAT LOADED! Press RightShift to toggle menu")
