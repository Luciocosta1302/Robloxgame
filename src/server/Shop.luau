local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local PlayerData = require(script.Parent.PlayerData)

local Shop = {}

local VALID_KINDS = {
	trail = true,
	potato = true,
	explosion = true,
	aura = true,
	hat = true,
	title = true,
	emote = true,
	pet = true,
}

local itemById: { [string]: any } = {}
for _, item in Config.COSMETICS do
	itemById[item.id] = item
end

local remotes: Folder

-- Replica estado da loja (owned + equipped) para o cliente via atributos no Player
local function pushState(player: Player)
	local data = PlayerData.get(player)
	if not data then
		return
	end
	local owned = {}
	for id in data.cosmetics do
		table.insert(owned, id)
	end
	table.sort(owned)
	player:SetAttribute("OwnedCosmetics", table.concat(owned, ","))

	for kind in VALID_KINDS do
		player:SetAttribute("Equipped_" .. kind, data.equipped[kind] or "")
	end
end

local function sendCatalog(player: Player)
	remotes.ShopCatalog:FireClient(player, Config.COSMETICS)
end

local function buy(player: Player, itemId: string)
	if type(itemId) ~= "string" then
		return
	end
	local item = itemById[itemId]
	if not item then
		return
	end
	if PlayerData.ownsCosmetic(player, itemId) then
		remotes.Notify:FireClient(player, "Você já tem esse item.")
		return
	end
	local price = item.price
	if type(price) ~= "number" or price < 0 then
		return
	end
	if not PlayerData.spendCoins(player, price) then
		remotes.Notify:FireClient(player, "Moedas insuficientes.")
		return
	end
	PlayerData.grantCosmetic(player, itemId)
	-- Equipa automaticamente se nada está equipado no slot
	local equipped = PlayerData.getEquipped(player)
	if not equipped[item.kind] then
		PlayerData.equipCosmetic(player, item.kind, itemId)
	end
	pushState(player)
	remotes.Notify:FireClient(player, ("✅ Comprou: %s"):format(item.name))
end

local function equip(player: Player, itemId: string)
	if type(itemId) ~= "string" then
		return
	end
	if itemId == "" then
		return
	end
	local item = itemById[itemId]
	if not item then
		return
	end
	if not PlayerData.ownsCosmetic(player, itemId) then
		return
	end
	PlayerData.equipCosmetic(player, item.kind, itemId)
	pushState(player)
end

local function unequip(player: Player, kind: string)
	if type(kind) ~= "string" or not VALID_KINDS[kind] then
		return
	end
	PlayerData.equipCosmetic(player, kind, nil)
	pushState(player)
end

function Shop.getEquippedPayload(player: Player, kind: string)
	local equipped = PlayerData.getEquipped(player)
	local id = equipped[kind]
	if not id then
		return nil
	end
	local item = itemById[id]
	if not item then
		return nil
	end
	return item.payload, item
end

function Shop.init(remoteFolder: Folder)
	remotes = remoteFolder

	for _, name in { "ShopBuy", "ShopEquip", "ShopUnequip", "ShopCatalog" } do
		if not remotes:FindFirstChild(name) then
			local remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = remotes
		end
	end

	remotes.ShopBuy.OnServerEvent:Connect(buy)
	remotes.ShopEquip.OnServerEvent:Connect(equip)
	remotes.ShopUnequip.OnServerEvent:Connect(unequip)

	Players.PlayerAdded:Connect(function(player)
		-- Espera o PlayerData carregar antes de empurrar estado
		task.delay(1, function()
			if player.Parent then
				pushState(player)
				sendCatalog(player)
			end
		end)
	end)
	for _, player in Players:GetPlayers() do
		task.delay(1, function()
			if player.Parent then
				pushState(player)
				sendCatalog(player)
			end
		end)
	end

	PlayerData.onDataChanged(function(player)
		pushState(player)
	end)
end

return Shop
