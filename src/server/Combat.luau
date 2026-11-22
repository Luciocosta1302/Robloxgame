local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Ragdoll = require(ReplicatedStorage.Shared.Ragdoll)
local Animations = require(ReplicatedStorage.Shared.Animations)

local Combat = {}
Combat.onHit = nil :: ((attacker: Player, victim: Player) -> ())?
Combat.hasDashDuplo = function(_player: Player): boolean
	return false
end

local remotes: Folder
local lastDash: { [Player]: number } = {}
local dashCharges: { [Player]: number } = {}

function Combat.getRoot(player: Player): BasePart?
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

function Combat.knock(player: Player, velocity: Vector3?, stayDown: boolean?)
	local character = player.Character
	if not character then
		return
	end

	Ragdoll.enable(character)
	remotes.Ragdoll:FireClient(player, true, velocity)

	if stayDown then
		return
	end

	local token = (character:GetAttribute("RagdollToken") or 0) + 1
	character:SetAttribute("RagdollToken", token)

	task.delay(Config.RAGDOLL_TIME, function()
		if character.Parent and character:GetAttribute("RagdollToken") == token then
			Ragdoll.disable(character)
			remotes.Ragdoll:FireClient(player, false)
			-- animação de levantar
			pcall(Animations.play, character, "STAND_UP", { priority = Enum.AnimationPriority.Action })
		end
	end)
end

local function maxCharges(player: Player): number
	return if Combat.hasDashDuplo(player) then Config.DASH_DUPLO_CHARGES else 1
end

local function onDash(player: Player)
	local now = os.clock()
	local last = lastDash[player] or 0
	local charges = dashCharges[player] or maxCharges(player)

	if now - last >= Config.DASH_COOLDOWN then
		charges = maxCharges(player)
	end

	if charges <= 0 then
		return
	end

	local character = player.Character
	local root = Combat.getRoot(player)
	if not character or not root or character:GetAttribute("Ragdolled") then
		return
	end

	charges -= 1
	dashCharges[player] = charges
	lastDash[player] = now

	pcall(Animations.play, character, "PUSH", { priority = Enum.AnimationPriority.Action2, fade = 0.05 })

	local hit = {}
	local connection
	connection = RunService.Heartbeat:Connect(function()
		if os.clock() - now > Config.DASH_TIME + 0.1 or not root.Parent then
			connection:Disconnect()
			return
		end

		for _, other in Players:GetPlayers() do
			local otherRoot = Combat.getRoot(other)
			if other ~= player and not hit[other] and otherRoot then
				local offset = otherRoot.Position - root.Position
				if offset.Magnitude < Config.DASH_HIT_DISTANCE then
					hit[other] = true
					local flat = Vector3.new(offset.X, 0, offset.Z)
					if flat.Magnitude < 0.1 then
						flat = root.CFrame.LookVector
					end
					Combat.knock(other, flat.Unit * Config.DASH_PUSH + Vector3.new(0, 35, 0))
					if Combat.onHit then
						Combat.onHit(player, other)
					end
				end
			end
		end
	end)
end

function Combat.init(remoteFolder: Folder)
	remotes = remoteFolder
	remotes.Dash.OnServerEvent:Connect(onDash)
	Players.PlayerRemoving:Connect(function(player)
		lastDash[player] = nil
		dashCharges[player] = nil
	end)
end

return Combat
