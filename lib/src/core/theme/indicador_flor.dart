import 'package:flutter/material.dart';

import 'app_cores.dart';
import 'flor_garapuvu.dart';

/// Indicador de carregamento com a flor do garapuvu girando.
///
/// Substitui o `CircularProgressIndicator` padrao nas esperas do app: e a marca
/// do projeto que gira, nao um circulo generico.
///
/// **Acessibilidade:** movimento continuo incomoda quem tem sensibilidade
/// vestibular, e a WCAG pede respeitar isso. Por isso, quando o sistema esta
/// com "reduzir movimento" ligado, a flor **para de girar** e so pulsa de leve;
/// e o widget sempre carrega um rotulo em texto para o leitor de tela.
class IndicadorFlor extends StatefulWidget {
  /// Cria o indicador.
  const IndicadorFlor({
    this.tamanho = 48,
    this.rotulo = 'Carregando',
    super.key,
  });

  /// Largura e altura da flor, em dp.
  final double tamanho;

  /// O que o leitor de tela anuncia enquanto a espera dura.
  final String rotulo;

  /// Quanto tempo a flor leva para dar uma volta completa.
  static const Duration duracaoDaVolta = Duration(milliseconds: 2400);

  @override
  State<IndicadorFlor> createState() => _IndicadorFlorState();
}

class _IndicadorFlorState extends State<IndicadorFlor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controle = AnimationController(
    vsync: this,
    duration: IndicadorFlor.duracaoDaVolta,
  )..repeat();

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduzirMovimento = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: widget.rotulo,
      liveRegion: true,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _controle,
        builder: (BuildContext context, Widget? filho) {
          // A flor tem 5 petalas iguais: girar 1/5 de volta ja a devolve ao
          // mesmo desenho, entao o laco fica continuo sem salto.
          final double giro = reduzirMovimento ? 0 : _controle.value;
          // Um respiro leve de tamanho, para a espera nao parecer travada nem
          // quando o giro esta desligado.
          final double pulso =
              0.9 + 0.1 * (1 - (_controle.value * 2 - 1).abs());

          return Transform.rotate(
            angle: giro * 2 * 3.1415926535897932,
            child: Transform.scale(scale: pulso, child: filho),
          );
        },
        child: FlorGarapuvu(
          tamanho: widget.tamanho,
          cor: AppCores.flor,
          corDoMiolo: AppCores.florQuente,
        ),
      ),
    );
  }
}
