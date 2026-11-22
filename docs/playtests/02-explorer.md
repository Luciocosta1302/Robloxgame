# Playtest 02 — Explorer / Exploit Audit

Perfil: eng. júnior curioso + jogador mala. Foco: validação de RemoteEvents, race conditions,
idempotência e bypass de regras. Testado via leitura de cada `OnServerEvent` em `src/server`
e dos pontos de origem no `src/client`.

## Achados

1. **Race em RedeemCode duplica recompensa** — **critico** — `src/server/Codes.luau:68-96`.
   `PlayerData.hasCode` é lido do cache antes do `UpdateAsync` (yield). Dois FireServers quase
   simultâneos do mesmo code passam no gate, ambos reservam uso global e caem em
   `markCode+addCoinsRaw` → crédito dobrado. Codes sem `uses` (ex.: `tiktok`) nem têm barreira global.

2. **Fail-open quando DataStore de Codes cai** — **alto** — `src/server/Codes.luau:42-66`.
   Se `usesStore` é nil ou o `pcall(UpdateAsync)` erra, `reserveGlobalUse` retorna true.
   Durante uma falha de DataStore o cap global (ex.: `launch.uses = 10000`) é totalmente bypassado
   enquanto o DS estiver fora — "dev mode" não deveria valer em produção.

3. **`passBomb` chama `awardCoins` antes da declaração local** — **alto** — `src/server/Main.server.luau:296`
   (fn `awardCoins` só em `375`). Referência vira acesso global (nil). Toda vez que `Combat.onHit`
   dispara `passBomb`, estoura `attempt to call a nil value` sem pcall — passe + +1 moeda do passador
   quebram a cada rodada real.

4. **speedMul do modificador TURBO não é desfeito no restorer** — **alto** — `src/server/Main.server.luau:640-661`.
   O restorer só faz `charConn:Disconnect()`. WalkSpeed já multiplicada em jogadores vivos permanece após a
   rodada; sobreviventes carregam velocidade pumpada pra próxima rodada se nunca virarem holder nem morrerem.

5. **ShopEquip/Buy/Unequip sem rate limit** — **medio** — `src/server/Shop.luau:49-103,129-131`.
   Validam tipo mas não têm debounce/cooldown. Spam de FireServer rebate `pushState → SetAttribute`
   repetidamente, floodando replicação e o próprio cliente; nenhum item inexistente quebra, só gera
   trabalho/log.

6. **Dash aceita FireServer "pelado"** — **medio** — `src/server/Combat.luau:63-119` +
   `src/client/Controls.client.luau:69`. Servidor confere ragdoll/cooldown/charges mas não exige
   LinearVelocity nem posição mudada. Exploit pode parar colado na vítima e spamar `Dash:FireServer()`
   a cada 2.5s batendo knock sem movimento visual.

7. **TURBO não se aplica ao holder** — **medio** — `src/server/Main.server.luau:258-262,713`.
   `setHolder` fixa WalkSpeed = `Config.HOLDER_SPEED` (22) sem aplicar `speedMul`. Com `speedMul=1.5`,
   quem está com a batata fica **mais lento** que todo mundo — inversão do design.

8. **Dash duplo "mente" logo depois do join** — **baixo** — `src/client/Controls.client.luau:21-23`.
   Até `refreshPlayerPasses` terminar o `UserOwnsGamePassAsync`, o atributo `DashDuplo` está false;
   cliente VIP acha que só tem 1 carga, servidor concede 2. Inconsistência curta mas visível no primeiro dash da sessão.

9. **VIP atrasado é recusado no portal** — **baixo** — `src/server/Main.server.luau:100` +
   `src/server/Monetization.luau:19-52`. Primeiro Touched pode acontecer antes do pcall assíncrono
   terminar; `hasVIP=false` → "precisa do passe VIP" + prompt de compra pra quem **já comprou**.

10. **`boostedThisRound` não limpa em PlayerRemoving** — **baixo** — `src/server/Main.server.luau:174,600-607`.
    Reset só no início da rodada; jogador que sai no meio deixa o key pendurado até a próxima reset.
    Leve memory leak, sem impacto de gameplay.

11. **Rebirth sem anti-spam** — **baixo** — `src/server/Rebirth.luau:33-39`. Ignora args espúrios (ok),
    mas sem cooldown: spam de FireServer gera flood de Notify para o próprio jogador (ruído, não exploit).
    Após 25 wins, não há "pausa" — primeira chamada já concede.

12. **PromptProduct/PromptGamePass sem cooldown** — **baixo** — `src/server/Monetization.luau:204-220`.
    Nome fora do catálogo é filtrado (`Config.GAME_PASSES[which]==nil → return`), mas valid names
    podem ser spammados e o cliente recebe N prompts de compra abertos (self-DoS, tela entope).

## Cenários tratados corretamente (não viraram achado)

- `ShopBuy("coins_small_FAKE")` → `itemById[id]=nil` → return (Shop.luau:53).
- `RedeemCode` com 10000 chars → bloqueado em `#code > CODE_MAX_LENGTH` (Codes.luau:28).
- Rebirth com args extras → ignorados; tryRebirth confere `wins >= 25` (PlayerData.luau:297).
- Dev Product offline → `GetPlayerByUserId=nil` → `NotProcessedYet`, Roblox retenta (Monetization.luau:104).
- Dash durante ragdoll → `character:GetAttribute("Ragdolled")` bloqueia e **não** consome carga (Combat.luau:78).
- REVIVE_ROUND fora da janela → `tryRevive` retorna false → `NotProcessedYet` (Monetization.luau:82-92).
- FireServer com nil/tabela nos handlers tipados → type check em todos (Shop/Codes/Quests/Monetization).
- `spendCoins` nega saldo insuficiente E amount negativo (PlayerData.luau:315-324).
- VIP Portal multi-touch mesmo tick → cooldown de 2s setado antes de agir (Main.server.luau:96-99).
- VIPExitPortal funciona sem checar VIP → VIP ragdolled consegue sair (Main.server.luau:110-124).
- SecretPotato → exige `getPlayerFromCharacter` não-nil; pets (Folder ancestor) não acionam badge.

salvei em docs/playtests/02-explorer.md
