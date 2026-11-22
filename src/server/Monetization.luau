local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local PlayerData = require(script.Parent.PlayerData)

local Monetization = {}

local remotes: Folder
local notifyAllFn: ((text: string) -> ())? = nil
local trollExplodeFn: ((player: Player) -> ())? = nil
local reviveFn: ((player: Player) -> boolean)? = nil
local coinBoostFn: ((player: Player) -> boolean)? = nil

local ownsPassCache: { [number]: { [number]: boolean } } = {} -- [passId][userId] -> bool
local gamePassRefresh: { [number]: boolean } = {}

local function userOwnsPass(player: Player, passId: number): boolean
	if passId == 0 then
		return false
	end
	local bucket = ownsPassCache[passId]
	if not bucket then
		bucket = {}
		ownsPassCache[passId] = bucket
	end
	local cached = bucket[player.UserId]
	if cached ~= nil then
		return cached
	end
	local ok, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
	end)
	if ok then
		bucket[player.UserId] = owns
		return owns
	end
	return false
end

local function refreshPlayerPasses(player: Player)
	local vipId = Config.GAME_PASSES.VIP
	local dashId = Config.GAME_PASSES.DASH_DUPLO

	local hasVIP = userOwnsPass(player, vipId)
	PlayerData.setVIP(player, hasVIP)
	player:SetAttribute("VIP", hasVIP)

	local hasDash = userOwnsPass(player, dashId)
	player:SetAttribute("DashDuplo", hasDash)
end

function Monetization.hasDashDuplo(player: Player): boolean
	return player:GetAttribute("DashDuplo") == true
end

function Monetization.hasVIP(player: Player): boolean
	return player:GetAttribute("VIP") == true
end

local function grantProduct(player: Player, productId: number): Enum.ProductPurchaseDecision
	local reward = Config.DEV_PRODUCT_REWARDS[productId]
	if not reward then
		-- Produto não mapeado: NÃO retornamos PurchaseGranted — se devolvermos
		-- NotProcessedYet o Roblox tenta de novo e o dev pode consertar sem
		-- perder o Robux do jogador.
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if reward.kind == "coins" then
		PlayerData.addCoinsRaw(player, reward.amount)
		if remotes and remotes:FindFirstChild("Notify") then
			remotes.Notify:FireClient(player, ("💰 +%d moedas!"):format(reward.amount))
		end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif reward.kind == "troll_explode" then
		if trollExplodeFn then
			trollExplodeFn(player)
		end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif reward.kind == "revive_round" then
		-- Se o revive não puder ser aplicado (fora da janela, rodada acabou),
		-- retornamos NotProcessedYet pra o Roblox devolver o Robux. Isso é
		-- essencial: não cobrar pelo que não entrega.
		if reviveFn and reviveFn(player) then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		if remotes and remotes:FindFirstChild("Notify") then
			remotes.Notify:FireClient(player, "⚠️ Revive não pôde ser aplicado — tente na próxima rodada.")
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	elseif reward.kind == "coin_boost_round" then
		if coinBoostFn and coinBoostFn(player) then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

local function processReceipt(receiptInfo): Enum.ProductPurchaseDecision
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Idempotência: o Roblox pode mandar o mesmo recibo mais de uma vez.
	-- Nunca devolva PurchaseGranted duas vezes sem checar.
	if PlayerData.wasReceiptProcessed(player, receiptInfo.PurchaseId) then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local decision = grantProduct(player, receiptInfo.ProductId)
	if decision == Enum.ProductPurchaseDecision.PurchaseGranted then
		PlayerData.markReceiptProcessed(player, receiptInfo.PurchaseId)
	end
	return decision
end

local function onGamePassPurchased(player: Player, passId: number, wasPurchased: boolean)
	if not wasPurchased then
		return
	end
	-- Invalida cache e re-checa
	local bucket = ownsPassCache[passId]
	if bucket then
		bucket[player.UserId] = nil
	end
	task.spawn(refreshPlayerPasses, player)
	if notifyAllFn then
		notifyAllFn("🎉 " .. player.DisplayName .. " virou VIP!")
	end
end

function Monetization.promptPurchaseGamePass(player: Player, which: string)
	local id = Config.GAME_PASSES[which]
	if not id or id == 0 then
		return
	end
	MarketplaceService:PromptGamePassPurchase(player, id)
end

function Monetization.promptPurchaseProduct(player: Player, which: string)
	local id = Config.DEV_PRODUCTS[which]
	if not id or id == 0 then
		return
	end
	MarketplaceService:PromptProductPurchase(player, id)
end

function Monetization.getConfiguredProducts(): { [string]: number }
	local out = {}
	for key, id in Config.DEV_PRODUCTS do
		if id ~= 0 then
			out[key] = id
		end
	end
	return out
end

function Monetization.getConfiguredPasses(): { [string]: number }
	local out = {}
	for key, id in Config.GAME_PASSES do
		if id ~= 0 then
			out[key] = id
		end
	end
	return out
end

function Monetization.init(remoteFolder: Folder, callbacks: {
	notifyAll: (string) -> ()?,
	trollExplode: (Player) -> ()?,
	revive: (Player) -> boolean?,
	coinBoost: (Player) -> boolean?,
}?)
	remotes = remoteFolder
	if callbacks then
		notifyAllFn = callbacks.notifyAll
		trollExplodeFn = callbacks.trollExplode
		reviveFn = callbacks.revive
		coinBoostFn = callbacks.coinBoost
	end

	MarketplaceService.ProcessReceipt = processReceipt
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(onGamePassPurchased)

	Players.PlayerAdded:Connect(function(player)
		task.spawn(refreshPlayerPasses, player)
	end)
	for _, player in Players:GetPlayers() do
		task.spawn(refreshPlayerPasses, player)
	end

	-- Expor endpoints de compra para o cliente
	local promptPass = remotes:FindFirstChild("PromptGamePass")
	if not promptPass then
		promptPass = Instance.new("RemoteEvent")
		promptPass.Name = "PromptGamePass"
		promptPass.Parent = remotes
	end
	promptPass.OnServerEvent:Connect(function(player, which)
		if type(which) == "string" then
			Monetization.promptPurchaseGamePass(player, which)
		end
	end)

	local promptProduct = remotes:FindFirstChild("PromptProduct")
	if not promptProduct then
		promptProduct = Instance.new("RemoteEvent")
		promptProduct.Name = "PromptProduct"
		promptProduct.Parent = remotes
	end
	promptProduct.OnServerEvent:Connect(function(player, which)
		if type(which) == "string" then
			Monetization.promptPurchaseProduct(player, which)
		end
	end)
end

return Monetization
