import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/indicador_flor.dart';
import '../model/regras_quadro.dart';
import '../model/status.dart';
import '../model/tarefa.dart';
import '../state/quadro_controller.dart';
import '../widgets/cartao_de_tarefa.dart';
import '../widgets/quantas_guardadas.dart';
import 'abrir_cadastro_de_tarefa.dart';
import 'tela_cadastro_tarefa.dart';

/// O quadro Kanban: as quatro colunas, lado a lado, com a tarefa caminhando.
///
/// E o coracao do app. Cada coluna e uma etapa do fluxo (regra de negocio 1) e
/// cada cartao anda **uma coluna por vez**, para frente ou para tras (regra 2).
///
/// As colunas rolam na horizontal de proposito. A alternativa — espremer quatro
/// colunas na largura de um telefone — deixaria cada cartao com poucos
/// caracteres de titulo, e um quadro que nao se le nao serve para nada. A
/// largura de coluna sempre deixa a proxima **espiando** na borda, que e como
/// quem usa descobre que ha mais coisa para o lado.
class TelaQuadro extends StatelessWidget {
  /// Cria a tela do quadro.
  const TelaQuadro({super.key});

  /// Titulo da tela, reutilizado pelo botao que a abre.
  static const String titulo = 'Quadro do time';

  /// Largura confortavel de uma coluna, em dp.
  static const double larguraDaColuna = 280;

  /// A largura que a coluna realmente ocupa em [larguraDaTela].
  ///
  /// Em telefone pequeno (320 dp) a coluna encolhe para caber com a proxima
  /// espiando; em tablet ela para de crescer, porque cartao largo demais fica
  /// cansativo de ler.
  static double larguraParaTela(double larguraDaTela) {
    final double comEspiada = larguraDaTela - AppEspacos.xl * 2;
    return comEspiada < larguraDaColuna ? comEspiada : larguraDaColuna;
  }

  @override
  Widget build(BuildContext context) {
    final QuadroController quadro = context.watch<QuadroController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(titulo),
        actions: <Widget>[
          IconButton(
            onPressed: () => abrirCadastroDeTarefa(context),
            icon: const Icon(Icons.add),
            tooltip: TelaCadastroTarefa.titulo,
          ),
        ],
      ),
      body: SafeArea(child: _Corpo(quadro: quadro)),
    );
  }
}

/// Escolhe entre "lendo o aparelho" e o quadro montado.
class _Corpo extends StatelessWidget {
  const _Corpo({required this.quadro});

  final QuadroController quadro;

  @override
  Widget build(BuildContext context) {
    if (quadro.carregando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IndicadorFlor(tamanho: 48, rotulo: 'Lendo as tarefas guardadas'),
            SizedBox(height: AppEspacos.md),
            Text('Lendo as tarefas guardadas...'),
          ],
        ),
      );
    }

    final double largura = TelaQuadro.larguraParaTela(
      MediaQuery.sizeOf(context).width,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (quadro.aviso != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppEspacos.md,
              AppEspacos.md,
              AppEspacos.md,
              0,
            ),
            child: AvisoDoQuadro(texto: quadro.aviso!),
          ),
        // Expanded: da altura definida as colunas, que por dentro tem cada uma
        // a sua propria rolagem vertical.
        Expanded(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppEspacos.md),
            itemCount: Status.values.length,
            separatorBuilder: (BuildContext _, int __) =>
                const SizedBox(width: AppEspacos.md),
            itemBuilder: (BuildContext _, int indice) => _Coluna(
              status: Status.values[indice],
              largura: largura,
              quadro: quadro,
            ),
          ),
        ),
      ],
    );
  }
}

/// Uma coluna do quadro: o cabecalho e os cartoes que estao nela.
class _Coluna extends StatelessWidget {
  const _Coluna({
    required this.status,
    required this.largura,
    required this.quadro,
  });

  final Status status;
  final double largura;
  final QuadroController quadro;

  @override
  Widget build(BuildContext context) {
    final List<Tarefa> tarefas = quadro.daColuna(status);

    return SizedBox(
      width: largura,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _CabecalhoDaColuna(status: status, quantas: tarefas.length),
          const SizedBox(height: AppEspacos.sm),
          Expanded(
            child: tarefas.isEmpty
                ? _ColunaVazia(status: status)
                : ListView.separated(
                    itemCount: tarefas.length,
                    separatorBuilder: (BuildContext _, int __) =>
                        const SizedBox(height: AppEspacos.sm),
                    itemBuilder: (BuildContext _, int indice) {
                      final Tarefa tarefa = tarefas[indice];
                      return CartaoDeTarefa(
                        tarefa: tarefa,
                        // A coluna ja esta escrita no cabecalho.
                        mostrarColuna: false,
                        aoAvancar: () => quadro.avancar(tarefa.id),
                        aoVoltar: () => quadro.voltar(tarefa.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// O nome da coluna, quantos cartoes ela tem e — em `Fazendo` — a politica.
///
/// A quarta pratica do Kanban pede **politicas explicitas**: o limite de tres
/// tarefas por pessoa fica escrito na coluna, e nao escondido ate alguem
/// esbarrar nele.
class _CabecalhoDaColuna extends StatelessWidget {
  const _CabecalhoDaColuna({required this.status, required this.quantas});

  final Status status;
  final int quantas;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return Semantics(
      header: true,
      container: true,
      label: '${status.rotulo}: $quantas '
          '${quantas == 1 ? 'tarefa' : 'tarefas'}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  status.rotulo,
                  style: tema.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppEspacos.sm),
              Text('$quantas', style: tema.textTheme.titleMedium),
            ],
          ),
          if (status == Status.fazendo)
            Text(
              'Ate $limiteWipPorPessoa por pessoa',
              style: tema.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

/// O que uma coluna sem cartao nenhum mostra.
///
/// Regra 6.6: nem uma coluna vazia fica muda. Ela diz o que significa estar
/// vazia — que e diferente em cada etapa do fluxo.
class _ColunaVazia extends StatelessWidget {
  const _ColunaVazia({required this.status});

  final Status status;

  /// O recado de cada coluna vazia, escrito para quem nunca ouviu falar de
  /// Kanban.
  static String recadoDe(Status status) {
    return switch (status) {
      Status.aFazer => 'Nada esperando para comecar. Use o + la em cima para '
          'criar uma tarefa.',
      Status.fazendo => 'Ninguem com trabalho em andamento. Avance uma tarefa '
          'de "${Status.aFazer.rotulo}" quando comecar.',
      Status.emRevisao => 'Nada esperando conferencia de outra pessoa.',
      Status.concluido => 'Nada concluido ainda. O que terminar aparece aqui.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: tema.colorScheme.outline),
        borderRadius: BorderRadius.circular(AppEspacos.sm),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppEspacos.md),
        child: Text(
          recadoDe(status),
          style: tema.textTheme.bodySmall,
        ),
      ),
    );
  }
}
