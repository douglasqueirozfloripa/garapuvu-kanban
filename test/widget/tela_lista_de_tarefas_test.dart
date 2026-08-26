import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garapuvu_kanban/src/data/repositorio_de_tarefas.dart';
import 'package:garapuvu_kanban/src/features/board/model/prioridade.dart';
import 'package:garapuvu_kanban/src/features/board/model/status.dart';
import 'package:garapuvu_kanban/src/features/board/model/tarefa.dart';
import 'package:garapuvu_kanban/src/features/board/state/quadro_controller.dart';
import 'package:garapuvu_kanban/src/features/board/view/tela_lista_de_tarefas.dart';
import 'package:garapuvu_kanban/src/features/board/widgets/cartao_de_tarefa.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'suporte_de_tela.dart';

/// Nomes ficticios, como manda a regra 6.7 (LGPD): nenhum dado de pessoa real
/// entra em codigo, teste ou screenshot.
const String _ana = 'Ana Voluntaria';
const String _bruno = 'Bruno Horta';
const String _carla = 'Carla Mutirao';

final DateTime _base = DateTime(2026, 8, 26, 9);

/// O comeco da frase do estado vazio, para os testes nao repetirem o texto.
const String _tituloDoVazio = 'Nenhuma tarefa por aqui ainda';

Tarefa _tarefa(
  String titulo, {
  required Prioridade prioridade,
  String responsavel = _ana,
  Status status = Status.aFazer,
  Duration idade = Duration.zero,
  int? estimativa,
  String? descricao,
}) =>
    Tarefa(
      id: titulo,
      titulo: titulo,
      responsavel: responsavel,
      prioridade: prioridade,
      status: status,
      criadaEm: _base.add(idade),
      estimativaEmHoras: estimativa,
      descricao: descricao,
    );

/// As tres tarefas usadas na maioria dos testes, de proposito FORA de ordem.
final List<Tarefa> _tresTarefas = <Tarefa>[
  _tarefa('Comprar mudas para o mutirao', prioridade: Prioridade.baixa),
  _tarefa(
    'Consertar o portao do galpao',
    prioridade: Prioridade.alta,
    responsavel: _bruno,
    status: Status.fazendo,
    estimativa: 3,
  ),
  _tarefa(
    'Montar a lista de presenca',
    prioridade: Prioridade.media,
    responsavel: _carla,
  ),
];

Future<QuadroController> _quadroCom(List<Tarefa> tarefas) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final RepositorioDeTarefas repo =
      RepositorioDeTarefas(preferencias: await SharedPreferences.getInstance());
  await repo.salvar(tarefas);
  final QuadroController quadro = QuadroController(repositorio: repo);
  await quadro.carregar();
  return quadro;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TelaListaDeTarefas com tarefas', () {
    testWidgets('mostra as tarefas da mais urgente para a menos urgente',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaListaDeTarefas(),
        quadro: await _quadroCom(_tresTarefas),
      );

      final double alta =
          tester.getTopLeft(find.text('Consertar o portao do galpao')).dy;
      final double media =
          tester.getTopLeft(find.text('Montar a lista de presenca')).dy;
      final double baixa =
          tester.getTopLeft(find.text('Comprar mudas para o mutirao')).dy;

      expect(alta, lessThan(media));
      expect(media, lessThan(baixa));
    });

    testWidgets('a prioridade vem ESCRITA, e nao so em cor',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaListaDeTarefas(),
        quadro: await _quadroCom(_tresTarefas),
      );

      // Se alguem trocar a etiqueta por um simples ponto colorido, estes tres
      // expects falham — que e exatamente o ponto da regra 6.3.
      for (final Prioridade prioridade in Prioridade.values) {
        expect(
          find.text(prioridade.rotulo),
          findsOneWidget,
          reason: 'Quem nao distingue as cores precisa LER a prioridade.',
        );
      }
    });

    testWidgets('cada cartao diz de quem e a tarefa e em que coluna ela esta',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaListaDeTarefas(),
        quadro: await _quadroCom(_tresTarefas),
      );

      expect(find.text(_bruno), findsOneWidget);
      expect(find.text(Status.fazendo.rotulo), findsOneWidget);
      expect(find.text('3h'), findsOneWidget);
    });

    testWidgets('campo opcional vazio nao vira etiqueta vazia',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaListaDeTarefas(),
        quadro: await _quadroCom(<Tarefa>[
          _tarefa('Sem estimativa', prioridade: Prioridade.media),
        ]),
      );

      expect(find.byIcon(Icons.schedule), findsNothing);
    });

    testWidgets('explica por que a lista esta nesta ordem',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaListaDeTarefas(),
        quadro: await _quadroCom(_tresTarefas),
      );

      expect(find.textContaining('mais antiga vem primeiro'), findsOneWidget);
      expect(find.text('3 tarefas no quadro'), findsOneWidget);
    });

    testWidgets('uma tarefa so nao vira "1 tarefas"',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaListaDeTarefas(),
        quadro: await _quadroCom(<Tarefa>[
          _tarefa('Unica', prioridade: Prioridade.alta),
        ]),
      );

      expect(find.text('1 tarefa no quadro'), findsOneWidget);
    });

    testWidgets('titulo comprido quebra em vez de estourar a linha',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaListaDeTarefas(),
        tamanho: tamanhosDeTela['telefone pequeno (320 dp)'],
        quadro: await _quadroCom(<Tarefa>[
          _tarefa(
            'Organizar o mutirao de plantio de mudas nativas da encosta '
            'do morro com o pessoal do bairro inteiro',
            prioridade: Prioridade.alta,
            responsavel: 'Maria Aparecida dos Santos Voluntaria',
          ),
        ]),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('mantem folga maior que 0,5 dp entre cartoes vizinhos',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaListaDeTarefas(),
        quadro: await _quadroCom(_tresTarefas),
      );

      final double folga = folgaVertical(
        tester,
        find.byType(CartaoDeTarefa).at(0),
        find.byType(CartaoDeTarefa).at(1),
      );

      expect(
        folga,
        greaterThan(0.5),
        reason: 'Cartoes nao podem colar nem se sobrepor (regra 6.5).',
      );
    });

    testWidgets('mantem folga entre o titulo e as etiquetas do cartao',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaListaDeTarefas(),
        quadro: await _quadroCom(<Tarefa>[
          _tarefa('Unica', prioridade: Prioridade.alta),
        ]),
      );

      expect(
        folgaVertical(tester, find.text('Unica'), find.text('Alta')),
        greaterThan(0.5),
      );
    });

    testWidgets('o recado do quadro aparece na lista e da para dispensar',
        (WidgetTester tester) async {
      final QuadroController quadro = await _quadroCom(_tresTarefas);
      // Estourar o limite de WIP e a forma honesta de produzir um recado: e
      // uma regra de negocio de verdade, nao um campo forcado no teste.
      final QuadroController comAviso = quadro;
      for (final Tarefa t in <Tarefa>[
        _tarefa('WIP 1', prioridade: Prioridade.media, status: Status.fazendo),
        _tarefa('WIP 2', prioridade: Prioridade.media, status: Status.fazendo),
        _tarefa('WIP 3', prioridade: Prioridade.media, status: Status.fazendo),
        _tarefa('WIP 4', prioridade: Prioridade.media),
      ]) {
        await comAviso.adicionar(t);
      }
      await comAviso.avancar('WIP 4');

      await montarTela(tester, const TelaListaDeTarefas(), quadro: comAviso);

      expect(find.textContaining('limite combinado pelo time'), findsOneWidget);

      await tester.tap(find.text('Entendi'));
      await tester.pumpAndSettle();

      expect(find.textContaining('limite combinado pelo time'), findsNothing);
    });

    for (final MapEntry<String, Size> entrada in tamanhosDeTela.entries) {
      testWidgets('monta sem overflow em ${entrada.key}',
          (WidgetTester tester) async {
        await montarTela(
          tester,
          const TelaListaDeTarefas(),
          tamanho: entrada.value,
          quadro: await _quadroCom(_tresTarefas),
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(CartaoDeTarefa), findsWidgets);
      });
    }

    testWidgets('respeita fonte ampliada em 200% sem quebrar',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaListaDeTarefas(),
        tamanho: tamanhosDeTela['telefone pequeno (320 dp)'],
        escalaDeFonte: 2,
        quadro: await _quadroCom(_tresTarefas),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('passa nas diretrizes de acessibilidade do Flutter',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await montarTela(
        tester,
        const TelaListaDeTarefas(),
        quadro: await _quadroCom(_tresTarefas),
      );

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));

      handle.dispose();
    });

    testWidgets('o leitor de tela ouve "prioridade alta", e nao so "Alta"',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await montarTela(
        tester,
        const TelaListaDeTarefas(),
        quadro: await _quadroCom(_tresTarefas),
      );

      expect(find.bySemanticsLabel('Prioridade alta'), findsOneWidget);
      expect(find.bySemanticsLabel('Responsavel: $_bruno'), findsOneWidget);

      handle.dispose();
    });
  });

  group('TelaListaDeTarefas sem tarefas', () {
    testWidgets('explica o que fazer e traz o botao da acao',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaListaDeTarefas(),
        quadro: await _quadroCom(<Tarefa>[]),
      );

      // Regra 6.6: estado vazio nunca e um beco.
      expect(find.textContaining(_tituloDoVazio), findsOneWidget);
      expect(find.textContaining('aparece nesta lista'), findsOneWidget);
      expect(find.text('Nova tarefa'), findsOneWidget);
    });

    testWidgets('o botao do estado vazio abre o cadastro',
        (WidgetTester tester) async {
      await montarTela(
        tester,
        const TelaListaDeTarefas(),
        quadro: await _quadroCom(<Tarefa>[]),
      );

      await tester.tap(find.text('Nova tarefa'));
      await tester.pumpAndSettle();

      expect(find.text('Titulo da tarefa'), findsOneWidget);
    });

    for (final MapEntry<String, Size> entrada in tamanhosDeTela.entries) {
      testWidgets('estado vazio monta sem overflow em ${entrada.key}',
          (WidgetTester tester) async {
        await montarTela(
          tester,
          const TelaListaDeTarefas(),
          tamanho: entrada.value,
          escalaDeFonte: 2,
          quadro: await _quadroCom(<Tarefa>[]),
        );

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('estado vazio passa nas diretrizes de acessibilidade',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await montarTela(
        tester,
        const TelaListaDeTarefas(),
        quadro: await _quadroCom(<Tarefa>[]),
      );

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

      handle.dispose();
    });
  });

  group('TelaListaDeTarefas enquanto le o aparelho', () {
    testWidgets('mostra a flor girando em vez de dizer "nenhuma tarefa"',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      // Um repositorio que NUNCA termina de ler. Com o repositorio de verdade
      // a leitura acaba antes de a tela ser montada, e o estado "lendo" nunca
      // chegaria a aparecer no teste.
      final _RepositorioTravado travado = _RepositorioTravado(
        await SharedPreferences.getInstance(),
      );
      final QuadroController quadro = QuadroController(repositorio: travado);
      final Future<void> leitura = quadro.carregar();

      // aguardarEstabilizar: false porque a flor gira para sempre e o
      // pumpAndSettle esperaria a animacao acabar — ou seja, travaria.
      await montarTela(
        tester,
        const TelaListaDeTarefas(),
        quadro: quadro,
        aguardarEstabilizar: false,
      );

      expect(find.textContaining('Lendo as tarefas'), findsOneWidget);
      expect(
        find.textContaining(_tituloDoVazio),
        findsNothing,
        reason: 'Dizer "vazio" antes de terminar de ler seria mentira.',
      );

      travado.terminar();
      await leitura;
      await tester.pumpAndSettle();

      expect(find.textContaining(_tituloDoVazio), findsOneWidget);
    });
  });
}

/// Repositorio de teste cuja leitura so termina quando o teste mandar.
///
/// Serve para congelar o app no estado "lendo o aparelho" — o unico jeito de
/// conferir que a tela mostra a flor girando em vez de anunciar, cedo demais,
/// que nao ha tarefa nenhuma.
class _RepositorioTravado extends RepositorioDeTarefas {
  _RepositorioTravado(SharedPreferences preferencias)
      : super(preferencias: preferencias);

  final Completer<ResultadoDaCarga> _porta = Completer<ResultadoDaCarga>();

  @override
  Future<ResultadoDaCarga> carregar() => _porta.future;

  /// Libera a leitura, como se o aparelho tivesse respondido agora.
  void terminar() =>
      _porta.complete(const ResultadoDaCarga(tarefas: <Tarefa>[]));
}
