/// As regras do quadro Garapuvu, em Dart puro.
///
/// Este arquivo **nao importa Flutter** de proposito (regra de arquitetura da
/// secao 4 do arquivo de instrucoes): sao funcoes puras, que recebem dados e
/// devolvem dados, sem tocar em tela, disco ou relogio. Por isso rodam em
/// milissegundos no teste unitario e podem ser lidas por quem nao conhece
/// Flutter.
///
/// "Funcao pura" quer dizer duas coisas: para a mesma entrada ela sempre
/// devolve a mesma saida, e ela nao muda nada fora dela — nenhuma lista
/// recebida aqui e alterada no lugar.
library;

import 'status.dart';
import 'tarefa.dart';

/// Quantos cards uma mesma pessoa pode ter em [Status.fazendo] ao mesmo tempo.
///
/// Regra de negocio 3. O numero **3** nao e chute: a Lei de Little
/// (secao 2.3 do arquivo de instrucoes) diz que
/// `tempo de ciclo = WIP / vazao`. Com a vazao do time parada, dobrar o WIP
/// dobra o tempo que cada tarefa leva para terminar — sem ninguem ter ficado
/// mais lento.
const int limiteWipPorPessoa = 3;

/// Devolve a proxima coluna do quadro, ou `null` se [atual] ja e a ultima.
///
/// O card anda **uma coluna por vez**, sem pulo (regra de negocio 2). O `null`
/// e proposital: obriga quem chama a decidir o que fazer no fim do quadro, em
/// vez de devolver a mesma coluna e fingir que algo aconteceu.
Status? avancarStatus(Status atual) {
  if (!atual.temProxima) {
    return null;
  }
  return Status.values[atual.index + 1];
}

/// Devolve a coluna anterior do quadro, ou `null` se [atual] ja e a primeira.
///
/// Voltar e permitido e **nao e fracasso**: no Kanban, mover para tras e
/// informacao sobre o fluxo (a revisao pediu ajuste, por exemplo). Como no
/// avanco, e uma coluna por vez.
Status? voltarStatus(Status atual) {
  if (!atual.temAnterior) {
    return null;
  }
  return Status.values[atual.index - 1];
}

/// Devolve uma **nova** lista ordenada por prioridade (regra de negocio 4).
///
/// Criterios, nesta ordem:
///
/// 1. prioridade: `Alta`, depois `Media`, depois `Baixa`;
/// 2. em caso de empate, a tarefa **mais antiga** primeiro.
///
/// O desempate por data existe para a lista nao dancar: sem ele, duas tarefas
/// de mesma prioridade poderiam trocar de lugar a cada vez que a tela abre.
///
/// A lista recebida **nao e alterada** — `List.sort` mexeria no original, e um
/// canto do app mudaria a ordem de outro sem querer.
List<Tarefa> ordenarPorPrioridade(List<Tarefa> tarefas) {
  final List<Tarefa> copia = List<Tarefa>.of(tarefas);
  copia.sort((Tarefa a, Tarefa b) {
    final int porPrioridade = a.prioridade.index.compareTo(b.prioridade.index);
    if (porPrioridade != 0) {
      return porPrioridade;
    }
    return a.criadaEm.compareTo(b.criadaEm);
  });
  return copia;
}

/// Conta quantas tarefas [responsavel] tem em [Status.fazendo] agora.
int contarEmFazendo({
  required List<Tarefa> tarefasDoQuadro,
  required String responsavel,
}) {
  final String procurado = _normalizar(responsavel);
  return tarefasDoQuadro
      .where(
        (Tarefa tarefa) =>
            tarefa.status == Status.fazendo &&
            _normalizar(tarefa.responsavel) == procurado,
      )
      .length;
}

/// `true` quando [responsavel] ainda tem espaco para puxar mais uma tarefa
/// para [Status.fazendo].
///
/// E o **sistema puxado** do Kanban virando codigo: trabalho novo so entra se
/// houver capacidade. Compare com [limiteWipPorPessoa].
bool podeEntrarEmFazendo({
  required List<Tarefa> tarefasDoQuadro,
  required String responsavel,
}) {
  final int emAndamento = contarEmFazendo(
    tarefasDoQuadro: tarefasDoQuadro,
    responsavel: responsavel,
  );
  return emAndamento < limiteWipPorPessoa;
}

/// Explica, em portugues, por que o limite de WIP barrou a tarefa.
///
/// A regra de negocio 3 diz que o app "avisa **e explica o porquê**", e a
/// pratica 4 do Kanban exige politicas explicitas: bloquear em silencio
/// esconde a regra de quem precisa entende-la. Por isso a mensagem vem junto da
/// checagem, e nao espalhada pelas telas.
String motivoDoLimiteDeWip(String responsavel) {
  return '$responsavel ja tem $limiteWipPorPessoa tarefas em '
      '"${Status.fazendo.rotulo}", que e o limite combinado pelo time. '
      'Termine ou devolva uma delas antes de comecar outra: quanto mais '
      'coisas em andamento ao mesmo tempo, mais devagar cada uma acaba.';
}

/// Deixa o nome comparavel: sem espaco sobrando e sem diferenca de maiusculas.
///
/// Sem isso, 'Ana Voluntaria' e 'ana voluntaria ' contariam como duas pessoas
/// diferentes, e o limite de WIP deixaria passar o dobro de tarefas.
String _normalizar(String nome) => nome.trim().toLowerCase();
