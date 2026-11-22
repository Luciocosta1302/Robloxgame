# Prompt para o Claude Code — pesquisa + monetização

Cole o texto abaixo no Claude Code, aberto dentro da pasta do projeto (`batata-bomba`).

---

Você está no projeto do meu jogo de Roblox "Batata Quente Ragdoll" (leia README.md e CLAUDE.md primeiro). Quero que você pesquise na web e depois implemente. Use fontes atuais (últimos 3 meses sempre que der) e confira tudo na documentação oficial em create.roblox.com/docs antes de afirmar qualquer coisa. Cite o link de cada informação.

## Parte 1 — Pesquisa (salve cada tema em `docs/pesquisa/`)

1. **Skills e ferramentas pra IA criar jogos Roblox** → `docs/pesquisa/skills.md`
   - Skills, plugins e agentes do Claude Code para Roblox/Luau (GitHub, marketplaces de skills, MCP).
   - MCP oficial do Roblox Studio e alternativas (robloxstudio-mcp etc.): o que cada um faz e qual usar.
   - Ferramentas de linha de comando: Rojo, Rokit/Aftman, Selene, StyLua, Wally, TestEZ/Jest-Lua.
   - Ferramentas de IA do próprio Roblox (Assistant, geração de mesh/texturas, Build).
   - No final: recomende o conjunto mínimo pra eu instalar e os comandos exatos, e crie uma skill própria em `.claude/skills/roblox-dev/SKILL.md` com as regras deste projeto.

2. **Animações** → `docs/pesquisa/animacoes.md`
   - Como criar e publicar animações (Animation Editor, Moon Animator, captura por câmera/vídeo, animações geradas por IA).
   - Animações de ragdoll, levantar do chão, comemoração de vitória, emotes, empurrão.
   - Como carregar animações por código (Animator, AnimationTrack, prioridades) e regras de permissão de assets.
   - Proponha 5 animações pro jogo e onde cada uma entra.

3. **Moda e tendências de avatar** → `docs/pesquisa/moda.md`
   - O que está em alta em roupas, acessórios, estilos de avatar e jogos de moda (ex.: Dress to Impress) agora.
   - Que cosméticos os jogadores mais compram dentro de jogos: trilhas, auras, chapéus, skins, efeitos de morte/explosão, títulos.
   - Proponha uma loja de cosméticos temática (skins de batata, efeitos de explosão, trilhas) com preços em moedas e em Robux.

4. **Tendências do jogo** → `docs/pesquisa/tendencias.md`
   - Top jogos e gêneros que mais cresceram nas últimas semanas, com foco em ragdoll, física, festa e jogos pra amigos.
   - O que copiar como ideia (gancho, ícone, título, atualizações) e o que evitar.

5. **Todas as formas de ganhar dinheiro com o jogo** → `docs/pesquisa/monetizacao.md`
   Pesquise e explique cada uma, com como ativar, requisitos e quanto rende em média:
   - Game Passes, Developer Products, Private Servers pagos
   - Assinaturas dentro do jogo
   - Premium Payouts (dinheiro por tempo de jogo de quem tem Premium)
   - Anúncios: vídeo com recompensa, anúncios imersivos, e anúncios pagos (Sponsored/Ads Manager) pra divulgar
   - Venda de itens UGC de avatar ligados ao jogo
   - Comércio/produtos físicos integrados, se estiver disponível
   - DevEx: requisitos (idade, mínimo de Robux, conta verificada), taxa de conversão atual e como recebo no Brasil (impostos, conta)
   - Regras que preciso seguir: caixas/itens aleatórios pagos (mostrar chances, países com restrição), público infantil, políticas de anúncio, o que pode banir o jogo
   - Termine com uma tabela: fonte de renda | esforço | potencial | quando ativar.

6. **Jogos novos da Steam que ainda não têm versão no Roblox** → `docs/pesquisa/steam-oportunidades.md`
   - Pesquise jogos lançados ou que viralizaram na Steam nos últimos 6 meses: mais vendidos, mais jogados, "Overwhelmingly Positive", jogos virais no TikTok/YouTube, jogos indie co-op baratos (estilo Lethal Company, R.E.P.O., Peak, Schedule I, Content Warning).
   - Para cada candidato, procure no Roblox (busca do Roblox, Rolimons, RoMonitor, Bloxodes, YouTube "roblox version of ...") se já existe versão, quantas e com quantos jogadores. Quero os que ainda **não têm** cópia ou têm só cópias fracas.
   - Monte uma tabela com os 10 melhores: jogo | por que é divertido | mecânica principal (o loop) | tem no Roblox? | dá pra fazer no Roblox sozinho? (dificuldade 1–5) | combina com celular? | potencial viral.
   - Escolha os 3 melhores e, para cada um, escreva um documento de design próprio: loop principal, história e mundo, progressão, multiplayer, como fica no celular, primeiros 5 minutos do jogador e um MVP que eu consiga lançar em 2–3 semanas.

   **Regra importante sobre "imitar":** mecânica, gênero e ideia de jogo não têm dono e podem ser usados como inspiração. Mas nome, personagens, história, falas, músicas, arte, logo e modelos do jogo original têm direitos autorais e marca — copiar isso gera denúncia DMCA e o Roblox derruba o jogo e pode banir a conta. Então: pegue a mecânica e o sentimento do jogo, e crie nome, história, personagens e visual **originais** (pode ser uma "versão Roblox" com tema diferente, tipo trocar monstros por memes brasileiros). Deixe claro no documento o que é inspirado e o que é original.

7. **Clássicos que todo jogo de Roblox tem** → `docs/pesquisa/classicos-roblox.md`
   Pesquise o que os jogos do topo usam e que os jogadores já esperam encontrar, e como implementar cada um:
   - Emotes e danças (roda de emotes, dança de vitória, emotes pagos)
   - Easter eggs e segredos (salas escondidas, referências a memes do Roblox e da internet, badges secretas)
   - Lojas que aparecem em toda fase/rodada (comprar vida extra, pular fase, boost, revive com Robux), lojas entre rodadas e "skip stage"
   - Códigos promocionais (aba de Codes, códigos liberados por meta de likes)
   - Badges, conquistas, títulos e níveis
   - Recompensa diária, roleta grátis, baú por tempo jogado, missões diárias
   - Bônus por entrar no grupo/curtir o jogo, sala VIP, chat tag VIP
   - Pets/acompanhantes, rebirth, multiplicadores, gifting (dar item de presente pra amigo)
   - Eventos ao vivo e "admin abuse", atualizações semanais com contagem regressiva
   - Leaderboards globais, servidores privados, convite de amigos com recompensa
   - Música e sons marcantes (sem usar músicas com direitos autorais)
   Para cada item: o que é, exemplo de jogo grande que usa, se rende dinheiro, e prioridade pro meu jogo (alta/média/baixa). Respeite as regras do Roblox sobre itens aleatórios pagos e público infantil.

## Parte 2 — Plano e implementação

8. Escreva `docs/plano-monetizacao.md` com as 5 primeiras coisas a implementar (incluindo os clássicos de prioridade alta do item 7), em ordem, sem pay-to-win (quem paga não deve ganhar a rodada só por pagar).

9. Implemente no código:
   - `src/server/Monetization.luau` usando MarketplaceService: checagem de Game Pass (VIP: +50% moedas e efeito dourado; Dash Duplo), `ProcessReceipt` correto e seguro pra Developer Products (pacotes de moedas, "Explosão em todo mundo" como efeito troll só visual), salvando compras pra não duplicar.
   - Loja de cosméticos com moedas do jogo (`src/server/Shop.luau` + UI no cliente).
   - Animações carregadas por código (vitória, levantar, empurrão).
   - Recompensa diária e anúncio com recompensa, se a API estiver disponível.
   - Todos os IDs (Game Pass, produtos, animações, sons) ficam em `src/shared/Config.luau` com valor 0 e um comentário dizendo onde criar. Nunca invente IDs.
   - Siga as regras do CLAUDE.md: servidor é a autoridade, valide tudo que vem do cliente.

10. Se o MCP do Roblox Studio estiver conectado, dê Play, leia o Output e corrija os erros. Se não estiver, rode Selene/StyLua se instalados.

11. No final, me entregue um resumo curto em português: o que pesquisou, o que implementou, o que eu preciso criar no Creator Hub (Game Passes, produtos, uploads) com o passo a passo, e quanto realisticamente dá pra ganhar no começo.

Eu tenho 18 anos e moro no Brasil. Escreva tudo em português, de forma direta.
