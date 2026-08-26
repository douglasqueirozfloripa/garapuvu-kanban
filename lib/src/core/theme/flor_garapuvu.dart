import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_cores.dart';

/// A flor do garapuvu — o simbolo da marca, desenhado em Flutter.
///
/// E a mesma figura do `favicon.svg` do site oficial: **cinco petalas**
/// douradas giradas de 72 graus em torno de um miolo ambar. Foi redesenhada com
/// [CustomPaint] em vez de carregada como SVG porque assim ela nao precisa de
/// biblioteca nenhuma, escala sem borrar em qualquer tamanho e pode ser
/// animada — o que o indicador de carregamento aproveita.
class FlorGarapuvu extends StatelessWidget {
  /// Desenha a flor com [tamanho] dp de lado.
  const FlorGarapuvu({
    this.tamanho = 64,
    this.cor = AppCores.flor,
    this.corDoMiolo = AppCores.florQuente,
    super.key,
  });

  /// Largura e altura do desenho, em dp.
  final double tamanho;

  /// Cor das petalas.
  final Color cor;

  /// Cor do miolo.
  final Color corDoMiolo;

  /// Quantas petalas a flor tem. O favicon do Garapuvu usa cinco.
  static const int petalas = 5;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: CustomPaint(
        painter: _PintorDaFlor(cor: cor, corDoMiolo: corDoMiolo),
      ),
    );
  }
}

class _PintorDaFlor extends CustomPainter {
  const _PintorDaFlor({required this.cor, required this.corDoMiolo});

  final Color cor;
  final Color corDoMiolo;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centro = size.center(Offset.zero);
    // As medidas do favicon sao dadas numa arte de 100x100; a proporcao e
    // mantida para a flor ficar identica em qualquer tamanho.
    final double escala = size.shortestSide / 100;

    final Paint tintaPetala = Paint()..color = cor;
    canvas
      ..save()
      ..translate(centro.dx, centro.dy);

    for (int i = 0; i < FlorGarapuvu.petalas; i++) {
      canvas
        ..save()
        ..rotate(2 * math.pi * i / FlorGarapuvu.petalas)
        ..drawOval(
          Rect.fromCenter(
            center: Offset(0, -22 * escala),
            width: 24 * escala,
            height: 48 * escala,
          ),
          tintaPetala,
        )
        ..restore();
    }

    canvas
      ..drawCircle(Offset.zero, 11 * escala, Paint()..color = corDoMiolo)
      ..drawCircle(Offset.zero, 4.5 * escala, tintaPetala)
      ..restore();
  }

  @override
  bool shouldRepaint(_PintorDaFlor anterior) =>
      anterior.cor != cor || anterior.corDoMiolo != corDoMiolo;
}
