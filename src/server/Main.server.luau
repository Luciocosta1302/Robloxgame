local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Ragdoll = require(Shared.Ragdoll)
local Animations = require(Shared.Animations)
local SoundPlay = require(Shared.SoundPlay)

local MapBuilder = require(script.Parent.MapBuilder)
local PlayerData = require(script.Parent.PlayerData)
local Combat = require(script.Parent.Combat)
local Monetization = require(script.Parent.Monetization)
local Shop = require(script.Parent.Shop)
local Cosmetics = require(script.Parent.Cosmetics)
local DailyReward = require(script.Parent.DailyReward)
local RewardedAds = require(script.Parent.RewardedAds)
local Analytics = require(script.Parent.Analytics)
local Referrals = require(script.Parent.Referrals)
local Badges = require(script.Parent.Badges)
local Codes = require(script.Parent.Codes)

local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
for _, name in { "Dash", "Ragdoll", "Notify" } do
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = remotes
end
remotes.Parent = ReplicatedStorage

MapBuilder.build()
local currentArena = MapBuilder.buildArena()
PlayerData.init()
Combat.init(remotes)
Shop.init(remotes)
DailyReward.init(remotes)
RewardedAds.init(remotes)
Analytics.init()
Referrals.init(remotes)
Badges.init(remotes)
Codes.init(remotes)

-- Easter egg: tocar na SecretPotato do lobby concede a badge SECRET
local secretPart = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("SecretPotato")
if secretPart and secretPart:IsA("BasePart") then
	secretPart.Touched:Connect(function(hit)
		local character = hit and hit:FindFirstAncestorOfClass("Model")
		local player = character and Players:GetPlayerFromCharacter(character)
		if player then
			Badges.onSecret(player)
		end
	end)
end

-- Remote pro cliente pedir pra abrir o prompt de convite
local inviteRemote = Instance.new("RemoteEvent")
inviteRemote.Name = "RequestInvitePrompt"
inviteRemote.Parent = remotes
-- Nota: PromptGameInvite roda no cliente. O servidor não chama direto.
-- Esse Remote existe só pra o cliente avisar de volta "cliquei em convidar"
-- (analytics). O cliente chama Players:PromptGameInvite localmente.

-- Remote pro cliente avisar que abriu a loja (funil passo 5). Shop.init já
-- criou ShopBuy/Equip/Unequip/Catalog; esse é adicional.
local shopOpened = Instance.new("RemoteEvent")
shopOpened.Name = "ShopOpened"
shopOpened.Parent = remotes
shopOpened.OnServerEvent:Connect(function(player)
	Analytics.step(player, "opened_shop")
end)

local alive: { [Player]: boolean } = {}
local holder: Player? = nil
local bomb: BasePart? = nil
local lastPass = 0
local roundActive = false

local POTATO_COLOR = Color3.fromRGB(181, 130, 70)
local DANGER_COLOR = Color3.fromRGB(255, 40, 40)

local function setStatus(text: string)
	ReplicatedStorage:SetAttribute("Status", text)
end

local function notifyAll(text: string)
	remotes.Notify:FireAllClients(text)
end

local function countAlive()
	local n = 0
	for _ in alive do
		n += 1
	end
	return n
end

local function randomAlive(except: Player?): Player?
	local list = {}
	for player in alive do
		if player ~= except then
			table.insert(list, player)
		end
	end
	if #list == 0 then
		return nil
	end
	return list[math.random(1, #list)]
end

local function createBomb()
	local potato = Instance.new("Part")
	potato.Name = "Batata"
	potato.Shape = Enum.PartType.Ball
	potato.Size = Vector3.new(2.6, 2.6, 2.6)
	potato.Color = POTATO_COLOR
	potato.Material = Enum.Material.Sand
	potato.CanCollide = false
	potato.Massless = true

	local fire = Instance.new("Fire")
	fire.Size = 3
	fire.Heat = 6
	fire.Parent = potato

	local light = Instance.new("PointLight")
	light.Color = DANGER_COLOR
	light.Range = 12
	light.Parent = potato

	potato.Parent = workspace
	-- tique em loop; a velocidade cresce conforme o pavio queima
	SoundPlay.loopOn(potato, "TICK", 0.6)
	return potato
end

local function setHolder(player: Player?)
	if holder and holder.Character then
		local humanoid = holder.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = Config.NORMAL_SPEED
		end
		local highlight = holder.Character:FindFirstChild("BombHighlight")
		if highlight then
			highlight:Destroy()
		end
		Animations.stop(holder.Character, "PANIC")
	end

	holder = player
	ReplicatedStorage:SetAttribute("Holder", if player then player.UserId else 0)

	if bomb then
		Cosmetics.applyToBomb(bomb, player)
	end

	if not player or not player.Character or not bomb then
		return
	end

	local character = player.Character
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = Config.HOLDER_SPEED
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "BombHighlight"
	highlight.FillColor = DANGER_COLOR
	highlight.FillTransparency = 0.6
	highlight.Parent = character

	local anchor = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
	if anchor then
		local oldWeld = bomb:FindFirstChild("Weld")
		if oldWeld then
			oldWeld:Destroy()
		end
		bomb.CFrame = anchor.CFrame * CFrame.new(0, 2.6, 0)
		local weld = Instance.new("WeldConstraint")
		weld.Name = "Weld"
		weld.Part0 = anchor
		weld.Part1 = bomb
		weld.Parent = bomb
	end

	pcall(Animations.play, character, "PANIC", { priority = Enum.AnimationPriority.Action2, looped = true })
end

local function passBomb(from: Player, to: Player)
	if not roundActive or holder ~= from or not alive[to] then
		return
	end
	if os.clock() - lastPass < Config.PASS_COOLDOWN then
		return
	end
	lastPass = os.clock()
	setHolder(to)
	PlayerData.addCoins(from, Config.COINS_PASS)
	Badges.onPotatoPass(from)
	remotes.Notify:FireClient(to, "🥔 A batata é sua! Passa pra frente!")
end

local function eliminate(player: Player, reason: string)
	if not alive[player] then
		return
	end
	alive[player] = nil
	notifyAll(player.DisplayName .. " " .. reason)

	if player == holder then
		setHolder(randomAlive())
	end

	task.delay(2.5, function()
		if player.Parent and not alive[player] then
			player:LoadCharacter()
		end
	end)
end

local function makeExplosionFX(center: Vector3, explosionPayload)
	local blast = Instance.new("Explosion")
	blast.Position = center
	blast.BlastPressure = 0
	blast.BlastRadius = Config.BLAST_RADIUS
	blast.DestroyJointRadiusPercent = 0
	blast.Parent = workspace

	if explosionPayload then
		-- partículas coloridas extras (puramente visual, não altera a física)
		local att = Instance.new("Attachment")
		att.WorldPosition = center
		att.Parent = workspace.Terrain
		local p = Instance.new("ParticleEmitter")
		p.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		p.Rate = 0
		p.Lifetime = NumberRange.new(0.6, 1.2)
		p.Speed = NumberRange.new(20, 40)
		p.Size = NumberSequence.new(1.5, 0)
		p.Rotation = NumberRange.new(0, 360)
		if explosionPayload.rainbow then
			p.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 220, 120)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 160, 255)),
			})
		elseif typeof(explosionPayload.color) == "Color3" then
			p.Color = ColorSequence.new(explosionPayload.color)
		end
		p.Parent = att
		p:Emit(80)
		task.delay(1.5, function()
			att:Destroy()
		end)
	end
end

local function explode()
	if not holder or not bomb then
		return
	end
	local victim = holder
	local center = bomb.Position
	local explosionPayload = Cosmetics.getExplosionPayload(victim)

	if victim.Character then
		pcall(Animations.play, victim.Character, "EXPLODE", { priority = Enum.AnimationPriority.Action4, fade = 0 })
	end
	makeExplosionFX(center, explosionPayload)
	SoundPlay.at(center, "EXPLOSION", 1)

	for player in alive do
		local root = Combat.getRoot(player)
		if root then
			local offset = root.Position - center
			if offset.Magnitude < Config.BLAST_RADIUS then
				local flat = Vector3.new(offset.X, 0, offset.Z)
				if flat.Magnitude < 0.1 then
					flat = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5)
				end
				local force = flat.Unit * Config.BLAST_FORCE + Vector3.new(0, Config.BLAST_FORCE * 0.8, 0)
				Combat.knock(player, force, player == victim)
			end
		end
	end

	setHolder(nil)
	Badges.onExplode(victim)
	eliminate(victim, "explodiu! 💥")
	for player in alive do
		PlayerData.addCoins(player, Config.COINS_SURVIVE)
	end
end

local function clearBomb()
	setHolder(nil)
	if bomb then
		bomb:Destroy()
		bomb = nil
	end
end

local function trollExplode(from: Player)
	-- Troll só visual: ragdolla todo mundo por 2s, NÃO elimina, NÃO passa a batata.
	notifyAll("💥 " .. from.DisplayName .. " explodiu todo mundo pra zoar!")
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if character and root then
			local dir = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5)
			if dir.Magnitude < 0.1 then
				dir = Vector3.new(1, 0, 0)
			end
			local fling = dir.Unit * 45 + Vector3.new(0, 55, 0)
			Ragdoll.enable(character)
			remotes.Ragdoll:FireClient(player, true, fling)

			local token = (character:GetAttribute("RagdollToken") or 0) + 1
			character:SetAttribute("RagdollToken", token)
			task.delay(2, function()
				if character.Parent and character:GetAttribute("RagdollToken") == token then
					Ragdoll.disable(character)
					remotes.Ragdoll:FireClient(player, false)
				end
			end)
		end
	end
end

-- expor dash duplo para o Combat
Combat.hasDashDuplo = function(player: Player): boolean
	return Monetization.hasDashDuplo(player)
end

Monetization.init(remotes, {
	notifyAll = notifyAll,
	trollExplode = trollExplode,
})

Combat.onHit = function(attacker, victim)
	Badges.onDashHit(attacker)
	if attacker == holder then
		passBomb(attacker, victim)
	end
end

RunService.Heartbeat:Connect(function()
	if not roundActive then
		return
	end

	for player in alive do
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = Combat.getRoot(player)
		if not humanoid or humanoid.Health <= 0 or not root then
			eliminate(player, "saiu da arena")
		elseif root.Position.Y < Config.FALL_Y then
			eliminate(player, "caiu da arena! 😵")
		end
	end

	local current = holder
	if not current or os.clock() - lastPass < Config.PASS_COOLDOWN then
		return
	end
	local holderRoot = Combat.getRoot(current)
	if not holderRoot then
		return
	end
	for player in alive do
		local root = Combat.getRoot(player)
		if player ~= current and root and (root.Position - holderRoot.Position).Magnitude < Config.PASS_DISTANCE then
			passBomb(current, player)
			break
		end
	end
end)

local function onPlayerAdded(player: Player)
	Analytics.step(player, "joined")
	-- Bônus de boas-vindas: espera o PlayerData carregar.
	task.delay(1.5, function()
		if not player.Parent then
			return
		end
		if PlayerData.tryGrantWelcome(player) then
			remotes.Notify:FireClient(
				player,
				("🎉 Bem-vindo! +%d moedas e uma trilha grátis — abre a 🛒 loja!"):format(Config.WELCOME_COINS)
			)
		end
	end)

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid", 5)
		if humanoid then
			character:WaitForChild("HumanoidRootPart", 5)
			task.wait(0.1)
			Cosmetics.applyToCharacter(player, character, Monetization.hasVIP(player))
		end
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
	onPlayerAdded(player)
	if player.Character then
		Cosmetics.applyToCharacter(player, player.Character, Monetization.hasVIP(player))
	end
end

Players.PlayerRemoving:Connect(function(player)
	if alive[player] then
		alive[player] = nil
		if player == holder then
			setHolder(randomAlive())
		end
	end
end)

local function runRound()
	currentArena = MapBuilder.buildArena()
	notifyAll("🗺️ Arena: " .. currentArena.name:upper())

	alive = {}
	for i, player in Players:GetPlayers() do
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if character and humanoid and humanoid.Health > 0 then
			Ragdoll.disable(character)
			character:PivotTo(currentArena.spawns[(i - 1) % #currentArena.spawns + 1])
			alive[player] = true
		end
	end

	local startCount = countAlive()
	if startCount == 0 then
		return
	end
	local endAt = if startCount > 1 then 1 else 0

	for player in alive do
		Analytics.step(player, "saw_first_round")
	end

	roundActive = true
	setStatus("PREPARA... 🥔")
	task.wait(3)

	while countAlive() > endAt do
		bomb = createBomb()
		lastPass = os.clock()
		setHolder(randomAlive())

		local fuse = math.random(Config.FUSE_MIN, Config.FUSE_MAX)
		local started = os.clock()

		while holder and countAlive() > endAt do
			local elapsed = os.clock() - started
			if elapsed >= fuse then
				break
			end
			local progress = elapsed / fuse
			ReplicatedStorage:SetAttribute("FuseProgress", progress)
			local blinkSpeed = 2 + progress * 12
			if bomb then
				local baseColor = bomb:GetAttribute("CosmeticBase") or POTATO_COLOR
				bomb.Color = if math.floor(elapsed * blinkSpeed) % 2 == 0 then DANGER_COLOR else baseColor
				local tick = bomb:FindFirstChildOfClass("Sound")
				if tick and tick.Looped then
					tick.PlaybackSpeed = 0.8 + progress * 1.6
					tick.Volume = 0.6 + progress * 0.4
				end
			end
			setStatus(("🥔 %d vivos — não fica com a batata!"):format(countAlive()))
			task.wait(0.05)
		end
		ReplicatedStorage:SetAttribute("FuseProgress", 0)

		if holder and os.clock() - started >= fuse then
			explode()
		end
		clearBomb()

		if countAlive() > endAt then
			setStatus("Nova batata em 3...")
			task.wait(3)
		end
	end

	roundActive = false
	clearBomb()

	local winner = next(alive)
	if winner and startCount > 1 then
		PlayerData.addCoins(winner, Config.COINS_WIN)
		PlayerData.addWin(winner)
		Analytics.step(winner, "first_win")
		Badges.onWin(winner)
		setStatus("🏆 " .. winner.DisplayName .. " venceu!")
		notifyAll("🏆 " .. winner.DisplayName .. " sobreviveu à batata! +" .. Config.COINS_WIN .. " moedas")
		if winner.Character then
			pcall(Animations.play, winner.Character, "VICTORY", { priority = Enum.AnimationPriority.Action3 })
			SoundPlay.on(winner.Character, "VICTORY", 1)
		end
	else
		setStatus("Fim da rodada!")
	end

	local survivors = alive
	for player in survivors do
		Badges.onRoundSurvived(player)
	end
	alive = {}
	task.delay(3, function()
		for player in survivors do
			if player.Parent and not roundActive then
				player:LoadCharacter()
			end
		end
	end)
end

while true do
	if #Players:GetPlayers() < Config.MIN_PLAYERS then
		setStatus(("Esperando jogadores (%d/%d)..."):format(#Players:GetPlayers(), Config.MIN_PLAYERS))
		task.wait(1)
	else
		local ready = true
		for t = Config.INTERMISSION, 1, -1 do
			if #Players:GetPlayers() < Config.MIN_PLAYERS then
				ready = false
				break
			end
			setStatus(("Rodada começa em %d"):format(t))
			task.wait(1)
		end
		if ready then
			runRound()
			task.wait(4)
		end
	end
end
