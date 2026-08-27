# Resumão — o que é o Garapuvu Kanban, em linguagem simples

> Este arquivo responde "o que existe hoje?" sem jargão. Ele é atualizado a cada
> passo do roteiro. Se você chegou agora no projeto, leia só isto.

## A ideia

O time do **projeto social Garapuvu** precisa saber quem está fazendo o quê. Hoje
isso vive espalhado em conversa de grupo e memória. O **Garapuvu Kanban** é um
aplicativo de celular que junta tudo em um **quadro**: cada tarefa é um cartão, e
o cartão anda por quatro colunas até ficar pronto.

```
A fazer  →  Fazendo  →  Em revisão  →  Concluído
```

Cada cartão diz: **o que é**, **quem faz**, **qual a urgência** e **de qual
sprint** (o período de trabalho) ele faz parte.

Duas regras dão o tom:

- **Ninguém segura mais de 3 tarefas ao mesmo tempo** na coluna `Fazendo`. Se
  tentar, o app avisa e explica o porquê — o objetivo é o time *terminar* coisas,
  não *começar* muitas.
- **Nada some sem confirmação.** Apagar tarefa, limpar coluna ou recomeçar do
  zero sempre perguntam antes, dizendo o nome do que vai sumir.

E os **dados ficam só no aparelho**. Não tem login, não tem servidor, nada é
enviado para lugar nenhum.

## Em que pé o projeto está

**Passo atual: Prompt 4 concluído.**

O que já existe:

- **A documentação toda.** O arquivo de instruções (`instrucoes-do-projeto-…md`)
  é a lei do projeto — a IA lê ele sozinha e segue as regras em toda resposta,
  sem precisar repetir. O `PROMPTS.md` traz o roteiro inteiro, do Prompt 1 ao 13,
  com o texto pronto para colar em cada passo.
- **A fundamentação, com fontes de verdade.** A seção §2 do arquivo de instruções
  agora explica **de onde vem** cada regra do app, com link para o *Scrum Guide*
  oficial (inclusive em português), para o guia do Método Kanban e para o artigo
  de 1961 que prova a Lei de Little. É ela que responde a pergunta "por que o
  limite é 3 e não 9?": a conta mostra que segurar 9 tarefas faz cada uma demorar
  **três vezes mais**, sem ninguém trabalhar menos. O `GLOSSARIO.md` foi de 9
  para 30 termos de método, todos em uma frase.
- **O app compilando para valer.** Além de rodar no navegador, o projeto já gera
  o **APK** (instalar no celular) e o **AAB** (enviar ao Google Play) — a
  ferramenta do Android foi acertada e testada de ponta a ponta.
- **O esqueleto do app — e ele roda de verdade.** As pastas de plataforma
  (`android/`, `ios/`, `web/`) já foram geradas, as dependências instaladas, e o
  app foi aberto no navegador: mostra uma tela que explica em que passo o projeto
  está, sem nenhum erro no console e sem quebrar nem em tela de celular. Os
  prints estão em `docs/screenshots/`. As pastas do código já estão separadas em
  camadas: regras de negócio de um lado, telas do outro, guardar dados de um
  terceiro.
- **As regras do quadro, em código testado.** O "miolo" do app já existe, mesmo
  sem tela: o que é uma `Tarefa`, quais são as quatro colunas, as três
  prioridades e o que é uma `Sprint`; e as regras de **avançar e voltar** uma
  coluna por vez, **ordenar por prioridade** (com a mais antiga ganhando o
  empate), **barrar a quarta tarefa** de uma mesma pessoa em `Fazendo` e
  **conferir o título** (3 a 80 caracteres). Tudo em Dart puro — sem tela, sem
  banco, sem internet — o que faz os 36 testes dessa parte rodarem em menos de
  um segundo.
- **A cara do Garapuvu, de verdade.** O app abre com a foto do garapuvu florido
  e a flor de cinco pétalas da marca — a mesma do favicon do site, redesenhada
  para escalar sem borrar e girar como indicador de carregamento. As cores não
  são chute: foram lidas do próprio site do projeto (azul-noite, creme e o
  amarelo da flor).
- **Duas telas de verdade.** Dá para **cadastrar uma tarefa** (título,
  responsável, prioridade e estimativa), com cada erro explicando o que fazer em
  seguida. E há um **relatório de contraste** que calcula, na hora, o quanto cada
  cor do app se destaca do seu fundo — hoje **13 de 13 pares passam** no critério
  de acessibilidade AA, nos temas claro e escuro.
- **As tarefas não somem mais.** O que você cria fica guardado **no próprio
  aparelho** — feche o app, abra de novo, e a tarefa continua lá. Sem servidor,
  sem conta, sem nada saindo do celular. E se o arquivo guardado um dia estragar,
  o app **avisa e continua funcionando** em vez de quebrar: as tarefas que ainda
  dão para ler são mantidas, e ele diz quantas se perderam.
- **O ferramental de qualidade.** Um revisor automático de código, um formatador
  e um "porteiro" que roda antes de cada commit: se o código estiver fora do
  padrão, com aviso do revisor ou com teste vermelho, ele **não entra** no
  histórico.
- **Os comandos de build.** Um só atalho gera o app pronto para instalar: para
  Android (`make build-android`), para iPhone (`make build-ios`), para o
  navegador (`make build-web`) — ou tudo de uma vez (`make build`). E há um
  comando que prepara a **publicação nas lojas** (`make build-deploy`): ele só
  gera os arquivos depois de conferir formatação, análise e testes. Quando falta
  algo no computador (Xcode, SDK do Android, assinatura), o comando diz **o que
  falta e o que fazer**, em português.
- **Os comandos de emulador.** `make emulador-android` e `make emulador-ios`
  abrem um celular "de mentira" numa janela do computador e **esperam ele acabar
  de ligar** antes de devolver o terminal — assim o `make run` seguinte não falha
  só por pressa. O emulador Android do projeto (`garapuvu_pixel_7`, um Pixel 7
  com Android 16) já vem escolhido por padrão, e o teclado do computador funciona
  dentro dele. Se o id pedido não existir, o comando **lista os que existem** em
  vez de deixar a pessoa esperando.

- **Os primeiros testes.** A tela inicial já é testada em três tamanhos de tela
  (celular pequeno, celular comum e tablet), com fonte ampliada em 200%, com
  verificação de contraste e de espaçamento entre elementos.

- **A lista de tarefas.** A tela "Tarefas do time" mostra tudo o que o time tem
  para fazer, **da mais urgente para a menos urgente** — e, quando duas tarefas
  empatam na urgência, a mais antiga vem primeiro, para a lista não trocar de
  ordem sozinha a cada vez que o app abre. Cada cartão diz o título, a
  prioridade, quem se responsabilizou, em que coluna a tarefa está e a
  estimativa de horas, quando existe. A prioridade aparece **escrita**, com
  ícone e com cor: quem não distingue as três cores continua sabendo o que é
  urgente. E quando não há tarefa nenhuma, a tela explica o que vai aparecer ali
  e oferece o botão de criar a primeira, em vez de deixar a pessoa olhando para
  o nada.

- **O quadro.** É o coração do app. As quatro colunas ficam lado a lado e
  correm para o lado quando não cabem na tela — cada coluna deixa a próxima
  espiando na borda, para ninguém achar que acabou ali. Cada cartão tem duas
  setas: uma leva a tarefa para a coluna seguinte, outra traz de volta, sempre
  **uma coluna por vez**. Voltar não é fracasso: no Kanban é informação sobre o
  fluxo, como quando a revisão pede um ajuste. E quando a tarefa chega na ponta,
  a seta fica apagada em vez de sumir, para os botões não dançarem de lugar.
- **O limite de trabalho em andamento.** A coluna "Fazendo" aceita no máximo
  três tarefas **por pessoa**, e diz isso escrito embaixo do próprio nome — a
  regra não fica escondida esperando alguém esbarrar nela. Quando alguém tenta
  pegar a quarta, o app **explica**: diz quem já está com três, qual é o limite,
  por que ele existe (quanto mais coisas ao mesmo tempo, mais devagar cada uma
  acaba) e o que fazer — terminar ou devolver uma antes de começar outra. Nada é
  bloqueado em silêncio.

O que **ainda não existe**: os números da sprint (quantas tarefas em cada
coluna, quanto foi concluído), os filtros e o botão de apagar. Isso vem dos
Prompts 7 a 10.

## Como o projeto avança

Um passo de cada vez, sempre no mesmo formato:

1. Você cola um prompt do `PROMPTS.md`.
2. A IA faz **um** objetivo, com os testes junto.
3. Ela explica em português simples, mostra o placar dos testes (e o print, se
   mexeu em tela), atualiza a documentação e propõe 2–3 próximos passos.
4. **Você escolhe** o próximo. Ela não emenda sozinha.

## Próximo passo

**Prompt 7 — o painel da sprint.** O quadro mostra *onde* cada tarefa está, mas
não responde de cabeça "como estamos?". O próximo passo monta o painel com os
números do período: quantas tarefas em cada coluna, quantas já foram concluídas
e quanto ainda falta — para a reunião de acompanhamento começar com todo mundo
olhando para o mesmo lugar.
