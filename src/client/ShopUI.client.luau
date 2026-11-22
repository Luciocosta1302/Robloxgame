local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local playerGui = player:WaitForChild("PlayerGui")
local hud = playerGui:WaitForChild("HUD")

local RARITY_COLOR = {
	comum = Color3.fromRGB(200, 200, 200),
	raro = Color3.fromRGB(100, 170, 255),
	["épico"] = Color3.fromRGB(190, 110, 255),
	["lendário"] = Color3.fromRGB(255, 190, 60),
}

local KIND_LABEL = {
	trail = "Trilha",
	potato = "Batata",
	explosion = "Explosão",
	aura = "Aura",
	hat = "Chapéu",
	title = "Título",
	emote = "Emote",
}

local function make(className, props, parent)
	local item = Instance.new(className)
	for k, v in props do
		item[k] = v
	end
	item.Parent = parent
	return item
end

-- ============================================================
-- Painel principal (começa fechado)
-- ============================================================
local gui = make("ScreenGui", { Name = "ShopUI", ResetOnSpawn = false, IgnoreGuiInset = true, Enabled = false }, playerGui)

local backdrop = make("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.4,
}, gui)

local panel = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(0.8, 0, 0.78, 0),
	BackgroundColor3 = Color3.fromRGB(28, 28, 40),
}, backdrop)
make("UICorner", { CornerRadius = UDim.new(0, 18) }, panel)
make("UIPadding", {
	PaddingTop = UDim.new(0, 56),
	PaddingLeft = UDim.new(0, 16),
	PaddingRight = UDim.new(0, 16),
	PaddingBottom = UDim.new(0, 16),
}, panel)

local title = make("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, -44),
	Size = UDim2.new(1, -32, 0, 36),
	BackgroundTransparency = 1,
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.fromRGB(255, 220, 80),
	Text = "🛒 LOJA DE COSMÉTICOS",
	TextScaled = true,
	TextXAlignment = Enum.TextXAlignment.Left,
}, panel)
title.Parent = panel

local closeBtn = make("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -8, 0, -44),
	Size = UDim2.new(0, 36, 0, 36),
	BackgroundColor3 = Color3.fromRGB(200, 50, 50),
	Font = Enum.Font.FredokaOne,
	Text = "X",
	TextScaled = true,
	TextColor3 = Color3.new(1, 1, 1),
	AutoButtonColor = true,
}, panel)
make("UICorner", { CornerRadius = UDim.new(1, 0) }, closeBtn)

local coinsLabel = make("TextLabel", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -52, 0, -42),
	Size = UDim2.new(0, 180, 0, 32),
	BackgroundTransparency = 1,
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.fromRGB(255, 220, 80),
	Text = "🪙 0",
	TextScaled = true,
	TextXAlignment = Enum.TextXAlignment.Right,
}, panel)

-- grid de itens
local scroll = make("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, -8),
	BackgroundTransparency = 1,
	ScrollBarThickness = 8,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, panel)
local grid = make("UIGridLayout", {
	CellSize = UDim2.new(0, 150, 0, 190),
	CellPadding = UDim2.new(0, 10, 0, 10),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, scroll)

-- ============================================================
-- Estado
-- ============================================================
local catalog: { any } = Config.COSMETICS
local cards: { [string]: any } = {}

local function parseOwned(): { [string]: true }
	local out = {}
	local raw = player:GetAttribute("OwnedCosmetics")
	if typeof(raw) == "string" and raw ~= "" then
		for id in raw:gmatch("[^,]+") do
			out[id] = true
		end
	end
	return out
end

local function equippedId(kind: string): string?
	local v = player:GetAttribute("Equipped_" .. kind)
	if type(v) == "string" and v ~= "" then
		return v
	end
	return nil
end

local function getCoins(): number
	local stats = player:FindFirstChild("leaderstats")
	local value = stats and stats:FindFirstChild("Moedas")
	return (value and value.Value) or 0
end

local function refreshCard(item)
	local card = cards[item.id]
	if not card then
		return
	end
	local owned = parseOwned()
	local isOwned = owned[item.id] == true
	local isEquipped = equippedId(item.kind) == item.id

	if isEquipped then
		card.action.Text = "EQUIPADO"
		card.action.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
		card.action.AutoButtonColor = false
	elseif isOwned then
		card.action.Text = "EQUIPAR"
		card.action.BackgroundColor3 = Color3.fromRGB(80, 130, 210)
		card.action.AutoButtonColor = true
	else
		local enough = getCoins() >= item.price
		card.action.Text = "🪙 " .. item.price
		card.action.BackgroundColor3 = if enough then Color3.fromRGB(230, 170, 60) else Color3.fromRGB(100, 100, 100)
		card.action.AutoButtonColor = enough
	end
end

local function refreshAll()
	for _, item in catalog do
		refreshCard(item)
	end
	coinsLabel.Text = "🪙 " .. getCoins()
end

local function makeCard(item)
	local card = make("Frame", {
		Name = item.id,
		BackgroundColor3 = Color3.fromRGB(44, 44, 60),
	}, scroll)
	make("UICorner", { CornerRadius = UDim.new(0, 10) }, card)
	make("UIStroke", {
		Color = RARITY_COLOR[item.rarity] or Color3.new(1, 1, 1),
		Thickness = 2,
		Transparency = 0.3,
	}, card)

	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 6, 0, 6),
		Size = UDim2.new(1, -12, 0, 18),
		Font = Enum.Font.Gotham,
		TextColor3 = RARITY_COLOR[item.rarity] or Color3.new(1, 1, 1),
		Text = (KIND_LABEL[item.kind] or item.kind):upper() .. " · " .. (item.rarity or ""):upper(),
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)

	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 6, 0, 28),
		Size = UDim2.new(1, -12, 0, 42),
		Font = Enum.Font.FredokaOne,
		TextColor3 = Color3.new(1, 1, 1),
		Text = item.name,
		TextScaled = true,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)

	-- Preview simples por categoria
	local preview = make("Frame", {
		Position = UDim2.new(0.5, -32, 0, 76),
		Size = UDim2.new(0, 64, 0, 64),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.5,
	}, card)
	make("UICorner", { CornerRadius = UDim.new(0, 10) }, preview)
	local payload = item.payload or {}
	local previewColor = Color3.new(1, 1, 1)
	if typeof(payload.color) == "Color3" then
		previewColor = payload.color
	elseif typeof(payload.color1) == "Color3" then
		previewColor = payload.color1
	end
	if payload.rainbow then
		local stripe = make("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 220, 120)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 160, 255)),
			}),
		}, preview)
		stripe.Parent = preview
	else
		preview.BackgroundColor3 = previewColor
		preview.BackgroundTransparency = 0.1
	end

	local action = make("TextButton", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -6),
		Size = UDim2.new(1, -12, 0, 36),
		Font = Enum.Font.FredokaOne,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		AutoButtonColor = true,
		Text = "",
	}, card)
	make("UICorner", { CornerRadius = UDim.new(0, 8) }, action)

	action.MouseButton1Click:Connect(function()
		local owned = parseOwned()
		if equippedId(item.kind) == item.id then
			remotes.ShopUnequip:FireServer(item.kind)
			return
		end
		if owned[item.id] then
			remotes.ShopEquip:FireServer(item.id)
		else
			remotes.ShopBuy:FireServer(item.id)
		end
	end)

	cards[item.id] = { frame = card, action = action, item = item }
end

for i, item in catalog do
	item._layout = i
	makeCard(item)
end
refreshAll()

-- ============================================================
-- Reagir a mudanças do servidor (owned/equipped via atributos)
-- ============================================================
player:GetAttributeChangedSignal("OwnedCosmetics"):Connect(refreshAll)
for kind in KIND_LABEL do
	player:GetAttributeChangedSignal("Equipped_" .. kind):Connect(refreshAll)
end

task.spawn(function()
	local stats = player:WaitForChild("leaderstats")
	local value = stats:WaitForChild("Moedas")
	value.Changed:Connect(refreshAll)
end)

-- Toggle do painel via BindableEvent do HUD
local shopToggle = hud:WaitForChild("ShopToggle")
local shopOpened = remotes:FindFirstChild("ShopOpened")
shopToggle.Event:Connect(function()
	gui.Enabled = not gui.Enabled
	if gui.Enabled then
		refreshAll()
		if shopOpened then
			shopOpened:FireServer()
		end
	end
end)
closeBtn.MouseButton1Click:Connect(function()
	gui.Enabled = false
end)
backdrop.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if input.Position.X < panel.AbsolutePosition.X
			or input.Position.X > panel.AbsolutePosition.X + panel.AbsoluteSize.X
			or input.Position.Y < panel.AbsolutePosition.Y
			or input.Position.Y > panel.AbsolutePosition.Y + panel.AbsoluteSize.Y
		then
			gui.Enabled = false
		end
	end
end)

-- O servidor manda o catálogo atualizado em ShopCatalog; ignoramos por enquanto
-- porque já lemos de Config, mas deixamos o hook caso o dono queira forçar
-- atualização em runtime.
remotes.ShopCatalog.OnClientEvent:Connect(function(_newCatalog)
	-- reservado: hot-reload do catálogo
end)
