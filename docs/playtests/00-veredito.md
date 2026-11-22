# Veredito — Batata Quente Ragdoll

## 1. TL;DR
**Não lançar público ainda.** Há dois bugs de forward-declaration em `Main.server.luau` que fazem o servidor crashar **a cada passe e a cada explosão** — o jogo não roda uma rodada inteira. Depois desses fixes e dos 7 bloqueantes abaixo, dá pra abrir em soft-launch; antes disso qualquer impressão do jogador é falsa.

## 2. Top 5 problemas (severidade = criticidade × probabilidade)

1. **`awardCoins` / `currentModifier` usados antes de serem declarados**
   QA + Explorer — `src/server/Main.server.luau:296` (passBomb), `:433` e `:456` (explode); declarações só em `:375` / `:610`.
   Fix: mover `local function awardCoins` e `local currentModifier` para acima de `passBomb`.

2. **ReviveUI engana criança com "R$" sem avisar que é Robux real**
   Iniciante — `src/client/ReviveUI.client.luau:66–104`.
   Fix: trocar o label para "REVIVER (ROBUX de verdade — preço X)" + segundo clique de confirmação, igual Rebirth.

3. **`processReceipt` não é atômico — duplo crédito em retries concorrentes**
   QA — `src/server/Monetization.luau:103–120`.
   Fix: marcar `PurchaseId` em set in-flight **antes** do `grantProduct`.

4. **Race em RedeemCode duplica moedas (e fail-open quando DataStore cai)**
   Explorer + QA — `src/server/Codes.luau:42–66, 68–96`.
   Fix: reservar global **antes** do `hasCode`, retornar `false` em erro de DataStore, e usar chave `player_code` global pra bloquear cross-server.

5. **Modificador TURBO: `speedMul` não é restaurado e não se aplica ao holder**
   QA + Explorer — `src/server/Main.server.luau:258–262, 640–657`.
   Fix: guardar WalkSpeed original por char e reaplicar em `setHolder`; desconectar todos os `CharacterAdded` ao final da rodada.

## 3. CORRIGIR ANTES DE DAR PÚBLICO (ordem obrigatória)

1. `Main.server.luau:296, 433, 456` — forward-decl de `awardCoins` e `currentModifier` (**bloqueia tudo**; sem isso 2–7 não dá pra validar).
2. `Monetization.luau:103–120` — `processReceipt` atômico.
3. `Codes.luau:42–66, 68–96` — fail-closed + ordem reserva→hasCode.
4. `ReviveUI.client.luau:66–104` — label "Robux", preço real via `GetProductInfo`, confirmação dupla.
5. `Main.server.luau:88–107` — portal VIP não deve disparar `promptPurchaseGamePass` automático; prompt só via botão interno com preço.
6. `Main.server.luau:258–262 + 640–657` — TURBO: aplicar ao holder e restaurar WalkSpeed.
7. `Rebirth.luau:33–39` + `Main.server.luau runRound` — bloquear rebirth enquanto `roundActive=true`.
8. `Cosmetics.luau:247` + `:210–214` — desconectar `AncestryChanged` do apply anterior e limpar Attachment em HRP.
9. `Main.server.luau:529, 724` — só `SetAttribute` quando o inteiro muda (ArenaRadius/FuseProgress inundam replicação).

## 4. PODE ESPERAR (não-bloqueante)

**UX / onboarding**
- Sidebar de 7 botões → 2 + "➕ MAIS", Rebirth escondido até 1ª vitória (HUD.client.luau:118–165).
- "REBIRTH" / "CHAMA" / "CÓDIGO" com rótulos infantis + ícones (HUD:161, RebirthUI:115).
- `DailyUI:141` "VOLTA DEPOIS" com timer colorido.
- Tutorial "Q = empurra" piscando na 1ª rodada (HUD:89).
- Modificador de rodada precisa de legenda (HUD:239).
- Pós-morte: dar algo pra fazer enquanto espera.
- `Cosmetics.applyToBomb`: setar `CosmeticBase` pra skins não sumirem no blink (Main:729).

**Performance**
- `Combat.luau:97` iterar `alive` server-side, hits a 30 Hz.
- `Leaderboard.nameCache` / `Monetization.ownsPassCache` / `VIPCoin lastCoin` / `boostedThisRound` — bounds + limpar em `PlayerRemoving`.
- `PlayerData.processedReceipts` compactar antes do `save` (:380).

**Hardening**
- `ShopBuy/Equip/Unequip`, `PromptProduct`, `Rebirth` sem cooldown — adicionar debounce.
- Dash aceita FireServer sem movimento (Combat:63–119) — exigir Δposição mínima.
- `DashDuplo` race pós-join (Controls.client:21).
- VIP primeiro Touched antes do pcall (Main:100).
- Migração `BatataQuente_v1 → v2` no primeiro load (PlayerData:9).
- `MapBuilder.buildArena` sem pcall (Main:454).
- Mutação de `alive` durante iteração (Main:316/604) — coletar vítimas antes.
- `Cosmetics.applyToCharacter` esperar data loaded (:587).
- Dança do winner cortada pelo LoadCharacter (:781).

**Discordâncias com testadores**
- QA chamou `Codes.luau:28` (ordem #/gsub) de MÉDIO — na prática é cosmético, vai pra "Pode esperar".
- Explorer #11 "Rebirth sem anti-spam" é BAIXO, concordo — ruído, não exploit.

## 5. Retenção D1
- **Hoje:** ~5–8%. Qualquer rodada crasha no `awardCoins`; players veem notify quebrado, moedas de passe não pingam, Rebirth em inglês trava a sidebar, e o Revive leva pro popup de Robux sem aviso — review-bombing garantido.
- **Depois dos 9 bloqueantes:** ~15–20%, dentro da faixa do nicho casual Roblox. Para empurrar pra 25%+ precisa dos itens de UX (sidebar enxuta, tutorial de Q, Rebirth escondido até 1ª vitória).

## 6. Primeira coisa pra consertar hoje
**Mover `local function awardCoins` e `local currentModifier` para antes de `passBomb` em `src/server/Main.server.luau:287`.**
Custo: 2 minutos, 1 commit, zero risco. Impacto: desbloqueia toda a stack de playtest — sem isso nenhum outro fix pode ser verificado em runtime, porque o servidor estoura em cada passe e em cada explosão.

---

salvei em docs/playtests/00-veredito.md
