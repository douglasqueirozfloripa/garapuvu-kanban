import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tela_contraste.dart';
import '../model/tarefa.dart';
import '../state/quadro_controller.dart';
import '../widgets/quantas_guardadas.dart';
import 'tela_cadastro_tarefa.dart';

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
              'Passo atual: Prompt 4 concluido',
              style: tema.textTheme.titleMedium,
            ),
            const SizedBox(height: AppEspacos.sm),
            Text(
              'As tarefas agora ficam guardadas no aparelho: elas continuam '
              'aqui quando o app fecha e abre de novo. O proximo passo do '
              'roteiro e o Prompt 5: mostrar a lista de tarefas em ordem de '
              'prioridade.',
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

  /// Abre o cadastro e, se uma tarefa voltar, confirma na tela.
  ///
  /// O `ScaffoldMessenger` e capturado ANTES do `await`: depois dele o
  /// `context` pode nao valer mais, e usa-lo seria um bug silencioso.
  static Future<void> _abrirCadastro(BuildContext context) async {
    final ScaffoldMessengerState mensageiro = ScaffoldMessenger.of(context);
    final NavigatorState navegador = Navigator.of(context);
    final QuadroController quadro = context.read<QuadroController>();

    final Tarefa? criada = await navegador.push<Tarefa>(
      MaterialPageRoute<Tarefa>(
        builder: (BuildContext _) => const TelaCadastroTarefa(),
      ),
    );

    if (criada == null) {
      return;
    }

    // A partir do Prompt 4 a tarefa e realmente gravada no aparelho.
    await quadro.adicionar(criada);

    mensageiro.showSnackBar(
      SnackBar(
        content: Text(
          'Tarefa "${criada.titulo}" guardada neste aparelho para '
          '${criada.responsavel}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppEspacos.sm,
      runSpacing: AppEspacos.sm,
      children: <Widget>[
        SizedBox(
          height: AppEspacos.alvoDeToque,
          child: FilledButton.icon(
            onPressed: () => _abrirCadastro(context),
            icon: const Icon(Icons.add),
            label: const Text(TelaCadastroTarefa.titulo),
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
