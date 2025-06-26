-- Rivals XERA Hack v7.0 - Complete Working Solution
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

-- ESP functions
local function CreateEsp(player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = ESP_COLOR
    Box.Thickness = 2
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
                    local height = (headPos.Y - rootPos.Y) * 2.2
                    local width = height * 0.6
                    local boxX = rootPos.X - width/2
                    local boxY = rootPos.Y - height/2
                    
                    drawings.Box.Size = Vector2.new(width, height)
                    drawings.Box.Position = Vector2.new(boxX, boxY)
                    drawings.Box.Visible = EspEnabled
                    drawings.Box.Color = ESP_COLOR
                    
                    if SHOW_NAMES then
                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                        drawings.NameTag.Text = string.format("%s [%d]", player.Name, math.floor(distance))
                        drawings.NameTag.Position = Vector2.new(headPos.X, headPos.Y - 25)
                        drawings.NameTag.Visible = EspEnabled
                    else
                        drawings.NameTag.Visible = false
                    end
                    
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

-- FIXED AIMBOT - Targets enemy heads at any distance
local function GetClosestTarget()
    local closestPlayer = nil
    local closestDistance = math.huge
    local cameraPos = Camera.CFrame.Position
    
    for _, player in ipairs(Players:GetPlayers()) do
        -- Only target enemies
        if not IsEnemy(player) then continue end
        
        -- Skip invalid targets
        if not player.Character then continue end
        if not player.Character:FindFirstChild("Humanoid") then continue end
        if player.Character.Humanoid.Health <= 0 then continue end
        
        -- Target head specifically
        local head = player.Character:FindFirstChild("Head")
        if head then
            local distance = (cameraPos - head.Position).Magnitude
            
            -- Target closest enemy head regardless of distance
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer
end

-- FIXED AIMBOT FUNCTION
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

-- Menu system
local function CreateMenu()
    if menuFrame and menuFrame.Parent then 
        menuFrame.Enabled = MenuVisible
        return menuFrame
    end
    
    menuFrame = Instance.new("ScreenGui")
    menuFrame.Name = "XeraMenu"
    menuFrame.ResetOnSpawn = false
    menuFrame.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    menuFrame.Parent = game:GetService("CoreGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = menuFrame
    
    -- Top bar
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 2
    topBar.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Text = "RIVALS XERA v7.0"
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
