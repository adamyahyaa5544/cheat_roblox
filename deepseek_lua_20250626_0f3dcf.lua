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

-- UI elements tables for easier management
local UI = {}

-- وظائف مساعدة
local function lerp(a, b, t)
    return a + (b - a) * t
end

local function lerpVector3(a, b, t)
    return a:Lerp(b, t)
end

-- إنشاء صندوق مستدير مع ظل وتدرج ألوان
local function createButton(pos, size, text)
    local bg = Drawing.new("Square")
    bg.Position = pos
    bg.Size = size
    bg.Filled = true
    bg.Color = Color3.fromRGB(50, 50, 50)
    bg.Transparency = 0.85
    bg.Visible = false
    bg.ZIndex = 10
    bg.Rounded = true -- خاصية موجودة في بعض بيئات Lua (لو مش موجودة احذفها)

    local hover = false

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
        hover = hover,
        pos = pos,
        size = size,
        text = text,
        setVisible = function(self, visible)
            self.bg.Visible = visible
            self.txt.Visible = visible
        end,
        setHover = function(self, hoverState)
            self.hover = hoverState
            if hoverState then
                self.bg.Color = Color3.fromRGB(70, 130, 180)
            else
                self.bg.Color = Color3.fromRGB(50, 50, 50)
            end
        end,
        isMouseOver = function(self, mousePos)
            return mousePos.X >= self.pos.X and mousePos.X <= self.pos.X + self.size.X
               and mousePos.Y >= self.pos.Y and mousePos.Y <= self.pos.Y + self.size.Y
        end
    }
end

-- إنشاء عناصر UI
UI.menuBox = Drawing.new("Square")
UI.menuBox.Position = Vector2.new(10, 10)
UI.menuBox.Size = Vector2.new(260, 150)
UI.menuBox.Filled = true
UI.menuBox.Color = Color3.fromRGB(20, 20, 20)
UI.menuBox.Transparency = 0.9
UI.menuBox.Visible = false
UI.menuBox.ZIndex = 9

UI.titleText = Drawing.new("Text")
UI.titleText.Position = Vector2.new(20, 15)
UI.titleText.Size = 24
UI.titleText.Color = Color3.fromRGB(135, 206, 250) -- أزرق سماوي
UI.titleText.Outline = true
UI.titleText.Text = "Rivals Script Menu"
UI.titleText.Visible = false
UI.titleText.ZIndex = 11

UI.espButton = createButton(Vector2.new(20, 50), Vector2.new(100, 40), "ESP: OFF")
UI.aimbotButton = createButton(Vector2.new(140, 50), Vector2.new(100, 40), "Aimbot: OFF")

local espBoxes = {}

local function updateUI()
    if espEnabled then
        UI.espButton.txt.Text = "ESP: ON"
        UI.espButton.bg.Color = Color3.fromRGB(34, 139, 34) -- أخضر غامق
    else
        UI.espButton.txt.Text = "ESP: OFF"
        UI.espButton.bg.Color = Color3.fromRGB(178, 34, 34) -- أحمر غامق
    end

    if aimbotEnabled then
        UI.aimbotButton.txt.Text = "Aimbot: ON"
        UI.aimbotButton.bg.Color = Color3.fromRGB(34, 139, 34)
    else
        UI.aimbotButton.txt.Text = "Aimbot: OFF"
        UI.aimbotButton.bg.Color = Color3.fromRGB(178, 34, 34)
    end
end

updateUI()

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

        -- تحديث Hover لكل زر
        for _, button in pairs({UI.espButton, UI.aimbotButton}) do
            button:setHover(button:isMouseOver(mousePos))
        end

        -- تحقق النقر على الأزرار
        if UI.espButton:isMouseOver(mousePos) then
            espEnabled = not espEnabled
            updateUI()
            print("ESP toggled:", espEnabled and "ON" or "OFF")
        elseif UI.aimbotButton:isMouseOver(mousePos) then
            aimbotEnabled = not aimbotEnabled
            updateUI()
            print("Aimbot toggled:", aimbotEnabled and "ON" or "OFF")
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if menuVisible then
        local mousePos = UserInputService:GetMouseLocation()
        for _, button in pairs({UI.espButton, UI.aimbotButton}) do
            button:setHover(button:isMouseOver(mousePos))
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if aimbotEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

local function getTargetPosition(character)
    -- نفضل الرأس إذا موجود، وإذا لا نستخدم HumanoidRootPart
    if character:FindFirstChild("Head") then
        return character.Head.Position
    elseif character:FindFirstChild("HumanoidRootPart") then
        return character.HumanoidRootPart.Position
    else
        return nil
    end
end

RunService.RenderStepped:Connect(function(delta)
    -- تنظيف ESP
    for _, box in pairs(espBoxes) do
        box.Visible = false
        box:Remove()
    end
    espBoxes = {}

    -- رسم ESP لو مفعّل
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local screenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                    if onScreen then
                        local size = Vector2.new(60, 80)
                        local box = Drawing.new("Square")
                        box.Size = size
                        box.Position = Vector2.new(screenPos.X - size.X/2, screenPos.Y - size.Y/2)
                        box.Color = Color3.fromRGB(255, 0, 0)
                        box.Thickness = 2
                        box.Filled = false
                        box.Visible = true
                        box.ZIndex = 100
                        table.insert(espBoxes, box)
                    end
                end
            end
        end
    end

    -- تحسين التصويب (Aimbot)
    if aimbotEnabled and aiming then
        local closestPlayer = nil
        local shortestDistance = math.huge
        local mousePos = UserInputService:GetMouseLocation()

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local targetPos = getTargetPosition(player.Character)
                if targetPos then
                    local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                        if dist < shortestDistance then
                            shortestDistance = dist
                            closestPlayer = player
                        end
                    end
                end
            end
        end

        if closestPlayer then
            local targetPos = getTargetPosition(closestPlayer.Character)
            if targetPos then
                local currentCFrame = camera.CFrame
                local desiredCFrame = CFrame.new(currentCFrame.Position, targetPos)
                -- تنعيم الحركة (lerp)
                camera.CFrame = currentCFrame:Lerp(desiredCFrame, math.clamp(delta * 10, 0, 1))
            end
        end
    end
end)
