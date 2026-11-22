-- Modal temporizado que aparece quando o jogador é eliminado. Mostra
-- "REVIVER por R$ XX" com contagem regressiva. O servidor dispara via
-- Remotes.ShowRevivePrompt(player, windowSeconds).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local playerGui = player:WaitForChild("PlayerGui")

local function make(className, props, parent)
	local item = Instance.new(className)
	for k, v in props do
		item[k] = v
	end
	item.Parent = parent
	return item
end

local gui = make("ScreenGui", {
	Name = "ReviveUI",
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
	Size = UDim2.new(0, 360, 0, 220),
	BackgroundColor3 = Color3.fromRGB(28, 28, 40),
}, backdrop)
make("UICorner", { CornerRadius = UDim.new(0, 16) }, panel)
make("UIStroke", { Color = Color3.fromRGB(255, 50, 50), Thickness = 3, Transparency = 0.3 }, panel)

make("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 12),
	Size = UDim2.new(1, -24, 0, 36),
	BackgroundTransparency = 1,
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.fromRGB(255, 80, 80),
	TextScaled = true,
	Text = "VOCÊ EXPLODIU!",
}, panel)

local subtitle = make("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 56),
	Size = UDim2.new(1, -24, 0, 26),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextColor3 = Color3.fromRGB(220, 220, 220),
	TextScaled = true,
	Text = "Volta pra rodada na próxima batata?",
}, panel)

local reviveBtn = make("TextButton", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 94),
	Size = UDim2.new(1, -40, 0, 60),
	BackgroundColor3 = Color3.fromRGB(255, 80, 80),
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.new(1, 1, 1),
	TextScaled = true,
	AutoButtonColor = true,
	Text = "🔁 REVIVER (R$)",
}, panel)
make("UICorner", { CornerRadius = UDim.new(0, 12) }, reviveBtn)

local timer = make("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -12),
	Size = UDim2.new(1, -24, 0, 30),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextColor3 = Color3.fromRGB(200, 200, 200),
	TextScaled = true,
	Text = "",
}, panel)

local closeAt = 0

local function close()
	gui.Enabled = false
end

reviveBtn.MouseButton1Click:Connect(function()
	local prompt = remotes:FindFirstChild("PromptProduct")
	if prompt then
		prompt:FireServer("REVIVE_ROUND")
	end
	-- fecha o modal; se a compra for cancelada no popup do Roblox o
	-- jogador pode abrir de novo tocando outra vez se der tempo
	close()
end)

remotes.ShowRevivePrompt.OnClientEvent:Connect(function(seconds)
	if type(seconds) ~= "number" or seconds <= 0 then
		return
	end
	gui.Enabled = true
	closeAt = os.clock() + seconds
	subtitle.Text = "Volta pra rodada na próxima batata?"
end)

RunService.RenderStepped:Connect(function()
	if not gui.Enabled then
		return
	end
	local remaining = math.max(0, closeAt - os.clock())
	timer.Text = ("Oferta expira em %ds"):format(math.ceil(remaining))
	if remaining <= 0 then
		close()
	end
end)
