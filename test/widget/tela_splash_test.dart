import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garapuvu_kanban/app.dart';
import 'package:garapuvu_kanban/src/core/theme/flor_garapuvu.dart';
import 'package:garapuvu_kanban/src/core/theme/indicador_flor.dart';
import 'package:garapuvu_kanban/src/features/board/view/tela_inicial.dart';
import 'package:garapuvu_kanban/src/features/board/view/tela_splash.dart';

import 'suporte_de_tela.dart';

void main() {
  // O app cria o QuadroController, que le o aparelho. Sem o cofre em memoria,
  // esses testes dependeriam do plugin nativo — que nao existe aqui.
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('FlorGarapuvu', () {
    test('tem cinco petalas, como o favicon do site', () {
      expect(FlorGarapuvu.petalas, 5);
    });

    testWidgets('desenha no tamanho pedido', (WidgetTester tester) async {
      await montarTela(tester, const Center(child: FlorGarapuvu(tamanho: 80)));

      expect(tester.getSize(find.byType(FlorGarapuvu)), const Size(80, 80));
    });
  });

  group('IndicadorFlor', () {
    testWidgets('anuncia a espera para o leitor de tela',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await montarTela(
        tester,
        const Center(child: IndicadorFlor(rotulo: 'Abrindo o aplicativo')),
        aguardarEstabilizar: false,
      );

      expect(find.bySemanticsLabel('Abrindo o aplicativo'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('gira sem quebrar ao longo do tempo',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const Center(child: IndicadorFlor()),
        aguardarEstabilizar: false,
      );

      // Avanca duas voltas inteiras. pumpAndSettle travaria aqui: a animacao
      // se repete e nunca "termina".
      for (int i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 600));
      }

      expect(tester.takeException(), isNull);
      expect(find.byType(FlorGarapuvu), findsOneWidget);
    });
  });

  group('TelaSplash', () {
    testWidgets('mostra a marca, a flor e a espera',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaSplash(),
        aguardarEstabilizar: false,
      );

      expect(find.text('Garapuvu Kanban'), findsOneWidget);
      expect(find.text('O quadro de tarefas do time'), findsOneWidget);
      expect(find.byType(IndicadorFlor), findsOneWidget);
      expect(find.byType(FlorGarapuvu), findsNWidgets(2));
    });

    testWidgets('o app abre no splash e segue sozinho para a tela inicial',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GarapuvuKanbanApp());
      await tester.pump();

      expect(find.byType(TelaSplash), findsOneWidget);
      expect(find.byType(TelaInicial), findsNothing);

      await tester.pump(TelaSplash.duracao);
      await tester.pumpAndSettle();

      expect(find.byType(TelaInicial), findsOneWidget);
      expect(
        find.byType(TelaSplash),
        findsNothing,
        reason: 'pushReplacement: o splash sai da pilha e nao volta.',
      );
    });

    testWidgets('tocar na tela pula a espera (nao e um beco)',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GarapuvuKanbanApp());
      await tester.pump();

      await tester.tap(find.byType(TelaSplash));
      await tester.pumpAndSettle();

      expect(find.byType(TelaInicial), findsOneWidget);
    });

    for (final MapEntry<String, Size> entrada in tamanhosDeTela.entries) {
      testWidgets('monta sem overflow em ${entrada.key}',
          (WidgetTester tester) async {
        await montarTela(
          tester,
          const TelaSplash(),
          tamanho: entrada.value,
          aguardarEstabilizar: false,
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Garapuvu Kanban'), findsOneWidget);
      });
    }

    testWidgets('respeita fonte ampliada em 200% sem quebrar',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaSplash(),
        escalaDeFonte: 2,
        aguardarEstabilizar: false,
      );

      expect(tester.takeException(), isNull);
    });
  });
}
