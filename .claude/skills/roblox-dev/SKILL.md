---
name: roblox-dev
description: Usar sempre que mexer em código Luau neste projeto Batata Quente Ragdoll. Regras de arquitetura, segurança e estilo específicas deste repo.
---

# roblox-dev — regras do projeto Batata Quente Ragdoll

Este projeto é um party game Roblox em Luau, sincronizado via Rojo
(`default.project.json`). Carregue esta skill antes de editar qualquer arquivo
em `src/`.

## 1. Arquitetura — autoridade do servidor

- **Servidor manda.** Rodadas, estado da batata, moedas e eliminações ficam
  em `src/server/` e são verdade única. O cliente apenas envia input, roda
  física local (dash/fling) e desenha UI.
- **Cliente nunca decide.** Pontuação, vitória, derrota, vida, cooldown,
  posse da batata — só o servidor grava.
- **Física do personagem fica com o cliente** (ele é network owner). Para
  aplicar velocidade no jogador, o servidor envia `Remotes.Ragdoll` e o cliente
  aplica. Nunca force `Velocity` do server no personagem controlado por outro.

## 2. Remotes — sempre validar

- Toda `RemoteEvent`/`RemoteFunction` do cliente **tem que** ser validada no servidor:
  - **Cooldown** por jogador (Map `[Player] = tick()`).
  - **Distância** (jogador tá perto o bastante do alvo?).
  - **Estado** (rodada em andamento? jogador vivo? tem a batata?).
  - **Tipo** dos argumentos (`typeof(x) == "number"` etc.).
- Remotes ficam em `src/shared/Remotes.luau`, criados pelo servidor via
  `Instance.new("RemoteEvent")` com `Parent = ReplicatedStorage`.
- Nunca confie em qualquer argumento vindo do cliente sem validar.

## 3. Config.luau — números só aqui

- **Todo** número de balanceamento (dano, tempo, raio, preço, cooldown, chance)
  mora em `src/shared/Config.luau`. Nenhum número mágico no meio do código.
- IDs de asset (Game Pass, Developer Product, Animation, Sound, Image)
  também ficam no Config, com valor `0` e comentário dizendo onde criar
  no Creator Hub.
- **Nunca invente ID.** Se não existe ainda, o valor é `0` e um comentário
  `-- TODO: criar Game Pass para VIP e colar ID aqui`.

## 4. Nomes e idiomas

- **Código em inglês**: nomes de função, variável, módulo, arquivo, campo
  de Config, nome de Remote. Ex: `giveBomb`, `RoundState`, `BOMB_TIMER`.
- **UI em português**: textos mostrados ao jogador (botões, mensagens, hint
  da rodada). Ex: botão `"Jogar"`, mensagem `"Você explodiu!"`.
- Comentários em português ou inglês — tanto faz, mas seja consistente dentro
  do arquivo.

## 5. Estrutura de pastas (via Rojo)

```
src/
  server/    → ServerScriptService.Server    (autoridade)
  client/    → StarterPlayerScripts.Client   (input, UI, física local)
  shared/    → ReplicatedStorage.Shared      (Config, Remotes, tipos, módulos puros)
```

Se criar módulo novo, pense onde ele vive:
- Precisa rodar no servidor? → `src/server/`
- Precisa rodar no cliente? → `src/client/`
- Ambos precisam da mesma lógica (tipo, config, função pura)? → `src/shared/`

## 6. Formato de arquivo Rojo

- `.luau` para código moderno, `.lua` só se for dependência externa.
- Para fazer um `ModuleScript` vira `init.luau` dentro da pasta, OU arquivo
  solto com nome `Foo.luau`.
- `default.project.json` já aponta cada pasta para o serviço certo —
  **não mude** sem motivo claro, e se mudar, avise.

## 7. Estilo de código (StyLua + Selene)

- Rode `stylua src/` antes de qualquer commit se a ferramenta estiver instalada.
- Rode `selene src/` idem — corrija warnings.
- Config esperada: `syntax = "Luau"`, `indent_type = "Tabs"`,
  `column_width = 100`, `std = "roblox+testez"`.
- Prefira `local` sobre global sempre.
- `type` do Luau é bem-vindo em tipos de retorno e campos públicos de módulo.

## 8. APIs — atuais vs. depreciadas

- Carregue animação com `Animator:LoadAnimation(animation)` — **não** com
  `Humanoid:LoadAnimation` (depreciado).
- Para distância 2D no plano use `(a - b).Magnitude` com Vector3 zerando Y se
  necessário; prefira `Vector3.Magnitude` a cálculos manuais.
- Prefira `task.wait` / `task.spawn` / `task.delay` em vez de
  `wait` / `spawn` / `delay` (depreciados).
- `DataStoreService` com `UpdateAsync`, nunca `SetAsync` cru para dados do jogador.
- Para MarketplaceService, implemente `ProcessReceipt` idempotente
  (guarde o PurchaseId para não processar duas vezes).

## 9. Testar

- Rodar `rojo serve` + Studio conectado via plugin Rojo.
- **Play solo**: funciona porque `MIN_PLAYERS = 1` no Studio.
- **Multiplayer**: `Test → Clients and Servers` com 2–4 jogadores.
- Se o MCP do Roblox Studio estiver conectado, use-o para dar Play, ler Output
  e consertar erros automaticamente.

## 10. O que nunca fazer

- Inventar `assetId` (som, imagem, mesh, animação, Game Pass, Developer Product).
- Dar poder ao cliente de alterar moedas, pontuação ou estado da rodada
  diretamente.
- Usar `loadstring` / `HttpService:LoadFromCloud`.
- Deixar número mágico no meio do código — tem que estar em `Config.luau`.
- Commitar sem rodar (ou tentar rodar) StyLua e Selene.
- Mudar `default.project.json` sem necessidade clara.
- Adicionar dependência (`wally.toml`) sem antes avaliar se não dá pra fazer em
  ~30 linhas de código próprio.

## 11. Checklist antes de dizer "pronto"

1. Números novos estão em `Config.luau`? 
2. IDs novos (se houver) estão em `Config.luau` com valor `0` + comentário?
3. Todo Remote novo tem validação de cooldown + estado + tipo no servidor?
4. UI nova tem texto em português?
5. StyLua + Selene passam sem warnings (se as ferramentas estão instaladas)?
6. Dei Play solo e multiplayer no Studio, se possível?
