import '../../../data/leitura_json.dart';

/// Periodo de trabalho com inicio e fim, no sentido do Scrum.
///
/// O *Scrum Guide* define a Sprint como um evento de **duracao fixa, de um mes
/// ou menos**, e diz que e ela que "cria consistencia" (secao 2.1 do arquivo de
/// instrucoes). Aqui ela serve para o time ter um momento de "olha o que a
/// gente fez" — o que trabalho voluntario, sem fim de ciclo, costuma perder.
///
/// Uma tarefa pertence a **no maximo uma** sprint; sem sprint, ela fica no
/// backlog (regra de negocio 6).
///
/// A classe e **imutavel**: para mudar uma data, crie outra sprint com
/// [copyWith]. Assim nenhum canto do app altera a sprint por baixo dos panos.
class Sprint {
  /// Cria uma sprint. Todos os campos sao obrigatorios.
  const Sprint({
    required this.id,
    required this.nome,
    required this.inicio,
    required this.fim,
  });

  /// Identificador unico e estavel, usado pelas tarefas para apontar para ca.
  final String id;

  /// Como o time chama esta sprint. Ex.: 'Mutirao de outubro'.
  final String nome;

  /// Primeiro dia do periodo.
  final DateTime inicio;

  /// Ultimo dia do periodo.
  final DateTime fim;

  /// Numero maximo de dias que uma sprint pode ter.
  ///
  /// Vem do *Scrum Guide*: "um mes ou menos". 31 e o maior mes do calendario.
  static const int duracaoMaximaEmDias = 31;

  /// Quantos dias o periodo cobre, contando o primeiro e o ultimo.
  ///
  /// Uma sprint que comeca e termina no mesmo dia dura 1 dia, nao 0 — e por
  /// isso o `+ 1`.
  int get duracaoEmDias => fim.difference(inicio).inDays + 1;

  /// `true` quando o periodo faz sentido: termina depois de comecar e cabe no
  /// limite do Scrum.
  bool get periodoValido =>
      !fim.isBefore(inicio) && duracaoEmDias <= duracaoMaximaEmDias;

  /// `true` quando [dia] cai dentro do periodo (inclusive nas pontas).
  bool contem(DateTime dia) => !dia.isBefore(inicio) && !dia.isAfter(fim);

  /// Reconstroi uma sprint a partir do que foi gravado.
  factory Sprint.fromJson(Map<String, dynamic> dados) {
    return Sprint(
      id: textoObrigatorio(dados, 'id'),
      nome: textoObrigatorio(dados, 'nome'),
      inicio: dataObrigatoria(dados, 'inicio'),
      fim: dataObrigatoria(dados, 'fim'),
    );
  }

  /// Converte a sprint no mapa que vai para o disco.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nome': nome,
      'inicio': inicio.toIso8601String(),
      'fim': fim.toIso8601String(),
    };
  }

  /// Devolve uma copia desta sprint trocando so os campos informados.
  Sprint copyWith({
    String? id,
    String? nome,
    DateTime? inicio,
    DateTime? fim,
  }) {
    return Sprint(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      inicio: inicio ?? this.inicio,
      fim: fim ?? this.fim,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Sprint &&
        other.id == id &&
        other.nome == nome &&
        other.inicio == inicio &&
        other.fim == fim;
  }

  @override
  int get hashCode => Object.hash(id, nome, inicio, fim);

  @override
  String toString() => 'Sprint($id, $nome, $inicio -> $fim)';
}
