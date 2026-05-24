local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local emotes = {
    {Name = "Wave", Command = [[execCmd("animation 85446816148276")]]},
    {Name = "Fly", Command = [[execCmd("fly")]]},
    {Name = "Dance", Command = [[execCmd("animation 1234567890")]]},
    {Name = "Laugh", Command = [[execCmd("animation 11223344")]]},
    {Name = "Sit", Command = [[execCmd("animation 56789012")]]},
    {Name = "Cheer", Command = [[execCmd("animation 34567890")]]},
    {Name = "Point", Command = [[execCmd("animation 98765432")]]},
    {Name = "Clap", Command = [[execCmd("animation 19283746")]]},
}

local wheelVisible = false
local emotePlaying = false

local backgroundColor = Color3.fromRGB(130, 102, 57)
local buttonColor = Color3.fromRGB(194, 153, 89)
local black = Color3.new(0, 0, 0)
local white = Color3.new(1, 1, 1)

local wheelRadius = 250
local holeRadius = 90
local buttonSize = 70
local maxVisibleButtons = 8

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EmoteWheelGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local bgContainer = Instance.new("Frame")
bgContainer.Name = "BackgroundContainer"
bgContainer.AnchorPoint = Vector2.new(0.5, 0.5)
bgContainer.Size = UDim2.new(0, wheelRadius * 2 + 20, 0, wheelRadius * 2 + 20)
bgContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
bgContainer.BackgroundTransparency = 1
bgContainer.Parent = screenGui
bgContainer.Visible = false

local outerCircle = Instance.new("Frame")
outerCircle.Name = "OuterCircle"
outerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
outerCircle.Size = UDim2.new(0, wheelRadius * 2 + 6, 0, wheelRadius * 2 + 6)
outerCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
outerCircle.BackgroundColor3 = black
outerCircle.BorderSizePixel = 0
outerCircle.Parent = bgContainer
local outerUICorner = Instance.new("UICorner")
outerUICorner.CornerRadius = UDim.new(1, 0)
outerUICorner.Parent = outerCircle

local innerCircle = Instance.new("Frame")
innerCircle.Name = "InnerCircle"
innerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
innerCircle.Size = UDim2.new(0, wheelRadius * 2, 0, wheelRadius * 2)
innerCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
innerCircle.BackgroundColor3 = backgroundColor
innerCircle.BorderSizePixel = 0
innerCircle.Parent = outerCircle
local innerUICorner = Instance.new("UICorner")
innerUICorner.CornerRadius = UDim.new(1, 0)
innerUICorner.Parent = innerCircle

local holeCircle = Instance.new("Frame")
holeCircle.Name = "HoleCircle"
holeCircle.AnchorPoint = Vector2.new(0.5, 0.5)
holeCircle.Size = UDim2.new(0, holeRadius * 2, 0, holeRadius * 2)
holeCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
holeCircle.BackgroundTransparency = 1
holeCircle.BorderSizePixel = 0
holeCircle.Parent = innerCircle
local holeUICorner = Instance.new("UICorner")
holeUICorner.CornerRadius = UDim.new(1, 0)
holeUICorner.Parent = holeCircle

local invisLine = Instance.new("Frame")
invisLine.Name = "InvisibilityLine"
invisLine.AnchorPoint = Vector2.new(0.5, 0.5)
invisLine.Size = UDim2.new(1, 0, 0, 4)
invisLine.Position = UDim2.new(0.5, 0, 0.5, 0)
invisLine.BackgroundColor3 = black
invisLine.BackgroundTransparency = 0.7
invisLine.BorderSizePixel = 0
invisLine.Parent = bgContainer
invisLine.ZIndex = 105

local buttonsContainer = Instance.new("Frame")
buttonsContainer.Name = "ButtonsContainer"
buttonsContainer.AnchorPoint = Vector2.new(0.5, 0.5)
buttonsContainer.Size = UDim2.new(0, wheelRadius * 2, 0, wheelRadius * 2)
buttonsContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
buttonsContainer.BackgroundTransparency = 1
buttonsContainer.Parent = bgContainer
buttonsContainer.ClipsDescendants = true
buttonsContainer.ZIndex = 110

local function roundCorners(guiObject, radius)
    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, radius)
    uicorner.Parent = guiObject
end

local buttons = {}

for i = 1, maxVisibleButtons do
    local btn = Instance.new("TextButton")
    btn.Name = "EmoteButton" .. i
    btn.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.BackgroundColor3 = buttonColor
    btn.BorderColor3 = black
    btn.BorderSizePixel = 2
    btn.TextColor3 = black
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSans
    btn.TextStrokeColor3 = white
    btn.TextStrokeTransparency = 0
    btn.Parent = buttonsContainer
    btn.ZIndex = 120
    roundCorners(btn, 12)
    buttons[i] = btn
end

local startIndex = 1
local angleOffset = 0

local function executeCommand(commandString)
    local func, err = loadstring(commandString)
    if func then
        local success, execErr = pcall(func)
        if not success then
            warn("Failed to execute command:", execErr)
        end
    else
        warn("Failed to load command string:", err)
    end
end

local function updateButtons()
    local angleStep = (2 * math.pi) / maxVisibleButtons
    local center = Vector2.new(wheelRadius, wheelRadius)
    local invisLineY = wheelRadius

    for i, btn in ipairs(buttons) do
        local emoteIndex = ((startIndex + i - 2) % #emotes) + 1
        local emote = emotes[emoteIndex]

        local angle = angleStep * (i - 1) + angleOffset

        local x = center.X + wheelRadius * math.cos(angle)
        local y = center.Y + wheelRadius * math.sin(angle)
        btn.Position = UDim2.new(0, x, 0, y)

        btn.Text = emote.Name
        btn.Command = emote.Command

        local distanceToLine = y - invisLineY
        -- Ocultar botón si cruza la línea horizontal (solo scroll antihorario)
        if distanceToLine > -buttonSize / 2 then
            btn.Visible = false
        else
            btn.Visible = true
        end
    end
end

for _, btn in ipairs(buttons) do
    btn.MouseButton1Click:Connect(function()
        print("Executing command for emote:", btn.Text)
        wheelVisible = false
        bgContainer.Visible = false
        emotePlaying = true
        executeCommand(btn.Command)
    end)
end

local keysPressed = {}

-- Bloquear zoom de cámara mientras la rueda está abierta
local function blockCameraZoom(actionName, inputState, inputObject)
    if wheelVisible then
        return Enum.ContextActionResult.Sink
    else
        return Enum.ContextActionResult.Pass
    end
end

ContextActionService:BindAction("BlockCameraZoom", blockCameraZoom, false, Enum.UserInputType.MouseWheel)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keysPressed[input.KeyCode] = true
        if keysPressed[Enum.KeyCode.P] and keysPressed[Enum.KeyCode.G] then
            wheelVisible = not wheelVisible
            bgContainer.Visible = wheelVisible
            print("Emote wheel toggled:", wheelVisible)
        end

        if wheelVisible then
            -- Solo scroll antihorario (incrementar ángulo)
            if input.KeyCode == Enum.KeyCode.Left then
                angleOffset = angleOffset + 0.1
                updateButtons()
            end
        end

        if emotePlaying and (input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D) then
            print("Movement key pressed, refreshing animations")
            executeCommand([[execCmd("refreshanimations")]])
            emotePlaying = false
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keysPressed[input.KeyCode] = false
    end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if wheelVisible and input.UserInputType == Enum.UserInputType.MouseWheel then
        -- Solo scroll antihorario (solo decremento negativo)
        if input.Position.Z < 0 then
            angleOffset = angleOffset + 0.05
            updateButtons()
        end
    end
end)

updateButtons()
