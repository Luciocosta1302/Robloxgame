local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

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

-- ============================================================
-- Botão no HUD: adicionar um 5º botão na sidebar criada pelo HUD.
-- Procura o sidebar existente pra não quebrar se a ordem mudar.
-- ============================================================
local sidebar = hud:WaitForChild("Sidebar")

local codesBtn = make("TextButton", {
	Name = "CodesBtn",
	Size = UDim2.new(0, 68, 0, 68),
	Text = "🎟️\nCÓDIGO",
	LayoutOrder = 5,
	BackgroundColor3 = Color3.fromRGB(80, 180, 80),
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.new(1, 1, 1),
	TextScaled = true,
	AutoButtonColor = true,
}, sidebar)
make("UICorner", { CornerRadius = UDim.new(0, 12) }, codesBtn)
make("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 2, Transparency = 0.5 }, codesBtn)

-- ============================================================
-- Modal
-- ============================================================
local gui = make("ScreenGui", { Name = "CodesUI", ResetOnSpawn = false, IgnoreGuiInset = true, Enabled = false }, playerGui)

local backdrop = make("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.4,
}, gui)

local panel = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(0, 420, 0, 260),
	BackgroundColor3 = Color3.fromRGB(28, 28, 40),
}, backdrop)
make("UICorner", { CornerRadius = UDim.new(0, 16) }, panel)

make("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 12),
	Size = UDim2.new(1, -20, 0, 36),
	BackgroundTransparency = 1,
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.fromRGB(80, 220, 120),
	Text = "🎟️ CÓDIGOS PROMOCIONAIS",
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

local input = make("TextBox", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 70),
	Size = UDim2.new(1, -40, 0, 48),
	BackgroundColor3 = Color3.fromRGB(44, 44, 60),
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.new(1, 1, 1),
	PlaceholderText = "DIGITE O CÓDIGO",
	PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
	Text = "",
	TextScaled = true,
	ClearTextOnFocus = false,
}, panel)
make("UICorner", { CornerRadius = UDim.new(0, 10) }, input)

local submit = make("TextButton", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 132),
	Size = UDim2.new(1, -40, 0, 48),
	BackgroundColor3 = Color3.fromRGB(80, 220, 120),
	Font = Enum.Font.FredokaOne,
	Text = "RESGATAR",
	TextColor3 = Color3.new(0, 0, 0),
	TextScaled = true,
	AutoButtonColor = true,
}, panel)
make("UICorner", { CornerRadius = UDim.new(0, 10) }, submit)

make("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -12),
	Size = UDim2.new(1, -40, 0, 50),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextColor3 = Color3.fromRGB(180, 180, 180),
	Text = "Siga o TikTok/Shorts @batatabomba pra códigos novos.",
	TextScaled = true,
	TextWrapped = true,
}, panel)

-- ============================================================
-- Comportamento
-- ============================================================
local function tryRedeem()
	local code = input.Text
	if type(code) ~= "string" or #code == 0 then
		return
	end
	-- trim básico e corta no limite antes de enviar
	code = code:gsub("^%s+", ""):gsub("%s+$", "")
	if #code > Config.CODE_MAX_LENGTH then
		code = code:sub(1, Config.CODE_MAX_LENGTH)
	end
	remotes.RedeemCode:FireServer(code)
	input.Text = ""
end

submit.MouseButton1Click:Connect(tryRedeem)
input.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		tryRedeem()
	end
end)

local function setOpen(open: boolean)
	gui.Enabled = open
	if open then
		input:CaptureFocus()
	else
		input:ReleaseFocus()
	end
end

codesBtn.MouseButton1Click:Connect(function()
	setOpen(not gui.Enabled)
end)
closeBtn.MouseButton1Click:Connect(function()
	setOpen(false)
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if gui.Enabled and input.KeyCode == Enum.KeyCode.Escape then
		setOpen(false)
	end
end)
