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

## Prompt 0.8 — abrir os emuladores pelo Makefile ✅ executado

```
Prepare 2 comandos no make file para abrir o emular com ios e o outro para
abrir o emulador com android
+ pode instalar os emuladores no meu macos
```

**Resultado:** o `Makefile` ganhou `make emulador-android` e `make emulador-ios`.
Os dois **esperam o celular acabar de ligar** (consultando `flutter devices` a
cada 3 segundos, até `ESPERA=180`) antes de liberar o terminal — sem isso, o
`make run` na sequência falha só por pressa. Dá para escolher o aparelho:
`make emulador-android EMULADOR=Resizable_Experimental` ou
`make emulador-ios EMULADOR="iPhone 16"`.

**Sobre "instalar os emuladores":** não faltava nada para baixar. A máquina já
tinha Xcode 16.2 com iOS 18.3 (11 iPhones/iPads de simulador) e o SDK do Android
com a imagem `android-36`. O que faltava era um emulador Android **do projeto** —
só existia o genérico `Resizable_Experimental`. Criado o AVD
**`garapuvu_pixel_7`** (Pixel 7, Android 36 com Google Play, teclado do
computador ligado, para digitar título de tarefa sem catar letra na tela).
Sem `EMULADOR=`, os comandos preferem esse AVD.

**Lição registrada:** `flutter emulators --launch <id-que-nao-existe>` avisa que
não achou o emulador mas **termina com sucesso** (código 0). A primeira versão do
comando confiava nesse código e deixava a pessoa esperando 90 segundos por um
celular que nunca vinha — um beco sem saída. Agora o id é **conferido antes** de
tentar abrir, e o erro já lista os ids válidos.

Nenhum código Dart foi tocado: **89 testes** continuam verdes.

**Próximo passo:** a decidir entre os três propostos no fim da resposta.

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

## Prompt 0.7 — o primeiro commit ✅ executado

```
2   (fazer o primeiro commit)
```

**Resultado:** commit inicial `e86248d` — **100 arquivos, 4.406 linhas**, em
`main` (o repositório não tinha nenhum commit ainda e não tem remoto, então não
havia de onde ramificar).

Antes de commitar, o conteúdo foi auditado:

- **Nenhum caminho absoluto da máquina** vazou para o histórico. Os arquivos que
  contêm esses caminhos (`ios/Flutter/Generated.xcconfig`,
  `android/local.properties`, `.flutter-plugins-dependencies`) existem no disco
  mas ficaram **de fora**, barrados pelos `.gitignore` que o próprio Flutter cria
  dentro de `android/` e `ios/`.
- **Nenhum artefato de build** entrou: o APK e o AAB de 19 MB estão em `build/`,
  que o `.gitignore` já ignorava. O maior arquivo do commit tem 56 KB (um print).
- `pubspec.lock` **entrou** de propósito — em app (diferente de biblioteca), ele
  trava a versão exata das dependências para todo mundo do time.
- `.gitignore` ganhou uma linha: `.playwright-mcp/`, pasta temporária criada ao
  tirar os prints das telas.

O **hook de pre-commit funcionou de verdade**, rodando os três portões antes de
liberar: `dart format` (6 arquivos, 0 alterações) → `flutter analyze` (*No issues
found!*) → `flutter test` (**9 de 9**).

**Próximo passo:** Prompt 2 — o núcleo da lógica em Dart puro, com testes.

---

## Prompt 2 — Núcleo da lógica em Dart puro + testes ✅ executado

```
Rode o Prompt 2: o núcleo da lógica. Em Dart puro (sem importar Flutter), crie os
modelos imutáveis Tarefa, Status, Prioridade e Sprint em lib/src/features/board/model/,
e as funções puras do quadro em lib/src/features/board/model/regras_quadro.dart:
avancarStatus, voltarStatus, ordenarPorPrioridade, podeEntrarEmFazendo (limite de
WIP de 3 por pessoa) e validarTitulo (3 a 80 caracteres). Escreva os testes
unitários em test/unit/ cobrindo os casos de borda: primeira e última coluna,
empate de prioridade, WIP no limite e estourado, título vazio/curto/longo.
```

**Resultado:** 5 arquivos em `model/` (461 linhas) + 2 de teste, **nenhum deles
importando Flutter**. Placar: **45 testes verdes** (25 de regras + 11 de
modelos + 9 de tela que já existiam).

Decisões de projeto que valem registro:

| Decisão | Por quê |
| --- | --- |
| `avancarStatus` devolve `Status?`, e `null` na última coluna | Obriga a tela a decidir o que fazer no fim do quadro em vez de devolver a mesma coluna e fingir que algo aconteceu (regra 6.6) |
| `validarTitulo` devolve a **mensagem de erro**, não `true`/`false` | O erro precisa dizer o que houve e qual o próximo passo — e encaixa direto no `validator` de um formulário |
| `ordenarPorPrioridade` copia a lista antes de ordenar | `List.sort` altera o original; um canto do app mudaria a ordem de outro sem querer |
| Nome do responsável é normalizado (sem espaço extra, sem caixa) | Sem isso `'Ana'` e `'ana '` contariam como duas pessoas e o limite de WIP deixaria passar **o dobro** de tarefas |
| `motivoDoLimiteDeWip` mora junto da checagem | Regra 5.3 exige avisar **e explicar**; a prática 4 do Kanban exige política explícita. Espalhar a mensagem pelas telas convidaria a versões diferentes dela |

A ordem de declaração dos `enum` **é** a regra de negócio: `Status` declara as
colunas na ordem do quadro e `Prioridade`, da mais para a menos urgente. Um teste
trava isso, para ninguém reordenar sem perceber a consequência.

**Sobre a regra 6.1 (testes dos dois lados):** este prompt é explicitamente "sem
UI", então só existe o lado da lógica. O lado da tela nasce junto da tela, no
Prompt 3.

**Próximo passo:** Prompt 3 — primeira tela + design tokens + contraste.

---

## Prompt 3 — Primeira tela + design tokens + contraste ✅ executado

```
Rode o Prompt 3: a primeira tela. [...] Adicione o painel de contraste ao vivo
que calcula a razão de cada par de cores do tema e mostra PASSA/FALHA AA. [...]

+ (no meio do passo) https://projeto-garapuvu.web.app/
  Quero esse design token de cores, primarias, secundarias, etcc..
+ aproveite pegue o five icon e a imagem de background e faça um splashscreen
  do app na tela de inicio, e um mini loading do simbolizando o favi icon da
  flor do garapuvu
```

**Resultado:** placar **100 testes verdes**. Entregue: `app_cores.dart`,
`pares_de_contraste.dart`, `contraste.dart` (WCAG em Dart puro),
`flor_garapuvu.dart`, `indicador_flor.dart`, `tela_splash.dart`,
`tela_cadastro_tarefa.dart`, `tela_contraste.dart`, `seletor_prioridade.dart`,
`validacoes.dart` e 4 arquivos de teste. Prints em `docs/screenshots/`.

### A paleta parou de ser palpite

O pedido do site mudou o passo no meio: a §8 do arquivo de instruções dizia
"verde de mata com acento de madeira" — **chute feito antes de alguém olhar o
site**. O site expõe seus design tokens em CSS (`--gp-*`), e a identidade real é
**azul-noite + creme + o amarelo da flor do garapuvu**. A §8 foi corrigida com a
tabela de equivalência e o registro do erro.

### Três defeitos que só apareceram porque olhamos

| Como apareceu | O defeito | A correção |
| --- | --- | --- |
| **Screenshot** | As mensagens de erro vinham **cortadas** em "…" — um erro truncado não consegue dizer o próximo passo (regra 6.6). O `find.textContaining` passava, porque olha o widget e não o que a pessoa lê | `errorMaxLines: 4` no tema + o teste `textoFoiCortado`, que lê o `RenderParagraph` já desenhado. Provado: vermelho sem a correção, verde com ela |
| **Diretriz do `flutter_test`** | O botão de contorno usava o amarelo como **cor de texto** sobre o creme: **1,70:1**, ilegível | Âmbar escuro (`--gp-bloom-deep`) no claro, amarelo no escuro — e o par entrou no relatório, que não o conferia por não estar na lista |
| **Teste do splash** | `Future.delayed` cria um timer **impossível de cancelar**, que dispara em uma tela já morta | `Timer` guardado em campo e cancelado no `dispose` |

O segundo é o mais instrutivo: **o painel de contraste não pegou**. Ele só
confere os pares listados em `pares_de_contraste.dart`, e esse par não estava
lá. Painel e diretriz automática se cobrem — nenhum dos dois basta sozinho.

### Outras decisões

- A flor do favicon foi **redesenhada com `CustomPaint`** em vez de carregada
  como SVG: sem dependência nova, escala sem borrar e pode girar.
- O indicador de carregamento **para de girar** quando o sistema está com
  "reduzir movimento" ligado, e sempre anuncia a espera em texto.
- `pumpAndSettle` **trava** com animação que se repete. O suporte de teste ganhou
  `aguardarEstabilizar: false` para essas telas.
- O contador `0/80` dividia a linha com a mensagem de erro e a cortava ao meio na
  leitura ("...o que **0/80** precisa ser feito"). Escondido: o `maxLength` já
  impede passar de 80.
- O véu sobre a foto do splash é quase sólido na altura do texto: texto claro
  precisa de fundo escuro **garantido**, não de sorte com a foto.

**Contraste final: 13 de 13 pares em AA**, nos temas claro e escuro. O botão
principal (amarelo-flor sobre azul-noite) dá **9,08:1**.

**Próximo passo:** Prompt 4 — persistência com `shared_preferences`.

---

## Prompt 3.5 — rodar nos emuladores + `make rodar` / `make parar` ✅ executado

```
Antes de fazer o Prompt 4 (opção 2), preciso que vc execute o app para que o
emulador do android e ios que estao abertos, iniciarem o app
+ deixe um comando para eu encerrar via terminal a execucao do app nos 2
  emuladores, e ql comando para rodar novamente
```

**Resultado:** o app rodou nos dois emuladores (Android 16 / API 36 e iPhone 16
Pro / iOS 18.3), com prints tirados **de dentro** deles (`adb exec-out screencap`
e `xcrun simctl io screenshot`) — não da web. O `Wrap` se provou fora do teste:
no Android os dois botões couberam numa linha e no iPhone quebraram para duas,
sem estourar layout em nenhum.

Dois alvos novos no `Makefile`:

| Comando | O que faz |
| --- | --- |
| `make rodar` | Liga o app nos **dois** emuladores de uma vez, em segundo plano, com log em `build/logs/` |
| `make parar` | Fecha o app nos dois e encerra as sessões de execução; os emuladores continuam abertos |
| `make run APARELHO=android\|ios\|web\|mac` | Um aparelho por vez, em primeiro plano, **com hot reload** |

Decisões que valem registro:

- **`make run` puro pedia escolha.** Com 5 dispositivos conectados, `flutter run`
  abre um menu — o que trava execução automática. Daí o `APARELHO=`.
- **O `parar` não usa `pkill` genérico.** Um `pkill -f 'flutter run'` derrubaria
  sessões de **outros projetos** Flutter abertos na máquina. Ele fecha o app em
  cada emulador (o que já faz o `flutter run` daquele aparelho sair sozinho) e só
  então limpa sessões presas, filtrando pelo **id do aparelho**.
- **Os identificadores do app são diferentes** nas duas plataformas —
  `br.org.garapuvu.garapuvu_kanban` no Android e
  `br.org.garapuvu.garapuvuKanban` no iOS. Foi assim que o `flutter create`
  gerou; o Makefile guarda os dois em `ID_ANDROID` e `ID_IOS`.
- **O `adb` não está no PATH.** O Makefile o procura em `$ANDROID_HOME` e no
  caminho padrão do macOS antes de desistir.
- Rodar `make parar` com nada rodando **não é erro**: ele avisa e aponta o
  próximo comando (regra 6.6, nenhum beco sem saída).

### Achado: o app ainda se apresenta como "app Flutter"

Ao reiniciar no emulador Android, a primeira coisa na tela é **o logo do
Flutter** — o ícone do app ainda é o padrão do `flutter create`, e o Android 12+
usa o ícone na abertura nativa, antes de o nosso splash existir. No iOS o
`LaunchImage.png` também é o padrão. Não é regressão (nunca foi configurado),
mas contrasta com a marca aplicada no Prompt 3. O SVG da flor já está em
`assets/images/favicon-garapuvu.svg`.

Placar: **100 testes verdes** (nenhum código Dart foi alterado neste passo).

**Próximo passo:** Prompt 4 — persistência com `shared_preferences`.

---

## Prompt 3.6 — o ícone do app vira a flor do Garapuvu ✅ executado

```
2 e 4 nessa ordem   (opção 2 = trocar o ícone do app)
```

**Resultado:** o app deixou de se apresentar como "app Flutter". O achado do
Prompt 3.5 — o logo do Flutter aparecendo na abertura nativa do Android — está
resolvido: eram os ícones padrão que o `flutter create` gerou, em Android e iOS.

Novo script `scripts/gerar_icones.py` + alvo **`make icones`**. Ele **desenha** a
flor por código, com a mesma geometria do `favicon-garapuvu.svg` (cinco pétalas
giradas de 72°, miolo âmbar), e produz os ~25 tamanhos de uma vez.

| Decisão | Por quê |
| --- | --- |
| Desenhar por código, com Pillow | Refazer 25 tamanhos à mão a cada ajuste da marca seria trabalhoso e sujeito a erro. Mudou a cor em `app_cores.dart`? `make icones` e pronto |
| **Não** usar `flutter_launcher_icons` | Resolveria o mesmo problema, mas acrescentaria dependência e esconderia a conta. Aqui dá para ler o desenho — o projeto é didático |
| Ícone **adaptativo** no Android, não só o clássico | É o que o Android 8+ usa, e é dele que sai a tela de abertura do Android 12+ — exatamente onde o logo do Flutter aparecia |
| Flor a 55% no adaptativo (contra 92% no clássico) | A arte adaptativa tem 108 dp e o sistema mostra só os 72 dp do meio. A 92% as pétalas seriam **cortadas** |
| Camada `monochrome` | É o que o Android 13+ usa quando a pessoa liga ícones temáticos |
| iOS gravado sem canal alfa | O iOS **recusa** ícone com transparência e arredonda o canto sozinho — por isso o quadrado vai cheio, sem o arredondamento nosso |

O desenho gerado foi conferido contra o SVG oficial renderizado (`qlmanage`),
lado a lado: mesma forma, mesmas proporções. O gerador é **determinístico** —
rodar duas vezes produz arquivos byte a byte idênticos (conferido por `shasum`).

### De quebra: o nome do app

O ícone novo deixou visível outro resquício do `flutter create`: o Android
rotulava o app como **`garapuvu_kanban`** — snake_case, com sublinhado, na cara
de quem usa. Corrigido para `Garapuvu Kanban` no `AndroidManifest.xml`.

No iOS o `Info.plist` já trazia `CFBundleDisplayName = "Garapuvu Kanban"`, e o
registro do simulador (`xcrun simctl listapps`) confirma esse valor — mas a tela
de início desenhava `GarapuvuKanban`, sem espaço, mesmo após desinstalar e
reinstalar. É cache de rótulo do SpringBoard, não configuração do projeto: o
dado autoritativo está certo. Reiniciar o SpringBoard limpa, mas move o app para
outra página da tela de início.

**Próximo passo:** Prompt 4 — persistência com `shared_preferences`.

---

## Prompt 4 — Persistência com `shared_preferences` ✅ executado

```
Rode o Prompt 4: a persistência. Crie em lib/src/data/ um repositório que serializa
a lista de tarefas para JSON e grava no shared_preferences, com toJson/fromJson nos
modelos e tratamento de dado corrompido (se o JSON não for válido, começar vazio e
avisar, nunca crashar). Ligue o QuadroController (ChangeNotifier) ao repositório.
Teste com um shared_preferences em memória (mock), cobrindo salvar, carregar, dado
ausente e dado corrompido.
```

**Resultado:** as tarefas sobrevivem ao fechar o app. Placar: **156 testes
verdes** (56 novos). Provado no emulador Android: tarefa criada → processo do
app **morto** (PID 8929) → app reaberto (PID 9245) → a tarefa continua lá, lida
do disco e não da memória.

### Decisões de projeto

| Decisão | Por quê |
| --- | --- |
| Enums gravados por **nome** (`'fazendo'`), não por posição | A ordem de declaração **é** a regra de negócio e pode mudar. Com posição, mover `fazendo` na declaração faria toda tarefa gravada **mudar de coluna sozinha**. Tem teste travando isso |
| Datas em **ISO 8601** | Ordena igual à data que representa e não depende do idioma do aparelho — `26/08/2026` num celular em inglês vira 8 de fevereiro |
| Uma tarefa estragada **não** derruba as boas | Descartar 20 tarefas por causa de 1 quebrada seria pior que o próprio defeito. O aviso diz **quantas** se perderam |
| `status`/`prioridade` desconhecidos caem no padrão | Perder a tarefa inteira por causa de uma coluna com nome estranho seria pior que vê-la reaparecer em "A fazer" |
| Aviso viaja no **resultado**, não em `print` | Quem precisa saber é a **pessoa**, na tela — e a regra 6.6 exige que o erro diga o próximo passo |
| Chave versionada (`garapuvu.quadro.v1`) | Se o formato mudar, a versão nova lê a antiga e converte, sem atropelar quem não atualizou |
| O quadro inteiro em **um** JSON, não uma chave por tarefa | Salvar vira uma operação só: sem risco de meia gravação deixar o quadro pela metade |
| Voltar de `Fazendo` **nunca** é barrado pelo WIP | Tirar trabalho de cima de alguém não pode ser bloqueado. Mas voltar **para** `Fazendo` respeita o limite, senão ele teria porta dos fundos |

### Um defeito que o teste pegou

O `ChangeNotifierProvider` é **preguiçoso por padrão**: só cria o objeto quando
alguém o lê. Como nenhuma tela lia o quadro ainda, o `carregar()` **nunca
começava** — jogando fora a ideia de ler o aparelho em paralelo com a tela de
abertura. O teste `ao abrir, o app JA carrega o que estava guardado` falhou e
expôs isso; a correção é `lazy: false`.

### Coerência da interface

A tela inicial dizia, na cara da pessoa, que a tarefa "ainda nao e guardada:
isso entra no Prompt 4". Isso virou mentira — o cadastro agora grava de verdade,
e a tela ganhou uma linha dizendo **quantas tarefas estão guardadas** (a lista
completa é o Prompt 5) e um cartão de aviso com botão "Entendi" para os recados
do quadro.

**Próximo passo:** Prompt 5 — a lista ordenada por prioridade, com estado vazio.

---

## Conserto 4.1 — o build do Android voltou a funcionar ✅ executado

```
make rodar  ->  Error: Gradle task assembleDebug failed with exit code 1
A problem occurred configuring project ':shared_preferences_android'.
> Parameter specified as non-null is null: method
  com.flutter.gradle.VersionUtils.mostRecentSemanticVersion, parameter version1
```

**O que estava acontecendo:** havia **dois SDKs do Flutter** no computador, e o
projeto usava um em cada lugar.

| Onde | SDK que estava sendo usado |
| --- | --- |
| Terminal comum (`flutter --version`) | `~/flutter` — **3.24.5** |
| Terminal *de dentro do VS Code* | `.../DirtLockerApp2/lib/flutter` — **3.32.0** |
| Gradle (`android/local.properties`) | `.../DirtLockerApp2/lib/flutter` — **3.32.0** |

A extensão Dart do VS Code tinha, nas configurações globais do editor, um
`dart.flutterSdkPath` apontando para o SDK **de outro projeto**; ela coloca esse
SDK na frente do `PATH` do terminal integrado. Ou seja: `make rodar` rodado
dentro do VS Code chamava um Flutter diferente do que a mesma pessoa via ao
digitar `flutter --version` num terminal normal.

**Por que isso quebrou o build:** o Flutter 3.32 exige `Android Gradle Plugin`
**8.3 ou maior** (o próprio log avisava isso) e este projeto foi montado no
padrão do 3.24, com **AGP 8.1.0**. No AGP 8.1 um plugin que não declara
`ndkVersion` — o caso do `shared_preferences_android` — devolve `null`, e o
plugin Gradle do 3.32 (escrito em Kotlin) explode ao comparar essa versão. O
plugin Gradle do 3.24 é outro (Groovy) e não faz essa comparação.

**Sintoma extra:** o `flutter pub get` de cada SDK reescrevia o `pubspec.lock`
com resoluções diferentes (o `sky_engine` alternando entre `0.0.99` e `0.0.0`) —
por isso o arquivo vivia aparecendo como modificado no `git status`.

### O conserto

| Arquivo | Mudança |
| --- | --- |
| Configurações **globais** do VS Code | removido o `dart.flutterSdkPath` que apontava para o SDK do outro projeto — era ele a origem de tudo |
| `.vscode/settings.json` do **outro** projeto | criado, com `"dart.flutterSdkPath": "lib/flutter"` — cada projeto passa a declarar o SDK **dele** |
| `android/local.properties` | `flutter.sdk` apontando para `~/flutter` (é o arquivo que o Gradle lê; não vai para o git) |
| `pubspec.lock` | restaurado para a versão commitada e regerado com o 3.24.5 |

Nada foi mexido no código do app, nem no `AGP`, nem no `Gradle`. Um SDK só,
usado em todo lugar.

Este projeto **não** declara `dart.flutterSdkPath` nenhum: sem a configuração
global atrapalhando, a extensão Dart acha o Flutter pelo `PATH` sozinha. Isso
evita cravar um caminho de máquina (`/Users/fulano/...`) num repositório
público, que quebraria para qualquer outra pessoa que clonasse.

O caminho do outro projeto é **relativo** de propósito. A extensão Dart passa
esse ajuste por uma função (`resolvePaths`) que entende `~/` e caminho relativo
à pasta do projeto — então `lib/flutter` funciona em qualquer computador. Vale a
pena conferir esse tipo de detalhe antes de confiar nele: `${workspaceFolder}`,
por exemplo, **não** é resolvido nesse ajuste.

**Atenção:** a mudança do `PATH` do terminal do VS Code só vale em terminais
**abertos depois** — se o `make rodar` ainda falhar, feche a aba do terminal e
abra outra (ou recarregue a janela do VS Code).

**Resultado:** `flutter build apk --debug` verde, app instalado e rodando no
emulador Android. Placar: **156 testes verdes** (`make check` completo).

---

## Prompt 5 — Lista organizada por prioridade ✅ executado

```
Rode o Prompt 5: a lista. Monte a tela que mostra as tarefas ordenadas por
prioridade (empate desempata por data de criação), com o chip de prioridade
colorido e legendado por texto — cor nunca é a única informação. Inclua o estado
vazio explicando o que fazer e com o botão de criar a primeira tarefa. Widget
tests nos 3 tamanhos + teste de espaçamento + screenshot.
```

**Resultado:** a tela **Tarefas do time** mostra o quadro inteiro em uma lista
só, da mais urgente para a menos urgente. Placar: **185 testes verdes**
(29 novos). Prints em `docs/screenshots/p5-lista-por-prioridade.png` e
`p5-lista-estado-vazio.png`.

### Decisões de projeto

| Decisão | Por quê |
| --- | --- |
| A lista atravessa as **quatro colunas**, sem separar | A pergunta que ela responde é "o que é mais urgente agora?", e essa resposta não muda de acordo com a coluna. A visão por coluna é o quadro do Prompt 6 |
| Quem ordena é a **regra**, não a tela | `QuadroController.emOrdemDePrioridade` só repassa `ordenarPorPrioridade`. Se a tela ordenasse, a próxima tela ordenaria de outro jeito |
| A etiqueta de prioridade carrega **três** pistas | Texto ("Alta"), ícone com direção própria e cor. Tire a cor e ela continua legível — é exatamente o que o teste `a prioridade vem ESCRITA, e nao so em cor` exige |
| Vermelho → âmbar → verde, nessa ordem | É a leitura de semáforo que a maioria das pessoas já traz de fora do app |
| Responsável, coluna e estimativa ficam **sem cor de fundo** | Se tudo fosse colorido, a prioridade — que é o que ordena a lista — deixaria de saltar aos olhos |
| Cabeçalho **dentro** do `ListView` | Em 320 dp com fonte a 200% ele sozinho ocupa boa parte da tela; fora da lista, ficaria travado ocupando espaço |
| O fluxo "Nova tarefa" virou função (`abrirCadastroDeTarefa`) | Duas telas precisam dele. Duplicado, uma delas esqueceria de gravar ou de confirmar quando o código mudasse |
| O cartão **não tem botão** ainda | Mover a tarefa de coluna é o Prompt 6. Um cartão que parecesse tocável e não fizesse nada seria um beco (regra 6.6) |

### Dois defeitos que só o print pegou

1. **As cores da prioridade saíram invertidas.** "Média" nasceu verde e "Baixa"
   âmbar, porque `ColorScheme.fromSeed` deriva os `*Container` da cor-semente e
   **não** dos papéis `secondary`/`tertiary` que o tema fixa por cima. Os dois
   pares passavam no contraste, e nenhum teste reprovava — só o app rodando
   mostrou que a leitura ficava trocada.
2. **O leitor de tela lia tudo numa frase só.** Um `Semantics` com rótulo, mas
   sem `container: true`, se **funde** com os vizinhos: em vez de "prioridade
   alta", o leitor anunciava a etiqueta, o responsável e a coluna emendados.

### Um detalhe de teste

Para conferir o estado "lendo o aparelho" foi preciso um `_RepositorioTravado`
— um repositório cuja leitura só termina quando o teste manda. Com o
repositório de verdade, a leitura acaba **antes** de a tela ser montada, e o
estado nunca apareceria no teste.

**Próximo passo:** Prompt 6 — o quadro em colunas, com a tarefa avançando e
voltando de status.

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
- [x] **Prompt 0.7** — commit inicial (`e86248d`).
- [x] **Prompt 0.8** — `make emulador-android` / `make emulador-ios` + AVD `garapuvu_pixel_7`.
- [x] **Prompt 1** — fundamentação (Scrum/Kanban com fontes).
- [x] **Prompt 2** — núcleo da lógica em Dart puro + testes.
- [x] **Prompt 2.5** — ferramental de qualidade *(entregue no Prompt 0; revisar quando existir código)*.
- [x] **Prompt 3** — primeira tela + design tokens + contraste (+ splash e marca real).
- [x] **Prompt 3.5** — app rodando nos emuladores + `make rodar` / `make parar`.
- [x] **Prompt 3.6** — ícone do app (Android e iOS) com a flor do Garapuvu.
- [x] **Prompt 4** — persistência (`shared_preferences`).
- [x] **Conserto 4.1** — build do Android consertado (dois SDKs do Flutter brigando).
- [x] **Prompt 5** — lista por prioridade.
- [ ] **Prompt 6** — quadro Kanban (avança/volta).
- [ ] **Prompt 7** — dashboard.
- [ ] **Prompt 8** — filtros persistidos.
- [ ] **Prompt 9** — ações destrutivas com confirmação.
- [ ] **Prompt 10** — exportar/apagar dados (LGPD).
- [ ] **Prompt 11** — acessibilidade WCAG AA + `integration_test`.
- [ ] **Prompt 12** — README + slides.
- [ ] **Prompt 13** — Plan Test.
