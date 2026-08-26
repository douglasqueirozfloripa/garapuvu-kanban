import 'package:flutter_test/flutter_test.dart';
import 'package:garapuvu_kanban/app.dart';
import 'package:integration_test/integration_test.dart';

/// Testes ponta a ponta — o equivalente ao Playwright do template web.
///
/// Rode com um emulador ou aparelho conectado:
/// ```bash
/// make e2e     # flutter test integration_test
/// ```
///
/// O fluxo completo (criar tarefa -> avancar ate Concluido -> filtrar -> ver o
/// dashboard -> reabrir e confirmar que persistiu) entra no **Prompt 11**. Por
/// enquanto, o teste garante o basico: o app sobe de verdade, no aparelho de
/// verdade, sem excecao.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('o app inicia e mostra a tela inicial',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GarapuvuKanbanApp());
    await tester.pumpAndSettle();

    expect(find.text('Quadro do time Garapuvu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
