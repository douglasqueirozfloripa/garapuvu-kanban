import 'package:flutter/material.dart';

import 'src/core/theme/app_theme.dart';
import 'src/features/board/view/tela_inicial.dart';

/// Raiz do aplicativo: define titulo, tema (claro e escuro) e a tela inicial.
///
/// A partir do Prompt 4 esta classe tambem passara a criar os `Provider`s do
/// quadro; por enquanto o app ainda nao tem estado compartilhado.
class GarapuvuKanbanApp extends StatelessWidget {
  /// Cria a raiz do aplicativo.
  const GarapuvuKanbanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garapuvu Kanban',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro(),
      darkTheme: AppTheme.escuro(),
      home: const TelaInicial(),
    );
  }
}
