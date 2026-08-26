# Instruções para a IA — Garapuvu Kanban

> Este arquivo existe para que qualquer assistente de IA (GitHub Copilot, Claude,
> Gemini…) carregue as regras do projeto automaticamente.

**As regras completas estão em
[`instrucoes-do-projeto-garapuvu-kanban.md`](../instrucoes-do-projeto-garapuvu-kanban.md).
Leia aquele arquivo antes de responder qualquer coisa neste repositório e siga-o
em TODAS as respostas.**

Resumo do que ele exige, para consulta rápida:

- **Um objetivo por resposta.** Pedido grande vira primeiro passo + próximos passos.
- **Testes dos dois lados:** unitário (`test/unit/`) **e** de interface (`test/widget/`).
- **Clean code comentado:** domínio em português, `///` em tudo que é público,
  comentário explica o *porquê*.
- **Acessibilidade WCAG AA:** `Semantics` em tudo interativo, alvo de 48x48 dp,
  contraste ≥ 4,5:1 calculado por código, fonte até 200% sem quebrar.
- **Layout sem quebra:** `Row`/`Column`/`Wrap`/`GridView`, zero `RenderFlex overflow`,
  testado em 320 / 390 / 768 dp.
- **Espaçamento por teste:** folga > 0,5 dp entre elementos vizinhos.
- **Usabilidade sem becos:** sempre dá para voltar; erro diz o próximo passo.
- **LGPD:** só dados fictícios em código, teste, print e slide.
- **Registro:** atualizar `GLOSSARIO.md`, `RESUMAO.md` e `PROMPTS.md`.
- **Regressão:** terminar rodando `make check` e **reportar o placar**. Mexeu em
  tela? Vem screenshot junto.
- **Fechamento:** explicar simples → placar → documentar → propor 2–3 próximos
  passos e parar.
