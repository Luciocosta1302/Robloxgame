# Plano de Monetização — Batata Quente Ragdoll

Este é o plano das **5 primeiras coisas a implementar em ordem**, depois do que já
foi codado nesta sessão (Game Pass VIP, Dash Duplo, Dev Products de moedas,
"Explode everyone", loja de cosméticos, recompensa diária, vídeo com recompensa
opcional, animações por id).

Princípio não-negociável: **sem pay-to-win**. Dinheiro só compra cosmético,
conveniência pequena (dash duplo não decide rodada), ou multiplicador de moedas
para gastar em cosmético. Quem paga nunca ganha rodada só por pagar.

Baseado nas pesquisas em `docs/pesquisa/` — leia-as antes de mudar qualquer coisa.

---

## Passo 1 — Criar os assets no Creator Hub e colar os IDs

Isto é **o único passo bloqueante**: todo o código de monetização já está
pronto, mas não aparece no jogo enquanto `Config.luau` tiver `0` nos IDs. Vai lá
em **create.roblox.com → sua experiência**:

1. **Monetization → Passes** — criar 2 passes:
   - `Batata VIP` · **99 Robux** (começa barato pra testar conversão; +50% moedas
     e brilho dourado).
     Preço histórico recomendado: 49–199 R$ para passes "VIP introdutório"
     (ver `docs/pesquisa/moda.md` §3).
   - `Dash Duplo` · **149 Robux** · dois dashes seguidos antes do cooldown.
   - Cole os IDs em `Config.GAME_PASSES.VIP` e `Config.GAME_PASSES.DASH_DUPLO`.

2. **Monetization → Developer Products** — criar 4 produtos:
   - `Pacote de 500 moedas` · **29 Robux** → `COINS_SMALL`
   - `Pacote de 1500 moedas` · **79 Robux** → `COINS_MEDIUM`
   - `Pacote de 5000 moedas` · **249 Robux** → `COINS_LARGE`
   - `Explode Todo Mundo` · **49 Robux** → `EXPLODE_EVERYONE`
   - Cole os IDs em `Config.DEV_PRODUCTS`. O `DEV_PRODUCT_REWARDS` já está
     mapeado por chave para não quebrar quando os IDs trocarem.

3. **Creations → Animations** — publicar 5 animações no grupo do jogo:
   `VICTORY`, `STAND_UP`, `PUSH`, `PANIC`, `EXPLODE`. Veja
   `docs/pesquisa/animacoes.md` §4 para prioridade, duração sugerida e quando
   cada uma dispara. Cole os IDs em `Config.ANIMATIONS`.

4. **Sounds** — na Toolbox do Studio, pegue 6 sons (ou publique seus): `TICK`,
   `EXPLOSION`, `VICTORY`, `COIN`, `BUY`, `WHOOSH`. Cole em `Config.SOUNDS`.

5. **Settings → Permissions → Allow private servers** — ative com **25 Robux/mês**
   (mínimo 10, taxa 30%). Fica como receita passiva de "jogos de amigos".

6. **Settings → Monetization → Opt in to Creator Rewards** — substituiu Premium
   Payouts em jul/2025. Paga pelo tempo que jogadores Premium passam no seu
   jogo (`docs/pesquisa/monetizacao.md` §5).

Depois do passo 1, 90% da monetização que já está no código começa a aparecer.

---

## Passo 2 — Sons + câmera tremendo + tremor na UI (polir o "feel")

Sem isso, o jogo não dá clipe pro TikTok. Com isso, cada explosão vira
compartilhamento.

- `src/shared/SoundPlay.luau` — helper `SoundPlay.at(position, name, volume)`
  que cria um Sound no Terrain na posição do evento, toca, destrói. Lê de
  `Config.SOUNDS`; se id for 0, no-op (não quebra).
- Tocar `TICK` no `bomb` com `PlaybackSpeed` aumentando conforme o pavio queima
  (ciclo: `0.8 + progress * 1.2`).
- Tocar `EXPLOSION` em `explode()` na posição do boom.
- Tocar `VICTORY` no vencedor; `COIN` ao ganhar moeda; `BUY` ao comprar na loja.
- Câmera tremendo no cliente: quando o jogador está a <20 studs da batata com
  pavio quase no fim, aplicar `Workspace.CurrentCamera.CFrame *= CFrame.new(shake)`
  no RenderStepped com intensidade proporcional ao progresso.
- Partícula extra no `makeExplosionFX` mesmo sem explosão custom.

Esforço: 1 tarde. Impacto no retention: alto.

---

## Passo 3 — Badges + Códigos promocionais

Os dois clássicos de retenção com ROI mais alto por hora de código
(`docs/pesquisa/classicos-roblox.md`).

- **Badges** (Creator Hub → Badges, 100 R$/badge até os 1000 primeiros, depois
  grátis). Criar 6:
  1. Primeira Explosão — jogador explode uma vez.
  2. Primeira Vitória — ganha uma rodada.
  3. Passou a Batata 50x.
  4. Sobreviveu 10 rodadas.
  5. Ragdoll Master — 100 dashes acertados.
  6. Easter egg: achar o botão escondido no lobby.
  - `src/server/Badges.luau` com `Badges.award(player, "FirstWin")` e tabela
    mapeando chave → id. IDs em `Config.BADGES`. Chama no ponto certo
    (`addWin`, `eliminate`, `onHit`).

- **Códigos promocionais** — `src/server/Codes.luau` com tabela:
  ```lua
  { LAUNCH = { coins = 100, uses = 10000, expires = os.time() + 7*86400 },
    BATATA1K = { coins = 250, uses = 5000 },
    TIKTOK = { coins = 50, uses = nil } }
  ```
  - RemoteEvent `RedeemCode(player, code)`, servidor valida tipo string,
    comprimento ≤ 32, lowercase, compara. Guarda em `PlayerData.codesClaimed`
    para o jogador não pegar duas vezes. **Limite de resgates globais é gravado
    em `OrderedDataStore`** para não inflar, com `UpdateAsync` atômico.
  - Botão "CÓDIGOS" no HUD, modal com input. UI em português.

Esforço: 1 fim de semana. Impacto: viraliza (poste código no TikTok com meta
de likes).

---

## Passo 4 — Convite de amigo + leaderboard global

K-factor quase de graça (`docs/pesquisa/classicos-roblox.md`).

- **Convite de amigo**: o Roblox já tem a API oficial
  `Players:PromptGameInvite(player)` e `GetJoinData().ReferredByPlayerId`
  desde 2025. No servidor:
  - Quando um jogador entra com `ReferredByPlayerId`, dá +200 moedas pros dois
    (uma vez por par, guarda em DataStore).
  - Botão "CONVIDAR" no HUD que chama `PromptGameInvite`.
- **Leaderboard global**: `OrderedDataStore` separado `BatataWinsOrdered_v1`,
  update a cada vitória. Painel global no lobby mostra top 100 com
  `GetSortedAsync`.
- **Mural de vitórias** no lobby (SurfaceGui + reflexão de top 10).

Esforço: 2 fins de semana. Impacto: cada jogador traz 0,3–0,8 amigo novo.

---

## Passo 5 — Loja in-round (revive com Robux) + sala VIP

Monetização "evento quente" — jogador prestes a perder tem o impulso de gastar.
Cuidado para **não ser pay-to-win**: revive custa Robux, mas não garante
vitória nem restaura progresso nas rodadas anteriores.

- Dev Product `REVIVE_ROUND` · **35 Robux**: quando o jogador for
  `eliminate()`-ado, aparece um modal "pagar 35 R$ para voltar na próxima
  batata". Se aceitar antes da próxima batata ser criada, o servidor marca
  `alive[player] = true` de novo, `LoadCharacter`, reentra nessa mesma rodada.
  Compra é de **uma vez por rodada** (guardar em `revivesThisRound[player]`).
- Dev Product `COIN_BOOST_ROUND` · **19 Robux**: 2x moedas naquela rodada só.
- **Sala VIP no lobby**: parte acessível só para quem tem o `VIP` Game Pass
  (`MarketplaceService:UserOwnsGamePassAsync`). Portal no lobby com trigger
  `Touched` que testa a ownership — se tem, teleporta para uma área com um
  mini-jogo de cofrinho (clique → +1 moeda a cada 5s). Se não tem, abre o
  prompt de compra.
- Expor isso tudo pelo **mesmo** `Monetization.luau` que já existe.

Esforço: 1 fim de semana. Impacto: ARPPU sobe ~20–40% segundo benchmarks de
party games citados em `docs/pesquisa/moda.md` §3.

---

## O que vem depois (semana 6+)

Em ordem de prioridade:

- **UGC do jogo** (chapéu de batata, trilha de fogo como item de avatar).
  Requer verificação de ID adulto no Creator Hub e **R$ 80 por upload**
  (`docs/pesquisa/monetizacao.md` §8).
- **Admin abuse semanal** — você entra ao vivo numa sexta à noite com uma batata
  gigante, grava, posta. ROI altíssimo com custo zero.
- **Evento sazonal** (Natal, Carnaval) com skin de batata exclusiva do mês e
  badge cronometrada.
- **Subscription** mensal (49 Robux/mês) com +300 moedas/dia e cor exclusiva no
  nome. Floor do Roblox é 49 R$/mês (`docs/pesquisa/monetizacao.md` §4).
- **Anúncios** (Sponsored Experiences) só quando a retenção D1 passar de 20%.
  Antes disso é jogar dinheiro fora.

## Regras obrigatórias que vão junto

- **Odds disclosure** — se um dia você vender qualquer caixa/roleta com prêmio
  aleatório pago em Robux, precisa mostrar a probabilidade exata de cada prêmio.
  O Brasil entrou na lista de países restritos em 26/mai/2026
  (`docs/pesquisa/monetizacao.md` §11). Fuja de caixas aleatórias no começo.
- **Público infantil** — o jogo é party ragdoll, provavelmente vai cair em "Mild
  Violence" (OK). Não suba para violência realista — o Roblox tirou 4 jogos
  "Hyper Realistic Ragdoll" do ar em nov/2026 (`docs/pesquisa/tendencias.md`).
- **ProcessReceipt idempotente** — `Monetization.luau` já faz isso usando
  `PlayerData.wasReceiptProcessed(PurchaseId)`. Nunca remova esse check.
- **DevEx (quando chegar lá)** — a conversão é hoje US$ 0,0038/Robux (US$ 0,0054
  pra gasto originado nos EUA 18+). Para sacar você precisa de **100 000 Robux
  earned**, conta verificada por ID, ter 13+ (vão exigir 18+ cedo ou tarde),
  e um W-8BEN cadastrado para evitar retenção dupla. Pagamento pelo Tipalti
  cai no PayPal/conta em até 30 dias. No Brasil é **Carnê-Leão** mensal,
  DARF 0190, alíquota IR progressiva. **MEI não cobre esse tipo de receita**.
  Detalhes em `docs/pesquisa/monetizacao.md` §10.
