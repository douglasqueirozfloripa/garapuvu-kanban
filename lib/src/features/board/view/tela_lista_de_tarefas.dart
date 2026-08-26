import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/indicador_flor.dart';
import '../model/tarefa.dart';
import '../state/quadro_controller.dart';
import '../widgets/cartao_de_tarefa.dart';
import '../widgets/quantas_guardadas.dart';
import 'abrir_cadastro_de_tarefa.dart';
import 'tela_cadastro_tarefa.dart';

/// A lista de tarefas do time, da mais urgente para a menos urgente.
///
/// A ordem e a regra de negocio 4, e ela nao e escolha da tela: quem ordena e
/// `ordenarPorPrioridade`, em `model/regras_quadro.dart`, atraves de
/// [QuadroController.emOrdemDePrioridade]. A tela so desenha o que recebe —
/// assim a mesma ordem vale para qualquer outra tela que venha depois.
///
/// A lista atravessa as quatro colunas de proposito. A pergunta que ela
/// responde e "o que e mais urgente agora?"; a visao dividida por coluna e o
/// quadro do Prompt 6.
class TelaListaDeTarefas extends StatelessWidget {
  /// Cria a tela da lista.
  const TelaListaDeTarefas({super.key});

  /// Titulo da tela, reutilizado pelo botao que a abre.
  static const String titulo = 'Tarefas do time';

  /// A frase que explica a ordem, escrita para quem nunca ouviu falar de
  /// Kanban.
  ///
  /// Regra 6.6: a tela diz **por que** os cartoes estao nesta ordem, em vez de
  /// deixar a pessoa deduzir.
  static const String explicacaoDaOrdem =
      'Da mais urgente para a menos urgente. Quando duas tarefas empatam na '
      'prioridade, a mais antiga vem primeiro.';

  @override
  Widget build(BuildContext context) {
    final QuadroController quadro = context.watch<QuadroController>();

    return Scaffold(
      appBar: AppBar(title: const Text(titulo)),
      body: SafeArea(
        child: Center(
          // Em tablet a lista para de esticar e continua confortavel de ler.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _Corpo(quadro: quadro),
          ),
        ),
      ),
    );
  }
}

/// Escolhe entre os tres estados possiveis da tela: lendo, vazia e com lista.
class _Corpo extends StatelessWidget {
  const _Corpo({required this.quadro});

  final QuadroController quadro;

  @override
  Widget build(BuildContext context) {
    if (quadro.carregando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppEspacos.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IndicadorFlor(tamanho: 48, rotulo: 'Lendo as tarefas guardadas'),
              SizedBox(height: AppEspacos.md),
              Text('Lendo as tarefas guardadas...'),
            ],
          ),
        ),
      );
    }

    final List<Tarefa> tarefas = quadro.emOrdemDePrioridade;
    if (tarefas.isEmpty) {
      return const _ListaVazia();
    }
    return _Lista(tarefas: tarefas, aviso: quadro.aviso);
  }
}

/// O estado vazio: explica o que aconteceu e traz o botao da acao.
///
/// Regra 6.6 do arquivo de instrucoes — "todo estado vazio explica o que fazer
/// e traz o botao da acao". Uma tela que so dissesse "nenhuma tarefa" seria um
/// beco: quem abriu o app pela primeira vez ficaria olhando para o nada.
class _ListaVazia extends StatelessWidget {
  const _ListaVazia();

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    // Rolagem mesmo no estado vazio: com fonte a 200% em tela de 320 dp, este
    // texto sozinho ja passa da altura disponivel.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppEspacos.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.checklist_outlined,
            size: 48,
            color: tema.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppEspacos.md),
          Semantics(
            header: true,
            child: Text(
              'Nenhuma tarefa por aqui ainda',
              style: tema.textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: AppEspacos.sm),
          Text(
            'Assim que o time criar a primeira tarefa, ela aparece nesta '
            'lista. As mais urgentes ficam no topo, para ninguem precisar '
            'procurar o que fazer agora.',
            style: tema.textTheme.bodyLarge,
          ),
          const SizedBox(height: AppEspacos.lg),
          const _BotaoNovaTarefa(),
        ],
      ),
    );
  }
}

/// A lista de verdade, com o cabecalho que explica a ordem.
class _Lista extends StatelessWidget {
  const _Lista({required this.tarefas, required this.aviso});

  final List<Tarefa> tarefas;
  final String? aviso;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    // Um item de cabecalho + um por tarefa. Fica tudo no mesmo ListView (e nao
    // num Column acima dele) para o cabecalho rolar junto: em 320 dp com fonte
    // a 200% ele sozinho ocupa boa parte da tela.
    return ListView.separated(
      padding: const EdgeInsets.all(AppEspacos.md),
      itemCount: tarefas.length + 1,
      separatorBuilder: (BuildContext _, int __) =>
          const SizedBox(height: AppEspacos.md),
      itemBuilder: (BuildContext context, int indice) {
        if (indice == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _quantasTarefas(tarefas.length),
                style: tema.textTheme.titleMedium,
              ),
              const SizedBox(height: AppEspacos.xs),
              Text(
                TelaListaDeTarefas.explicacaoDaOrdem,
                style: tema.textTheme.bodyMedium,
              ),
              if (aviso != null) ...<Widget>[
                const SizedBox(height: AppEspacos.md),
                AvisoDoQuadro(texto: aviso!),
              ],
              const SizedBox(height: AppEspacos.md),
              const _BotaoNovaTarefa(),
            ],
          );
        }
        return CartaoDeTarefa(tarefa: tarefas[indice - 1]);
      },
    );
  }

  /// O cabecalho em portugues, sem "1 tarefas".
  static String _quantasTarefas(int quantas) {
    return quantas == 1 ? '1 tarefa no quadro' : '$quantas tarefas no quadro';
  }
}

/// O botao que abre o cadastro, com o alvo de toque minimo de 48 dp.
class _BotaoNovaTarefa extends StatelessWidget {
  const _BotaoNovaTarefa();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppEspacos.alvoDeToque,
      child: FilledButton.icon(
        onPressed: () => abrirCadastroDeTarefa(context),
        icon: const Icon(Icons.add),
        label: const Text(TelaCadastroTarefa.titulo),
      ),
    );
  }
}
