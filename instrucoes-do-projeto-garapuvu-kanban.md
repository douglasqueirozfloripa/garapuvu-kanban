# Instruções do projeto — Garapuvu Kanban (app Flutter)

> **Este arquivo é a lei do projeto.** A IA lê este documento e segue estas regras
> em **todas as respostas**, sem que o usuário precise repeti-las a cada prompt.
> Ele nasceu do modelo *estado zero* do **ia-na-pratica** (originalmente escrito
> para desenvolvimento **web**) e foi **traduzido para o ecossistema Flutter** —
> as regras de qualidade continuam as mesmas; só mudam as ferramentas que as
> executam.

---

## 1. O que é o app

**Garapuvu Kanban** é um aplicativo **Flutter** para o time do **projeto social
Garapuvu** organizar suas tarefas em um quadro **Scrum/Kanban**: cada tarefa é um
**card** que caminha por **colunas de status** (`A fazer → Fazendo → Em revisão →
Concluído`), com **prioridade**, **responsável** e **estimativa**, dentro de
**sprints** de duração fixa.

O app é **didático**: ele existe tanto para servir ao Garapuvu quanto para ensinar,
passo a passo, como se constrói um app Flutter de verdade — com testes,
acessibilidade, documentação e histórico de decisões.

**Público-alvo:** pessoas voluntárias do Garapuvu, muitas delas sem experiência
técnica. Isso significa: telas óbvias, textos em português claro, nada de jargão
sem explicação, e nenhum caminho sem saída.

**Plataformas-alvo:** Android e iOS primeiro; Web como bônus para o time abrir no
navegador sem instalar nada.

---

## 2. FUNDAMENTAÇÃO (seção obrigatória)

> **Estado: preenchida no Prompt 1** (fontes consultadas e links verificados em
> 26/08/2026). Toda afirmação abaixo aponta para a fonte que a sustenta.

O **conceito central** que este software implementa é o par **Scrum + Kanban**
aplicado a um time voluntário pequeno. Esta seção diz de onde esse conceito vem
— para que nenhuma regra do app seja "porque sim".

Critério de escolha das fontes: **fonte primária > livro do autor original >
blog > post de rede social**. Foram usadas apenas as duas primeiras categorias.

---

### 2.1 Scrum — o ciclo curto e repetido

**Fonte primária:** *The Scrum Guide* (2020), de Ken Schwaber e Jeff Sutherland,
os criadores do método. É o documento normativo, mantido em site neutro, de graça
e em mais de 40 idiomas.

- Original: <https://scrumguides.org/scrum-guide.html>
- PDF: <https://scrumguides.org/docs/scrumguide/v2020/2020-Scrum-Guide-US.pdf>
- **Português do Brasil (leia este):**
  <https://scrumguides.org/docs/scrumguide/v2020/2020-Scrum-Guide-PortugueseBR-3.0.pdf>

O que o Guia define, e que este app respeita:

- Scrum é *"um framework leve que ajuda pessoas, times e organizações a gerar
  valor por meio de soluções adaptativas para problemas complexos"*. **Leve** é a
  palavra-chave: ele diz o mínimo, e o resto o time decide.
- O time é **"tipicamente 10 pessoas ou menos"**, porque *"times menores se
  comunicam melhor e são mais produtivos"* — o Garapuvu se encaixa nisso.
- A **Sprint** é um evento de **duração fixa, de um mês ou menos**, e é o que
  *"cria consistência"*. Daí a regra §5.6: sprint tem nome, início e fim.
- Os três **artefatos** e seus compromissos: *Product Backlog* → Meta do Produto;
  *Sprint Backlog* → Meta da Sprint; *Increment* → Definição de Pronto. O nosso
  `backlog` (§5.6) é o primeiro deles.
- Os três **pilares do empirismo**: **transparência** (*"o trabalho deve estar
  visível para quem o faz"*), **inspeção** e **adaptação**. O quadro visível na
  tela é a transparência virando software.

---

### 2.2 Kanban — o fluxo e o quadro

Kanban tem **duas** fontes primárias vivas, e elas não são a mesma coisa:

**(a) O Método Kanban, de David J. Anderson** — formulado no livro *Kanban:
Successful Evolutionary Change for Your Technology Business* (Blue Hole Press,
2010, ISBN 978-0-9845214-0-1), hoje mantido como guia oficial pela Kanban
University.

- Guia oficial: <https://kanban.university/kanban-guide/>
- Escola do autor: <https://djaa.com/the-principles-and-general-practices-of-the-kanban-method/>

Dele vêm os **princípios de gestão da mudança** — *comece com o que você faz
hoje*, *busque melhoria por evolução*, *encoraje liderança em todos os níveis* —
e as **seis práticas gerais**:

1. **Visualizar** o trabalho e o fluxo;
2. **Limitar o trabalho em progresso (WIP)**;
3. **Gerenciar o fluxo**;
4. **Tornar as políticas explícitas**;
5. **Implementar ciclos de feedback**;
6. **Melhorar de forma colaborativa e evoluir experimentalmente**.

A prática 2 é a que gera a regra §5.3 deste app. O guia é explícito: limitar WIP
faz o sistema focar em *"fluxo suave em vez de utilização total dos recursos"*, e
cria um **sistema puxado** — *"puxar trabalho só acontece se houver capacidade"*.
A prática 4 é a que gera a regra "o app avisa **e explica o porquê**": política
escondida não é política explícita.

**(b) O Kanban Guide (ProKanban.org)**, de Daniel Vacanti e John Coleman — versão
mais enxuta e independente de fornecedor.

- <https://kanbanguides.org/english/>

Dele vêm as **quatro métricas de fluxo**, citadas literalmente:

| Métrica | Definição oficial |
| --- | --- |
| **WIP** | *"o número de itens de trabalho começados mas não terminados"* |
| **Throughput** (vazão) | *"o número de itens de trabalho terminados por unidade de tempo"* |
| **Cycle Time** (tempo de ciclo) | *"o tempo decorrido entre quando um item começou e quando terminou"* |
| **Work Item Age** (idade do item) | *"o tempo decorrido entre quando um item começou e a data de hoje"* |

Essas quatro são exatamente as contas que o **dashboard do Prompt 7** deve
mostrar. Note que este guia trata o controle de WIP como prática fundante e
**não** cita a Lei de Little — a ponte matemática vem da fonte seguinte.

---

### 2.3 Por que **3**? O limite de WIP e a Lei de Little

A regra §5.3 (máximo de 3 cards por pessoa em `Fazendo`) não é palpite: ela se
apoia num teorema com 60+ anos.

**Fonte primária:** LITTLE, John D. C. *A Proof for the Queuing Formula: L = λW*.
**Operations Research**, v. 9, n. 3, p. 383–387, 1961.
DOI [10.1287/opre.9.3.383](https://doi.org/10.1287/opre.9.3.383)
· Retrospectiva do próprio autor nos 50 anos:
[10.1287/opre.1110.0940](https://doi.org/10.1287/opre.1110.0940)

> Os dois links são de periódico científico (INFORMS): abrem no navegador, mas o
> texto completo é pago. A citação acima já é suficiente para localizar o artigo.

**Aplicação a Kanban** — whitepaper *Little's Law for Professional Scrum with
Kanban*, de Daniel Vacanti (Scrum.org):
<https://scrumorg-website-prod.s3.amazonaws.com/drupal/2018-05/Little%E2%80%99s%20Law%20for%20Professional%20Scrum%20with%20Kanban.pdf>

Nele a lei aparece nesta forma, literalmente:

```
Average Cycle Time = Average Work In Progress / Average Throughput
```

Em português: **tempo médio para terminar uma tarefa = tarefas em andamento ÷
tarefas concluídas por período.**

O resultado prático, nas palavras do autor: *quanto mais coisas você toca ao mesmo
tempo (em média), mais tempo cada uma delas leva para terminar (em média)*.

Traduzindo para o Garapuvu: se a vazão do time é ~2 tarefas por semana e cada
pessoa segura 3 tarefas, cada tarefa demora ~1,5 semana. Se ela segurar 9, passa
a demorar ~4,5 semanas — **sem que ninguém tenha ficado mais lento**. O único
número que mudou foi o WIP. É por isso que o app avisa em vez de deixar passar.

Vacanti também alerta que a lei vale sob **premissas de estabilidade** (o que
entra e o que sai precisam se equilibrar ao longo do tempo). Por isso o app usa a
lei como **argumento para o limite**, não como previsão exata de prazo — e o
dashboard mostrará números observados, não profecias.

---

### 2.4 Por que o **par** Scrum + Kanban serve a um time voluntário pequeno

Em linguagem simples, cada um resolve uma dor diferente do Garapuvu:

| A dor do time | Quem resolve | Como |
| --- | --- | --- |
| "Ninguém sabe quem está fazendo o quê" | **Kanban** | O quadro visível (prática 1) é a resposta em 3 segundos |
| "A gente começa muita coisa e não termina nada" | **Kanban** | Limite de WIP + Lei de Little (§2.3) |
| "O trabalho nunca acaba, não dá senso de progresso" | **Scrum** | A sprint tem fim; no fim, algo ficou pronto |
| "Cada um combinou uma regra diferente" | **Kanban** | Políticas explícitas (prática 4), escritas na tela |
| "Voluntário entra e sai, some por duas semanas" | **Kanban** | Fluxo contínuo: o quadro não depende de todo mundo estar presente |
| "Não temos gerente" | **ambos** | Scrum: time **auto-gerenciável**; Kanban: *encoraje liderança em todos os níveis* |

E por que **os dois juntos**, e não um só?

- **Só Scrum** exige cerimônias (planning, review, retrospectiva, daily) e
  papéis formais. Para gente que doa 3 horas por semana, isso é caro demais — o
  método viraria o trabalho.
- **Só Kanban** dá visibilidade e fluxo, mas não dá **ritmo**. Sem um fim de
  ciclo, trabalho voluntário tende a se dissolver: não há o momento de "olha o
  que a gente fez".
- **Juntos**: pegamos de Scrum o que é **barato e motivador** (a sprint com data
  de fim, o backlog priorizado) e de Kanban o que é **contínuo e honesto** (o
  quadro, o limite de WIP, as políticas explícitas). Ninguém precisa virar
  Scrum Master para usar o app.

Isso está alinhado ao próprio Método Kanban, cujo primeiro princípio é
**"comece com o que você faz hoje"**: o app não obriga o Garapuvu a adotar Scrum
inteiro — ele acrescenta uma camada sobre o jeito que o time já trabalha.

---

### 2.5 Rastreabilidade: cada regra e sua fonte

| Regra de negócio (§5) | Vem de |
| --- | --- |
| 1. Colunas fixas do quadro | Kanban, prática 1 (visualizar o fluxo) |
| 2. Avança e volta uma coluna por vez | Kanban, prática 3 (gerenciar o fluxo): voltar é informação, não fracasso |
| 3. Limite de WIP = 3, com aviso explicado | Kanban, práticas 2 e 4 + Lei de Little (§2.3) |
| 4. Prioridade com desempate por data | Scrum, *Product Backlog* ordenado |
| 6. Sprint com início e fim | Scrum, *"evento de duração fixa, de um mês ou menos"* |
| 7. Nada some sem confirmação | Não vem do método: é usabilidade (§6) e LGPD |
| 8. Tudo é local | Não vem do método: é LGPD (§6) |

As duas últimas linhas são deliberadas — **nem toda regra do app precisa vir de
Scrum ou Kanban**, e fingir que vem seria inventar fonte.

---

### 2.6 O que esta seção **não** cobre

A **inspiração visual** (marca/sistema de mercado que guia paleta, cores e estilo
de tela) é assunto **diferente** e entra junto da primeira tela / design tokens
(Prompt 3). Neste projeto ela já está definida: **Material Design 3 + paleta
derivada da identidade do Garapuvu** (ver §8).

---

## 3. Stack (decisões já tomadas)

| Camada | Escolha | Por quê |
| --- | --- | --- |
| Framework | **Flutter** (canal `stable`) + **Dart 3** | Um código, Android + iOS + Web. |
| Estado | **Provider + `ChangeNotifier`** | Abordagem recomendada na documentação oficial do Flutter para apps pequenos/médios; poucos conceitos novos. |
| Persistência | **`shared_preferences` guardando JSON** | Equivalente direto ao `localStorage` do template web: simples, sem schema, sem migração. |
| Design | **Material 3** (`useMaterial3: true`) + design tokens próprios | Padrão do Flutter, acessível por construção. |
| Testes unitários | `package:test` / `flutter_test` | Lógica pura testada isoladamente. |
| Testes de interface | `flutter_test` (widget tests) | Equivalente ao teste de DOM do template web. |
| Testes ponta a ponta | **`integration_test`** | Equivalente ao **Playwright** do template web. |
| Lint | **`flutter analyze`** + `flutter_lints` + regras estritas | Equivalente ao **ESLint**. |
| Formatação | **`dart format`** | Equivalente ao **Prettier**. Formatador oficial, sem configuração. |
| Hook de commit | **Git hook em `.githooks/pre-commit`** | Equivalente ao **Husky**. Dart não tem `package.json`, então o hook é nativo do Git. |
| Atalhos de comando | **`Makefile`** (`make lint`, `make format`, `make prepare`) | Equivalente aos *scripts* do `package.json`. |

**Regra de dependências:** nenhuma dependência nova entra sem que a IA explique,
em uma frase, **o que ela resolve** e **por que não dá para fazer sem ela**.

---

## 4. Arquitetura de pastas

Camadas separadas, seguindo a orientação de arquitetura da documentação do Flutter
(*UI ← lógica de estado ← dados*):

```
lib/
  main.dart                     # só o ponto de entrada
  app.dart                      # MaterialApp, tema, rotas
  src/
    core/
      theme/                    # design tokens, ColorScheme, contraste
      utils/                    # helpers puros (datas, formatação)
    features/
      board/
        model/                  # Tarefa, Status, Prioridade, Sprint (imutáveis)
        state/                  # QuadroController (ChangeNotifier)
        view/                   # telas
        widgets/                # componentes reutilizáveis
    data/                       # repositório: shared_preferences <-> JSON
test/
  unit/                         # lógica pura (sem widget)
  widget/                       # telas e componentes
integration_test/               # fluxo ponta a ponta no app real
docs/
  screenshots/                  # prints da "definição de pronto visual"
```

**Regras:**

- `model/` e `utils/` **não importam Flutter** — são Dart puro, para poderem ser
  testados sem `WidgetTester`.
- `view/` e `widgets/` **não falam com `shared_preferences`** diretamente; passam
  sempre pelo `state/`, que passa pelo `data/`.
- Um arquivo, uma responsabilidade. Se passar de ~200 linhas, é hora de dividir.

---

## 5. Regras de negócio

1. **Colunas fixas do quadro:** `A fazer`, `Fazendo`, `Em revisão`, `Concluído`.
2. **Ciclo de status:** o card avança uma coluna por vez e **também volta** uma
   coluna por vez. Não existe pulo de coluna.
3. **Limite de WIP:** a coluna `Fazendo` aceita no máximo **3 cards por pessoa**.
   Ao estourar, o app **avisa e explica o porquê** — não bloqueia em silêncio.
4. **Prioridade:** `Alta`, `Média`, `Baixa`. A lista ordena por prioridade e, em
   caso de empate, pela data de criação (mais antigo primeiro).
5. **Toda tarefa tem** título obrigatório (3 a 80 caracteres), responsável,
   prioridade e status. Descrição e estimativa são opcionais.
6. **Sprint:** período com nome, data de início e de fim. Uma tarefa pertence a
   no máximo uma sprint; tarefas sem sprint ficam no *backlog*.
7. **Nada some sem confirmação:** excluir tarefa, limpar coluna e "Reiniciar
   experiência" pedem confirmação explícita, com o nome do que será apagado.
8. **Tudo é local:** os dados vivem no aparelho de quem usa. Não há servidor,
   não há conta, não há envio de dados para lugar nenhum.

---

## 6. Regras automáticas de TODA resposta

Estas oito regras valem para **cada** resposta da IA neste projeto, sem precisar
serem pedidas.

### 6.1 Testes dos dois lados

Toda funcionalidade nasce com teste **da lógica** (unitário, em `test/unit/`) **e**
teste **da interface** (widget test, em `test/widget/`). "Dos dois lados" é literal:
se a resposta mexeu na regra e na tela, as duas coisas têm teste.

### 6.2 Clean code comentado

Nomes em **português** para o domínio (`Tarefa`, `Prioridade`, `avancarStatus`) e
em inglês só onde o Flutter obriga. Funções curtas, sem número mágico. Comentários
explicam **o porquê**, nunca o *o quê* — e todo arquivo público leva `///` de
documentação (padrão `dartdoc`).

### 6.3 Acessibilidade WCAG AA com relatório de contraste ao vivo

- Todo elemento interativo tem `Semantics` com rótulo em português.
- Alvo de toque mínimo de **48x48 dp**.
- Contraste de texto **≥ 4,5:1** (texto normal) e **≥ 3:1** (texto grande e ícones).
- O app tem uma **tela de contraste ao vivo** (`docs`/rodapé de desenvolvimento)
  que calcula e mostra a razão de contraste real de cada par de cores do tema,
  com o selo **PASSA/FALHA AA** — o cálculo é código, não estimativa.
- O app funciona com fonte ampliada até **200%** (`textScaler`) sem quebrar.

### 6.4 Qualidade visual: layout sem quebra

O equivalente Flutter do "Flexbox/Grid sem quebra" do template web:

- Layout com `Row`/`Column`/`Flex`/`Expanded`/`Wrap`/`GridView` — **nunca** com
  posição fixa em pixel.
- **Zero `RenderFlex overflow`**: todo widget test roda com a tela em três
  tamanhos (telefone pequeno 320dp, telefone comum 390dp, tablet 768dp) e falha
  se aparecer *overflow*.
- Texto longo usa `TextOverflow.ellipsis` ou quebra de linha — nunca corte seco.

### 6.5 Espaçamento garantido por teste

Elementos não se colam nem se sobrepõem. Cada tela ganha um teste que compara os
retângulos (`tester.getRect`) dos elementos vizinhos e exige **folga > 0,5 dp**
entre eles. Se encostou, o teste falha.

### 6.6 Usabilidade sem becos

De qualquer tela dá para **voltar**. Todo estado vazio explica o que fazer e traz
o botão da ação. Todo erro diz **o que aconteceu** e **qual é o próximo passo**.
Nenhuma mensagem termina sem uma saída.

### 6.7 LGPD com dados fictícios

Nada de dados reais de pessoas voluntárias em código, teste, screenshot ou slide.
Os exemplos usam nomes fictícios (`Ana Voluntária`, `Bruno Horta`, `Carla Mutirão`).
O app tem **exportar meus dados** (JSON) e **apagar tudo** — e o README diz, em
português claro, que os dados nunca saem do aparelho.

### 6.8 Registro obrigatório

Toda resposta atualiza, quando fizer sentido:

- **`GLOSSARIO.md`** — cada termo novo (de Scrum/Kanban ou de Flutter) com
  explicação em uma frase para leigos.
- **`RESUMAO.md`** — o que o projeto é hoje, em linguagem simples.
- **`PROMPTS.md`** — o prompt enviado, o resultado em 2–4 linhas e o próximo passo.

---

## 7. Checagem de regressão em TODO prompt

**Qualquer** resposta que altere código — inclusive as **sem tela** (persistência,
refatoração, ferramental) — termina com:

```bash
make check      # dart format --set-exit-if-changed + flutter analyze + flutter test
```

e **reporta o placar** (`X testes passaram, Y falharam`). Depois que o ferramental
do Prompt 2.5 existir, `dart format` e `flutter analyze` são obrigatórios antes de
encerrar — o mesmo par que o **hook de pre-commit** repete a cada commit, em
**qualquer** branch.

**Se algum teste ficar vermelho, a resposta não está pronta.** A IA conserta ou
explica exatamente o que quebrou — nunca entrega placar omitido.

---

## 8. Definição de pronto VISUAL

Respostas que mexem em **interface** (primeira tela, quadro, dashboard, filtros…),
além do placar de testes, **geram o screenshot**:

```bash
flutter test --update-goldens          # golden files, versionados
# ou, para print de tela real:
flutter run -d <dispositivo>           # e screenshot salvo em docs/screenshots/
```

A tela só é **pronta** quando: o screenshot está bom, nenhum teste regrediu, o
relatório de contraste passa em AA e o teste de espaçamento passa. **Print e
placar vêm juntos**, na mesma resposta.

### Inspiração visual e design tokens

**Inspiração:** **Material Design 3** com a paleta **real** do
[site oficial do Garapuvu](https://projeto-garapuvu.web.app/), lida das CSS
custom properties (`--gp-*`) que o próprio site declara.

> **Correção registrada (Prompt 3):** até aqui esta seção dizia que a base era
> "verde de mata com acento de madeira". Era **palpite**, feito antes de alguém
> olhar o site. A identidade de verdade é outra: **azul-noite + creme + o
> amarelo da flor do garapuvu** — a árvore floresce amarelo, e é esse amarelo
> que o site usa no botão principal, sobre fundo azul-noite. Verde-folha e
> marrom-galho existem, mas são apoio.

| Token do site | Cor | Papel no app |
| --- | --- | --- |
| `--gp-bloom` | `#F2B705` amarelo-flor | `primary` — a cor de ação |
| `--gp-band` / `--gp-text` | `#0E1F38` azul-noite | barra do topo, texto, `onPrimary` |
| `--gp-page` | `#FBF7EE` creme | fundo das telas claras |
| `--gp-leaf` | `#3E6B4F` verde-folha | `secondary` |
| `--gp-branch` | `#5B4636` marrom-galho | `tertiary` |
| `--gp-bloom-deep` | `#A85F00` âmbar escuro | texto de botão sobre fundo claro |

**Armadilha aprendida:** o amarelo-flor só funciona como **fundo** (com texto
azul-noite, 9,08:1). Como **cor de texto** sobre o creme ele dá **1,70:1** —
ilegível. É para isso que o site oferece o âmbar escuro. A diretriz de contraste
do `flutter_test` pegou esse erro; o painel de contraste **não**, porque o par
não estava na lista dele. Lição: o painel só confere o que está listado em
`pares_de_contraste.dart` — os dois testes são necessários.

A marca também entra como **imagem**: o `favicon.svg` do site (a flor de cinco
pétalas) foi redesenhado em Flutter com `CustomPaint` (`flor_garapuvu.dart`), e a
foto do garapuvu florido abre o app na tela de splash.

Os tokens ficam em `lib/src/core/theme/app_cores.dart` como constantes nomeadas
(nada de cor solta no meio do widget), e cada par fundo/texto entra no relatório
de contraste da §6.3.

---

## 9. Como a IA fecha CADA resposta

Sempre nesta ordem, sem exceção:

1. **Explicar em linguagem simples** o que foi feito (como se fosse para alguém do
   time do Garapuvu que não programa).
2. **Mostrar o placar** dos testes (e o screenshot, se mexeu em tela).
3. **Documentar** — atualizar `GLOSSARIO.md` / `RESUMAO.md` / `PROMPTS.md`.
4. **Propor 2–3 próximos passos** numerados — e **parar**, esperando a escolha do
   usuário. A IA **não** emenda o próximo passo sozinha.

E sempre que uma decisão técnica for tomada, dizer **por que** aquela e não a
alternativa. Entender a decisão vale mais do que só receber o código.

---

## 10. Um objetivo por prompt

O projeto avança em **partes pequenas**. Se um pedido do usuário embutir várias
coisas, a IA faz a primeira, entrega funcionando e testada, e oferece as demais
como próximos passos. É mais fácil revisar e corrigir um passo do que um
"faça tudo".
