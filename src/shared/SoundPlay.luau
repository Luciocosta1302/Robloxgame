-- Helper de som. Lê os ids em Config.SOUNDS. Se o id for 0, é no-op (não dá
-- erro). Tocar no servidor cria o Sound numa Part do mundo e o Roblox
-- replica pra todos os clientes.

local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local Config = require(script.Parent.Config)

local SoundPlay = {}

local function idOrNil(name: string): string?
	local id = Config.SOUNDS[name]
	if not id or id == 0 then
		return nil
	end
	return "rbxassetid://" .. id
end

-- Toca um som one-shot numa posição do mundo. Retorna o Sound (ou nil).
function SoundPlay.at(position: Vector3, name: string, volume: number?): Sound?
	local assetUrl = idOrNil(name)
	if not assetUrl then
		return nil
	end
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.Position = position
	part.Parent = workspace

	local sound = Instance.new("Sound")
	sound.SoundId = assetUrl
	sound.Volume = volume or 1
	sound.PlayOnRemove = false
	sound.Parent = part
	sound:Play()

	sound.Ended:Once(function()
		part:Destroy()
	end)
	Debris:AddItem(part, 10) -- failsafe
	return sound
end

-- Anexa um Sound em um Instance específico (parte ou personagem). Toca uma
-- vez e se auto-destrói. Útil pra sons que acompanham um alvo.
function SoundPlay.on(target: Instance, name: string, volume: number?): Sound?
	local assetUrl = idOrNil(name)
	if not assetUrl then
		return nil
	end
	local sound = Instance.new("Sound")
	sound.SoundId = assetUrl
	sound.Volume = volume or 1
	sound.Parent = target
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	Debris:AddItem(sound, 10)
	return sound
end

-- Som "ambiente" (UI, feedback do cliente): toca local no SoundService sem
-- posição 3D. Chame só no cliente.
function SoundPlay.ui(name: string, volume: number?): Sound?
	local assetUrl = idOrNil(name)
	if not assetUrl then
		return nil
	end
	local sound = Instance.new("Sound")
	sound.SoundId = assetUrl
	sound.Volume = volume or 1
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	Debris:AddItem(sound, 10)
	return sound
end

-- Cria um Sound em loop numa parte e devolve o handle. Quem chamou controla
-- Volume e PlaybackSpeed. Útil pro tique do pavio.
function SoundPlay.loopOn(target: Instance, name: string, volume: number?): Sound?
	local assetUrl = idOrNil(name)
	if not assetUrl then
		return nil
	end
	local sound = Instance.new("Sound")
	sound.SoundId = assetUrl
	sound.Volume = volume or 1
	sound.Looped = true
	sound.Parent = target
	sound:Play()
	return sound
end

return SoundPlay
