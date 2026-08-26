import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garapuvu_kanban/src/core/theme/app_theme.dart';
import 'package:garapuvu_kanban/src/core/theme/pares_de_contraste.dart';
import 'package:garapuvu_kanban/src/core/theme/tela_contraste.dart';

import 'suporte_de_tela.dart';

void main() {
  group('paleta do tema', () {
    // O teste que da sentido ao Prompt 3: se alguem trocar uma cor e o
    // contraste cair, ESTE teste fica vermelho antes de a tela ir para
    // producao.
    for (final Brightness brilho in Brightness.values) {
      final String nome = brilho == Brightness.light ? 'claro' : 'escuro';

      test('todo par do tema $nome passa no nivel AA', () {
        final ThemeData tema =
            brilho == Brightness.light ? AppTheme.claro() : AppTheme.escuro();
        final List<ParDeCores> pares = paresDoTema(tema.colorScheme);

        expect(pares, isNotEmpty);
        for (final ParDeCores par in pares) {
          expect(
            par.passa,
            isTrue,
            reason: 'O par "${par.nome}" (${par.onde}) esta em '
                '${par.razaoFormatada} no tema $nome.',
          );
        }
      });
    }

    test('a razao independe da ordem e fica na faixa possivel', () {
      for (final ParDeCores par in paresDoTema(AppTheme.claro().colorScheme)) {
        expect(par.razao, greaterThanOrEqualTo(1));
        expect(par.razao, lessThanOrEqualTo(21));
      }
    });
  });

  group('TelaContraste', () {
    testWidgets('mostra o placar geral e nenhum par reprovado',
        (WidgetTester tester) async {
      await montarTela(tester, const TelaContraste());

      final List<ParDeCores> pares = paresDoTema(AppTheme.claro().colorScheme);

      expect(
        find.text('${pares.length} de ${pares.length} pares passam no '
            'nivel AA.'),
        findsOneWidget,
      );
      expect(find.text('PASSA AA'), findsWidgets);
      expect(find.text('FALHA AA'), findsNothing);
      expect(
        find.text(pares.first.razaoFormatada),
        findsWidgets,
        reason: 'A razao calculada precisa aparecer escrita na tela.',
      );
    });

    testWidgets('rolando ate o fim, todos os pares aparecem e nenhum reprova',
        (WidgetTester tester) async {
      await montarTela(tester, const TelaContraste());

      final List<ParDeCores> pares = paresDoTema(AppTheme.claro().colorScheme);

      // A lista e preguicosa (so monta o que esta visivel), entao cada par
      // precisa ser trazido a tela antes de ser conferido.
      for (final ParDeCores par in pares) {
        await tester.scrollUntilVisible(
          find.text(par.onde),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(par.onde), findsOneWidget);
        expect(find.text('FALHA AA'), findsNothing);
      }
    });

    testWidgets('o selo nao depende so de cor: traz texto e icone',
        (WidgetTester tester) async {
      await montarTela(tester, const TelaContraste());

      expect(find.byIcon(Icons.check_circle), findsWidgets);
      expect(find.text('PASSA AA'), findsWidgets);
    });

    testWidgets('funciona tambem no tema escuro', (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaContraste(),
        brilho: Brightness.dark,
      );

      expect(find.text('FALHA AA'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    for (final MapEntry<String, Size> entrada in tamanhosDeTela.entries) {
      testWidgets('monta sem overflow em ${entrada.key}',
          (WidgetTester tester) async {
        await montarTela(
          tester,
          const TelaContraste(),
          tamanho: entrada.value,
        );

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('respeita fonte ampliada em 200% sem quebrar',
        (WidgetTester tester) async {
      await montarTela(tester, const TelaContraste(), escalaDeFonte: 2);

      expect(tester.takeException(), isNull);
    });

    testWidgets('passa nas diretrizes de acessibilidade do Flutter',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await montarTela(tester, const TelaContraste());

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));

      handle.dispose();
    });
  });
}
