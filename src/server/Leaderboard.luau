-- Leaderboard global de vitórias. OrderedDataStore separado dos dados do
-- jogador porque o OrderedDataStore tem API diferente (SetAsync + chave
-- numérica) e queremos permitir reset sem apagar moedas/cosméticos.
-- A UI do mural lê de ReplicatedStorage.LeaderboardTop (um Folder com
-- IntValues/StringValues por posição) — assim replica sozinho.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local Leaderboard = {}

local store
pcall(function()
	store = DataStoreService:GetOrderedDataStore("BatataWins_v1")
end)

-- Cache de nome por userId pra não bater GetNameFromUserIdAsync toda hora
local nameCache: { [number]: string } = {}
local replicatedFolder: Folder
local muralList: Instance? = nil

local function ensureFolder()
	if replicatedFolder and replicatedFolder.Parent then
		return
	end
	local existing = ReplicatedStorage:FindFirstChild("LeaderboardTop")
	if existing then
		existing:Destroy()
	end
	replicatedFolder = Instance.new("Folder")
	replicatedFolder.Name = "LeaderboardTop"
	replicatedFolder.Parent = ReplicatedStorage
end

local function resolveName(userId: number): string
	if nameCache[userId] then
		return nameCache[userId]
	end
	-- jogador online = resolução imediata
	local online = Players:GetPlayerByUserId(userId)
	if online then
		nameCache[userId] = online.DisplayName
		return online.DisplayName
	end
	local ok, name = pcall(function()
		return Players:GetNameFromUserIdAsync(userId)
	end)
	if ok and type(name) == "string" then
		nameCache[userId] = name
		return name
	end
	return "Jogador #" .. userId
end

local function writeEntryToFolder(index: number, entry)
	local row = replicatedFolder:FindFirstChild("Row" .. index)
	if not row then
		row = Instance.new("Folder")
		row.Name = "Row" .. index
		row.Parent = replicatedFolder

		local name = Instance.new("StringValue")
		name.Name = "Name"
		name.Parent = row

		local wins = Instance.new("IntValue")
		wins.Name = "Wins"
		wins.Parent = row

		local userId = Instance.new("IntValue")
		userId.Name = "UserId"
		userId.Parent = row
	end
	if entry then
		row:FindFirstChild("Name").Value = entry.name
		row:FindFirstChild("Wins").Value = entry.wins
		row:FindFirstChild("UserId").Value = entry.userId
	else
		row:FindFirstChild("Name").Value = ""
		row:FindFirstChild("Wins").Value = 0
		row:FindFirstChild("UserId").Value = 0
	end
end

local function fetchTop()
	if not store then
		return
	end
	local ok, pages = pcall(function()
		return store:GetSortedAsync(false, Config.LEADERBOARD_SIZE)
	end)
	if not ok or not pages then
		return
	end
	local okPage, top = pcall(function()
		return pages:GetCurrentPage()
	end)
	if not okPage or type(top) ~= "table" then
		return
	end

	local entries = {}
	for _, entry in top do
		local userId = tonumber(entry.key) or 0
		local wins = tonumber(entry.value) or 0
		if userId > 0 then
			table.insert(entries, { userId = userId, wins = wins, name = resolveName(userId) })
		end
	end

	ensureFolder()
	for i = 1, Config.LEADERBOARD_SIZE do
		writeEntryToFolder(i, entries[i])
	end
	ReplicatedStorage:SetAttribute("LeaderboardUpdatedAt", os.time())

	-- Espelha no mural do lobby (TextLabels em muralList.Row1..Row10)
	if muralList then
		for i = 1, Config.LEADERBOARD_SIZE do
			local row = muralList:FindFirstChild("Row" .. i) :: TextLabel?
			if row then
				local entry = entries[i]
				if entry then
					row.Text = ("  %d. %s · %d"):format(i, entry.name, entry.wins)
				else
					row.Text = ("  %d. —"):format(i)
				end
			end
		end
	end
end

-- Registra o Frame que contém Row1..RowN. Chame uma vez depois de criar
-- o mural no lobby.
function Leaderboard.bindMural(listFrame: Instance?)
	muralList = listFrame
end

-- Chame quando o jogador ganhar uma rodada. Soma 1 à pontuação global.
function Leaderboard.recordWin(player: Player)
	if not store then
		return
	end
	nameCache[player.UserId] = player.DisplayName
	task.spawn(function()
		pcall(function()
			store:IncrementAsync("u_" .. player.UserId, 1)
		end)
	end)
end

function Leaderboard.init()
	ensureFolder()
	for i = 1, Config.LEADERBOARD_SIZE do
		writeEntryToFolder(i, nil)
	end
	task.spawn(function()
		-- primeira fetch com pequeno atraso pra não competir com carregamento
		task.wait(5)
		while true do
			fetchTop()
			task.wait(Config.LEADERBOARD_REFRESH)
		end
	end)
end

return Leaderboard
