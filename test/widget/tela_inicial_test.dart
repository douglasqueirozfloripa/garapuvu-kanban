import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garapuvu_kanban/app.dart';
import 'package:garapuvu_kanban/src/features/board/view/tela_inicial.dart';

/// Tamanhos de tela em que TODA tela deste projeto precisa funcionar.
///
/// Regra do arquivo de instrucoes (secao "Qualidade visual: layout sem
/// quebra"): telefone pequeno, telefone comum e tablet.
const Map<String, Size> tamanhosDeTela = <String, Size>{
  'telefone pequeno (320 dp)': Size(320, 640),
  'telefone comum (390 dp)': Size(390, 844),
  'tablet (768 dp)': Size(768, 1024),
};

Future<void> _montarEm(WidgetTester tester, Size tamanho) async {
  tester.view.physicalSize = tamanho;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const GarapuvuKanbanApp());
  await tester.pumpAndSettle();
}

void main() {
  group('TelaInicial', () {
    testWidgets('mostra o titulo do app e o passo atual do roteiro',
        (WidgetTester tester) async {
      await _montarEm(tester, tamanhosDeTela['telefone comum (390 dp)']!);

      expect(find.text('Garapuvu Kanban'), findsOneWidget);
      expect(find.text('Quadro do time Garapuvu'), findsOneWidget);
      expect(find.textContaining('Prompt 0 concluido'), findsOneWidget);
    });

    testWidgets('lista as quatro colunas na ordem da regra de negocio',
        (WidgetTester tester) async {
      await _montarEm(tester, tamanhosDeTela['telefone comum (390 dp)']!);

      expect(
        TelaInicial.colunasDoQuadro,
        <String>['A fazer', 'Fazendo', 'Em revisao', 'Concluido'],
        reason: 'O card caminha uma coluna por vez, nesta ordem.',
      );

      for (final String coluna in TelaInicial.colunasDoQuadro) {
        expect(
          find.text(coluna),
          findsOneWidget,
          reason: 'A coluna "$coluna" precisa aparecer escrita, nao so em cor.',
        );
      }
    });

    testWidgets('avisa que os dados ficam no aparelho (LGPD)',
        (WidgetTester tester) async {
      await _montarEm(tester, tamanhosDeTela['telefone comum (390 dp)']!);

      expect(find.textContaining('somente neste aparelho'), findsOneWidget);
    });

    // Um teste por tamanho: se qualquer um estourar o RenderFlex, o proprio
    // framework de teste falha com "A RenderFlex overflowed by ... pixels".
    for (final MapEntry<String, Size> entrada in tamanhosDeTela.entries) {
      testWidgets('monta sem overflow em ${entrada.key}',
          (WidgetTester tester) async {
        await _montarEm(tester, entrada.value);

        expect(tester.takeException(), isNull);
        expect(find.text('Quadro do time Garapuvu'), findsOneWidget);
      });
    }

    testWidgets('mantem folga maior que 0,5 dp entre o titulo e o texto',
        (WidgetTester tester) async {
      await _montarEm(tester, tamanhosDeTela['telefone comum (390 dp)']!);

      final Rect titulo = tester.getRect(find.text('Quadro do time Garapuvu'));
      final Rect paragrafo =
          tester.getRect(find.textContaining('Um lugar simples'));

      final double folga = paragrafo.top - titulo.bottom;

      expect(
        folga,
        greaterThan(0.5),
        reason: 'Elementos vizinhos nao podem colar nem se sobrepor.',
      );
    });

    testWidgets('respeita fonte ampliada em 200% sem quebrar',
        (WidgetTester tester) async {
      tester.view.physicalSize = tamanhosDeTela['telefone comum (390 dp)']!;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MediaQuery(
          // fromView preserva o tamanho real da tela de teste; so o textScaler
          // e trocado. Um MediaQueryData vazio daria Size.zero e
          // quebraria o layout inteiro.
          data: MediaQueryData.fromView(tester.view).copyWith(
            textScaler: const TextScaler.linear(2),
          ),
          child: const GarapuvuKanbanApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('passa nas diretrizes de acessibilidade do Flutter',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _montarEm(tester, tamanhosDeTela['telefone comum (390 dp)']!);

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));

      handle.dispose();
    });
  });
}
