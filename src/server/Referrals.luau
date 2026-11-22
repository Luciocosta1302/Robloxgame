-- Convite de amigo com recompensa. Usa Players:PromptGameInvite no cliente
-- (chamada pelo botão do HUD) e GetJoinData().ReferredByPlayerId no servidor
-- pra detectar quem indicou. Dá +Config.REFERRAL_COINS pros dois,
-- uma vez por par.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local PlayerData = require(script.Parent.PlayerData)

local Referrals = {}

local remotes: Folder

local function handleJoin(player: Player)
	-- Espera o PlayerData carregar
	task.wait(1.5)
	if not player.Parent then
		return
	end
	local ok, data = pcall(function()
		return player:GetJoinData()
	end)
	if not ok or type(data) ~= "table" then
		return
	end
	local referrerId = data.ReferredByPlayerId
	if type(referrerId) ~= "number" or referrerId == 0 then
		return
	end
	if referrerId == player.UserId then
		return -- não pode indicar a si mesmo
	end

	local pdata = PlayerData.get(player)
	if not pdata then
		return
	end

	-- Garante campo (defaults já criou na próxima versão do PlayerData)
	local pairKey = tostring(referrerId)
	pdata.referrals = pdata.referrals or {}
	if pdata.referrals[pairKey] then
		return -- já reivindicou com esse referrer antes
	end
	pdata.referrals[pairKey] = true

	-- Bônus pro novato
	PlayerData.addCoinsRaw(player, Config.REFERRAL_COINS)
	if remotes and remotes:FindFirstChild("Notify") then
		remotes.Notify:FireClient(
			player,
			("🤝 Você aceitou um convite! +%d moedas"):format(Config.REFERRAL_COINS)
		)
	end

	-- Bônus pro referrer (se tá online)
	local referrer = Players:GetPlayerByUserId(referrerId)
	if referrer then
		local rdata = PlayerData.get(referrer)
		if rdata then
			rdata.referrals = rdata.referrals or {}
			-- marca no referrer também pra não dar duplo em outro match
			local reverseKey = tostring(player.UserId)
			if not rdata.referrals[reverseKey] then
				rdata.referrals[reverseKey] = true
				PlayerData.addCoinsRaw(referrer, Config.REFERRAL_COINS)
				if remotes and remotes:FindFirstChild("Notify") then
					remotes.Notify:FireClient(
						referrer,
						("🤝 %s entrou pelo seu convite! +%d moedas"):format(player.DisplayName, Config.REFERRAL_COINS)
					)
				end
			end
		end
	end
end

function Referrals.init(remoteFolder: Folder)
	remotes = remoteFolder

	Players.PlayerAdded:Connect(function(player)
		task.spawn(handleJoin, player)
	end)
	for _, player in Players:GetPlayers() do
		task.spawn(handleJoin, player)
	end
end

return Referrals
