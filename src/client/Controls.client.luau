local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local lastDashTime = 0
local dashCharges = 1

local function getParts()
	local character = player.Character
	if not character then
		return nil, nil, nil
	end
	return character, character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")
end

local function maxCharges(): number
	return if player:GetAttribute("DashDuplo") then Config.DASH_DUPLO_CHARGES else 1
end

local function currentCooldown(): number
	local mul = ReplicatedStorage:GetAttribute("DashCooldownMul")
	if type(mul) == "number" and mul > 0 then
		return Config.DASH_COOLDOWN * mul
	end
	return Config.DASH_COOLDOWN
end

local function dash(_, state)
	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	local character, humanoid, root = getParts()
	if not character or not humanoid or not root or character:GetAttribute("Ragdolled") then
		return Enum.ContextActionResult.Sink
	end

	local now = os.clock()
	if now - lastDashTime >= currentCooldown() then
		dashCharges = maxCharges()
	end
	if dashCharges <= 0 then
		return Enum.ContextActionResult.Sink
	end
	dashCharges -= 1
	lastDashTime = now

	local direction = if humanoid.MoveDirection.Magnitude > 0.1 then humanoid.MoveDirection else root.CFrame.LookVector
	direction = Vector3.new(direction.X, 0, direction.Z).Unit

	local attachment = Instance.new("Attachment")
	attachment.Parent = root

	local velocity = Instance.new("LinearVelocity")
	velocity.Attachment0 = attachment
	velocity.MaxForce = 1e6
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.VectorVelocity = direction * Config.DASH_SPEED
	velocity.Parent = root

	Debris:AddItem(velocity, Config.DASH_TIME)
	Debris:AddItem(attachment, Config.DASH_TIME)

	remotes.Dash:FireServer()
	return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction("Dash", dash, true, Enum.KeyCode.Q, Enum.KeyCode.ButtonX)
ContextActionService:SetTitle("Dash", "EMPURRA")
ContextActionService:SetPosition("Dash", UDim2.new(1, -180, 1, -150))

remotes.Ragdoll.OnClientEvent:Connect(function(enabled: boolean, fling: Vector3?)
	local character, humanoid = getParts()
	if not character or not humanoid then
		return
	end

	if enabled then
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		for _, part in character:GetDescendants() do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and not part:FindFirstAncestorOfClass("Accessory") then
				part.CanCollide = true
			end
		end
		if fling then
			for _, part in character:GetDescendants() do
				if part:IsA("BasePart") then
					part.AssemblyLinearVelocity = fling
				end
			end
		end
	else
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end)
