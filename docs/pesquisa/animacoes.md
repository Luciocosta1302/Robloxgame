# Pesquisa: Animações para "Batata Quente Ragdoll"

> Documento de pesquisa técnica sobre como criar, carregar e usar animações no Roblox, aplicado ao party game "Batata Quente Ragdoll" (jogadores seguram a batata, viram ragdoll ao explodir, e passam a batata entre si).
>
> Fontes priorizadas: documentação oficial `create.roblox.com/docs` e tópicos recentes (2024-2026) do DevForum oficial. Todas as afirmações têm link direto na linha ou ao final da seção.

---

## 1. Formas de criar animação no Roblox

### 1.1 Animation Editor nativo do Studio

O **Animation Editor** é a ferramenta oficial embutida no Studio. É acessível pela aba **Avatar** da barra de ferramentas ou por **Window > Avatar** ([create.roblox.com/docs/animation/editor](https://create.roblox.com/docs/animation/editor)). Para criar animações você precisa de um rig; se não tiver um, use o **Rig Builder** que vem no Studio para inserir um rig pronto (R6, R15 ou um custom) ([create.roblox.com/docs/animation/editor](https://create.roblox.com/docs/animation/editor)).

**Fluxo de criação:**
1. Selecione o rig e abra o Animation Editor pela aba Avatar.
2. Crie poses movendo/rotacionando as partes do rig (braços, pernas, torso). O editor interpola automaticamente entre as poses com as curvas de easing escolhidas.
3. Para animações em loop, duplique os keyframes iniciais ao final — o editor não interpola do último para o primeiro quadro automaticamente.

**Publicar:**
- No controle de reprodução/mídia dentro do editor, clique no botão `⋯` (três pontos) e escolha **Publish to Roblox**. Preencha o formulário de Asset Configuration e salve. Copie o **Asset ID** gerado — é esse ID que você usa com `rbxassetid://...` no código ([create.roblox.com/docs/animation/editor](https://create.roblox.com/docs/animation/editor)).
- Toda animação precisa estar publicada na nuvem para tocar em um jogo publicado — não existe animação "local" em produção ([create.roblox.com/docs/animation/editor](https://create.roblox.com/docs/animation/editor)).

**Exportar como arquivo:** Clique com o botão direito no nome da animação e selecione **Save to File** — salva um `.rbxm` que você pode compartilhar com outros devs ([create.roblox.com/docs/animation/editor](https://create.roblox.com/docs/animation/editor)).

**Importar de software externo:** O editor também aceita animações vindas de `.fbx` (ex.: Blender via File > Export > FBX, Maya via plugin FBX, Cascadeur via botão "Publish to Roblox" dentro do próprio Cascadeur) ([create.roblox.com/docs/en-us/art/characters/export-avatar-animations-from-maya](https://create.roblox.com/docs/en-us/art/characters/export-avatar-animations-from-maya), [cascadeur.com/help/category/280](https://cascadeur.com/help/category/280)).

### 1.2 Moon Animator 2

O **Moon Animator 2** é um plugin de terceiros muito popular por oferecer timeline multi-track, controle sobre câmera, partículas e efeitos — coisas que o editor oficial não cobre bem para cutscenes.

- **Preço:** Atualmente é vendido como plugin pago na Creator Store por aproximadamente **US$ 29,99** ([thetoolstrunk.com/?p=49964](https://thetoolstrunk.com/?p=49964)). Antes era vendido por volta de 1.200 Robux. O autor migrou para preço em dólar.
- **Vale a pena?** A opinião geral no DevForum é positiva — devs dizem que é fácil de aprender e muito superior ao editor nativo para animações complexas, mas lembram que hoje ele é pago ([devforum.roblox.com/t/is-moon-animator-worth-it/2477738](https://devforum.roblox.com/t/is-moon-animator-worth-it/2477738)).
- **Versão "free"?** Existem builds não-oficiais modificados hospedados fora da Creator Store (ex.: GitHub) que se instalam como "local plugin" ([github.com/zildjibian/moon-animator](https://github.com/zildjibian/moon-animator)). **Atenção:** não são atualizados automaticamente, podem violar termos de uso e não têm garantia de segurança. Recomendação: se o projeto puder bancar, compre a versão oficial.
- **Alternativas gratuitas:** O editor nativo cobre 80% dos casos. Para quem quer algo intermediário, há o **RFrame Animator** (também free, referenciado em discussões do DevForum como "meio-termo entre o oficial e Moon") ([devforum.roblox.com/t/rframeanimator-a-brand-new-animation-editor/1406100](https://devforum.roblox.com/t/rframeanimator-a-brand-new-animation-editor/1406100)).

**Recomendação para "Batata Quente Ragdoll":** O editor nativo é suficiente para as animações listadas na Seção 4. Moon Animator só se justifica se você for criar cutscene de vitória com câmera cinematográfica.

### 1.3 Captura por câmera/webcam

A Roblox oferece **Animation Capture** diretamente no Animation Editor (ambos ainda em beta em 2025-2026):

- **Face Capture (webcam ao vivo):** permite usar a webcam para dirigir rigs com cabeças compatíveis com animação facial. Grava até **60 segundos** por take. Ative em **File > Beta Features > Face Capture** e reinicie o Studio; na primeira vez é preciso aceitar um consentimento de coleta de dados faciais e dar permissão à câmera ([create.roblox.com/docs/animation/capture](https://create.roblox.com/docs/animation/capture)).
- **Body Capture (upload de vídeo):** gera keyframes de corpo inteiro para rigs R15 a partir de um arquivo `.mp4` ou `.mov`. O clipe precisa ter **uma única pessoa**, bem iluminada, visível o tempo todo, câmera estática e duração abaixo de **15 segundos**. Ative o beta **Live Animation Creator** ([create.roblox.com/docs/animation/capture](https://create.roblox.com/docs/animation/capture), [devforum.roblox.com/t/live-animation-creator-beta/1908284](https://devforum.roblox.com/t/live-animation-creator-beta/1908284)).

**Soluções de terceiros — Rokoko Vision:** A Rokoko é referência em mocap AI, mas sua versão 3.0 **removeu a captura ao vivo por webcam**. Agora toda captura acontece via upload de vídeo dentro do **Rokoko Create**, e exporta em FBX/BVH ([rokoko.com/insights/introducing-rokoko-vision-3-0](https://www.rokoko.com/insights/introducing-rokoko-vision-3-0), [rokoko.com/products/video](https://www.rokoko.com/products/video)). O suporte oficial diz que a captura dual-cam e webcam online será **retirada em 16/agosto/2026** ([support.rokoko.com/hc/en-us/articles/48823033216017](https://support.rokoko.com/hc/en-us/articles/48823033216017-Rokoko-Vision-and-Rokoko-Create-What-you-need-to-know)). Para importar no Roblox, o FBX exportado passa ainda pelo fluxo Blender → Animation Editor.

**Recomendação para o jogo:** A captura nativa (body via vídeo) é a rota mais simples se você quiser gravar reações exageradas de "batata quente" com um ator real. Rokoko só vale se já for parte do pipeline da equipe.

### 1.4 Animações geradas por IA

Em 2025-2026 o Roblox investe pesado em IA generativa, mas para **3D e rigging**, não ainda para **animação texto-para-movimento**:

- **Avatar Auto Setup:** gera automaticamente o rig R15, dados de animação facial e pontos de encaixe para acessórios a partir de um modelo humanoide ([maginative.com/article/roblox-unveils-ai-powered-tools-to-make-creating-3d-content-easier](https://www.maginative.com/article/roblox-unveils-ai-powered-tools-to-make-creating-3d-content-easier/)).
- **Cube 3D:** modelo texto-para-3D lançado em março/2025. Já gerou mais de 1,8M de objetos em um ano, mas **não gera animação** — só malha ([devforum.roblox.com/t/beta-cube-3d-generation-tools-and-apis-for-creators/3558947](https://devforum.roblox.com/t/beta-cube-3d-generation-tools-and-apis-for-creators/3558947), [axios.com/2025/03/17/roblox-genai-3d-image-generator](https://www.axios.com/2025/03/17/roblox-genai-3d-image-generator)).
- **Mixamo + importador:** o fluxo clássico ainda é válido. Mixamo é gratuito (Adobe), tem 3000+ animações. Rota mais prática em 2025: **plugin RoMixamo** faz importação em um clique para R15/R6 ([devforum.roblox.com/t/plugin-romixamo-use-mixamo-animations-in-roblox-easily-as-one-click/3655115](https://devforum.roblox.com/t/plugin-romixamo-use-mixamo-animations-in-roblox-easily-as-one-click-v500/3655115)). Rota manual: exportar rig do Blender para Mixamo, baixar a animação, importar de volta no Blender e usar o **Blender Rig Exporter/Animation Importer** ([devforum.roblox.com/t/blender-rig-exporter-animation-importer/34729](https://devforum.roblox.com/t/blender-rig-exporter-animation-importer/34729)). Atenção: Mixamo tem mais ossos que R15, pode quebrar hierarquia — sempre exportar com **apenas a armature** selecionada.

**Status atual:** Não existe (ainda) um "texto → animação" oficial do Roblox. Para o jogo, use Mixamo+RoMixamo para base e refine no Animation Editor.

### 1.5 Comprar/pegar animações livres (Toolbox e Marketplace)

A **Creator Store** (antigo Toolbox) tem muitas animações gratuitas, mas:

- **Todo asset gratuito ainda é protegido por direitos autorais** — o autor apenas licencia para uso sem royalties/créditos; isso não é "domínio público" ([devforum.roblox.com/t/reminder-about-ip/116517](https://devforum.roblox.com/t/reminder-about-ip/116517)).
- A Roblox modera assets ativamente contra DMCA e Community Rules ([create.roblox.com/docs/production/creator-store](https://create.roblox.com/docs/production/creator-store)).
- Risco real: se alguém publicou algo roubado como free model, você pode ser forçado a remover depois; em casos extremos, com comentários de decompile indicando asset roubado, há relatos de advertência/suspensão ([devforum.roblox.com/t/am-i-allowed-to-use-toolbox-assets-how-safe-is-it/2232744](https://devforum.roblox.com/t/am-i-allowed-to-use-toolbox-assets-how-safe-is-it/2232744)).
- Desde 2024-2025, a Roblox permite **publicar e vender animation packs e emotes no Marketplace** ([devforum.roblox.com/t/full-release-create-and-sell-animation-packs-on-marketplace/4861803](https://devforum.roblox.com/t/full-release-create-and-sell-animation-packs-on-marketplace/4861803), [devforum.roblox.com/t/avatar-creators-can-publish-and-sell-emotes-on-marketplace/3866987](https://devforum.roblox.com/t/avatar-creators-can-publish-and-sell-emotes-on-marketplace/3866987)) — alternativa segura: comprar pack oficial em vez de pegar no Toolbox.

**Recomendação:** para "Batata Quente Ragdoll", priorize animações feitas internamente ou compradas no Marketplace. Toolbox só para prototipagem.

---

## 2. Animações específicas para este jogo

### 2.1 Ragdoll (combinar física + animação)

O Roblox tem **física de ragdoll nativa** ao desativar o `Humanoid` (estado `PlatformStand = true`), mas isso **desliga qualquer animação em execução** nas partes afetadas, porque o motor passa controle das Motors para físicas de restrição ([devforum.roblox.com/t/how-do-i-make-a-ragdoll-standing-transition-smoother/3171976](https://devforum.roblox.com/t/how-do-i-make-a-ragdoll-standing-transition-smoother/3171976)).

**Como combinar:**
- Dispare a animação **antes** do ragdoll começar (ex.: animação de "voar pelos ares" tocando por ~0.3s, depois ativa ragdoll).
- Durante o ragdoll, use `BodyVelocity` ou `ApplyImpulse` para dar a sensação de arremesso ([devforum.roblox.com/t/explosion-knockback/3435842](https://devforum.roblox.com/t/explosion-knockback/3435842)).
- Mude de volta para `GettingUp` no estado do Humanoid no cliente, não no servidor, para evitar o bug do "backflip ao levantar" ([devforum.roblox.com/t/how-do-i-fix-the-ragdoll-causing-me-to-backflip-when-unragdolling/3939958](https://devforum.roblox.com/t/how-do-i-fix-the-ragdoll-causing-me-to-backflip-when-unragdolling/3939958)).

### 2.2 Levantar do chão após o ragdoll (Recovery)

O Humanoid tem o estado nativo `Enum.HumanoidStateType.GettingUp`. Problemas comuns relatados no DevForum:

- Personagem é "lançado" ao se levantar (jogadores, mas não NPCs) ([devforum.roblox.com/t/player-gets-flinged-when-getting-up-from-ragdoll-whereas-npc-gets-up-normally/3651271](https://devforum.roblox.com/t/player-gets-flinged-when-getting-up-from-ragdoll-whereas-npc-gets-up-normally/3651271)).
- Personagem fica "congelado" após levantar ([devforum.roblox.com/t/how-do-you-stop-the-player-from-freezing-after-getting-up-from-a-ragdoll/3602048](https://devforum.roblox.com/t/how-do-you-stop-the-player-from-freezing-after-getting-up-from-ragdoll/3602048)).

**Solução recomendada:**
- Desativar `PlatformStand` **antes** de setar `ChangeState(Enum.HumanoidStateType.GettingUp)`.
- Rodar a troca de estado no cliente para evitar replicação atrasada.
- Para controlar quando o jogador **pode** se levantar sozinho, use `Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false/true)` ([devforum.roblox.com/t/how-can-i-keep-a-humanoid-from-getting-up/2824779](https://devforum.roblox.com/t/how-can-i-keep-a-humanoid-from-getting-up/2824779)) — essencial para o seu caso: você quer segurar o jogador no chão por X segundos antes de ele voltar à batalha.
- Toque uma animação custom de prioridade **Action** no evento `StateChanged` quando o estado virar `GettingUp` — ela sobrescreve a animação default de levantar.

### 2.3 Comemoração de vitória

Não há documentação oficial de "animação de vitória" como feature pronta. Padrão do gênero:

- Anima a 3-6 segundos, prioridade **Action** ou **Action2**, em loop desativado.
- Pode combinar com `ParticleEmitter` (confete), `Sound` e o emote oficial de dança equipado no `HumanoidDescription`.
- Em jogos tipo "ragdoll party", o padrão observado é sincronizar emotes entre jogadores — ex.: no jogo *RAGDOLL* (asset 8342867486), tocar em outro jogador sincroniza a dança ([roblox.com/games/8342867486](https://www.roblox.com/games/8342867486/RAGDOLL)).

### 2.4 Emotes (sistema oficial)

O sistema de emotes usa `HumanoidDescription`:

- `HumanoidDescription:SetEmotes(table)` — recebe tabela mapeando nome → lista de asset IDs.
- `HumanoidDescription:SetEquippedEmotes(table)` — até **8 emotes** equipados no menu do jogador.
- `Humanoid:PlayEmote(emoteName)` — toca e retorna `true` se sucesso, `false` caso contrário ([create.roblox.com/docs/characters/emotes](https://create.roblox.com/docs/characters/emotes), [github.com/Roblox/creator-docs/blob/main/content/en-us/characters/emotes.md](https://github.com/Roblox/creator-docs/blob/main/content/en-us/characters/emotes.md)).
- Desabilitar o menu de emotes **não** impede o comando de chat `/e dance` etc. ([create.roblox.com/docs/characters/emotes](https://create.roblox.com/docs/characters/emotes)).

Os emotes oficiais keyframe-based (dança, saudar, agitar) ficam listados no catálogo da Roblox e cada um tem um AssetId que pode ser usado em `SetEmotes`.

### 2.5 Empurrão / Dash

Mecânica clássica de party: jogador toca espaço ou botão e empurra o portador da batata.

- Animação: 0.3-0.5s, prioridade **Action**, de braços estendidos para frente.
- No keyframe do "impacto" (meio da anim), dispara `ApplyImpulse` no HumanoidRootPart do alvo. Use `KeyframeReached` para sincronizar efeito com animação ([devforum.roblox.com/t/how-to-make-knockback-for-bomb/1032917](https://devforum.roblox.com/t/how-to-make-knockback-for-bomb/1032917)).
- Prefira `ApplyImpulse` ou `LinearVelocity` em vez dos antigos `BodyForce`/`BodyVelocity` (deprecated) ([devforum.roblox.com/t/explosion-knockback/3435842](https://devforum.roblox.com/t/explosion-knockback/3435842)).

---

## 3. Como carregar e tocar animação por código

### 3.1 Criar o `Animation` e obter o `Animator`

A rota recomendada hoje (`Humanoid:LoadAnimation` ainda funciona mas emite warning de deprecated — use `Animator`):

```lua
-- LocalScript dentro de StarterCharacterScripts ou Script em um NPC
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator") -- Humanoid cria automaticamente

local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://COLE_O_ID_AQUI"

local track = animator:LoadAnimation(animation)
track.Priority = Enum.AnimationPriority.Action
track.Looped = false
track:Play()
```

Referência: [create.roblox.com/docs/animation/using](https://create.roblox.com/docs/animation/using), [create.roblox.com/docs/reference/engine/classes/AnimationController/LoadAnimation](https://create.roblox.com/docs/reference/engine/classes/AnimationController/LoadAnimation).

Para rigs sem `Humanoid`, crie um `AnimationController` + `Animator` manualmente e parenteie no rig ([create.roblox.com/docs/animation/using](https://create.roblox.com/docs/animation/using)).

### 3.2 Controle do `AnimationTrack`

Métodos principais ([create.roblox.com/docs/reference/engine/classes/AnimationTrack](https://create.roblox.com/docs/en-us/reference/engine/classes/AnimationTrack)):

- `track:Play(fadeTime, weight, speed)` — fade padrão 0.1s.
- `track:Stop(fadeTime)` — fade padrão 0.1s.
- `track:AdjustSpeed(speed)` — 2 = dobro de velocidade; útil para cooldowns: `track:AdjustSpeed(track.Length / desiredDuration)`.
- `track:AdjustWeight(weight, fadeTime)` — mistura entre animações simultâneas.
- Evento `track.KeyframeReached:Connect(function(name) ... end)` — útil para disparar VFX/impacto no frame exato (ex.: explosão no keyframe `"BOOM"`).
- Evento `track.Stopped` — ideal para enfileirar a próxima animação (ex.: terminar `PanicPose` e voltar ao idle).

### 3.3 Prioridades de animação

Enum `Enum.AnimationPriority`, do mais alto ao mais baixo ([create.roblox.com/docs/reference/engine/enums/AnimationPriority](https://create.roblox.com/docs/en-us/reference/engine/enums/AnimationPriority.md)):

| Prioridade | Uso recomendado |
|---|---|
| **Action4** | Mais alto — sobrescreve tudo (ex.: morte, cutscene dentro do jogo). |
| **Action3** | Ações críticas (ex.: animação de vitória). |
| **Action2** | Ações secundárias (ex.: celebração, tomar dano). |
| **Action** | Ações gerais (atacar, empurrar, pegar objeto). |
| **Movement** | Walk / Run / Swim. |
| **Idle** | Parado. |
| **Core** | Default da Roblox — fácil de sobrescrever. |

Observações do DevForum: há relatos de pacotes oficiais da Roblox marcados como `Action` quando deveriam ser `Movement`, o que causa bugs onde a animação de correr "trava" ao parar ([devforum.roblox.com/t/some-official-animation-packages-have-incorrect-animation-priority/3773601](https://devforum.roblox.com/t/some-official-animation-packages-have-incorrect-animation-priority/3773601)). Sempre revise a prioridade ao publicar.

**Como funciona o override:** a comparação é **por joint**. Se a animação A (Idle) mexe no braço e a animação B (Action) também, B ganha naquele braço. Se B só mexe na perna, A continua controlando o braço simultaneamente ([create.roblox.com/docs/reference/engine/enums/AnimationPriority](https://create.roblox.com/docs/en-us/reference/engine/enums/AnimationPriority.md)).

### 3.4 Regras de upload e permissão

- **Publicar:** sempre pela caixa de diálogo do Animation Editor (ver Seção 1.1).
- **Owner User vs Group:** Se o jogo pertence a um **group**, a animação precisa ser publicada **pelo group** — animações de user individual **não tocam** em jogos de group ([devforum.roblox.com/t/animation-only-works-for-publisher-in-a-group-game/3120683](https://devforum.roblox.com/t/animation-only-works-for-publisher-in-a-group-game/3120683)).
- **Permissões de role no group:** o dev precisa dos papéis "View development items" + "Create and configure development items" para que o selecionador de grupo apareça no Studio ([devforum.roblox.com/t/animations-under-a-group-dont-work-for-group-members/3073070](https://devforum.roblox.com/t/animations-under-a-group-dont-work-for-group-members/3073070)).
- **Compartilhar com colaboradores:** desde 2024, animações podem ser compartilhadas com usuários específicos que podem então autorizar uso em suas experiências. Acesso é revogável ([devforum.roblox.com/t/sharing-animation-assets-with-connections-and-groups/3892540](https://devforum.roblox.com/t/sharing-animation-assets-with-connections-and-groups/3892540)).
- **Público geral:** até 2026, animações **não podem ser publicadas como "public"** da forma que modelos podem — a pergunta aparece recorrente no DevForum sem resposta positiva ([devforum.roblox.com/t/public-animations/43299](https://devforum.roblox.com/t/public-animations/43299)).
- **Bug conhecido:** mesmo com permissões corretas, há relatos de "sanitized ID" errors em Team Create — aguardar fix oficial e, se necessário, republicar com conta de grupo ([devforum.roblox.com/t/failed-to-load-animation-asset-access-beta/3838581](https://devforum.roblox.com/t/failed-to-load-animation-asset-access-beta/3838581)).

**Recomendação para "Batata Quente Ragdoll":** crie um **group** para o jogo desde o início e publique **todas as animações no group**. Evita todo tipo de dor de cabeça de permissão quando a equipe crescer.

---

## 4. Animações propostas para "Batata Quente Ragdoll"

| # | Nome | Prioridade | Duração sugerida | Quando dispara | Impacto esperado |
|---|---|---|---|---|---|
| 1 | **VitoriaDanca** | `Action3` | 4-6s em loop | Fim de round, para o último sobrevivente. Dispara via `RemoteEvent "RoundEnded"` no cliente do vencedor. | Momento climático do jogo. Aumenta retenção: jogadores querem ganhar para ver a dança. Combine com confete (`ParticleEmitter`), som de vitória e câmera levemente afastada. |
| 2 | **LevantarDoChao** | `Action` (sobrepõe a default `Core`) | 0.8-1.2s | Quando `Humanoid.StateChanged` vai para `GettingUp`, após ragdoll de explosão. Tocar via LocalScript pra não ter atraso. | Dá personalidade e peso cômico ao levantar — o jogador faz pose atrapalhada ("onde eu tô?"), virando marca registrada do jogo. Resolve ainda o bug do "fling ao levantar" ao sobrescrever a animação nativa. |
| 3 | **EmpurrarBatata** | `Action` | 0.4-0.5s | Quando portador da batata aperta botão de empurrão / colide intencionalmente com outro jogador. `KeyframeReached("Impact")` dispara `ApplyImpulse` + transfere a batata. | Interação central do gameplay. Animação curta e legível (braços lançados para frente). Sincroniza fisicamente com knockback do alvo — telegrafa quem está atacando. |
| 4 | **BatataSuaPanico** | `Action2` | 0.6-1s em loop curto | No momento em que o jogador recebe a batata (via evento `PotatoReceived`). Loopa até o jogador empurrar outro ou explodir. | Feedback instantâneo de que "é com você" — jogador treme, se agita. Emoção clara mesmo sem olhar na UI. Sobrepõe Idle mas não Movement, então o jogador tremedor consegue correr. |
| 5 | **ExplosaoDramatica** | `Action4` | 0.3-0.5s (antes do ragdoll) | Quando o timer da batata zera no portador. Toca por ~0.3s, depois `PlatformStand=true` e `Explosion` com `BlastPressure=0` + `ApplyImpulse` custom. | Antecipação cômica: olhos arregalados, braços pra cima, "oh não". Vende o momento da explosão antes do ragdoll começar. `Action4` garante que nada sobrescreve, nem um empurrão do último segundo. |

### Observações de design

- Todas em **R15** (preferido pelo Roblox em 2026 e único suportado pelo Body Capture nativo).
- Começar com 5 animações mantém o escopo enxuto; expandir depois com variações de dança (3-4 vitórias diferentes sorteadas), animações de spawn e taunts.
- Centralizar o IDs em um `ModuleScript` (`ReplicatedStorage/Config/AnimationIds.lua`) em vez de hardcode em cada script — facilita trocar durante iteração.
- Testar prioridades em pares: "EmpurrarBatata" (Action) vs "BatataSuaPanico" (Action2) — a de pânico ganha, então ao empurrar, o pânico some brevemente. É o comportamento desejado.

---

## Referências principais

- Roblox Creator Hub — Animation Editor: https://create.roblox.com/docs/animation/editor
- Roblox Creator Hub — Using Animations: https://create.roblox.com/docs/animation/using
- Roblox Creator Hub — Animation Capture: https://create.roblox.com/docs/animation/capture
- Roblox Creator Hub — AnimationPriority Enum: https://create.roblox.com/docs/en-us/reference/engine/enums/AnimationPriority.md
- Roblox Creator Hub — AnimationTrack: https://create.roblox.com/docs/en-us/reference/engine/classes/AnimationTrack
- Roblox Creator Hub — Emotes: https://create.roblox.com/docs/characters/emotes
- Rokoko Vision 3.0: https://www.rokoko.com/insights/introducing-rokoko-vision-3-0
- RoMixamo Plugin (DevForum): https://devforum.roblox.com/t/plugin-romixamo-use-mixamo-animations-in-roblox-easily-as-one-click-v500/3655115
- Avatar Creators podem vender emotes no Marketplace: https://devforum.roblox.com/t/avatar-creators-can-publish-and-sell-emotes-on-marketplace/3866987
