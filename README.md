# Batata Quente Ragdoll 🥔💥

Jogo de festa pro Roblox: uma batata-bomba passa de jogador em jogador. Quem estiver com ela quando o pavio acabar explode e sai voando em ragdoll. Dá pra **empurrar** (Q / botão no celular) os outros pra fora da arena ou pra passar a batata. O último vivo vence.

## Por que esse conceito (pesquisa de nov/2026)

- **Física/ragdoll é a tendência mais clara da leva nova.** No Top Playing Now de 18/11, 4 jogos com "ragdoll"/"crash physics" no nome somavam ~173 mil jogadores (Hyper Realistic Ragdoll, Ragdoll Soccer, BloxNG, Realistic Ragdoll MMA). 12 jogos novos têm "ragdoll" no título.
- **Jogos de bola/bomba + queda** também estão subindo (Volley Bomb, Ragdoll Soccer).
- **Jogar com amigos espalha o jogo**, e um **gancho claro** é apontado como o centro do sucesso.
- **Rodadas curtas e progresso rápido**: o público é mobile e quer recompensa imediata.
- Fonte principal: GGRecon (artigos de 02/11 e 19/11/2026), Bloxodes, creation.dev.

Gancho em uma frase: **"Não fica com a batata."** O pavio é aleatório (10–18 s) e a batata pisca mais rápido perto do fim — isso gera tensão e clipes engraçados (bom pra TikTok/Shorts).

## O que já funciona (MVP)

- Lobby e arena gerados por código (sem assets)
- Rodadas com intermissão, eliminação, vencedor
- Batata que passa ao encostar ou ao empurrar; quem segura corre mais rápido
- Ragdoll em explosão, empurrão e queda; queda da arena elimina
- Moedas e vitórias salvas em DataStore + leaderboard
- HUD: status, moedas, aviso piscando, notificações; botão mobile automático

## Como rodar (caminho mais direto com Claude Code)

### Opção A — Rojo (recomendado: código em arquivos, Claude Code edita direto)
1. Instale o Roblox Studio e o plugin **Rojo** (pelo Studio: Plugins → Manage → buscar "Rojo").
2. Instale o Rojo no PC: `aftman add rojo-rbx/rojo` ou baixe em github.com/rojo-rbx/rojo/releases.
3. Nesta pasta: `rojo serve`
4. No Studio: abra um Baseplate vazio → plugin Rojo → **Connect**.
5. Aperte **Play**. Em Studio funciona com 1 jogador; teste multiplayer em Test → Clients and Servers (2+ jogadores).
6. Abra `claude` nesta pasta e peça mudanças — o Rojo sincroniza ao salvar.

### Opção B — MCP oficial do Roblox Studio (Claude mexe no Studio ao vivo)
1. No Studio: Assistant → **…** → **Manage MCP Servers** → ativar **Enable Studio as MCP server**.
2. Use a conexão rápida para Claude Code (ou siga create.roblox.com/docs/studio/mcp).
3. O Claude consegue ler a árvore do jogo, editar scripts, rodar Luau e controlar o playtest.

Dica: use **A + B juntos** — Rojo pro código, MCP pro Claude testar e ver erros no Output.

## Roadmap pra tentar viralizar

**Semana 1 — polir o núcleo**
- Sons (explosão, tique do pavio acelerando) — escolher na Toolbox do Studio
- Câmera tremendo perto da batata, partículas, efeito de "voar longe"
- Testar com 4–8 amigos e ajustar Config (pavio, força, velocidade)

**Semana 2 — retenção**
- Loja de cosméticos com moedas: trilhas, chapéus, skins de batata (sem pay-to-win)
- Mapas rotativos (gelo escorregadio, plataformas que caem, arena que encolhe)
- Recompensa diária e missões ("passe a batata 20 vezes")

**Semana 3 — lançamento**
- Ícone e thumbnail chamativos (personagem voando + batata explodindo)
- Título com palavra em alta: ex. "🥔 Ragdoll Hot Potato" (versão EN) — a busca do Roblox é em inglês na maioria
- Gravar clipes curtos de explosões engraçadas pro TikTok/Reels/Shorts
- Rodar anúncios baratos (Sponsored) por poucos dias e ver retenção D1

**Monetização (depois de ter retenção)**
- Game Pass: VIP (efeito dourado, +moedas), Dash duplo
- Dev Product: "Explosão em todo mundo" (troll engraçado, sem afetar vitória)
- Private Servers baratos (jogo de amigos)

## Métricas pra acompanhar (Creator Dashboard)
- Retenção D1 (meta: >20%), tempo médio de sessão, taxa de clique no ícone
- Se a retenção for baixa, mude o gancho antes de gastar com anúncio.

## Estrutura
```
default.project.json   mapeamento Rojo
src/shared/Config.luau  todos os números de balanceamento
src/shared/Ragdoll.luau liga/desliga ragdoll
src/server/Main.server.luau  loop de rodadas e batata
src/server/Combat.luau  empurrão, knockback
src/server/MapBuilder.luau lobby e arena
src/server/PlayerData.luau  moedas, vitórias, DataStore
src/client/Controls.client.luau  dash e física do ragdoll no cliente
src/client/HUD.client.luau  interface
```
