-- Roblox Rivals ESP & Aimbot
-- Press RightShift to toggle menu
-- WARNING: This script violates Roblox ToS

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Configuration
local ESP_COLOR = Color3.fromRGB(255, 0, 0)  -- Default red
local TEAM_CHECK = true
local AIMBOT_KEY = Enum.UserInputType.MouseButton2  -- Right mouse
local HEADSHOT_MODE = true
local FOV = 120  -- Aim field of view

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

-- Initialize UI
function initUI()
    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = "CheatMenu"
    
    Frame.Size = UDim2.new(0, 200, 0, 150)
    Frame.Position = UDim2.new(0.5, -100, 0.5, -75)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.Parent = ScreenGui
    Frame.Visible = false
    
    ColorPicker.PlaceholderText = "ESP Color (R,G,B)"
    ColorPicker.Size = UDim2.new(0.8, 0, 0, 25)
    ColorPicker.Position = UDim2.new(0.1, 0, 0.1, 0)
    ColorPicker.Parent = Frame
    
    TeamToggle.Text = "Team Check: ON"
    TeamToggle.Size = UDim2.new(0.8, 0, 0, 25)
    TeamToggle.Position = UDim2.new(0.1, 0, 0.3, 0)
    TeamToggle.Parent = Frame
    
    HeadshotToggle.Text = "Headshot: ON"
    HeadshotToggle.Size = UDim2.new(0.8, 0, 0, 25)
    HeadshotToggle.Position = UDim2.new(0.1, 0, 0.5, 0)
    HeadshotToggle.Parent = Frame
    
    FOVSlider.Text = "FOV: " .. FOV
    FOVSlider.Size = UDim2.new(0.8, 0, 0, 25)
    FOVSlider.Position = UDim2.new(0.1, 0, 0.7, 0)
    FOVSlider.Parent = Frame
end

-- Update ESP color
function updateColor()
    local r, g, b = ESP_COLOR.r * 255, ESP_COLOR.g * 255, ESP_COLOR.b * 255
    ColorPicker.Text = string.format("%d,%d,%d", r, g, b)
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
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
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

-- Aimbot function
function aimAtTarget(target)
    if not target or not target.Character then return end
    
    local targetPart = HEADSHOT_MODE and target.Character.Head or target.Character.HumanoidRootPart
    if not targetPart then return end
    
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
end

-- Input handling
Mouse.KeyDown:Connect(function(key)
    if key == "RightShift" then
        Frame.Visible = not Frame.Visible
    end
end)

-- Color picker handler
ColorPicker.FocusLost:Connect(function()
    local colors = {}
    for val in string.gmatch(ColorPicker.Text, "%d+") do
        table.insert(colors, tonumber(val))
    end
    
    if #colors == 3 then
        ESP_COLOR = Color3.fromRGB(colors[1], colors[2], colors[3])
        updateColor()
    end
end)

-- Toggle handlers
TeamToggle.MouseButton1Click:Connect(function()
    TEAM_CHECK = not TEAM_CHECK
    TeamToggle.Text = TEAM_CHECK and "Team Check: ON" or "Team Check: OFF"
end)

HeadshotToggle.MouseButton1Click:Connect(function()
    HEADSHOT_MODE = not HEADSHOT_MODE
    HeadshotToggle.Text = HEADSHOT_MODE and "Headshot: ON" or "Headshot: OFF"
end)

-- Main loop
initUI()
updateColor()

RunService.RenderStepped:Connect(function()
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
            aimAtTarget(target)
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

print("Rivals Cheat Loaded! Press RightShift to toggle menu")
