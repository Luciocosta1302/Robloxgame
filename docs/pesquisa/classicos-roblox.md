# Clássicos do Roblox: o que todo jogo do topo tem

Documento de pesquisa para **Batata Quente Ragdoll** (party game ragdoll).
Última atualização: 2026-11-22. Fontes priorizadas: 2025-2026.

## Contexto e regras de ouro

Antes dos 12 clássicos, duas regras fundamentais que afetam várias das escolhas abaixo.

### Público infantil (COPPA / chat)

- Em novembro de 2025, o Roblox passou a exigir verificação facial de idade para liberar chat, e o chat é desligado por padrão para menores de 9 anos salvo consentimento parental; em sistemas pré-existentes, menores de 13 já tinham DMs fora de experiências bloqueadas desde 2024 ([Roblox corporate newsroom, nov/2025](https://corp.roblox.com/newsroom/2025/11/roblox-requires-age-checks-limits-minor-and-adult-chat); [PC Gamer, nov/2025](https://pcgamer.com/software/platforms/roblox-adds-new-rules-for-players-under-13-following-scathing-child-safety-report); [TechCrunch, 2024](https://techcrunch.com/2024/11/07/roblox-adds-new-safety-measures-to-ban-kids-under-13-from-social-spaces)).
- A partir do começo de 2026, criadores não podem colocar links de redes sociais dentro das experiências; proibição de imagens/vídeos em chat permanece ([Roblox newsroom, nov/2025](https://corp.roblox.com/newsroom/2025/11/roblox-requires-age-checks-limits-minor-and-adult-chat)).
- COPPA: menores de 13 têm coleta de dados limitada a “non-personal information” para segurança da conta ([Roblox corporate newsroom, nov/2025](https://corp.roblox.com/newsroom/2025/11/roblox-requires-age-checks-limits-minor-and-adult-chat)).

**Impacto no nosso jogo:** chat entre players provavelmente estará muito restrito para a nossa faixa (ragdoll party = jovens). Monetize cosmético e progressão, não social; não coloque “cole seu Discord” na UI; evite texto livre como vetor de identificação.

### Itens aleatórios pagos (lootboxes, ovos, baús)

- Roda de prêmios paga por Robux, ovos/baús/cápsulas, itens que modificam probabilidade (pity, luck) **tudo entra nessa política** ([Roblox Creator Docs - paid random items, pt-br](https://create.roblox.com/docs/pt-br/production/monetization/paid-random-items); [EN](https://create.roblox.com/docs/en-us/production/monetization/paid-random-items)).
- É **obrigatório exibir as odds numéricas antes da compra**, refletindo a chance real de cada resultado. Se vários itens compartilham a mesma odd, pode agrupar com um cabeçalho. Modificadores de sorte precisam atualizar a odd exibida dinamicamente ([Roblox Creator Docs](https://create.roblox.com/docs/en-us/production/monetization/paid-random-items)).
- Flag de API `ArePaidRandomItemsRestricted` bloqueia usuários inelegíveis (por região/idade). Deve-se esconder o gerador, trocar por item determinístico, ou tirar o player da área ([Roblox Creator Docs](https://create.roblox.com/docs/en-us/production/monetization/paid-random-items)).

**Impacto no nosso jogo:** se formos ter baú/roleta com Robux, UI **precisa** mostrar odds. Alternativa segura: baú só com moeda ganha jogando (não comprada com Robux) ou skins vendidas diretamente sem sorteio.

---

## 1. Emotes e danças

**O que é:** menu radial (Emote Wheel) que faz o personagem dançar/reagir. Clássico desde 2019; é a forma mais universal de “expressão” sem chat.

**Como o Roblox entrega oficialmente:** existe o módulo oficial `emote-bar` (Emote Bar / Mega Emote). Cada emote é `{name, animation}`; o módulo lida com replicação server-side e tem o recurso “Mega Emote” que amplifica efeito quando vários players fazem o mesmo emote na mesma área ([Roblox docs - emote bar](https://create.roblox.com/docs/en-us/resources/modules/emote-bar); [tools/modules/emote-bar](https://create.roblox.com/docs/tools/modules/emote-bar)).

**Exemplo de jogo grande:** Dress to Impress (fashion / ranking entre players) usa emotes como parte central da expressão dos avatares ([progameguides, Top 10 Hottest Roblox Games abr/2025](https://progameguides.com/roblox/top-10-hottest-roblox-games-you-cant-miss/)). Hyper Realistic Ragdoll e Ragdoll Soccer entraram no top 10 em semanas em 2026 e apostam muito em “show-off” corporal, que é terreno natural para emotes ([GGRecon, nov/2026](https://www.ggrecon.com/articles/roblox-top-games-didnt-exist-before-october/)).

**Rende dinheiro?** Sim, indiretamente (retenção + fonte de cosmético pago). Emotes vendidos como gamepass/pacote funcionam; emotes do catálogo Roblox que o player já comprou podem ser carregados automaticamente no wheel ([Roblox docs - emote bar](https://create.roblox.com/docs/en-us/resources/modules/emote-bar)).

**Dá pra fazer sozinho?** **Sim** — usando o módulo oficial Emote Bar; animações customizadas podem ser importadas via `KeyframeSequence`. Alternativa: sistemas prontos da comunidade ([DevForum In-Game Emotes Menu](https://devforum.roblox.com/t/in-game-emotes-menu/292380/407)).

**Prioridade para Batata Quente Ragdoll: alta** — party game vive de reação dos outros players; emote wheel multiplica momentos “clipáveis” e naturalmente vira cosmético pago (gamepass “Emote Pack”).

---

## 2. Easter eggs e segredos

**O que é:** salas escondidas, referências a memes do Roblox e da internet, badges secretas, NPCs ocultos, interações bizarras que só o “Achievement Hunter” acha. Vira TikTok/YouTube de graça.

**Exemplos recentes e grandes:**
- **Brookhaven RP (2025)** rodou um egg hunt extremo com 35+ eggs escondidos, alguns exigindo escada, saco de dormir ou encolher o personagem ([Ginx, 2025](https://www.ginx.tv/en/?p=71900)).
- **The Hunt: Roblox 20** (evento oficial, até set/2026) escondeu uma segunda camada de recompensa: pegar a badge normal → fazer quest secreta → voltar ao hub pegar item flutuante ([Xbox news, jul/2025](https://news.xbox.com/en-us/2025/07/03/roblox-the-hatch-egg-hunt-event/); [AllThings.how](https://allthings.how/how-to-get-every-secret-badge-in-the-hunt-roblox-20/)).
- **Nico's Nextbots, Meme Sea, Epic Minigames** mantêm listas enormes de segredos e eggs recorrentes ([ProGameGuides - Meme Sea secrets](https://progameguides.com/roblox/all-meme-sea-secrets-and-easter-eggs-locations/); [AllThings.how - Epic Minigames 2026](https://allthings.how/how-to-find-every-easter-egg-in-epic-minigames-2026-hunt/)).

**Rende dinheiro?** Indireto — não vende direto, mas gera conteúdo (vídeos “ALL SECRET BADGES in X”), o que puxa visitas → monetização via cosméticos/passes. Guia de design recomenda amarrar badges a eventos únicos (derrotar boss, achar sala), não spammar badges ([Alibaba guide para badges Roblox](https://www.alibaba.com/product-insights/a-step-by-step-guide-to-creating-custom-badges-in-roblox-for-your-game.html)).

**Dá pra fazer sozinho?** **Sim**. API de badges é gratuita desde o anúncio “free badge creations” ([DevForum, 2023](https://devforum.roblox.com/t/announcing-free-badge-creations/1680515)). Lógica = `BadgeService:AwardBadge(userId, badgeId)` + condição no servidor. Esconder uma sala é só mapa + collider trigger.

**Prioridade para Batata Quente Ragdoll: alta** — baratíssimo de fazer, gera vídeo de YouTuber (“achei a BATATA DOURADA escondida”) e vira trend de TikTok; cada eliminação ragdoll engraçada já é clipe, segredos reforçam.

---

## 3. Lojas in-round (revive, skip, boost)

**O que é:** produtos pagáveis com Robux **durante** a rodada — “vida extra”, “pular fase”, “revive”, boost de velocidade — e loja entre rodadas.

**Exemplos:**
- **Tower of Hell** (obby, bilhões de visitas) é o case clássico citado nos glossários dev: skip-stage e extra-life como developer products comprados “in the moment of need” ([creation.dev glossary, developer products](https://www.creation.dev/glossary/developer-products)).
- **Tower Defense Simulator** vende `3x Revive Tickets` e `3x Time Scale Tickets` por Robux via dev product ([TDS Wiki - Developer Products](https://tds.fandom.com/wiki/Developer_Products)).
- **Dress to Impress** (Halloween 2025) introduziu um produto “+60s no cronômetro” ([esports.gg, out/2025](https://esports.gg/news/gaming/dti-halloween-event-patch-notes-dress-to-impress)).

**Rende dinheiro?** **Sim, muito.** Guia oficial recomenda: “in obby games, horror games, and any experience with a fail state, selling extra lives as developer products is a proven strategy” ([creation.dev - Roblox Developer Products Guide](https://www.creation.dev/learn/roblox-developer-products-guide)). Desde 25 fev 2025 dev products podem até aparecer na página da experiência (fora do jogo) ([Roblox docs - shop](https://create.roblox.com/docs/production/monetization/shop)).

**Dá pra fazer sozinho?** **Parcial.** `MarketplaceService:PromptProductPurchase` é trivial; a parte chata é implementar `ProcessReceipt` idempotente (o doc oficial recomenda explicitamente para o player receber na hora) ([Roblox docs - developer products](https://create.roblox.com/docs/production/monetization/developer-products.md)). Houve outage de MarketplaceService em jul/2025 — logue e dê retry ([DevForum - purchasing dev products bug](https://devforum.roblox.com/tag/purchasing-dev-products-bug)).

**Prioridade para Batata Quente Ragdoll: alta** — party game ragdoll = morrer é o conteúdo. “Revive por 25 Robux” quando a batata explode é a venda mais natural do mundo e tem precedente em Tower of Hell / TDS; cuidado para não virar pay-to-win em modo competitivo (tenha modo “pure” sem revive).

---

## 4. Códigos promocionais

**O que é:** aba Codes na UI, códigos liberados por meta (ex.: “1M likes”, “100k membros no grupo”), redeemados por recompensa in-game. **Diferente** dos antigos “promo codes” da plataforma Roblox (que praticamente secaram — GamesRadar nota que códigos oficiais da plataforma viraram raridade em 2025) ([GamesRadar, ago/2025](https://www.gamesradar.com/roblox-promo-codes); [PC Gamer, jun/2025](https://www.pcgamer.com/roblox-promo-codes-redeem)).

**Exemplos:** Blox Fruits, Dress to Impress, Anime Defenders todos mantêm aba Codes ativa, e sites como ProGameGuides/Sportskeeda vivem de agregar essas listas ([ProGameGuides New Year codes 2025](https://progameguides.com/roblox/all-new-years-active-roblox-promo-codes-listed/)).

**Rende dinheiro?** **Indireto** — códigos não geram venda direta; eles **aumentam visitas/likes** e são liberados precisamente em cima de metas de visibilidade (grupo, curtidas), o que puxa monetização.

**Dá pra fazer sozinho?** **Sim.** Arquitetura padrão (das fontes): manter lista de códigos válidos **no servidor** (nunca no cliente — “you wouldn't want to leak the assetId where you store your codes”), validar via `RemoteFunction` com retorno, registrar redenção em `DataStoreService` (um código por player), e usar `MessagingService` só para **propagar novos códigos** entre servidores ao vivo (não para armazenar estado — pode falhar ocasionalmente) ([DevForum - Twitter Codes System](https://devforum.roblox.com/t/twitter-codes-system-howto-resource-scripting/994593); [Roblox security docs](https://create.roblox.com/docs/scripting/security/client-server-boundary); [DevForum - one-time code](https://devforum.roblox.com/t/how-to-make-a-code-one-time-use/581016)). Toda validação **no servidor**, nunca no LocalScript.

**Prioridade para Batata Quente Ragdoll: alta** — custo de implementação baixíssimo, é a métrica/alavanca mais barata que existe para campanha de likes e seguidores do grupo; e é 100% convenção que o player já procura ao entrar num jogo novo.

---

## 5. Badges, conquistas, títulos, níveis

**O que é:**
- **Badges** (sistema oficial Roblox, conta na ficha do player na plataforma).
- **XP + level** (progressão interna do jogo).
- **Títulos cosméticos** (prefix/suffix no nome, ex.: `[Lenda]`).

**Estado da arte Roblox:**
- Criação de badges é **gratuita** desde 2023 ([DevForum anúncio](https://devforum.roblox.com/t/announcing-free-badge-creations/1680515)).
- Em 2025 saiu beta de **badge reordering** (dev consegue ordenar como aparecem no perfil) ([gameranx, 2025](https://gameranx.com/updates/id/534800/article/roblox-implements-new-public-beta-for-badge-system/)).
- Comunidade pede há anos: progresso parcial da badge, mostrar badge no perfil, e renomear para “Achievements” ([DevForum feature request](https://devforum.roblox.com/t/enhance-how-games-can-reward-players-on-roblox/334031)).

**Boas práticas de design:**
- Formato quadrado (150×150), cores da paleta do jogo, formas limpas, sem texto pequeno ([Alibaba guide](https://www.alibaba.com/product-insights/a-step-by-step-guide-to-creating-custom-badges-in-roblox-for-your-game.html)).
- Cada badge amarrada a **um evento único e significativo** (chegar fase X, achar sala secreta, zerar primeira vez) — não spammar ([Alibaba guide](https://www.alibaba.com/product-insights/a-step-by-step-guide-to-creating-custom-badges-in-roblox-for-your-game.html)).
- Usar analytics do Roblox para ver quantos players ganham cada badge e rebalancear dificuldade ([Alibaba guide](https://www.alibaba.com/product-insights/a-step-by-step-guide-to-creating-custom-badges-in-roblox-for-your-game.html)).

**Rende dinheiro?** **Indireto** — badges não vendem, mas XP/level habilita “skins exclusivas de level 50”, “título dourado”, que viram gatilho de cosmético pago ou gamepass “2x XP”.

**Dá pra fazer sozinho?** **Sim.** Badges: `BadgeService:AwardBadge`. XP/Level: valor no `leaderstats` + `DataStoreService` + barrinha custom na GUI. Títulos: `TextChatService` + `ChatSpeaker.Prefix` (ver §7).

**Prioridade para Batata Quente Ragdoll: alta** — party game precisa de meta de longo prazo pra player não evaporar após 20min. XP + level + títulos é o esqueleto mais barato; badges “primeiro a ganhar” / “100 rodadas” são clipe de TikTok.

---

## 6. Recompensa diária, roleta grátis, baú por tempo jogado, missões diárias

**O que é:** Login Reward com streak (dia 1, 2, 3… prêmio maior no dia 7), Daily Quests (3 missões que resetam 00h UTC), baú a cada X minutos jogados, roleta grátis diária.

**Exemplos recentes:**
- **Jujutsu Infinite** permite manter streak mesmo logando 3 dias por semana — regra desenhada pra não punir o casual ([Ginx, 2025](https://www.ginx.tv/en/free-jujutsu-infinite-rewards)).
- **Plants vs Brainrots** (out/2025) tem daily rewards guide dedicado ([Sportskeeda](https://widgets.sportskeeda.com/roblox-news/plants-vs-brainrots-daily-rewards-guide)).
- **Attack on Titan Revolution** tem daily quests como loop central ([Sportskeeda](https://www.sportskeeda.com/roblox-news/attack-titan-revolution-daily-quests-guide)).
- **Creatures of Sonaria** usa Login Shop com tiers ([Sportskeeda](https://www.sportskeeda.com/roblox-news/creatures-sonaria-login-shop)).
- **Pet Simulator 99** notavelmente *não tem* login streak nativo (jogadores usam Pet Quest como alternativa), mostrando que até o top do top consegue viver sem — mas é exceção, não regra ([ProGameGuides, dez/2025](https://progameguides.com/?p=614193)).

**Boas práticas de regra (das fontes):** streak que quebra com 2 dias ausentes mas **mantém os bônus já ganhos** evita frustração ([Sportskeeda - Creatures of Sonaria](https://www.sportskeeda.com/roblox-news/creatures-sonaria-login-shop)).

**Rende dinheiro?** **Sim, indireto fortíssimo.** Retenção D1/D7 é o input de todas as outras receitas. Além disso, dá upsell natural: “pagar 50 Robux para pular o cooldown do baú” é dev product óbvio.

**Dá pra fazer sozinho?** **Sim.** `DataStoreService` guardando `lastLogin` e `streak`; verifica `os.time()` no join; em UTC ou timezone fixa para evitar exploits. Sistemas prontos existem no BuiltByBit ([exemplo Daily Rewards Login Streak](https://builtbybit.com/resources/daily-rewards-login-streak-system.105963/)), mas é um dos sistemas mais fáceis de escrever do zero.

**Prioridade para Batata Quente Ragdoll: alta** — party game vive de retorno diário; sem login reward o CCU despenca após o primeiro pico.

---

## 7. Grupo, VIP, chat tag, sala VIP

**O que é:** bônus por entrar no grupo do Roblox (`GroupService`), bônus por “Like” no jogo (`PlaceLike`), gamepass VIP que dá **chat tag** (`[VIP]` antes do nome em roxo/dourado) e acesso a área exclusiva.

**Exemplos:**
- **Steal a Brainrot (VIP gamepass):** +0.5x multiplicador de cash, chat tag `[VIP]`, +10s de lock time base ([FandomWire](https://fandomwire.com/vip-roblox-steal-a-brainrot-all-benefits-explained/); [Sportskeeda hindi](https://hindi3.sportskeeda.com/roblox-news/steal-brainrot-vip-gamepass-explained); [PowerUp Gaming, ago/2025](https://powerupgaming.co.uk/2025/08/31/what-does-the-vip-gamepass-do-in-roblox-steal-a-brainrot/)).
- **Brookhaven, Adopt Me**: múltiplos gamepasses incluem tag + benefícios funcionais ([Sportskeeda - Adopt Me gamepasses](https://www.sportskeeda.com/roblox-news/exploring-gamepasses-roblox-adopt-me); [games.gg Brookhaven](https://games.gg/brookhaven-rp/guides/brookhaven-rp-gamepasses-tier-list/)).

**Como implementar corretamente (das fontes):**
- Chat tag no **`TextChatService`** (sistema novo), não no chat legado ([DevForum TextChatService VIP](https://devforum.roblox.com/t/how-to-make-a-serverscript-for-vip-chat-tag-with-textchatservice-and-not-legacy/2510077)).
- Checar gamepass ownership **no servidor** via `MarketplaceService:UserOwnsGamePassAsync`; cliente não pode checar isso com segurança ([DevForum thread](https://devforum.roblox.com/t/how-to-make-a-serverscript-for-vip-chat-tag-with-textchatservice-and-not-legacy/2510077)).
- Usar `attributes` no `Player` para armazenar status e reutilizar em outras partes do jogo (acesso a área, boost) ([Roblox docs - group chat tags](https://create.roblox.com/docs/pl-pl/chat/examples/group-chat-tags)).
- Player pode exibir múltiplas tags (Owner + VIP + Tester) via sistema stackeado ([BuiltByBit chat tag systems](https://builtbybit.com/resources/advanced-chat-tag-system.111571/)).

**Grupo bonus:** `GroupService:GetGroupsAsync(userId)` ou `Player:IsInGroup(groupId)` → dar moeda/XP no join. **Place Like bonus:** Roblox **não expõe API oficial** pra checar like por player; o padrão é dar baseado em `ThumbsUp` global (quando bate X likes, libera recompensa pra todo mundo via código). Isso é convenção da comunidade e cai no §4 (códigos liberados por meta).

**Rende dinheiro?** **Sim, direto.** Gamepass VIP é um dos produtos mais estáveis do Roblox (precedente em quase todo top-game).

**Dá pra fazer sozinho?** **Sim** — sistema inteiro é ~150 linhas de Luau.

**Prioridade para Batata Quente Ragdoll: alta** — VIP gamepass (R$ 99/149) com chat tag + multiplicador pequeno de XP (não de dano) + cosmético exclusivo é regra do jogo no Roblox; não ter é deixar dinheiro na mesa.

---

## 8. Pets, rebirth, multiplicadores, gifting

**O que é:**
- **Pet/companheiro** flutuando atrás do player, cosmético ou com bônus (XP, moeda).
- **Rebirth**: player zera progresso em troca de multiplicador permanente.
- **Gifting**: dar/trocar item com amigo.

**Exemplos:**
- **Pet Simulator 99 (BIG Games)** é o template mais agressivo: pets com rarities, trading, rebirth gates, multiplicadores por pet equipado ([RoWatcher - PS99 Monetization](https://rowatcher.com/news/pet-simulator-99-inside-roblox-s-most-aggressive-monetization-machine); [RoWatcher - Adopt Me vs PS99](https://rowatcher.com/news/adopt-me-vs-pet-simulator-99-which-pet-game-model-actually-wins)). Monetização descrita como “aggressive” e “clearly works”.
- **Pets Go:** rebirth é skill paga **E** travada por level 200 → pay-for-convenience, não pay-to-win direto ([via DevForum discussion](https://devforum.roblox.com/t/creating-and-maintaining-a-high-income-game-while-avoiding-pay-to-win-tactics/2200208)).
- **Flashpoint: Worlds Collide:** primeiro rebirth é grátis; depois custa 5000 Cash in-game ([Sportskeeda hindi](https://hindi3.sportskeeda.com/roblox-news/how-rebirth-flashpoint-worlds-collide)).
- **PS99 primeira rebirth** dá `+75% pet strength`, teleport, Castle Key, 10k diamantes ([RobloxDen guide](https://robloxden.com/game-codes/pet-simulator-99/guides/pet-simulator-99-how-to-rebirth)).

**Design pra não virar pay-to-win:**
- Comentário recorrente no DevForum: converter em “pay for convenience” — slots limitados, delay de hatch, multi-hatch ([DevForum](https://devforum.roblox.com/t/creating-and-maintaining-a-high-income-game-while-avoiding-pay-to-win-tactics/2200208)). Esse post é opinião de comunidade, não política oficial.
- Rebirth deve ser **voluntário**, trocando progresso por bônus duradouro; resetar demais vira castigo ([creation.dev - rebirth glossary](https://www.creation.dev/glossary/rebirth)).

**Gifting — cuidado:** Roblox não tem “gift item” nativo pra items de jogo. Transferir inventário entre players exige sistema próprio e **cai na política de itens aleatórios se o item tiver vindo de random gen pago** — e usuários inelegíveis à flag `ArePaidRandomItemsRestricted` **não podem trocar o resultado** ([Roblox docs](https://create.roblox.com/docs/en-us/production/monetization/paid-random-items)). Além disso, trading entre players é vetor forte de scam infantil — pensar duas vezes.

**Rende dinheiro?** **Sim, muito.** É a fórmula de ~$40–90M/mês combinados dos top 10 jogos (estimativa RoMonitor/dev disclosures) ([RoWatcher 2026](https://rowatcher.com/news/the-10-highest-earning-roblox-games-in-2026-and-what-they-mean-for-the-platform)).

**Dá pra fazer sozinho?** **Parcial.** Pet (parte visual + atração atrás do player) é fácil (`BodyPosition` ou `AlignPosition`). Rebirth é lógica simples. Sistema de trading seguro é **difícil** (precisa de UI dupla, lock de confirmação, logs anti-scam, anti-exploit; alvo favorito de duplicação).

**Prioridade para Batata Quente Ragdoll: média-baixa** — party game de rodada curta não precisa de loop de pets/rebirth no estilo PS99; ragdoll vive de momento, não de grind. **Pode funcionar:** pet puramente cosmético que te segue no lobby (fácil, zero pay-to-win). **Evitar:** trading entre players (risco COPPA/scam/duplicação alto demais para o custo).

---

## 9. Eventos ao vivo, admin abuse, updates semanais

**O que é:** desenvolvedor entra no jogo e sorteia itens, eventos temporais (Halloween, Natal), atualizações semanais com teaser/countdown, patch notes publicadas em grupo/discord.

**Caso mais importante de 2025 — “Admin War” / “Admin Abuse”:**
- Em agosto 2025 o Roblox bateu **47.4 milhões de players concorrentes**, atribuído em grande parte a um Admin War colaborativo entre *Steal a Brainrot* e *Grow a Garden* ([Insider Gaming](https://insider-gaming.com/roblox-mindblowing-player-count-record-steal-a-brainrot/); [Notebookcheck](https://www.notebookcheck.net/Roblox-achieves-record-breaking-47-4-million-concurrent-players-in-August-despite-recent-legal-controversies.1096346.0.html); [Tubefilter, ago/2025](https://www.tubefilter.com/2025/08/25/roblox-grow-garden-steal-brainrot-admin-war-record/amp/)).
- Formato: devs entram em servidor público e distribuem drops limitados em janelas específicas ([Beebom, 2025](https://beebom.com/robloxs-steal-a-brainrot-delivered-a-2025-masterclass-in-player-engagement-and-gave-uefn-a-second-wind/amp/)).
- Jogos com ~20k de visitas pulavam pra >100k no momento do Admin Abuse ao vivo ([Beebom Admin Abuse analysis](https://beebom.com/admin-abuse-might-save-dying-roblox-games-but-hurts-them-in-the-long-run)).
- **Crítica:** o pico some rápido quando a sessão acaba; se vira muleta o jogo não cresce organicamente ([Beebom](https://beebom.com/admin-abuse-might-save-dying-roblox-games-but-hurts-them-in-the-long-run); [Filibuster Blog](https://thefilibusterblog.com/the-impact-of-admin-abuse-on-struggling-roblox-games-short-term-relief-or-long-term-damage/)).
- Plants vs Brainrots roda Admin Abuse **3 vezes por update** como pilar oficial ([Beebom](https://beebom.com/admin-abuse-might-save-dying-roblox-games-but-hurts-them-in-the-long-run)).

**Eventos sazonais (2025):**
- **Halloween Spotlight 2025** oficial do Roblox: 23 out–5 nov 2025, cross-game ([ProGameGuides countdown](https://progameguides.com/roblox/roblox-halloween-spotlight-event-2025-release-date-countdown-leaks-faq/); [Beebom confirmed games](https://beebom.com/roblox-halloween-spotlight-event-release-date-games-rewards)).
- Grow a Garden (Ghoul Garden, out 2025), Fisch (FischFright, 18 out), TDS (Lord Exo boss), Adopt Me, Dress to Impress (patch Halloween com produto `+60s`) todos sincronizaram patches ([games.gg major Halloween updates](https://games.gg/news/roblox-major-halloween-updates/); [Sportskeeda TDS](https://www.sportskeeda.com/roblox-news/tower-defense-simulator-halloween-update-v1-37-0-patch-notes); [esports.gg DTI](https://esports.gg/news/gaming/dti-halloween-event-patch-notes-dress-to-impress)).

**Rende dinheiro?** **Sim, muito indireto.** Events não vendem direto, mas são o **driver primário de pico de CCU**, o que viraliza. Items event-only ainda assim viram gamepass de evento.

**Dá pra fazer sozinho?** **Sim** — admin abuse é puramente operacional: `remoteEvent` que só aceita se `UserId` estiver em whitelist, spawn de items temporários, anúncio via `TextChatService`. Patch notes = post no grupo + GUI de changelog.

**Prioridade para Batata Quente Ragdoll: alta** — party game ragdoll é perfeito para “dev entra, joga a batata gigante dourada, caos”. Custo quase zero, retorno em visibilidade enorme, direto no padrão 2025.

---

## 10. Leaderboards globais, servidores privados, convite de amigo

### 10a. Leaderboard global

- **Nativo (beta 2026):** Roblox lançou **Persistent Friends and Global Leaderboards** em beta — Here (sessão), Friends e Global, com Friends/Global lendo de um `OrderedDataStore` registrado no Creator Hub. Limite inicial: 1 leaderboard persistente por experiência ([DevForum beta](https://devforum.roblox.com/t/beta-add-persistent-friends-and-global-leaderboards-easily/4832224); [Weekly Recap ago/2026](https://devforum.roblox.com/t/weekly-recap-august-24%E2%80%9328-2026-persistent-leaderboards-opencloud-apis/4836039)).
- **Custom (clássico):** `OrderedDataStore:SetAsync` → `GetSortedAsync` traz top N global entre todos os servidores ([Roblox tutorial](https://create.roblox.com/docs/tutorials/use-case-tutorials/data-storage/create-leaderboard)). Mesmo rate-limit que DataStore normal ([DevForum - Ordered DataStores](https://devforum.roblox.com/t/ordered-datastores/3683582)).

### 10b. Servidor privado / VIP server

- Dois tipos distintos: **ReservedServer** (criado pelo dev via código) vs **VipServer** (comprado pelo player) — campos separados no `TeleportOptions`: `ReservedServerId` e `VipServerId` ([Roblox docs - teleport private servers](https://create.roblox.com/docs/projects/teleport-private-servers)).
- Pra teleportar pra VIP server, `TeleportOptions.VipServerId = game.PrivateServerId` do destino. Pra ir e voltar, manter o VipServerId em `teleportData` ou DataStore porque o reserved server perde esse contexto ([Roblox docs](https://create.roblox.com/docs/projects/teleport-private-servers)).
- Sempre tratar `TeleportService.TeleportInitFailed` (acesso pode mudar entre teleport call e entrada) ([Roblox docs](https://create.roblox.com/docs/projects/teleport-private-servers)).

### 10c. Referral / convite com recompensa

- **Sistema oficial Roblox (2025):** Friend Invite Reward System. Convite exposto via `GetJoinData().ReferredByPlayerId`. Dev pode recompensar o inviter e o invitee ([Roblox docs - referral system](https://create.roblox.com/docs/production/promotion/referral-system); [DevForum anúncio](https://devforum.roblox.com/t/announcing-the-new-friend-referral-system-for-your-experiences/3623795)).
- UI oficial “Invite Friends pop-up” + “Friend Referral Rewards banner” liberada no início de 2025 ([Roblox docs](https://create.roblox.com/docs/production/promotion/referral-system)).
- **Pegadinha conhecida:** `ReferredByPlayerId` pode ser 0 em reserved servers ([DevForum](https://devforum.roblox.com/t/announcing-the-new-friend-referral-system-for-your-experiences/3623795)).
- Recompense **uma vez por invitee** para evitar farm.

**Rende dinheiro?** **Indireto** — leaderboard global é retenção/competição; private server é **direto** (gamepass “seu próprio servidor”); referral é K-factor (viral growth), que puxa tudo o mais.

**Dá pra fazer sozinho?** **Sim** — todos os três são chamadas de API bem documentadas. Leaderboard custom é ~80 linhas; referral é ler `ReferredByPlayerId` no join; private server é cobrar gamepass + chamada de `TeleportService`.

**Prioridade para Batata Quente Ragdoll:**
- Leaderboard global: **média** — party game se beneficia de “Top 100 Sobreviventes Mundial”, mas não é core.
- Private server: **alta** — party game com amigos **precisa** de sala só nossa; é literalmente o case ideal e vira gamepass direto.
- Referral: **alta** — K-factor é praticamente de graça implementar e Roblox já fez a UI pra você.

---

## 11. Música e sons marcantes

**O que é:** trilha e SFX que viram marca do jogo (jingle de vitória, grito ragdoll icônico).

**Estado legal em 2025 — IMPORTANTE:**
- Roblox **foi processado em >$200M** em 2025 por publishers de música por uso não licenciado ([PC Gamer](https://www.pcgamer.com/roblox-has-been-hit-by-dollar200m-lawsuit-by-music-publishers-for-copyright-infringement/); [GameSpot](https://www.gamespot.com/articles/roblox-sued-by-music-companies-over-unlicensed-use-of-songs/1100-6492646/); [Music Business Worldwide](https://www.musicbusinessworldwide.com/roblox-sued-for-more-than-200m-by-music-publishers-who-allege-copyright-infringement)).
- Caso **Robinson v. Binello** em abr/2025 expôs o Roblox a “potentially unlimited copyright liability” — a moderação pode ser vista como conduta volitiva de infração ([Eric Goldman blog, abr/2025](https://blog.ericgoldman.org/archives/2025/04/roblox-faces-potentially-unlimited-copyright-liability-robinson-v-binello.htm); [Harvard tagteam](https://tagteam.harvard.edu/hub_feeds/3626/feed_items/13562603)).
- **Enforcement interno é agressivo:** devs relatam áudio licenciado sendo removido mesmo com prova, e músicas Creative Commons Attribution também sumindo sem meio de reversão ([DevForum - Licensed Audio Removed](https://devforum.roblox.com/t/licensed-audio-removed-despite-proof-and-permission-%E2%80%93-no-way-to-restore/3631363); [DevForum - CC Attribution being removed](https://devforum.roblox.com/t/roblox-removing-songs-licensed-under-creative-commons-attribution/2559774)).

**Regra oficial:** só pode usar áudio de outros devs se marcado **free to take** no catálogo **ou** com licença explícita documentada ([DevForum policy](https://devforum.roblox.com/t/upcoming-music-changes-and-copyright-related-action/130570?page=5)).

**Caminhos seguros:**
1. **Roblox Audio Library** oficial (filtrado por “licensed”/”free”).
2. Compor/encomendar original e manter a licença/prova.
3. SFX feitos por você (grunt de ragdoll, “boom” da batata é trivial com Audacity).
4. **Evitar categoricamente:** pop/anime/meme sounds comerciais, mesmo que “todo mundo usa”.

**Rende dinheiro?** **Indireto** — música marcante = clipe de TikTok reconhecível = retorno orgânico. Mas o downside (claim derruba o áudio, jogo fica mudo) é crítico.

**Dá pra fazer sozinho?** **Parcial** — carregar som é trivial; escolher legalmente é o trabalho real.

**Prioridade para Batata Quente Ragdoll: média-alta** — party game vive de energia sonora (loop upbeat, boom da explosão, jingle de vitória). Investir em SFX original ou licenciado via Roblox Audio é essencial; nunca subir MP3 do YouTube.

---

## 12. Avatar do jogo ↔ avatar do Roblox

**O que é:** jogo refletir o avatar do player como ele configurou no Roblox, deixar “se trocar” no lobby, e vestir cosméticos do jogo sobre esse avatar.

**Como funciona (oficial):**
- `HumanoidDescription` é a classe que descreve todo o visual (corpo, roupas, acessórios, animações). Modificar e aplicar via `Humanoid:ApplyDescription()` ([Roblox docs - Character appearance](https://create.roblox.com/docs/characters/appearance); [pt-br](https://create.roblox.com/docs/pt-br/characters/appearance)).
- Melhor prática: **começar da description existente do player** (não da default) e sobrescrever só o que mudar — isso preserva o visual ([Roblox docs](https://create.roblox.com/docs/en-us/characters/appearance)).
- Para lobby com viewport mostrando outros players, padrão comum é NPC com Humanoid dentro do `ViewportFrame` e `ApplyDescription` na description copiada ([DevForum](https://devforum.roblox.com/t/new-api-for-equipping-assets-on-humanoid-player-avatars/233076/197)).
- **Cuidado de performance:** mudar description em muitos characters ao mesmo tempo spikea ping do server ([DevForum](https://devforum.roblox.com/t/new-api-for-equipping-assets-on-humanoid-player-avatars/233076?page=9)).
- Novidade 2025 — beta “Add Avatar to Inventory From In-Experience” deixa o player salvar look direto do seu jogo pro avatar ([DevForum](https://devforum.roblox.com/t/client-beta-introducing-add-avatar-to-inventory-from-in-experience/3300883)).

**Cosméticos do jogo em cima do avatar:**
- Adicionar como `Accessory` (chapéu, mochila), ou como `HumanoidDescription.Shirt/Pants` se for roupa 2D.
- Para skins radicais (mascote completo substituindo o player) **anexar modelo** ao character e esconder partes originais; não é um `HumanoidDescription`.

**Rende dinheiro?** **Sim, muito.** Cosméticos equipáveis sobre o avatar do Roblox é o motor de várias top-games (Dress to Impress inteira gira em torno disso) ([progameguides](https://progameguides.com/roblox/top-10-hottest-roblox-games-you-cant-miss/)). Análise de 2026 lista “cosmetics-first monetization” como traço comum dos top 10 ([RoWatcher](https://rowatcher.com/news/the-10-highest-earning-roblox-games-in-2026-and-what-they-mean-for-the-platform)).

**Dá pra fazer sozinho?** **Parcial** — clonar description e aplicar é fácil; fazer pipeline de cosméticos próprios (acessórios 3D, upload, categorias, preview, lobby trocador, persistência) é trabalho médio (semanas).

**Prioridade para Batata Quente Ragdoll: alta** — jogo ragdoll ganha MUITO com cosmético: chapéu de batata, skin de batata frita, luva de batata… é cosmético-first como os top-10. Fundamental para monetização no longo prazo.

---

## Tabela resumo

| # | Item | Prioridade | Rende dinheiro? | Esforço (1-5) |
|---|------|-----------|-----------------|---------------|
| 1 | Emotes / Emote Wheel | Alta | Indireto (gamepass emote pack) | 2 |
| 2 | Easter eggs / badges secretas | Alta | Indireto (visibilidade) | 2 |
| 3 | Loja in-round (revive/skip) | Alta | **Sim (direto, forte)** | 3 |
| 4 | Códigos promocionais | Alta | Indireto (likes/grupo) | 2 |
| 5 | Badges / XP / Nível / Títulos | Alta | Indireto (habilita cosmético e boost) | 2 |
| 6 | Daily reward / quests / baús | Alta | Indireto (retenção) + direto (skip cooldown) | 2 |
| 7 | Grupo bonus / VIP tag / sala VIP | Alta | **Sim (gamepass VIP)** | 2 |
| 8 | Pets / Rebirth / Multiplicador / Gifting | Média-baixa | Sim, mas desenhado pra outro gênero; gifting arriscado | 4 |
| 9 | Eventos ao vivo / Admin Abuse / patch notes | Alta | Indireto (CCU + viral) | 2 |
| 10 | Leaderboard global / Private Server / Referral | Alta (private + referral), Média (leaderboard) | Direto (private server), K-factor (referral) | 3 |
| 11 | Música e sons marcantes | Média-alta | Indireto (identidade sonora) | 3 (legal) + 2 (técnico) |
| 12 | Avatar Roblox + cosmético do jogo | Alta | **Sim (cosmetics-first)** | 4 |

Esforço: 1 = tarde de trabalho; 5 = semanas-mês.

---

## Resumo

Para Batata Quente Ragdoll o combo de maior ROI é: **(3) loja in-round + (7) VIP gamepass + (9) admin abuse semanal + (12) cosméticos sobre avatar**, com (4) códigos, (5) badges/level e (6) daily reward como base de retenção; pet/rebirth/trading do estilo PS99 são opcionais e trading é melhor evitar por COPPA/scam.

Fonte-chave para decisões monetárias: [Roblox docs - paid random items (pt-br)](https://create.roblox.com/docs/pt-br/production/monetization/paid-random-items). Fonte-chave para segurança infantil: [Roblox newsroom nov/2025](https://corp.roblox.com/newsroom/2025/11/roblox-requires-age-checks-limits-minor-and-adult-chat). Fonte-chave para padrão de 2025: [Beebom - Steal a Brainrot masterclass](https://beebom.com/robloxs-steal-a-brainrot-delivered-a-2025-masterclass-in-player-engagement-and-gave-uefn-a-second-wind/amp/).
