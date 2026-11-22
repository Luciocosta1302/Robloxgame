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

local gui = make("ScreenGui", { Name = "DailyUI", ResetOnSpawn = false, IgnoreGuiInset = true, Enabled = false }, playerGui)

local backdrop = make("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.4,
}, gui)

local panel = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(0, 460, 0, 320),
	BackgroundColor3 = Color3.fromRGB(28, 28, 40),
}, backdrop)
make("UICorner", { CornerRadius = UDim.new(0, 16) }, panel)

make("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 10),
	Size = UDim2.new(1, -20, 0, 36),
	BackgroundTransparency = 1,
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.fromRGB(230, 170, 60),
	Text = "🎁 RECOMPENSA DIÁRIA",
	TextScaled = true,
}, panel)

local closeBtn = make("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -8, 0, 8),
	Size = UDim2.new(0, 32, 0, 32),
	BackgroundColor3 = Color3.fromRGB(200, 50, 50),
	Font = Enum.Font.FredokaOne,
	Text = "X",
	TextScaled = true,
	TextColor3 = Color3.new(1, 1, 1),
}, panel)
make("UICorner", { CornerRadius = UDim.new(1, 0) }, closeBtn)

local daysFrame = make("Frame", {
	Position = UDim2.new(0, 12, 0, 56),
	Size = UDim2.new(1, -24, 0, 170),
	BackgroundTransparency = 1,
}, panel)
make("UIGridLayout", {
	CellSize = UDim2.new(0, 58, 0, 80),
	CellPadding = UDim2.new(0, 4, 0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, daysFrame)

local info = make("TextLabel", {
	Position = UDim2.new(0, 12, 1, -92),
	Size = UDim2.new(1, -24, 0, 30),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextColor3 = Color3.new(1, 1, 1),
	Text = "",
	TextScaled = true,
}, panel)

local claim = make("TextButton", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -12),
	Size = UDim2.new(1, -40, 0, 46),
	BackgroundColor3 = Color3.fromRGB(230, 170, 60),
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.new(0, 0, 0),
	Text = "PEGAR",
	TextScaled = true,
	AutoButtonColor = true,
}, panel)
make("UICorner", { CornerRadius = UDim.new(0, 12) }, claim)

local cells: { TextLabel } = {}

local function buildDays(rewards)
	for _, c in cells do
		c:Destroy()
	end
	cells = {}
	for i, amount in rewards do
		local cell = make("TextLabel", {
			Name = "Day" .. i,
			BackgroundColor3 = Color3.fromRGB(44, 44, 60),
			Font = Enum.Font.FredokaOne,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			LayoutOrder = i,
			Text = "Dia " .. i .. "\n+" .. amount,
		}, daysFrame)
		make("UICorner", { CornerRadius = UDim.new(0, 8) }, cell)
		cells[i] = cell
	end
end

local lastRewards: { number }? = nil
local lastStatus

local function formatHMS(seconds: number): string
	local s = math.max(0, math.floor(seconds))
	local h = s // 3600
	local m = (s % 3600) // 60
	return string.format("%02dh %02dm", h, m)
end

local function render(status)
	lastStatus = status
	if not lastRewards or #lastRewards ~= #status.rewards then
		lastRewards = status.rewards
		buildDays(status.rewards)
	end

	for i, cell in cells do
		cell.BackgroundColor3 = if i <= status.streak then Color3.fromRGB(80, 200, 120) else Color3.fromRGB(44, 44, 60)
		cell.TextColor3 = if i <= status.streak then Color3.new(0, 0, 0) else Color3.new(1, 1, 1)
	end

	if status.canClaim then
		info.Text = ("Próximo: Dia %d · +%d moedas"):format(status.nextStreak, status.nextReward)
		claim.Text = ("PEGAR +%d 🪙"):format(status.nextReward)
		claim.AutoButtonColor = true
		claim.BackgroundColor3 = Color3.fromRGB(230, 170, 60)
	else
		info.Text = ("Próximo em %s"):format(formatHMS(status.secondsUntilClaim))
		claim.Text = "VOLTA DEPOIS"
		claim.AutoButtonColor = false
		claim.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	end
end

remotes.DailyStatus.OnClientEvent:Connect(render)

claim.MouseButton1Click:Connect(function()
	if lastStatus and lastStatus.canClaim then
		remotes.DailyClaim:FireServer()
	end
end)

local dailyToggle = hud:WaitForChild("DailyToggle")
dailyToggle.Event:Connect(function()
	gui.Enabled = not gui.Enabled
	if gui.Enabled then
		remotes.DailyRequest:FireServer()
	end
end)
closeBtn.MouseButton1Click:Connect(function()
	gui.Enabled = false
end)

-- Atualiza a cada minuto enquanto o painel estiver aberto
task.spawn(function()
	while true do
		task.wait(30)
		if gui.Enabled and lastStatus and not lastStatus.canClaim then
			lastStatus.secondsUntilClaim -= 30
			render(lastStatus)
		end
	end
end)
