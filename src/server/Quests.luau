-- Missões diárias. 3 missões aleatórias por "dia" (reset no mesmo intervalo
-- que o daily reward, 20h). Cada missão compara a stat atual do PlayerData
-- com a baseline salva no momento em que a missão foi sorteada — então
-- "passe 20 vezes" é 20 passes DURANTE a missão, não 20 totais.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local PlayerData = require(script.Parent.PlayerData)

local Quests = {}

local remotes: Folder

local function todayBucket(): number
	-- Bucket de 20h alinhado ao daily reward pra resetar junto
	return math.floor(os.time() / Config.DAILY_WINDOW_MIN)
end

local function allKeys(): { string }
	local keys = {}
	for k in Config.QUESTS do
		table.insert(keys, k)
	end
	return keys
end

local function ensureFreshQuests(player: Player)
	local data = PlayerData.get(player)
	if not data then
		return
	end
	local today = todayBucket()
	if data.questsDay == today and #data.questsPicked > 0 then
		return
	end

	data.questsDay = today
	data.questsPicked = {}
	data.questsBaseline = {}
	data.questsClaimed = {}

	local pool = allKeys()
	local picked = {}
	local target = math.min(Config.QUESTS_PER_DAY, #pool)
	for _ = 1, target do
		if #pool == 0 then
			break
		end
		local idx = math.random(1, #pool)
		local key = pool[idx]
		table.remove(pool, idx)
		table.insert(picked, key)
		local quest = Config.QUESTS[key]
		-- Baseline da stat no momento do sorteio; a missão é o delta.
		data.questsBaseline[key] = tonumber((data :: any)[quest.stat]) or 0
	end
	data.questsPicked = picked
end

local function status(player: Player)
	ensureFreshQuests(player)
	local data = PlayerData.get(player)
	if not data then
		return {}
	end
	local out = {}
	for _, key in data.questsPicked do
		local quest = Config.QUESTS[key]
		if quest then
			local current = tonumber((data :: any)[quest.stat]) or 0
			local baseline = data.questsBaseline[key] or current
			local progress = math.max(0, math.min(current - baseline, quest.target))
			table.insert(out, {
				key = key,
				label = quest.label,
				target = quest.target,
				progress = progress,
				reward = quest.reward,
				claimed = data.questsClaimed[key] == true,
				complete = progress >= quest.target,
			})
		end
	end
	return out
end

local function send(player: Player)
	local list = status(player)
	if remotes and remotes:FindFirstChild("QuestsStatus") then
		remotes.QuestsStatus:FireClient(player, list)
	end
end

-- Para outros módulos pingarem o cliente quando uma stat mudou
function Quests.notify(player: Player)
	send(player)
end

local function claim(player: Player, key: string)
	if type(key) ~= "string" then
		return
	end
	ensureFreshQuests(player)
	local data = PlayerData.get(player)
	if not data then
		return
	end

	local found = false
	for _, picked in data.questsPicked do
		if picked == key then
			found = true
			break
		end
	end
	if not found then
		return
	end
	if data.questsClaimed[key] then
		return
	end

	local quest = Config.QUESTS[key]
	if not quest then
		return
	end
	local current = tonumber((data :: any)[quest.stat]) or 0
	local baseline = data.questsBaseline[key] or current
	if current - baseline < quest.target then
		return
	end

	data.questsClaimed[key] = true
	PlayerData.addCoinsRaw(player, quest.reward)
	if remotes:FindFirstChild("Notify") then
		remotes.Notify:FireClient(player, ("✅ Missão! +%d moedas"):format(quest.reward))
	end
	send(player)
end

function Quests.init(remoteFolder: Folder)
	remotes = remoteFolder

	for _, name in { "QuestsStatus", "QuestsRequest", "QuestsClaim" } do
		if not remotes:FindFirstChild(name) then
			local remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = remotes
		end
	end
	remotes.QuestsRequest.OnServerEvent:Connect(send)
	remotes.QuestsClaim.OnServerEvent:Connect(claim)

	Players.PlayerAdded:Connect(function(player)
		task.delay(1.5, function()
			if player.Parent then
				ensureFreshQuests(player)
				send(player)
			end
		end)
	end)
	for _, player in Players:GetPlayers() do
		task.delay(1.5, function()
			if player.Parent then
				ensureFreshQuests(player)
				send(player)
			end
		end)
	end
end

return Quests
