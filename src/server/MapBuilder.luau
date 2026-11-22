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

-- ============================================================
-- Lobby (fixo, construído uma vez)
-- ============================================================
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

	-- Easter egg (badge SECRET): batata dourada minúscula atrás do letreiro.
	local secret = part({
		Name = "SecretPotato",
		Size = Vector3.new(0.8, 0.8, 0.8),
		Shape = Enum.PartType.Ball,
		CFrame = CFrame.new(c + Vector3.new(21, 1.5, -51.4)),
		Color = Color3.fromRGB(255, 215, 60),
		Material = Enum.Material.Neon,
		Transparency = 0.3,
		Parent = map,
	})
	secret.CanCollide = false

	-- Mural de vitórias (top 10 global). O servidor de leaderboard replica
	-- em ReplicatedStorage.LeaderboardTop; um script no cliente atualiza este
	-- SurfaceGui lendo de lá.
	local mural = part({
		Name = "VictoryMural",
		Size = Vector3.new(26, 32, 1),
		CFrame = CFrame.new(c + Vector3.new(50, 16, -20)) * CFrame.Angles(0, math.rad(-90), 0),
		Color = Color3.fromRGB(40, 40, 60),
		Material = Enum.Material.Metal,
		Parent = map,
	})

	local muralGui = Instance.new("SurfaceGui")
	muralGui.Name = "MuralGui"
	muralGui.Face = Enum.NormalId.Back
	muralGui.CanvasSize = Vector2.new(520, 640)
	muralGui.Parent = mural

	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 56)
	header.BackgroundTransparency = 1
	header.Font = Enum.Font.FredokaOne
	header.TextColor3 = Color3.fromRGB(255, 220, 80)
	header.TextScaled = true
	header.Text = "🏆 TOP 10 VITÓRIAS"
	header.Parent = muralGui

	local list = Instance.new("Frame")
	list.Name = "List"
	list.Position = UDim2.new(0, 10, 0, 60)
	list.Size = UDim2.new(1, -20, 1, -70)
	list.BackgroundTransparency = 1
	list.Parent = muralGui

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.Padding = UDim.new(0, 4)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	for i = 1, 10 do
		local row = Instance.new("TextLabel")
		row.Name = "Row" .. i
		row.LayoutOrder = i
		row.Size = UDim2.new(1, 0, 0, 48)
		row.BackgroundColor3 = Color3.fromRGB(28, 28, 44)
		row.BackgroundTransparency = 0.2
		row.Font = Enum.Font.FredokaOne
		row.TextColor3 = Color3.new(1, 1, 1)
		row.TextScaled = true
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.Text = ("  %d. —"):format(i)
		row.Parent = list
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = row
	end
end

-- ============================================================
-- Arena helpers
-- ============================================================
local function makeSpawns(center: Vector3, radius: number, count: number, height: number?)
	local spawns = {}
	local y = height or 4
	for i = 1, count do
		local angle = i / count * math.pi * 2
		local pos = center + Vector3.new(math.cos(angle) * radius * 0.58, y, math.sin(angle) * radius * 0.58)
		table.insert(spawns, CFrame.lookAt(pos, Vector3.new(center.X, pos.Y, center.Z)))
	end
	return spawns
end

local function roundFloor(container: Folder, center: Vector3, radius: number, color: Color3, material: Enum.Material)
	part({
		Name = "ArenaFloor",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(4, radius * 2, radius * 2),
		CFrame = CFrame.new(center - Vector3.new(0, 2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = color,
		Material = material,
		Parent = container,
	})
end

-- ============================================================
-- Arena 1 — Clássica (grama + blocos espalhados)
-- ============================================================
local function buildArenaClassic(arena: Folder)
	local c = Config.ARENA_CENTER
	local r = Config.ARENA_RADIUS
	local rng = Random.new(42)

	roundFloor(arena, c, r, Color3.fromRGB(110, 200, 90), Enum.Material.Grass)

	part({
		Name = "CenterPillar",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(10, 10, 10),
		CFrame = CFrame.new(c + Vector3.new(0, 5, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(255, 120, 60),
		Parent = arena,
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
			Parent = arena,
		})
	end

	return {
		spawns = makeSpawns(c, r, 12, 4),
		name = "classic",
	}
end

-- ============================================================
-- Arena 2 — Gelo (pista escorregadia)
-- ============================================================
local function buildArenaIce(arena: Folder)
	local c = Config.ARENA_CENTER
	local r = Config.ARENA_RADIUS

	local floor = part({
		Name = "ArenaFloor",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(4, r * 2, r * 2),
		CFrame = CFrame.new(c - Vector3.new(0, 2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(180, 230, 255),
		Material = Enum.Material.Glass,
		Parent = arena,
	})
	-- Gelo: baixa fricção pra escorregar
	local physProps = PhysicalProperties.new(0.5, 0.02, 0, 100, 1)
	floor.CustomPhysicalProperties = physProps

	-- 4 "icebergs" como obstáculos pontiagudos
	for i = 1, 4 do
		local angle = i / 4 * math.pi * 2
		local pos = c + Vector3.new(math.cos(angle) * r * 0.4, 0, math.sin(angle) * r * 0.4)
		part({
			ClassName = "WedgePart",
			Name = "Iceberg",
			Size = Vector3.new(14, 10, 14),
			CFrame = CFrame.new(pos + Vector3.new(0, 5, 0)) * CFrame.Angles(0, angle, 0),
			Color = Color3.fromRGB(220, 240, 255),
			Material = Enum.Material.Ice,
			Parent = arena,
		}).CustomPhysicalProperties = physProps
	end

	-- Centro: pirâmide de gelo iluminada
	part({
		Name = "IcePillar",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(14, 6, 6),
		CFrame = CFrame.new(c + Vector3.new(0, 7, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(180, 220, 255),
		Material = Enum.Material.Ice,
		Transparency = 0.2,
		Parent = arena,
	}).CustomPhysicalProperties = physProps

	return {
		spawns = makeSpawns(c, r, 12, 4),
		name = "ice",
	}
end

-- ============================================================
-- Arena 3 — Plataformas (anel exterior + ilhas, sem floor contínuo)
-- ============================================================
local function buildArenaIslands(arena: Folder)
	local c = Config.ARENA_CENTER
	local r = Config.ARENA_RADIUS
	local rng = Random.new(7)

	-- anel externo (assim o jogador não cai imediato na borda)
	for i = 1, 20 do
		local angle = i / 20 * math.pi * 2
		local pos = c + Vector3.new(math.cos(angle) * r * 0.9, 0, math.sin(angle) * r * 0.9)
		part({
			Name = "RingSlab",
			Size = Vector3.new(16, 2, 16),
			CFrame = CFrame.new(pos + Vector3.new(0, -1, 0)),
			Color = Color3.fromRGB(80, 60, 110),
			Material = Enum.Material.Rock,
			Parent = arena,
		})
	end

	-- plataforma central
	part({
		Name = "CenterIsland",
		Size = Vector3.new(26, 3, 26),
		CFrame = CFrame.new(c + Vector3.new(0, -1.5, 0)),
		Color = Color3.fromRGB(120, 80, 160),
		Material = Enum.Material.Marble,
		Parent = arena,
	})

	-- ilhas dispersas em meio ao vazio
	for i = 1, 10 do
		local angle = rng:NextNumber(0, math.pi * 2)
		local dist = rng:NextNumber(0.35, 0.72)
		local pos = c + Vector3.new(math.cos(angle) * r * dist, rng:NextNumber(-1, 3), math.sin(angle) * r * dist)
		local size = Vector3.new(rng:NextNumber(6, 12), 2, rng:NextNumber(6, 12))
		part({
			Name = "Island",
			Size = size,
			CFrame = CFrame.new(pos),
			Color = COLORS[rng:NextInteger(1, #COLORS)],
			Material = Enum.Material.SmoothPlastic,
			Parent = arena,
		})
	end

	return {
		spawns = makeSpawns(c, r, 12, 6),
		name = "islands",
	}
end

local BUILDERS = {
	classic = buildArenaClassic,
	ice = buildArenaIce,
	islands = buildArenaIslands,
}

local VARIATIONS = { "classic", "ice", "islands" }

-- ============================================================
-- API pública
-- ============================================================

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

	return { map = map }
end

-- Constroi uma arena específica (ou aleatória se name=nil) dentro de workspace.Map.Arena.
-- Retorna { spawns, name }. Destrói a arena anterior se existir.
function MapBuilder.buildArena(name: string?): { spawns: { CFrame }, name: string }
	local map = workspace:FindFirstChild("Map")
	if not map then
		MapBuilder.build()
		map = workspace.Map
	end

	local old = map:FindFirstChild("Arena")
	if old then
		old:Destroy()
	end

	local arena = Instance.new("Folder")
	arena.Name = "Arena"
	arena.Parent = map

	local chosen = name
	if not chosen or not BUILDERS[chosen] then
		chosen = VARIATIONS[math.random(1, #VARIATIONS)]
	end
	local result = BUILDERS[chosen](arena)
	ReplicatedStorage:SetAttribute("CurrentArena", result.name)
	return result
end

function MapBuilder.getVariations(): { string }
	return table.clone(VARIATIONS)
end

return MapBuilder
