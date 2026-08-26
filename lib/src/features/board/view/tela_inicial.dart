import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tela_contraste.dart';
import '../widgets/quantas_guardadas.dart';
import 'abrir_cadastro_de_tarefa.dart';
import 'tela_cadastro_tarefa.dart';
import 'tela_lista_de_tarefas.dart';

/// Tela inicial provisoria do Garapuvu Kanban.
///
/// O projeto esta no **Prompt 0** do roteiro (`PROMPTS.md`): a documentacao e o
/// ferramental existem, mas o quadro ainda nao foi construido. Esta tela cumpre
/// tres papeis:
///
/// 1. provar que o app compila e roda em todas as plataformas;
/// 2. mostrar em qual passo o projeto esta, para quem abre o app pela primeira
///    vez nao ficar sem saber o que aconteceu;
/// 3. servir de referencia viva das regras de layout do projeto:
///    rolagem em vez de corte, [Wrap] em vez de linha rigida e
///    [Semantics] em tudo que importa.
///
/// Ela sera substituida pelo quadro real no **Prompt 6**.
class TelaInicial extends StatelessWidget {
  /// Cria a tela inicial provisoria.
  const TelaInicial({super.key});

  /// Colunas fixas do quadro, na ordem em que um card caminha por elas.
  static const List<String> colunasDoQuadro = <String>[
    'A fazer',
    'Fazendo',
    'Em revisao',
    'Concluido',
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Garapuvu Kanban'),
      ),
      body: SafeArea(
        // Rolagem garante que nenhuma tela pequena (320 dp) corte conteudo.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppEspacos.md),
          child: Center(
            // Em tablet o texto para de esticar e continua legivel.
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: Text(
                      'Quadro do time Garapuvu',
                      style: tema.textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: AppEspacos.sm),
                  Text(
                    'Um lugar simples para o time enxergar quem esta fazendo o '
                    'que, o que ja acabou e o que ainda nem comecou.',
                    style: tema.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppEspacos.lg),
                  Semantics(
                    header: true,
                    child: Text(
                      'As colunas do quadro',
                      style: tema.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: AppEspacos.sm),
                  // Wrap: em tela estreita as colunas descem de linha em vez de
                  // estourar o RenderFlex.
                  Wrap(
                    spacing: AppEspacos.sm,
                    runSpacing: AppEspacos.sm,
                    children: <Widget>[
                      for (final String coluna in colunasDoQuadro)
                        Chip(
                          label: Text(coluna),
                          // O rotulo ja e texto: nada aqui depende so de cor.
                        ),
                    ],
                  ),
                  const SizedBox(height: AppEspacos.lg),
                  const QuantasGuardadas(),
                  const SizedBox(height: AppEspacos.lg),
                  const _Acoes(),
                  const SizedBox(height: AppEspacos.lg),
                  _CartaoProximoPasso(tema: tema),
                  const SizedBox(height: AppEspacos.lg),
                  Text(
                    'Seus dados ficam somente neste aparelho. O app nao envia '
                    'nada para servidor nenhum.',
                    style: tema.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cartao que explica em que passo do roteiro o projeto esta.
///
/// Existe para que a tela nunca seja um "beco": mesmo sem funcionalidade, quem
/// abre o app entende o estado atual e sabe qual e o proximo passo.
class _CartaoProximoPasso extends StatelessWidget {
  const _CartaoProximoPasso({required this.tema});

  final ThemeData tema;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppEspacos.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Passo atual: Prompt 5 concluido',
              style: tema.textTheme.titleMedium,
            ),
            const SizedBox(height: AppEspacos.sm),
            Text(
              'A lista ja mostra as tarefas em ordem de prioridade, com o '
              'estado vazio explicando o que fazer. Toque em '
              '"${TelaListaDeTarefas.titulo}" para ver. O proximo passo do '
              'roteiro e o Prompt 6: o quadro em colunas, onde a tarefa avanca '
              'e volta de status.',
              style: tema.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppEspacos.sm),
            Text(
              'O roteiro completo esta em PROMPTS.md.',
              style: tema.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Os botoes que levam as telas que ja existem.
///
/// Usa [Wrap] para que em 320 dp os botoes desçam de linha em vez de estourar,
/// e cada um tem altura minima de alvo de toque.
class _Acoes extends StatelessWidget {
  const _Acoes();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppEspacos.sm,
      runSpacing: AppEspacos.sm,
      children: <Widget>[
        SizedBox(
          height: AppEspacos.alvoDeToque,
          child: FilledButton.icon(
            onPressed: () => abrirCadastroDeTarefa(context),
            icon: const Icon(Icons.add),
            label: const Text(TelaCadastroTarefa.titulo),
          ),
        ),
        SizedBox(
          height: AppEspacos.alvoDeToque,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext _) => const TelaListaDeTarefas(),
              ),
            ),
            icon: const Icon(Icons.checklist),
            label: const Text(TelaListaDeTarefas.titulo),
          ),
        ),
        SizedBox(
          height: AppEspacos.alvoDeToque,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext _) => const TelaContraste(),
              ),
            ),
            icon: const Icon(Icons.contrast),
            label: const Text(TelaContraste.titulo),
          ),
        ),
      ],
    );
  }
}
