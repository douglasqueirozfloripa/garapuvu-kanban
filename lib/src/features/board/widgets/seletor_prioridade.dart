import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../model/prioridade.dart';

/// Escolha da prioridade da tarefa, em botoes lado a lado.
///
/// Usa [Wrap] em vez de [Row] porque em tela estreita (320 dp) as tres opcoes
/// nao cabem numa linha so: com `Wrap` elas descem de linha; com `Row`
/// estourariam o layout (regra 6.4).
///
/// Cada opcao carrega o **rotulo em texto**, nunca so a cor — quem nao
/// distingue cores precisa conseguir escolher do mesmo jeito.
class SeletorPrioridade extends StatelessWidget {
  /// Cria o seletor de prioridade.
  const SeletorPrioridade({
    required this.selecionada,
    required this.aoSelecionar,
    super.key,
  });

  /// A prioridade escolhida agora.
  final Prioridade selecionada;

  /// Chamado quando a pessoa escolhe outra prioridade.
  final ValueChanged<Prioridade> aoSelecionar;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppEspacos.sm,
      runSpacing: AppEspacos.sm,
      children: <Widget>[
        for (final Prioridade prioridade in Prioridade.values)
          ConstrainedBox(
            // Alvo de toque minimo do WCAG e do Material.
            constraints: const BoxConstraints(
              minHeight: AppEspacos.alvoDeToque,
              minWidth: AppEspacos.alvoDeToque,
            ),
            child: ChoiceChip(
              label: Text(prioridade.rotulo),
              selected: prioridade == selecionada,
              // O rotulo semantico diz o estado, para o leitor de tela nao
              // depender do destaque visual.
              tooltip: 'Prioridade ${prioridade.rotulo}',
              onSelected: (bool escolhida) {
                if (escolhida) {
                  aoSelecionar(prioridade);
                }
              },
            ),
          ),
      ],
    );
  }
}
