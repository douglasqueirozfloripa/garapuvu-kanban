# CLAUDE.md

Este repositório é o **Garapuvu Kanban**, um app Flutter didático para o time do
projeto social Garapuvu organizar tarefas em um quadro Scrum/Kanban.

## Antes de qualquer coisa

Leia **`instrucoes-do-projeto-garapuvu-kanban.md`** — é a lei do projeto. Ele define
a stack, a arquitetura de pastas, as regras de negócio e as **regras automáticas de
toda resposta** (testes dos dois lados, clean code comentado, acessibilidade WCAG AA
com relatório de contraste, layout sem quebra, espaçamento por teste, usabilidade
sem becos, LGPD com dados fictícios e registro em `GLOSSARIO.md` / `RESUMAO.md` /
`PROMPTS.md`).

Leia também **`PROMPTS.md`** para saber em que passo do roteiro o projeto está.

## Comandos

```bash
make prepare   # instala dependências e ativa o hook de pre-commit
make format    # dart format .
make lint      # flutter analyze
make test      # flutter test
make check     # format (modo verificação) + lint + test  <- rodar antes de encerrar
make e2e       # integration_test em um dispositivo conectado
```

## Fechamento obrigatório de toda resposta

1. Explicar em linguagem simples.
2. Mostrar o placar dos testes (+ screenshot, se mexeu em tela).
3. Atualizar a documentação.
4. Propor 2–3 próximos passos numerados **e parar**.
