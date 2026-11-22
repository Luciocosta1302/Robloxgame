local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local PlayerData = require(script.Parent.PlayerData)

local RewardedAds = {}

-- A API de Rewarded Video Ads no Roblox foi mudando. Mantemos uma referência
-- cuidadosa: se o serviço não existir no canal onde o jogo roda, a UI do
-- cliente é desligada. NÃO invente IDs; o Roblox entrega o anúncio.
local AdService: any = nil
pcall(function()
	AdService = game:GetService("AdService")
end)

local remotes: Folder

local function show(player: Player)
	if not AdService then
		remotes.Notify:FireClient(player, "Vídeo com recompensa não está disponível agora.")
		return
	end

	local data = PlayerData.get(player)
	if not data then
		return
	end
	if os.time() - data.lastRewardedAd < Config.REWARDED_AD_COOLDOWN then
		remotes.Notify:FireClient(player, "Volte em alguns minutos para o próximo vídeo.")
		return
	end

	local ok, result = pcall(function()
		-- A chamada exata muda entre canais (PromptAd vs ShowRewardedVideoAd).
		-- Tentamos o nome mais recente e caímos para o legado.
		local service = AdService :: any
		if typeof(service.PromptAd) == "function" then
			return service:PromptAd(player, Enum.AdType and Enum.AdType.Rewarded or nil)
		end
		if typeof(service.ShowRewardedVideoAd) == "function" then
			return service:ShowRewardedVideoAd(player)
		end
		return nil
	end)

	if not ok or result == nil then
		remotes.Notify:FireClient(player, "Vídeo com recompensa não está disponível agora.")
		return
	end

	-- `result` pode ser um booleano (completou) ou uma tabela ({success = true}).
	local completed = result == true or (type(result) == "table" and result.success == true)
	if not completed then
		remotes.Notify:FireClient(player, "Vídeo não foi assistido até o fim.")
		return
	end

	local granted, reward = PlayerData.tryClaimRewardedAd(player)
	if granted then
		remotes.Notify:FireClient(player, ("🎬 +%d moedas pelo vídeo!"):format(reward))
	end
end

function RewardedAds.isAvailable(): boolean
	return AdService ~= nil
end

function RewardedAds.init(remoteFolder: Folder)
	remotes = remoteFolder
	if not remotes:FindFirstChild("WatchAd") then
		local remote = Instance.new("RemoteEvent")
		remote.Name = "WatchAd"
		remote.Parent = remotes
	end
	remotes.WatchAd.OnServerEvent:Connect(show)
end

return RewardedAds
