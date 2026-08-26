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
- **Dart puro** — código que **não importa Flutter**. Roda sem tela e sem
  aparelho, então o teste dele é instantâneo. É onde vivem as regras do quadro.
- **Função pura** — função que, para a mesma entrada, sempre devolve a mesma
  saída, e **não muda nada fora dela**. Fácil de testar e de confiar.
- **`enum`** — lista fechada de opções com nome. `Status` e `Prioridade` são
  enums: não existe uma quinta coluna nem uma quarta prioridade por acidente.
- **Classe imutável** — objeto cujos campos nunca mudam depois de criado. Para
  "alterar", cria-se uma cópia. Evita que um canto do app mude o dado de outro
  sem querer.
- **`copyWith`** — o método que faz essa cópia trocando só os campos pedidos.
- **`final`** — marca um campo ou variável que recebe valor uma vez e nunca mais
  muda.
- **Tipo anulável (`Status?`)** — tipo que aceita `null`. Aqui o `null` tem
  significado de negócio: *"não dá para avançar, esta é a última coluna"*.
- **Igualdade de valor (`==` e `hashCode`)** — fazer dois objetos com os mesmos
  dados serem considerados iguais, em vez de comparados por endereço na memória.
- **Caso de borda** — a entrada no limite da regra, onde o erro costuma se
  esconder: a primeira e a última coluna, o título com exatamente 80
  caracteres, a terceira tarefa em `Fazendo`.
- **Design token** — uma decisão de visual guardada como **constante com nome**
  (`AppCores.flor`, `AppEspacos.md`) em vez de escrita solta no meio da tela.
  Trocar o token muda o app inteiro de uma vez.
- **`ColorScheme`** — o conjunto de papéis de cor do Material 3 (`primary`,
  `surface`, `error`…). Cada papel tem o seu par `onX`, que é a cor do texto que
  vai **em cima** dele.
- **Cor semente (*seed color*)** — a cor a partir da qual o Material 3 gera a
  paleta inteira, harmonizada.
- **CSS custom property (`--gp-bloom`)** — como um site guarda seus design
  tokens. Foi de lá que as cores do Garapuvu vieram, em vez de serem chutadas.
- **Razão de contraste** — o quanto um texto se destaca do fundo, de 1:1 (some)
  a 21:1 (preto no branco). O critério AA pede **4,5:1** para texto normal e
  **3:1** para texto grande, ícone e borda.
- **Luminância relativa** — o "quanto de luz" uma cor tem, de 0 a 1. Não é a
  média dos canais: o verde pesa dez vezes mais que o azul, porque o olho humano
  enxerga assim.
- **Ícone adaptativo (Android)** — ícone em duas camadas (fundo e frente) que o
  sistema recorta no formato que quiser: círculo, quadrado arredondado, gota.
  Por isso o desenho precisa de margem — o que fica na borda **some**.
- **Densidade de tela (mdpi, hdpi, xhdpi…)** — quantos pixels reais cabem em
  1 dp. É por isso que o mesmo ícone precisa existir em vários tamanhos.
- **Camada `monochrome`** — a versão de uma cor só do ícone, usada quando a
  pessoa liga "ícones temáticos" no Android 13+.
- **Canal alfa** — a informação de transparência de uma imagem. O ícone do iOS
  não pode ter: ele precisa ser um quadrado cheio.
- **Superamostragem (*supersampling*)** — desenhar ampliado e reduzir no fim.
  É o que deixa a borda lisa em vez de serrilhada.
- **Splash screen (tela de abertura)** — a primeira tela, que mostra a marca
  enquanto o app termina de abrir.
- **`CustomPaint`** — desenhar formas diretamente na tela (a flor do garapuvu é
  feita assim, sem imagem: ela escala sem borrar e pode girar).
- **`AnimationController`** — o "motor" de uma animação: conta de 0 a 1 no tempo
  que você definir, e o desenho acompanha.
- **Reduzir movimento** — ajuste do sistema para quem passa mal com animação. O
  app respeita: com ele ligado, a flor do carregamento para de girar.
- **Serializar / desserializar** — transformar um objeto em texto para guardar
  (e o contrário, para ler de volta).
- **ISO 8601** — o jeito internacional de escrever data e hora
  (`2026-08-26T09:00:00.000`). Ordena igual à data e não depende do idioma do
  aparelho — `26/08/2026` num celular em inglês seria lido como 8 de fevereiro.
- **Repositório** — a camada que sabe **onde** os dados ficam. As telas nunca
  falam com o disco: falam com ela.
- **Cofre do aparelho (`shared_preferences`)** — o espacinho onde o app guarda
  coisas pequenas no próprio celular. Nada sai dali.
- **Chave versionada (`...v1`)** — o nome sob o qual os dados são gravados, com
  número no fim. Se o formato mudar um dia, a versão nova lê a antiga e converte
  em vez de atropelar quem não atualizou.
- **Dado corrompido** — informação gravada que não dá mais para ler (arquivo
  truncado, editado na mão). O app precisa **avisar**, nunca quebrar.
- **`ChangeNotifier`** — objeto que guarda dados e **avisa** quem escuta quando
  eles mudam.
- **Provider** — quem entrega esse objeto às telas que precisam dele, sem passar
  de mão em mão pela árvore inteira.
- **Criação preguiçosa (*lazy*)** — quando algo só é criado no momento em que
  alguém pede. Útil para economizar, mas aqui atrapalhava: o quadro só começaria
  a ser lido quando alguma tela pedisse.
- **Mock** — uma peça de mentirinha que substitui a de verdade no teste. Aqui, um
  cofre do aparelho **em memória**: o teste roda em milissegundos e não deixa
  sujeira entre um caso e outro.
- **`validator`** — a função que um campo de formulário chama para saber se o
  que foi digitado presta; devolve a mensagem de erro ou `null`.
- **`Timer` cancelável** — contador de tempo guardado numa variável para poder
  ser desligado quando a tela morre. Sem isso ele dispara em uma tela que já
  não existe.
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

## Dos emuladores (o celular de mentira)

- **Emulador** — celular Android "de mentira" que roda numa janela do
  computador; serve para ver o app sem precisar de aparelho físico.
- **Simulador** — o mesmo, do lado do iPhone. A Apple chama de *simulador*
  porque ele reaproveita o próprio macOS em vez de imitar o hardware do celular
  — por isso abre bem mais rápido que o emulador do Android.
- **AVD (*Android Virtual Device*)** — a "receita" de um emulador salva no seu
  computador: qual aparelho imitar, qual versão do Android e quanta memória. O
  deste projeto se chama `garapuvu_pixel_7`.
- **Imagem do sistema (*system image*)** — o Android em si, baixado uma vez e
  reaproveitado por todos os AVDs; a nossa é a `android-36` com Google Play.
- **Cold boot** — a primeira vez que um emulador liga: ele precisa iniciar o
  Android do zero e pode levar alguns minutos. Nas vezes seguintes é rápido,
  porque ele volta de onde parou.
- **`make emulador-android` / `make emulador-ios`** — abrem o celular de mentira
  e **esperam** ele terminar de ligar, para o `make run` seguinte não falhar por
  pressa. Escolher outro aparelho: `make emulador-ios EMULADOR="iPhone 16"`.
- **`flutter devices`** — lista os aparelhos que o Flutter está vendo agora
  (emulador, simulador, navegador, o próprio Mac); é o que os comandos acima
  ficam consultando enquanto esperam.
- **`simctl`** — programa de linha de comando da Apple que liga e desliga
  simuladores (`xcrun simctl list devices available` mostra os disponíveis).

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
- **Hospedagem estática** — serviço que publica uma pasta de site pronta (o
  `build/web/`) sem precisar de servidor programado.
- **Artefato de build** — cada arquivo gerado pelo build (`.apk`, `.aab`,
  `.ipa`, pasta `build/web/`); `make artefatos` mostra quais já existem.

## Do ambiente (quando o build quebra sem ninguém ter mexido no código)

- **SDK do Flutter** — a pasta com o Flutter inteiro (o comando `flutter`, as
  bibliotecas, o plugin do Gradle). Dá para ter **mais de uma** no computador, e
  aí é preciso deixar claro qual vale para cada projeto.
- **`PATH`** — a lista de pastas que o terminal percorre para achar um comando.
  Quem aparece **primeiro** ganha; por isso dois SDKs instalados podem fazer
  `flutter` significar coisas diferentes em terminais diferentes.
- **`dart.flutterSdkPath`** — configuração do VS Code que escolhe o SDK do
  Flutter. Colocada no `.vscode/settings.json` do projeto, vale **só ali** e
  vence a configuração global do editor.
- **`android/local.properties`** — arquivinho, **não versionado**, onde o Gradle
  lê onde está o SDK do Android (`sdk.dir`) e o do Flutter (`flutter.sdk`). É
  regravado pelo próprio comando `flutter`.
- **AGP (*Android Gradle Plugin*)** — o plugin que ensina o Gradle a montar apps
  Android. Cada versão do Flutter exige uma faixa de versões do AGP; misturar
  Flutter novo com AGP antigo quebra o build.
- **`ndkVersion`** — versão do kit de código nativo (C/C++) do Android. Quando um
  plugin não declara a sua, versões antigas do AGP devolvem "nada" — e o Flutter
  novo não espera esse "nada".
- **`pubspec.lock`** — a lista congelada das versões exatas de cada dependência.
  Cada SDK do Flutter resolve essa lista à sua maneira, então dois SDKs
  alternando deixam o arquivo mudando sozinho a cada `pub get`.
- **`flutter clean`** — apaga a pasta `build/`. Resolve restos de build antigo —
  e, de quebra, apaga os logs de `make rodar`, o que faz um `tail -f` aberto
  parecer travado.
