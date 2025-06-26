-- Roblox Rivals Enhanced ESP & Aimbot
-- Fixed head tracking and smooth aiming
-- Press RightShift to toggle menu

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
local AIM_SMOOTHNESS = 0.25  -- Aim smoothing factor (0 = instant, 1 = very smooth)
local MAX_DISTANCE = 1000  -- Max targeting distance
local VISIBILITY_CHECK = true  -- Check if enemy is visible

-- ESP Storage
local ESPBoxes = {}
local ESPTexts = {}
local ESPConnections = {}

-- Menu GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local ColorPicker = Instance.new("TextBox")
local TeamToggle = Instance.new("TextButton")
local HeadshotToggle = Instance.new("TextButton")
local FOVSlider = Instance.new("TextButton")
local SmoothSlider = Instance.new("TextButton")
local VisibilityToggle = Instance.new("TextButton")
local FOVCircle = Drawing.new("Circle")

-- Initialize UI
function initUI()
    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = "CheatMenu"
    
    Frame.Size = UDim2.new(0, 250, 0, 200)
    Frame.Position = UDim2.new(0.5, -125, 0.5, -100)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    Frame.Visible = false
    
    ColorPicker.PlaceholderText = "ESP Color (R,G,B)"
    ColorPicker.Size = UDim2.new(0.8, 0, 0, 25)
    ColorPicker.Position = UDim2.new(0.1, 0, 0.05, 0)
    ColorPicker.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ColorPicker.TextColor3 = Color3.fromRGB(255, 255, 255)
    ColorPicker.BorderSizePixel = 0
    ColorPicker.Parent = Frame
    
    TeamToggle.Text = "Team Check: ON"
    TeamToggle.Size = UDim2.new(0.8, 0, 0, 25)
    TeamToggle.Position = UDim2.new(0.1, 0, 0.2, 0)
    TeamToggle.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    TeamToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeamToggle.BorderSizePixel = 0
    TeamToggle.Parent = Frame
    
    HeadshotToggle.Text = "Headshot: ON"
    HeadshotToggle.Size = UDim2.new(0.8, 0, 0, 25)
    HeadshotToggle.Position = UDim2.new(0.1, 0, 0.35, 0)
    HeadshotToggle.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    HeadshotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeadshotToggle.BorderSizePixel = 0
    HeadshotToggle.Parent = Frame
    
    VisibilityToggle.Text = "Visibility Check: ON"
    VisibilityToggle.Size = UDim2.new(0.8, 0, 0, 25)
    VisibilityToggle.Position = UDim2.new(0.1, 0, 0.5, 0)
    VisibilityToggle.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    VisibilityToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    VisibilityToggle.BorderSizePixel = 0
    VisibilityToggle.Parent = Frame
    
    FOVSlider.Text = "FOV: " .. FOV
    FOVSlider.Size = UDim2.new(0.8, 0, 0, 25)
    FOVSlider.Position = UDim2.new(0.1, 0, 0.65, 0)
    FOVSlider.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    FOVSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    FOVSlider.BorderSizePixel = 0
    FOVSlider.Parent = Frame
    
    SmoothSlider.Text = "Smoothness: " .. string.format("%.2f", AIM_SMOOTHNESS)
    SmoothSlider.Size = UDim2.new(0.8, 0, 0, 25)
    SmoothSlider.Position = UDim2.new(0.1, 0, 0.8, 0)
    SmoothSlider.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    SmoothSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    SmoothSlider.BorderSizePixel = 0
    SmoothSlider.Parent = Frame
    
    -- FOV Circle Visualization
    FOVCircle.Visible = false
    FOVCircle.Transparency = 1
    FOVCircle.Color = Color3.new(1, 0, 0)
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 64
    FOVCircle.Radius = FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
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
    local closestPlayer = nil
    local closestDistance = FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if TEAM_CHECK and player.Team == LocalPlayer.Team then continue end
            
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                -- Check if player is visible
                if not isVisible(player.Character) then continue end
                
                -- Check distance
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
                if distance > MAX_DISTANCE then continue end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                local offset = Vector2.new(screenPos.X, screenPos.Y) - mousePos
                local distance = offset.Magnitude
                
                if distance < closestDistance and onScreen then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

-- Smooth aim function
function smoothAim(target)
    if not target or not target.Character then return end
    
    local targetPart = HEADSHOT_MODE and target.Character.Head or target.Character.HumanoidRootPart
    if not targetPart then return end
    
    -- Get target position in screen space
    local targetPos = Camera:WorldToViewportPoint(targetPart.Position)
    local targetVec = Vector2.new(targetPos.X, targetPos.Y)
    
    -- Get current mouse position
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    -- Calculate direction to target
    local direction = (targetVec - center)
    
    -- Apply smoothing
    direction = direction * (1 - AIM_SMOOTHNESS)
    
    -- Move mouse towards target
    local newPos = center + direction
    
    -- Set mouse position (using exploit API)
    if set_mouse_position then
        set_mouse_position(newPos.X, newPos.Y)
    else
        -- Fallback method
        mousemoverel(direction.X, direction.Y)
    end
end

-- Input handling
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.RightShift then
        Frame.Visible = not Frame.Visible
        FOVCircle.Visible = Frame.Visible
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
    
    -- Aimbot Handling
    if UserInputService:IsMouseButtonPressed(AIMBOT_KEY) then
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
        ESPTexts[player]:Remove()
        ESPBoxes[player] = nil
        ESPTexts[player] = nil
    end
end)

print("Enhanced Rivals Cheat Loaded! Press RightShift to toggle menu")
