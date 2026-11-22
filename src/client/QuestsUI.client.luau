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

-- Botão na sidebar do HUD
local sidebar = hud:WaitForChild("Sidebar")

local questsBtn = make("TextButton", {
	Name = "QuestsBtn",
	Size = UDim2.new(0, 68, 0, 68),
	Text = "🎯\nMISSÃO",
	LayoutOrder = 6,
	BackgroundColor3 = Color3.fromRGB(230, 120, 60),
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.new(1, 1, 1),
	TextScaled = true,
	AutoButtonColor = true,
}, sidebar)
make("UICorner", { CornerRadius = UDim.new(0, 12) }, questsBtn)
make("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 2, Transparency = 0.5 }, questsBtn)

local badge = make("Frame", {
	Name = "Badge",
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -2, 0, 2),
	Size = UDim2.new(0, 14, 0, 14),
	BackgroundColor3 = Color3.fromRGB(255, 50, 50),
	Visible = false,
}, questsBtn)
make("UICorner", { CornerRadius = UDim.new(1, 0) }, badge)

-- Painel modal
local gui = make("ScreenGui", {
	Name = "QuestsUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	Enabled = false,
}, playerGui)

local backdrop = make("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.4,
}, gui)

local panel = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(0, 460, 0, 380),
	BackgroundColor3 = Color3.fromRGB(28, 28, 40),
}, backdrop)
make("UICorner", { CornerRadius = UDim.new(0, 16) }, panel)

make("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 10),
	Size = UDim2.new(1, -20, 0, 34),
	BackgroundTransparency = 1,
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.fromRGB(230, 120, 60),
	Text = "🎯 MISSÕES DO DIA",
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

local list = make("Frame", {
	Position = UDim2.new(0, 14, 0, 54),
	Size = UDim2.new(1, -28, 1, -70),
	BackgroundTransparency = 1,
}, panel)
make("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	Padding = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, list)

local rows: { any } = {}

local function clearRows()
	for _, row in rows do
		row.frame:Destroy()
	end
	rows = {}
end

local function makeRow(index: number)
	local frame = make("Frame", {
		Name = "Quest" .. index,
		LayoutOrder = index,
		Size = UDim2.new(1, 0, 0, 86),
		BackgroundColor3 = Color3.fromRGB(44, 44, 60),
	}, list)
	make("UICorner", { CornerRadius = UDim.new(0, 10) }, frame)

	local label = make("TextLabel", {
		Position = UDim2.new(0, 10, 0, 6),
		Size = UDim2.new(1, -20, 0, 26),
		BackgroundTransparency = 1,
		Font = Enum.Font.FredokaOne,
		TextColor3 = Color3.new(1, 1, 1),
		Text = "",
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, frame)

	local barBg = make("Frame", {
		Position = UDim2.new(0, 10, 0, 36),
		Size = UDim2.new(0.68, -20, 0, 18),
		BackgroundColor3 = Color3.fromRGB(20, 20, 30),
	}, frame)
	make("UICorner", { CornerRadius = UDim.new(0, 8) }, barBg)

	local bar = make("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(80, 220, 120),
	}, barBg)
	make("UICorner", { CornerRadius = UDim.new(0, 8) }, bar)

	local progressText = make("TextLabel", {
		Position = UDim2.new(0, 10, 0, 56),
		Size = UDim2.new(0.68, -20, 0, 24),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, frame)

	local action = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0.3, 0, 0, 56),
		Font = Enum.Font.FredokaOne,
		TextScaled = true,
		AutoButtonColor = true,
	}, frame)
	make("UICorner", { CornerRadius = UDim.new(0, 10) }, action)

	return { frame = frame, label = label, bar = bar, progressText = progressText, action = action }
end

local function render(entries)
	clearRows()
	local anyReady = false
	for i, entry in entries do
		local row = makeRow(i)
		table.insert(rows, row)
		row.label.Text = entry.label
		local pct = math.min(1, entry.progress / entry.target)
		row.bar.Size = UDim2.new(pct, 0, 1, 0)
		row.progressText.Text = ("%d / %d"):format(entry.progress, entry.target)
		if entry.claimed then
			row.action.Text = "PEGO"
			row.action.BackgroundColor3 = Color3.fromRGB(80, 100, 80)
			row.action.TextColor3 = Color3.fromRGB(180, 180, 180)
			row.action.AutoButtonColor = false
		elseif entry.complete then
			row.action.Text = ("+%d 🪙"):format(entry.reward)
			row.action.BackgroundColor3 = Color3.fromRGB(230, 170, 60)
			row.action.TextColor3 = Color3.new(0, 0, 0)
			row.action.AutoButtonColor = true
			anyReady = true
			local captured = entry.key
			row.action.MouseButton1Click:Connect(function()
				remotes.QuestsClaim:FireServer(captured)
			end)
		else
			row.action.Text = ("+%d 🪙"):format(entry.reward)
			row.action.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
			row.action.TextColor3 = Color3.new(1, 1, 1)
			row.action.AutoButtonColor = false
		end
	end
	badge.Visible = anyReady
end

remotes.QuestsStatus.OnClientEvent:Connect(render)

questsBtn.MouseButton1Click:Connect(function()
	gui.Enabled = not gui.Enabled
	if gui.Enabled then
		remotes.QuestsRequest:FireServer()
	end
end)
closeBtn.MouseButton1Click:Connect(function()
	gui.Enabled = false
end)

task.delay(2.5, function()
	remotes.QuestsRequest:FireServer()
end)
