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

-- متغيرات السحب
local dragging = false
local dragStartPos = Vector2.new(0,0)
local menuStartPos = Vector2.new(10,10)

-- UI elements
local UI = {}

-- دوال مساعدة
local function lerp(a, b, t)
    return a + (b - a) * t
end

local function lerpVector3(a, b, t)
    return a:Lerp(b, t)
end

-- إنشاء زر مع دعم Hover
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

    local hovered = false

    return {
        bg = bg,
        txt = txt,
        pos = pos,
        size = size,
        text = text,
        hovered = hovered,
        setVisible = function(self, visible)
            self.bg.Visible = visible
            self.txt.Visible = visible
        end,
        setHover = function(self, hover)
            if self.hovered ~= hover then
                self.hovered = hover
                if hover then
                    self.bg.Color = Color3.fromRGB(70, 130, 180)
                else
                    if self.text:find("ON") then
                        self.bg.Color = Color3.fromRGB(34, 139, 34)
                    elseif self.text:find("OFF") then
                        self.bg.Color = Color3.fromRGB(178, 34, 34)
                    else
                        self.bg.Color = Color3.fromRGB(50, 50, 50)
                    end
                end
            end
        end,
        isMouseOver = function(self, mousePos)
            return mousePos.X >= self.pos.X and mousePos.X <= self.pos.X + self.size.X and
                   mousePos.Y >= self.pos.Y and mousePos.Y <= self.pos.Y + self.size.Y
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

-- إنشاء واجهة المستخدم
UI.menuBox = Drawing.new("Square")
UI.menuBox.Position = menuStartPos
UI.menuBox.Size = Vector2.new(260, 160)
UI.menuBox.Filled = true
UI.menuBox.Color = Color3.fromRGB(20, 20, 20)
UI.menuBox.Transparency = 0.9
UI.menuBox.Visible = false
UI.menuBox.ZIndex = 9

UI.titleText = Drawing.new("Text")
UI.titleText.Position = Vector2.new(menuStartPos.X + 10, menuStartPos.Y + 15)
UI.titleText.Size = 24
UI.titleText.Color = Color3.fromRGB(135, 206, 250)
UI.titleText.Outline = true
UI.titleText.Text = "Rivals Script Menu"
UI.titleText.Visible = false
UI.titleText.ZIndex = 11

UI.espButton = createButton(Vector2.new(menuStartPos.X + 20, menuStartPos.Y + 60), Vector2.new(100, 40), "ESP: OFF")
UI.aimbotButton = createButton(Vector2.new(menuStartPos.X + 140, menuStartPos.Y + 60), Vector2.new(100, 40), "Aimbot: OFF")

local espBoxes = {}

local function updateUI()
    if espEnabled then
        UI.espButton:setText("ESP: ON")
        UI.espButton.bg.Color = Color3.fromRGB(34, 139, 34)
    else
        UI.espButton:setText("ESP: OFF")
        UI.espButton.bg.Color = Color3.fromRGB(178, 34, 34)
    end

    if aimbotEnabled then
        UI.aimbotButton:setText("Aimbot: ON")
        UI.aimbotButton.bg.Color = Color3.fromRGB(34, 139, 34)
    else
        UI.aimbotButton:setText("Aimbot: OFF")
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

-- تحديث موقع القائمة وعناصرها عند السحب
local function updateMenuPosition(newPos)
    UI.menuBox.Position = newPos
    UI.titleText.Position = Vector2.new(newPos.X + 10, newPos.Y + 15)
    UI.espButton:setPosition(Vector2.new(newPos.X + 20, newPos.Y + 60))
    UI.aimbotButton:setPosition(Vector2.new(newPos.X + 140, newPos.Y + 60))
    menuStartPos = newPos
end

-- فتح وإغلاق القائمة بالضغط على Right Shift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setMenuVisible(not menuVisible)
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 and menuVisible then
        local mousePos = UserInputService:GetMouseLocation()

        -- إذا ضغط على شريط العنوان نبدأ السحب
        local titleBarPos = Vector2.new(menuStartPos.X, menuStartPos.Y)
        local titleBarSize = Vector2.new(UI.menuBox.Size.X, 30)

        if mousePos.X >= titleBarPos.X and mousePos.X <= titleBarPos.X + titleBarSize.X and
           mousePos.Y >= titleBarPos.Y and mousePos.Y <= titleBarPos.Y + titleBarSize.Y then
            dragging = true
            dragStartPos = mousePos - menuStartPos
            return
        end

        -- تحقق النقر على أزرار القائمة
        if UI.espButton:isMouseOver(mousePos) then
            espEnabled = not espEnabled
            updateUI()
            print("ESP toggled:", espEnabled and "ON" or "OFF")
            return
        elseif UI.aimbotButton:isMouseOver(mousePos) then
            aimbotEnabled = not aimbotEnabled
            updateUI()
            print("Aimbot toggled:", aimbotEnabled and "ON" or "OFF")
            return
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and menuVisible and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        local newMenuPos = mousePos - dragStartPos
        -- تحديد حدود الشاشة (اختياري، لتمنع خروج القائمة)
        local screenSize = Vector2.new(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y)
        newMenuPos = Vector2.new(
            math.clamp(newMenuPos.X, 0, screenSize.X - UI.menuBox.Size.X),
            math.clamp(newMenuPos.Y, 0, screenSize.Y - UI.menuBox.Size.Y)
        )
        updateMenuPosition(newMenuPos)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- التفعيل والإيقاف باستخدام زر الماوس الأيمن
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
    if character:FindFirstChild("Head") then
        return character.Head.Position
    elseif character:FindFirstChild("HumanoidRootPart") then
        return character.HumanoidRootPart.Position
    else
        return nil
    end
end

RunService.RenderStepped:Connect(function(delta)
    -- تنظيف ESP القديم
    for _, box in pairs(espBoxes) do
        box.Visible = false
        box:Remove()
    end
    espBoxes = {}

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
                camera.CFrame = currentCFrame:Lerp(desiredCFrame, math.clamp(delta * 15, 0, 1))
            end
        end
    end
end)
