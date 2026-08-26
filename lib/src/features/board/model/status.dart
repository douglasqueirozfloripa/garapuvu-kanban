/// Em que ponto do quadro uma tarefa esta.
///
/// A **ordem de declaracao e a ordem das colunas**, da esquerda para a direita
/// (regra de negocio 1). As funcoes [avancarStatus] e [voltarStatus], em
/// `regras_quadro.dart`, dependem disso: mudar a ordem aqui muda o caminho que
/// a tarefa percorre no quadro.
enum Status {
  /// Ainda nao comecou. Toda tarefa nova nasce nesta coluna.
  aFazer('A fazer'),

  /// Alguem esta tocando a tarefa agora.
  ///
  /// E a unica coluna com limite de WIP (regra de negocio 3) — e o limite
  /// existe por causa da Lei de Little, explicada na secao 2.3 do arquivo de
  /// instrucoes: quanto mais tarefas em andamento, mais tempo cada uma leva
  /// para terminar.
  fazendo('Fazendo'),

  /// O trabalho acabou e espera a conferencia de outra pessoa.
  emRevisao('Em revisao'),

  /// Passou pela revisao. Fim do caminho.
  concluido('Concluido');

  const Status(this.rotulo);

  /// Texto exibido na tela, ja em portugues e pronto para quem usa o app.
  ///
  /// Existe para a interface nunca precisar traduzir o nome tecnico do enum
  /// (`aFazer` viraria "aFazer" na tela).
  final String rotulo;

  /// Encontra o status pelo [nome] tecnico, ou `null` se nao existir.
  ///
  /// Usado ao ler dados gravados. Guardamos o **nome** (`'fazendo'`) e nao a
  /// posicao (`1`): a ordem de declaracao e a regra de negocio e pode mudar, e
  /// aí toda tarefa gravada mudaria de coluna sozinha. Nome nao tem esse risco.
  ///
  /// Devolve `null` em vez de estourar porque quem le dado gravado precisa
  /// decidir o que fazer com lixo — e essa decisao e da camada `data/`.
  static Status? porNome(String? nome) {
    for (final Status status in Status.values) {
      if (status.name == nome) {
        return status;
      }
    }
    return null;
  }

  /// A primeira coluna do quadro, onde toda tarefa nova entra.
  static Status get primeira => Status.values.first;

  /// A ultima coluna do quadro.
  static Status get ultima => Status.values.last;

  /// `true` quando ainda existe coluna a direita desta.
  ///
  /// A tela usa isto para desabilitar o botao "avancar" em vez de deixar a
  /// pessoa clicar e nao acontecer nada (regra 6.6: nenhum beco sem saida).
  bool get temProxima => index < Status.values.length - 1;

  /// `true` quando ainda existe coluna a esquerda desta.
  bool get temAnterior => index > 0;
}
