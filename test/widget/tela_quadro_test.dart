import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garapuvu_kanban/src/data/repositorio_de_tarefas.dart';
import 'package:garapuvu_kanban/src/features/board/model/prioridade.dart';
import 'package:garapuvu_kanban/src/features/board/model/regras_quadro.dart';
import 'package:garapuvu_kanban/src/features/board/model/status.dart';
import 'package:garapuvu_kanban/src/features/board/model/tarefa.dart';
import 'package:garapuvu_kanban/src/features/board/state/quadro_controller.dart';
import 'package:garapuvu_kanban/src/features/board/view/tela_quadro.dart';
import 'package:garapuvu_kanban/src/features/board/widgets/cartao_de_tarefa.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'suporte_de_tela.dart';

/// Nomes ficticios (regra 6.7, LGPD).
const String _ana = 'Ana Voluntaria';
const String _bruno = 'Bruno Horta';

final DateTime _base = DateTime(2026, 8, 26, 9);

/// Apelido curto para a coluna do meio, para as chamadas de teste caberem
/// numa linha so.
const Status _emAndamento = Status.fazendo;

Tarefa _tarefa(
  String titulo, {
  Status status = Status.aFazer,
  String responsavel = _ana,
  Prioridade prioridade = Prioridade.media,
}) =>
    Tarefa(
      id: titulo,
      titulo: titulo,
      responsavel: responsavel,
      prioridade: prioridade,
      status: status,
      criadaEm: _base,
    );

Future<QuadroController> _quadroCom(List<Tarefa> tarefas) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final RepositorioDeTarefas repo =
      RepositorioDeTarefas(preferencias: await SharedPreferences.getInstance());
  await repo.salvar(tarefas);
  final QuadroController quadro = QuadroController(repositorio: repo);
  await quadro.carregar();
  return quadro;
}

/// O rotulo do botao de avancar/voltar de uma tarefa para [destino].
String _paraColuna(String verbo, String titulo, Status destino) =>
    '$verbo "$titulo" para ${destino.rotulo}';

/// Uma tela larga o bastante para as quatro colunas caberem de uma vez.
///
/// Os testes de COMPORTAMENTO usam este tamanho para nao precisarem rolar
/// antes de cada toque. Os testes de LAYOUT continuam nos tres tamanhos do
/// projeto, e ha um teste so para a rolagem horizontal.
const Size _telaLarga = Size(1280, 1000);

/// O botao de avancar/voltar de uma tarefa, achado pelo rotulo do leitor de
/// tela — o mesmo texto que o `tooltip` mostra a quem usa mouse.
///
/// `find.byTooltip` devolve o `Tooltip`, que o `IconButton` constroi por
/// dentro; subimos ate o botao para poder tocar nele e ler o `onPressed`.
Finder _botao(String rotulo) => find.ancestor(
      of: find.byTooltip(rotulo),
      matching: find.byType(IconButton),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TelaQuadro', () {
    testWidgets('mostra as quatro colunas na ordem do fluxo',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaQuadro(),
        tamanho: _telaLarga,
        quadro: await _quadroCom(<Tarefa>[]),
      );

      double? anterior;
      for (final Status status in Status.values) {
        final double x = tester.getTopLeft(find.text(status.rotulo)).dx;
        if (anterior != null) {
          expect(
            x,
            greaterThan(anterior),
            reason: 'A coluna "${status.rotulo}" vem depois da anterior.',
          );
        }
        anterior = x;
      }
    });

    testWidgets('cada cartao aparece na coluna em que a tarefa esta',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaQuadro(),
        tamanho: _telaLarga,
        quadro: await _quadroCom(<Tarefa>[
          _tarefa('Levar doacoes'),
          _tarefa('Consertar portao', status: Status.fazendo),
        ]),
      );

      // O cartao fica sob o cabecalho da sua coluna: mesma faixa horizontal.
      expect(
        tester.getTopLeft(find.text('Consertar portao')).dx,
        greaterThan(tester.getTopLeft(find.text('Levar doacoes')).dx),
      );
    });

    testWidgets('o ciclo completo na tela: vai ate o fim e volta ao inicio',
        (WidgetTester tester) async {
      final QuadroController quadro =
          await _quadroCom(<Tarefa>[_tarefa('Levar doacoes')]);
      await montarTela(
        tester,
        const TelaQuadro(),
        tamanho: _telaLarga,
        quadro: quadro,
      );

      for (final Status destino in <Status>[
        Status.fazendo,
        Status.emRevisao,
        Status.concluido,
      ]) {
        await tester
            .tap(_botao(_paraColuna('Avancar', 'Levar doacoes', destino)));
        await tester.pumpAndSettle();
        expect(quadro.tarefas.single.status, destino);
      }

      for (final Status destino in <Status>[
        Status.emRevisao,
        Status.fazendo,
        Status.aFazer,
      ]) {
        await tester
            .tap(_botao(_paraColuna('Voltar', 'Levar doacoes', destino)));
        await tester.pumpAndSettle();
        expect(quadro.tarefas.single.status, destino);
      }
    });

    testWidgets('na ponta do quadro o botao fica desabilitado, e nao some',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaQuadro(),
        tamanho: _telaLarga,
        quadro: await _quadroCom(<Tarefa>[_tarefa('Primeira')]),
      );

      // Sumir faria os botoes dancarem de lugar a cada movimento.
      final Finder voltar = _botao('"Primeira" ja esta na primeira coluna');
      expect(voltar, findsOneWidget);
      expect(tester.widget<IconButton>(voltar).onPressed, isNull);

      expect(
        _botao('Avancar "Primeira" para ${Status.fazendo.rotulo}'),
        findsOneWidget,
      );
    });

    testWidgets('a ultima coluna nao oferece avancar', (WidgetTester t) async {
      await montarTela(
        t,
        const TelaQuadro(),
        tamanho: _telaLarga,
        quadro: await _quadroCom(<Tarefa>[
          _tarefa('Pronta', status: Status.concluido),
        ]),
      );

      final Finder avancar = _botao('"Pronta" ja esta na ultima coluna');
      expect(t.widget<IconButton>(avancar).onPressed, isNull);
    });

    testWidgets('o limite de WIP avisa, explica e nao move a tarefa',
        (WidgetTester tester) async {
      final QuadroController quadro = await _quadroCom(<Tarefa>[
        for (int i = 1; i <= limiteWipPorPessoa; i++)
          _tarefa('Em andamento $i', status: _emAndamento, responsavel: _bruno),
        _tarefa('A quarta', responsavel: _bruno),
      ]);
      await montarTela(
        tester,
        const TelaQuadro(),
        tamanho: _telaLarga,
        quadro: quadro,
      );

      await tester
          .tap(_botao('Avancar "A quarta" para ${Status.fazendo.rotulo}'));
      await tester.pumpAndSettle();

      // Regra de negocio 3: avisa E explica, sem bloquear em silencio.
      expect(find.textContaining('limite combinado pelo time'), findsOneWidget);
      expect(find.textContaining('Termine ou devolva'), findsOneWidget);
      expect(
        quadro.tarefas.firstWhere((Tarefa t) => t.id == 'A quarta').status,
        Status.aFazer,
        reason: 'A tarefa barrada nao pode ter andado.',
      );

      await tester.tap(find.text('Entendi'));
      await tester.pumpAndSettle();
      expect(find.textContaining('limite combinado pelo time'), findsNothing);
    });

    testWidgets('o limite e por pessoa: outra pessoa passa',
        (WidgetTester tester) async {
      final QuadroController quadro = await _quadroCom(<Tarefa>[
        for (int i = 1; i <= limiteWipPorPessoa; i++)
          _tarefa('Em andamento $i', status: _emAndamento, responsavel: _bruno),
        _tarefa('Da Ana', responsavel: _ana),
      ]);
      await montarTela(
        tester,
        const TelaQuadro(),
        tamanho: _telaLarga,
        quadro: quadro,
      );

      await tester
          .tap(_botao('Avancar "Da Ana" para ${Status.fazendo.rotulo}'));
      await tester.pumpAndSettle();

      expect(
        quadro.tarefas.firstWhere((Tarefa t) => t.id == 'Da Ana').status,
        Status.fazendo,
      );
    });

    testWidgets('a coluna Fazendo mostra a politica, e nao so a esconde',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaQuadro(),
        tamanho: _telaLarga,
        quadro: await _quadroCom(<Tarefa>[]),
      );

      expect(
        find.text('Ate $limiteWipPorPessoa por pessoa'),
        findsOneWidget,
        reason: 'Politica explicita e a quarta pratica do Kanban.',
      );
    });

    testWidgets('coluna vazia explica o que significa estar vazia',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaQuadro(),
        tamanho: _telaLarga,
        quadro: await _quadroCom(<Tarefa>[]),
      );

      // Cada coluna tem o seu proprio recado: "vazio" quer dizer coisas
      // diferentes em cada etapa do fluxo.
      expect(find.textContaining('Use o + la em cima'), findsOneWidget);
      expect(find.textContaining('Nada concluido ainda'), findsOneWidget);
    });

    testWidgets('o cartao do quadro nao repete a coluna dentro dele',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaQuadro(),
        tamanho: _telaLarga,
        quadro: await _quadroCom(<Tarefa>[_tarefa('Levar doacoes')]),
      );

      // "A fazer" aparece uma vez so: no cabecalho da coluna.
      expect(find.text(Status.aFazer.rotulo), findsOneWidget);
    });

    testWidgets('rolando para o lado, chega-se a ultima coluna',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaQuadro(),
        tamanho: tamanhosDeTela['tablet (768 dp)'],
        quadro: await _quadroCom(<Tarefa>[
          _tarefa('Comprar mudas', status: Status.concluido),
        ]),
      );

      // Em 768 dp as ultimas colunas comecam fora da tela — e por isso que o
      // quadro rola na horizontal em vez de espremer tudo.
      expect(find.text('Comprar mudas'), findsNothing);

      await tester.drag(
        find.byType(TelaQuadro),
        const Offset(-900, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('Comprar mudas'), findsOneWidget);
      expect(find.text(Status.concluido.rotulo), findsOneWidget);
    });

    testWidgets('a coluna deixa a proxima espiando na tela pequena',
        (WidgetTester tester) async {
      const double telefonePequeno = 320;
      final double largura = TelaQuadro.larguraParaTela(telefonePequeno);

      expect(
        largura,
        lessThan(telefonePequeno),
        reason: 'Se a coluna ocupasse a tela toda, ninguem descobriria que ha '
            'mais colunas para o lado.',
      );
    });

    testWidgets('mantem folga maior que 0,5 dp entre cartoes da mesma coluna',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaQuadro(),
        tamanho: _telaLarga,
        quadro: await _quadroCom(<Tarefa>[
          _tarefa('Primeira', prioridade: Prioridade.alta),
          _tarefa('Segunda', prioridade: Prioridade.baixa),
        ]),
      );

      expect(
        folgaVertical(
          tester,
          find.byType(CartaoDeTarefa).at(0),
          find.byType(CartaoDeTarefa).at(1),
        ),
        greaterThan(0.5),
      );
    });

    for (final MapEntry<String, Size> entrada in tamanhosDeTela.entries) {
      testWidgets('monta sem overflow em ${entrada.key}',
          (WidgetTester tester) async {
        await montarTela(
          tester,
          const TelaQuadro(),
          tamanho: entrada.value,
          quadro: await _quadroCom(<Tarefa>[
            _tarefa('Levar doacoes ao galpao do bairro'),
            _tarefa('Consertar portao', status: Status.fazendo),
            _tarefa('Conferir a lista', status: Status.emRevisao),
            _tarefa('Comprar mudas', status: Status.concluido),
          ]),
        );

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('respeita fonte ampliada em 200% sem quebrar',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaQuadro(),
        tamanho: tamanhosDeTela['telefone pequeno (320 dp)'],
        escalaDeFonte: 2,
        quadro: await _quadroCom(<Tarefa>[
          _tarefa('Levar doacoes ao galpao do bairro'),
        ]),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('passa nas diretrizes de acessibilidade do Flutter',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await montarTela(
        tester,
        const TelaQuadro(),
        tamanho: _telaLarga,
        quadro: await _quadroCom(<Tarefa>[
          _tarefa('Levar doacoes'),
          _tarefa('Consertar portao', status: Status.fazendo),
        ]),
      );

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));

      handle.dispose();
    });

    testWidgets('o cabecalho da coluna se anuncia inteiro ao leitor de tela',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await montarTela(
        tester,
        const TelaQuadro(),
        tamanho: _telaLarga,
        quadro: await _quadroCom(<Tarefa>[_tarefa('Levar doacoes')]),
      );

      expect(find.bySemanticsLabel('A fazer: 1 tarefa'), findsOneWidget);
      expect(find.bySemanticsLabel('Fazendo: 0 tarefas'), findsOneWidget);

      handle.dispose();
    });
  });
}
