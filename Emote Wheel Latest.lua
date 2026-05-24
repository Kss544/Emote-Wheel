local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Emotes list (example)
local emotes = {
    {Name = "Invincible Wobble", Command = [[execCmd("animation 85446816148276")]]},
    {Name = "Body Phone", Command = [[execCmd("animation 95714033584938")]]},
    {Name = "Bibicaly Angle", Command = [[execCmd("animation 118314972618293")]]},
    {Name = "Spider man gang", Command = [[execCmd("animation 108635834286627")]]},
    {Name = "Basketball head", Command = [[execCmd("animation 128861093061630")]]},
    {Name = "godly aura fly idle", Command = [[execCmd("animation 76361248833307")]]},
    -- Add more emotes here for testing infinite scroll
}

local wheelVisible = false
local emotePlaying = false

-- Colors
local beige = Color3.fromRGB(245, 245, 220) -- beige
local beigeLight = Color3.fromRGB(255, 250, 240) -- lighter beige
local white = Color3.new(1, 1, 1)
local black = Color3.new(0, 0, 0)

-- Wheel parameters
local wheelRadius = 250 -- radius of outer circle
local holeRadius = 90   -- radius of center cutout
local buttonSize = 70
local scrollSpeed = 0.02 -- radians per frame for automatic scroll (can be controlled)

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EmoteWheelGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Background container frame (for layering)
local bgContainer = Instance.new("Frame")
bgContainer.Name = "BackgroundContainer"
bgContainer.AnchorPoint = Vector2.new(0.5, 0.5)
bgContainer.Size = UDim2.new(0, wheelRadius * 2 + 20, 0, wheelRadius * 2 + 20)
bgContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
bgContainer.BackgroundTransparency = 1
bgContainer.Parent = screenGui
bgContainer.Visible = false

-- Outer circle background
local outerCircle = Instance.new("Frame")
outerCircle.Name = "OuterCircle"
outerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
outerCircle.Size = UDim2.new(0, wheelRadius * 2, 0, wheelRadius * 2)
outerCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
outerCircle.BackgroundColor3 = beige
outerCircle.BorderColor3 = white
outerCircle.BorderSizePixel = 3
outerCircle.Parent = bgContainer
outerCircle.ClipsDescendants = true
local outerUICorner = Instance.new("UICorner")
outerUICorner.CornerRadius = UDim.new(1, 0)
outerUICorner.Parent = outerCircle

-- Center cutout circle (simulate hole)
local holeCircle = Instance.new("Frame")
holeCircle.Name = "HoleCircle"
holeCircle.AnchorPoint = Vector2.new(0.5, 0.5)
holeCircle.Size = UDim2.new(0, holeRadius * 2, 0, holeRadius * 2)
holeCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
holeCircle.BackgroundColor3 = Color3.new(1, 1, 1) -- white background to simulate hole
holeCircle.BorderSizePixel = 0
holeCircle.Parent = outerCircle
local holeUICorner = Instance.new("UICorner")
holeUICorner.CornerRadius = UDim.new(1, 0)
holeUICorner.Parent = holeCircle

-- Horizontal invisibility line (transparent frame)
local invisLine = Instance.new("Frame")
invisLine.Name = "InvisibilityLine"
invisLine.AnchorPoint = Vector2.new(0.5, 0.5)
invisLine.Size = UDim2.new(1, 0, 0, 4)
invisLine.Position = UDim2.new(0.5, 0, 0.5, 0)
invisLine.BackgroundColor3 = Color3.new(0, 0, 0)
invisLine.BackgroundTransparency = 0.7
invisLine.BorderSizePixel = 0
invisLine.Parent = bgContainer
invisLine.ZIndex = 105

-- Container for buttons
local buttonsContainer = Instance.new("Frame")
buttonsContainer.Name = "ButtonsContainer"
buttonsContainer.AnchorPoint = Vector2.new(0.5, 0.5)
buttonsContainer.Size = UDim2.new(0, wheelRadius * 2, 0, wheelRadius * 2)
buttonsContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
buttonsContainer.BackgroundTransparency = 1
buttonsContainer.Parent = bgContainer
buttonsContainer.ClipsDescendants = true
buttonsContainer.ZIndex = 110

-- Round corners for buttons
local function roundCorners(guiObject, radius)
    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, radius)
    uicorner.Parent = guiObject
end

-- Create buttons pool (reuse buttons for infinite scroll)
local buttons = {}
local maxVisibleButtons = 8 -- number of buttons visible at once around the wheel

-- Angle offset for scrolling
local angleOffset = 0

-- Create buttons (maxVisibleButtons)
for i = 1, maxVisibleButtons do
    local btn = Instance.new("TextButton")
    btn.Name = "EmoteButton" .. i
    btn.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.BackgroundColor3 = beigeLight
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

-- Current index in emotes list for the first button
local startIndex = 1

-- Update buttons positions and visibility based on angleOffset and startIndex
local function updateButtons()
    local angleStep = (2 * math.pi) / maxVisibleButtons
    local center = Vector2.new(wheelRadius, wheelRadius)
    local invisLineY = wheelRadius -- y position of horizontal invisibility line in buttonsContainer space

    for i, btn in ipairs(buttons) do
        local emoteIndex = ((startIndex + i - 2) % #emotes) + 1
        local emote = emotes[emoteIndex]

        -- Calculate angle for this button
        local angle = angleStep * (i - 1) + angleOffset

        -- Position on circle
        local x = center.X + wheelRadius * math.cos(angle)
        local y = center.Y + wheelRadius * math.sin(angle)
        btn.Position = UDim2.new(0, x, 0, y)

        -- Set text and command
        btn.Text = emote.Name
        btn.Command = emote.Command

        -- Check if button crosses invisibility line (horizontal line at center)
        -- If button's Y is within 10 pixels of invisLineY, hide it and show next button on opposite side
        local distanceToLine = math.abs(y - invisLineY)
        if distanceToLine < (buttonSize / 2) then
            btn.Visible = false
        else
            btn.Visible = true
        end
    end
end

-- Execute command helper
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

-- Button click handler
for _, btn in ipairs(buttons) do
    btn.MouseButton1Click:Connect(function()
        print("Executing command for emote:", btn.Text)
        wheelVisible = false
        bgContainer.Visible = false
        emotePlaying = true
        executeCommand(btn.Command)
    end)
end

-- Show/hide wheel
local keysPressed = {}
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keysPressed[input.KeyCode] = true
        if keysPressed[Enum.KeyCode.P] and keysPressed[Enum.KeyCode.G] then
            wheelVisible = not wheelVisible
            bgContainer.Visible = wheelVisible
            print("Emote wheel toggled:", wheelVisible)
        end

        -- Scroll wheel counter-clockwise with Left and Right arrows
        if wheelVisible then
            if input.KeyCode == Enum.KeyCode.Left then
                angleOffset = angleOffset + 0.1
                updateButtons()
            elseif input.KeyCode == Enum.KeyCode.Right then
                angleOffset = angleOffset - 0.1
                updateButtons()
            end
        end

        -- Refresh animations on movement keys if emote playing
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

-- Mouse wheel scrolling for smoother control
UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if wheelVisible and input.UserInputType == Enum.UserInputType.MouseWheel then
        angleOffset = angleOffset - input.Position.Z * 0.05
        updateButtons()
    end
end)

-- Initial update
updateButtons()
