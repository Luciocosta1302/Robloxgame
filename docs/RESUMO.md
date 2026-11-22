# Resumo — pesquisa e implementação

Tudo em português. Dev é brasileiro, 18 anos.

## O que foi pesquisado

Sete relatórios em `docs/pesquisa/`, cada afirmação com link:

| Arquivo | Linhas | Resumo |
| --- | --- | --- |
| `skills.md` | 368 | Skills, MCP oficial do Studio, CLIs (Rojo 7.7, Rokit 1.1, Selene 0.32, StyLua 2.5, Wally, Jest-Lua), IA do Roblox. Comandos exatos de instalação. |
| `animacoes.md` | 222 | Como criar/publicar animação, Moon Animator pago, captura por câmera, Mixamo. Como carregar por código (Animator, não Humanoid:LoadAnimation). 5 animações propostas para o jogo. |
| `moda.md` | 128 | Tendências Y2K/Clean Girl, criadores UGC de destaque. 16 cosméticos na loja proposta com preço em moedas e Robux (49/99/199/399/599 R$). |
| `tendencias.md` | 163 | Top do Roblox hoje. Alerta: Roblox puniu 4 jogos "Hyper Realistic Ragdoll" em nov/2026 — manter Mild Violence. Padrões vencedores (título-verbo curto, ícone com cara expressiva, loop <5 min). Sugestões de título em inglês. |
| `monetizacao.md` | 542 | **O doc mais importante.** 12 seções: Game Pass, Dev Product, Private Servers, Subscriptions, Creator Rewards (substituiu Premium Payouts em jul/2025), Rewarded Ads, Ads Manager, UGC Marketplace, Commerce, **DevEx no Brasil** (Carnê-Leão, por que MEI não serve, não há tratado BR-EUA), regras obrigatórias (odds disclosure, Brasil na lista desde mai/2026). Tabela final por fonte de renda. |
| `steam-oportunidades.md` | 409 | 15 candidatos Steam mai–nov/2026. Top 3 escolhidos e redesenhados com temática brasileira (folclore/meme): *"Senhor, Temos um Problema de Saci"*, *"Desce a Ladeira!"*, *"Treta no Sacolão do Zé"*. Cada um com design completo e MVP de 2–3 semanas. |
| `classicos-roblox.md` | 316 | 12 clássicos (emotes, easter eggs, loja in-round, códigos, badges, daily, grupo/VIP, pets/rebirth, eventos, leaderboard global, música sem copyright, avatar). Descoberta-chave: **Admin War** foi o gancho de engajamento de 2025 (47,4 M CCU). Tabela de prioridade + esforço. |

## O que foi implementado no código

Mudanças em `src/` (tudo respeitando o CLAUDE.md: servidor é autoridade, `Config.luau` guarda números, nenhum ID inventado).

**Novos módulos servidor** (`src/server/`):

- `Monetization.luau` — `MarketplaceService:UserOwnsGamePassAsync` com cache, `PromptGamePassPurchaseFinished`, **ProcessReceipt idempotente** (por `PurchaseId` salvo em DataStore). Atributos `VIP` e `DashDuplo` no player.
- `Shop.luau` — loja de cosméticos em moedas do jogo. Valida compras no servidor, salva `owned` e `equipped` via `PlayerData`. Replica estado via atributos `OwnedCosmetics` e `Equipped_<kind>`.
- `Cosmetics.luau` — aplica os cosméticos equipados no personagem (trilha, aura, chapéu, título) e na batata (skin + extra fire). VIP ganha brilho dourado e título ⭐ de cortesia.
- `DailyReward.luau` — recompensa diária 7 dias, com streak. Janela 20h–48h. Botão "DIÁRIO" no HUD piscando um ponto vermelho quando pode resgatar.
- `RewardedAds.luau` — detecta em runtime se `AdService:PromptAd` ou `ShowRewardedVideoAd` existem; se existir, concede +50 moedas com cooldown de 15 min. Se não existir no canal, o botão fica escondido.

**Módulo shared novo**:

- `Animations.luau` — helper `play(character, "VICTORY", opts)` que lê de `Config.ANIMATIONS`. Se o id for `0`, é no-op (não quebra o jogo até você publicar os arquivos de animação).

**Arquivos reescritos**:

- `Config.luau` — todos os IDs (`GAME_PASSES`, `DEV_PRODUCTS`, `DEV_PRODUCT_REWARDS`, `ANIMATIONS`, `SOUNDS`), catálogo `COSMETICS` com 15 itens, parâmetros de loja/daily/ad/VIP.
- `PlayerData.luau` — ganhou `cosmetics`, `equipped`, `dailyStreak`, `processedReceipts` (até 128 últimos ids), `lastRewardedAd`. DataStore virou `BatataQuente_v2`. Autosave a cada 60 s.
- `Combat.luau` — dash com **cargas** (1 ou 2 se tiver Dash Duplo). Toca animação `PUSH` e `STAND_UP` após levantar.
- `Main.server.luau` — orquestra os novos módulos, aplica cosméticos no `CharacterAdded`, toca animações de `PANIC` (holder), `EXPLODE` (vítima) e `VICTORY` (vencedor). Função `trollExplode` só visual.
- `Controls.client.luau` — cliente também respeita cargas do dash.
- `HUD.client.luau` — barra lateral com botões 🛒 Loja, 🎁 Diário, 🎬 Vídeo (só visível se o canal tiver `AdService`). Badge vermelha no diário.
- `ShopUI.client.luau` (novo) — painel com grid, cartões por raridade, botões Comprar/Equipar/Equipado.
- `DailyUI.client.luau` (novo) — 7 dias com destaque do streak, contador até o próximo resgate.

**Skill do projeto**: `.claude/skills/roblox-dev/SKILL.md` com 11 regras (autoridade do servidor, Config.luau, sem IDs inventados, validação de Remote, APIs atuais, checklist final).

**Plano**: `docs/plano-monetizacao.md` com as 5 próximas tarefas em ordem, com preços sugeridos e estimativa de esforço/impacto.

## Nenhum ID foi inventado

Tudo o que foi codado tem o ID `0` no `Config.luau` com um comentário dizendo o que criar no Creator Hub. O jogo já roda assim — os botões aparecem, só não têm o produto do outro lado. O **Passo 1** do `docs/plano-monetizacao.md` é a lista exata do que criar e onde colar cada id.

## O que você precisa fazer no Creator Hub (passo a passo)

1. Publicar o jogo em `create.roblox.com` (se ainda não publicou). Vai em
   "Create" → nova experience → importar `default.project.json` via Rojo.
2. **Monetization → Passes** → criar `Batata VIP` (99 R$) e `Dash Duplo`
   (149 R$). Cole os ids em `Config.GAME_PASSES`.
3. **Monetization → Developer Products** → criar 4 produtos: `Pacote de 500
   moedas` (29 R$), `Pacote de 1500 moedas` (79 R$), `Pacote de 5000 moedas`
   (249 R$), `Explode Todo Mundo` (49 R$). Cole os ids em `Config.DEV_PRODUCTS`.
4. **Settings → Permissions → Private servers** → ativar com 25 R$/mês.
5. **Settings → Monetization → Creator Rewards** → opt-in.
6. **Creations → Animations** → publicar as 5 animações e colar ids em `Config.ANIMATIONS`. Veja `docs/pesquisa/animacoes.md` §4 pra quais fazer.
7. **Toolbox** do Studio → pegar 6 sons e colar ids em `Config.SOUNDS`.

Detalhes e justificativa de cada preço: `docs/plano-monetizacao.md` Passo 1.

## Quanto dá pra ganhar realistamente

Sendo direto, baseado nos benchmarks das pesquisas:

- **Mês 1 (até 500 jogadores simultâneos e <20k visits/dia)**: ~R$ 50–300/mês.
  A maior parte vem de 1–3 compras de VIP + poucas compras de pacotes de
  moedas. Creator Rewards é insignificante nesse volume.
- **Mês 3 (se a retenção D1 passar de 20 % e você postar clipes no TikTok)**:
  ~R$ 500–3 000/mês. Começa a ter sentido rodar anúncios Sponsored. Dev Product
  "Explode Todo Mundo" costuma ter boa conversão em party games (impulso).
- **Mês 6+ (se o jogo "enganchar" e passar de 5k CCU)**: entra na zona onde
  vale pensar em DevEx. Mínimo para sacar: **100 000 Robux earned**, conta
  verificada, W-8BEN cadastrado, Tipalti para receber no Brasil. Imposto é
  **Carnê-Leão** mensal. **MEI não cobre** essa receita.
- **Expectativa realista pra dev solo brasileiro**: a maioria dos jogos nunca
  passa de R$ 100/mês. Os que estouram, estouram muito — retenção D1 e tempo
  de sessão são os números que separam os dois grupos. Foco no **ícone,
  título e primeiros 30 segundos** antes de mexer em monetização pesada.

Fonte dos números: `docs/pesquisa/monetizacao.md` (tabela final) e
`docs/pesquisa/tendencias.md`.

## Como testar agora

1. `rojo serve` nesta pasta.
2. Studio: Baseplate novo → plugin Rojo → Connect.
3. Play. O HUD agora tem os 3 botões laterais, loja abre, daily abre.
   Animações e sons ficam silenciosos até você colar os ids.
4. Para testar compra Robux, use o **Test Place** no Creator Hub (ele debita
   Robux "virtuais" do seu Studio sem cobrar de verdade).

## Próximos passos (ordem recomendada)

Ver `docs/plano-monetizacao.md`. Resumo:
1. Criar os assets no Creator Hub e colar ids (bloqueia tudo).
2. Sons + câmera tremendo (pro clipe do TikTok).
3. Badges + códigos promocionais.
4. Convite de amigo com recompensa + leaderboard global.
5. Loja in-round (revive com Robux) + sala VIP.
