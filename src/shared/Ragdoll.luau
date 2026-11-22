local Ragdoll = {}

local KEEP_RIGID = {
	Root = true,
	RootJoint = true,
}

function Ragdoll.enable(character: Model)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or character:GetAttribute("Ragdolled") then
		return
	end
	character:SetAttribute("Ragdolled", true)
	humanoid.RequiresNeck = false
	humanoid.BreakJointsOnDeath = false

	for _, motor in character:GetDescendants() do
		if motor:IsA("Motor6D") and motor.Part0 and motor.Part1 and not KEEP_RIGID[motor.Name] then
			local a0 = Instance.new("Attachment")
			a0.Name = "RagdollA0"
			a0.CFrame = motor.C0
			a0.Parent = motor.Part0

			local a1 = Instance.new("Attachment")
			a1.Name = "RagdollA1"
			a1.CFrame = motor.C1
			a1.Parent = motor.Part1

			local socket = Instance.new("BallSocketConstraint")
			socket.Name = "RagdollSocket"
			socket.Attachment0 = a0
			socket.Attachment1 = a1
			socket.LimitsEnabled = true
			socket.TwistLimitsEnabled = true
			socket.UpperAngle = 50
			socket.TwistLowerAngle = -45
			socket.TwistUpperAngle = 45
			socket.Parent = motor.Parent

			motor.Enabled = false
		end
	end

	humanoid.PlatformStand = true
end

function Ragdoll.disable(character: Model)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or not character:GetAttribute("Ragdolled") then
		return
	end

	for _, item in character:GetDescendants() do
		if item.Name == "RagdollSocket" or item.Name == "RagdollA0" or item.Name == "RagdollA1" then
			item:Destroy()
		elseif item:IsA("Motor6D") then
			item.Enabled = true
		end
	end

	humanoid.PlatformStand = false
	character:SetAttribute("Ragdolled", false)
end

return Ragdoll
