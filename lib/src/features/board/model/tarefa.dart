import '../../../data/leitura_json.dart';
import 'prioridade.dart';
import 'status.dart';

/// Um card do quadro: uma coisa que alguem do time precisa fazer.
///
/// A classe e **imutavel** — nenhum campo muda depois de criada. Para "mover"
/// uma tarefa de coluna, gera-se uma copia com [copyWith]. O motivo e pratico:
/// com objetos imutaveis, nenhuma tela consegue alterar a tarefa por baixo dos
/// panos, e comparar o antes e o depois vira uma comparacao simples.
///
/// Campos obrigatorios e opcionais seguem a regra de negocio 5: titulo,
/// responsavel, prioridade e status sao obrigatorios; descricao e estimativa,
/// nao.
class Tarefa {
  /// Cria uma tarefa.
  ///
  /// O [titulo] deve passar por `validarTitulo` (em `regras_quadro.dart`)
  /// **antes** de chegar aqui: o modelo guarda o dado, quem julga se ele presta
  /// e a camada de regras.
  const Tarefa({
    required this.id,
    required this.titulo,
    required this.responsavel,
    required this.prioridade,
    required this.criadaEm,
    this.status = Status.aFazer,
    this.descricao,
    this.estimativaEmHoras,
    this.sprintId,
  });

  /// Identificador unico e estavel da tarefa.
  final String id;

  /// O que precisa ser feito, em uma linha.
  final String titulo;

  /// Quem se responsabilizou pela tarefa.
  ///
  /// E por pessoa que o limite de WIP e contado (regra de negocio 3).
  final String responsavel;

  /// O quanto a tarefa e urgente.
  final Prioridade prioridade;

  /// Em que coluna do quadro a tarefa esta agora.
  ///
  /// Toda tarefa nasce em [Status.aFazer] — dai o valor padrao.
  final Status status;

  /// Quando a tarefa foi criada.
  ///
  /// Serve de criterio de desempate na ordenacao: entre duas tarefas de mesma
  /// prioridade, a mais antiga vem primeiro (regra de negocio 4). Sem isso, a
  /// ordem de tarefas empatadas mudaria a cada abertura do app.
  final DateTime criadaEm;

  /// Detalhes que nao cabem no titulo. Opcional.
  final String? descricao;

  /// Chute de quantas horas o trabalho leva. Opcional.
  final int? estimativaEmHoras;

  /// A qual sprint a tarefa pertence, ou `null` se ela esta no backlog.
  ///
  /// Guarda o [Sprint.id] em vez do objeto inteiro para nao existirem duas
  /// copias da mesma sprint espalhadas pelo app.
  final String? sprintId;

  /// `true` quando a tarefa ainda nao entrou em nenhuma sprint.
  bool get estaNoBacklog => sprintId == null;

  /// `true` quando a tarefa chegou ao fim do quadro.
  bool get estaConcluida => status == Status.concluido;

  /// Reconstroi uma tarefa a partir do que foi gravado.
  ///
  /// Estoura [DadoInvalido] quando algum campo obrigatorio nao presta. Quem
  /// chama (o repositorio) decide o que fazer com a tarefa estragada — o modelo
  /// so diz que ela nao da para montar.
  ///
  /// Campos **opcionais** que vierem errados sao tratados com tolerancia
  /// diferente: [status] e [prioridade] desconhecidos caem no padrao, porque
  /// perder a tarefa inteira por causa de uma coluna com nome estranho seria
  /// pior do que ve-la reaparecer em "A fazer".
  factory Tarefa.fromJson(Map<String, dynamic> dados) {
    return Tarefa(
      id: textoObrigatorio(dados, 'id'),
      titulo: textoObrigatorio(dados, 'titulo'),
      responsavel: textoObrigatorio(dados, 'responsavel'),
      prioridade: Prioridade.porNome(dados['prioridade'] as String?) ??
          Prioridade.media,
      status: Status.porNome(dados['status'] as String?) ?? Status.aFazer,
      criadaEm: dataObrigatoria(dados, 'criadaEm'),
      descricao: textoOpcional(dados, 'descricao'),
      estimativaEmHoras: inteiroOpcional(dados, 'estimativaEmHoras'),
      sprintId: textoOpcional(dados, 'sprintId'),
    );
  }

  /// Converte a tarefa no mapa que vai para o disco.
  ///
  /// Os enums viram **nome** (`'fazendo'`) e nao posicao, e a data vira texto
  /// ISO 8601 — os dois motivos estao em [Status.porNome] e em
  /// [dataObrigatoria]. Campos opcionais vazios sao omitidos para o arquivo
  /// ficar menor e mais facil de ler quando alguem exportar os dados
  /// (Prompt 10).
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'titulo': titulo,
      'responsavel': responsavel,
      'prioridade': prioridade.name,
      'status': status.name,
      'criadaEm': criadaEm.toIso8601String(),
      if (descricao != null) 'descricao': descricao,
      if (estimativaEmHoras != null) 'estimativaEmHoras': estimativaEmHoras,
      if (sprintId != null) 'sprintId': sprintId,
    };
  }

  /// Devolve uma copia desta tarefa trocando so os campos informados.
  ///
  /// **Limitacao proposital:** passar `null` aqui significa "mantem como
  /// estava", entao este metodo nao consegue *apagar* um campo opcional. Para
  /// tirar a tarefa da sprint, use [semSprint], que diz o que faz.
  Tarefa copyWith({
    String? id,
    String? titulo,
    String? responsavel,
    Prioridade? prioridade,
    Status? status,
    DateTime? criadaEm,
    String? descricao,
    int? estimativaEmHoras,
    String? sprintId,
  }) {
    return Tarefa(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      responsavel: responsavel ?? this.responsavel,
      prioridade: prioridade ?? this.prioridade,
      status: status ?? this.status,
      criadaEm: criadaEm ?? this.criadaEm,
      descricao: descricao ?? this.descricao,
      estimativaEmHoras: estimativaEmHoras ?? this.estimativaEmHoras,
      sprintId: sprintId ?? this.sprintId,
    );
  }

  /// Devolve uma copia desta tarefa de volta ao backlog, fora de qualquer
  /// sprint (regra de negocio 6).
  Tarefa semSprint() {
    return Tarefa(
      id: id,
      titulo: titulo,
      responsavel: responsavel,
      prioridade: prioridade,
      status: status,
      criadaEm: criadaEm,
      descricao: descricao,
      estimativaEmHoras: estimativaEmHoras,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Tarefa &&
        other.id == id &&
        other.titulo == titulo &&
        other.responsavel == responsavel &&
        other.prioridade == prioridade &&
        other.status == status &&
        other.criadaEm == criadaEm &&
        other.descricao == descricao &&
        other.estimativaEmHoras == estimativaEmHoras &&
        other.sprintId == sprintId;
  }

  @override
  int get hashCode => Object.hash(
        id,
        titulo,
        responsavel,
        prioridade,
        status,
        criadaEm,
        descricao,
        estimativaEmHoras,
        sprintId,
      );

  @override
  String toString() =>
      'Tarefa($id, "$titulo", $responsavel, ${prioridade.rotulo}, '
      '${status.rotulo})';
}
