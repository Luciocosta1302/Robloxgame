-- Funil de retenção (dica §1 do devlog BR). Usa AnalyticsService nativo quando
-- existe; cai pro silêncio quando não existe (ex.: canal antigo). No Creator
-- Hub, crie o funil "onboarding_v1" com os passos listados em STEPS pra ver
-- os números.

local Players = game:GetService("Players")

local Analytics = {}

local AnalyticsService: any = nil
pcall(function()
	AnalyticsService = game:GetService("AnalyticsService")
end)

local FUNNEL = "onboarding_v1"
local STEPS = {
	joined = 1,
	saw_first_round = 2,
	survived_first_round = 3,
	first_win = 4,
	opened_shop = 5,
}

local fired: { [Player]: { [string]: boolean } } = {}

function Analytics.step(player: Player, name: string)
	local index = STEPS[name]
	if not index then
		return
	end
	local bucket = fired[player]
	if not bucket then
		bucket = {}
		fired[player] = bucket
	end
	if bucket[name] then
		return
	end
	bucket[name] = true
	if AnalyticsService and typeof(AnalyticsService.LogFunnelStepEvent) == "function" then
		pcall(function()
			AnalyticsService:LogFunnelStepEvent(player, FUNNEL, nil, index, name)
		end)
	end
end

function Analytics.init()
	Players.PlayerRemoving:Connect(function(player)
		fired[player] = nil
	end)
end

return Analytics
