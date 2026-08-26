import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../model/prioridade.dart';

/// A etiqueta que mostra o quanto uma tarefa e urgente.
///
/// **Cor nunca e a unica informacao** (regra 6.3 do arquivo de instrucoes). A
/// etiqueta carrega tres pistas ao mesmo tempo:
///
/// 1. o **rotulo escrito** ("Alta"), que qualquer pessoa le;
/// 2. um **icone com direcao propria** (seta para cima, traco, seta para
///    baixo), que se distingue mesmo impresso em preto e branco;
/// 3. a **cor**, que e a pista mais rapida para quem enxerga as tres.
///
/// Tire a cor e a etiqueta continua legivel — que e exatamente o teste.
///
/// As cores saem de papeis do `ColorScheme` (`errorContainer`,
/// `secondaryContainer`, `tertiaryContainer`) e nao de valores soltos: os tres
/// pares estao em `pares_de_contraste.dart` e sao conferidos por teste nos
/// temas claro e escuro.
///
/// A sequencia segue a leitura de semaforo — vermelho, ambar, verde — porque e
/// a que a maioria das pessoas ja traz de fora do app. A primeira versao saiu
/// invertida (media verde, baixa ambar) e so um print do app rodando mostrou
/// isso: nenhum teste reprova uma cor que passa no contraste mas confunde.
class EtiquetaPrioridade extends StatelessWidget {
  /// Cria a etiqueta de [prioridade].
  const EtiquetaPrioridade({required this.prioridade, super.key});

  /// A prioridade a mostrar.
  final Prioridade prioridade;

  /// A cor de fundo da etiqueta para [prioridade], dentro de [esquema].
  ///
  /// `alta` usa o papel de erro porque e o unico que o Material reserva para
  /// "isto pede atencao agora" — e o mesmo papel do aviso de limite de WIP,
  /// entao o app fala uma lingua so.
  static Color fundoDe(Prioridade prioridade, ColorScheme esquema) {
    return switch (prioridade) {
      Prioridade.alta => esquema.errorContainer,
      Prioridade.media => esquema.secondaryContainer,
      Prioridade.baixa => esquema.tertiaryContainer,
    };
  }

  /// A cor do texto e do icone desenhados sobre [fundoDe].
  static Color textoDe(Prioridade prioridade, ColorScheme esquema) {
    return switch (prioridade) {
      Prioridade.alta => esquema.onErrorContainer,
      Prioridade.media => esquema.onSecondaryContainer,
      Prioridade.baixa => esquema.onTertiaryContainer,
    };
  }

  /// O icone de [prioridade].
  ///
  /// As tres formas apontam para lados diferentes de proposito: em preto e
  /// branco, "seta para cima" e "seta para baixo" continuam distinguiveis.
  static IconData iconeDe(Prioridade prioridade) {
    return switch (prioridade) {
      Prioridade.alta => Icons.keyboard_double_arrow_up,
      Prioridade.media => Icons.drag_handle,
      Prioridade.baixa => Icons.keyboard_double_arrow_down,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final Color fundo = fundoDe(prioridade, tema.colorScheme);
    final Color texto = textoDe(prioridade, tema.colorScheme);

    return Semantics(
      // Sem isto, o leitor de tela anunciaria so "Alta", solto, sem dizer
      // alta o que.
      label: 'Prioridade ${prioridade.rotulo.toLowerCase()}',
      excludeSemantics: true,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.circular(AppEspacos.sm),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppEspacos.sm,
            vertical: AppEspacos.xs,
          ),
          // mainAxisSize.min: a etiqueta ocupa so o que precisa, para caber
          // dentro do Wrap do cartao em tela de 320 dp.
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(iconeDe(prioridade), size: 16, color: texto),
              const SizedBox(width: AppEspacos.xs),
              Text(
                prioridade.rotulo,
                style: tema.textTheme.labelLarge?.copyWith(color: texto),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
