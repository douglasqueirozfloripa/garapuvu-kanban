import 'package:flutter_test/flutter_test.dart';
import 'package:garapuvu_kanban/src/data/repositorio_de_tarefas.dart';
import 'package:garapuvu_kanban/src/features/board/model/prioridade.dart';
import 'package:garapuvu_kanban/src/features/board/model/regras_quadro.dart';
import 'package:garapuvu_kanban/src/features/board/model/status.dart';
import 'package:garapuvu_kanban/src/features/board/model/tarefa.dart';
import 'package:garapuvu_kanban/src/features/board/state/quadro_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

final DateTime _base = DateTime(2026, 8, 26, 9);

/// Idade da tarefa em dias, para as chamadas de teste caberem numa linha.
Duration _dias(int quantos) => Duration(days: quantos);

/// Apelido curto para a ultima coluna, pelo mesmo motivo de [_dias].
const Status _fim = Status.concluido;

Tarefa _tarefa(
  String id, {
  Status status = Status.aFazer,
  String responsavel = 'Ana Voluntaria',
  Prioridade prioridade = Prioridade.media,
  Duration idade = Duration.zero,
}) =>
    Tarefa(
      id: id,
      titulo: 'Tarefa $id',
      responsavel: responsavel,
      prioridade: prioridade,
      status: status,
      criadaEm: _base.add(idade),
    );

Future<QuadroController> _controller({
  List<Tarefa> jaGravadas = const <Tarefa>[],
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final RepositorioDeTarefas repo =
      RepositorioDeTarefas(preferencias: await SharedPreferences.getInstance());
  if (jaGravadas.isNotEmpty) {
    await repo.salvar(jaGravadas);
  }
  return QuadroController(repositorio: repo);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('carregar', () {
    test('traz o que estava gravado no aparelho', () async {
      final QuadroController c = await _controller(
        jaGravadas: <Tarefa>[
          _tarefa('1'),
          _tarefa('2', status: Status.fazendo),
        ],
      );

      expect(c.tarefas, isEmpty, reason: 'antes de carregar, o quadro e vazio');
      await c.carregar();

      expect(c.tarefas.map((Tarefa t) => t.id), <String>['1', '2']);
      expect(c.aviso, isNull);
      expect(c.carregando, isFalse);
    });

    test('avisa os ouvintes e sinaliza "carregando" no meio do caminho',
        () async {
      final QuadroController c =
          await _controller(jaGravadas: <Tarefa>[_tarefa('1')]);
      final List<bool> estados = <bool>[];
      c.addListener(() => estados.add(c.carregando));

      await c.carregar();

      expect(
        estados,
        <bool>[true, false],
        reason: 'a tela precisa poder mostrar a flor girando e depois some-la',
      );
    });

    test('dado danificado: quadro vazio e aviso, sem estourar', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'flutter.${RepositorioDeTarefas.chave}': 'lixo {{{',
      });
      final QuadroController c = QuadroController(
        repositorio: RepositorioDeTarefas(
          preferencias: await SharedPreferences.getInstance(),
        ),
      );

      await c.carregar();

      expect(c.tarefas, isEmpty);
      expect(c.aviso, contains('danificado'));
    });
  });

  group('adicionar e remover', () {
    test('a tarefa nova sobrevive a fechar e reabrir o app', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences cofre = await SharedPreferences.getInstance();

      // "Sessao" 1: cria a tarefa.
      final QuadroController primeira = QuadroController(
        repositorio: RepositorioDeTarefas(preferencias: cofre),
      );
      await primeira.carregar();
      await primeira.adicionar(_tarefa('t1'));

      // "Sessao" 2: o app abriu de novo, com um controller zerado.
      final QuadroController segunda = QuadroController(
        repositorio: RepositorioDeTarefas(preferencias: cofre),
      );
      await segunda.carregar();

      expect(segunda.tarefas.map((Tarefa t) => t.id), <String>['t1']);
    });

    test('remover tira do quadro e do aparelho', () async {
      final QuadroController c = await _controller();
      await c.adicionar(_tarefa('1'));
      await c.adicionar(_tarefa('2'));

      await c.remover('1');

      expect(c.tarefas.map((Tarefa t) => t.id), <String>['2']);
      final QuadroController outra = QuadroController(
        repositorio: RepositorioDeTarefas(
          preferencias: await SharedPreferences.getInstance(),
        ),
      );
      await outra.carregar();
      expect(outra.tarefas.map((Tarefa t) => t.id), <String>['2']);
    });

    test('remover id que nao existe nao quebra nem apaga nada', () async {
      final QuadroController c = await _controller();
      await c.adicionar(_tarefa('1'));

      await c.remover('nao-existe');

      expect(c.tarefas.length, 1);
    });

    test('a lista devolvida NAO pode ser alterada por fora', () async {
      final QuadroController c = await _controller();
      await c.adicionar(_tarefa('1'));

      expect(() => c.tarefas.add(_tarefa('2')), throwsUnsupportedError);
      expect(c.tarefas.length, 1);
    });
  });

  group('avancar', () {
    test('anda uma coluna e grava', () async {
      final QuadroController c = await _controller();
      await c.adicionar(_tarefa('1'));

      expect(await c.avancar('1'), isTrue);
      expect(c.tarefas.single.status, Status.fazendo);
    });

    test('na ultima coluna devolve false e nao muda nada', () async {
      final QuadroController c = await _controller();
      await c.adicionar(_tarefa('1', status: Status.concluido));

      expect(await c.avancar('1'), isFalse);
      expect(c.tarefas.single.status, Status.concluido);
    });

    test('id inexistente devolve false', () async {
      final QuadroController c = await _controller();

      expect(await c.avancar('fantasma'), isFalse);
    });

    test('BARRA a quarta tarefa em Fazendo e explica o porque', () async {
      final QuadroController c = await _controller();
      for (int i = 0; i < limiteWipPorPessoa; i++) {
        await c.adicionar(_tarefa('em-andamento-$i', status: Status.fazendo));
      }
      await c.adicionar(_tarefa('a-quarta'));

      expect(await c.avancar('a-quarta'), isFalse);
      expect(
        c.tarefas.last.status,
        Status.aFazer,
        reason: 'nao pode ter movido',
      );
      expect(c.aviso, contains('Ana Voluntaria'));
      expect(c.aviso, contains('Termine ou devolva'));
    });

    test('o limite e por pessoa: outra pessoa passa', () async {
      final QuadroController c = await _controller();
      for (int i = 0; i < limiteWipPorPessoa; i++) {
        await c.adicionar(_tarefa('ana-$i', status: Status.fazendo));
      }
      await c.adicionar(_tarefa('bruno', responsavel: 'Bruno Horta'));

      expect(await c.avancar('bruno'), isTrue);
      expect(c.aviso, isNull);
    });

    test('avancar de Fazendo para Em revisao NAO passa pelo limite', () async {
      final QuadroController c = await _controller();
      for (int i = 0; i < limiteWipPorPessoa; i++) {
        await c.adicionar(_tarefa('ana-$i', status: Status.fazendo));
      }

      // Ela esta no limite, mas TIRAR trabalho de andamento nunca e bloqueado.
      expect(await c.avancar('ana-0'), isTrue);
      expect(c.tarefas.first.status, Status.emRevisao);
    });
  });

  group('voltar', () {
    test('volta uma coluna', () async {
      final QuadroController c = await _controller();
      await c.adicionar(_tarefa('1', status: Status.emRevisao));

      expect(await c.voltar('1'), isTrue);
      expect(c.tarefas.single.status, Status.fazendo);
    });

    test('na primeira coluna devolve false', () async {
      final QuadroController c = await _controller();
      await c.adicionar(_tarefa('1'));

      expect(await c.voltar('1'), isFalse);
      expect(c.tarefas.single.status, Status.aFazer);
    });

    test('sair de Fazendo NUNCA e bloqueado, mesmo no limite', () async {
      final QuadroController c = await _controller();
      for (int i = 0; i < limiteWipPorPessoa; i++) {
        await c.adicionar(_tarefa('ana-$i', status: Status.fazendo));
      }

      expect(
        await c.voltar('ana-0'),
        isTrue,
        reason: 'tirar trabalho de cima de alguem nao pode ser barrado',
      );
      expect(c.tarefas.first.status, Status.aFazer);
    });

    test('voltar PARA Fazendo respeita o limite (senao seria porta dos fundos)',
        () async {
      final QuadroController c = await _controller();
      for (int i = 0; i < limiteWipPorPessoa; i++) {
        await c.adicionar(_tarefa('ana-$i', status: Status.fazendo));
      }
      await c.adicionar(_tarefa('em-revisao', status: Status.emRevisao));

      expect(await c.voltar('em-revisao'), isFalse);
      expect(c.tarefas.last.status, Status.emRevisao);
      expect(c.aviso, isNotNull);
    });
  });

  group('daColuna', () {
    test('filtra pela coluna e ordena por prioridade', () async {
      final QuadroController c = await _controller();
      await c.adicionar(_tarefa('baixa', prioridade: Prioridade.baixa));
      await c.adicionar(_tarefa('alta', prioridade: Prioridade.alta));
      await c.adicionar(_tarefa('media', prioridade: Prioridade.media));
      await c.adicionar(_tarefa('outra-coluna', status: Status.concluido));

      expect(
        c.daColuna(Status.aFazer).map((Tarefa t) => t.id),
        <String>['alta', 'media', 'baixa'],
      );
      expect(
        c.daColuna(Status.concluido).map((Tarefa t) => t.id),
        <String>['outra-coluna'],
      );
      expect(c.daColuna(Status.emRevisao), isEmpty);
    });
  });

  group('aviso', () {
    test('limparAviso apaga o recado e avisa a tela', () async {
      final QuadroController c = await _controller();
      for (int i = 0; i < limiteWipPorPessoa; i++) {
        await c.adicionar(_tarefa('ana-$i', status: Status.fazendo));
      }
      await c.adicionar(_tarefa('quarta'));
      await c.avancar('quarta');
      expect(c.aviso, isNotNull);

      int avisos = 0;
      c.addListener(() => avisos++);
      c.limparAviso();

      expect(c.aviso, isNull);
      expect(avisos, 1);
    });

    test('limparAviso sem recado nao avisa a tela a toa', () async {
      final QuadroController c = await _controller();
      int avisos = 0;
      c.addListener(() => avisos++);

      c.limparAviso();

      expect(avisos, 0);
    });

    test('uma acao bem-sucedida limpa o recado antigo', () async {
      final QuadroController c = await _controller();
      for (int i = 0; i < limiteWipPorPessoa; i++) {
        await c.adicionar(_tarefa('ana-$i', status: Status.fazendo));
      }
      await c.adicionar(_tarefa('quarta'));
      await c.avancar('quarta');
      expect(c.aviso, isNotNull);

      await c.voltar('ana-0');

      expect(c.aviso, isNull);
    });
  });

  group('apagarTudo (LGPD)', () {
    test('esvazia o quadro e o aparelho', () async {
      final QuadroController c = await _controller();
      await c.adicionar(_tarefa('1'));
      await c.adicionar(_tarefa('2'));

      await c.apagarTudo();

      expect(c.tarefas, isEmpty);
      final QuadroController outra = QuadroController(
        repositorio: RepositorioDeTarefas(
          preferencias: await SharedPreferences.getInstance(),
        ),
      );
      await outra.carregar();
      expect(outra.tarefas, isEmpty);
    });
  });

  // A ordem da lista e a regra de negocio 4. Ela ja e testada em Dart puro
  // (regras_quadro_test.dart); aqui o que se testa e o CONTRATO do controller:
  // que a tela recebe a lista ja ordenada e nao precisa ordenar de novo.
  group('emOrdemDePrioridade', () {
    test('poe as urgentes primeiro, atravessando as colunas', () async {
      final QuadroController c = await _controller(
        jaGravadas: <Tarefa>[
          _tarefa('baixa', prioridade: Prioridade.baixa),
          _tarefa('alta-fim', prioridade: Prioridade.alta, status: _fim),
          _tarefa('media', prioridade: Prioridade.media),
        ],
      );
      await c.carregar();

      expect(
        c.emOrdemDePrioridade.map((Tarefa t) => t.id).toList(),
        <String>['alta-fim', 'media', 'baixa'],
        reason:
            'A pergunta e "o que e mais urgente", nao "em que coluna esta": '
            'uma tarefa alta continua no topo mesmo ja concluida.',
      );
    });

    test('no empate de prioridade, a mais antiga vem primeiro', () async {
      final QuadroController c = await _controller(
        jaGravadas: <Tarefa>[
          _tarefa('nova', prioridade: Prioridade.alta, idade: _dias(2)),
          _tarefa('antiga', prioridade: Prioridade.alta),
          _tarefa('meio', prioridade: Prioridade.alta, idade: _dias(1)),
        ],
      );
      await c.carregar();

      expect(
        c.emOrdemDePrioridade.map((Tarefa t) => t.id).toList(),
        <String>['antiga', 'meio', 'nova'],
        reason: 'Sem o desempate por data, a lista trocaria de ordem sozinha '
            'a cada vez que o app abrisse.',
      );
    });

    test('sem tarefas, devolve lista vazia em vez de estourar', () async {
      final QuadroController c = await _controller();
      await c.carregar();

      expect(c.emOrdemDePrioridade, isEmpty);
    });

    test('ordenar nao reordena o quadro por baixo dos panos', () async {
      final QuadroController c = await _controller(
        jaGravadas: <Tarefa>[
          _tarefa('baixa', prioridade: Prioridade.baixa),
          _tarefa('alta', prioridade: Prioridade.alta),
        ],
      );
      await c.carregar();

      final List<String> antes = c.tarefas.map((Tarefa t) => t.id).toList();
      c.emOrdemDePrioridade;

      expect(
        c.tarefas.map((Tarefa t) => t.id).toList(),
        antes,
        reason: 'Ler a lista ordenada nao pode mexer na lista guardada: '
            'ordenar no lugar faria uma tela mudar a ordem de outra.',
      );
    });

    test('a lista devolvida acompanha a tarefa recem-criada', () async {
      final QuadroController c = await _controller();
      await c.carregar();
      await c.adicionar(_tarefa('nova', prioridade: Prioridade.alta));

      expect(c.emOrdemDePrioridade.single.id, 'nova');
    });
  });
}
