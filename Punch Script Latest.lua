--// Punch GUI (animações aleatórias + GUI preta/vermelha)
--// Funciona em executores (Solara etc.) como LocalScript client-side

------------------------------------------------------------
-- CONFIGURAÇÃO (edite aqui)
------------------------------------------------------------
local CONFIG = {
	DefaultKey = "Q",          -- tecla padrão do soco
	Cooldown = 0.3,            -- tempo mínimo entre socos (segundos)
	AnimationSpeed = 1,        -- velocidade das animações
	StopAfter = 0,             -- para a animação após X segundos (0 = deixa terminar sozinha)

	-- Coloque quantos IDs quiser (só o número ou "rbxassetid://número")
	AnimationIds = {
		"rbxassetid://118002791533481",
		"rbxassetid://113491263286233",
		"rbxassetid://112242378828218",
	},
}

------------------------------------------------------------
-- SERVIÇOS
------------------------------------------------------------
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

------------------------------------------------------------
-- UTILITÁRIOS
------------------------------------------------------------
local function normalizeId(id)
	id = tostring(id)
	if id:find("rbxassetid://") then
		return id
	end
	return "rbxassetid://" .. id:gsub("%D", "")
end

local punchKey = Enum.KeyCode[CONFIG.DefaultKey:upper()] or Enum.KeyCode.Q
local lastPunch = 0
local currentTrack = nil
local loadedCache = {}

local function getAnimator()
	local char = player.Character
	if not char then return nil end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return nil end
	return hum:FindFirstChildOfClass("Animator") or hum
end

local function playRandomAnimation()
	if #CONFIG.AnimationIds == 0 then return end

	local animator = getAnimator()
	if not animator then return end

	local id = normalizeId(CONFIG.AnimationIds[math.random(1, #CONFIG.AnimationIds)])

	local anim = Instance.new("Animation")
	anim.AnimationId = id

	local ok, track = pcall(function()
		return animator:LoadAnimation(anim)
	end)
	if not ok or not track then
		warn("[PunchGUI] Não foi possível carregar a animação: " .. id)
		return
	end

	if currentTrack then
		currentTrack:Stop(0.1)
	end

	currentTrack = track
	track.Priority = Enum.AnimationPriority.Action
	track:Play()
	track:AdjustSpeed(CONFIG.AnimationSpeed)

	if CONFIG.StopAfter > 0 then
		task.delay(CONFIG.StopAfter, function()
			if currentTrack == track then
				track:Stop(0.1)
			end
		end)
	end
end

------------------------------------------------------------
-- GUI
------------------------------------------------------------
local BLACK = Color3.fromRGB(12, 12, 12)
local DARK = Color3.fromRGB(25, 25, 25)
local RED = Color3.fromRGB(200, 20, 20)
local WHITE = Color3.fromRGB(240, 240, 240)

local function getGuiParent()
	if gethui then
		local ok, result = pcall(gethui)
		if ok and result then return result end
	end
	local ok = pcall(function() return CoreGui.Name end)
	if ok then return CoreGui end
	return player:WaitForChild("PlayerGui")
end

local old = getGuiParent():FindFirstChild("PunchGUI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "PunchGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = getGuiParent()

local function addStroke(obj, thickness)
	local s = Instance.new("UIStroke")
	s.Color = RED
	s.Thickness = thickness or 2
	s.Parent = obj
	return s
end

local function addCorner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = obj
end

local function makeDraggable(handle, target)
	local dragging, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- Janela principal
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 260, 0, 120)
main.Position = UDim2.new(0.5, -130, 0.4, 0)
main.BackgroundColor3 = BLACK
main.BorderSizePixel = 0
main.Parent = gui
addCorner(main, 8)
addStroke(main, 2)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = RED
titleBar.BorderSizePixel = 0
titleBar.Parent = main
addCorner(titleBar, 8)

local titleFix = Instance.new("Frame") -- cobre cantos arredondados de baixo
titleFix.Size = UDim2.new(1, 0, 0, 8)
titleFix.Position = UDim2.new(0, 0, 1, -8)
titleFix.BackgroundColor3 = RED
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Punch GUI"
title.TextColor3 = BLACK
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 22)
minBtn.Position = UDim2.new(1, -30, 0, 4)
minBtn.BackgroundColor3 = BLACK
minBtn.Text = "-"
minBtn.TextColor3 = RED
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.AutoButtonColor = true
minBtn.Parent = titleBar
addCorner(minBtn, 4)

-- Linha "Punch Key"
local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(0, 80, 0, 30)
keyLabel.Position = UDim2.new(0, 15, 0, 50)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "Punch Key"
keyLabel.TextColor3 = WHITE
keyLabel.Font = Enum.Font.GothamMedium
keyLabel.TextSize = 14
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.Parent = main

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0, 90, 0, 30)
keyBox.Position = UDim2.new(0, 110, 0, 50)
keyBox.BackgroundColor3 = DARK
keyBox.Text = CONFIG.DefaultKey:upper()
keyBox.PlaceholderText = "tecla"
keyBox.TextColor3 = WHITE
keyBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
keyBox.Font = Enum.Font.GothamBold
keyBox.TextSize = 14
keyBox.ClearTextOnFocus = true
keyBox.Parent = main
addCorner(keyBox, 5)
addStroke(keyBox, 1)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 20)
status.Position = UDim2.new(0, 10, 1, -26)
status.BackgroundTransparency = 1
status.Text = "Tecla atual: " .. punchKey.Name
status.TextColor3 = RED
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.Parent = main

-- Barra minimizada
local bar = Instance.new("Frame")
bar.Name = "MinimizedBar"
bar.Size = UDim2.new(0, 170, 0, 30)
bar.Position = main.Position
bar.BackgroundColor3 = BLACK
bar.BorderSizePixel = 0
bar.Visible = false
bar.Parent = gui
addCorner(bar, 8)
addStroke(bar, 2)

local barTitle = Instance.new("TextLabel")
barTitle.Size = UDim2.new(1, -40, 1, 0)
barTitle.Position = UDim2.new(0, 10, 0, 0)
barTitle.BackgroundTransparency = 1
barTitle.Text = "Punch GUI"
barTitle.TextColor3 = RED
barTitle.Font = Enum.Font.GothamBold
barTitle.TextSize = 14
barTitle.TextXAlignment = Enum.TextXAlignment.Left
barTitle.Parent = bar

local restoreBtn = Instance.new("TextButton")
restoreBtn.Size = UDim2.new(0, 24, 0, 22)
restoreBtn.Position = UDim2.new(1, -30, 0, 4)
restoreBtn.BackgroundColor3 = RED
restoreBtn.Text = "+"
restoreBtn.TextColor3 = BLACK
restoreBtn.Font = Enum.Font.GothamBold
restoreBtn.TextSize = 18
restoreBtn.Parent = bar
addCorner(restoreBtn, 4)

makeDraggable(titleBar, main)
makeDraggable(bar, bar)

minBtn.MouseButton1Click:Connect(function()
	bar.Position = main.Position
	main.Visible = false
	bar.Visible = true
end)

restoreBtn.MouseButton1Click:Connect(function()
	main.Position = bar.Position
	bar.Visible = false
	main.Visible = true
end)

------------------------------------------------------------
-- TECLA DE SOCO
------------------------------------------------------------
keyBox.FocusLost:Connect(function()
	local text = keyBox.Text:gsub("%s", "")
	local newKey = Enum.KeyCode[text:upper()] or Enum.KeyCode[text]
	if newKey then
		punchKey = newKey
		keyBox.Text = newKey.Name
		status.Text = "Tecla atual: " .. newKey.Name
	else
		keyBox.Text = punchKey.Name
		status.Text = "Tecla inválida! Mantida: " .. punchKey.Name
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if UserInputService:GetFocusedTextBox() then return end
	if input.KeyCode == punchKey then
		if tick() - lastPunch < CONFIG.Cooldown then return end
		lastPunch = tick()
		playRandomAnimation()
	end
end)
