local RunService = game:GetService("RunService")

local Config = {}

-- ============================================================
-- Jogabilidade
-- ============================================================
Config.MIN_PLAYERS = if RunService:IsStudio() then 1 else 2
Config.INTERMISSION = 15

Config.FUSE_MIN = 10
Config.FUSE_MAX = 18
Config.PASS_DISTANCE = 5
Config.PASS_COOLDOWN = 0.7

Config.NORMAL_SPEED = 16
Config.HOLDER_SPEED = 22

Config.DASH_COOLDOWN = 2.5
Config.DASH_SPEED = 85
Config.DASH_TIME = 0.3
Config.DASH_HIT_DISTANCE = 5.5
Config.DASH_PUSH = 60

Config.RAGDOLL_TIME = 1.6
Config.BLAST_RADIUS = 14
Config.BLAST_FORCE = 110
Config.FALL_Y = -40

Config.COINS_PASS = 1
Config.COINS_SURVIVE = 5
Config.COINS_WIN = 50

Config.LOBBY_CENTER = Vector3.new(0, 0, 0)
Config.ARENA_CENTER = Vector3.new(0, 0, 300)
Config.ARENA_RADIUS = 70

-- ============================================================
-- Monetização — TODOS os IDs ficam 0 até você criar no Creator Hub.
-- Nunca invente IDs. Siga as instruções do fim deste arquivo.
-- ============================================================

-- Game Passes — Creator Hub → sua experiência → Monetization → Passes
-- Cada passe é permanente; cobre com PromptGamePassPurchase.
Config.GAME_PASSES = {
	VIP = 0,         -- efeito dourado + Config.VIP_COIN_MULTIPLIER no ganho de moedas
	DASH_DUPLO = 0,  -- 2 dashes em sequência antes do cooldown
}
Config.VIP_COIN_MULTIPLIER = 1.5
Config.DASH_DUPLO_CHARGES = 2

-- Developer Products — Creator Hub → Monetization → Developer Products
-- Consumíveis; cobra com PromptProductPurchase e precisa de ProcessReceipt.
Config.DEV_PRODUCTS = {
	-- Pacotes de moedas (não é pay-to-win: moedas só compram cosméticos)
	COINS_SMALL = 0,   -- 500 moedas
	COINS_MEDIUM = 0,  -- 1 500 moedas
	COINS_LARGE = 0,   -- 5 000 moedas

	-- Troll só visual: faz todo mundo cair no ragdoll por 2s. NÃO passa a batata,
	-- NÃO conta para vitória, NÃO elimina ninguém. É só palhaçada pra clipe.
	EXPLODE_EVERYONE = 0,
}

-- Quanto cada Developer Product entrega. O ProcessReceipt lê desta tabela.
-- Se o id ficar 0, o produto não é oferecido na UI.
Config.DEV_PRODUCT_REWARDS = {
	[Config.DEV_PRODUCTS.COINS_SMALL] = { kind = "coins", amount = 500 },
	[Config.DEV_PRODUCTS.COINS_MEDIUM] = { kind = "coins", amount = 1500 },
	[Config.DEV_PRODUCTS.COINS_LARGE] = { kind = "coins", amount = 5000 },
	[Config.DEV_PRODUCTS.EXPLODE_EVERYONE] = { kind = "troll_explode" },
}

-- ============================================================
-- Catálogo da loja (compra com moedas do jogo). Sem pay-to-win:
-- tudo aqui é cosmético, não muda a jogabilidade.
-- ============================================================
Config.COSMETICS = {
	-- Trilhas (trails) nos pés
	{ id = "trail_fogo",         name = "Trilha de Fogo",        price = 200,  kind = "trail",     rarity = "comum",    payload = { color1 = Color3.fromRGB(255, 160, 40),  color2 = Color3.fromRGB(255, 60, 0) } },
	{ id = "trail_arco_iris",    name = "Trilha Arco-Íris",      price = 600,  kind = "trail",     rarity = "raro",     payload = { rainbow = true } },
	{ id = "trail_estrela",      name = "Trilha de Estrelas",    price = 1000, kind = "trail",     rarity = "épico",    payload = { color1 = Color3.fromRGB(255, 250, 120), color2 = Color3.fromRGB(180, 160, 255) } },

	-- Skins da batata
	{ id = "skin_batata_ouro",   name = "Batata de Ouro",        price = 800,  kind = "potato",    rarity = "raro",     payload = { color = Color3.fromRGB(255, 215, 60),  material = "Neon" } },
	{ id = "skin_batata_pedra",  name = "Batata Pedra",          price = 400,  kind = "potato",    rarity = "comum",    payload = { color = Color3.fromRGB(120, 120, 120), material = "Slate" } },
	{ id = "skin_batata_meteoro", name = "Batata Meteoro",       price = 1500, kind = "potato",    rarity = "épico",    payload = { color = Color3.fromRGB(80, 20, 20),    material = "CorrodedMetal", extraFire = true } },
	{ id = "skin_batata_melancia", name = "Batata Melancia",     price = 700,  kind = "potato",    rarity = "raro",     payload = { color = Color3.fromRGB(200, 40, 60),   material = "Grass" } },

	-- Efeitos de explosão (só visual, mesma força)
	{ id = "fx_explosion_arco_iris", name = "Explosão Arco-Íris", price = 900,  kind = "explosion", rarity = "raro",     payload = { rainbow = true } },
	{ id = "fx_explosion_coracao",   name = "Explosão de Coração", price = 1200, kind = "explosion", rarity = "épico",   payload = { color = Color3.fromRGB(255, 100, 180) } },

	-- Auras (brilho em volta do holder)
	{ id = "aura_dourada",       name = "Aura Dourada",          price = 1500, kind = "aura",      rarity = "épico",    payload = { color = Color3.fromRGB(255, 220, 80) } },

	-- Chapéus simples (parts clonadas)
	{ id = "chapeu_festa",       name = "Chapéu de Festa",       price = 150,  kind = "hat",       rarity = "comum",    payload = { shape = "cone", color = Color3.fromRGB(255, 80, 150) } },
	{ id = "chapeu_coroa",       name = "Coroa",                 price = 1200, kind = "hat",       rarity = "épico",    payload = { shape = "crown", color = Color3.fromRGB(255, 215, 60) } },

	-- Títulos (texto acima do nome)
	{ id = "titulo_lenda",       name = "Título: LENDA",         price = 2500, kind = "title",     rarity = "lendário", payload = { text = "LENDA",     color = Color3.fromRGB(255, 220, 80) } },
	{ id = "titulo_tombo",       name = "Título: CAI-CAI",       price = 400,  kind = "title",     rarity = "comum",    payload = { text = "CAI-CAI",   color = Color3.fromRGB(180, 180, 180) } },
	{ id = "titulo_fritador",    name = "Título: FRITADOR",      price = 1000, kind = "title",     rarity = "raro",     payload = { text = "FRITADOR",  color = Color3.fromRGB(255, 120, 60) } },
}

-- ============================================================
-- Animações — crie em create.roblox.com/dashboard/creations → Animations
-- Cole o id numérico (sem "rbxassetid://").
-- ============================================================
Config.ANIMATIONS = {
	VICTORY = 0,   -- dança curta quando vence
	STAND_UP = 0,  -- levantar do ragdoll
	PUSH = 0,      -- braços pra frente no dash
	PANIC = 0,     -- loop curto enquanto segura a batata
	EXPLODE = 0,   -- pose dramática no momento da explosão
}

-- ============================================================
-- Sons — ache no Toolbox do Studio ou publique seus.
-- Cole o id numérico (sem "rbxassetid://").
-- ============================================================
Config.SOUNDS = {
	TICK = 0,       -- tique do pavio (loopa, acelera perto do fim)
	EXPLOSION = 0,  -- boom
	VICTORY = 0,    -- fanfarra curta
	COIN = 0,       -- bling ao ganhar moeda
	BUY = 0,        -- som de compra na loja
	WHOOSH = 0,     -- dash
}

-- ============================================================
-- Recompensa diária (dia 1 → dia 7, depois reinicia)
-- ============================================================
Config.DAILY_REWARDS = { 25, 50, 100, 150, 250, 400, 1000 }
Config.DAILY_WINDOW_MIN = 20 * 3600   -- precisa ter passado 20h desde a última
Config.DAILY_WINDOW_MAX = 48 * 3600   -- se passou de 48h, streak reseta

-- ============================================================
-- Vídeo com recompensa (RewardedAds). A API pode não estar
-- disponível em todos os canais; o módulo que lê isto checa em
-- runtime e desliga a UI se não der.
-- ============================================================
Config.REWARDED_AD_COINS = 50
Config.REWARDED_AD_COOLDOWN = 15 * 60  -- 15 min entre vídeos por jogador

return Config
