import 'package:flutter_test/flutter_test.dart';
import 'package:garapuvu_kanban/src/features/board/model/prioridade.dart';
import 'package:garapuvu_kanban/src/features/board/model/sprint.dart';
import 'package:garapuvu_kanban/src/features/board/model/status.dart';
import 'package:garapuvu_kanban/src/features/board/model/tarefa.dart';

final DateTime _base = DateTime(2026, 8, 26, 9);

Tarefa _tarefa() => Tarefa(
      id: 't1',
      titulo: 'Levar doacoes ao galpao',
      responsavel: 'Ana Voluntaria',
      prioridade: Prioridade.alta,
      criadaEm: _base,
    );

void main() {
  group('Status', () {
    test('tem as quatro colunas da regra de negocio, nesta ordem', () {
      expect(
        Status.values.map((Status s) => s.rotulo),
        <String>['A fazer', 'Fazendo', 'Em revisao', 'Concluido'],
      );
    });

    test('sabe quais sao as pontas do quadro', () {
      expect(Status.primeira, Status.aFazer);
      expect(Status.ultima, Status.concluido);
      expect(Status.aFazer.temAnterior, isFalse);
      expect(Status.concluido.temProxima, isFalse);
      expect(Status.fazendo.temAnterior, isTrue);
      expect(Status.fazendo.temProxima, isTrue);
    });
  });

  group('Prioridade', () {
    test('vai da mais urgente para a menos urgente', () {
      expect(
        Prioridade.values.map((Prioridade p) => p.rotulo),
        <String>['Alta', 'Media', 'Baixa'],
      );
      expect(Prioridade.alta.index, lessThan(Prioridade.baixa.index));
    });
  });

  group('Tarefa', () {
    test('nasce em "A fazer" e no backlog', () {
      final Tarefa tarefa = _tarefa();

      expect(tarefa.status, Status.aFazer);
      expect(tarefa.estaNoBacklog, isTrue);
      expect(tarefa.estaConcluida, isFalse);
    });

    test('copyWith troca so o campo pedido e nao mexe na original', () {
      final Tarefa original = _tarefa();
      final Tarefa movida = original.copyWith(status: Status.fazendo);

      expect(movida.status, Status.fazendo);
      expect(movida.titulo, original.titulo);
      expect(movida.id, original.id);
      expect(original.status, Status.aFazer, reason: 'a original mudou');
    });

    test('semSprint devolve a tarefa ao backlog', () {
      final Tarefa naSprint = _tarefa().copyWith(sprintId: 's1');

      expect(naSprint.estaNoBacklog, isFalse);
      expect(naSprint.semSprint().estaNoBacklog, isTrue);
      expect(naSprint.semSprint().titulo, naSprint.titulo);
    });

    test('duas tarefas com os mesmos dados sao iguais', () {
      expect(_tarefa(), _tarefa());
      expect(_tarefa().hashCode, _tarefa().hashCode);
      expect(_tarefa() == _tarefa().copyWith(titulo: 'Outro'), isFalse);
    });
  });

  group('Sprint', () {
    Sprint sprintDe(int dias) => Sprint(
          id: 's1',
          nome: 'Mutirao de outubro',
          inicio: _base,
          fim: _base.add(Duration(days: dias - 1)),
        );

    test('conta o primeiro e o ultimo dia', () {
      expect(sprintDe(1).duracaoEmDias, 1);
      expect(sprintDe(14).duracaoEmDias, 14);
    });

    test('respeita o limite de um mes do Scrum', () {
      expect(sprintDe(Sprint.duracaoMaximaEmDias).periodoValido, isTrue);
      expect(sprintDe(Sprint.duracaoMaximaEmDias + 1).periodoValido, isFalse);
    });

    test('periodo que termina antes de comecar e invalido', () {
      final Sprint invertida = Sprint(
        id: 's1',
        nome: 'Invertida',
        inicio: _base,
        fim: _base.subtract(const Duration(days: 1)),
      );

      expect(invertida.periodoValido, isFalse);
    });

    test('contem() inclui as duas pontas e exclui o que esta fora', () {
      final Sprint sprint = sprintDe(7);

      expect(sprint.contem(sprint.inicio), isTrue);
      expect(sprint.contem(sprint.fim), isTrue);
      expect(
        sprint.contem(sprint.inicio.subtract(const Duration(days: 1))),
        isFalse,
      );
      expect(
        sprint.contem(sprint.fim.add(const Duration(days: 1))),
        isFalse,
      );
    });
  });
}
