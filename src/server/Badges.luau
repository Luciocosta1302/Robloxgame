-- Badges do jogo. Lê os ids em Config.BADGES. Se o id for 0, tudo é no-op.
-- Guardamos quais badges já foram concedidos no PlayerData pra não bater no
-- BadgeService toda hora (ele tem rate limit). AwardBadge pedro é idempotente
-- no lado do Roblox também, mas evitamos a chamada quando dá.

local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local PlayerData = require(script.Parent.PlayerData)

local Badges = {}

local remotes: Folder

local function trulyAward(player: Player, key: string, badgeId: number)
	local ok, hasBadge = pcall(function()
		return BadgeService:UserHasBadgeAsync(player.UserId, badgeId)
	end)
	if ok and hasBadge then
		PlayerData.markBadge(player, key)
		return
	end

	local okAward, awarded = pcall(function()
		return BadgeService:AwardBadge(player.UserId, badgeId)
	end)
	if okAward and awarded then
		PlayerData.markBadge(player, key)
		if remotes and remotes:FindFirstChild("Notify") then
			remotes.Notify:FireClient(player, "🏅 Nova badge desbloqueada!")
		end
	end
end

-- Concede um badge pelo key definido em Config.BADGES.
function Badges.award(player: Player, key: string)
	local id = Config.BADGES[key]
	if not id or id == 0 then
		return
	end
	if PlayerData.hasBadge(player, key) then
		return
	end
	task.spawn(trulyAward, player, key, id)
end

-- Callbacks que outros módulos chamam. Incrementam contadores no PlayerData
-- e concedem a badge correspondente quando bate o alvo.

function Badges.onExplode(player: Player)
	local total = PlayerData.incStat(player, "explodes") or 0
	if total == 1 then
		Badges.award(player, "FIRST_EXPLODE")
	end
end

function Badges.onWin(player: Player)
	Badges.award(player, "FIRST_WIN")
end

function Badges.onPotatoPass(player: Player)
	local total = PlayerData.incStat(player, "potatoPasses") or 0
	if total >= 50 then
		Badges.award(player, "PASS_50")
	end
end

function Badges.onRoundSurvived(player: Player)
	local total = PlayerData.incStat(player, "roundsSurvived") or 0
	if total >= 10 then
		Badges.award(player, "SURVIVE_10")
	end
end

function Badges.onDashHit(player: Player)
	local total = PlayerData.incStat(player, "successfulDashes") or 0
	if total >= 100 then
		Badges.award(player, "DASH_MASTER")
	end
end

function Badges.onSecret(player: Player)
	Badges.award(player, "SECRET")
end

function Badges.init(remoteFolder: Folder)
	remotes = remoteFolder
end

return Badges
