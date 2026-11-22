-- Aplica no mundo os cosméticos equipados pelo jogador. Tudo é puramente visual.
-- O servidor cria as instâncias para que todo mundo veja; o Roblox replica.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shop = require(script.Parent.Shop)
local PlayerData = require(script.Parent.PlayerData)

local Cosmetics = {}

local function clearNamed(parent: Instance, prefix: string)
	for _, child in parent:GetChildren() do
		if child.Name:sub(1, #prefix) == prefix then
			child:Destroy()
		end
	end
end

local function makeAttachment(parent: BasePart, name: string, offset: Vector3)
	local att = Instance.new("Attachment")
	att.Name = name
	att.Position = offset
	att.Parent = parent
	return att
end

local function applyTrail(character: Model, payload)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	clearNamed(root, "CosmeticTrail")

	local a0 = makeAttachment(root, "CosmeticTrailA0", Vector3.new(0, -1, 0))
	local a1 = makeAttachment(root, "CosmeticTrailA1", Vector3.new(0, 1.2, 0))

	local trail = Instance.new("Trail")
	trail.Name = "CosmeticTrail"
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = 0.6
	trail.MinLength = 0.1
	trail.LightEmission = 0.5
	trail.FaceCamera = true
	if payload.rainbow then
		trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 60, 60)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 180, 60)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 240, 80)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(80, 220, 120)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(80, 160, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(180, 100, 255)),
			ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 80, 200)),
		})
	else
		local c1 = payload.color1 or Color3.new(1, 1, 1)
		local c2 = payload.color2 or c1
		trail.Color = ColorSequence.new(c1, c2)
	end
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 1),
	})
	trail.Parent = root
end

local function applyAura(character: Model, payload)
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
	if not torso then
		return
	end
	clearNamed(character, "CosmeticAura")

	local light = Instance.new("PointLight")
	light.Name = "CosmeticAura"
	light.Color = payload.color or Color3.fromRGB(255, 220, 80)
	light.Range = 10
	light.Brightness = 2
	light.Parent = torso

	local att = makeAttachment(torso, "CosmeticAuraAtt", Vector3.new(0, 0, 0))
	local particle = Instance.new("ParticleEmitter")
	particle.Name = "CosmeticAuraFX"
	particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particle.Rate = 8
	particle.Lifetime = NumberRange.new(0.8, 1.4)
	particle.Size = NumberSequence.new(0.6, 0.2)
	particle.Color = ColorSequence.new(light.Color)
	particle.Speed = NumberRange.new(1, 2)
	particle.Rotation = NumberRange.new(0, 360)
	particle.Parent = att
end

local HAT_SHAPES: { [string]: (hat: BasePart, color: Color3) -> () } = {
	cone = function(hat, color)
		hat.Size = Vector3.new(1.4, 2.2, 1.4)
		hat.Shape = Enum.PartType.Cylinder
		hat.Color = color
	end,
	crown = function(hat, color)
		hat.Size = Vector3.new(2, 0.8, 2)
		hat.Shape = Enum.PartType.Block
		hat.Color = color
		hat.Material = Enum.Material.Neon
	end,
}

local function applyHat(character: Model, payload)
	local head = character:FindFirstChild("Head")
	if not head then
		return
	end
	clearNamed(character, "CosmeticHat")

	local hat = Instance.new("Part")
	hat.Name = "CosmeticHat"
	hat.CanCollide = false
	hat.Massless = true
	hat.Anchored = false
	hat.TopSurface = Enum.SurfaceType.Smooth
	hat.BottomSurface = Enum.SurfaceType.Smooth

	local shaper = HAT_SHAPES[payload.shape or "cone"]
	if shaper then
		shaper(hat, payload.color or Color3.new(1, 1, 1))
	else
		hat.Size = Vector3.new(1.4, 1.4, 1.4)
		hat.Color = payload.color or Color3.new(1, 1, 1)
	end
	hat.Parent = character

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = head
	weld.Part1 = hat
	weld.Parent = hat
	hat.CFrame = head.CFrame * CFrame.new(0, 0.9 + hat.Size.Y / 2, 0)
end

local function applyTitle(character: Model, payload, isVIP: boolean)
	local head = character:FindFirstChild("Head")
	if not head then
		return
	end
	clearNamed(character, "CosmeticTitle")

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "CosmeticTitle"
	billboard.Size = UDim2.fromScale(6, 1)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.TextColor3 = payload.color or Color3.fromRGB(255, 255, 255)
	label.Text = (if isVIP then "⭐ " else "") .. (payload.text or "")
	label.Parent = billboard
end

local function applyVIPBody(character: Model)
	-- Efeito dourado nos próprios membros do VIP (só visual)
	clearNamed(character, "CosmeticVIP")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local a = makeAttachment(root, "CosmeticVIPAtt", Vector3.new(0, 0, 0))
	a.Name = "CosmeticVIP" -- clearNamed vai pegar este também
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Name = "CosmeticVIPSparkle"
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 3
	sparkle.Lifetime = NumberRange.new(1, 1.6)
	sparkle.Size = NumberSequence.new(0.3, 0)
	sparkle.Speed = NumberRange.new(0.5, 1)
	sparkle.Color = ColorSequence.new(Color3.fromRGB(255, 220, 80))
	sparkle.Parent = a
end

function Cosmetics.applyToCharacter(player: Player, character: Model, hasVIP: boolean)
	-- limpa anteriores
	for _, name in { "CosmeticTrail", "CosmeticAura", "CosmeticHat", "CosmeticTitle", "CosmeticVIP" } do
		clearNamed(character, name)
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		clearNamed(root, "CosmeticTrail")
		clearNamed(root, "CosmeticVIP")
	end

	local function apply(kind, fn)
		local payload, item = Shop.getEquippedPayload(player, kind)
		if payload then
			fn(character, payload, item)
		end
		return payload
	end

	apply("trail", function(c, p)
		applyTrail(c, p)
	end)
	apply("aura", function(c, p)
		applyAura(c, p)
	end)
	apply("hat", function(c, p)
		applyHat(c, p)
	end)
	local titlePayload = apply("title", function(c, p)
		applyTitle(c, p, hasVIP)
	end)

	if hasVIP and not titlePayload then
		-- VIP sem título comprado ganha um título ⭐ de cortesia
		applyTitle(character, { text = "VIP", color = Color3.fromRGB(255, 220, 80) }, true)
	end
	if hasVIP then
		applyVIPBody(character)
	end
end

function Cosmetics.applyToBomb(bomb: BasePart, holder: Player?)
	-- cor/material padrão
	local defaultColor = Color3.fromRGB(181, 130, 70)
	bomb.Color = defaultColor
	bomb.Material = Enum.Material.Sand

	local fire = bomb:FindFirstChildOfClass("Fire")
	if fire then
		fire.Size = 3
	end

	if not holder then
		return
	end
	local payload = Shop.getEquippedPayload(holder, "potato")
	if not payload then
		return
	end
	if typeof(payload.color) == "Color3" then
		bomb.Color = payload.color
	end
	if payload.material then
		local m = Enum.Material[payload.material]
		if m then
			bomb.Material = m
		end
	end
	if payload.extraFire and fire then
		fire.Size = 6
	end
end

function Cosmetics.getExplosionPayload(holder: Player?)
	if not holder then
		return nil
	end
	return Shop.getEquippedPayload(holder, "explosion")
end

return Cosmetics
