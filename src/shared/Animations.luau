-- Helper de animação. Lê os ids em Config.ANIMATIONS.
-- Se o id for 0, as funções viram no-op em vez de dar erro.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(script.Parent.Config)

local Animations = {}

local trackCache: { [Instance]: { [number]: AnimationTrack } } = {}

local function getAnimator(character: Model): Animator?
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil
	end
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	return animator
end

local function loadTrack(character: Model, id: number): AnimationTrack?
	if id == 0 then
		return nil
	end
	local animator = getAnimator(character)
	if not animator then
		return nil
	end

	local bucket = trackCache[character]
	if not bucket then
		bucket = {}
		trackCache[character] = bucket
		character.AncestryChanged:Once(function()
			trackCache[character] = nil
		end)
	end
	if bucket[id] then
		return bucket[id]
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. id
	local track = animator:LoadAnimation(anim)
	bucket[id] = track
	return track
end

function Animations.play(character: Model, name: string, options: { priority: Enum.AnimationPriority?, looped: boolean?, speed: number?, weight: number?, fade: number? }?)
	local id = Config.ANIMATIONS[name]
	if not id or id == 0 then
		return nil
	end
	local track = loadTrack(character, id)
	if not track then
		return nil
	end
	if options then
		if options.priority then
			track.Priority = options.priority
		end
		if options.looped ~= nil then
			track.Looped = options.looped
		end
	end
	track:Play(options and options.fade or 0.1, options and options.weight or 1, options and options.speed or 1)
	return track
end

function Animations.stop(character: Model, name: string, fadeTime: number?)
	local id = Config.ANIMATIONS[name]
	if not id or id == 0 then
		return
	end
	local bucket = trackCache[character]
	local track = bucket and bucket[id]
	if track and track.IsPlaying then
		track:Stop(fadeTime or 0.1)
	end
end

function Animations.stopAll(character: Model, fadeTime: number?)
	local bucket = trackCache[character]
	if not bucket then
		return
	end
	for _, track in bucket do
		if track.IsPlaying then
			track:Stop(fadeTime or 0.1)
		end
	end
end

return Animations
