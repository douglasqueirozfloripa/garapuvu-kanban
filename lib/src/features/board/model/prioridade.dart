/// O quanto uma tarefa e urgente (regra de negocio 4).
///
/// A **ordem de declaracao e a ordem de exibicao**: `alta` aparece antes de
/// `media`, que aparece antes de `baixa`. A funcao `ordenarPorPrioridade`, em
/// `regras_quadro.dart`, usa exatamente esta ordem.
enum Prioridade {
  /// Trava o trabalho de outra pessoa ou tem prazo curto.
  alta('Alta'),

  /// Importante, mas o time sobrevive se atrasar um pouco.
  media('Media'),

  /// Boa de fazer quando sobrar folego.
  baixa('Baixa');

  const Prioridade(this.rotulo);

  /// Texto exibido na tela, ja em portugues.
  final String rotulo;

  /// Encontra a prioridade pelo [nome] tecnico, ou `null` se nao existir.
  ///
  /// Como em [Status.porNome], gravamos o nome e nao a posicao.
  static Prioridade? porNome(String? nome) {
    for (final Prioridade prioridade in Prioridade.values) {
      if (prioridade.name == nome) {
        return prioridade;
      }
    }
    return null;
  }
}
