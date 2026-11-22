local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local SoundPlay = require(Shared:WaitForChild("SoundPlay"))
local Config = require(Shared:WaitForChild("Config"))

local function make(className: string, props, parent: Instance?)
	local item = Instance.new(className)
	for key, value in props do
		item[key] = value
	end
	item.Parent = parent
	return item
end

local function textLabel(props, parent)
	local label = make("TextLabel", {
		BackgroundColor3 = Color3.fromRGB(20, 20, 30),
		BackgroundTransparency = 0.3,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.FredokaOne,
		TextScaled = true,
	}, parent)
	for key, value in props do
		label[key] = value
	end
	make("UICorner", { CornerRadius = UDim.new(0, 12) }, label)
	return label
end

local function textButton(props, parent)
	local btn = make("TextButton", {
		BackgroundColor3 = Color3.fromRGB(45, 45, 60),
		BackgroundTransparency = 0.1,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.FredokaOne,
		TextScaled = true,
		AutoButtonColor = true,
	}, parent)
	for key, value in props do
		btn[key] = value
	end
	make("UICorner", { CornerRadius = UDim.new(0, 12) }, btn)
	make("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 2, Transparency = 0.5 }, btn)
	return btn
end

local gui = make("ScreenGui", { Name = "HUD", ResetOnSpawn = false, IgnoreGuiInset = true }, player:WaitForChild("PlayerGui"))

local status = textLabel({
	Name = "Status",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 10),
	Size = UDim2.new(0.55, 0, 0, 44),
	Text = "",
}, gui)

local coins = textLabel({
	Name = "Coins",
	Position = UDim2.new(0, 10, 0, 64),
	Size = UDim2.new(0, 140, 0, 36),
	TextColor3 = Color3.fromRGB(255, 220, 80),
	Text = "🪙 0",
}, gui)

local warning = textLabel({
	Name = "Warning",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.3, 0),
	Size = UDim2.new(0.7, 0, 0, 70),
	BackgroundColor3 = Color3.fromRGB(200, 30, 30),
	Text = "🥔 A BATATA É SUA! ENCOSTA EM ALGUÉM!",
	Visible = false,
}, gui)

local toast = textLabel({
	Name = "Toast",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 0.82, 0),
	Size = UDim2.new(0.5, 0, 0, 40),
	Text = "",
	Visible = false,
}, gui)

textLabel({
	Name = "Hint",
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 10, 1, -10),
	Size = UDim2.new(0, 220, 0, 30),
	BackgroundTransparency = 0.6,
	Text = "Q / botão = EMPURRA",
}, gui)

local shrinkBadge = textLabel({
	Name = "ShrinkBadge",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 60),
	Size = UDim2.new(0, 230, 0, 30),
	BackgroundColor3 = Color3.fromRGB(180, 30, 30),
	Text = "⚠️ ARENA ENCOLHENDO",
	Visible = false,
}, gui)

-- Barra lateral com botões
local sidebar = make("Frame", {
	Name = "Sidebar",
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -10, 0.5, 0),
	Size = UDim2.new(0, 72, 0, 260),
	BackgroundTransparency = 1,
}, gui)

make("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	Padding = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, sidebar)

local shopBtn = textButton({
	Name = "ShopBtn",
	Size = UDim2.new(0, 68, 0, 68),
	Text = "🛒\nLOJA",
	LayoutOrder = 1,
	BackgroundColor3 = Color3.fromRGB(80, 130, 210),
}, sidebar)

local dailyBtn = textButton({
	Name = "DailyBtn",
	Size = UDim2.new(0, 68, 0, 68),
	Text = "🎁\nDIÁRIO",
	LayoutOrder = 2,
	BackgroundColor3 = Color3.fromRGB(230, 170, 60),
}, sidebar)

local adBtn = textButton({
	Name = "AdBtn",
	Size = UDim2.new(0, 68, 0, 68),
	Text = "🎬\n+50",
	LayoutOrder = 3,
	BackgroundColor3 = Color3.fromRGB(80, 200, 120),
	Visible = false, -- só aparece se o servidor confirmar que tem ads
}, sidebar)

local inviteBtn = textButton({
	Name = "InviteBtn",
	Size = UDim2.new(0, 68, 0, 68),
	Text = "🤝\nCHAMA",
	LayoutOrder = 4,
	BackgroundColor3 = Color3.fromRGB(200, 100, 200),
}, sidebar)

-- Notificação pisca-pisca no botão Diário quando pode resgatar
local dailyBadge = make("Frame", {
	Name = "Badge",
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -2, 0, 2),
	Size = UDim2.new(0, 14, 0, 14),
	BackgroundColor3 = Color3.fromRGB(255, 50, 50),
	Visible = false,
}, dailyBtn)
make("UICorner", { CornerRadius = UDim.new(1, 0) }, dailyBadge)

-- ============================================================
-- Status / warning / coins
-- ============================================================
local function updateStatus()
	status.Text = ReplicatedStorage:GetAttribute("Status") or ""
end

local function updateHolder()
	warning.Visible = ReplicatedStorage:GetAttribute("Holder") == player.UserId
end

ReplicatedStorage:GetAttributeChangedSignal("Status"):Connect(updateStatus)
ReplicatedStorage:GetAttributeChangedSignal("Holder"):Connect(updateHolder)
updateStatus()
updateHolder()

task.spawn(function()
	local stats = player:WaitForChild("leaderstats")
	local value = stats:WaitForChild("Moedas")
	local lastValue = value.Value
	local function refresh()
		coins.Text = "🪙 " .. value.Value
		if value.Value > lastValue then
			SoundPlay.ui("COIN", 0.4)
		end
		lastValue = value.Value
	end
	value.Changed:Connect(refresh)
	refresh()
end)

local toastId = 0
remotes.Notify.OnClientEvent:Connect(function(text: string)
	toastId += 1
	local id = toastId
	toast.Text = text
	toast.Visible = true
	task.delay(2.8, function()
		if id == toastId then
			toast.Visible = false
		end
	end)
end)

RunService.RenderStepped:Connect(function()
	if warning.Visible then
		local pulse = math.abs(math.sin(os.clock() * 6))
		warning.BackgroundTransparency = 0.1 + pulse * 0.4
		warning.Rotation = math.sin(os.clock() * 20) * 2
	end
	-- arena encolhendo: mostra quando o raio atual é menor que o original
	local radius = ReplicatedStorage:GetAttribute("ArenaRadius")
	if type(radius) == "number" and radius < Config.ARENA_RADIUS - 0.1 then
		shrinkBadge.Visible = true
		shrinkBadge.Text = ("⚠️ ARENA: %dm"):format(math.floor(radius))
		local pulse = math.abs(math.sin(os.clock() * 5))
		shrinkBadge.BackgroundTransparency = 0.1 + pulse * 0.3
	else
		shrinkBadge.Visible = false
	end
end)

-- ============================================================
-- Botões: Loja, Diário, Vídeo
-- ============================================================
local shopEvent = Instance.new("BindableEvent")
shopEvent.Name = "ShopToggle"
shopEvent.Parent = gui

local dailyEvent = Instance.new("BindableEvent")
dailyEvent.Name = "DailyToggle"
dailyEvent.Parent = gui

shopBtn.MouseButton1Click:Connect(function()
	shopEvent:Fire()
end)

dailyBtn.MouseButton1Click:Connect(function()
	dailyEvent:Fire()
end)

adBtn.MouseButton1Click:Connect(function()
	remotes.WatchAd:FireServer()
end)

inviteBtn.MouseButton1Click:Connect(function()
	local ok, canSend = pcall(function()
		return Players:CanSendGameInviteAsync(player)
	end)
	if ok and canSend then
		pcall(function()
			Players:PromptGameInvite(player)
		end)
	else
		-- Dispara mesmo assim; o Roblox mostra a UI de convite se possível
		pcall(function()
			Players:PromptGameInvite(player)
		end)
	end
	local requestRemote = remotes:FindFirstChild("RequestInvitePrompt")
	if requestRemote then
		requestRemote:FireServer()
	end
end)

-- Atualiza badge do daily
remotes.DailyStatus.OnClientEvent:Connect(function(info)
	dailyBadge.Visible = info and info.canClaim == true
end)

task.delay(2, function()
	remotes.DailyRequest:FireServer()
end)
