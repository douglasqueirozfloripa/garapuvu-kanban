# Glossário — Garapuvu Kanban

> Todo termo novo que aparecer no projeto entra aqui, explicado **em uma frase**,
> para alguém que nunca programou. Se você leu uma palavra no código ou na
> documentação e não entendeu, ela deveria estar nesta lista — se não estiver,
> peça para a IA acrescentar.

## Do método (Scrum e Kanban)

> As **fontes** de cada termo estão na seção **FUNDAMENTAÇÃO** (§2) do arquivo
> `instrucoes-do-projeto-garapuvu-kanban.md`, com link direto.

### Os dois métodos e seus documentos

- **Scrum** — jeito de organizar o time em ciclos curtos e repetidos (as
  sprints), com uma lista de prioridades e uma conversa rápida por dia. A
  definição oficial: *"framework leve que ajuda pessoas, times e organizações a
  gerar valor por meio de soluções adaptativas para problemas complexos"*.
- **Scrum Guide (Guia do Scrum)** — o documento de ~13 páginas que **define** o
  Scrum, escrito pelos criadores dele (Ken Schwaber e Jeff Sutherland). É de
  graça e tem versão em português.
- **Framework** — um conjunto mínimo de regras que dá a moldura, mas deixa o
  recheio por conta do time. Oposto de *receita de bolo*.
- **Kanban** — jeito de organizar trabalho em um quadro de colunas, onde cada
  tarefa é um cartão que caminha da esquerda para a direita até ficar pronta.
- **Método Kanban** — a formulação de David J. Anderson (livro de 2010), com
  princípios e seis práticas; é dela que vem o limite de WIP deste app.
- **Kanban Guide** — guia mais enxuto, de Daniel Vacanti e John Coleman, que
  define as quatro métricas de fluxo listadas abaixo.

### As peças do quadro

- **Card (cartão)** — uma tarefa representada no quadro.
- **Coluna / status** — em que ponto a tarefa está: `A fazer`, `Fazendo`,
  `Em revisão` ou `Concluído`.
- **Sprint** — período de tempo fixo (no Scrum, **de um mês ou menos**) dentro do
  qual o grupo se compromete com um conjunto de tarefas.
- **Backlog** — a fila de tarefas que ainda não entraram em nenhuma sprint.
- **Product Backlog** — a lista de tudo que o produto pode vir a ter, **ordenada
  por prioridade**. É o backlog "grande".
- **Sprint Backlog** — o pedaço do Product Backlog que o time puxou para a sprint
  atual.
- **Incremento (*Increment*)** — o resultado utilizável entregue ao fim de uma
  sprint. No Scrum, ele só conta se atender à Definição de Pronto.
- **Definição de Pronto (*Definition of Done*)** — a lista combinada do que
  precisa estar feito para alguém dizer "acabou". Neste projeto ela é literal:
  formatação, análise e testes verdes.
- **Prioridade** — o quanto a tarefa é urgente: `Alta`, `Média` ou `Baixa`.

### Fluxo, WIP e as contas

- **WIP (*work in progress*)** — *"o número de itens de trabalho começados mas
  não terminados"*. Em português: o que está no meio do caminho.
- **Limite de WIP** — teto de tarefas simultâneas (aqui, **3 por pessoa** na
  coluna `Fazendo`), para o time terminar coisas em vez de começar muitas.
- **Sistema puxado (*pull system*)** — o trabalho novo só entra **se houver
  capacidade**; ninguém empurra tarefa para cima de quem já está cheio.
- **Fluxo (*flow*)** — o movimento das tarefas da esquerda para a direita. "Bom
  fluxo" é tarefa que não fica parada, não que todo mundo esteja ocupado.
- **Throughput (vazão)** — *"o número de itens de trabalho terminados por unidade
  de tempo"*. Ex.: 2 tarefas por semana.
- **Cycle time (tempo de ciclo)** — *"o tempo decorrido entre quando um item
  começou e quando terminou"*.
- **Work item age (idade do item)** — *"o tempo decorrido entre quando um item
  começou e a data de hoje"*. Serve para achar tarefa esquecida no quadro.
- **Lei de Little** — teorema de fila (John D. C. Little, 1961) que, aplicado a
  Kanban, vira: **tempo de ciclo médio = WIP médio ÷ vazão média**. É a prova
  matemática de que segurar mais tarefas faz cada uma demorar mais.

### Como o time se organiza

- **Empirismo** — decidir com base no que se observa, não no que se planejou. No
  Scrum ele se apoia em três pilares:
  - **Transparência** — *"o trabalho deve estar visível para quem o faz"*; é o
    quadro na tela.
  - **Inspeção** — olhar com frequência para o que está acontecendo.
  - **Adaptação** — mudar o rumo quando a inspeção mostrar desvio.
- **Time auto-gerenciável** — o próprio time escolhe quem faz o quê e como; não
  há chefe distribuindo tarefa. É o caso do Garapuvu.
- **Políticas explícitas** — as regras do quadro ficam **escritas e visíveis**,
  não combinadas de boca. É por isso que o app *explica* o aviso de WIP em vez de
  só bloquear.
- **Papéis do Scrum** — *Product Owner* (cuida do valor e da ordem do backlog),
  *Scrum Master* (cuida de o método funcionar) e *Developers* (fazem o
  incremento). O Garapuvu **não** precisa criar esses cargos para usar o app.

## Do Flutter (a ferramenta)

- **Flutter** — kit da Google para escrever um app uma vez e rodá-lo no Android,
  no iPhone e no navegador.
- **Dart** — a linguagem de programação em que o Flutter é escrito.
- **Widget** — cada peça da tela (um botão, um texto, uma coluna inteira); no
  Flutter, *tudo* é widget.
- **`StatelessWidget`** — peça de tela que não muda sozinha: desenha e pronto.
- **`StatefulWidget`** — peça de tela que guarda um estado e se redesenha quando
  ele muda.
- **`ChangeNotifier`** — objeto que guarda dados e **avisa** quem estiver
  escutando quando eles mudam.
- **Provider** — biblioteca que entrega esse objeto para os widgets que precisam
  dele, sem passar de mão em mão pela árvore inteira.
- **`shared_preferences`** — cofrinho simples do aparelho para guardar dados
  pequenos; é o equivalente ao `localStorage` do navegador.
- **JSON** — formato de texto para representar dados estruturados; é como o
  quadro é guardado no cofrinho.
- **`MaterialApp`** — a casca do app: define tema, idioma e a tela inicial.
- **Material 3** — a linguagem visual padrão do Flutter (cores, sombras,
  espaçamentos), na versão mais recente.
- **`ColorScheme.fromSeed`** — receita que gera uma paleta inteira e harmônica a
  partir de **uma** cor semente.
- **dp** — *density-independent pixel*, a unidade de medida do Flutter: mede o
  tamanho **aparente** na tela, independente da densidade do aparelho.
- **`RenderFlex overflow`** — o erro (faixa listrada amarela e preta) que aparece
  quando o conteúdo não cabe na tela; neste projeto ele **reprova o teste**.
- **`Row` / `Column` / `Wrap` / `GridView`** — os jeitos de empilhar widgets em
  linha, em coluna, quebrando linha ou em grade — o equivalente ao Flexbox e ao
  Grid do CSS.
- **`Semantics`** — a etiqueta invisível que descreve um elemento para o leitor
  de tela de quem não enxerga.
- **`textScaler`** — o quanto a pessoa aumentou a fonte no sistema; o app precisa
  aguentar até 200%.

- **Pastas de plataforma** (`android/`, `ios/`, `web/`) — o "invólucro" que cada
  sistema exige para abrir o app. O código Dart é o mesmo para todos; essas
  pastas só contêm o projeto nativo que carrega esse código. São geradas **uma
  única vez** por `make bootstrap`.
- **`flutter doctor`** — o check-up do ambiente: lista o que já está instalado e
  o que falta (Android SDK, Xcode, navegador) antes de conseguir rodar.
- **`flutter devices`** — lista onde o app pode abrir agora: celular ligado,
  emulador, o próprio computador ou o navegador.
- **Dispositivo `web-server`** — modo em que o Flutter serve o app num endereço
  local (ex.: `http://127.0.0.1:8080`) em vez de abrir um navegador sozinho.
  Útil para conferir o app e tirar print de forma automatizada.
- **Hot reload / hot restart** — recarregar o app com o código novo **sem**
  fechá-lo: `r` aplica a mudança mantendo a tela onde está, `R` reinicia do zero.

## Dos testes e da qualidade

- **Teste unitário** — verifica uma regra isolada, sem tela (aqui, em
  `test/unit/`).
- **Widget test** — verifica uma tela ou componente montado de verdade, mas sem
  aparelho (em `test/widget/`).
- **Teste de integração (E2E)** — percorre o app inteiro como uma pessoa faria,
  em um aparelho ou emulador (em `integration_test/`); é o equivalente ao
  Playwright do template web.
- **Golden test** — teste que compara a tela com uma imagem de referência
  aprovada, pixel a pixel.
- **`flutter analyze`** — o revisor automático que aponta código suspeito; é o
  equivalente ao ESLint.
- **`dart format`** — o formatador oficial, que padroniza a aparência do código;
  é o equivalente ao Prettier.
- **Hook de pre-commit** — script que o Git roda **antes** de aceitar um commit;
  aqui ele bloqueia código mal formatado, com aviso do analisador ou com teste
  vermelho. É o equivalente ao Husky.
- **Placar dos testes** — o "X passaram, Y falharam" que toda resposta da IA
  precisa reportar.

## Da acessibilidade e da privacidade

- **WCAG AA** — nível intermediário do padrão internacional de acessibilidade da
  web, adotado aqui como piso.
- **Razão de contraste** — número que compara a luminosidade do texto com a do
  fundo; precisa ser **≥ 4,5:1** para texto normal e **≥ 3:1** para texto grande.
- **Alvo de toque** — a área clicável de um botão; o mínimo aqui é
  **48x48 dp**.
- **Leitor de tela** — programa que lê a tela em voz alta (TalkBack no Android,
  VoiceOver no iPhone).
- **LGPD** — Lei Geral de Proteção de Dados; no app se traduz em: só dados
  fictícios nos exemplos, e a pessoa pode exportar e apagar tudo.
- **Dados fictícios** — nomes inventados (`Ana Voluntária`, `Bruno Horta`,
  `Carla Mutirão`) usados em código, teste e print, para nunca expor pessoas
  reais do Garapuvu.

## Do build e da publicação

- **Build (ou "buildar")** — transformar o código em um arquivo pronto para
  instalar; é o que os comandos `make build-*` fazem.
- **Compilar** — a etapa dentro do build em que o código que a gente escreve
  vira código que o aparelho entende.
- **Modo debug** — build rápido, com ferramentas de desenvolvedor ligadas e
  *hot reload*; serve para desenvolver, **não** serve para loja.
- **Modo release** — build otimizado, sem ferramenta de desenvolvedor; é o que
  vai para o aparelho de quem usa.
- **Modo profile** — meio-termo: otimizado como o release, mas ainda permite
  medir desempenho.
- **APK** — o arquivo de app do Android que se instala direto no aparelho, sem
  passar por loja.
- **AAB (*Android App Bundle*)** — o formato que o **Google Play** exige hoje; a
  própria loja monta, a partir dele, o APK sob medida para cada celular.
- **IPA** — o arquivo de app do iPhone aceito pela **App Store**.
- **Assinatura (*code signing*)** — carimbo digital que prova quem publicou o
  app; sem ele a Apple e o Google recusam o envio.
- **`--no-codesign`** — opção que compila o app iOS **sem** o carimbo digital,
  só para conferir que ele compila.
- **Deploy (ou publicação)** — enviar o app pronto para as lojas ou para uma
  hospedagem.
- **`VERSAO` e `NUMERO`** — no `Makefile`, a versão que a pessoa vê (`0.2.0`) e o
  contador interno que as lojas exigem que cresça a cada envio (`8`). Sem eles,
  vale o que está no `pubspec.yaml`.
- **Gradle** — o montador de projetos do Android; é ele que roda por baixo do
  `flutter build apk`.
- **Xcode** — o programa da Apple que compila e assina apps de iPhone; só existe
  no macOS.
- **Simulador / emulador** — celular "de mentira" que roda no computador, para
  testar o app sem aparelho físico.
- **Hospedagem estática** — serviço que publica uma pasta de site pronta (o
  `build/web/`) sem precisar de servidor programado.
- **Artefato de build** — cada arquivo gerado pelo build (`.apk`, `.aab`,
  `.ipa`, pasta `build/web/`); `make artefatos` mostra quais já existem.
