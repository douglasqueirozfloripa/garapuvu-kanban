import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:garapuvu_kanban/src/data/repositorio_de_tarefas.dart';
import 'package:garapuvu_kanban/src/features/board/model/prioridade.dart';
import 'package:garapuvu_kanban/src/features/board/model/status.dart';
import 'package:garapuvu_kanban/src/features/board/model/tarefa.dart';
import 'package:shared_preferences/shared_preferences.dart';

final DateTime _base = DateTime(2026, 8, 26, 9);

Tarefa _tarefa(String id, {Status status = Status.aFazer}) => Tarefa(
      id: id,
      titulo: 'Tarefa $id',
      responsavel: 'Ana Voluntaria',
      prioridade: Prioridade.media,
      status: status,
      criadaEm: _base,
    );

/// Monta um repositorio com o cofre do aparelho **em memoria**.
///
/// `setMockInitialValues` e o mock oficial do `shared_preferences`: nada toca o
/// disco, entao o teste roda em milissegundos e nao deixa sujeira entre um caso
/// e outro.
Future<RepositorioDeTarefas> _repositorioCom(
  Map<String, Object> valoresIniciais,
) async {
  SharedPreferences.setMockInitialValues(valoresIniciais);
  return RepositorioDeTarefas(
    preferencias: await SharedPreferences.getInstance(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('primeira vez que o app abre', () {
    test('sem nada gravado, devolve vazio e NAO avisa', () async {
      final RepositorioDeTarefas repo =
          await _repositorioCom(<String, Object>{});

      final ResultadoDaCarga r = await repo.carregar();

      expect(r.tarefas, isEmpty);
      expect(r.aviso, isNull, reason: 'quadro novo nao e problema');
      expect(r.houveProblema, isFalse);
    });

    test('texto gravado em branco tambem conta como vazio', () async {
      final RepositorioDeTarefas repo = await _repositorioCom(<String, Object>{
        'flutter.${RepositorioDeTarefas.chave}': '   ',
      });

      final ResultadoDaCarga r = await repo.carregar();

      expect(r.tarefas, isEmpty);
      expect(r.aviso, isNull);
    });
  });

  group('salvar e carregar', () {
    test('o que foi salvo volta igual', () async {
      final RepositorioDeTarefas repo =
          await _repositorioCom(<String, Object>{});
      final List<Tarefa> quadro = <Tarefa>[
        _tarefa('1'),
        _tarefa('2', status: Status.fazendo),
        _tarefa('3', status: Status.concluido),
      ];

      await repo.salvar(quadro);
      final ResultadoDaCarga r = await repo.carregar();

      expect(r.tarefas, quadro);
      expect(r.aviso, isNull);
    });

    test('salvar de novo SUBSTITUI, nao acumula', () async {
      final RepositorioDeTarefas repo =
          await _repositorioCom(<String, Object>{});

      await repo.salvar(<Tarefa>[_tarefa('1'), _tarefa('2')]);
      await repo.salvar(<Tarefa>[_tarefa('3')]);

      final ResultadoDaCarga r = await repo.carregar();
      expect(r.tarefas.map((Tarefa t) => t.id), <String>['3']);
    });

    test('salvar lista vazia deixa o quadro vazio', () async {
      final RepositorioDeTarefas repo =
          await _repositorioCom(<String, Object>{});

      await repo.salvar(<Tarefa>[_tarefa('1')]);
      await repo.salvar(<Tarefa>[]);

      expect((await repo.carregar()).tarefas, isEmpty);
    });

    test('grava sob uma chave versionada', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences cofre = await SharedPreferences.getInstance();
      await RepositorioDeTarefas(preferencias: cofre)
          .salvar(<Tarefa>[_tarefa('1')]);

      expect(RepositorioDeTarefas.chave, endsWith('.v1'));
      expect(cofre.getString(RepositorioDeTarefas.chave), isNotNull);
    });
  });

  group('dado corrompido: NUNCA crasha', () {
    test('texto que nao e JSON: vazio + aviso que explica o proximo passo',
        () async {
      final RepositorioDeTarefas repo = await _repositorioCom(<String, Object>{
        'flutter.${RepositorioDeTarefas.chave}': 'isto nao e json {{{',
      });

      final ResultadoDaCarga r = await repo.carregar();

      expect(r.tarefas, isEmpty);
      expect(r.houveProblema, isTrue);
      expect(r.aviso, contains('danificado'));
      expect(r.aviso, contains('criar as tarefas de novo'));
      expect(
        r.aviso,
        contains('nada foi enviado'),
        reason: 'a pessoa precisa saber que os dados nao vazaram (LGPD)',
      );
    });

    test('JSON valido mas que nao e lista: vazio + aviso', () async {
      final RepositorioDeTarefas repo = await _repositorioCom(<String, Object>{
        'flutter.${RepositorioDeTarefas.chave}': '{"tarefas": 42}',
      });

      final ResultadoDaCarga r = await repo.carregar();

      expect(r.tarefas, isEmpty);
      expect(r.aviso, contains('nao reconhece'));
    });

    test('UMA tarefa estragada no meio: as boas sao MANTIDAS', () async {
      // A decisao de projeto: descartar 2 tarefas boas por causa de 1 quebrada
      // seria pior do que o proprio defeito.
      final String texto = jsonEncode(<Object>[
        _tarefa('boa-1').toJson(),
        <String, dynamic>{'id': 'quebrada', 'titulo': 'sem responsavel'},
        _tarefa('boa-2').toJson(),
      ]);
      final RepositorioDeTarefas repo = await _repositorioCom(<String, Object>{
        'flutter.${RepositorioDeTarefas.chave}': texto,
      });

      final ResultadoDaCarga r = await repo.carregar();

      expect(r.tarefas.map((Tarefa t) => t.id), <String>['boa-1', 'boa-2']);
      expect(r.aviso, contains('1 tarefa'));
      expect(r.aviso, contains('demais foram carregadas'));
    });

    test('o aviso concorda em numero com quantas se perderam', () async {
      final String texto = jsonEncode(<Object>[
        <String, dynamic>{'id': 'x'},
        <String, dynamic>{'id': 'y'},
        _tarefa('boa').toJson(),
      ]);
      final RepositorioDeTarefas repo = await _repositorioCom(<String, Object>{
        'flutter.${RepositorioDeTarefas.chave}': texto,
      });

      final ResultadoDaCarga r = await repo.carregar();

      expect(r.tarefas.length, 1);
      expect(r.aviso, contains('2 tarefas'));
    });

    test('item que nem e objeto tambem e descartado sem crashar', () async {
      final RepositorioDeTarefas repo = await _repositorioCom(<String, Object>{
        'flutter.${RepositorioDeTarefas.chave}': '[1, "texto", null]',
      });

      final ResultadoDaCarga r = await repo.carregar();

      expect(r.tarefas, isEmpty);
      expect(r.aviso, contains('3 tarefas'));
    });
  });

  group('apagarTudo (LGPD)', () {
    test('remove a chave do aparelho', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences cofre = await SharedPreferences.getInstance();
      final RepositorioDeTarefas repo =
          RepositorioDeTarefas(preferencias: cofre);

      await repo.salvar(<Tarefa>[_tarefa('1')]);
      await repo.apagarTudo();

      expect(cofre.getString(RepositorioDeTarefas.chave), isNull);
      expect((await repo.carregar()).tarefas, isEmpty);
    });
  });
}
