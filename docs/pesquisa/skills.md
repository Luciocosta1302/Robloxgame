# Skills, MCPs e ferramentas para desenvolver Roblox com IA

Pesquisa feita em 22/11/2026 para o projeto **Batata Quente Ragdoll** (Luau + Rojo).
Fontes priorizadas: 2025–2026. Cada afirmação tem link. Quando algo está parado ou
duvidoso, o texto diz claramente.

---

## 1. Skills, plugins e agentes do Claude Code para Roblox/Luau

O ecossistema oficial do Claude Code gira em torno do repositório
[`anthropics/skills`](https://github.com/gitlm/anthropics-skills), que é registrado
com `/plugin marketplace add anthropics/skills` e distribui dois pacotes principais:
`document-skills` (docx, pdf, pptx, xlsx) e `example-skills` (as demais) — segundo
o guia [allthings.how](https://allthings.how/claude-code-skills-on-github-how-to-find-install-and-build-them/).
**Nenhuma skill oficial da Anthropic é específica para Roblox** até agora.

Tudo o que existe para Roblox é comunidade. Os principais:

| Skill / plugin | O que faz | Vale a pena? |
|---|---|---|
| [`gamedev-skills/awesome-gamedev-agent-skills` → `roblox-luau`](https://skillselion.com/marketplace/afrxo/roblox-agent-skills) | A mais popular. Cobre estrutura cliente-servidor e trata RemoteEvent como não confiável até validar. Catálogos divergem: ~9,8k ou ~12,3k instalações. | Sim, é a mais madura. Instala com `npx skills add gamedev-skills/awesome-gamedev-agent-skills --skill roblox-luau`. |
| [`greedychipmunk/agent-skills` → `roblox-game-development`](https://claudemarketplaces.com/skills/greedychipmunk/agent-skills/roblox-game-development) | Scripting Luau sem trocar de contexto para a documentação. Reporta ~765 instalações. | Útil como complemento para quem é iniciante em Luau. |
| [`dig1t/skills` → `luau-best-practices`](https://claudemarketplaces.com/skills/dig1t/skills/luau-best-practices) | Clean-code, autoridade do servidor e gestão de memória. Visto pela primeira vez em junho/2026. | Boa como "revisor de código". |
| [`sentinelcore/roblox-skills`](https://claudemarketplaces.com/skills/sentinelcore/roblox-skills) | 6 skills: `roblox-gui`, `roblox-performance`, `roblox-animations`, `roblox-security`, `roblox-datastores`, `roblox-remote-events`. ~1,2k instalações. **Não é afiliado à Anthropic.** | Vale pela granularidade — só carrega o que precisa. |
| [`nonlooped/roblox-suite`](https://nonlooped.github.io/roblox-suite/) | 15 skills markdown cobrindo APIs atuais vs. depreciadas. Instala com `npx skills add nonlooped/roblox-suite`. | Útil para evitar APIs obsoletas (p. ex. `Humanoid:LoadAnimation` deprecated). |
| [`afrxo/roblox-agent-skills`](https://skillselion.com/marketplace/afrxo/roblox-agent-skills) | Plugin Claude Code com 4 skills: `luau-expert`, `roblox-dev`, `roblox-toolchain`, `roblox-ui`. Foco Rojo. | Interessante pelo foco Rojo, como esse projeto. |
| [`brockmartin/roblox-game-skill`](https://github.com/brockmartin/roblox-game-skill) | Skill com ~143 stars no GitHub. | Projeto pequeno; útil como exemplo de estrutura. |
| [`Quenty/NevermoreEngine` plugins](https://claudemarketplaces.com/plugins/quenty-nevermoreengine) | Plugins Claude Code para NevermoreEngine. ~605 stars. | Só se você usa Nevermore — não é o caso aqui. |

**Não encontrado:** não há repositório público verificável chamado `obinexus-claude`
nem `rokit-studio` com conteúdo relevante a Roblox — a busca só retornou
`rokit` em si (o gerenciador) e plugins não relacionados
([busca GitHub](https://github.com/roblox)). Se o usuário tinha um link específico
em mente, ele não está indexado.

**Sobre "superpowers":** o [Superpowers for Claude Code](https://www.mindstudio.ai/blog/what-is-superpowers-plugin-claude-code)
é um plugin MIT com 14–15 skills de fluxo (brainstorming, TDD, debugging, code review),
mas **nenhuma delas é específica de Luau/Roblox**. Serve para o processo, não
para o conteúdo Roblox.

**Skills do Roblox Assistant (lado deles):** existe também um sistema separado de
skills dentro do próprio Roblox Assistant, documentado em
[create.roblox.com/docs/assistant/skills](https://create.roblox.com/docs/assistant/skills).
São arquivos Markdown com frontmatter — prefixo `rbx-` é reservado para skills da
Roblox. **Importante:** o DevForum anuncia que
[qualquer cliente MCP conectado ao Studio pode usar essas skills](https://devforum.roblox.com/t/assistant-updates-introducing-creator-authored-skills/4728447),
inclusive Cursor e Claude Code.

---

## 2. MCP do Roblox Studio

### Oficial (recomendado): MCP embutido no Roblox Studio

- Página: [create.roblox.com/docs/studio/mcp](https://create.roblox.com/docs/studio/mcp).
- Hoje o servidor MCP **vem embutido no próprio Studio**. Como ligar: Studio →
  abre o **Assistant** → **…** → **Manage MCP Servers** → ligar
  **Enable Studio as MCP server**.
- Ferramentas expostas incluem `list_roblox_studios` (achar instance ID),
  `set_active_studio` (fixar qual Studio recebe os comandos) e `http_get` (buscar
  URLs permitidas da documentação Roblox), segundo a doc oficial.
- Clientes compatíveis listados: Claude Desktop, Claude Code, Cursor
  (via Devforum: [Studio MCP Server Updates and External LLM Support](https://devforum.roblox.com/t/studio-mcp-server-updates-and-external-llm-support-for-assistant/4415631)).

### Oficial antigo (parado): `Roblox/studio-rust-mcp-server`

- GitHub: [github.com/Roblox/studio-rust-mcp-server](https://github.com/Roblox/studio-rust-mcp-server).
- **Status: deprecated.** O próprio repo avisa que *"this MCP Server is no longer
  being actively developed"* e recomenda o MCP embutido no Studio.
  **Não instale esse.**

### Alternativas da comunidade (vale conhecer)

| Nome | Status | O que faz |
|---|---|---|
| [`Chrrxs/robloxstudio-mcp`](https://github.com/Chrrxs/robloxstudio-mcp) | **Mantido.** Fork oficial do `boshyxd/robloxstudio-mcp` após o original ser arquivado em 06/2026. | 24+ ferramentas para ler/editar scripts. Instala com `npx -y @chrrxs/robloxstudio-mcp@latest --auto-install-plugin`. |
| [`boshyxd/robloxstudio-mcp`](https://mcpservers.org/ko/servers/boshyxd/robloxstudio-mcp) | **Arquivado.** Base do Chrrxs. | Ver histórico. |
| [`drgost1/robloxstudio-mcp`](https://github.com/drgost1/robloxstudio-mcp) | Fork ativo. | 51 ferramentas para explorar, editar e automatizar jogos. |
| [RoBridge](https://devforum.roblox.com/t/robridge-is-free-%E2%80%94-local-studio-mcp-24-tools-no-pro-tier/4815258) | Local, MIT, grátis. | MCP local em 127.0.0.1:3737 com dashboard, 24 ferramentas. |
| [`el4cteo/rbx-studio-mcp`](https://mcpservers.org/servers/el4cteo/rbx-studio-mcp) | Open source. | Servidor MCP grátis para Studio. |
| [`kolvian/roblox-mcp-server`](https://github.com/kolvian/roblox-mcp-server) | Experimental. | Expõe `run_code` — executa Luau direto no Studio. Mais arriscado. |

**Observação:** um tópico da DevForum reporta que
[a Roblox já derrubou plugins de MCP de terceiros por conflito com o editor de scripts](https://devforum.roblox.com/t/v16-roblox-studio-mcp-server-speed-up-your-workflow-by-letting-ai-read-and-edit-your-scripts-directly/3707071).
Por isso: **para produção, o MCP embutido no Studio é o seguro.** Use terceiros
só se precisar de algo que o oficial não tem (p. ex. `run_code`).

### Recomendado para este projeto

**MCP embutido no Studio** (dentro do Assistant). É oficial, mantido, e
funciona com Claude Code via plugin oficial
[`Roblox/roblox-studio-agent-plugin`](https://github.com/Roblox) — no Claude Code
digite `/plugin` e adicione.

---

## 3. Ferramentas de linha de comando

### Rojo — sincroniza projeto filesystem ↔ Studio

- GitHub: [`rojo-rbx/rojo`](https://github.com/rojo-rbx/rojo). Docs: [rojo.space/docs/v7](https://rojo.space/docs/v7/getting-started/installation/).
- **Versão mais recente:** 7.7.0 (02/07/2026), conforme
  [mirror SourceForge](https://sourceforge.net/projects/rojo.mirror/files/v7.7.0/).
- Binários para Windows, macOS e Linux (x86_64 e aarch64), mais `Rojo.rbxm` (plugin do Studio).
- Comandos essenciais:
  - `rojo serve` — abre servidor local; conecte o plugin dentro do Studio.
  - `rojo build -o Place.rbxlx` — gera o place.
  - `rojo plugin install` — instala o plugin do Studio pela CLI.
- Compilar do fonte: `cargo install rojo --version 7.7.0` (precisa Rust 1.88+).

### Rokit — gerenciador de toolchain (sucessor de Aftman/Foreman)

- GitHub: [`rojo-rbx/rokit`](https://github.com/rojo-rbx/rokit). Versão mais nova vista: 1.1.0.
- Lê `aftman.toml` existente (basta renomear para `rokit.toml`), segundo [docs.rs/rokit](https://docs.rs/crate/rokit/1.1.0/source/README.md).
- O README diz literalmente: *"Aftman is maintained by a third party that is no
  longer interested in Roblox"* — por isso prefira Rokit.
- Instala tudo (Rojo, Selene, StyLua, Wally) via um único `rokit.toml`:
  ```toml
  [tools]
  rojo = "rojo-rbx/rojo@7.7.0"
  selene = "Kampfkarren/selene@0.30.1"
  stylua = "JohnnyMorganz/StyLua@2.5.2"
  wally = "UpliftGames/wally@0.3.2"
  ```
- Comandos: `rokit init`, `rokit add rojo-rbx/rojo`, `rokit install`, `rokit update`.

### Selene — linter Luau (sucessor do luacheck para Roblox)

- GitHub: [`Kampfkarren/selene`](https://github.com/Kampfkarren/selene). Docs: [kampfkarren.github.io/selene](https://kampfkarren.github.io/selene).
- Versão mais recente vista: **0.32.0** ([Chocolatey](https://community.chocolatey.org/packages/selene), 06/10/2026).
  Arch mostrava 0.30.1-1 e crates.io ainda em 0.28.0 — o Chocolatey parece mais atualizado.
- Suporta Luau (dialeto Roblox) via `std = "roblox"` em `selene.toml`.
- Comandos: `selene src/`, `selene --generate-roblox-std` (regenera a biblioteca padrão).

### StyLua — formatador Lua/Luau

- GitHub: [`JohnnyMorganz/StyLua`](https://github.com/JohnnyMorganz/StyLua).
- **Versão mais recente:** 2.5.2 ([docs.rs](https://docs.rs/crate/stylua/latest)).
- Para Luau use o feature flag: `cargo install stylua --features luau`.
- Opções de instalação:
  - `brew install stylua` (macOS/Linux via Homebrew).
  - `npx @johnnymorganz/stylua-bin --help` (sem instalar).
  - Binário direto dos [releases](https://github.com/JohnnyMorganz/StyLua/releases).
- Comando: `stylua src/ foo.lua bar.lua` — pode receber via stdin com `-`.
- Config vai em `stylua.toml` (configurar `syntax = "Luau"`).

### Wally — gerenciador de pacotes

- GitHub: [`UpliftGames/wally`](https://github.com/UpliftGames/wally). Versão estável: 0.3.2.
- Instala via Rokit/Aftman (`rokit add UpliftGames/wally`) ou `brew install wally`.
- Pede Rust 1.51+ se compilar do fonte: `cargo install --locked --path .`.
- Comando: `wally install` — cria pasta `Packages/` e `wally.lock` conforme
  [tutorial DevForum](https://devforum.roblox.com/t/how-to-use-wally/1555148).
- **Problema conhecido:** Wally gera "link modules" que quebram resolução de tipos
  — precisa rodar `wally-package-types` depois, segundo
  [post sobre Forest](https://devforum.roblox.com/t/forest-package-manager-the-modern-package-platform-for-roblox/4766024).
- Existe alternativa nova chamada **Forest**, mas é recente — fique com Wally para já.

### TestEZ / Jest-Lua — testes

- **TestEZ** ([`Roblox/TestEZ`](https://github.com/Roblox/TestEZ)): framework BDD
  da Roblox para Luau, inspirado em RSpec/Mocha. Roda dentro do Studio ou em Lemur (CI).
  Versão citada em guias: 0.4.1.
- **Jest-Lua** ([`jsdotlua/jest-lua`](https://github.com/jsdotlua/jest-lua)): port do
  Jest. Versão vista: 3.10.0 (JestGlobals, [migration guide](https://jsdotlua.github.io/jest-lua/testez-migration)).
- **Status confuso:** um [post DevForum de 2025](https://devforum.roblox.com/t/you-yes-you-need-more-tests/3622442)
  diz que a Roblox internamente abandonou TestEZ em favor do port deles de Jest.
  Um [guia 2026](https://www.oflight.co.jp/en/columns/testez-roblox-luau-unit-testing-setup-guide-2026)
  ainda chama TestEZ de "mantido pela Roblox". **Realidade:** o próprio README do
  Jest-Lua afirma que *"Roblox uses Jest Lua internally"*. Para projeto novo em
  2026, **prefira Jest-Lua**.

---

## 4. Ferramentas de IA do próprio Roblox

### Roblox Assistant (Studio) — **beta**

- Página: [devforum: Introducing Assistant in Studio](https://devforum.roblox.com/t/introducing-assistant-in-studio-beta/2725977).
- Ainda em beta em 2026. Habilita em **File → Beta Features → Assistant**.
- Pode modificar conteúdo do place, não só sugerir código ([Expanding Assistant to Modify Place Content](https://devforum.roblox.com/t/expanding-assistant-to-modify-place-content-beta/3107464)).
- **Limites:** há queixas de limite diário baixo
  ([Studio Assistant Limits and Reliability](https://devforum.roblox.com/t/studio-assistant-limits-and-reliability/4743968)).
  Nenhuma documentação oficial lista cotas, e não há tier Premium confirmado
  (apenas [pedido de feature](https://devforum.roblox.com/t/upgrade-roblox-studio-assistant-for-premium-members/3498910)).
- **Em 2026 a Roblox anunciou agentic Studio** ([newsroom](https://about.roblox.com/newsroom/2026/04/roblox-studio-going-agentic)) — o Assistant executa tarefas de várias etapas sozinho.

### Code Assist — **GA**

- Autocomplete de código Luau. Lançado em beta e depois
  [full release](https://devforum.roblox.com/t/code-assist-full-release-ai-powered-code-completion/2848978):
  *"creators have adopted about 300 million characters of code suggested by Code Assist"*.
- Alimentado por modelo próprio da Roblox.

### Cube 3D — geração de mesh por texto — **beta**

- Anunciado em [março/2025](https://corp.roblox.com/newsroom/2025/03/introducing-roblox-cube).
- 1,8B parâmetros, treinado em 1,5M de assets 3D. Open-source: [`Roblox/cube`](https://github.com/Roblox/cube).
- Dentro do Studio: no Assistant digite `/generate` + descrição.
- **Limitação:** vem **sem textura** — precisa gerar textura separado no Texture Generator.
- API em beta para experiências: [Cube 3D Generation Tools and APIs for Creators](https://devforum.roblox.com/t/beta-cube-3d-generation-tools-and-apis-for-creators/3558947).
- **Atualização 05/2026: [CubePart](https://about.roblox.com/newsroom/2026/05/cubepart-roblox-open-vocabulary-part-controllable-3d-generator)** — geração 3D controlável por partes, open-vocabulary.

### Texture Generator — **beta**

- [DevForum beta](https://devforum.roblox.com/t/texture-generator-beta/2880635).
- Gera textura para mesh via prompt natural.
- Lançado junto do Avatar Auto Setup em [GDC 2024](https://about.roblox.com/newsroom/2024/03/roblox-introduces-ai-powered-avatar-and-texturing-technologies-to-accelerate-3d-creation).
- **Limitação:** reviews dizem que a saída é "ponto de partida", não produto final.
- Nenhuma confirmação de GA.

### Material Generator — **beta**

- [DevForum beta](https://devforum.roblox.com/t/material-generator-beta/2224446). Gera materiais PBR via prompt.

### Avatar Auto Setup — **production release (GA)**

- Anunciado em [GDC 2024](https://about.roblox.com/newsroom/2024/03/roblox-introduces-ai-powered-avatar-and-texturing-technologies-to-accelerate-3d-creation).
- Rigging + skinning automáticos. Agora em [production release](https://devforum.roblox.com/t/avatar-auto-setup-production-release/3294214).
- Acesso: aba **Avatar** no Studio.

### Build (gerar jogos por IA) — **não liberado publicamente**

- Roblox anunciou intenção de deixar criar jogos inteiros por prompt. Até agora o
  produto mais próximo é o Assistant agentic citado acima. **Nada GA no front de
  "faça um jogo inteiro por IA".**

### Resumo de status

| Ferramenta | Status | Para que serve |
|---|---|---|
| Code Assist | **GA** | Autocomplete Luau |
| Avatar Auto Setup | **GA / Production** | Rig+skin automáticos |
| Roblox Assistant | **Beta** | Chat+modifica place |
| Cube 3D / Mesh Gen | **Beta** | Mesh por texto |
| Texture Generator | **Beta** | Textura por texto |
| Material Generator | **Beta** | Material PBR por texto |
| "Build an entire game by AI" | **Não liberado** | — |

---

## 5. Recomendação final para este projeto

### Conjunto mínimo

1. **Rojo 7.7.0** — já está no projeto (`default.project.json`).
2. **Rokit** — para instalar/pinar tudo no mesmo arquivo.
3. **Selene** — linter.
4. **StyLua** — formatador.
5. **MCP embutido do Studio** — para o Claude Code dar Play, ler Output e consertar.
6. **Skill `roblox-dev`** (abaixo) — regras do projeto para o Claude Code seguir.

Wally e Jest-Lua são opcionais — só entre quando precisar de pacote externo ou
testar algo que compense.

### Comandos exatos

**Linux (Ubuntu/Debian/Fedora):**
```bash
# 1. Rokit (gerenciador de tudo)
curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash
# abrir novo terminal pra PATH atualizar

# 2. Entre na pasta do projeto e peça pro Rokit instalar o resto
cd ~/Robloxgame
rokit init
rokit add rojo-rbx/rojo
rokit add Kampfkarren/selene
rokit add JohnnyMorganz/StyLua
rokit install
```
Fonte: [docs.rs/rokit](https://docs.rs/crate/rokit/0.2.4/source/README.md).

**macOS:**
```bash
# Opção A — via Homebrew (mais simples)
brew install rojo stylua selene wally

# Opção B — via Rokit (centraliza versões)
curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash
cd ~/Robloxgame
rokit init
rokit add rojo-rbx/rojo Kampfkarren/selene JohnnyMorganz/StyLua
rokit install
```
Fontes: [brew formula rojo](https://formulae.brew.sh/formula/rojo),
[brew formula stylua](https://formulae.brew.sh/formula/stylua),
[brew formula selene](https://formulae.brew.sh/formula/selene),
[brew formula wally](https://formulae.brew.sh/formula/wally).

**Windows (PowerShell):**
```powershell
# 1. Baixe rokit.exe do release mais recente e rode
# https://github.com/rojo-rbx/rokit/releases
.\rokit.exe self-install

# 2. Reinicie o terminal e:
cd C:\Robloxgame
rokit init
rokit add rojo-rbx/rojo Kampfkarren/selene JohnnyMorganz/StyLua
rokit install
```
Fonte: [docs.rs/rokit 0.2.4 README](https://docs.rs/crate/rokit/0.2.4/source/README.md).

**Instalar o plugin do Rojo dentro do Studio (qualquer SO):**
```bash
rojo plugin install
```

**Ligar o MCP do Studio (dentro do Studio):**
Abra **Assistant → … → Manage MCP Servers → Enable Studio as MCP server**.
([docs](https://create.roblox.com/docs/studio/mcp).)

**Conectar Claude Code ao Studio:**
No Claude Code: `/plugin` → adicione `Roblox/roblox-studio-agent-plugin`
([repo oficial](https://github.com/Roblox)).

### Rodar no dia a dia

```bash
# Sincronizar com Studio
rojo serve

# Rodar lint
selene src/

# Formatar
stylua src/
```

### Arquivos de config recomendados (criar no repo)

- `selene.toml`:
  ```toml
  std = "roblox+testez"
  ```
- `stylua.toml`:
  ```toml
  syntax = "Luau"
  indent_type = "Tabs"
  column_width = 100
  ```
- `rokit.toml` — gerado por `rokit init` + os `rokit add` acima.

---

## 6. Skill própria do projeto

Criada em `.claude/skills/roblox-dev/SKILL.md`. Resume as regras do `CLAUDE.md`
em formato de skill (frontmatter YAML + corpo Markdown) para o Claude Code
carregar automaticamente quando mexer em Luau neste projeto.

---

## Fontes principais

- [Rojo repo oficial](https://github.com/rojo-rbx/rojo) · [docs Rojo 7](https://rojo.space/docs/v7/getting-started/installation/) · [release 7.7.0](https://sourceforge.net/projects/rojo.mirror/files/v7.7.0/)
- [Rokit repo](https://github.com/rojo-rbx/rokit) · [README docs.rs](https://docs.rs/crate/rokit/0.2.4/source/README.md)
- [Selene docs](https://kampfkarren.github.io/selene) · [brew formula](https://formulae.brew.sh/formula/selene) · [Chocolatey](https://community.chocolatey.org/packages/selene)
- [StyLua docs.rs](https://docs.rs/crate/stylua/latest) · [repo](https://github.com/JohnnyMorganz/StyLua)
- [Wally brew](https://formulae.brew.sh/formula/wally) · [DevForum tutorial](https://devforum.roblox.com/t/how-to-use-wally/1555148)
- [TestEZ](https://github.com/Roblox/TestEZ) · [Jest-Lua](https://github.com/jsdotlua/jest-lua) · [migration](https://jsdotlua.github.io/jest-lua/testez-migration)
- [Roblox Studio MCP oficial](https://create.roblox.com/docs/studio/mcp) · [repo deprecated](https://github.com/Roblox/studio-rust-mcp-server) · [Chrrxs fork](https://github.com/Chrrxs/robloxstudio-mcp)
- [Assistant beta](https://devforum.roblox.com/t/introducing-assistant-in-studio-beta/2725977) · [Code Assist GA](https://devforum.roblox.com/t/code-assist-full-release-ai-powered-code-completion/2848978) · [Cube 3D](https://corp.roblox.com/newsroom/2025/03/introducing-roblox-cube) · [CubePart 2026](https://about.roblox.com/newsroom/2026/05/cubepart-roblox-open-vocabulary-part-controllable-3d-generator) · [Avatar Auto Setup production](https://devforum.roblox.com/t/avatar-auto-setup-production-release/3294214) · [Texture Generator beta](https://devforum.roblox.com/t/texture-generator-beta/2880635) · [Material Generator beta](https://devforum.roblox.com/t/material-generator-beta/2224446) · [Agentic Studio 2026](https://about.roblox.com/newsroom/2026/04/roblox-studio-going-agentic)
- [anthropics/skills marketplace](https://github.com/gitlm/anthropics-skills) · [guia allthings.how](https://allthings.how/claude-code-skills-on-github-how-to-find-install-and-build-them/)
- [sentinelcore/roblox-skills](https://claudemarketplaces.com/skills/sentinelcore/roblox-skills) · [nonlooped/roblox-suite](https://nonlooped.github.io/roblox-suite/) · [gamedev-skills/roblox-luau](https://skillselion.com/marketplace/afrxo/roblox-agent-skills) · [afrxo/roblox-agent-skills](https://skillselion.com/marketplace/afrxo/roblox-agent-skills) · [greedychipmunk/roblox-game-development](https://claudemarketplaces.com/skills/greedychipmunk/agent-skills/roblox-game-development) · [dig1t/luau-best-practices](https://claudemarketplaces.com/skills/dig1t/skills/luau-best-practices)
- [Assistant skills (Roblox)](https://create.roblox.com/docs/assistant/skills) · [Creator-Authored Skills](https://devforum.roblox.com/t/assistant-updates-introducing-creator-authored-skills/4728447)
