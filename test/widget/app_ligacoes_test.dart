import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garapuvu_kanban/app.dart';
import 'package:garapuvu_kanban/src/data/repositorio_de_tarefas.dart';
import 'package:garapuvu_kanban/src/features/board/model/prioridade.dart';
import 'package:garapuvu_kanban/src/features/board/model/tarefa.dart';
import 'package:garapuvu_kanban/src/features/board/state/quadro_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prova que o Prompt 4 esta ligado de ponta a ponta: o app cria o controller,
/// o controller le o aparelho, e a arvore de widgets enxerga o resultado.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('o app entrega um QuadroController para a arvore',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const GarapuvuKanbanApp());
    await tester.pump();

    final BuildContext contexto = tester.element(find.byType(MaterialApp));

    expect(
      Provider.of<QuadroController>(contexto, listen: false),
      isA<QuadroController>(),
      reason: 'sem isto, nenhuma tela conseguiria ler o quadro',
    );
  });

  testWidgets('ao abrir, o app JA carrega o que estava guardado',
      (WidgetTester tester) async {
    // Simula um aparelho que ja tinha tarefas de uma sessao anterior.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await RepositorioDeTarefas(
      preferencias: await SharedPreferences.getInstance(),
    ).salvar(<Tarefa>[
      Tarefa(
        id: 't1',
        titulo: 'Levar doacoes ao galpao',
        responsavel: 'Ana Voluntaria',
        prioridade: Prioridade.alta,
        criadaEm: DateTime(2026, 8, 26, 9),
      ),
    ]);

    await tester.pumpWidget(const GarapuvuKanbanApp());
    // A leitura e assincrona: alguns quadros ate ela chegar.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final QuadroController controller = Provider.of<QuadroController>(
      tester.element(find.byType(MaterialApp)),
      listen: false,
    );

    expect(controller.tarefas.map((Tarefa t) => t.id), <String>['t1']);
    expect(controller.carregando, isFalse);
    expect(controller.aviso, isNull);
  });

  testWidgets('o app NAO quebra quando o dado guardado esta danificado',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'flutter.${RepositorioDeTarefas.chave}': 'isto nao e json {{{',
    });

    await tester.pumpWidget(const GarapuvuKanbanApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final QuadroController controller = Provider.of<QuadroController>(
      tester.element(find.byType(MaterialApp)),
      listen: false,
    );

    expect(tester.takeException(), isNull, reason: 'o app abriu mesmo assim');
    expect(controller.tarefas, isEmpty);
    expect(controller.aviso, contains('danificado'));
  });
}
