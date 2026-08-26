import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_cores.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/flor_garapuvu.dart';
import '../../../core/theme/indicador_flor.dart';
import 'tela_inicial.dart';

/// Tela de abertura do app, com a identidade do Garapuvu.
///
/// Traz a foto do garapuvu florido do site oficial, escurecida por um veu
/// azul-noite — o mesmo recurso que o site usa para o texto ficar legivel sobre
/// a imagem. Sem esse veu, texto claro sobre o ceu claro da foto reprovaria em
/// contraste.
///
/// **Nao e um beco:** ela sai sozinha depois de [duracao] e tambem sai ao
/// toque, para quem nao quiser esperar (regra 6.6).
class TelaSplash extends StatefulWidget {
  /// Cria a tela de abertura.
  const TelaSplash({super.key});

  /// Quanto tempo a abertura fica na tela antes de seguir sozinha.
  static const Duration duracao = Duration(milliseconds: 2200);

  /// Caminho da foto de fundo, baixada do site oficial do projeto.
  static const String fundo = 'assets/images/garapuvu-hero.jpg';

  @override
  State<TelaSplash> createState() => _TelaSplashState();
}

class _TelaSplashState extends State<TelaSplash> {
  /// O contador que leva a tela adiante sozinha.
  ///
  /// Guardado num campo (em vez de `Future.delayed`) porque assim ele pode ser
  /// **cancelado** no [dispose]: sem isso, quem toca na tela antes do tempo
  /// deixa um timer vivo apontando para uma tela que ja morreu.
  Timer? _contador;

  bool _jaSaiu = false;

  @override
  void initState() {
    super.initState();
    _contador = Timer(TelaSplash.duracao, _seguir);
  }

  @override
  void dispose() {
    _contador?.cancel();
    super.dispose();
  }

  void _seguir() {
    // Guarda dupla: o timer pode disparar depois de a pessoa ja ter tocado, e
    // empilhar a tela inicial duas vezes seria um bug visivel.
    if (_jaSaiu || !mounted) {
      return;
    }
    _jaSaiu = true;
    _contador?.cancel();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const TelaInicial(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.azulNoite,
      body: GestureDetector(
        onTap: _seguir,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              TelaSplash.fundo,
              fit: BoxFit.cover,
              // A foto leva alguns quadros para decodificar. Sem isto ela
              // "pipoca" sobre o azul-noite; com o fade ela entra suave, e
              // quem esta com "reduzir movimento" ligado recebe ela pronta.
              frameBuilder: (
                BuildContext context,
                Widget filho,
                int? quadro,
                bool veioDoCache,
              ) {
                if (veioDoCache || MediaQuery.disableAnimationsOf(context)) {
                  return filho;
                }
                return AnimatedOpacity(
                  opacity: quadro == null ? 0 : 1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  child: filho,
                );
              },
              // Se a imagem faltar, a tela continua de pe em azul-noite em vez
              // de mostrar um icone de erro quebrado.
              errorBuilder: (BuildContext _, Object __, StackTrace? ___) =>
                  const ColoredBox(color: AppCores.azulNoite),
            ),
            // O veu: transparente em cima, solido embaixo, para o texto ter
            // fundo escuro garantido.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    // Leve no topo, para a foto do garapuvu florido aparecer;
                    // praticamente solido da metade para baixo, onde ficam o
                    // nome e o subtitulo — texto claro precisa de fundo
                    // escuro garantido, e nao de sorte.
                    Color(0x2E0E1F38),
                    Color(0x8A0E1F38),
                    Color(0xF20E1F38),
                    AppCores.azulNoite,
                  ],
                  stops: <double>[0, 0.28, 0.5, 1],
                ),
              ),
            ),
            const SafeArea(child: _ConteudoDaAbertura()),
          ],
        ),
      ),
    );
  }
}

/// O que aparece por cima da foto: a flor, o nome e a espera.
class _ConteudoDaAbertura extends StatelessWidget {
  const _ConteudoDaAbertura();

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        const Spacer(),
        const FlorGarapuvu(tamanho: 96),
        const SizedBox(height: AppEspacos.lg),
        Semantics(
          header: true,
          child: Text(
            'Garapuvu Kanban',
            textAlign: TextAlign.center,
            style: tema.textTheme.headlineMedium?.copyWith(
              color: AppCores.creme,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: AppEspacos.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppEspacos.lg),
          child: Text(
            'O quadro de tarefas do time',
            textAlign: TextAlign.center,
            style: tema.textTheme.bodyLarge?.copyWith(color: AppCores.creme),
          ),
        ),
        const Spacer(),
        const IndicadorFlor(tamanho: 40, rotulo: 'Abrindo o aplicativo'),
        const SizedBox(height: AppEspacos.xl),
      ],
    );
  }
}
