import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/indicador_flor.dart';
import '../state/quadro_controller.dart';

/// Quantas tarefas estao guardadas neste aparelho.
///
/// Existe porque a **lista** de tarefas so nasce no Prompt 5: sem esta linha,
/// nao haveria como ver que a persistencia funciona. Ela tambem cumpre a regra
/// 6.6 — o estado vazio explica o que fazer em vez de nao dizer nada.
class QuantasGuardadas extends StatelessWidget {
  /// Cria o resumo do que esta guardado.
  const QuantasGuardadas({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final QuadroController quadro = context.watch<QuadroController>();

    if (quadro.carregando) {
      return const Row(
        children: <Widget>[
          IndicadorFlor(tamanho: 24, rotulo: 'Lendo as tarefas guardadas'),
          SizedBox(width: AppEspacos.sm),
          Text('Lendo as tarefas guardadas...'),
        ],
      );
    }

    final int quantas = quadro.tarefas.length;
    final String recado = switch (quantas) {
      0 => 'Nenhuma tarefa guardada ainda. Toque em "Nova tarefa" para criar '
          'a primeira.',
      1 => '1 tarefa guardada neste aparelho. Ela continua aqui quando o app '
          'fechar.',
      _ => '$quantas tarefas guardadas neste aparelho. Elas continuam aqui '
          'quando o app fechar.',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(recado, style: tema.textTheme.bodyMedium),
        if (quadro.aviso != null) ...<Widget>[
          const SizedBox(height: AppEspacos.sm),
          AvisoDoQuadro(texto: quadro.aviso!),
        ],
      ],
    );
  }
}

/// O recado do quadro (dado danificado, limite de WIP), com botao de dispensar.
class AvisoDoQuadro extends StatelessWidget {
  /// Cria o cartao de aviso.
  const AvisoDoQuadro({required this.texto, super.key});

  /// O recado a mostrar.
  final String texto;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return Card(
      color: tema.colorScheme.errorContainer,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppEspacos.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              texto,
              style: tema.textTheme.bodyMedium
                  ?.copyWith(color: tema.colorScheme.onErrorContainer),
            ),
            const SizedBox(height: AppEspacos.sm),
            SizedBox(
              height: AppEspacos.alvoDeToque,
              child: TextButton(
                onPressed: context.read<QuadroController>().limparAviso,
                child: const Text('Entendi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
