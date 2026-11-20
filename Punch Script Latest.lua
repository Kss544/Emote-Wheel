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
	StopOnMove = true,         -- para a animação quando o personagem começar a andar
	UseInfiniteYield = true,   -- usa os comandos "animation" e "refreshanimations" do Infinite Yield (precisa estar executado)

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

local function findKey(name)
	local ok, key = pcall(function()
		return Enum.KeyCode[name]
	end)
	if ok then return key end
	ok, key = pcall(function()
		return Enum.KeyCode[name:upper()]
	end)
	if ok then return key end
	return nil
end

local punchKey = findKey(CONFIG.DefaultKey) or Enum.KeyCode.Q
local lastPunch = 0
local currentTrack = nil

local function getAnimator()
	local char = player.Character
	if not char then return nil end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return nil end
	return hum:FindFirstChildOfClass("Animator") or hum
end

local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local RunService = game:GetService("RunService")

local hashCache = {}
local moveConn = nil
local iyPlaying = false
local playCounter = 0

local function numericId(id)
	return (tostring(id):gsub("%D", ""))
end

------------------------------------------------------------
-- INFINITE YIELD
------------------------------------------------------------
local function getExecCmd()
	local f = rawget(_G, "execCmd")
	if type(f) == "function" then return f end
	if getgenv then
		local ok, env = pcall(getgenv)
		if ok and type(env.execCmd) == "function" then return env.execCmd end
	end
	if type(execCmd) == "function" then return execCmd end
	return nil
end

local function runIY(cmd)
	local f = getExecCmd()
	if not f then return false end
	local ok, err = pcall(f, cmd)
	if not ok then
		warn("[PunchGUI] Erro no comando do Infinite Yield: " .. tostring(err))
	end
	return ok
end

------------------------------------------------------------
-- MÉTODO DE RESERVA (sem Infinite Yield)
------------------------------------------------------------
local function loadViaKeyframes(animator, id)
	local ok, track = pcall(function()
		local hash = hashCache[id]
		if not hash then
			local objs = game:GetObjects("rbxassetid://" .. id)
			local ks = objs and objs[1]
			if not ks or not ks:IsA("KeyframeSequence") then
				error("não é KeyframeSequence")
			end
			hash = KeyframeSequenceProvider:RegisterKeyframeSequence(ks)
			hashCache[id] = hash
		end
		local anim = Instance.new("Animation")
		anim.AnimationId = hash
		return animator:LoadAnimation(anim)
	end)
	if ok then return track end
	return nil
end

local function loadNormal(animator, id)
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. id
	local ok, track = pcall(function()
		return animator:LoadAnimation(anim)
	end)
	if ok then return track end
	return nil
end

------------------------------------------------------------
-- PARAR / TOCAR
------------------------------------------------------------
local function stopCurrent()
	if moveConn then
		moveConn:Disconnect()
		moveConn = nil
	end
	if iyPlaying then
		iyPlaying = false
		runIY("refreshanimations")
	end
	if currentTrack then
		currentTrack:Stop(0.1)
		currentTrack = nil
	end
end

local function playRandomAnimation()
	if #CONFIG.AnimationIds == 0 then return end

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	local id = numericId(CONFIG.AnimationIds[math.random(1, #CONFIG.AnimationIds)])

	stopCurrent()
	playCounter += 1
	local myPlay = playCounter

	local started = false

	-- 1) Infinite Yield: comando "animation ID"
	if CONFIG.UseInfiniteYield then
		if getExecCmd() then
			started = runIY("animation " .. id)
			runIY("walkfling")
			iyPlaying = started
		else
			warn("[PunchGUI] Infinite Yield não encontrado (execute-o antes). Usando método próprio.")
		end
	end

	-- 2) Reserva: carregamento próprio
	if not started then
		local animator = getAnimator()
		if not animator then return end
		local track = loadViaKeyframes(animator, id) or loadNormal(animator, id)
		if not track then
			warn("[PunchGUI] Não foi possível carregar a animação: " .. id)
			return
		end
		currentTrack = track
		track.Priority = Enum.AnimationPriority.Action
		track:Play()
		track:AdjustSpeed(CONFIG.AnimationSpeed)
		track.Stopped:Connect(function()
			if currentTrack == track and myPlay == playCounter then
				stopCurrent()
			end
		end)
	end

	if CONFIG.StopAfter > 0 then
		task.delay(CONFIG.StopAfter, function()
			if myPlay == playCounter then
				stopCurrent()
			end
		end)
	end

	if CONFIG.StopOnMove then
		-- só para quando começar a andar (se já estava andando, espera parar antes)
		local armed = false
		moveConn = RunService.Heartbeat:Connect(function()
			if myPlay ~= playCounter then return end
			local moving = hum.MoveDirection.Magnitude > 0
			if not moving then
				armed = true
			elseif armed then
				stopCurrent()
				runIY("unwalkfling")
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
	local newKey = findKey(text)
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
