import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/core/theme/app_theme.dart';
import 'src/features/board/state/quadro_controller.dart';
import 'src/features/board/view/tela_splash.dart';

/// Raiz do aplicativo: define titulo, tema (claro e escuro) e a tela inicial.
///
/// A partir do Prompt 4 ela tambem cria o [QuadroController] e o entrega a
/// arvore de widgets com `Provider`. Fica **acima** do `MaterialApp` de
/// proposito: assim o controller sobrevive a troca de telas, e o quadro nao e
/// relido do aparelho a cada navegacao.
class GarapuvuKanbanApp extends StatelessWidget {
  /// Cria a raiz do aplicativo.
  const GarapuvuKanbanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QuadroController>(
      // `lazy: false` e essencial aqui. Por padrao o Provider so cria o objeto
      // quando alguem o le pela primeira vez — e, como nenhuma tela le o quadro
      // ainda, a leitura do aparelho so comecaria muito depois, jogando fora a
      // ideia de carregar em paralelo com a tela de abertura.
      lazy: false,
      create: (BuildContext _) {
        final QuadroController controller = QuadroController();
        // A leitura do aparelho comeca JA, em paralelo com a tela de abertura:
        // quando o splash sair, o quadro ja esta em memoria. Nao esperamos aqui
        // porque `create` e sincrono — o controller avisa a arvore sozinho
        // quando termina, que e para isso que ele e um ChangeNotifier.
        unawaited(controller.carregar());
        return controller;
      },
      child: MaterialApp(
        title: 'Garapuvu Kanban',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.claro(),
        darkTheme: AppTheme.escuro(),
        home: const TelaSplash(),
      ),
    );
  }
}
