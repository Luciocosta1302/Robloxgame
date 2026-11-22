# Batata Quente Ragdoll — guia para o Claude Code

Jogo Roblox em Luau, sincronizado com Rojo (`default.project.json`). Leia o README para o conceito.

## Regras
- Todo número de balanceamento fica em `src/shared/Config.luau`.
- Servidor é a autoridade: rodadas, batata, moedas e eliminação ficam em `src/server`. O cliente só faz input, física local (dash/fling) e UI.
- Física do personagem é do cliente (network owner): para aplicar velocidade no jogador, mande `Remotes.Ragdoll` e deixe o cliente aplicar.
- Valide no servidor tudo que vem de RemoteEvent (cooldown, distância, estado).
- Sem IDs de asset inventados. Se precisar de som/modelo, deixe um campo em Config para o dono preencher.
- Textos da UI em português; nomes de código em inglês.

## Testar
- `rojo serve` + Studio conectado. Play solo funciona (MIN_PLAYERS = 1 no Studio).
- Multiplayer: Test → Clients and Servers com 2–4 jogadores.
- Se o MCP do Roblox Studio estiver conectado, use-o para dar Play, ler o Output e corrigir erros.

## Próximas tarefas
1. Sons de tique/explosão (Config.SOUNDS) e tremor de câmera
2. Loja de cosméticos com moedas
3. Mapas rotativos e arena que encolhe
4. Recompensa diária
