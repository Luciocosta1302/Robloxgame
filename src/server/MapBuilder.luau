local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local Config = require(ReplicatedStorage.Shared.Config)

local MapBuilder = {}

local COLORS = {
	Color3.fromRGB(255, 99, 99),
	Color3.fromRGB(99, 170, 255),
	Color3.fromRGB(255, 200, 60),
	Color3.fromRGB(170, 110, 255),
	Color3.fromRGB(80, 220, 170),
}

local function part(props)
	local p = Instance.new(props.ClassName or "Part")
	props.ClassName = nil
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if props.Shape then
		p.Shape = props.Shape
	end
	local parent = props.Parent
	props.Parent = nil
	for key, value in props do
		p[key] = value
	end
	p.Parent = parent
	return p
end

local function buildLobby(map: Folder)
	local c = Config.LOBBY_CENTER

	part({
		Name = "LobbyFloor",
		Size = Vector3.new(140, 4, 140),
		CFrame = CFrame.new(c - Vector3.new(0, 2, 0)),
		Color = Color3.fromRGB(255, 214, 102),
		Material = Enum.Material.SmoothPlastic,
		Parent = map,
	})

	for i = 0, 3 do
		part({
			Name = "LobbyWall",
			Size = Vector3.new(140, 16, 2),
			CFrame = CFrame.new(c) * CFrame.Angles(0, i * math.pi / 2, 0) * CFrame.new(0, 8, 70),
			Transparency = 0.85,
			Color = Color3.fromRGB(255, 255, 255),
			Parent = map,
		})
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Anchored = true
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.CFrame = CFrame.new(c + Vector3.new(0, 0.5, 0))
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Color = Color3.fromRGB(255, 140, 50)
	spawn.Parent = map

	local sign = part({
		Name = "Sign",
		Size = Vector3.new(44, 16, 1),
		CFrame = CFrame.new(c + Vector3.new(0, 12, -50)),
		Color = Color3.fromRGB(120, 70, 40),
		Parent = map,
	})

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Back
	gui.Parent = sign

	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.FredokaOne
	text.TextScaled = true
	text.TextColor3 = Color3.fromRGB(255, 230, 150)
	text.Text = "BATATA QUENTE\nRAGDOLL 🥔💥"
	text.Parent = gui
end

local function buildArena(map: Folder)
	local c = Config.ARENA_CENTER
	local r = Config.ARENA_RADIUS
	local rng = Random.new(42)

	part({
		Name = "ArenaFloor",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(4, r * 2, r * 2),
		CFrame = CFrame.new(c - Vector3.new(0, 2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(110, 200, 90),
		Material = Enum.Material.Grass,
		Parent = map,
	})

	part({
		Name = "CenterPillar",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(10, 10, 10),
		CFrame = CFrame.new(c + Vector3.new(0, 5, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(255, 120, 60),
		Parent = map,
	})

	for i = 1, 14 do
		local angle = rng:NextNumber(0, math.pi * 2)
		local ring = if i % 2 == 0 then rng:NextNumber(0.2, 0.42) else rng:NextNumber(0.7, 0.85)
		local pos = c + Vector3.new(math.cos(angle) * r * ring, 0, math.sin(angle) * r * ring)
		local size = Vector3.new(rng:NextNumber(5, 12), rng:NextNumber(3, 8), rng:NextNumber(5, 12))
		local isRamp = i % 4 == 0

		part({
			ClassName = if isRamp then "WedgePart" else "Part",
			Name = if isRamp then "Ramp" else "Block",
			Size = size,
			CFrame = CFrame.new(pos + Vector3.new(0, size.Y / 2, 0)) * CFrame.Angles(0, rng:NextNumber(0, math.pi * 2), 0),
			Color = COLORS[rng:NextInteger(1, #COLORS)],
			Parent = map,
		})
	end

	local spawns = {}
	for i = 1, 12 do
		local angle = i / 12 * math.pi * 2
		local pos = c + Vector3.new(math.cos(angle) * r * 0.58, 4, math.sin(angle) * r * 0.58)
		table.insert(spawns, CFrame.lookAt(pos, Vector3.new(c.X, pos.Y, c.Z)))
	end
	return spawns
end

function MapBuilder.build()
	local old = workspace:FindFirstChild("Map")
	if old then
		old:Destroy()
	end

	local map = Instance.new("Folder")
	map.Name = "Map"
	map.Parent = workspace

	Lighting.ClockTime = 14

	buildLobby(map)
	local spawns = buildArena(map)

	return {
		spawns = spawns,
	}
end

return MapBuilder
