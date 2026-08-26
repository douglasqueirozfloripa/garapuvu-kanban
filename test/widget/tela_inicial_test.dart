import 'package:flutter/material.dart';
import 'package:garapuvu_kanban/src/features/board/model/prioridade.dart';
import 'package:garapuvu_kanban/src/features/board/model/tarefa.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garapuvu_kanban/app.dart';
import 'package:garapuvu_kanban/src/data/repositorio_de_tarefas.dart';
import 'package:garapuvu_kanban/src/features/board/state/quadro_controller.dart';
import 'package:garapuvu_kanban/src/features/board/view/tela_inicial.dart';
import 'package:garapuvu_kanban/src/features/board/view/tela_lista_de_tarefas.dart';

import 'suporte_de_tela.dart';

void main() {
  // O app cria o QuadroController, que le o aparelho. Sem o cofre em memoria,
  // esses testes dependeriam do plugin nativo — que nao existe aqui.
  TestWidgetsFlutterBinding.ensureInitialized();
  late QuadroController quadro;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    quadro = QuadroController(
      repositorio: RepositorioDeTarefas(
        preferencias: await SharedPreferences.getInstance(),
      ),
    );
  });

  group('TelaInicial', () {
    testWidgets('o app inteiro abre na tela inicial',
        (WidgetTester tester) async {
      // Os demais testes montam a tela sozinha, o que e mais rapido. Este
      // monta o GarapuvuKanbanApp de verdade, para garantir que o tema e a
      // home continuam ligados como o main espera.
      await tester.pumpWidget(const GarapuvuKanbanApp());
      await tester.pumpAndSettle();

      expect(find.byType(TelaInicial), findsOneWidget);
      expect(find.text('Garapuvu Kanban'), findsOneWidget);
    });

    testWidgets('mostra o titulo do app e o passo atual do roteiro',
        (WidgetTester tester) async {
      await montarTela(tester, const TelaInicial(), quadro: quadro);

      expect(find.text('Garapuvu Kanban'), findsOneWidget);
      expect(find.text('Quadro do time Garapuvu'), findsOneWidget);
      expect(find.textContaining('Prompt 5 concluido'), findsOneWidget);
    });

    testWidgets('lista as quatro colunas na ordem da regra de negocio',
        (WidgetTester tester) async {
      await montarTela(tester, const TelaInicial(), quadro: quadro);

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

    testWidgets('leva para a lista de tarefas', (WidgetTester tester) async {
      await montarTela(tester, const TelaInicial(), quadro: quadro);

      await tester.tap(find.text(TelaListaDeTarefas.titulo));
      await tester.pumpAndSettle();

      expect(find.byType(TelaListaDeTarefas), findsOneWidget);
      // Regra 6.6: de qualquer tela da para voltar.
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('avisa que os dados ficam no aparelho (LGPD)',
        (WidgetTester tester) async {
      await montarTela(tester, const TelaInicial(), quadro: quadro);

      expect(find.textContaining('somente neste aparelho'), findsOneWidget);
    });

    // Um teste por tamanho: se qualquer um estourar o RenderFlex, o proprio
    // framework de teste falha com "A RenderFlex overflowed by ... pixels".
    for (final MapEntry<String, Size> entrada in tamanhosDeTela.entries) {
      testWidgets('monta sem overflow em ${entrada.key}',
          (WidgetTester tester) async {
        await montarTela(
          tester,
          const TelaInicial(),
          tamanho: entrada.value,
          quadro: quadro,
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Quadro do time Garapuvu'), findsOneWidget);
      });
    }

    testWidgets('mantem folga maior que 0,5 dp entre o titulo e o texto',
        (WidgetTester tester) async {
      await montarTela(tester, const TelaInicial(), quadro: quadro);

      final double folga = folgaVertical(
        tester,
        find.text('Quadro do time Garapuvu'),
        find.textContaining('Um lugar simples'),
      );

      expect(
        folga,
        greaterThan(0.5),
        reason: 'Elementos vizinhos nao podem colar nem se sobrepor.',
      );
    });

    testWidgets('respeita fonte ampliada em 200% sem quebrar',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaInicial(),
        escalaDeFonte: 2,
        quadro: quadro,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('sem tarefas, explica o que fazer em vez de ficar mudo',
        (WidgetTester tester) async {
      await montarTela(tester, const TelaInicial(), quadro: quadro);

      expect(
        find.textContaining('Nenhuma tarefa guardada ainda'),
        findsOneWidget,
      );
      expect(find.textContaining('Nova tarefa'), findsWidgets);
    });

    testWidgets('com tarefas guardadas, diz quantas e que elas ficam',
        (WidgetTester tester) async {
      await quadro.adicionar(
        Tarefa(
          id: '1',
          titulo: 'Levar doacoes ao galpao',
          responsavel: 'Ana Voluntaria',
          prioridade: Prioridade.alta,
          criadaEm: DateTime(2026, 8, 26, 9),
        ),
      );

      await montarTela(tester, const TelaInicial(), quadro: quadro);

      expect(find.textContaining('1 tarefa guardada'), findsOneWidget);
      expect(
        find.textContaining('continua aqui quando o app fechar'),
        findsOneWidget,
      );
    });

    testWidgets('o aviso do quadro aparece e da para dispensar',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'flutter.${RepositorioDeTarefas.chave}': 'lixo {{{',
      });
      final QuadroController danificado = QuadroController(
        repositorio: RepositorioDeTarefas(
          preferencias: await SharedPreferences.getInstance(),
        ),
      );
      await danificado.carregar();

      await montarTela(tester, const TelaInicial(), quadro: danificado);

      expect(find.textContaining('danificado'), findsOneWidget);

      await tester.tap(find.text('Entendi'));
      await tester.pumpAndSettle();

      expect(find.textContaining('danificado'), findsNothing);
    });

    testWidgets('passa nas diretrizes de acessibilidade do Flutter',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await montarTela(tester, const TelaInicial(), quadro: quadro);

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));

      handle.dispose();
    });
  });
}
