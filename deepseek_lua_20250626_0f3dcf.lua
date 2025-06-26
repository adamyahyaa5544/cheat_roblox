-- [START OUTPUT]
-- PhantomRivals Fixed Edition v2.3
-- Fixed ESP, Aimbot, and Menu System for Roblox Rivals

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Fixed Configuration
local AIM_KEY = Enum.KeyCode.X
local MENU_KEY = Enum.KeyCode.RightShift
local MAX_DISTANCE = 1000
local SMOOTHING = 0.35
local FOV_CIRCLE_RADIUS = 120

-- Fixed State variables
local AimEnabled = false
local EspEnabled = true
local MenuVisible = false
local Target
local Connections = {}
local EspObjects = {}
local FovCircle

-- Fixed ESP functions
local function CreateEsp(player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.new(1, 0.2, 0.2)
    Box.Thickness = 1.5
    Box.Size = Vector2.new(20, 30)
    Box.Filled = false

    local NameTag = Drawing.new("Text")
    NameTag.Visible = false
    NameTag.Color = Color3.new(1, 1, 1)
    NameTag.Size = 16
    NameTag.Center = true
    NameTag.Outline = true
    NameTag.OutlineColor = Color3.new(0, 0, 0)

    EspObjects[player] = {Box = Box, NameTag = NameTag}
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
                    -- Calculate box dimensions based on head and root positions
                    local scale = (headPos.Y - rootPos.Y) * 1.8
                    local width = scale / 1.8
                    local height = scale * 1.4
                    
                    drawings.Box.Size = Vector2.new(width, height)
                    drawings.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
                    drawings.Box.Visible = EspEnabled
                    
                    -- Position nametag above head
                    drawings.NameTag.Text = player.Name
                    drawings.NameTag.Position = Vector2.new(headPos.X, headPos.Y - 40)
                    drawings.NameTag.Visible = EspEnabled
                else
                    drawings.Box.Visible = false
                    drawings.NameTag.Visible = false
                end
            end
        else
            drawings.Box.Visible = false
            drawings.NameTag.Visible = false
        end
    end
end

-- Fixed Aimbot functions
local function GetClosestTarget()
    local closestPlayer = nil
    local closestDistance = math.huge
    local cameraPos = Camera.CFrame.Position
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoidRootPart and head then
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
    end
    
    return closestPlayer
end

local function AimAtTarget()
    if not Target or not Target.Character or not Target.Character:FindFirstChild("HumanoidRootPart") then
        Target = GetClosestTarget()
    end
    
    if Target and Target.Character then
        local humanoidRootPart = Target.Character:FindFirstChild("HumanoidRootPart")
        local head = Target.Character:FindFirstChild("Head")
        
        if humanoidRootPart and head then
            local targetPosition = head.Position
            local cameraPosition = Camera.CFrame.Position
            local direction = (targetPosition - cameraPosition).Unit
            
            local currentLook = Camera.CFrame.LookVector
            local smoothed = currentLook:Lerp(direction, SMOOTHING)
            
            Camera.CFrame = CFrame.new(cameraPosition, cameraPosition + smoothed)
        end
    end
end

-- Fixed Menu System
local menuFrame
local function CreateMenu()
    if menuFrame then return end
    
    menuFrame = Instance.new("ScreenGui")
    menuFrame.Name = "PhantomMenu"
    menuFrame.ResetOnSpawn = false
    menuFrame.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    menuFrame.Parent = game.CoreGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = MenuVisible
    mainFrame.Parent = menuFrame
    
    local title = Instance.new("TextLabel")
    title.Text = "PHANTOM RIVALS v2.3"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.new(0.2, 0, 0)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = mainFrame
    
    -- Aimbot Toggle
    local aimbotToggle = Instance.new("TextButton")
    aimbotToggle.Text = "AIMBOT: " .. (AimEnabled and "ON" or "OFF")
    aimbotToggle.Size = UDim2.new(0.9, 0, 0, 40)
    aimbotToggle.Position = UDim2.new(0.05, 0, 0.2, 0)
    aimbotToggle.BackgroundColor3 = AimEnabled and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
    aimbotToggle.TextColor3 = Color3.new(1, 1, 1)
    aimbotToggle.Font = Enum.Font.Gotham
    aimbotToggle.TextSize = 16
    aimbotToggle.Parent = mainFrame
    
    aimbotToggle.MouseButton1Click:Connect(function()
        AimEnabled = not AimEnabled
        aimbotToggle.Text = "AIMBOT: " .. (AimEnabled and "ON" or "OFF")
        aimbotToggle.BackgroundColor3 = AimEnabled and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
        print("Aimbot " .. (AimEnabled and "ENABLED" or "DISABLED"))
    end)
    
    -- ESP Toggle
    local espToggle = Instance.new("TextButton")
    espToggle.Text = "ESP: " .. (EspEnabled and "ON" or "OFF")
    espToggle.Size = UDim2.new(0.9, 0, 0, 40)
    espToggle.Position = UDim2.new(0.05, 0, 0.4, 0)
    espToggle.BackgroundColor3 = EspEnabled and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
    espToggle.TextColor3 = Color3.new(1, 1, 1)
    espToggle.Font = Enum.Font.Gotham
    espToggle.TextSize = 16
    espToggle.Parent = mainFrame
    
    espToggle.MouseButton1Click:Connect(function()
        EspEnabled = not EspEnabled
        espToggle.Text = "ESP: " .. (EspEnabled and "ON" or "OFF")
        espToggle.BackgroundColor3 = EspEnabled and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
        print("ESP " .. (EspEnabled and "ENABLED" or "DISABLED"))
    end)
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "CLOSE MENU (RightShift)"
    closeButton.Size = UDim2.new(0.9, 0, 0, 40)
    closeButton.Position = UDim2.new(0.05, 0, 0.8, 0)
    closeButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 16
    closeButton.Parent = mainFrame
    
    closeButton.MouseButton1Click:Connect(function()
        MenuVisible = false
        mainFrame.Visible = false
    end)
    
    return mainFrame
end

local function ToggleMenu()
    MenuVisible = not MenuVisible
    local menu = CreateMenu()
    menu.Visible = MenuVisible
    print("Phantom Menu " .. (MenuVisible and "opened" or "closed"))
end

-- Fixed Keybind handlers
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == MENU_KEY then
        ToggleMenu()
    elseif input.KeyCode == AIM_KEY then
        AimEnabled = not AimEnabled
        print("Aimbot " .. (AimEnabled and "ENABLED" or "DISABLED"))
    end
end)

-- Fixed initialization
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
        EspObjects[player] = nil
    end
end)

-- Fixed Main loop
RunService.RenderStepped:Connect(function()
    if AimEnabled and not MenuVisible then
        AimAtTarget()
    end
    
    if EspEnabled then
        UpdateEsp()
    end
end)

print([[
  ____  _                      _   _       _ _      
 |  _ \| |__   __ _ _ __   ___| | | | __ _| | | ___ 
 | |_) | '_ \ / _` | '_ \ / _ \ |_| |/ _` | | |/ __|
 |  __/| | | | (_| | | | |  __/  _  | (_| | | | (__ 
 |_|   |_| |_|\__,_|_| |_|\___|_| |_|\__,_|_|_|\___|
]])

print("PhantomRivals Fixed Edition loaded")
print("Press RIGHT SHIFT to toggle menu")
print("Press X to toggle aimbot")
-- [END OUTPUT]
