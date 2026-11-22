-- Tremor de câmera conforme o pavio queima. Intensidade proporcional a
-- Config.SHAKE_INTENSITY e ao atributo FuseProgress (0..1) de ReplicatedStorage.
-- Quem é holder treme mais; quem está perto do holder treme pouco.
-- Dica §3 da pesquisa de tendências: tensão sensorial gera clipe.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local NEAR_RADIUS = 20
local HOLDER_INTENSITY = 0.9
local NEAR_INTENSITY = 0.35

local function getHolder(): Player?
	local id = ReplicatedStorage:GetAttribute("Holder")
	if type(id) ~= "number" or id == 0 then
		return nil
	end
	return Players:GetPlayerByUserId(id)
end

local function getRoot(target: Player?): BasePart?
	if not target then
		return nil
	end
	local char = target.Character
	return char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
end

-- Tabela de offsets pseudo-aleatórios pré-calculada pra evitar jitter perfeito
local function noise(seed: number): number
	return math.sin(seed * 12.9898) * 43758.5453 % 1
end

local trauma = 0

-- BindToRenderStep com prioridade um pouco maior que a da câmera para que o
-- shake seja aplicado DEPOIS do controlador da câmera sobrescrever CFrame.
RunService:BindToRenderStep("BatataCameraShake", Enum.RenderPriority.Camera.Value + 1, function(dt)
	local progress = ReplicatedStorage:GetAttribute("FuseProgress") or 0
	if type(progress) ~= "number" or progress <= 0 then
		-- decaimento rápido quando não tem pavio ativo
		trauma = math.max(0, trauma - dt * 4)
	else
		local holder = getHolder()
		local baseIntensity = 0
		if holder == player then
			baseIntensity = HOLDER_INTENSITY
		elseif holder then
			local a = getRoot(player)
			local b = getRoot(holder)
			if a and b and (a.Position - b.Position).Magnitude < NEAR_RADIUS then
				baseIntensity = NEAR_INTENSITY
			end
		end
		-- curva: quase nada no começo, cresce forte no fim
		local target = baseIntensity * progress * progress
		trauma = trauma + (target - trauma) * math.min(1, dt * 8)
	end

	if trauma <= 0.001 then
		return
	end

	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	-- Shake: offset pequeno + rotação em torno do look-vector
	local t = os.clock() * 40
	local shake = Vector3.new(
		(noise(t) - 0.5) * 2,
		(noise(t + 10) - 0.5) * 2,
		(noise(t + 20) - 0.5) * 2
	) * trauma * 0.25
	local roll = (noise(t + 30) - 0.5) * trauma * 0.04

	camera.CFrame = camera.CFrame
		* CFrame.new(shake)
		* CFrame.Angles(0, 0, roll)
end)
