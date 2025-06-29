-- Final Rivals Script: ESP + BEST Aimbot + Smooth Aim + Draggable Menu (RightShift toggle)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local aimbotEnabled = false
local espEnabled = false
local aiming = false
local menuVisible = false

local Drawing = Drawing

-- Dragging variables
local dragging = false
local dragStartPos = Vector2.new(0,0)
local menuStartPos = Vector2.new(10,10)

local UI = {}

-- Helper: create button
local function createButton(pos, size, text)
    local bg = Drawing.new("Square")
    bg.Position = pos
    bg.Size = size
    bg.Filled = true
    bg.Color = Color3.fromRGB(50, 50, 50)
    bg.Transparency = 0.85
    bg.Visible = false
    bg.ZIndex = 10

    local txt = Drawing.new("Text")
    txt.Position = Vector2.new(pos.X + size.X/2, pos.Y + size.Y/2 - 8)
    txt.Size = 20
    txt.Center = true
    txt.Color = Color3.fromRGB(220, 220, 220)
    txt.Outline = true
    txt.Text = text
    txt.Visible = false
    txt.ZIndex = 11

    return {
        bg = bg,
        txt = txt,
        pos = pos,
        size = size,
        text = text,
        setVisible = function(self, visible)
            self.bg.Visible = visible
            self.txt.Visible = visible
        end,
        setHover = function(self, hover)
            self.bg.Color = hover and Color3.fromRGB(70, 130, 180) or Color3.fromRGB(50, 50, 50)
        end,
        isMouseOver = function(self, mousePos)
            return mousePos.X >= self.pos.X and mousePos.X <= self.pos.X + self.size.X and mousePos.Y >= self.pos.Y and mousePos.Y <= self.pos.Y + self.size.Y
        end,
        setPosition = function(self, newPos)
            self.pos = newPos
            self.bg.Position = newPos
            self.txt.Position = Vector2.new(newPos.X + self.size.X/2, newPos.Y + self.size.Y/2 - 8)
        end,
        setText = function(self, newText)
            self.text = newText
            self.txt.Text = newText
        end,
    }
end

-- Menu UI
UI.menuBox = Drawing.new("Square")
UI.menuBox.Position = menuStartPos
UI.menuBox.Size = Vector2.new(260, 160)
UI.menuBox.Filled = true
UI.menuBox.Color = Color3.fromRGB(20, 20, 20)
UI.menuBox.Transparency = 0.9
UI.menuBox.Visible = false

UI.titleText = Drawing.new("Text")
UI.titleText.Position = Vector2.new(menuStartPos.X + 10, menuStartPos.Y + 15)
UI.titleText.Size = 24
UI.titleText.Color = Color3.fromRGB(135, 206, 250)
UI.titleText.Outline = true
UI.titleText.Text = "Rivals Script Menu"
UI.titleText.Visible = false

UI.espButton = createButton(Vector2.new(menuStartPos.X + 20, menuStartPos.Y + 60), Vector2.new(100, 40), "ESP: OFF")
UI.aimbotButton = createButton(Vector2.new(menuStartPos.X + 140, menuStartPos.Y + 60), Vector2.new(100, 40), "Aimbot: OFF")

local function updateUI()
    UI.espButton:setText(espEnabled and "ESP: ON" or "ESP: OFF")
    UI.espButton.bg.Color = espEnabled and Color3.fromRGB(34, 139, 34) or Color3.fromRGB(178, 34, 34)
    UI.aimbotButton:setText(aimbotEnabled and "Aimbot: ON" or "Aimbot: OFF")
    UI.aimbotButton.bg.Color = aimbotEnabled and Color3.fromRGB(34, 139, 34) or Color3.fromRGB(178, 34, 34)
end

local function setMenuVisible(visible)
    UI.menuBox.Visible = visible
    UI.titleText.Visible = visible
    UI.espButton:setVisible(visible)
    UI.aimbotButton:setVisible(visible)
    menuVisible = visible
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setMenuVisible(not menuVisible)
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 and menuVisible then
        local mousePos = UserInputService:GetMouseLocation()
        local titleBar = UI.menuBox.Position
        if mousePos.X >= titleBar.X and mousePos.X <= titleBar.X + 260 and mousePos.Y >= titleBar.Y and mousePos.Y <= titleBar.Y + 30 then
            dragging = true
            dragStartPos = mousePos - menuStartPos
        elseif UI.espButton:isMouseOver(mousePos) then
            espEnabled = not espEnabled
            updateUI()
        elseif UI.aimbotButton:isMouseOver(mousePos) then
            aimbotEnabled = not aimbotEnabled
            updateUI()
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and menuVisible and input.UserInputType == Enum.UserInputType.MouseMovement then
        local newPos = UserInputService:GetMouseLocation() - dragStartPos
        menuStartPos = newPos
        UI.menuBox.Position = newPos
        UI.titleText.Position = Vector2.new(newPos.X + 10, newPos.Y + 15)
        UI.espButton:setPosition(Vector2.new(newPos.X + 20, newPos.Y + 60))
        UI.aimbotButton:setPosition(Vector2.new(newPos.X + 140, newPos.Y + 60))
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

UserInputService.InputBegan:Connect(function(input)
    if aimbotEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then aiming = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then aiming = false end
end)

local espBoxes = {}

RunService.RenderStepped:Connect(function(delta)
    for _, box in ipairs(espBoxes) do box.Visible = false box:Remove() end
    espBoxes = {}

    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local pos, onScreen = camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local box = Drawing.new("Square")
                        box.Size = Vector2.new(60, 80)
                        box.Position = Vector2.new(pos.X - 30, pos.Y - 40)
                        box.Color = Color3.fromRGB(255, 0, 0)
                        box.Thickness = 2
                        box.Filled = false
                        box.Visible = true
                        table.insert(espBoxes, box)
                    end
                end
            end
        end
    end

    if aimbotEnabled and aiming then
        local closestPart = nil
        local shortestDist = math.huge

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local target = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
                if target then
                    local dist = (target.Position - camera.CFrame.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestPart = target
                    end
                end
            end
        end

        if closestPart then
            local current = camera.CFrame
            local targetPos = closestPart.Position
            local newCFrame = CFrame.new(current.Position, targetPos)
            camera.CFrame = current:Lerp(newCFrame, math.clamp(delta * 12, 0, 1))
        end
    end
end)

updateUI()
