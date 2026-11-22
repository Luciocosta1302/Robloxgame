-- Códigos promocionais. Jogador digita no modal do HUD, cliente envia pelo
-- remote RedeemCode. Servidor valida tipo, comprimento, se o código existe,
-- se expirou, se ainda tem usos e se este jogador já resgatou.
--
-- Contador global de usos vive num DataStore separado pra sobreviver a
-- restart de servidor e não inflar com a conta do jogador.

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local PlayerData = require(script.Parent.PlayerData)

local Codes = {}

local remotes: Folder

local usesStore
pcall(function()
	usesStore = DataStoreService:GetDataStore("BatataCodes_v1")
end)

-- Retorna (sucesso, mensagem). Mensagem em português pra UI.
local function validate(code: string): (any?, string)
	if type(code) ~= "string" then
		return nil, "Código inválido."
	end
	if #code == 0 or #code > Config.CODE_MAX_LENGTH then
		return nil, "Código fora do tamanho permitido."
	end
	local normalized = code:lower():gsub("%s", "")
	local entry = Config.CODES[normalized]
	if not entry then
		return nil, "Código não existe ou expirou."
	end
	if entry.expires and os.time() > entry.expires then
		return nil, "Código expirado."
	end
	return { key = normalized, entry = entry }, ""
end

local function reserveGlobalUse(key: string, max: number?): boolean
	if not max then
		return true -- sem limite global
	end
	if not usesStore then
		return true -- se o DataStore falhar, não bloqueia (dev mode)
	end
	local reserved = false
	local ok = pcall(function()
		usesStore:UpdateAsync("code_" .. key, function(current)
			local used = tonumber(current) or 0
			if used >= max then
				return nil -- sem update: código esgotado
			end
			reserved = true
			return used + 1
		end)
	end)
	if not ok then
		-- Erro de DataStore: por segurança deixa passar e loga apenas
		warn("[Codes] falha ao reservar uso do código " .. key)
		return true
	end
	return reserved
end

local function redeem(player: Player, raw: string)
	local parsed, err = validate(raw)
	local function notify(text: string)
		if remotes and remotes:FindFirstChild("Notify") then
			remotes.Notify:FireClient(player, text)
		end
	end
	if not parsed then
		notify("❌ " .. err)
		return
	end
	local key = parsed.key
	local entry = parsed.entry
	if PlayerData.hasCode(player, key) then
		notify("❌ Você já resgatou esse código.")
		return
	end
	if not reserveGlobalUse(key, entry.uses) then
		notify("❌ Código esgotado.")
		return
	end
	PlayerData.markCode(player, key)
	if entry.coins and entry.coins > 0 then
		PlayerData.addCoinsRaw(player, entry.coins)
		notify(("✅ +%d moedas pelo código!"):format(entry.coins))
	else
		notify("✅ Código resgatado!")
	end
end

function Codes.init(remoteFolder: Folder)
	remotes = remoteFolder
	if not remotes:FindFirstChild("RedeemCode") then
		local remote = Instance.new("RemoteEvent")
		remote.Name = "RedeemCode"
		remote.Parent = remotes
	end
	remotes.RedeemCode.OnServerEvent:Connect(redeem)
end

return Codes
