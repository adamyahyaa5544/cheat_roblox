-- [START OUTPUT]
-- 🔫 PHANTOM RIVALS PRECISION AIM FIX v3.2 🔫
-- Fixed team detection and head targeting system

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Teams = game:GetService("Teams")  -- Added team service
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Configuration
local AIM_KEY = Enum.KeyCode.X
local MENU_KEY = Enum.KeyCode.RightShift
local MAX_DISTANCE = 1200
local SMOOTHING = 0.28
local FOV_CIRCLE_RADIUS = 130
local AIM_OFFSET = Vector3.new(0, 0.3, 0)

-- State variables
local AimEnabled = false
local EspEnabled = true
local MenuVisible = false
local Target
local EspObjects = {}
local menuFrame
local FovCircle

-- FIXED: Team check function
local function IsEnemy(player)
    -- Handle games without teams
    if not Teams or #Teams:GetTeams() == 0 then
        return player ~= LocalPlayer
    end
    
    -- Handle players not on a team
    if not LocalPlayer.Team or not player.Team then
        return player ~= LocalPlayer
    end
    
    return player.Team ~= LocalPlayer.Team
end

-- ESP functions (unchanged from v3.1)
-- ... [Same ESP code as v3.1] ...

-- FIXED: Aimbot functions
local function GetClosestTarget()
    local closestPlayer = nil
    local closestDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        -- Skip invalid targets using fixed team check
        if not IsEnemy(player) then continue end
        if not player.Character then continue end
        if not player.Character:FindFirstChild("Humanoid") then continue end
        if player.Character.Humanoid.Health <= 0 then continue end
        
        -- FIXED: Head targeting
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
        -- FIXED: Head targeting
        local head = Target.Character:FindFirstChild("Head")
        if head then
            local cameraCF = Camera.CFrame
            -- Aim directly at head with offset
            local targetPosition = head.Position + AIM_OFFSET
            
            -- Calculate direction with smoothing
            local direction = (targetPosition - cameraCF.Position).Unit
            local newLookVector = cameraCF.LookVector:Lerp(direction, SMOOTHING)
            
            -- Apply smoothed aim
            Camera.CFrame = CFrame.new(cameraCF.Position, cameraCF.Position + newLookVector)
        end
    end
end

-- Menu System (unchanged from v3.1)
-- ... [Same menu code as v3.1] ...

-- Initialize ESP with team check
for _, player in ipairs(Players:GetPlayers()) do
    if IsEnemy(player) then  -- FIXED: Only create ESP for enemies
        CreateEsp(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if IsEnemy(player) then  -- FIXED: Only create ESP for enemies
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

print("🎯 PHANTOM RIVALS PRECISION AIM FIX v3.2 LOADED 🎯")
print("Press RIGHT SHIFT to toggle menu")
print("Press X to toggle aimbot")
-- [END OUTPUT]
