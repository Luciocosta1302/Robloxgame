# Monetização — Batata Quente Ragdoll

> Pesquisa das formas de ganhar dinheiro com um jogo no Roblox, voltada para um dev brasileiro de 18 anos trabalhando num party game ragdoll.
> Data: 22/11/2026.
>
> **Aviso de fonte:** nesta sessão o host `create.roblox.com` está fora da lista de domínios permitidos, então não consegui abrir as páginas oficiais diretamente — o parent/proxy precisa liberar `create.roblox.com` no network allowlist do ambiente. Em compensação, usei o GitHub `Roblox/creator-docs` (o mesmo conteúdo em Markdown que alimenta o Creator Hub), o `devforum.roblox.com`, o newsroom oficial, o help center e matérias de imprensa dos últimos 3–6 meses. Toda afirmação carrega o link da fonte. Antes de publicar qualquer coisa, abra a página do Creator Hub citada e confira.

---

## 1. Game Passes

**O que é.** Compra única, permanente, vinculada à conta do jogador (`AssetType = Game Pass`). Serve para VIP, double jump, 2× moedas, skin exclusiva, sala VIP. Depois de comprado, o jogador leva o passe para qualquer servidor do seu jogo.

**Como ativar — passo a passo.**
1. Abra o Creator Dashboard do seu jogo → aba **Associated Items** → **Create a Pass**.
2. Faça upload de um ícone 150×150 (PNG, fundo transparente).
3. Dê nome e descrição, publique.
4. Na página do passe, defina **Sale enabled** e o preço (mínimo 1 Robux; o Roblox recomenda 50 Robux pra perk simples e 500 Robux pra algo forte).
5. Copie o **Pass ID** (segundo número da URL) e use no código.

**API — padrão certo em 2026.**

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local GAMEPASS_VIP = 123456789
local ownsCache = {} -- por jogador, pra não martelar a API

local function hasPass(player)
    if ownsCache[player.UserId] ~= nil then
        return ownsCache[player.UserId]
    end
    local ok, result = pcall(MarketplaceService.UserOwnsGamePassAsync,
        MarketplaceService, player.UserId, GAMEPASS_VIP)
    if ok then
        ownsCache[player.UserId] = result
        return result
    end
    return false
end

-- Prompt
local function promptVIP(player)
    if not hasPass(player) then
        MarketplaceService:PromptGamePassPurchase(player, GAMEPASS_VIP)
    end
end

-- Confirmar compra feita dentro do jogo
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
    if wasPurchased and passId == GAMEPASS_VIP then
        ownsCache[player.UserId] = true
        -- aplicar benefício
    end
end)

Players.PlayerRemoving:Connect(function(p) ownsCache[p.UserId] = nil end)
```

**Pegadinhas importantes:**
- `UserOwnsGamePassAsync` tem cache (~10 s na observação da comunidade). Depois de uma compra dentro do jogo, prefira usar `wasPurchased` do evento `PromptGamePassPurchaseFinished` em vez de re-consultar imediatamente ([devforum thread](https://devforum.roblox.com/t/promptgamepassfinished-and-userownsgamepass-out-of-sync/230048)).
- Pass ID ≠ Asset ID. Pegue o número correto da URL do passe ([devforum](https://devforum.roblox.com/t/why-is-it-when-i-put-in-a-gamepass-id-it-tries-to-make-the-players-buy-a-t-shirt/258320)).
- Chamadas sempre no servidor pra verificação canônica, prompt pode vir do cliente.

**Requisitos.** Nenhuma idade mínima pra criar passe, mas o jogo tem que estar **publicado** (não dá pra vender em draft). O criador precisa ter conta em boa posição.

**Receita típica.** Fatia: Roblox fica com 30%, dev recebe 70% em Robux (visão agregada: em média 67% do gasto em experiências vai pro ecossistema dev, dos quais 25% chega ao bolso depois do DevEx) ([Roblox Monetize docs](https://create.roblox.com/docs/monetize-experiences)). Um jogo pequeno (500–1 000 CCU) com monetização só de passes tira ~1 000–1 250 Robux/dia (~US$ 1,4–7 mil/ano) segundo um relato de dev ([devforum](https://devforum.roblox.com/t/game-making-very-little-robux/2646143)).

**Exemplos típicos pro Batata Quente:**
| Passe | Preço | Efeito |
|---|---|---|
| VIP | 199 R$ | Coroa, chat dourado, câmera cinematic no replay |
| Dash Duplo | 99 R$ | Permite segurar o dash mais 0.5 s |
| 2× Moedas | 299 R$ | Dobra moedas ganhas por partida (não afeta ranking) |
| Pular a Fila | 49 R$ | Prioridade pra entrar em partida cheia |
| Skin "Batata Dourada" | 149 R$ | Skin permanente de personagem |

**Riscos.** Oferecer vantagem forte demais em PvP = pay-to-win, viola o espírito da Rules of Conduct e derruba retenção. Mantenha passes **cosméticos ou de conveniência**.

Fontes:
- [Developer Products / Game Passes — Creator Hub (via GitHub)](https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/monetization/developer-products.md)
- [Monetize your experiences](https://create.roblox.com/docs/monetize-experiences)
- [How Roblox pays creators 2026](https://dev.to/fzsheik/how-roblox-actually-pays-creators-the-30-fee-devex-rates-and-ugc-revenue-share-2026-580i)

---

## 2. Developer Products (consumíveis)

**O que é.** Compra **repetível**: moedas, revives, abrir uma caixa, pular rodada, reviver no round. O jogador pode comprar a mesma coisa várias vezes.

**Como ativar.**
1. Creator Dashboard → seu jogo → **Monetization → Developer Products → Create**.
2. Nome, descrição, imagem, preço em Robux.
3. Publique, anote o **Product ID**.

**API — ProcessReceipt correto (idempotente).** Essencial: se você **não** retornar `PurchaseGranted`, o Roblox liga o callback de novo no próximo join e a cada ~X minutos até você retornar sucesso. Se em 3 dias ele não conseguir, o jogador é reembolsado ([devforum](https://devforum.roblox.com/t/exactly-when-marketplaceserviceprocessreceipt-is-called/1042548)). O exemplo oficial tinha bug (não checava duplicatas) — ver [logic error thread, 2024](https://devforum.roblox.com/t/logic-error-in-the-processreceipt-example-code-will-cause-player-to-get-the-same-paid-items-with-every-server-join-after-purchase/3563250) e [example code misses key point](https://devforum.roblox.com/t/example-code-on-developer-product-purchase-handling-misses-a-key-point-that-can-cause-devs-to-lose-revenue/268980). Padrão seguro:

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local receipts = DataStoreService:GetDataStore("PurchaseHistory_v1")

local PRODUCTS = {
    [123123] = function(player) -- 100 moedas
        giveCoins(player, 100)
    end,
    [456456] = function(player) -- revive
        revive(player)
    end,
}

local function processReceipt(info)
    local key = "player_" .. info.PlayerId .. "_pid_" .. info.PurchaseId

    -- Idempotência: já processado?
    local ok, already = pcall(receipts.GetAsync, receipts, key)
    if ok and already then
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end
    if not ok then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local player = game.Players:GetPlayerByUserId(info.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local handler = PRODUCTS[info.ProductId]
    if not handler then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local gotItem = pcall(handler, player)
    if not gotItem then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    -- Marca como processado ANTES de retornar sucesso
    local saved = pcall(receipts.SetAsync, receipts, key, true)
    if not saved then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.ProcessReceipt = processReceipt
```

**Regras.**
- Somente **um** `ProcessReceipt` por jogo (último setado vence). Centralize.
- A chave de idempotência é `PurchaseId` + `PlayerId`.
- `PromptProductPurchaseFinished` é considerado deprecated pra validar entrega — use `ProcessReceipt`.
- Prompt: `MarketplaceService:PromptProductPurchase(player, productId)` do cliente ou servidor.
- **Mudança 2026:** a partir de **30 de maio de 2026** vendas de Developer Products **cross-experience** foram desabilitadas ([developer-products docs on GitHub](https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/monetization/developer-products.md)).

**Receita típica.** Mesma fatia que Game Pass (70/30). Tende a render mais que passe em jogos com loop curto (party, round-based) porque jogador compra várias vezes por sessão.

**Riscos.** Se `ProcessReceipt` quebrar, o Creator Hub mostra a banner "ProcessReceipt needs a fix" e o Roblox desativa a venda ([devforum 2026](https://devforum.roblox.com/t/fix-the-processreceipt-needs-a-fix-banner-and-sell-your-products-outside-your-game/4910527)). Sem idempotência, dá pra entregar o item duas vezes e perder dinheiro.

---

## 3. Private Servers (servidores privados pagos)

**O que é.** Servidor instanciado só pro jogador que paga e os amigos que ele convidar. Modelo mensal, auto-renovação.

**Como ativar.**
1. Creator Dashboard → **Monetization → Private Servers → Enable**.
2. Definir preço em Robux/mês (ou deixar gratuito).
3. Confirmar.

**Preço mínimo e fatia.**
- Preço mínimo historicamente é **10 Robux/mês** (preço menor zerava o criador porque a taxa engolia tudo) ([devforum](https://devforum.roblox.com/t/vip-server-fee-question/670671)).
- Fatia unificada do marketplace: **30% para o Roblox, 70% para o dev** em Private Servers, Paid Access e Plugin Marketplace, independente de ter Premium/Plus ([Unified Marketplace Fee devforum 2021](https://devforum.roblox.com/t/unified-marketplace-fee-for-private-servers-paid-access-and-plugin-marketplace-sales/902229)). (Antes era 90% de taxa em Private Server pra não-Premium — revogado.)
- Mudança de preço: só uma vez a cada **60 dias**, e mudar cancela todas as assinaturas ativas ([Creator Hub private-servers](https://create.roblox.com/docs/production/monetization/private-servers)).

**Impacto do Roblox Plus (2026).**
- Lançado em **30 de abril de 2026** por US$ 4,99/mês, substitui o Premium pra novos usuários ([Roblox Newsroom](https://about.roblox.com/newsroom/2026/04/introducing-roblox-plus-subscription), [DevForum](https://devforum.roblox.com/t/introducing-roblox-plus/4567894)).
- Assinantes do Plus **ganham acesso grátis** a Private Servers pagos.
- Em troca, o criador recebe até **100 Robux por assinante Plus** que passar 60+ minutos em servidor pago nos últimos 30 dias, limitado aos top 5 servidores daquele usuário ([Tubefilter](https://tubefilter.com/2026/04/13/roblox-plus-creator-payouts)).
- A partir de **24 de setembro de 2026**, o Plus inclui um Private Server grátis por jogo ([DevForum](https://devforum.roblox.com/t/changes-to-roblox-plus-private-server-limits/4739922)).

**Receita típica.** Pouco atraente num party game — jogadores de ragdoll querem servidor cheio, não privado. Faz sentido se oferecer um "modo esquentado" com regras customizáveis (gravidade, batata explode mais rápido, armas liberadas).

**Riscos.** Preço alto desencoraja uso; preço baixo rende zero. Se oferecer custom config, você acaba mantendo duas versões do jogo.

---

## 4. Subscriptions (assinaturas in-experience)

**O que é.** Assinatura **mensal auto-renovável** dentro do jogo. O jogador paga em Robux ou moeda local todo mês e ganha benefícios recorrentes (ex.: 1 000 moedas/dia, skin exclusiva, lounge VIP).

**Como ativar.**
1. Creator Dashboard → seu jogo → **Monetization → Subscriptions → Create Subscription**.
2. Subir cover image, nome, descrição, duração (atualmente mensal).
3. Preço: **a partir de 49 Robux/mês** (floor atualizado em 2026 — antes era 99) ([devforum](https://devforum.roblox.com/t/let-your-players-pay-for-subscriptions-within-experiences-in-robux/4552995)), ou em moeda local (regional pricing).
4. Ativar a assinatura. Uma vez ativa aparece no store da experiência.
5. No Luau, usar a família `MarketplaceService` (checa posse com `UserSubscriptionStatusAsync`, prompt análogo a Game Pass).

**Requisitos.**
- Todos os devs **ID-verified ou phone-verified** podem criar ([devforum 2023 launch](https://devforum.roblox.com/t/create-and-manage-subscriptions-within-your-experience/2600664)).
- Nome do jogo precisa ser encurtado ("shortened experience name"), **permanente**, não pode mudar depois.
- Preço pode ser alterado uma vez a cada **60 dias**.
- Múltiplas assinaturas por jogo são permitidas (mas não mutualmente exclusivas).
- **Não pode** direcionar o jogador pra pagar fora do Roblox (bannível).

**Impacto do Roblox Plus.** Ao mesmo tempo (abril de 2026) o Roblox lançou a API **`PromptRobloxSubscriptionPurchase`** — se o jogador assinar o Plus dentro do seu jogo, você ganha **250 Robux/mês** por conversão enquanto ele mantém o Plus ([Newsroom](https://about.roblox.com/newsroom/2026/04/introducing-roblox-plus-subscription)).

**Receita típica.** Subscription é a monetização de maior LTV se o jogo tem loop diário. Um party game sem meta-progressão pesada tende a converter pior que RPG/sim; vale testar depois que o jogo tiver base fiel.

**Riscos.** Se o benefício for competitivo (buff em partida), vira pay-to-win. Se for cosmético-only, conversão cai. Jogador menor de 13 anos paga por local currency? Precisa ver políticas de controle parental. Nunca apague uma subscription ativa — quem já paga perde ([Help Center](https://en.help.roblox.com/hc/cs/articles/20292312961556-Subscriptions-within-Experiences)).

---

## 5. Creator Rewards (antigo "Premium Payouts")

**ATENÇÃO — mudou:** O **Premium Payouts foi descontinuado em 24 de julho de 2025** e substituído pelo **Creator Rewards** ([Creator Rewards docs](https://create.roblox.com/docs/creator-rewards), [DevForum announcement](https://devforum.roblox.com/t/introducing-creator-rewards-earn-more-by-growing-the-community/3777628)). Qualquer tutorial anterior está desatualizado.

**Como funciona hoje.**
- Dois tipos de recompensa:
  1. **Daily Engagement Reward** — ganha **5 Robux** quando um "Active Spender" fica **10+ minutos** no seu jogo. Pago só nos **3 primeiros jogos** que o usuário abre no dia. Sem recompensa adicional além de 10 min/dia.
  2. **Audience Expansion Reward** — 35% de rev-share sobre os **primeiros US$ 100** de compras qualificantes de um jogador novo, durante os **primeiros 60 dias** depois que ele descobriu seu jogo. Exige manter 100+ DAU médio durante esse período.
- "Active Spender" = usuário que gastou **≥ US$ 9,99** nos últimos 60 dias e **não** é novo nem reativado nesse período.
- **Holding period de 60 dias** — o Robux só cai no saldo depois disso, pra Roblox validar as compras com cartão/bank antes de liberar.
- Primeiro pagamento começou em 24 de setembro de 2025.

**Como ativar.**
Automático. Qualquer jogo elegível já participa. Não há botão; o painel de earnings do Creator Hub mostra se seu jogo está recebendo.

**Requisitos.**
- Jogo publicado e acessível.
- Conta em boa posição.
- Sem violações recentes.

**Receita típica.** Pequena no início. Com 1 000 DAU, se 3% forem Active Spenders e 1 000 ficarem 10 min → ~150 Robux/dia (~US$ 0,50/dia). Escala **linear** com retenção. Jogos Top 100 fazem disso dezenas de milhares de Robux/dia.

**Riscos.** Mínimo, é renda passiva. Só cuidado com farm artificial (bots/afk) — bannível.

---

## 6. Anúncios dentro do jogo

### 6a. Rewarded Video Ads

**O que é.** Vídeo opcional de 15–30 s que o jogador assiste em troca de uma recompensa (moedas, revive, skip cooldown). O dev recebe por impressão.

**Como ativar.** API `AdService:ShowRewardedVideo()` (ou `AdService:IsRewardedVideoReady()` pra verificar antes). Setup:
1. Creator Dashboard → aba **Monetization → Ads** → habilitar Rewarded Video.
2. Implementar o botão no UI; o anúncio aparece sobrepondo o jogo.
3. Testar no Studio com modo preview.

**Requisitos de elegibilidade** ([Rewarded video ads docs](https://create.roblox.com/docs/production/promotion/rewarded-video-ads)):
- Dev **13+**.
- Conta **ID-verified**.
- Jogo público com **≥ 2 000 unique visitors/mês**.
- Content rating / maturity questionnaire aprovado.
- Conta em boa posição.

**Expansão em 2026.** Em fevereiro de 2026 o acesso self-service foi liberado pra **todos os criadores elegíveis** (antes era restrito a jogos 100K+ DAU) ([DevForum fev/2026](https://devforum.roblox.com/t/more-creators-can-now-use-rewarded-video-ads/3838678)).

**Receita.** Roblox não publica taxa oficial. Estimativas de terceiros falam em **eCPM US$ 5–15** em média, variando por região e demanda do advertiser ([rolearn](https://rolearn.dev/insights/rewarded-video-ads-new-revenue-stream/)). Um dev relatou **6 Robux por 49 impressões** = ~US$ 0,46 CPM, mas é caso extremo ([DevForum](https://devforum.roblox.com/t/more-creators-can-now-use-rewarded-video-ads/3838678)).

**Mudança importante — maio de 2026.** Todas as implementações **próprias** de rewarded video precisam migrar para a API nativa do Roblox. Depois de **4 de maio de 2026**, rewarded video independente **não é mais permitido** ([New Advertising Policies & Standards](https://devforum.roblox.com/t/new-advertising-policies-standards/4527365)).

### 6b. Immersive Ads (portals, billboards, vídeo imersivo)

**O que é.** Unidades visuais dentro do mundo 3D: outdoors em paredes, portais que teleportam pra experiência do advertiser, vídeos em telas 3D. Você coloca a unit no mapa e o Roblox decide o que mostra.

**Como ativar.** Via Studio: **View → Toolbox → Ads → Immersive Ad Containers**. Posicione a unit na cena (parede, portal), salve e publique.

**Requisitos de elegibilidade** ([immersive-ads docs on GitHub](https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/monetization/immersive-ads.md)):
- Conta **ID-verified** e com **2FA** habilitado.
- Elegibilidade não garante que o Roblox vai servir anúncios; é discricionário.

**Formatos.**
- **Billboards 2D** (image ads) — unidade estática na parede.
- **Portais** — teleport pro jogo do advertiser.
- **Video Ads** (immersive) — tela 3D com vídeo. Launchado em fev/2024 ([DevForum](https://devforum.roblox.com/t/immersive-ads-video-ads-launch-and-publisher-eligibility-requirements/2953428)).

**Receita.** CPM-based. Sem rate card oficial. Relatos de comunidade indicam que os immersive ads pagam **menos por impressão que o rewarded video**, mas rendem passivamente.

### Políticas de anúncio (o que vem aí)

Em **4 de maio de 2026** entraram em vigor as novas políticas ([DevForum](https://devforum.roblox.com/t/new-advertising-policies-standards/4527365)):
- Qualquer conteúdo pago por marca para aparecer no seu jogo conta como anúncio e tem que ser registrado.
- Rewarded video independente foi proibido (só via API nativa).
- Em janeiro de 2027 começa revenue share sobre brand deals in-game.

**Proibidos em anúncios** ([community standards](https://about.roblox.com/community-standards)): álcool, tabaco, cannabis, cassino/gambling, apostas esportivas, armas, produtos financeiros arriscados, conteúdo político, saúde regulada, etc.

---

## 7. Comprar anúncios para divulgar seu jogo (Ads Manager)

**O que é.** O Ads Manager é o painel de self-service onde você **paga** pra promover seu jogo. Dois produtos:
- **Sponsored Experiences** — tile do seu jogo na home/discover.
- **Search Ads** — seu jogo no topo dos resultados de busca.

**Como usar.**
1. Creator Dashboard → **Ads Manager → Create Campaign**.
2. Objetivo: Awareness (CPM) ou User Acquisition (CPT = Cost per Teleport).
3. Público-alvo: idade, região, dispositivo, interesses.
4. Formato: tile 16:9 (novo, 2026) ou 1:1 legado.
5. Bidding: define **max CPM/CPT**. Leilão Vickrey (segundo preço + 1 centavo) — você paga o segundo maior lance, não o seu ([Ads Manager docs](https://create.roblox.com/docs/production/promotion/sponsoring-experiences)).
6. Campanha paga em Robux do saldo.

**Custo.**
- Sem rate card público. Reportagens falam em CPM baixo (Roblox tem inventário gigante). Um dev reportou "CPM 0.02" em teste ([devforum](https://devforum.roblox.com/t/sponsored-experiences-moving-to-ads-manager/2661756)).
- CPT (cost per teleport) é a métrica mais útil pra user acquisition.

**Como medir retorno.**
- Ads Manager mostra **impressions, visits, teleports, cost, CPI**.
- A partir de 2026 o Ads Manager Reporting inclui **ROAS (Return on Ad Spend)** e **Incrementality** ([DevForum RDC 2026](https://devforum.roblox.com/t/ads-manager-rdc-recap-earnings-roas-reporting-incrementality/4909790)).
- Fórmula caseira: `(Robux ganhos pelo jogador adquirido em 30 dias) / (custo de aquisição em Robux)`. ROAS > 1.0 = sustentável.

**Dica pra party game.** Sponsored Experience funciona melhor pra jogos com **alta retenção D1** (voltar no dia seguinte). Se seu D1 é < 25%, o CPI vira caro demais pra pagar. Priorize comprar anúncios **depois** de você ter social proof (10k+ visits, 4+ stars).

Fontes:
- [Sponsored Experiences / Ads Manager](https://create.roblox.com/docs/production/promotion/sponsoring-experiences)
- [Ads for Creators RDC 2026](https://devforum.roblox.com/t/ads-for-creators-rdc-recap-and-what%E2%80%99s-next/3929106)

---

## 8. UGC (User-Generated Content) — vender itens de avatar

**O que é.** Você publica chapéus, roupas, acessórios, mochilas ligados ao tema do seu jogo (ex.: "Chapéu de Batata Dourada do Batata Quente") no Marketplace do Roblox. Qualquer jogador do Roblox compra e equipa no avatar — não só seus jogadores. Ótimo pra viralizar.

**Como ativar (regras unificadas 14 de julho de 2026).** O Roblox unificou os pipelines 2D e 3D ([DevForum](https://devforum.roblox.com/t/building-stronger-protections-and-a-more-consistent-marketplace-unifying-2d-and-3d-avatar-item-publishing/4722717)):

1. **Upload** (fazer item existir): requer **ID verification ou linked parent account**.
2. **Publish for sale** (botar à venda): requer **ID verification**, **2-step verification** E **Plus ou Premium ativo**.
3. Modelar/desenhar no Blender/Photoshop → importar pro Studio com o **Avatar Creator / 3D Importer**.
4. Preencher metadata (categoria, tags), rodar testes de rigging, submeter pra moderação.
5. Esperar aprovação (algumas horas até dias).
6. Precificar e publicar.

**Fees em 2026.**
- **Upload fee: 80 Robux por item** pra 2D e 3D (unificado em 14/jul/2026) ([DevForum weekly recap](https://devforum.roblox.com/t/weekly-recap-july-13-%E2%80%93-17-animation-graphs-go-live-5%C3%97-more-data-store-storage/4743286)).
  - Observação: fontes conflitam — uma reportagem diz **200 Robux** pra 2D ([tech-insider](https://tech-insider.org/roblox-2d-creator-revenue-share-cut-2026/)), outra diz 80. A fonte oficial (DevForum unifying post) é a mais confiável.
- **Publishing advance**: variável por categoria, a partir de **600 Robux**; pro 2D é **10 Robux** ([devforum unifying post](https://devforum.roblox.com/t/building-stronger-protections-and-a-more-consistent-marketplace-unifying-2d-and-3d-avatar-item-publishing/4722717)).
- **Price floor** (preço mínimo): dinâmico, calculado pelo Roblox por categoria, começando em **5 Robux** ([Marketplace FAQ](https://create.roblox.com/docs/marketplace/frequently-asked-questions)).

**Revenue split do UGC (Marketplace).**
- Modelo **progressivo**: quanto mais acima do price floor você precifica, maior é o % do criador. Começa em **30%** (price floor) e vai até **70%** (6× o price floor). ([dev.to how Roblox pays creators 2026](https://dev.to/fzsheik/how-roblox-actually-pays-creators-the-30-fee-devex-rates-and-ugc-revenue-share-2026-580i))
- **In-experience** (vender o mesmo item dentro do SEU jogo via Avatar Shop API): split 30% criador + 40% dono da experiência + 30% Roblox — ou seja, se **você é os dois**, 70% volta pra você.
- **Free Limiteds**: Roblox cobra per-unit fee (~100 Robux/unit, reembolsado via daily rebates se vender).

**Verification badge do criador.** Separado. Você ganha badge automaticamente quando faz **≥ 2M Robux em revenue** E vende **≥ 200K itens** nos últimos 90 dias ([walkthroughs.net](https://walkthroughs.net/roblox-marketplace-selling-requirements-fees-explained)).

**Receita típica.** UGC é a trilha de maior potencial de escala se seu jogo viraliza — um chapéu de meme pode vender 50k unidades. Pra jogo pequeno, começa devagar (100–1 000 vendas/item).

**Riscos.**
- Upload fee **não é reembolsável** se o item não vender.
- Precisa pagar **Plus/Premium (US$ 4,99/mês)** pra publicar.
- Copiar design existente = takedown + conta em risco.

---

## 9. Comércio / produtos físicos

**O que é.** Vender produto físico (camiseta, caneca, pelúcia) de dentro do jogo via Commerce APIs com Shopify como parceiro.

**Status (último update).** Lançou em **maio de 2025** ([Newsroom](https://corp.roblox.com/newsroom/2025/05/roblox-launches-shopify-integration-amp-licensing-program), [TechCrunch](https://techcrunch.com/2025/05/15/roblox-now-lets-creators-sell-physical-products-within-their-experiences)) e, até o fim do levantamento, **não teve expansão de mercado anunciada em 2026**.

**Requisitos atuais.**
- Jogo **all-ages** (sem restrição 13+ ou 17+).
- Comprador precisa ser **nos EUA, 13+**.
- Pra **bundle digital + físico**: ≥ **100K DAU médio** e ≥ **1M Robux earnings** nos últimos 3 meses na sua experiência ([progameguides](https://progameguides.com/roblox-creators/roblox-commerce-revolution-shopify-integration/)).
- Conta Shopify configurada e aprovada no Approved Merchandiser Program.

**Fees.** Variam por preço, categoria, exclusividade e ratio virtual/físico — Roblox não publica rate card ([Commerce products docs](https://create.roblox.com/docs/production/monetization/commerce-products)).

**Conclusão pro Batata Quente.** **Não acessível agora**. Você mora no Brasil + jogo pequeno + sem 100K DAU. Volte a verificar em 2027.

---

## 10. DevEx (Developer Exchange) — Robux em USD

**O que é.** Converter Earned Robux em USD, pago via Tipalti (ACH, PayPal, cheque, wire).

**Requisitos atuais** ([DevEx Portal docs](https://create.roblox.com/docs/production/monetization/devex-portal)):
- Idade **13+** (com conta parent-linked) OU 18+ independente — **você se encaixa (18)**.
- **≥ 30 000 Earned Robux** acumulados pra primeira request.
- **Email verificado** na conta Roblox.
- Formulário fiscal preenchido no Taxes page do Creator Hub: **W-9** (EUA) ou **W-8BEN** (pessoa física não-EUA — seu caso) ou **W-8BEN-E** (PJ).
- Conta em boa posição (sem bans/strikes).
- 1 request por mês.
- **Premium/Plus não é mais obrigatório** (removido em 2022).

**Taxa de conversão atual (nov/2026).**
- **Padrão: US$ 0,0038 por Earned Robux** = US$ 3,80 por 1 000 Robux ([DevEx Portal docs](https://create.roblox.com/docs/production/monetization/developer-exchange), confirmado em várias fontes atuais).
- **Rate maior: US$ 0,0054 por Earned Robux** — pra Robux ganhos de usuários **verificados EUA, 18+**, em experiências elegíveis, desde **8 de junho de 2026** ([generalistprogrammer DevEx 2026](https://generalistprogrammer.com/tutorials/roblox-devex-guide-how-to-cash-out-robux)).
- Robux earned antes de **5 de setembro de 2025 às 10h PT** cash-out no rate antigo de **US$ 0,0035** (FIFO: Robux mais velho sai primeiro).
- Minimum cashout: **30 000 Earned Robux = ~US$ 114**.

**Caminho do dinheiro.**
```
Jogador paga R$ 49,90 por 400 Robux (Robux Store)
  → Compra tua skin de 100 Robux no seu jogo
  → Você recebe 70 Robux (70%) como "Earned Robux" (depois do holding de 60 dias)
  → DevEx request: 70 Robux × $0,0038 = $0,266 em USD
  → Tipalti deduz withholding + fee → cai no PayPal ou conta bancária
```

**Como receber no Brasil (DevEx = Tipalti).**
- **Métodos ativos**: ACH (EUA), **PayPal**, cheque, **wire transfer internacional**, eCheck.
- **Hyperwallet**: não é o processador do DevEx hoje — é **Tipalti** ([Help Center Tipalti](https://en.help.roblox.com/hc/pl/articles/27985018895124-Tax-and-DevEx-Portal-Tipalti-Information)). Fontes antigas falam em Hyperwallet mas está desatualizado.
- **Brasil**: PayPal (cobra fee de até US$ 21/pagamento + 1,9–3% câmbio), ou wire direto pra banco brasileiro em USD.
- Nome do portal **tem que bater exatamente** com nome da conta bancária.
- Tempo: PayPal 2–3 dias úteis, wire 1–5 dias úteis.

**Impostos — EUA (retenção na fonte).**
A partir de **1º de novembro de 2026** o Roblox passou a tratar DevEx como **royalties** pros fins de imposto EUA ([Roblox DevEx Tax News](https://www.panstag.com/2026/10/roblox-devex-tax-change.html), [offshoreproz](https://offshoreproz.com/en/blog/roblox-devex-us-tax-brazilian-developers)).
- **Sem W-8BEN válido** → 24% backup withholding sobre **todo** o payout.
- **Com W-8BEN válido** → 0–30% só sobre a parte do earnings que veio de jogadores EUA.
- **Brasil NÃO tem tratado bilateral com os EUA** → sem redução por treaty, portanto a retenção aplicável é **30% sobre a fatia US** (não sobre o total global). Outras fontes citam 15% como se houvesse tratado — isso é **incorreto** ou aspiracional.

**Impostos — Brasil (Receita Federal).**
- Royalty recebido do exterior por pessoa física = rendimento tributável mensalmente via **Carnê-Leão** ([Receita Federal — Carnê-Leão](https://www.gov.br/receitafederal/pt-br/assuntos/orientacao-tributaria/tributos/irpf/carne-leao)).
- Alíquota: tabela progressiva do IRPF — **de 0% até 27,5%** conforme a faixa mensal (base de cálculo em reais, pelo câmbio PTAX do mês do recebimento).
- Precisa **recolher DARF** código **0190** até o último dia útil do mês seguinte.
- Lançamento anual no IRPF normal.
- **Crédito do imposto pago nos EUA**: só é aproveitável com **tratado ou reciprocidade**. Como Brasil–EUA **não tem tratado**, o aproveitamento depende do **ato declaratório interpretativo RFB nº 16/2005** (reciprocidade de tratamento), que historicamente reconhece o crédito do imposto federal americano. **Consulte contador** antes de aplicar.
- CPF é obrigatório; não precisa de CNPJ. **MEI não é adequado** porque royalties de pessoa jurídica no exterior não é atividade MEI e ultrapassa limite rapidamente. Se faturamento > ~R$ 30k/mês vale abrir **PJ (Simples Nacional ou Lucro Presumido)** com contador.
- Documentação a guardar: extratos DevEx, 1042-S (que o Tipalti emite anualmente), comprovantes bancários.

**Risco cambial e operacional.**
- IOF em remessa internacional (zerou pra pessoa física em 2024, confira).
- PayPal pro BRL aplica spread de câmbio pesado — comparar com wire direto.
- Se for receber mais de ~US$ 10k/ano, considere abrir conta global (Wise/Nomad) que recebe ACH em USD.

Fontes DevEx:
- [DevEx Portal docs](https://create.roblox.com/docs/production/monetization/developer-exchange)
- [Tipalti info](https://en.help.roblox.com/hc/pl/articles/27985018895124-Tax-and-DevEx-Portal-Tipalti-Information)
- [Rate 2026 analysis](https://clipclip.io/guides/roblox-devex)
- [Rate $0.0054 for US 18+ spend](https://generalistprogrammer.com/tutorials/roblox-devex-guide-how-to-cash-out-robux)
- [Brazil tax 1/nov/2026 change](https://offshoreproz.com/en/blog/roblox-devex-us-tax-brazilian-developers)

---

## 11. Regras obrigatórias

### 11a. Random items / loot boxes pagos — disclosure de odds

A política **"Clarifying Requirements for Paid Random Items"** entrou em vigor **26 de maio de 2026** ([DevForum](https://devforum.roblox.com/t/clarifying-requirements-for-paid-random-items/4654622)) depois da lei coreana.

**O que é obrigatório.**
- **Mostrar odds numéricas** (% ou fração) de **cada resultado possível** no UI de compra, **antes** do jogador pagar.
- A disclosure é **global**, não só nos países regulados.
- Design do UI: visível, legível, não escondido em menu enterrado.

**Países regulados / restritos** (sua implementação precisa **oferecer alternativa** ou **esconder** o item pro jogador dessa região):
- Bélgica (loot boxes classificados como gambling desde 2018 — proibido pra pagos).
- Países Baixos (regulamentação por consumer law).
- Reino Unido.
- Austrália.
- Brasil — sim, **Brasil está na lista Roblox** de regiões onde você tem que oferecer alternativa.

**Menores.** Não pode vender loot box pago pra conta < 13 anos, ponto.

**Alternativas pra região restrita.** As opções usuais:
- Esconder o botão de loot box.
- Oferecer compra direta do item em vez da caixa.
- Dar a mesma "caixa" de graça por tempo de jogo (não-paga = ok).

### 11b. Público infantil (under 13)

**Chat** ([Roblox newsroom nov/2025](https://corp.roblox.com/newsroom/2025/11/roblox-requires-age-checks-limits-minor-and-adult-chat)):
- Usuários < 9: chat **off por padrão**, só com consent parental verificado.
- Usuários < 13: chat **só dentro do jogo**, não entre jogos. Filtro reforçado bloqueia info pessoal e conteúdo impróprio.
- Chat entre adulto e menor: bloqueado por idade verificada ([TechCrunch](https://techcrunch.com/2024/11/07/roblox-adds-new-safety-measures-to-ban-kids-under-13-from-social-spaces)).

**Trading Window.** Trading (troca de itens Limiteds) exige **13+** e Plus/Premium — crianças não podem trocar.

**Anúncios pra < 13**: só **contextual**, servidos direto pelo Roblox ou pelo criador — **nada programático** (nada de Google Ads targeting em kid).

**Design implicação.** Como party game ragdoll atrai muito < 13, você deve:
- Marcar o jogo com content rating correto no questionário.
- Não exigir chat pra funcionar (algumas features de social quebram pra esse público).
- Monetização cosmética (não força compra).

### 11c. Políticas de anúncio — o que você NÃO pode anunciar

Lista proibida ([advertising standards pelas Rules of Conduct](https://en.help.roblox.com/hc/en-us/articles/203313410-Roblox-Rules-of-Conduct)):
- Gambling real (cassinos, apostas esportivas).
- Álcool, tabaco, cannabis, vapes.
- Armas, drogas.
- Conteúdo político.
- Produtos financeiros arriscados (crypto, day trading).
- Dating sites.
- Produtos médicos sem FDA/ANVISA.
- Conteúdo adulto/sexual.
- Phishing / scams.

### 11d. Termos que podem banir seu jogo

([Community Standards](https://about.roblox.com/community-standards) + [Rules of Conduct](https://en.help.roblox.com/hc/en-us/articles/203313410-Roblox-Rules-of-Conduct))

- **Gambling simulado** com itens de valor real (incluindo Robux pot de aposta). Permitido só como tema visual sem transação real.
- **Pay-to-win extremo**: sem rule explícita, mas gera takedown via reclamação em massa. Mantenha PvP cosmetic-first.
- **Phishing / off-platform redirect**: criar jogo **só** pra mandar o jogador pra fora do Roblox = ban. Discord link ok em descrição, não pode ser o core loop.
- **Trocar Robux fora da plataforma** (RMT): ban permanente.
- **Copiar jogo existente** (asset theft, código clonado): takedown.
- **Content infringement**: usar IP de terceiro (Pokémon, Minecraft, Marvel) sem licença.
- **Falso advertising**: título/thumbnail mostrar o que o jogo não tem (fake bait).

**Mudanças de ToS 2026.** Novas Terms entraram em vigor **1 de novembro de 2026** ([techwiser](https://techwiser.com/roblox-terms-of-service-rules/)) — regras mais estritas sobre ban rules. Confira na [Roblox Terms of Use](https://en.help.roblox.com/hc/en-us/articles/115004647846-Roblox-Terms-of-Use).

---

## 12. Tabela resumo — quando ativar cada coisa

Legenda: Esforço 1 (uma tarde) → 5 (semanas de trabalho). Potencial inicial = antes de ter 10k DAU. Potencial maduro = 10k+ DAU.

| # | Fonte de renda | Esforço | Potencial início | Potencial maduro | Quando ativar (semana do roadmap) |
|---|---|---|---|---|---|
| 1 | **Game Passes** | 2 | Médio | Alto | **Semana 1 do launch**. VIP + Dash Duplo + Skin desde o dia 1. |
| 2 | **Developer Products** | 3 | Médio | Alto | **Semana 2–3**. Moedas, revive, skip-cooldown após ter economia de moedas no jogo. |
| 3 | **Private Servers** | 1 | Baixo | Baixo-Médio | **Semana 4+**. Só habilitar com 10 Robux/mês; marginal pra party game. |
| 4 | **Subscriptions in-experience** | 3 | Baixo | Médio-Alto | **Após 1 000 DAU estável** (~3 meses pós-launch). Daily rewards + skin exclusiva mensal. |
| 5 | **Creator Rewards** | 0 | Baixo | Médio | **Automático desde o launch**. Zero setup. |
| 6a | **Rewarded Video Ads** | 2 | Baixo | Médio | **Quando atingir 2 000 unique visitors/mês** (~semana 3–6). Recompensa com moedas. |
| 6b | **Immersive Ads** (billboards/portals) | 1 | Baixo | Baixo-Médio | **Depois do rewarded** estar funcionando (semana 6+). Coloca billboards no mapa. |
| 7 | **Ads Manager** (gastar) | 2 | N/A | Alto | **Semana 4–6**, só depois de ter D1 ≥ 25% e 4+ stars. Testar budget pequeno (500 R$). |
| 8 | **UGC Marketplace** | 4 | Baixo | Alto | **Semana 6–12**. Precisa Plus (US$ 4,99/mês) + 1º chapéu temático; publicar junto com update viral. |
| 9 | **Commerce físico (Shopify)** | 5 | N/A | N/A agora | **Não acessível** (precisa 100K DAU + EUA). Reavaliar 2027. |
| 10 | **DevEx (cash-out USD)** | 2 | N/A | Alto | **Assim que acumular 30 000 Earned Robux** (pós holding de 60 dias). Preencher W-8BEN **antes** do primeiro request. |

**Priorização recomendada pro Batata Quente nos primeiros 90 dias:**
1. **Launch day**: 3 Game Passes + 3 Developer Products + Creator Rewards (automático).
2. **Dia 7**: ativar Rewarded Video assim que der 2k unique/mês.
3. **Dia 14**: colocar Immersive Ads no mapa.
4. **Dia 30**: primeiro teste pago no Ads Manager (500 Robux budget, Search Ad direcionado).
5. **Dia 45**: comprar Plus/Premium e publicar primeiro item UGC (chapéu de batata).
6. **Dia 60–90**: Subscription mensal com batata dourada + skip-of-the-day.
7. **Dia 90+**: primeira DevEx, preencher W-8BEN antes.

---

**Resumo em uma linha.** Comece com Game Passes + Dev Products no launch, ative Rewarded Video aos 2k visits/mês, comece a gastar em Ads Manager só depois do D1 ≥ 25%, e só peça o primeiro DevEx com W-8BEN já preenchido pra evitar 24% de backup withholding; o teto real de receita vai vir de UGC + Subscription depois que tiver base fiel.
