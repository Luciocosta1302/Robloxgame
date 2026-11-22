local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local PlayerData = require(script.Parent.PlayerData)

local DailyReward = {}

local remotes: Folder

local function status(player: Player)
	local data = PlayerData.get(player)
	if not data then
		return nil
	end
	local now = os.time()
	local elapsed = now - data.lastDailyClaim
	local canClaim = data.lastDailyClaim == 0 or elapsed >= Config.DAILY_WINDOW_MIN
	local nextStreak
	if data.lastDailyClaim == 0 or elapsed > Config.DAILY_WINDOW_MAX then
		nextStreak = 1
	else
		nextStreak = data.dailyStreak + (if canClaim then 1 else 0)
	end
	local rewards = Config.DAILY_REWARDS
	local index = ((nextStreak - 1) % #rewards) + 1
	return {
		canClaim = canClaim,
		streak = data.dailyStreak,
		nextStreak = nextStreak,
		nextReward = rewards[index],
		secondsUntilClaim = if canClaim then 0 else Config.DAILY_WINDOW_MIN - elapsed,
		rewards = rewards,
	}
end

local function send(player: Player)
	local s = status(player)
	if s then
		remotes.DailyStatus:FireClient(player, s)
	end
end

local function claim(player: Player)
	local ok, streak, reward = PlayerData.tryClaimDaily(player)
	if ok then
		remotes.Notify:FireClient(player, ("🎁 Dia %d: +%d moedas!"):format(streak, reward))
	else
		remotes.Notify:FireClient(player, "Volte em algumas horas para o próximo bônus.")
	end
	send(player)
end

function DailyReward.init(remoteFolder: Folder)
	remotes = remoteFolder

	for _, name in { "DailyClaim", "DailyStatus", "DailyRequest" } do
		if not remotes:FindFirstChild(name) then
			local remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = remotes
		end
	end

	remotes.DailyClaim.OnServerEvent:Connect(claim)
	remotes.DailyRequest.OnServerEvent:Connect(send)

	Players.PlayerAdded:Connect(function(player)
		task.delay(1.5, function()
			if player.Parent then
				send(player)
			end
		end)
	end)
	for _, player in Players:GetPlayers() do
		task.delay(1.5, function()
			if player.Parent then
				send(player)
			end
		end)
	end
end

return DailyReward
