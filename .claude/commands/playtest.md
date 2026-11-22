---
description: Simula 4 playtesters (iniciante, explorer, QA técnico, juiz) lendo o código do jogo e produz um veredito consolidado em docs/playtests/
---

# /playtest — bateria de playtest por 4 personas

Simula playtesters lendo o código do jogo em `/home/user/Robloxgame/src/`. Rode
depois de qualquer mudança grande no jogo. Dura uns 5 minutos.

Faça o seguinte, nesta ordem:

## Passo 1 — Dispare 3 agentes em paralelo (todos em background)

Use o Agent tool com `subagent_type: "general-purpose"` e `run_in_background: true`.
Mande os 3 numa mensagem só, lado a lado, pra rodar em paralelo.

### Agente 1 — "Iniciante absoluto" (persona do jogador casual novo)

```
Você vai testar mentalmente o jogo Roblox "Batata Quente Ragdoll" como se fosse
um jogador muito jovem (criança de 8-10 anos ou adolescente novo no Roblox).
Perfil: lê pouquíssimo, clica no primeiro botão colorido que vê, confunde
moeda do jogo com Robux, quer resultado imediato, fecha o jogo se ficar
esperando mais de 30 segundos sem ação.

Leia (não precisa tudo, só o que afeta UX):
- /home/user/Robloxgame/README.md
- /home/user/Robloxgame/src/client/HUD.client.luau
- /home/user/Robloxgame/src/client/ShopUI.client.luau
- /home/user/Robloxgame/src/client/DailyUI.client.luau
- /home/user/Robloxgame/src/client/QuestsUI.client.luau
- /home/user/Robloxgame/src/client/CodesUI.client.luau
- /home/user/Robloxgame/src/client/ReviveUI.client.luau
- /home/user/Robloxgame/src/client/RebirthUI.client.luau
- /home/user/Robloxgame/src/server/Main.server.luau (só a parte de loop e boas-vindas)

Faça um walkthrough mental: você entra no jogo. O que vê? O que aperta primeiro?
Entende o objetivo? Entende o que são as moedas? Sabe que é Robux ou moeda do jogo?

Procure especialmente:
- Textos que esse jogador NÃO entende (jargão, palavras longas, inglês, emoji sem contexto)
- Risco de confundir moeda com Robux e gastar sem querer
- Fluxos confusos: modal abrindo em cima de modal, botões demais lado a lado
- Momentos onde ele ia pensar "chato" e sair (esperas longas, muita espera entre rodadas)
- Primeira morte dolorosa: a criança explode na primeira rodada e fica sem nada, o que acontece?

Salve o relatório em `/home/user/Robloxgame/docs/playtests/01-iniciante.md`.
Estruture com:
1. "Primeiros 60 segundos" (narrativa em 1ª pessoa, como a criança falaria)
2. "Confusões" (lista de pontos onde ela se perdeu)
3. "Frustrações" (lista de momentos onde quase saiu)
4. "Risco de gasto acidental" (onde ela pode clicar em Robux sem querer)
5. "Recomendações objetivas" (mudanças pontuais no código/UX, com file:line quando dá)

Escreva no máximo 400 palavras. Seja específico e brutal.
```

### Agente 2 — "Clicador curioso / explorador" (persona busca exploits)

```
Você vai auditar o jogo Roblox "Batata Quente Ragdoll" como alguém que aperta
TUDO e procura comportamentos quebrados ou exploits. Perfil: engenheiro júnior
curioso + jogador mala. Tenta entrar na sala VIP sem ter VIP, spama FireServer
com argumentos sujos, abre 5 modais ao mesmo tempo, dá dash enquanto está no
ragdoll, resgata o mesmo código 2 vezes em sequência rápida.

Leia TODOS os arquivos de servidor em /home/user/Robloxgame/src/server/*.luau
e o cliente onde o RemoteEvent é disparado em /home/user/Robloxgame/src/client/.

Audite cada OnServerEvent: o servidor valida tipo dos args? Valida estado
(jogador vivo, rodada ativa, holder correto)? Valida cooldown? Idempotência
quando faz sentido (codes, badges, referrals)?

Teste cenários concretos:
- Cliente manda ShopBuy("coins_small") com string que não existe no catálogo → quebra?
- Spam ShopEquip de um item que não tem → o que acontece?
- RedeemCode com string de 10000 chars → trunca?
- RedeemCode do mesmo code em 2 FireServers quase ao mesmo tempo → dá crédito dobrado?
- Rebirth logo depois de atingir 25 wins, dá Rebirth antes do leaderboards atualizar?
- Dev Product comprado depois de sair do jogo → ProcessReceipt lida?
- Dash no exato momento que começa o ragdoll → vazam cargas?
- VIP Portal tocado por não-VIP → só spam prompt sem teleporte? E se tem spam de .Touched com cooldown bypass?
- Resgate de código enquanto o DataStore de Codes está caído → fail-open libera abuse?
- Troll explode spam → algum lag?
- Daily reward com clock skew (jogador muda data do PC)?
- PromptProduct REVIVE_ROUND chamado depois da rodada acabar?
- Dar FireServer com argumento nil ou tabela — algum crash não pego por pcall?

Para cada achado, classifique severidade (critico / alto / medio / baixo) e
dê o file:line quando dá pra localizar.

Salve em `/home/user/Robloxgame/docs/playtests/02-explorer.md`. Máximo 700
palavras. Lista numerada de achados.
```

### Agente 3 — "QA técnico" (persona exigente)

```
Você vai fazer code review severo do jogo Roblox "Batata Quente Ragdoll".
Perfil: engenheiro sênior de QA. Exige zero bug. Lê tudo.

Leia TODOS os arquivos em:
- /home/user/Robloxgame/src/server/*.luau
- /home/user/Robloxgame/src/client/*.luau
- /home/user/Robloxgame/src/shared/*.luau

Procure sistematicamente:

**Correção**:
- Race conditions (duas corrotinas tocando a mesma tabela)
- Nil dereference (acesso a character.Humanoid sem FindFirst, Player.Character podendo ser nil no spawn)
- Off-by-one em loops
- Comparações `==` com nil onde poderia ser `type() ==`
- Receipt pode ser processado 2x por race entre pcall e markReceiptProcessed?

**Memória e vazamentos**:
- RBXScriptConnection não desconectado
- Tabelas com [Player] como chave que não limpam no PlayerRemoving
- Parts criadas sem Debris:AddItem de fallback
- Caches que crescem sem limite (nameCache em Leaderboard, processedReceipts)

**Segurança**:
- RemoteEvent aceita qualquer type sem validar
- Cliente pode dar FireServer(nil, {}, function())
- Cliente autoridade sobre algo que deveria ser servidor

**Performance**:
- Heartbeat/RenderStepped fazendo trabalho pesado todo frame
- GetService() dentro de loop
- Loops aninhados sobre Players
- SetAttribute por frame (tipo FuseProgress, ArenaRadius)

**APIs e estilo**:
- Chamadas deprecated (Humanoid:LoadAnimation, wait, spawn, delay)
- SetAsync em vez de UpdateAsync pra dados do jogador
- Uso de BodyPosition (deprecated) vs AlignPosition
- Caminhos com :WaitForChild indefinido (sem timeout) em contextos que precisam falhar

**Específicos**:
- MapBuilder.buildArena destrói arena antiga enquanto jogadores estão parados em cima dela? O que acontece?
- setHolder(nil) sem bomb — o highlight some? O walkspeed volta?
- clearMod é referenciado antes de ser definido? pickRoundModifier sempre retorna clearMod?
- awardCoins com valor negativo passa pra PlayerData.addCoins sem checar?

Para CADA finding, dê file:line, severidade (critico/alto/medio/baixo) e sugestão
de fix de uma linha.

Salve em `/home/user/Robloxgame/docs/playtests/03-qa.md`. Lista numerada,
agrupada por severidade. Máximo 1000 palavras.
```

## Passo 2 — Espere os 3 completarem

Você vai receber 3 task-notifications. NÃO leia o arquivo .output deles — leia
os relatórios .md que eles salvaram. Isso mantém seu contexto limpo.

## Passo 3 — Dispare o juiz (foreground)

Use Agent com `run_in_background: false` e `subagent_type: "general-purpose"`.

```
Você é o juiz final do playtest. Leia os 3 relatórios:
- /home/user/Robloxgame/docs/playtests/01-iniciante.md
- /home/user/Robloxgame/docs/playtests/02-explorer.md
- /home/user/Robloxgame/docs/playtests/03-qa.md

Consolide num VEREDITO objetivo em /home/user/Robloxgame/docs/playtests/00-veredito.md
com:

1. **TL;DR** (3 frases): pode lançar? sim / não / com ressalvas.
2. **Top 5 problemas** por severidade combinada (criticidade × probabilidade),
   com qual persona achou e o arquivo:linha de referência.
3. **Lista "CORRIGIR ANTES DE DAR PÚBLICO"** — itens bloqueantes.
4. **Lista "PODE ESPERAR"** — melhorias que não bloqueiam lançamento.
5. **Estimativa realista de retenção D1** dado o estado atual (10-30% é a faixa
   do nicho; justifique o número).
6. **Primeira coisa pra consertar hoje** — um só item, o maior ROI.

Máximo 600 palavras. Não repita o conteúdo dos relatórios; sintetize.
```

## Passo 4 — Reporte ao usuário

Em 5-8 linhas de chat: o veredito, top-3 problemas, e "quer que eu conserte
agora?". Nada mais — o arquivo veredito tem os detalhes.
