local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local PlayerData = {}

local store
pcall(function()
	store = DataStoreService:GetDataStore("BatataQuente_v2")
end)

type Data = {
	coins: number,
	wins: number,
	cosmetics: { [string]: true },
	equipped: { [string]: string? },
	dailyStreak: number,
	lastDailyClaim: number,
	processedReceipts: { [string]: number },
	lastRewardedAd: number,
	welcomeGranted: boolean,
	referrals: { [string]: true },
	potatoPasses: number,
	successfulDashes: number,
	roundsSurvived: number,
	explodes: number,
	badgesAwarded: { [string]: true },
	codesClaimed: { [string]: true },
}

local cache: { [Player]: Data } = {}
local vipCache: { [Player]: boolean } = {}
local coinsListeners: { (player: Player, coins: number) -> () } = {}
local dataListeners: { (player: Player, data: Data) -> () } = {}

local function defaults(): Data
	return {
		coins = 0,
		wins = 0,
		cosmetics = {},
		equipped = {},
		dailyStreak = 0,
		lastDailyClaim = 0,
		processedReceipts = {},
		lastRewardedAd = 0,
		welcomeGranted = false,
		referrals = {},
		potatoPasses = 0,
		successfulDashes = 0,
		roundsSurvived = 0,
		explodes = 0,
		badgesAwarded = {},
		codesClaimed = {},
	}
end

local function merge(saved: any): Data
	local data = defaults()
	if type(saved) ~= "table" then
		return data
	end
	data.coins = tonumber(saved.coins) or 0
	data.wins = tonumber(saved.wins) or 0
	if type(saved.cosmetics) == "table" then
		for id in saved.cosmetics do
			if type(id) == "string" then
				data.cosmetics[id] = true
			end
		end
	end
	if type(saved.equipped) == "table" then
		for kind, id in saved.equipped do
			if type(kind) == "string" and (type(id) == "string" or id == nil) then
				data.equipped[kind] = id
			end
		end
	end
	data.dailyStreak = tonumber(saved.dailyStreak) or 0
	data.lastDailyClaim = tonumber(saved.lastDailyClaim) or 0
	if type(saved.processedReceipts) == "table" then
		-- compactamos: só os últimos 128 ids para o DataStore não estourar
		local pr = {}
		local entries = {}
		for k, v in saved.processedReceipts do
			if type(k) == "string" and type(v) == "number" then
				table.insert(entries, { key = k, time = v })
			end
		end
		table.sort(entries, function(a, b)
			return a.time > b.time
		end)
		for i = 1, math.min(#entries, 128) do
			pr[entries[i].key] = entries[i].time
		end
		data.processedReceipts = pr
	end
	data.lastRewardedAd = tonumber(saved.lastRewardedAd) or 0
	data.welcomeGranted = saved.welcomeGranted == true
	if type(saved.referrals) == "table" then
		for k in saved.referrals do
			if type(k) == "string" then
				data.referrals[k] = true
			end
		end
	end
	data.potatoPasses = tonumber(saved.potatoPasses) or 0
	data.successfulDashes = tonumber(saved.successfulDashes) or 0
	data.roundsSurvived = tonumber(saved.roundsSurvived) or 0
	data.explodes = tonumber(saved.explodes) or 0
	if type(saved.badgesAwarded) == "table" then
		for k in saved.badgesAwarded do
			if type(k) == "string" then
				data.badgesAwarded[k] = true
			end
		end
	end
	if type(saved.codesClaimed) == "table" then
		for k in saved.codesClaimed do
			if type(k) == "string" then
				data.codesClaimed[k] = true
			end
		end
	end
	return data
end

local function fireCoins(player: Player)
	local data = cache[player]
	if not data then
		return
	end
	for _, cb in coinsListeners do
		task.spawn(cb, player, data.coins)
	end
end

local function fireData(player: Player)
	local data = cache[player]
	if not data then
		return
	end
	for _, cb in dataListeners do
		task.spawn(cb, player, data)
	end
end

local function setupLeaderstats(player: Player, data: Data)
	local existing = player:FindFirstChild("leaderstats")
	if existing then
		existing:Destroy()
	end

	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"

	local coins = Instance.new("IntValue")
	coins.Name = "Moedas"
	coins.Value = data.coins
	coins.Parent = stats

	local wins = Instance.new("IntValue")
	wins.Name = "Vitórias"
	wins.Value = data.wins
	wins.Parent = stats

	stats.Parent = player
end

local function load(player: Player)
	local saved
	if store then
		local ok, result = pcall(function()
			return store:GetAsync("p_" .. player.UserId)
		end)
		if ok then
			saved = result
		end
	end
	local data = merge(saved)
	cache[player] = data
	setupLeaderstats(player, data)
	fireCoins(player)
	fireData(player)
end

local function save(player: Player)
	local data = cache[player]
	if not data or not store then
		return
	end
	-- UpdateAsync evita perder atualizações concorrentes
	pcall(function()
		store:UpdateAsync("p_" .. player.UserId, function(old)
			-- sempre sobrescrevemos: o cache é a fonte da verdade da sessão
			return data
		end)
	end)
end

function PlayerData.get(player: Player): Data?
	return cache[player]
end

function PlayerData.setVIP(player: Player, has: boolean)
	vipCache[player] = has
end

function PlayerData.hasVIP(player: Player): boolean
	return vipCache[player] == true
end

local function syncLeaderstatCoins(player: Player)
	local data = cache[player]
	local stats = player:FindFirstChild("leaderstats")
	local value = stats and stats:FindFirstChild("Moedas")
	if data and value then
		value.Value = data.coins
	end
end

function PlayerData.addCoinsRaw(player: Player, amount: number)
	local data = cache[player]
	if not data then
		return
	end
	data.coins += amount
	if data.coins < 0 then
		data.coins = 0
	end
	syncLeaderstatCoins(player)
	fireCoins(player)
end

-- Aplica multiplicador VIP para ganhos de gameplay (não para compras na loja).
function PlayerData.addCoins(player: Player, amount: number)
	if amount > 0 and vipCache[player] then
		amount = math.floor(amount * Config.VIP_COIN_MULTIPLIER + 0.5)
	end
	PlayerData.addCoinsRaw(player, amount)
end

function PlayerData.spendCoins(player: Player, amount: number): boolean
	local data = cache[player]
	if not data or data.coins < amount or amount < 0 then
		return false
	end
	data.coins -= amount
	syncLeaderstatCoins(player)
	fireCoins(player)
	return true
end

function PlayerData.addWin(player: Player)
	local data = cache[player]
	if not data then
		return
	end
	data.wins += 1
	local stats = player:FindFirstChild("leaderstats")
	local value = stats and stats:FindFirstChild("Vitórias")
	if value then
		value.Value = data.wins
	end
end

function PlayerData.ownsCosmetic(player: Player, id: string): boolean
	local data = cache[player]
	return data ~= nil and data.cosmetics[id] == true
end

function PlayerData.grantCosmetic(player: Player, id: string)
	local data = cache[player]
	if not data then
		return
	end
	data.cosmetics[id] = true
	fireData(player)
end

function PlayerData.equipCosmetic(player: Player, kind: string, id: string?)
	local data = cache[player]
	if not data then
		return
	end
	if id ~= nil and not data.cosmetics[id] then
		return
	end
	data.equipped[kind] = id
	fireData(player)
end

function PlayerData.getEquipped(player: Player): { [string]: string? }
	local data = cache[player]
	return if data then data.equipped else {}
end

function PlayerData.wasReceiptProcessed(player: Player, receiptId: string): boolean
	local data = cache[player]
	return data ~= nil and data.processedReceipts[receiptId] ~= nil
end

function PlayerData.markReceiptProcessed(player: Player, receiptId: string)
	local data = cache[player]
	if not data then
		return
	end
	data.processedReceipts[receiptId] = os.time()
end

function PlayerData.incStat(player: Player, key: string, amount: number?): number?
	local data = cache[player]
	if not data then
		return nil
	end
	local inc = amount or 1
	local current = (data :: any)[key]
	if type(current) ~= "number" then
		return nil
	end
	(data :: any)[key] = current + inc
	return (data :: any)[key]
end

function PlayerData.hasBadge(player: Player, key: string): boolean
	local data = cache[player]
	return data ~= nil and data.badgesAwarded[key] == true
end

function PlayerData.markBadge(player: Player, key: string)
	local data = cache[player]
	if not data then
		return
	end
	data.badgesAwarded[key] = true
end

function PlayerData.hasCode(player: Player, code: string): boolean
	local data = cache[player]
	return data ~= nil and data.codesClaimed[code] == true
end

function PlayerData.markCode(player: Player, code: string)
	local data = cache[player]
	if not data then
		return
	end
	data.codesClaimed[code] = true
end

-- Entrega o bônus de boas-vindas uma única vez por conta (dica §2 do devlog BR).
-- Retorna true se concedeu agora, false se já tinha concedido antes.
function PlayerData.tryGrantWelcome(player: Player): boolean
	local data = cache[player]
	if not data or data.welcomeGranted then
		return false
	end
	data.welcomeGranted = true
	data.coins += Config.WELCOME_COINS
	if Config.WELCOME_COSMETIC and Config.WELCOME_COSMETIC ~= "" then
		data.cosmetics[Config.WELCOME_COSMETIC] = true
	end
	syncLeaderstatCoins(player)
	fireCoins(player)
	fireData(player)
	return true
end

function PlayerData.tryClaimDaily(player: Player): (boolean, number, number)
	local data = cache[player]
	if not data then
		return false, 0, 0
	end
	local now = os.time()
	local elapsed = now - data.lastDailyClaim
	if data.lastDailyClaim ~= 0 and elapsed < Config.DAILY_WINDOW_MIN then
		return false, data.dailyStreak, Config.DAILY_WINDOW_MIN - elapsed
	end

	if data.lastDailyClaim == 0 or elapsed > Config.DAILY_WINDOW_MAX then
		data.dailyStreak = 1
	else
		data.dailyStreak += 1
	end
	data.lastDailyClaim = now

	local rewards = Config.DAILY_REWARDS
	local index = ((data.dailyStreak - 1) % #rewards) + 1
	local reward = rewards[index]
	PlayerData.addCoinsRaw(player, reward)
	fireData(player)
	return true, data.dailyStreak, reward
end

function PlayerData.tryClaimRewardedAd(player: Player): (boolean, number)
	local data = cache[player]
	if not data then
		return false, 0
	end
	local now = os.time()
	if now - data.lastRewardedAd < Config.REWARDED_AD_COOLDOWN then
		return false, Config.REWARDED_AD_COOLDOWN - (now - data.lastRewardedAd)
	end
	data.lastRewardedAd = now
	PlayerData.addCoinsRaw(player, Config.REWARDED_AD_COINS)
	fireData(player)
	return true, Config.REWARDED_AD_COINS
end

function PlayerData.onCoinsChanged(cb: (player: Player, coins: number) -> ())
	table.insert(coinsListeners, cb)
end

function PlayerData.onDataChanged(cb: (player: Player, data: Data) -> ())
	table.insert(dataListeners, cb)
end

function PlayerData.init()
	Players.PlayerAdded:Connect(load)
	for _, player in Players:GetPlayers() do
		task.spawn(load, player)
	end

	Players.PlayerRemoving:Connect(function(player)
		save(player)
		cache[player] = nil
		vipCache[player] = nil
	end)

	game:BindToClose(function()
		for _, player in Players:GetPlayers() do
			save(player)
		end
	end)

	-- Autosave periódico para não perder progresso em crash de servidor
	task.spawn(function()
		while true do
			task.wait(60)
			for player in cache do
				save(player)
			end
		end
	end)
end

return PlayerData
