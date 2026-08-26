/// Leitura defensiva de dados gravados.
///
/// Tudo que vem do disco e **suspeito**: pode ter sido gravado por uma versao
/// antiga do app, editado na mao, ou truncado por falta de espaco. Estas
/// funcoes leem cada campo checando o tipo e, quando algo nao presta, estouram
/// uma [DadoInvalido] dizendo **qual campo** e **o que se esperava** — em vez
/// de devolver `null` silencioso, que viraria um bug tres camadas adiante.
///
/// Quem chama (o repositorio) captura a excecao e decide o que fazer; o modelo
/// so precisa dizer o que espera.
library;

/// Um campo gravado que nao pode ser lido.
///
/// E [Exception] e nao [Error] de proposito: dado corrompido no disco e uma
/// situacao **esperada** (regra do Prompt 4: nunca crashar), nao um erro de
/// programacao.
class DadoInvalido implements Exception {
  /// Cria a excecao descrevendo o problema.
  const DadoInvalido(this.campo, this.motivo);

  /// Qual campo do JSON estava errado.
  final String campo;

  /// O que se esperava encontrar.
  final String motivo;

  @override
  String toString() => 'DadoInvalido: o campo "$campo" $motivo.';
}

/// Le um texto obrigatorio e nao vazio.
String textoObrigatorio(Map<String, dynamic> dados, String campo) {
  final Object? valor = dados[campo];
  if (valor is! String || valor.trim().isEmpty) {
    throw DadoInvalido(campo, 'precisa ser um texto preenchido');
  }
  return valor;
}

/// Le um texto que pode estar ausente. Texto vazio conta como ausente.
String? textoOpcional(Map<String, dynamic> dados, String campo) {
  final Object? valor = dados[campo];
  if (valor is! String || valor.trim().isEmpty) {
    return null;
  }
  return valor;
}

/// Le um inteiro que pode estar ausente.
int? inteiroOpcional(Map<String, dynamic> dados, String campo) {
  final Object? valor = dados[campo];
  if (valor == null) {
    return null;
  }
  if (valor is! int) {
    throw DadoInvalido(campo, 'precisa ser um numero inteiro');
  }
  return valor;
}

/// Le uma data obrigatoria, gravada no formato ISO 8601.
///
/// ISO 8601 (`2026-08-26T09:00:00.000`) e um texto que ordena igual a data que
/// representa e nao depende do idioma do aparelho — ao contrario de
/// `26/08/2026`, que um celular em ingles leria como 8 de fevereiro.
DateTime dataObrigatoria(Map<String, dynamic> dados, String campo) {
  final String texto = textoObrigatorio(dados, campo);
  final DateTime? data = DateTime.tryParse(texto);
  if (data == null) {
    throw DadoInvalido(campo, 'precisa ser uma data no formato ISO 8601');
  }
  return data;
}

/// Converte o conteudo lido do disco em um mapa, ou estoura [DadoInvalido].
Map<String, dynamic> comoMapa(Object? bruto, String campo) {
  if (bruto is! Map) {
    throw DadoInvalido(campo, 'precisa ser um objeto');
  }
  return Map<String, dynamic>.from(bruto);
}
