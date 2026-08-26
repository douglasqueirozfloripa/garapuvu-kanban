import 'package:flutter_test/flutter_test.dart';
import 'package:garapuvu_kanban/src/features/board/model/prioridade.dart';
import 'package:garapuvu_kanban/src/features/board/model/regras_quadro.dart';
import 'package:garapuvu_kanban/src/features/board/model/validacoes.dart';
import 'package:garapuvu_kanban/src/features/board/model/status.dart';
import 'package:garapuvu_kanban/src/features/board/model/tarefa.dart';

/// Data fixa para os testes nao dependerem do relogio.
///
/// Se usassemos `DateTime.now()`, o mesmo teste passaria hoje e poderia falhar
/// amanha. Aqui a data e sempre a mesma, entao o resultado tambem e.
final DateTime _base = DateTime(2026, 8, 26, 9);

/// Cria uma tarefa de teste com nomes ficticios (regra 6.7: nada de dado real).
Tarefa _tarefa({
  required String id,
  String titulo = 'Levar doacoes ao galpao',
  String responsavel = 'Ana Voluntaria',
  Prioridade prioridade = Prioridade.media,
  Status status = Status.aFazer,
  Duration idade = Duration.zero,
}) {
  return Tarefa(
    id: id,
    titulo: titulo,
    responsavel: responsavel,
    prioridade: prioridade,
    status: status,
    criadaEm: _base.add(idade),
  );
}

void main() {
  group('avancarStatus', () {
    test('anda uma coluna por vez, sem pular nenhuma', () {
      expect(avancarStatus(Status.aFazer), Status.fazendo);
      expect(avancarStatus(Status.fazendo), Status.emRevisao);
      expect(avancarStatus(Status.emRevisao), Status.concluido);
    });

    test('na ULTIMA coluna devolve null em vez de repetir o status', () {
      expect(Status.concluido, Status.ultima);
      expect(avancarStatus(Status.concluido), isNull);
    });

    test('percorre o quadro inteiro em exatamente 3 passos', () {
      Status atual = Status.primeira;
      int passos = 0;
      while (avancarStatus(atual) != null) {
        atual = avancarStatus(atual)!;
        passos++;
      }
      expect(atual, Status.ultima);
      expect(passos, Status.values.length - 1);
    });
  });

  group('voltarStatus', () {
    test('volta uma coluna por vez', () {
      expect(voltarStatus(Status.concluido), Status.emRevisao);
      expect(voltarStatus(Status.emRevisao), Status.fazendo);
      expect(voltarStatus(Status.fazendo), Status.aFazer);
    });

    test('na PRIMEIRA coluna devolve null', () {
      expect(Status.aFazer, Status.primeira);
      expect(voltarStatus(Status.aFazer), isNull);
    });

    test('desfaz exatamente o que avancarStatus fez', () {
      for (final Status status in Status.values) {
        final Status? proximo = avancarStatus(status);
        if (proximo != null) {
          expect(voltarStatus(proximo), status);
        }
      }
    });
  });

  group('ordenarPorPrioridade', () {
    test('poe Alta antes de Media, e Media antes de Baixa', () {
      final List<Tarefa> ordenada = ordenarPorPrioridade(<Tarefa>[
        _tarefa(id: 'baixa', prioridade: Prioridade.baixa),
        _tarefa(id: 'alta', prioridade: Prioridade.alta),
        _tarefa(id: 'media', prioridade: Prioridade.media),
      ]);

      expect(
        ordenada.map((Tarefa t) => t.id),
        <String>['alta', 'media', 'baixa'],
      );
    });

    test('no EMPATE de prioridade, a mais antiga vem primeiro', () {
      final List<Tarefa> ordenada = ordenarPorPrioridade(<Tarefa>[
        _tarefa(
          id: 'nova',
          prioridade: Prioridade.alta,
          idade: const Duration(days: 2),
        ),
        _tarefa(
          id: 'antiga',
          prioridade: Prioridade.alta,
        ),
        _tarefa(
          id: 'do meio',
          prioridade: Prioridade.alta,
          idade: const Duration(days: 1),
        ),
      ]);

      expect(
        ordenada.map((Tarefa t) => t.id),
        <String>['antiga', 'do meio', 'nova'],
      );
    });

    test('NAO altera a lista recebida', () {
      final List<Tarefa> original = <Tarefa>[
        _tarefa(id: 'baixa', prioridade: Prioridade.baixa),
        _tarefa(id: 'alta', prioridade: Prioridade.alta),
      ];

      ordenarPorPrioridade(original);

      expect(original.first.id, 'baixa', reason: 'a original mudou de ordem');
    });

    test('lista vazia continua vazia, sem estourar', () {
      expect(ordenarPorPrioridade(<Tarefa>[]), isEmpty);
    });
  });

  group('podeEntrarEmFazendo (limite de WIP)', () {
    List<Tarefa> emFazendo(int quantas, {String de = 'Ana Voluntaria'}) {
      return <Tarefa>[
        for (int i = 0; i < quantas; i++)
          _tarefa(id: '$de-$i', responsavel: de, status: Status.fazendo),
      ];
    }

    test('quadro vazio: pode comecar', () {
      expect(
        podeEntrarEmFazendo(
          tarefasDoQuadro: <Tarefa>[],
          responsavel: 'Ana Voluntaria',
        ),
        isTrue,
      );
    });

    test('com 2 tarefas (abaixo do limite): ainda pode', () {
      expect(
        podeEntrarEmFazendo(
          tarefasDoQuadro: emFazendo(2),
          responsavel: 'Ana Voluntaria',
        ),
        isTrue,
      );
    });

    test('NO limite (3 tarefas): nao pode mais', () {
      expect(limiteWipPorPessoa, 3);
      expect(
        podeEntrarEmFazendo(
          tarefasDoQuadro: emFazendo(limiteWipPorPessoa),
          responsavel: 'Ana Voluntaria',
        ),
        isFalse,
      );
    });

    test('ESTOURADO (4 tarefas): continua barrando', () {
      expect(
        podeEntrarEmFazendo(
          tarefasDoQuadro: emFazendo(limiteWipPorPessoa + 1),
          responsavel: 'Ana Voluntaria',
        ),
        isFalse,
      );
    });

    test('o limite e POR PESSOA: a lotacao de uma nao barra a outra', () {
      final List<Tarefa> quadro = emFazendo(limiteWipPorPessoa);

      expect(
        podeEntrarEmFazendo(
          tarefasDoQuadro: quadro,
          responsavel: 'Ana Voluntaria',
        ),
        isFalse,
      );
      expect(
        podeEntrarEmFazendo(
          tarefasDoQuadro: quadro,
          responsavel: 'Bruno Horta',
        ),
        isTrue,
      );
    });

    test('so conta a coluna Fazendo, nao o quadro inteiro', () {
      final List<Tarefa> quadro = <Tarefa>[
        _tarefa(id: '1', status: Status.aFazer),
        _tarefa(id: '2', status: Status.emRevisao),
        _tarefa(id: '3', status: Status.concluido),
        _tarefa(id: '4', status: Status.fazendo),
      ];

      expect(
        contarEmFazendo(
          tarefasDoQuadro: quadro,
          responsavel: 'Ana Voluntaria',
        ),
        1,
      );
    });

    test(
        'nome com espaco sobrando ou caixa diferente conta como a MESMA '
        'pessoa', () {
      final List<Tarefa> quadro = <Tarefa>[
        _tarefa(id: '1', responsavel: 'Ana Voluntaria', status: Status.fazendo),
        _tarefa(id: '2', responsavel: 'ana voluntaria', status: Status.fazendo),
        _tarefa(
          id: '3',
          responsavel: '  Ana Voluntaria  ',
          status: Status.fazendo,
        ),
      ];

      expect(
        contarEmFazendo(
          tarefasDoQuadro: quadro,
          responsavel: 'ANA VOLUNTARIA',
        ),
        limiteWipPorPessoa,
      );
      expect(
        podeEntrarEmFazendo(
          tarefasDoQuadro: quadro,
          responsavel: 'Ana Voluntaria',
        ),
        isFalse,
      );
    });

    test('o aviso explica o porque e diz o proximo passo', () {
      final String aviso = motivoDoLimiteDeWip('Ana Voluntaria');

      expect(aviso, contains('Ana Voluntaria'));
      expect(aviso, contains('$limiteWipPorPessoa'));
      expect(aviso, contains('Fazendo'));
      expect(aviso, contains('Termine ou devolva'));
    });
  });

  group('validarResponsavel', () {
    test('nome preenchido passa', () {
      expect(validarResponsavel('Ana Voluntaria'), isNull);
    });

    test('vazio, so-espacos e null sao recusados', () {
      expect(validarResponsavel(''), contains('Diga quem vai fazer'));
      expect(validarResponsavel('   '), contains('Diga quem vai fazer'));
      expect(validarResponsavel(null), contains('Diga quem vai fazer'));
    });
  });

  group('validarEstimativa', () {
    test('em branco passa: a estimativa e OPCIONAL', () {
      expect(validarEstimativa(''), isNull);
      expect(validarEstimativa('   '), isNull);
      expect(validarEstimativa(null), isNull);
    });

    test('numero inteiro positivo passa', () {
      expect(validarEstimativa('3'), isNull);
      expect(validarEstimativa(' 8 '), isNull);
      expect(validarEstimativa('$estimativaMaximaEmHoras'), isNull);
    });

    test('texto que nao e numero e recusado', () {
      expect(validarEstimativa('tres'), contains('numero de horas'));
      expect(validarEstimativa('3,5'), contains('numero de horas'));
    });

    test('zero e negativo sao recusados', () {
      expect(validarEstimativa('0'), contains('maior que zero'));
      expect(validarEstimativa('-2'), contains('maior que zero'));
    });

    test('acima do maximo manda quebrar a tarefa', () {
      expect(
        validarEstimativa('${estimativaMaximaEmHoras + 1}'),
        contains('Quebre em tarefas menores'),
      );
    });
  });

  group('validarTitulo', () {
    test('titulo bom passa (devolve null)', () {
      expect(validarTitulo('Levar doacoes ao galpao'), isNull);
    });

    test('VAZIO e so-espacos sao recusados com a mesma explicacao', () {
      expect(validarTitulo(''), contains('Escreva um titulo'));
      expect(validarTitulo('     '), contains('Escreva um titulo'));
      expect(validarTitulo(null), contains('Escreva um titulo'));
    });

    test('CURTO demais (2 caracteres) e recusado', () {
      expect(validarTitulo('Oi'), contains('curto demais'));
    });

    test('no minimo exato (3 caracteres) passa', () {
      expect(validarTitulo('Pao'), isNull);
      expect(tamanhoMinimoDoTitulo, 3);
    });

    test('no maximo exato (80 caracteres) passa', () {
      final String titulo = 'a' * tamanhoMaximoDoTitulo;

      expect(titulo.length, 80);
      expect(validarTitulo(titulo), isNull);
    });

    test('LONGO demais (81 caracteres) e recusado e diz o tamanho atual', () {
      final String titulo = 'a' * (tamanhoMaximoDoTitulo + 1);
      final String? erro = validarTitulo(titulo);

      expect(erro, contains('$tamanhoMaximoDoTitulo'));
      expect(erro, contains('81'));
    });

    test('espaco das pontas nao conta no tamanho', () {
      expect(validarTitulo('   Pao   '), isNull);
      expect(validarTitulo('  Oi  '), contains('curto demais'));
    });
  });
}
