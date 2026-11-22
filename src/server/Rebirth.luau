-- Rebirth: reseta moedas + vitórias em troca de +25% permanente nas moedas.
-- Cliente pede via Remotes.Rebirth. Servidor confirma requisitos e aplica.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local PlayerData = require(script.Parent.PlayerData)

local Rebirth = {}

local remotes: Folder

local function trySend(player: Player, kind: string, payload)
	if remotes and remotes:FindFirstChild(kind) then
		remotes[kind]:FireClient(player, payload)
	end
end

local function sendStatus(player: Player)
	local data = PlayerData.get(player)
	if not data then
		return
	end
	trySend(player, "RebirthStatus", {
		wins = data.wins,
		required = Config.REBIRTH_WINS_REQUIRED,
		rebirths = data.rebirths,
		bonus = data.rebirths * Config.REBIRTH_COIN_BONUS_PER_LEVEL,
	})
end

local function onRequestRebirth(player: Player)
	local ok, msg = PlayerData.tryRebirth(player)
	if remotes:FindFirstChild("Notify") then
		remotes.Notify:FireClient(player, (ok and "🌟 " or "❌ ") .. msg)
	end
	sendStatus(player)
end

function Rebirth.init(remoteFolder: Folder)
	remotes = remoteFolder
	for _, name in { "Rebirth", "RebirthStatus", "RebirthRequest" } do
		if not remotes:FindFirstChild(name) then
			local remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = remotes
		end
	end
	remotes.Rebirth.OnServerEvent:Connect(onRequestRebirth)
	remotes.RebirthRequest.OnServerEvent:Connect(sendStatus)

	Players.PlayerAdded:Connect(function(player)
		task.delay(1.5, function()
			if player.Parent then
				sendStatus(player)
			end
		end)
	end)
	for _, player in Players:GetPlayers() do
		task.delay(1.5, function()
			if player.Parent then
				sendStatus(player)
			end
		end)
	end
end

return Rebirth
