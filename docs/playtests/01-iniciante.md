# Playtest 01 — Criança iniciante (8–10 anos)

## 1. Primeiros 60 segundos
"Entrei no jogo. Tem uma bola rolando? Uma batata? Tem um monte de botão colorido do lado. CHAMA é gritar? Tem um ROXO BRILHANTE que diz REBIRTH, vou clicar — ah, abriu umas letrinha, fechei. Aí me deu fome de moeda, o 🪙 tá em 0. Aperto a LOJA, tem umas coisa de cor, diz 'Trilha comum' e '🪙 50'. Eu tenho 0. Fecho. Começou a rodada, saiu uma coisa vermelha gritando A BATATA É SUA e eu nem sei o que apertar. Morri. Abriu VOCÊ EXPLODIU, REVIVER (R$) — R$?? É dinheiro real?? Fechei rápido! Ficou travado 20 segundos sem eu fazer nada. Chato."

## 2. Confusões
- **Sidebar com 7 botões empilhados** (LOJA/DIÁRIO/ADS/CHAMA/CÓDIGO/MISSÃO/REBIRTH). Muita opção, nada ensina o que cada um faz. (HUD.client.luau:118–165 + ReviveUI/Rebirth/Quests/Codes injetando extras)
- **"REBIRTH"** é palavra em inglês e abre texto denso que fala em "+25% permanente", "acumulativo", "moedas e vitórias VOLTAM A ZERO". Criança não lê, só vê botão rosa brilhante. (RebirthUI.client.luau:115–121)
- **"CHAMA"** com emoji 🤝 — pensa em fogo/skate, não em convidar amigo. O PromptGameInvite abre tela nativa sem explicação.
- **"CÓDIGO"** 🎟️ — texto "CÓDIGOS PROMOCIONAIS" é longo; a dica "@batatabomba" é em fonte cinza pequena, ninguém lê. (CodesUI.client.luau:111–121)
- **"Loja de Cosméticos"** — palavra "cosméticos" é adulta; raridade em português ("épico", "lendário") mistura com KIND em inglês interno. Cards mostram "TRAIL · COMUM" se faltar label — já tem KIND_LABEL mas depende do kind existir (ShopUI.client.luau:197).
- **Toast de "🥔 A BATATA É SUA! ENCOSTA EM ALGUÉM!"** é bom, mas "Q / botão = EMPURRA" fica num cantinho minúsculo (HUD.client.luau:89–96) — criança não liga Q com "empurrar batata".
- **Modificador de rodada** aparece em roxo sem legenda do que faz (HUD.client.luau:239–247).

## 3. Frustrações
- Morreu na 1ª rodada → fica **esperando a próxima** sem nada pra fazer. Supera os 30s de paciência.
- Daily diz "VOLTA DEPOIS" em cinza — sem mostrar timer grande e piscante (DailyUI.client.luau:141–145). Criança lê "chato".
- Rebirth travado: botão "Faltam N vitórias" com cor morta — frustrante porque é o botão mais chamativo da UI.

## 4. Risco de gasto acidental em Robux
- **ReviveUI** — botão GIGANTE vermelho "🔁 REVIVER (R$)" direto após morrer, com timer pressionando. Clique dispara `PromptProduct("REVIVE_ROUND")` sem confirmação extra do jogo. Texto não diz o preço nem avisa "dinheiro de verdade". (ReviveUI.client.luau:66–104) **Risco altíssimo.**
- **Portal VIP no lobby** — tocar no portal já dispara `promptPurchaseGamePass(player, "VIP")` sem modal de confirmação dentro do jogo. Criança corre sem querer e cai no popup do Roblox. (Main.server.luau:104–106)
- **Confusão 🪙 vs R$**: HUD usa 🪙 e a loja preços em moeda, mas o Revive mistura "R$" e botões no mesmo estilo visual de "PEGAR" do Daily — dá pra achar que é a moeda do jogo.

## 5. Recomendações objetivas
1. **ReviveUI.client.luau:75** — trocar "REVIVER (R$)" por "REVIVER (ROBUX de verdade)" + mostrar o preço real via `MarketplaceService:GetProductInfo`. Adicionar segundo clique de confirmação ("Tem certeza? Toca de novo") igual ao Rebirth (RebirthUI:141).
2. **Main.server.luau:88–107** — não disparar `promptPurchaseGamePass` no Touched do portal. Mostrar antes um balão no mundo ("Pise de novo pra ver a oferta") ou um modal interno com "Ver preço" / "Voltar".
3. **HUD.client.luau:134–165** — reduzir sidebar inicial a 2 botões (LOJA, DIÁRIO). Agrupar MISSÃO/CÓDIGO/CHAMA/REBIRTH num menu "➕ MAIS". REBIRTH só aparece depois da 1ª vitória.
4. **HUD.client.luau:89–96** — dica "Q / botão = EMPURRA" vira tutorial grande piscando nos 10 primeiros segundos da 1ª rodada do jogador.
5. **DailyUI.client.luau:141–145** — "VOLTA DEPOIS" fica como "🎁 volta em 02h 15m" colorido, não cinza morto.
6. **RebirthUI.client.luau:115–121** — substituir texto por 3 ícones: "ganha +25% 🪙 pra sempre / zera 🪙 / zera 🏆". Esconder botão da sidebar até ter 1 vitória.
7. **HUD.client.luau:161** — "🤝 CHAMA" → "👥 AMIGO" (ou "CONVIDAR"). "CÓDIGO" fica, mas colocar lupa 🔍.
8. **Pós-morte** — enquanto espera a próxima rodada, dar algo pra fazer (spectar, dica de controle, missão em andamento) em vez de modal de Robux travando a tela.

salvei o relatório em docs/playtests/01-iniciante.md
