local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local playerGui = player:WaitForChild("PlayerGui")
local hud = playerGui:WaitForChild("HUD")

local function make(className, props, parent)
	local item = Instance.new(className)
	for k, v in props do
		item[k] = v
	end
	item.Parent = parent
	return item
end

-- Botão na sidebar
local sidebar = hud:WaitForChild("Sidebar")

local btn = make("TextButton", {
	Name = "RebirthBtn",
	Size = UDim2.new(0, 68, 0, 68),
	Text = "🌟\nREBIRTH",
	LayoutOrder = 7,
	BackgroundColor3 = Color3.fromRGB(200, 70, 200),
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.new(1, 1, 1),
	TextScaled = true,
	AutoButtonColor = true,
}, sidebar)
make("UICorner", { CornerRadius = UDim.new(0, 12) }, btn)
make("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 2, Transparency = 0.5 }, btn)

-- Modal
local gui = make("ScreenGui", {
	Name = "RebirthUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	Enabled = false,
}, playerGui)

local backdrop = make("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.5,
}, gui)

local panel = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(0, 420, 0, 310),
	BackgroundColor3 = Color3.fromRGB(28, 28, 40),
}, backdrop)
make("UICorner", { CornerRadius = UDim.new(0, 16) }, panel)
make("UIStroke", { Color = Color3.fromRGB(200, 70, 200), Thickness = 2, Transparency = 0.3 }, panel)

make("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 10),
	Size = UDim2.new(1, -20, 0, 36),
	BackgroundTransparency = 1,
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.fromRGB(255, 120, 220),
	Text = "🌟 REBIRTH",
	TextScaled = true,
}, panel)

local closeBtn = make("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -10, 0, 10),
	Size = UDim2.new(0, 32, 0, 32),
	BackgroundColor3 = Color3.fromRGB(200, 50, 50),
	Font = Enum.Font.FredokaOne,
	Text = "X",
	TextScaled = true,
	TextColor3 = Color3.new(1, 1, 1),
}, panel)
make("UICorner", { CornerRadius = UDim.new(1, 0) }, closeBtn)

local info = make("TextLabel", {
	Position = UDim2.new(0, 16, 0, 54),
	Size = UDim2.new(1, -32, 0, 140),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextColor3 = Color3.new(1, 1, 1),
	TextWrapped = true,
	TextSize = 18,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "",
}, panel)

local confirmBtn = make("TextButton", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -16),
	Size = UDim2.new(1, -40, 0, 56),
	BackgroundColor3 = Color3.fromRGB(100, 100, 100),
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.new(1, 1, 1),
	TextScaled = true,
	AutoButtonColor = false,
	Text = "CARREGANDO...",
}, panel)
make("UICorner", { CornerRadius = UDim.new(0, 12) }, confirmBtn)

local ready = false
local confirming = false

local function render(status)
	info.Text = (
		"Tem %d vitórias (precisa de %d).\n\n"
		.. "Rebirth atual: %d (+%d%% moedas permanente).\n\n"
		.. "Se der REBIRTH, suas moedas e vitórias VOLTAM A ZERO. Em troca, você ganha +25%% permanente no ganho de moedas (acumulativo). Cosméticos e badges ficam."
	):format(
		status.wins,
		status.required,
		status.rebirths,
		math.floor(status.bonus * 100 + 0.5)
	)
	ready = status.wins >= status.required
	if confirming then
		return
	end
	if ready then
		confirmBtn.Text = "RENASCER AGORA"
		confirmBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 200)
		confirmBtn.AutoButtonColor = true
	else
		confirmBtn.Text = ("Faltam %d vitórias"):format(status.required - status.wins)
		confirmBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
		confirmBtn.AutoButtonColor = false
	end
end

confirmBtn.MouseButton1Click:Connect(function()
	if not ready or confirming then
		return
	end
	if confirmBtn.Text ~= "TEM CERTEZA? TOCA DE NOVO" then
		confirmBtn.Text = "TEM CERTEZA? TOCA DE NOVO"
		confirmBtn.BackgroundColor3 = Color3.fromRGB(230, 70, 70)
		task.delay(5, function()
			if confirmBtn.Text == "TEM CERTEZA? TOCA DE NOVO" then
				confirmBtn.Text = "RENASCER AGORA"
				confirmBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 200)
			end
		end)
		return
	end
	confirming = true
	remotes.Rebirth:FireServer()
	confirmBtn.Text = "..."
	task.delay(2, function()
		confirming = false
	end)
end)

remotes.RebirthStatus.OnClientEvent:Connect(render)

btn.MouseButton1Click:Connect(function()
	gui.Enabled = not gui.Enabled
	if gui.Enabled then
		remotes.RebirthRequest:FireServer()
	end
end)
closeBtn.MouseButton1Click:Connect(function()
	gui.Enabled = false
end)

task.delay(2.5, function()
	remotes.RebirthRequest:FireServer()
end)
