/// Calculo de contraste entre duas cores, conforme a WCAG 2.1.
///
/// Este arquivo e **Dart puro**: nao importa Flutter, so `dart:math`. Por isso
/// o contraste do app e **calculado**, nunca estimado no olho — e da para
/// provar cada numero em teste unitario, comparando com os valores publicados
/// pelo W3C.
///
/// A referencia e a definicao oficial de *relative luminance* e de *contrast
/// ratio*: <https://www.w3.org/TR/WCAG21/#dfn-contrast-ratio>
library;

import 'dart:math' as math;

/// Razao minima para **texto normal** passar no nivel AA.
const double razaoMinimaAaTextoNormal = 4.5;

/// Razao minima para **texto grande** (>= 18pt, ou 14pt em negrito) e para
/// icones passarem no nivel AA.
const double razaoMinimaAaTextoGrande = 3;

/// Luminancia relativa de uma cor, entre 0 (preto) e 1 (branco).
///
/// Recebe a cor no formato `0xAARRGGBB` — o mesmo de `Color.value` no Flutter.
/// O canal alfa e ignorado: contraste se mede entre cores ja compostas.
///
/// A conta nao e a media dos canais. O verde pesa muito mais que o azul
/// (0,7152 contra 0,0722) porque o olho humano enxerga assim; e cada canal
/// passa antes por uma correcao de gama, que desfaz a curva com que a tela
/// guarda a cor.
double luminanciaRelativa(int argb) {
  final double r = _canalLinear((argb >> 16) & 0xFF);
  final double g = _canalLinear((argb >> 8) & 0xFF);
  final double b = _canalLinear(argb & 0xFF);

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// Razao de contraste entre duas cores, de 1:1 (iguais) a 21:1 (preto e
/// branco).
///
/// A ordem dos argumentos nao importa: 4,5 entre A e B e 4,5 entre B e A.
double razaoDeContraste(int argbUm, int argbDois) {
  final double a = luminanciaRelativa(argbUm);
  final double b = luminanciaRelativa(argbDois);

  final double clara = math.max(a, b);
  final double escura = math.min(a, b);

  return (clara + 0.05) / (escura + 0.05);
}

/// `true` quando [razao] atinge o minimo AA.
///
/// Texto grande e icone tem exigencia menor ([razaoMinimaAaTextoGrande])
/// porque o traco mais espesso ja ajuda a leitura.
bool passaAa(double razao, {bool textoGrande = false}) {
  final double minimo =
      textoGrande ? razaoMinimaAaTextoGrande : razaoMinimaAaTextoNormal;

  // Arredonda para 2 casas antes de comparar: e assim que a razao aparece no
  // relatorio, e seria confuso mostrar "4.50" com o selo FALHA.
  return _arredondar(razao) >= minimo;
}

/// A razao formatada como o relatorio mostra: `'4.53:1'`.
String formatarRazao(double razao) => '${razao.toStringAsFixed(2)}:1';

/// O selo do relatorio de contraste: `'PASSA AA'` ou `'FALHA AA'`.
String seloAa(double razao, {bool textoGrande = false}) =>
    passaAa(razao, textoGrande: textoGrande) ? 'PASSA AA' : 'FALHA AA';

/// Converte um canal de 0-255 para a escala linear que a WCAG usa.
double _canalLinear(int valor) {
  final double normalizado = valor / 255;

  if (normalizado <= 0.03928) {
    return normalizado / 12.92;
  }
  return math.pow((normalizado + 0.055) / 1.055, 2.4).toDouble();
}

double _arredondar(double razao) => (razao * 100).roundToDouble() / 100;
