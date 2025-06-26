-- [START OUTPUT]
-- 🔥 PHANTOM RIVALS PERFECTION v4.5 🔥
-- Ultimate aimbot with head tracking, vibrant ESP colors, and all fixes applied

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

-- Vibrant ESP color options
local ESP_COLORS = {
    {name = "NEON RED", color = Color3.fromRGB(255, 50, 50)},
    {name = "ELECTRIC BLUE", color = Color3.fromRGB(0, 150, 255)},
    {name = "ACID GREEN", color = Color3.fromRGB(50, 255, 100)},
    {name = "HOT PINK", color = Color3.fromRGB(255, 50, 150)},
    {name = "PURPLE HAZE", color = Color3.fromRGB(180, 80, 255)},
    {name = "SUNSET ORANGE", color = Color3.fromRGB(255, 150, 50)}
}
local ESP_COLOR = ESP_COLORS[1].color  -- Default to neon red
local NAME_COLOR = Color3.new(1, 1, 1)
local SHOW_NAMES = true
local SHOW_HEALTH = true

-- State variables
local AimEnabled = false
local EspEnabled = true
local MenuVisible = false
local EspObjects = {}
local menuFrame

-- Fixed team check
local function IsEnemy(player)
    if player == LocalPlayer then return false end
    if not Teams or #Teams:GetTeams() == 0 then return true end
    if not LocalPlayer.Team or not player.Team then return true end
    return player.Team ~= LocalPlayer.Team
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

-- Precision head tracking aimbot - FIXED FOR ALL GAME MODES
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
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer
end

local function AimAtTarget()
    local Target = GetClosestTarget()
    
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

-- Fixed Menu System with vibrant colors
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
    mainFrame.Size = UDim2.new(0, 350, 0, 420)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -210)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
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
    title.Text = "PHANTOM RIVALS v4.5"
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
    CreateSection("PRECISION AIMBOT", 0.02)
    
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
    local smoothFrame = CreateSection("AIM SMOOTHNESS", 0.22)
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
    
    -- ESP section
    CreateSection("VIBRANT ESP COLORS", 0.40)
    
    -- Color grid
    local yPos = 0.45
    for row = 1, 2 do
        for col = 1, 3 do
            local idx = (row-1)*3 + col
            if ESP_COLORS[idx] then
                local colorInfo = ESP_COLORS[idx]
                local colorBtn = Instance.new("TextButton")
                colorBtn.Text = colorInfo.name
                colorBtn.Size = UDim2.new(0.28, 0, 0, 35)
                colorBtn.Position = UDim2.new(0.05 + (col-1)*0.31, 0, yPos, 0)
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
        yPos = yPos + 0.10
    end
    
    -- ESP Options
    local nameToggle = Instance.new("TextButton")
    nameToggle.Text = SHOW_NAMES and "PLAYER NAMES: ON" or "PLAYER NAMES: OFF"
    nameToggle.Size = UDim2.new(0.9, 0, 0, 35)
    nameToggle.Position = UDim2.new(0.05, 0, 0.68, 0)
    nameToggle.BackgroundColor3 = SHOW_NAMES and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
    nameToggle.TextColor3 = Color3.new(1, 1, 1)
    nameToggle.Font = Enum.Font.Gotham
    nameToggle.TextSize = 14
    nameToggle.Parent = content
    
    nameToggle.MouseButton1Click:Connect(function()
        SHOW_NAMES = not SHOW_NAMES
        nameToggle.Text = SHOW_NAMES and "PLAYER NAMES: ON" or "PLAYER NAMES: OFF"
        nameToggle.BackgroundColor3 = SHOW_NAMES and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
    end)
    
    local healthToggle = Instance.new("TextButton")
    healthToggle.Text = SHOW_HEALTH and "HEALTH BARS: ON" or "HEALTH BARS: OFF"
    healthToggle.Size = UDim2.new(0.9, 0, 0, 35)
    healthToggle.Position = UDim2.new(0.05, 0, 0.76, 0)
    healthToggle.BackgroundColor3 = SHOW_HEALTH and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
    healthToggle.TextColor3 = Color3.new(1, 1, 1)
    healthToggle.Font = Enum.Font.Gotham
    healthToggle.TextSize = 14
    healthToggle.Parent = content
    
    healthToggle.MouseButton1Click:Connect(function()
        SHOW_HEALTH = not SHOW_HEALTH
        healthToggle.Text = SHOW_HEALTH and "HEALTH BARS: ON" or "HEALTH BARS: OFF"
        healthToggle.BackgroundColor3 = SHOW_HEALTH and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
    end)
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "CLOSE MENU (RightShift)"
    closeButton.Size = UDim2.new(0.9, 0, 0, 40)
    closeButton.Position = UDim2.new(0.05, 0, 0.88, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 16
    closeButton.Parent = content
    
    closeButton.MouseButton1Click:Connect(function()
        MenuVisible = false
        menuFrame.Enabled = false
    end)
    
    return menuFrame
end

local function ToggleMenu()
    MenuVisible = not MenuVisible
    
    if MenuVisible then
        CreateMenu().Enabled = true
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
end)

Players.PlayerRemoving:Connect(function(player)
    if EspObjects[player] then
        EspObjects[player].Box:Remove()
        EspObjects[player].NameTag:Remove()
        EspObjects[player].HealthBar:Remove()
        EspObjects[player].HealthBarBackground:Remove()
        EspObjects[player] = nil
    end
end)

-- Main loop
RunService.RenderStepped:Connect(function()
    if AimEnabled and not MenuVisible then
        AimAtTarget()
    end
    UpdateEsp()
end)

print([[
  ____  _                      _   _       _ _      ____  _     _____ 
 |  _ \| |__   __ _ _ __   ___| | | | __ _| | |    / ___|| |   |___ / 
 | |_) | '_ \ / _` | '_ \ / _ \ |_| |/ _` | | |    \___ \| |     |_ \ 
 |  __/| | | | (_| | | | |  __/  _  | (_| | | |     ___) | |___ ___) |
 |_|   |_| |_|\__,_|_| |_|\___|_| |_|\__,_|_|_|    |____/|_____|____/ 
]])

print("🔥 PHANTOM RIVALS PERFECTION v4.5 LOADED 🔥")
print("Press RIGHT SHIFT to open menu")
print("Press X to toggle aimbot")
-- [END OUTPUT]
