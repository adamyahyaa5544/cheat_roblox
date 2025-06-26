-- Roblox Rivals ESP & Aimbot - FINAL FIXED VERSION
-- Press RightShift to toggle menu - now properly disables when menu is open

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Configuration
local ESP_COLOR = Color3.fromRGB(255, 0, 0)  -- Default red
local TEAM_CHECK = true
local AIMBOT_KEY = Enum.UserInputType.MouseButton2  -- Right mouse
local HEADSHOT_MODE = true
local FOV = 120  -- Aim field of view
local AIM_SMOOTHNESS = 0.2  -- Aim smoothing factor
local MAX_DISTANCE = 1000  -- Max targeting distance
local VISIBILITY_CHECK = true  -- Check if enemy is visible
local AIMBOT_ENABLED = true
local ESP_ENABLED = true
local MENU_OPEN = false  -- Track menu state globally

-- ESP Storage
local ESPBoxes = {}
local ESPTexts = {}

-- Menu GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local ColorPicker = Instance.new("TextBox")
local TeamToggle = Instance.new("TextButton")
local HeadshotToggle = Instance.new("TextButton")
local FOVSlider = Instance.new("TextButton")
local SmoothSlider = Instance.new("TextButton")
local VisibilityToggle = Instance.new("TextButton")
local AimbotToggle = Instance.new("TextButton")
local ESPToggle = Instance.new("TextButton")
local FOVCircle = Drawing.new("Circle")
local TargetIndicator = Drawing.new("Circle")

-- Initialize UI
function initUI()
    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = "CheatMenu"
    ScreenGui.ResetOnSpawn = false
    
    Frame.Size = UDim2.new(0, 250, 0, 250)
    Frame.Position = UDim2.new(0.5, -125, 0.5, -125)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    Frame.Visible = false
    Frame.Active = true
    Frame.Draggable = true
    
    ColorPicker.PlaceholderText = "ESP Color (R,G,B)"
    ColorPicker.Size = UDim2.new(0.8, 0, 0, 25)
    ColorPicker.Position = UDim2.new(0.1, 0, 0.05, 0)
    ColorPicker.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ColorPicker.TextColor3 = Color3.fromRGB(255, 255, 255)
    ColorPicker.BorderSizePixel = 0
    ColorPicker.Parent = Frame
    
    TeamToggle.Text = "Team Check: ON"
    TeamToggle.Size = UDim2.new(0.8, 0, 0, 25)
    TeamToggle.Position = UDim2.new(0.1, 0, 0.14, 0)
    TeamToggle.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    TeamToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeamToggle.BorderSizePixel = 0
    TeamToggle.Parent = Frame
    
    HeadshotToggle.Text = "Headshot: ON"
    HeadshotToggle.Size = UDim2.new(0.8, 0, 0, 25)
    HeadshotToggle.Position = UDim2.new(0.1, 0, 0.23, 0)
    HeadshotToggle.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    HeadshotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeadshotToggle.BorderSizePixel = 0
    HeadshotToggle.Parent = Frame
    
    VisibilityToggle.Text = "Visibility Check: ON"
    VisibilityToggle.Size = UDim2.new(0.8, 0, 0, 25)
    VisibilityToggle.Position = UDim2.new(0.1, 0, 0.32, 0)
    VisibilityToggle.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    VisibilityToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    VisibilityToggle.BorderSizePixel = 0
    VisibilityToggle.Parent = Frame
    
    FOVSlider.Text = "FOV: " .. FOV
    FOVSlider.Size = UDim2.new(0.8, 0, 0, 25)
    FOVSlider.Position = UDim2.new(0.1, 0, 0.41, 0)
    FOVSlider.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    FOVSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    FOVSlider.BorderSizePixel = 0
    FOVSlider.Parent = Frame
    
    SmoothSlider.Text = "Smoothness: " .. string.format("%.2f", AIM_SMOOTHNESS)
    SmoothSlider.Size = UDim2.new(0.8, 0, 0, 25)
    SmoothSlider.Position = UDim2.new(0.1, 0, 0.50, 0)
    SmoothSlider.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    SmoothSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    SmoothSlider.BorderSizePixel = 0
    SmoothSlider.Parent = Frame
    
    AimbotToggle.Text = "Aimbot: ON"
    AimbotToggle.Size = UDim2.new(0.8, 0, 0, 25)
    AimbotToggle.Position = UDim2.new(0.1, 0, 0.59, 0)
    AimbotToggle.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimbotToggle.BorderSizePixel = 0
    AimbotToggle.Parent = Frame
    
    ESPToggle.Text = "ESP: ON"
    ESPToggle.Size = UDim2.new(0.8, 0, 0, 25)
    ESPToggle.Position = UDim2.new(0.1, 0, 0.68, 0)
    ESPToggle.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ESPToggle.BorderSizePixel = 0
    ESPToggle.Parent = Frame
    
    -- FOV Circle Visualization
    FOVCircle.Visible = false
    FOVCircle.Transparency = 1
    FOVCircle.Color = Color3.new(1, 0, 0)
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 64
    FOVCircle.Radius = FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    -- Target Indicator
    TargetIndicator.Visible = false
    TargetIndicator.Transparency = 1
    TargetIndicator.Color = Color3.new(0, 1, 0)
    TargetIndicator.Thickness = 3
    TargetIndicator.NumSides = 12
    TargetIndicator.Radius = 8
end

-- Update ESP color
function updateColor()
    local r, g, b = ESP_COLOR.r * 255, ESP_COLOR.g * 255, ESP_COLOR.b * 255
    ColorPicker.Text = string.format("%d,%d,%d", r, g, b)
    FOVCircle.Color = ESP_COLOR
end

-- Create ESP box
function createESP(player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = ESP_COLOR
    Box.Thickness = 2
    Box.Filled = false
    
    local Text = Drawing.new("Text")
    Text.Visible = false
    Text.Color = ESP_COLOR
    Text.Size = 18
    Text.Center = true
    
    ESPBoxes[player] = Box
    ESPTexts[player] = Text
end

-- Update ESP
function updateESP()
    if not ESP_ENABLED or MENU_OPEN then return end
    
    for player, box in pairs(ESPBoxes) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                local headPos = Camera:WorldToViewportPoint(player.Character.Head.Position)
                local scale = (rootPos - headPos).Magnitude * 2
                
                box.Size = Vector2.new(scale, scale * 1.5)
                box.Position = Vector2.new(rootPos.X - scale/2, rootPos.Y - scale/2)
                box.Visible = true
                
                ESPTexts[player].Position = Vector2.new(rootPos.X, rootPos.Y - scale)
                ESPTexts[player].Text = player.Name
                ESPTexts[player].Visible = true
                
                -- Distance calculation
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                ESPTexts[player].Text = player.Name .. " [" .. math.floor(distance) .. "m]"
            else
                box.Visible = false
                ESPTexts[player].Visible = false
            end
        else
            box.Visible = false
            ESPTexts[player].Visible = false
        end
    end
end

-- Check if enemy is visible
function isVisible(character)
    if not VISIBILITY_CHECK then return true end
    
    local origin = Camera.CFrame.Position
    local target = character.Head.Position
    local direction = (target - origin).Unit * MAX_DISTANCE
    
    local ray = Ray.new(origin, direction)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    
    if hit and hit:IsDescendantOf(character) then
        return true
    end
    
    return false
end

-- Find target for aimbot
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
                    -- Check if player is visible
                    if VISIBILITY_CHECK and not isVisible(player.Character) then
                        -- Skip if not visible
                    else
                        -- Check distance
                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
                        if distance > MAX_DISTANCE then
                            -- Skip if too far
                        else
                            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                            if onScreen then
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
                end
            end
        end
    end
    
    return closestPlayer
end

-- Smooth aim function - FINALLY WORKING!
function smoothAim(target)
    if not target or not target.Character or MENU_OPEN then 
        TargetIndicator.Visible = false
        return 
    end
    
    local targetPart = HEADSHOT_MODE and target.Character.Head or target.Character.HumanoidRootPart
    if not targetPart then 
        TargetIndicator.Visible = false
        return 
    end
    
    -- Get target position in world space
    local targetPos = targetPart.Position
    
    -- Calculate direction
    local cameraPos = Camera.CFrame.Position
    local direction = (targetPos - cameraPos).Unit
    
    -- Create new CFrame looking at target
    local newCFrame = CFrame.new(cameraPos, cameraPos + direction)
    
    -- Apply smoothing
    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, AIM_SMOOTHNESS)
    
    -- Update target indicator
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
    if onScreen then
        TargetIndicator.Visible = true
        TargetIndicator.Position = Vector2.new(screenPos.X, screenPos.Y)
    else
        TargetIndicator.Visible = false
    end
end

-- Input handling
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MENU_OPEN = not Frame.Visible
        Frame.Visible = MENU_OPEN
        FOVCircle.Visible = MENU_OPEN
    end
end)

-- Color picker handler
ColorPicker.FocusLost:Connect(function()
    local colors = {}
    for val in string.gmatch(ColorPicker.Text, "%d+") do
        table.insert(colors, tonumber(val))
    end
    
    if #colors == 3 then
        ESP_COLOR = Color3.fromRGB(math.clamp(colors[1], 0, 255), 
                                  math.clamp(colors[2], 0, 255), 
                                  math.clamp(colors[3], 0, 255))
        updateColor()
    end
end)

-- Toggle handlers
TeamToggle.MouseButton1Click:Connect(function()
    TEAM_CHECK = not TEAM_CHECK
    TeamToggle.Text = TEAM_CHECK and "Team Check: ON" or "Team Check: OFF"
    TeamToggle.BackgroundColor3 = TEAM_CHECK and Color3.fromRGB(70, 130, 180) or Color3.fromRGB(180, 70, 70)
end)

HeadshotToggle.MouseButton1Click:Connect(function()
    HEADSHOT_MODE = not HEADSHOT_MODE
    HeadshotToggle.Text = HEADSHOT_MODE and "Headshot: ON" or "Headshot: OFF"
    HeadshotToggle.BackgroundColor3 = HEADSHOT_MODE and Color3.fromRGB(70, 130, 180) or Color3.fromRGB(180, 70, 70)
end)

VisibilityToggle.MouseButton1Click:Connect(function()
    VISIBILITY_CHECK = not VISIBILITY_CHECK
    VisibilityToggle.Text = VISIBILITY_CHECK and "Visibility Check: ON" or "Visibility Check: OFF"
    VisibilityToggle.BackgroundColor3 = VISIBILITY_CHECK and Color3.fromRGB(70, 130, 180) or Color3.fromRGB(180, 70, 70)
end)

-- FOV slider handler
FOVSlider.MouseButton1Click:Connect(function()
    FOV = FOV + 20
    if FOV > 200 then FOV = 40 end
    FOVSlider.Text = "FOV: " .. FOV
    FOVCircle.Radius = FOV
end)

-- Smoothness slider handler
SmoothSlider.MouseButton1Click:Connect(function()
    AIM_SMOOTHNESS = AIM_SMOOTHNESS + 0.1
    if AIM_SMOOTHNESS > 0.9 then AIM_SMOOTHNESS = 0.1 end
    SmoothSlider.Text = "Smoothness: " .. string.format("%.2f", AIM_SMOOTHNESS)
end)

-- Aimbot toggle handler
AimbotToggle.MouseButton1Click:Connect(function()
    AIMBOT_ENABLED = not AIMBOT_ENABLED
    AimbotToggle.Text = AIMBOT_ENABLED and "Aimbot: ON" or "Aimbot: OFF"
    AimbotToggle.BackgroundColor3 = AIMBOT_ENABLED and Color3.fromRGB(70, 130, 180) or Color3.fromRGB(180, 70, 70)
    TargetIndicator.Visible = false
end)

-- ESP toggle handler
ESPToggle.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    ESPToggle.Text = ESP_ENABLED and "ESP: ON" or "ESP: OFF"
    ESPToggle.BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(70, 130, 180) or Color3.fromRGB(180, 70, 70)
    
    -- Clear ESP when disabled
    if not ESP_ENABLED then
        for player, box in pairs(ESPBoxes) do
            box.Visible = false
            if ESPTexts[player] then
                ESPTexts[player].Visible = false
            end
        end
    end
end)

-- Main loop
initUI()
updateColor()

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
    
    -- Aimbot Handling - FINALLY WORKING PROPERLY!
    if UserInputService:IsMouseButtonPressed(AIMBOT_KEY) and AIMBOT_ENABLED and not MENU_OPEN then
        local target = findTarget()
        if target then
            smoothAim(target)
        else
            TargetIndicator.Visible = false
        end
    else
        TargetIndicator.Visible = false
    end
end)

-- Cleanup when player leaves
Players.PlayerRemoving:Connect(function(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Remove()
        ESPTexts[player]:Remove()
        ESPBoxes[player] = nil
        ESPTexts[player] = nil
    end
end)

print("ULTIMATE FIXED CHEAT LOADED! Press RightShift to toggle menu")
