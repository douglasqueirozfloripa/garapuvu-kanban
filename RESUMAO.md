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

**Passo atual: Prompt 1 concluído.**

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
- **Os primeiros testes.** A tela inicial já é testada em três tamanhos de tela
  (celular pequeno, celular comum e tablet), com fonte ampliada em 200%, com
  verificação de contraste e de espaçamento entre elementos.

O que **ainda não existe**: o quadro de verdade. Nenhuma tarefa pode ser criada
ainda — isso começa no Prompt 2 (as regras) e aparece na tela no Prompt 3.

## Como o projeto avança

Um passo de cada vez, sempre no mesmo formato:

1. Você cola um prompt do `PROMPTS.md`.
2. A IA faz **um** objetivo, com os testes junto.
3. Ela explica em português simples, mostra o placar dos testes (e o print, se
   mexeu em tela), atualiza a documentação e propõe 2–3 próximos passos.
4. **Você escolhe** o próximo. Ela não emenda sozinha.

## Próximo passo

**Prompt 2 — o núcleo da lógica.** Agora que a teoria está documentada, ela vira
código: os modelos `Tarefa`, `Status`, `Prioridade` e `Sprint`, mais as regras de
avançar/voltar coluna, ordenar por prioridade e barrar o quarto card em
`Fazendo` — tudo em Dart puro, sem tela, com testes desde a primeira linha.
