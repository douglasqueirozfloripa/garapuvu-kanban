import 'package:flutter_test/flutter_test.dart';
import 'package:garapuvu_kanban/src/data/leitura_json.dart';
import 'package:garapuvu_kanban/src/features/board/model/prioridade.dart';
import 'package:garapuvu_kanban/src/features/board/model/sprint.dart';
import 'package:garapuvu_kanban/src/features/board/model/status.dart';
import 'package:garapuvu_kanban/src/features/board/model/tarefa.dart';

final DateTime _base = DateTime(2026, 8, 26, 9);

Tarefa _completa() => Tarefa(
      id: 't1',
      titulo: 'Levar doacoes ao galpao',
      responsavel: 'Ana Voluntaria',
      prioridade: Prioridade.alta,
      status: Status.emRevisao,
      criadaEm: _base,
      descricao: 'Combinar a chave com o Bruno Horta',
      estimativaEmHoras: 3,
      sprintId: 's1',
    );

void main() {
  group('Tarefa: ida e volta', () {
    test('uma tarefa completa volta identica', () {
      final Tarefa original = _completa();

      expect(Tarefa.fromJson(original.toJson()), original);
    });

    test('uma tarefa so com o obrigatorio volta identica', () {
      final Tarefa magra = Tarefa(
        id: 't2',
        titulo: 'Comprar tinta',
        responsavel: 'Carla Mutirao',
        prioridade: Prioridade.baixa,
        criadaEm: _base,
      );

      final Tarefa volta = Tarefa.fromJson(magra.toJson());

      expect(volta, magra);
      expect(volta.descricao, isNull);
      expect(volta.estimativaEmHoras, isNull);
      expect(volta.estaNoBacklog, isTrue);
    });

    test('campos opcionais vazios NAO ocupam espaco no arquivo', () {
      final Map<String, dynamic> json = Tarefa(
        id: 't3',
        titulo: 'Sem extras',
        responsavel: 'Ana Voluntaria',
        prioridade: Prioridade.media,
        criadaEm: _base,
      ).toJson();

      expect(json.containsKey('descricao'), isFalse);
      expect(json.containsKey('estimativaEmHoras'), isFalse);
      expect(json.containsKey('sprintId'), isFalse);
    });
  });

  group('Tarefa: o formato gravado', () {
    test('enums viram NOME, nunca posicao', () {
      final Map<String, dynamic> json = _completa().toJson();

      expect(json['status'], 'emRevisao');
      expect(json['prioridade'], 'alta');
      expect(json['status'], isNot(isA<int>()));
    });

    test('reordenar o enum NAO muda a coluna do que ja foi gravado', () {
      // Este e o motivo de gravar nome. Com posicao, mover 'fazendo' na
      // declaracao faria toda tarefa gravada mudar de coluna sozinha.
      final Map<String, dynamic> json = _completa().toJson();
      final int posicaoHoje = Status.emRevisao.index;

      expect(json['status'], 'emRevisao');
      expect(
        Tarefa.fromJson(json).status,
        Status.emRevisao,
        reason: 'a leitura usa o nome, nao a posicao $posicaoHoje',
      );
    });

    test('a data vira texto ISO 8601, que ordena igual a data', () {
      final Map<String, dynamic> json = _completa().toJson();

      expect(json['criadaEm'], '2026-08-26T09:00:00.000');
      expect(
        '2026-08-26T09:00:00.000'.compareTo('2026-08-27T09:00:00.000'),
        lessThan(0),
      );
    });
  });

  group('Tarefa: dado estragado', () {
    Map<String, dynamic> base() => _completa().toJson();

    test('campo obrigatorio ausente estoura DadoInvalido dizendo qual', () {
      for (final String campo in <String>[
        'id',
        'titulo',
        'responsavel',
        'criadaEm',
      ]) {
        final Map<String, dynamic> json = base()..remove(campo);

        expect(
          () => Tarefa.fromJson(json),
          throwsA(
            isA<DadoInvalido>()
                .having((DadoInvalido e) => e.campo, 'campo', campo),
          ),
          reason: 'sem "$campo" a tarefa nao da para montar',
        );
      }
    });

    test('titulo so com espacos conta como ausente', () {
      expect(
        () => Tarefa.fromJson(base()..['titulo'] = '   '),
        throwsA(isA<DadoInvalido>()),
      );
    });

    test('data que nao e data estoura, dizendo o formato esperado', () {
      expect(
        () => Tarefa.fromJson(base()..['criadaEm'] = 'ontem'),
        throwsA(
          isA<DadoInvalido>().having(
            (DadoInvalido e) => e.motivo,
            'motivo',
            contains('ISO 8601'),
          ),
        ),
      );
    });

    test('estimativa que nao e numero estoura', () {
      expect(
        () => Tarefa.fromJson(base()..['estimativaEmHoras'] = 'tres'),
        throwsA(isA<DadoInvalido>()),
      );
    });

    test('status desconhecido NAO perde a tarefa: cai em "A fazer"', () {
      // Tolerancia proposital: perder a tarefa inteira por causa de uma coluna
      // com nome estranho seria pior do que ve-la reaparecer em "A fazer".
      final Tarefa volta = Tarefa.fromJson(base()..['status'] = 'arquivado');

      expect(volta.status, Status.aFazer);
      expect(volta.titulo, 'Levar doacoes ao galpao');
    });

    test('prioridade desconhecida cai em "Media"', () {
      expect(
        Tarefa.fromJson(base()..['prioridade'] = 'urgentissima').prioridade,
        Prioridade.media,
      );
    });
  });

  group('Sprint', () {
    test('ida e volta preserva nome e periodo', () {
      final Sprint original = Sprint(
        id: 's1',
        nome: 'Mutirao de outubro',
        inicio: _base,
        fim: _base.add(const Duration(days: 13)),
      );

      expect(Sprint.fromJson(original.toJson()), original);
    });

    test('periodo faltando estoura DadoInvalido', () {
      expect(
        () => Sprint.fromJson(<String, dynamic>{'id': 's1', 'nome': 'X'}),
        throwsA(isA<DadoInvalido>()),
      );
    });
  });

  group('porNome', () {
    test('encontra todos os valores declarados', () {
      for (final Status s in Status.values) {
        expect(Status.porNome(s.name), s);
      }
      for (final Prioridade p in Prioridade.values) {
        expect(Prioridade.porNome(p.name), p);
      }
    });

    test('devolve null para nome desconhecido, vazio ou null', () {
      expect(Status.porNome('arquivado'), isNull);
      expect(Status.porNome(''), isNull);
      expect(Status.porNome(null), isNull);
      expect(Prioridade.porNome('urgentissima'), isNull);
    });
  });
}
