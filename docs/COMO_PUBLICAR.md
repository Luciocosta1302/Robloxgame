# Como publicar o jogo no Roblox — guia pra quem nunca fez isso

Guia de verdade do zero. Pode seguir linha por linha.

---

## O que precisa estar na sua cabeça antes

- O **código** (os arquivos `.luau` em `src/`) pode morar no seu PC e no
  GitHub. O **Roblox Studio** é só o editor visual que você usa pra testar
  e apertar o botão de publicar.
- O **Rojo** é uma ferramenta que sincroniza a pasta do projeto com o Studio
  em tempo real. Quando o Claude muda um arquivo aqui, o Studio enxerga em
  2 segundos.
- Publicar é de graça. Não tem plano obrigatório.

---

## Parte 1 — Montar o ambiente no seu PC (uma vez só)

### 1.1 Criar conta Roblox

- Vai em [roblox.com](https://www.roblox.com) e cria uma conta.
- Entra nas configurações → **Account Info → Verify my age / ID**. Precisa
  mostrar documento. Isso libera monetização, UGC e DevEx. **Faz isso cedo**,
  demora 1–2 dias pra sair.

### 1.2 Baixar Roblox Studio

- Entra em [create.roblox.com](https://create.roblox.com), loga, clica em
  "Open Studio". Ele baixa um instalador. Roda. Fim.
- Windows e Mac. Não tem Linux oficial (se você estiver no Linux, tem que
  usar Windows numa VM ou ir pelo Chromebook / nuvem).

### 1.3 Instalar o Rojo

- O jeito mais fácil é instalar o **Rokit**, que é um gerenciador que já
  pega Rojo e outras ferramentas de uma vez.
- No terminal:
  - **Mac**: `curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | sh`
  - **Windows PowerShell**: `irm https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.ps1 | iex`
  - Depois, dentro da pasta do projeto: `rokit install` (usa o `rokit.toml`,
    e já pega Rojo, Selene, StyLua).
  - Documentação de referência em `docs/pesquisa/skills.md` §3.
- Para confirmar: `rojo --version` deve imprimir um número.

### 1.4 Instalar o plugin do Rojo no Studio

- Abre o Studio → aba **Plugins → Manage Plugins → Marketplace**.
- Busca "Rojo". Instala o oficial (autor rojo-rbx).

### 1.5 Clonar este repositório

```
git clone https://github.com/Luciocosta1302/Robloxgame
cd Robloxgame
```

---

## Parte 2 — Rodar o jogo localmente

### 2.1 Começar o Rojo

Dentro da pasta do projeto, num terminal:

```
rojo serve
```

Deixa esse terminal aberto. Ele imprime algo como "Rojo server listening
on port 34872".

### 2.2 Abrir o Studio e conectar

- Abre o Roblox Studio.
- **File → New** → escolhe um template qualquer (o "Baseplate" vazio funciona).
- Na aba **Plugins** vai ter um ícone do Rojo. Clica.
- No painel do Rojo clica **Connect**.
- Em segundos, o painel esquerdo do Studio (chamado "Explorer") fica cheio
  das pastas do seu projeto. ReplicatedStorage.Shared, ServerScriptService.Server,
  etc. — a estrutura que tá no `default.project.json`.
- Aperta **F5** (ou o botão Play azul em cima). Você joga sozinho em modo de teste.

### 2.3 Testar multiplayer

- No Studio, aba **Test → Clients and Servers**. Escolhe **2 players**.
- Vai abrir 3 janelas: uma do servidor, duas de clientes. Dá pra testar
  a jogatina real com empurrão, passe de batata, etc.

---

## Parte 3 — Publicar o jogo pela primeira vez

### 3.1 Dar nome ao place

- No Studio, **File → Save As** → salva o arquivo `.rbxl` no seu PC pra ter
  backup. Chama de "batata-quente-v0.rbxl".
- Alternativamente, **File → Save to Roblox As…** já cria direto na nuvem,
  mas o save local é bom como seguro.

### 3.2 Publicar

- **File → Publish to Roblox As…**
- Vai abrir uma janela:
  - **Name**: Batata Quente Ragdoll (ou o título em inglês que a pesquisa
    recomenda em `docs/pesquisa/tendencias.md` §4)
  - **Description**: 2–3 linhas sobre o jogo. Em português e inglês fica legal.
  - **Genre**: All Genres funciona. Depois dá pra ajustar.
  - **Creator**: pode ser você (User) ou um grupo. Pra solo começa como User,
    depois migra pra grupo quando for colocar UGC/animação.
- Clica em **Create**. Ele faz upload e volta com um link. Esse link é o seu
  jogo no Roblox. Qualquer pessoa pode abrir pela aba Discover do Roblox
  depois que você deixar público.

### 3.3 Deixar público

Quando acabou de publicar, o jogo nasce em **modo privado** (só você joga).
Pra abrir pra todo mundo:

- Vai em [create.roblox.com](https://create.roblox.com/dashboard/creations)
- Clica no seu jogo → **Settings → Permissions**.
- Muda de **Private** para **Public**.
- Pronto, tá no ar.

---

## Parte 4 — Depois do primeiro upload

### 4.1 Atualizar o jogo

- Toda vez que você mudar código (ou o Claude mudar), com o Rojo conectado
  no Studio: salva no Studio e manda **File → Publish to Roblox**. Ele
  sobrescreve a versão atual. Jogadores pegam automaticamente na próxima
  vez que entrarem.
- O **Rojo** também tem um comando `rojo build` + `rojo upload` que publica
  direto do terminal, mas no começo é mais seguro passar pelo Studio pra ver
  que não quebrou nada.

### 4.2 Configurar monetização (Game Pass, Dev Product)

Siga o **Passo 1** de `docs/plano-monetizacao.md`. Resumo:

- No painel do seu jogo em [create.roblox.com](https://create.roblox.com):
  **Monetization → Passes → Create a Pass**.
- Depois **Developer Products → Create new**.
- Cada vez que cria um, copia o ID (aparece na URL ou no painel) e cola
  em `src/shared/Config.luau` nos campos `Config.GAME_PASSES.VIP` etc.
- Faz commit e publica de novo. Pronto, os botões de compra passam a funcionar.

### 4.3 Primeira campanha de anúncios (quando tiver retenção)

- [create.roblox.com → Promote → Ads Manager](https://create.roblox.com/dashboard)
- Cria uma campanha de **200 Robux** só pra medir CTR do seu ícone (dica
  §7 de `docs/pesquisa/licoes-lancamento-br.md`).
- Se o CTR for < 1 %, **troca o ícone** antes de gastar mais nada.
- **Nunca compre Robux com dinheiro pra anunciar seu próprio jogo** — usa
  Robux earned direto (dica §8).

---

## Parte 5 — Esse fluxo é mesmo o mais usado?

Sim. Esse padrão (editor externo + Rojo + Studio só pra testar/publicar) é o
que **todo estúdio profissional de Roblox usa**. Os indies solo também, por
causa do GitHub (versionamento, histórico, trabalhar em várias máquinas).
Fazer tudo "dentro do Studio" só é prático pra protótipos de 1 arquivo.

Tem uma alternativa onde a IA fica **dentro** do Studio (MCP), e aí ela edita
direto a cena enquanto você joga — isso é o estado-da-arte. Como ligar:
Studio → Assistant → ⋯ → **Manage MCP Servers → Enable Studio as MCP server**.
Depois o Claude Code (instalado no PC) vai detectar e usar.

Referências detalhadas em `docs/pesquisa/skills.md` (todas as ferramentas
e seus comandos).

---

## Parte 6 — Checklist pra publicar a versão "pré-lançamento"

Antes do primeiro **public**:

- [ ] Jogo abre sem erro no Output do Studio (testar com Play solo).
- [ ] Multiplayer com 2–4 jogadores funciona.
- [ ] Testou em celular (Device Emulator do Studio, qualquer Android fraco).
- [ ] Ícone 512×512 pronto (expressivo, ver `docs/pesquisa/tendencias.md`).
- [ ] 3 thumbnails prontos (gameplay com cara engraçada).
- [ ] Título em inglês (a busca do Roblox é maioria em inglês).
- [ ] Descrição em inglês + português, com link do TikTok.
- [ ] Game Pass VIP e Dash Duplo criados e IDs colados em `Config.luau`.
- [ ] Dev Products de moedas criados.
- [ ] Private Servers habilitados (25 R$/mês).
- [ ] Creator Rewards opt-in.
- [ ] Funil de retenção `onboarding_v1` criado no Analytics.

Pronto. Aperta Publish, abre pra Public, posta o primeiro clipe no TikTok
e começa a medir.

---

## FAQ rápida

**Preciso pagar pra publicar?** Não.

**Preciso ser maior de 18?** Não pra publicar. Sim na prática pra sacar (DevEx exige verificação de ID e o processo é mais tranquilo com 18+).

**Preciso ter Roblox Premium?** Não pra publicar. Só pra vender UGC de avatar.

**Posso programar no VS Code / IDE normal?** Pode, e é o recomendado. Instala a extensão "Luau Language Server" pra ter autocomplete.

**Dá pra fazer no celular?** Não dá pra programar/publicar jogo Roblox pelo celular. Precisa de PC com Windows ou Mac.

**Quanto tempo leva pra publicar?** Primeira publicação: 5 minutos. Updates depois: 30 segundos.

**Posso tirar o jogo do ar?** Sim, qualquer hora. Settings → Permissions → Private.

**O que acontece com Robux já gastos se eu tirar o jogo do ar?** Os jogadores não têm direito a reembolso automático. Tente nunca fazer isso depois que tiver gente gastando.

**O jogo pode ser banido?** Sim, se violar política do Roblox (violência extrema, conteúdo sexual, cópia descarada de IP, phishing, direcionar pra sair da plataforma). Detalhes em `docs/pesquisa/monetizacao.md` §11.
