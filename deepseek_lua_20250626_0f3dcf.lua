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

-- Dragging vars
local dragging = false
local dragStartPos = Vector2.new(0,0)
local menuStartPos = Vector2.new(50,50) -- بداية مكان القائمة

local UI = {}

-- زر مع تأثير hover وجميل
local function createButton(pos, size, text)
    local bg = Drawing.new("Square")
    bg.Position = pos
    bg.Size = size
    bg.Filled = true
    bg.Color = Color3.fromRGB(30, 30, 30)
    bg.Transparency = 0.85
    bg.Visible = false
    bg.ZIndex = 10

    local txt = Drawing.new("Text")
    txt.Position = Vector2.new(pos.X + size.X/2, pos.Y + size.Y/2 - 8)
    txt.Size = 22
    txt.Center = true
    txt.Color = Color3.fromRGB(200, 200, 200)
    txt.Outline = true
    txt.OutlineColor = Color3.fromRGB(10,10,10)
    txt.Text = text
    txt.Visible = false
    txt.ZIndex = 11

    local hovered = false

    -- تحديث لون الزر حسب الحالة (on/off) و hover
    local function updateColor()
        if hovered then
            bg.Color = Color3.fromRGB(70, 130, 180) -- أزرق عند hover
            txt.Color = Color3.fromRGB(245, 245, 245)
        else
            if text:find("ON") then
                bg.Color = Color3.fromRGB(34, 139, 34) -- أخضر تفعيل
                txt.Color = Color3.fromRGB(240, 240, 240)
            else
                bg.Color = Color3.fromRGB(100, 100, 100) -- رمادي إيقاف
                txt.Color = Color3.fromRGB(200, 200, 200)
            end
        end
    end

    bg.MouseEnter = function()
        hovered = true
        updateColor()
    end
    bg.MouseLeave = function()
        hovered = false
        updateColor()
    end

    return {
        bg = bg,
        txt = txt,
        pos = pos,
        size = size,
        text = text,
        updateColor = updateColor,
        setVisible = function(self, visible)
            self.bg.Visible = visible
            self.txt.Visible = visible
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
            self:updateColor()
        end,
    }
end

-- القائمة
UI.menuBox = Drawing.new("Square")
UI.menuBox.Position = menuStartPos
UI.menuBox.Size = Vector2.new(280, 170)
UI.menuBox.Filled = true
UI.menuBox.Color = Color3.fromRGB(15, 15, 15)
UI.menuBox.Transparency = 0.92
UI.menuBox.Visible = false
UI.menuBox.ZIndex = 9

-- ظل خفيف على القائمة
UI.menuShadow = Drawing.new("Square")
UI.menuShadow.Position = Vector2.new(menuStartPos.X + 5, menuStartPos.Y + 5)
UI.menuShadow.Size = Vector2.new(280, 170)
UI.menuShadow.Filled = true
UI.menuShadow.Color = Color3.fromRGB(0, 0, 0)
UI.menuShadow.Transparency = 0.6
UI.menuShadow.Visible = false
UI.menuShadow.ZIndex = 8

UI.titleText = Drawing.new("Text")
UI.titleText.Position = Vector2.new(menuStartPos.X + 15, menuStartPos.Y + 18)
UI.titleText.Size = 28
UI.titleText.Color = Color3.fromRGB(135, 206, 250)
UI.titleText.Outline = true
UI.titleText.OutlineColor = Color3.fromRGB(20,20,20)
UI.titleText.Text = "Rivals Script Menu"
UI.titleText.Visible = false
UI.titleText.ZIndex = 10

UI.espButton = createButton(Vector2.new(menuStartPos.X + 30, menuStartPos.Y + 70), Vector2.new(110, 45), "ESP: OFF")
UI.aimbotButton = createButton(Vector2.new(menuStartPos.X + 140, menuStartPos.Y + 70), Vector2.new(110, 45), "Aimbot: OFF")

local function updateUI()
    UI.espButton:setText(espEnabled and "ESP: ON" or "ESP: OFF")
    UI.aimbotButton:setText(aimbotEnabled and "Aimbot: ON" or "Aimbot: OFF")
end

local function setMenuVisible(visible)
    UI.menuBox.Visible = visible
    UI.menuShadow.Visible = visible
    UI.titleText.Visible = visible
    UI.espButton:setVisible(visible)
    UI.aimbotButton:setVisible(visible)
    menuVisible = visible
end

-- التعامل مع المدخلات
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setMenuVisible(not menuVisible)
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 and menuVisible then
        local mousePos = UserInputService:GetMouseLocation()
        local titleBar = UI.menuBox.Position
        -- سحب القائمة عند الضغط على شريط العنوان
        if mousePos.X >= titleBar.X and mousePos.X <= titleBar.X + UI.menuBox.Size.X and mousePos.Y >= titleBar.Y and mousePos.Y <= titleBar.Y + 35 then
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
        UI.menuShadow.Position = Vector2.new(newPos.X + 5, newPos.Y + 5)
        UI.titleText.Position = Vector2.new(newPos.X + 15, newPos.Y + 18)
        UI.espButton:setPosition(Vector2.new(newPos.X + 30, newPos.Y + 70))
        UI.aimbotButton:setPosition(Vector2.new(newPos.X + 140, newPos.Y + 70))
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then aiming = false end
end)

UserInputService.InputBegan:Connect(function(input)
    if aimbotEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

local espBoxes = {}

RunService.RenderStepped:Connect(function(delta)
    -- إزالة الصناديق القديمة
    for _, box in ipairs(espBoxes) do box.Visible = false box:Remove() end
    espBoxes = {}

    -- رسم ESP
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
                        box.Color = Color3.fromRGB(255, 50, 50)
                        box.Thickness = 2
                        box.Filled = false
                        box.Visible = true
                        table.insert(espBoxes, box)
                    end
                end
            end
        end
    end

    -- أيمبوت متحرك يتبع أقرب هدف للماوس
    if aimbotEnabled and aiming then
        local closest, shortest = nil, math.huge
        local mousePos = UserInputService:GetMouseLocation()

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local head = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
                if head then
                    local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                        if dist < shortest then
                            shortest = dist
                            closest = head
                        end
                    end
                end
            end
        end

        if closest then
            local current = camera.CFrame
            local targetPos = closest.Position
            local newCFrame = CFrame.new(current.Position, targetPos)
            camera.CFrame = current:Lerp(newCFrame, math.clamp(delta * 10, 0, 1))
        end
    end
end)

updateUI()
