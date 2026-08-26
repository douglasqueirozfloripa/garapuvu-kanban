import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garapuvu_kanban/src/features/board/model/prioridade.dart';
import 'package:garapuvu_kanban/src/features/board/model/status.dart';
import 'package:garapuvu_kanban/src/features/board/model/tarefa.dart';
import 'package:garapuvu_kanban/src/features/board/view/tela_cadastro_tarefa.dart';

import 'suporte_de_tela.dart';

/// Preenche o formulario com dados ficticios (regra 6.7).
Future<void> _preencher(
  WidgetTester tester, {
  String titulo = 'Levar doacoes ao galpao',
  String responsavel = 'Ana Voluntaria',
  String estimativa = '',
}) async {
  await tester.enterText(find.byType(TextFormField).at(0), titulo);
  await tester.enterText(find.byType(TextFormField).at(1), responsavel);
  await tester.enterText(find.byType(TextFormField).at(2), estimativa);
  await tester.pumpAndSettle();
}

void main() {
  group('TelaCadastroTarefa', () {
    testWidgets('mostra os quatro campos que o prompt pede',
        (WidgetTester tester) async {
      await montarTela(tester, const TelaCadastroTarefa());

      expect(find.text('Titulo da tarefa'), findsOneWidget);
      expect(find.text('Quem vai fazer'), findsOneWidget);
      expect(find.text('Prioridade'), findsOneWidget);
      expect(find.text('Estimativa em horas (opcional)'), findsOneWidget);
      for (final Prioridade p in Prioridade.values) {
        expect(find.text(p.rotulo), findsOneWidget);
      }
    });

    testWidgets('titulo vazio barra o salvamento e explica o motivo',
        (WidgetTester tester) async {
      await montarTela(tester, const TelaCadastroTarefa());

      await tester.tap(find.text('Salvar tarefa'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Escreva um titulo'), findsOneWidget);
      expect(find.textContaining('Diga quem vai fazer'), findsOneWidget);
    });

    testWidgets('a mensagem de erro aparece INTEIRA, sem corte',
        (WidgetTester tester) async {
      await montarTela(tester, const TelaCadastroTarefa());

      await tester.tap(find.text('Salvar tarefa'));
      await tester.pumpAndSettle();

      for (final String trecho in <String>[
        'Escreva um titulo',
        'Diga quem vai fazer',
      ]) {
        expect(
          textoFoiCortado(tester, find.textContaining(trecho)),
          isFalse,
          reason: 'A mensagem "$trecho..." esta cortada: quem le nao descobre '
              'qual e o proximo passo.',
        );
      }
    });

    testWidgets('titulo curto demais e recusado com explicacao',
        (WidgetTester tester) async {
      await montarTela(tester, const TelaCadastroTarefa());
      await _preencher(tester, titulo: 'Oi');

      await tester.tap(find.text('Salvar tarefa'));
      await tester.pumpAndSettle();

      expect(find.textContaining('curto demais'), findsOneWidget);
    });

    testWidgets('estimativa que nao e numero e recusada',
        (WidgetTester tester) async {
      await montarTela(tester, const TelaCadastroTarefa());
      await _preencher(tester, estimativa: 'tres');

      await tester.tap(find.text('Salvar tarefa'));
      await tester.pumpAndSettle();

      expect(find.textContaining('numero de horas'), findsOneWidget);
    });

    testWidgets('formulario valido devolve a Tarefa montada',
        (WidgetTester tester) async {
      Tarefa? recebida;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () async {
                  recebida = await Navigator.of(context).push<Tarefa>(
                    MaterialPageRoute<Tarefa>(
                      builder: (BuildContext _) => const TelaCadastroTarefa(),
                    ),
                  );
                },
                child: const Text('abrir'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await _preencher(tester, estimativa: '3');
      await tester.tap(find.text('Alta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar tarefa'));
      await tester.pumpAndSettle();

      expect(recebida, isNotNull);
      expect(recebida!.titulo, 'Levar doacoes ao galpao');
      expect(recebida!.responsavel, 'Ana Voluntaria');
      expect(recebida!.prioridade, Prioridade.alta);
      expect(recebida!.estimativaEmHoras, 3);
      expect(recebida!.status, Status.aFazer, reason: 'nasce em "A fazer"');
      expect(recebida!.estaNoBacklog, isTrue);
    });

    // Regra 6.4: zero RenderFlex overflow nos tres tamanhos.
    for (final MapEntry<String, Size> entrada in tamanhosDeTela.entries) {
      testWidgets('monta sem overflow em ${entrada.key}',
          (WidgetTester tester) async {
        await montarTela(
          tester,
          const TelaCadastroTarefa(),
          tamanho: entrada.value,
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Salvar tarefa'), findsOneWidget);
      });
    }

    testWidgets(
        'mantem folga maior que 0,5 dp entre o titulo da secao e os '
        'botoes de prioridade', (WidgetTester tester) async {
      await montarTela(tester, const TelaCadastroTarefa());

      expect(
        folgaVertical(
          tester,
          find.text('Prioridade'),
          find.text(Prioridade.alta.rotulo),
        ),
        greaterThan(0.5),
        reason: 'Elementos vizinhos nao podem colar nem se sobrepor.',
      );
    });

    testWidgets('respeita fonte ampliada em 200% sem quebrar',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaCadastroTarefa(),
        escalaDeFonte: 2,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('passa nas diretrizes de acessibilidade do Flutter',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await montarTela(tester, const TelaCadastroTarefa());

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });
  });
}
