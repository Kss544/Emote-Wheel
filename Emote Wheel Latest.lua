local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Emotes list: each with a name and a full command string to execute
local emotes = {
    {Name = "Invincible Wobble", Command = [[execCmd("animation 85446816148276")]]},
    {Name = "Body Phone", Command = [[execCmd("animation 95714033584938")]]},
    {Name = "Bibicaly Angle", Command = [[execCmd("animation 118314972618293")]]},
 {Name = "Spider man gang", Command = [[execCmd("animation 108635834286627")]]},
{Name = "Basketball head", Command = [[execCmd("animation 128861093061630")]]},
{Name = "godly aura fly idle", Command = [[execCmd("animation 76361248833307")]]},
    -- Add more emotes here with full commands
}

local wheelVisible = false
local emotePlaying = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EmoteWheelGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local wheelFrame = Instance.new("Frame")
wheelFrame.Name = "WheelFrame"
wheelFrame.AnchorPoint = Vector2.new(0.5, 0.5)
wheelFrame.Size = UDim2.new(0, 300, 0, 300)
wheelFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
wheelFrame.BackgroundTransparency = 0.7
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.Visible = false
wheelFrame.Parent = screenGui
wheelFrame.ClipsDescendants = true
wheelFrame.BorderSizePixel = 0
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100
wheelFrame.AutomaticSize = Enum.AutomaticSize.None
wheelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wheelFrame.BackgroundTransparency = 0.3
wheelFrame.BorderSizePixel = 0
wheelFrame.ClipsDescendants = true
wheelFrame.ZIndex = 100

local radius = 120

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

local function createEmoteButtons()
    wheelFrame:ClearAllChildren()
    local count = #emotes
    for i, emote in ipairs(emotes) do
        local angle = (2 * math.pi / count) * (i - 1) - math.pi/2

        local button = Instance.new("TextButton")
        button.Name = emote.Name .. "Button"
        button.Size = UDim2.new(0, 70, 0, 70)
        button.AnchorPoint = Vector2.new(0.5, 0.5)
        button.Position = UDim2.new(0, radius * math.cos(angle) + 150, 0, radius * math.sin(angle) + 150)
        button.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        button.BorderSizePixel = 0
        button.Text = emote.Name
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextScaled = true
        button.AutoLocalize = false
        button.Parent = wheelFrame
        button.ZIndex = 101
        button.BackgroundTransparency = 0
        button.ClipsDescendants = true
        button.BorderSizePixel = 0
        button.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        button.AutoButtonColor = true
        button.Modal = true
        button.TextWrapped = true
        button.TextXAlignment = Enum.TextXAlignment.Center
        button.TextYAlignment = Enum.TextYAlignment.Center
        button.Font = Enum.Font.SourceSans
        button.TextStrokeTransparency = 1
        button.TextStrokeColor3 = Color3.new(0, 0, 0)
        button.TextTransparency = 0
        button.TextScaled = true
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Text = emote.Name
        button.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        button.BorderSizePixel = 0
        button.ClipsDescendants = true
        button.AutoLocalize = false
        button.ZIndex = 101
        button.AnchorPoint = Vector2.new(0.5, 0.5)
        button.Position = UDim2.new(0, radius * math.cos(angle) + 150, 0, radius * math.sin(angle) + 150)
        button.Size = UDim2.new(0, 70, 0, 70)
        button.Parent = wheelFrame
        button.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        button.BorderSizePixel = 0
        button.AutoButtonColor = true
        button.Modal = true
        button.TextWrapped = true
        button.TextXAlignment = Enum.TextXAlignment.Center
        button.TextYAlignment = Enum.TextYAlignment.Center
        button.Font = Enum.Font.SourceSans
        button.TextStrokeTransparency = 1
        button.TextStrokeColor3 = Color3.new(0, 0, 0)
        button.TextTransparency = 0
        button.TextScaled = true
        button.TextColor3 = Color3.new(1, 1, 1)

        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(170, 170, 170)
        end)
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        end)

        button.MouseButton1Click:Connect(function()
            print("Executing command for emote:", emote.Name)
            wheelFrame.Visible = false
            wheelVisible = false
            emotePlaying = true
            executeCommand(emote.Command)
        end)
    end
end

createEmoteButtons()

local keysPressed = {}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keysPressed[input.KeyCode] = true
        if keysPressed[Enum.KeyCode.P] and keysPressed[Enum.KeyCode.G] then
            wheelVisible = not wheelVisible
            wheelFrame.Visible = wheelVisible
            print("Emote wheel toggled:", wheelVisible)
        end

        -- If an emote is playing and user presses W, A, S, or D, refresh animations
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

-- Round corners for wheelFrame and buttons
local function roundCorners(guiObject, radius)
    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, radius)
    uicorner.Parent = guiObject
end

roundCorners(wheelFrame, 20)

for _, child in ipairs(wheelFrame:GetChildren()) do
    if child:IsA("TextButton") then
        roundCorners(child, 12)
    end
end
