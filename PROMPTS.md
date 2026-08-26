# Prompts do projeto — Garapuvu Kanban (app Flutter Scrum/Kanban)

> **Diário de prompts.** Este arquivo **cresce** com o projeto: a cada avanço,
> registre aqui o prompt enviado, o resultado e o próximo passo escolhido.
> O **Prompt 0** já foi executado; os demais entram na ordem em que forem rodados.

## Como conversar com a IA (para iniciantes)

Poucas regras deixam a conversa produtiva:

1. **Um objetivo por prompt.** Peça em **partes pequenas** — é mais fácil revisar
   e corrigir do que um "faça tudo".
2. **Peça os testes junto** de cada funcionalidade (a IA já faz isso, mas reforce).
3. **Deixe a IA fechar cada resposta** com: explicar em linguagem simples →
   documentar → propor 2–3 próximos passos. **Você escolhe** o próximo.
4. **Valide o que vê**: peça o screenshot / `flutter run` quando for algo visual.
5. **Não precisa repetir as regras**: a IA lê
   `instrucoes-do-projeto-garapuvu-kanban.md` (espelhado em
   `.github/copilot-instructions.md` e `CLAUDE.md`) e as segue automaticamente.
6. **Na dúvida, pergunte "por quê?"** — entender a decisão vale mais do que só
   receber o código.

---

## Prompt 0 — Setup ✅ executado

```
Inicie meu projeto baseado nos prompts de boas praticas para desenvolvimento web
do projeto ia-na-pratica.
```

**Resultado:** o modelo estado zero do ia-na-pratica (escrito para web) foi
**traduzido para Flutter** e preenchido com o tema Scrum/Kanban do Garapuvu.
Criados: `instrucoes-do-projeto-garapuvu-kanban.md` (a lei do projeto),
`.github/copilot-instructions.md`, `CLAUDE.md`, este `PROMPTS.md` com o roteiro
1 → 13, `GLOSSARIO.md`, `RESUMAO.md`, `README.md`, o scaffold do app
(`pubspec.yaml`, `lib/`, `test/`, `integration_test/`) e o ferramental de
qualidade (`analysis_options.yaml`, `Makefile`, `.githooks/pre-commit`,
`.gitignore`). Decisões: **Provider + ChangeNotifier**, **shared_preferences com
JSON**, **Material 3 + paleta Garapuvu**.

**Próximo passo:** Prompt 1 — fundamentação de Scrum/Kanban com fontes.

---

## Prompt 0.5 — comandos de build no Makefile ✅ executado

```
prepare no makefile o comando para
a) Buildar o app
b) Compilar ele local
c) Preparar build para deploy
d) Gerar versão IOS
e) Gerar versão Android
```

**Resultado:** o `Makefile` ganhou os comandos de build — `build` (a, todas as
plataformas), `build-local` (b, debug, com `PLATAFORMA=web|android|ios`),
`build-deploy` (c, roda `make check`, limpa e gera AAB + IPA + web),
`build-ios`/`build-ipa` (d) e `build-android` (e), mais `build-web`,
`artefatos`, `doctor` e `ajuda`. Cada comando tem guarda com recado em português
quando falta a pasta de plataforma, o macOS ou a assinatura — nada de erro
cifrado. Nenhum código Dart foi tocado: 9 testes continuam verdes.
**Próximo passo:** a decidir entre os três propostos no fim da resposta.

---

## Prompt 0.6 — pré-requisitos, rodar o app e fechar o Android ✅ executado

```
Verifique se está tudo certo com os prequisitos para rodar o app e rode ele
```

**Resultado:** faltavam as **pastas de plataforma** — o repositório tinha todo o
código Dart, mas não `android/`, `ios/` e `web/`. Rodado `make bootstrap` (que as
gera sem sobrescrever código), instaladas as 51 dependências e o app foi aberto
no navegador via `flutter run -d web-server --web-port=8080`: **zero erro de
console**, layout íntegro em desktop e em 390 dp. Prints em `docs/screenshots/`.

Em seguida, a pendência do Android: instalado o `cmdline-tools` 21.0 no SDK e
aceitas as licenças — mas o `flutter doctor` **verde não bastou**: o build de APK
quebrou no `JdkImageTransform`, porque **AGP 8.1.0 + Gradle 8.3 não suportam o
JDK 21** (o único da máquina era o bundle do Android Studio). Instalado o
**JDK 17** via Homebrew e apontado com `flutter config --jdk-dir`, sem tocar em
nenhum arquivo do projeto. Resultado: **APK release 19,8 MB + AAB 19,9 MB**
gerados com sucesso. 9 testes continuam verdes.

**Lição registrada:** `flutter doctor` atesta o *ambiente*, não a *compilação*.
Só `make build-local PLATAFORMA=android` prova que o Android funciona.

**Próximo passo:** Prompt 1 — fundamentação.

---

## Prompt 1 — Fundamentação: de onde vem Scrum e Kanban ✅ executado

```
Rode o Prompt 1 do roteiro: a FUNDAMENTAÇÃO. Pesquise na internet as referências
primárias sobre Scrum e sobre Kanban (Scrum Guide oficial, o material original de
Kanban do David Anderson, e o que houver sobre limite de WIP e Lei de Little
aplicados a times pequenos). Escolha as mais sólidas, escreva a seção FUNDAMENTAÇÃO
no arquivo de instruções com o LINK de cada fonte, e explique em português simples
por que um time voluntário pequeno como o Garapuvu se beneficia do par Scrum+Kanban.
Registre todos os termos novos no GLOSSARIO.md. Não escreva código ainda.
```

**Resultado:** §2 do arquivo de instruções deixou de ser "a preencher" e virou
uma fundamentação com **6 subseções** e **8 fontes primárias**, todas com link
testado (HTTP conferido em 26/08/2026):

| Fonte | Papel |
| --- | --- |
| *The Scrum Guide* 2020 (Schwaber & Sutherland) — inclusive o PDF **em português** | define Scrum, sprint, artefatos, empirismo |
| Guia oficial do **Método Kanban** (Kanban University / David J. Anderson) | princípios + as 6 práticas gerais |
| Livro *Kanban* (Anderson, 2010, ISBN 978-0-9845214-0-1) | fonte original do método |
| **Kanban Guide** (Vacanti & Coleman, ProKanban) | as 4 métricas de fluxo, citadas literalmente |
| **Little (1961)**, *Operations Research* 9(3):383–387, DOI `10.1287/opre.9.3.383` | o teorema original |
| Whitepaper *Little's Law for Professional Scrum with Kanban* (Vacanti, Scrum.org) | a lei aplicada a Kanban |

O ponto alto é **§2.3**, que responde "por que 3?": a Lei de Little
(`tempo de ciclo = WIP ÷ vazão`) mostra que segurar 9 tarefas em vez de 3 triplica
o tempo de cada uma **sem ninguém ficar mais lento**. E **§2.5** é uma tabela de
rastreabilidade que liga cada regra de negócio à sua fonte — assumindo
explicitamente que as regras 7 e 8 (confirmação e dados locais) **não** vêm do
método, e sim de usabilidade e LGPD. Inventar fonte seria pior do que não ter.

`GLOSSARIO.md` teve a seção de método reescrita: de 9 para **30 termos**,
agrupados em *os dois métodos*, *as peças do quadro*, *fluxo e as contas* e *como
o time se organiza*. Nenhuma linha de código foi escrita, como o prompt pedia.

**Próximo passo:** Prompt 2 — o núcleo da lógica em Dart puro, com testes.

---

## Equivalências web → Flutter (por que o roteiro mudou de ferramenta)

O roteiro original do ia-na-pratica é web. Este projeto é Flutter. As **regras**
são as mesmas; as **ferramentas** mudam:

| Template web (ia-na-pratica) | Aqui (Flutter) |
| --- | --- |
| `package.json` + scripts npm | `pubspec.yaml` + `Makefile` |
| ESLint | `flutter analyze` + `flutter_lints` |
| Prettier | `dart format` |
| Husky (pre-commit) | Git hook em `.githooks/pre-commit` |
| `localStorage` | `shared_preferences` guardando JSON |
| Teste de DOM (jsdom) | **widget test** (`flutter_test`) |
| Playwright (E2E) | **`integration_test`** |
| CSS Flexbox/Grid | `Row`/`Column`/`Flex`/`Wrap`/`GridView` |
| Rodapé de contraste em CSS/JS | Painel de contraste calculado em Dart |
| `.eslintignore` / `.prettierignore` | `analysis_options.yaml` (`analyzer: exclude:`) |

---

## Como registrar cada prompt (convenção)

A cada avanço, adicione um bloco assim (o mais recente por último):

```
## Prompt N — [título curto do que foi pedido] ✅ executado

​```
[o texto exato do prompt que você enviou]
​```

**Resultado:** [o que a IA entregou, em 2–4 linhas: arquivos, decisões, testes].
**Próximo passo:** [a opção escolhida entre as que a IA propôs].
```

---

# Roteiro previsto de prompts (mapa do caminho)

> **É guia, não trilho.** A ordem pode mudar conforme as suas escolhas — a IA
> sempre fecha cada resposta com 2–3 próximos passos e **você decide**. Vale
> sempre "um objetivo por prompt, com testes junto".
>
> **Todo prompt que altera código termina rodando `make check` e reportando o
> placar.** Os que mexem em **interface** (3, 5, 6, 7, 8, 9) **além disso** geram
> o **screenshot** — print e placar vêm juntos.

---

### Prompt 1 — Fundamentação: de onde vem Scrum e Kanban

**[Objetivo]** O projeto passa a ter uma base teórica documentada com fontes, antes
de existir qualquer linha de código de domínio.

```
Rode o Prompt 1 do roteiro: a FUNDAMENTAÇÃO. Pesquise na internet as referências
primárias sobre Scrum e sobre Kanban (Scrum Guide oficial, o material original de
Kanban do David Anderson, e o que houver sobre limite de WIP e Lei de Little
aplicados a times pequenos). Escolha as mais sólidas, escreva a seção FUNDAMENTAÇÃO
no arquivo de instruções com o LINK de cada fonte, e explique em português simples
por que um time voluntário pequeno como o Garapuvu se beneficia do par Scrum+Kanban.
Registre todos os termos novos no GLOSSARIO.md. Não escreva código ainda.
```

**[Entrega]** Seção FUNDAMENTAÇÃO preenchida com links verificáveis + `GLOSSARIO.md`
com os termos de Scrum/Kanban. Nenhum código.

---

### Prompt 2 — Núcleo da lógica em Dart puro + testes

**[Objetivo]** As regras do quadro existem como código testável, sem nenhuma tela.

```
Rode o Prompt 2: o núcleo da lógica. Em Dart puro (sem importar Flutter), crie os
modelos imutáveis Tarefa, Status, Prioridade e Sprint em lib/src/features/board/model/,
e as funções puras do quadro em lib/src/features/board/model/regras_quadro.dart:
avancarStatus, voltarStatus, ordenarPorPrioridade, podeEntrarEmFazendo (limite de
WIP de 3 por pessoa) e validarTitulo (3 a 80 caracteres). Escreva os testes
unitários em test/unit/ cobrindo os casos de borda: primeira e última coluna,
empate de prioridade, WIP no limite e estourado, título vazio/curto/longo.
```

**[Entrega]** `model/` completo + `regras_quadro.dart` + testes unitários verdes.
Sem UI.

---

### Prompt 2.5 — Ferramental de qualidade de código (rode cedo)

**[Objetivo]** O padrão de código passa a ser garantido por máquina, valendo para
todas as etapas seguintes. *(Já veio pronto no Prompt 0 — use este prompt para
conferir e endurecer as regras.)*

```
Revise o ferramental de qualidade deste projeto. Confirme que o Makefile tem
lint (flutter analyze), format (dart format), prepare (flutter pub get + ativar o
hook) e check (os três juntos). Endureça o analysis_options.yaml com as regras
estritas de Dart (strict-casts, strict-raw-types, prefer_final_locals,
public_member_api_docs, always_declare_return_types) e confirme que o hook de
pre-commit em .githooks/pre-commit roda format + analyze + test antes de CADA
commit, em QUALQUER branch. Ao final rode make check e me diga o placar.
```

**[Entrega]** `analysis_options.yaml` estrito, `Makefile`, hook ativo e placar
verde.

---

### Prompt 3 — Primeira tela: cadastrar tarefa + design tokens + contraste

**[Objetivo]** Existe uma tela real, com a identidade visual do projeto e o
contraste provado por código.

```
Rode o Prompt 3: a primeira tela. Crie os design tokens em lib/src/core/theme/
derivados da inspiração visual do projeto (Material 3 com paleta do Garapuvu:
verde de Mata Atlântica com acento de madeira), sem nenhuma cor solta dentro de
widget. Monte a tela de cadastro de tarefa (título, responsável, prioridade,
estimativa) usando Column/Wrap, com validação, Semantics em português em cada
campo e alvo de toque de 48x48 dp. Adicione o painel de contraste ao vivo que
calcula a razão de cada par de cores do tema e mostra PASSA/FALHA AA. Escreva os
widget tests em 320, 390 e 768 dp (zero overflow) e o teste de espaçamento
(folga > 0,5 dp). Gere o screenshot.
```

**[Entrega]** `theme/` com tokens, tela de cadastro, painel de contraste, widget
tests nos 3 tamanhos, teste de espaçamento, screenshot em `docs/screenshots/`.

---

### Prompt 4 — Persistência com shared_preferences (sem tela)

**[Objetivo]** As tarefas sobrevivem ao fechar o app.

```
Rode o Prompt 4: a persistência. Crie em lib/src/data/ um repositório que serializa
a lista de tarefas para JSON e grava no shared_preferences, com toJson/fromJson nos
modelos e tratamento de dado corrompido (se o JSON não for válido, começar vazio e
avisar, nunca crashar). Ligue o QuadroController (ChangeNotifier) ao repositório.
Teste com um shared_preferences em memória (mock), cobrindo salvar, carregar, dado
ausente e dado corrompido.
```

**[Entrega]** Repositório + `QuadroController` + testes de persistência. Sem tela
nova — mas com placar.

---

### Prompt 5 — Lista organizada por prioridade

**[Objetivo]** A tela mostra as tarefas na ordem certa e nunca deixa o usuário no
vazio.

```
Rode o Prompt 5: a lista. Monte a tela que mostra as tarefas ordenadas por
prioridade (empate desempata por data de criação), com o chip de prioridade
colorido e legendado por texto — cor nunca é a única informação. Inclua o estado
vazio explicando o que fazer e com o botão de criar a primeira tarefa. Widget
tests nos 3 tamanhos + teste de espaçamento + screenshot.
```

**[Entrega]** Tela de lista, estado vazio, testes e screenshot.

---

### Prompt 6 — O quadro Kanban: avançar e voltar status

**[Objetivo]** O card caminha pelas colunas — o coração do app.

```
Rode o Prompt 6: o quadro. Monte a tela de colunas (A fazer / Fazendo / Em revisão
/ Concluído) com rolagem horizontal, e os botões de avançar e voltar em cada card
(com Semantics dizendo para qual coluna vai). Aplique o limite de WIP: ao estourar,
mostrar mensagem que explica o porquê e oferece o que fazer, sem bloquear em
silêncio. Widget tests do ciclo completo ida e volta + 3 tamanhos + espaçamento +
screenshot.
```

**[Entrega]** Tela do quadro, ciclo de status na UI, aviso de WIP, testes e
screenshot.

---

### Prompt 7 — Dashboard com indicadores da sprint

**[Objetivo]** O time enxerga como a sprint está indo.

```
Rode o Prompt 7: o dashboard. Mostre os indicadores da sprint: total de tarefas
por coluna, percentual concluído, quantas estão acima do limite de WIP e a
distribuição por responsável. Use GridView/Wrap para não quebrar em tela pequena,
e escreva cada número também em texto (acessibilidade). Widget tests nos 3
tamanhos + espaçamento + screenshot.
```

**[Entrega]** Tela de dashboard, cálculo dos indicadores em funções puras
testadas, testes e screenshot.

---

### Prompt 8 — Filtros e preferências persistidos

**[Objetivo]** O app lembra como cada pessoa gosta de ver o quadro.

```
Rode o Prompt 8: os filtros. Adicione filtro por responsável, por prioridade e por
sprint, e salve a escolha no shared_preferences para o app reabrir do jeito que
ficou. Mostre sempre, em texto, quais filtros estão ativos e um botão de limpar
filtros. Widget tests + teste de persistência do filtro + screenshot.
```

**[Entrega]** Filtros funcionando e persistidos, indicador de filtro ativo, testes
e screenshot.

---

### Prompt 9 — Ações destrutivas com confirmação + Reiniciar experiência

**[Objetivo]** Nada some por acidente.

```
Rode o Prompt 9: as ações destrutivas. Excluir tarefa, limpar coluna e "Reiniciar
experiência" passam a pedir confirmação em diálogo que diz o NOME do que será
apagado e quantos itens. Adicione desfazer (SnackBar) na exclusão de tarefa.
Widget tests cobrindo confirmar, cancelar e desfazer + screenshot.
```

**[Entrega]** Diálogos de confirmação, desfazer, testes e screenshot.

---

### Prompt 10 — Exportar e apagar meus dados (LGPD)

**[Objetivo]** A pessoa dona dos dados manda neles.

```
Rode o Prompt 10: LGPD. Adicione "exportar meus dados" gerando um JSON legível e
"apagar tudo" com confirmação. Escreva na tela, em português claro, que os dados
ficam só no aparelho e nunca são enviados para servidor nenhum. Garanta que todos
os exemplos e testes usam nomes fictícios. Testes do export (formato e conteúdo) e
do apagar.
```

**[Entrega]** Export/apagar, aviso de privacidade na tela, testes verdes.

---

### Prompt 11 — Acessibilidade WCAG AA + testes ponta a ponta

**[Objetivo]** O app é usável por todo mundo, e isso é provado por teste.

```
Rode o Prompt 11: acessibilidade e E2E. Passe o app inteiro pelo
meetsGuideline do flutter_test (textContrastGuideline, androidTapTargetGuideline,
labeledTapTargetGuideline) e conserte o que falhar. Verifique que tudo funciona com
textScaler em 200%. Depois escreva o teste ponta a ponta em integration_test/
cobrindo o fluxo completo: criar tarefa → avançar até Concluído → filtrar → ver o
dashboard → reabrir o app e confirmar que persistiu. Reporte o placar dos dois.
```

**[Entrega]** Guidelines de acessibilidade passando, fonte 200% sem quebra, suíte
`integration_test` verde.

---

### Prompt 12 — Entregas finais: README e slides

**[Objetivo]** Alguém de fora consegue rodar, entender e apresentar o projeto.

```
Rode o Prompt 12: as entregas finais. Atualize o README.md com o passo a passo
para subir o repositório (git init → commit → flutter pub get → make prepare →
criar repo remoto → push) e para rodar o app. Depois monte os slides da
apresentação a partir deste PROMPTS.md e do RESUMAO.md: a CAPA abre com o TEMA e a
INSPIRAÇÃO visual, há um SLIDE DEDICADO à inspiração, um slide de qualidade de
código (analyze + format + pre-commit) e um slide de acessibilidade com o relatório
de contraste.
```

**[Entrega]** `README.md` completo + slides com capa tema/inspiração, slide de
inspiração, slide de qualidade e slide de acessibilidade.

---

### Prompt 13 — Plan Test: planejar os próximos testes

**[Objetivo]** Saber, em português, o que ainda não está coberto.

```
Rode o Prompt 13, o Plan Test: analise a suíte atual e escreva, em português, um
plano dos próximos testes unitários e de interface que faltam. Para cada um: o que
ele prova, por que importa, e o risco de não existir. Ordene por risco. Não
implemente ainda — só o plano, para eu escolher os 3 primeiros.
```

**[Entrega]** Plano de testes priorizado por risco, sem código.

---

## Status do roteiro

- [x] **Prompt 0** — setup do arquivo de instruções + este roteiro + scaffold + ferramental.
- [x] **Prompt 0.5** — comandos de build no `Makefile`.
- [x] **Prompt 0.6** — pré-requisitos, app rodando e toolchain Android fechada.
- [x] **Prompt 1** — fundamentação (Scrum/Kanban com fontes).
- [ ] **Prompt 2** — núcleo da lógica em Dart puro + testes.
- [x] **Prompt 2.5** — ferramental de qualidade *(entregue no Prompt 0; revisar quando existir código)*.
- [ ] **Prompt 3** — primeira tela + design tokens + contraste.
- [ ] **Prompt 4** — persistência (`shared_preferences`).
- [ ] **Prompt 5** — lista por prioridade.
- [ ] **Prompt 6** — quadro Kanban (avança/volta).
- [ ] **Prompt 7** — dashboard.
- [ ] **Prompt 8** — filtros persistidos.
- [ ] **Prompt 9** — ações destrutivas com confirmação.
- [ ] **Prompt 10** — exportar/apagar dados (LGPD).
- [ ] **Prompt 11** — acessibilidade WCAG AA + `integration_test`.
- [ ] **Prompt 12** — README + slides.
- [ ] **Prompt 13** — Plan Test.
