# Lições de lançamento — devlog "Lancei meu jogo no Roblox há 3 dias"

Fonte: vídeo [szZRBhGXgW0](https://www.youtube.com/watch?v=szZRBhGXgW0) ("Lancei meu jogo
no Roblox há 3 dias — olha os números"), devlog do criador de *Rouba o Ovo do
Gigante* (variação BR do "Steal An Egg") contando o que deu certo e errado nos
primeiros 3 dias. 9 dicas, com timestamps originais e o que elas significam
para o **Batata Quente Ragdoll**.

## As 9 dicas

### 1. Implemente um funil de retenção `4:48 – 5:45`
Use a ferramenta de **Funnels** no Creator Hub pra ver em qual etapa o jogador
desiste. Sem isso você conserta o que *parece* ser o problema, não o que é.

> **Para Batata Quente Ragdoll:** definir 5 etapas de funil no Creator Hub:
> `joined → saw_first_round → survived_first_round → earned_first_coin →
> opened_shop`. No código, já replicamos `Status` e `Holder` por atributo;
> dá pra chamar `AnalyticsService:LogFunnelStepEvent` em cada transição
> (API nativa, não precisa de terceiro). Adicionar em `Main.server.luau` e
> `Shop.luau` (abre loja). Criar o funil no Creator Hub → Analytics → Funnels
> com esses 5 passos.

### 2. Torne o início acessível `6:25 – 7:00`
Mecânica inicial não pode frustrar. Primeiro item fácil, primeiro chefe fácil,
primeiros 30 s ensinam sem matar.

> **Para o nosso jogo:** o onboarding é a primeira rodada. Já é curto (pavio
> 10–18 s), mas o jogador novo chega sem moedas, sem cosmético, e pode perder
> na 1ª rodada sem ganhar nada. **Aplicado:** bônus de boas-vindas de 150
> moedas + 1 trilha grátis (`trail_fogo`) ao entrar pela 1ª vez. Faz o novo
> jogador já abrir a loja e equipar algo — e já engatou no laço de cosmético.

### 3. Respeite o tempo do jogador `7:00 – 7:35`
Ele reduziu uma esteira de 4 min pra 1 min. Tempo de espera entre ações é
veneno em jogo mobile.

> **Para o nosso jogo:** intermissão era 15 s em produção. **Aplicado:**
> 10 s (`Config.INTERMISSION = 10`). O countdown "PREPARA… 🥔" de 3 s dentro
> da rodada fica, porque é anúncio, não espera.
> O que não mudar: o pavio da batata (10–18 s) é o próprio gameplay, não espera.

### 4. Incentive a interação social `7:39 – 7:51`
Sistema que recompensa trazer amigo ou jogar em grupo.

> **Para o nosso jogo:** já é o Passo 4 do `plano-monetizacao.md` (convite
> de amigo com `PromptGameInvite` + `ReferredByPlayerId` nativo). Subir pra
> **Passo 2.5** (fazer junto com sons/polimento), não esperar a semana 4.
> +200 moedas pros dois em cada par novo que entrar.

### 5. Priorize o polimento em dispositivos móveis `8:34 – 9:15`
A maioria do Roblox é celular. Testar em celular fraco. Não travar.

> **Para o nosso jogo:** o HUD e os painéis (`ShopUI`, `DailyUI`) usam
> `UDim2.fromScale` e `UDim2.new(x, 0, y, 0)` — já responsivo. **Checklist pra
> rodar antes de lançar:**
> - Abrir no app do Roblox num Android fraco (ou usar o Device Emulator do
>   Studio: View → Device → iPhone SE/A20 Lite).
> - Confirmar que os botões 🛒/🎁/🎬 são atingíveis com o polegar e não
>   cobrem o joystick virtual.
> - Confirmar que o painel da loja não corta cartões no 16:9 pequeno.
> - Rodar `MicroProfiler` com 4 bots no Studio pra ver se bate 30 fps no mínimo.
> - Reduzir partículas da aura se a CPU subir.

### 6. Não foque apenas em gráficos `9:37 – 9:55`
Roblox premia hype, não polimento. Ideia divertida e simples ganha de jogo
bonito e complicado.

> **Para o nosso jogo:** o `MapBuilder.luau` gera o mapa por código
> (sem assets caros). Decisão certa — manter. Gastar tempo em título/ícone/
> clipe de TikTok ao invés de melhor skybox.

### 7. Teste com anúncios de valor baixo antes de investir `10:15 – 11:30`
Começa com R$ 10–30 de Sponsored. Vê se os jogadores entram. Só depois
escala.

> **Para o nosso jogo:** o `plano-monetizacao.md` dizia "só rode anúncios
> quando a retenção D1 passar de 20%". Refino: **mesmo antes dos 20% D1,
> rode uma campanha de 200 Robux (≈ R$ 2,50) só pra ver se o ícone converte**.
> CTR < 1 % = ícone ruim → troca o ícone antes de qualquer outro gasto.
> Só depois do CTR OK + D1 > 20 % que escala pra R$ 50–100/dia.

### 8. Cuidado com a conversão financeira `10:40 – 11:00`
Quando converte Robux pra crédito de anúncio, tem perda por taxas.

> **Para o nosso jogo:** é importante. Tem **dois caminhos** pra comprar ads
> no Ads Manager:
> 1. **Gastar Robux ganho** — você usa Robux do seu earned balance direto
>    no Ads Manager. Sem taxa extra, mas perde o *oportunity cost* de sacar
>    via DevEx (que converte Robux earned a US$ 0,0038 → R$).
> 2. **Comprar Robux novo pra anunciar** — você compra Robux com reais,
>    perde a margem do Roblox (≈ R$ 0,80/Robux no varejo contra R$ 0,20 no DevEx
>    cheio), e aí gasta.
> **Regra prática:** sempre use Robux earned direto. Nunca compre Robux pra
> anunciar seu próprio jogo — é jogar 4× o dinheiro fora.

### 9. Seja um criador de hype `15:18 – 15:55`
O sucesso depende tanto do jogo quanto da divulgação. Faça seus próprios
cortes e posta.

> **Para o nosso jogo:** o gancho "batata explode em ragdoll" já é clipável.
> **Checklist semanal:**
> - Gravar 3 clipes por semana (Cmd+Shift+5 no Mac, Xbox Game Bar no Windows).
> - Montar 15 s vertical, legenda com uma frase, música sem copyright.
> - Postar na mesma hora todo dia (18–22 h).
> - Primeiro clipe fechar com "link no perfil" → bio do perfil → link do jogo.
> - 1 clipe de "admin abuse" por semana ao vivo (dica do `classicos-roblox.md`).

---

## O que foi aplicado agora no código

- `Config.INTERMISSION` reduzido de 15 → 10 (dica 3).
- `PlayerData.luau` ganhou `welcomeGranted` (bool), e na 1ª entrada do jogador
  dá 150 moedas + `trail_fogo` grátis (dica 2). Avisa por `Notify`.
- `Main.server.luau` chama `AnalyticsService:LogFunnelStepEvent` em 3 pontos
  chave (entrou no servidor, sobreviveu a 1 rodada, abriu a loja) para a
  dica 1. Protegido por `pcall` pra não quebrar em canais que não têm o
  serviço.

## O que precisa ser feito manualmente

- Criar o funil no Creator Hub (**Analytics → Funnels → Create**): nome
  `onboarding_v1`, 5 passos. Depois ler semanalmente.
- Subir convite de amigo pro passo 2.5 do `plano-monetizacao.md`.
- Seguir o checklist mobile (item 5) antes do soft launch.
- Rodar a primeira campanha de teste no Ads Manager com 200 Robux só pra
  medir CTR do ícone (item 7).
