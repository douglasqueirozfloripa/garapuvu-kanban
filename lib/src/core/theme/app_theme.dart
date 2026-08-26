import 'package:flutter/material.dart';

/// Espacamentos do projeto, em dp.
///
/// Nenhum widget usa numero solto de padding: sempre um destes valores. Isso
/// mantem o ritmo visual constante e faz o teste de espacamento (folga
/// > 0,5 dp entre elementos vizinhos) ter um padrao para conferir.
abstract final class AppEspacos {
  /// 4 dp — colagem intencional entre icone e rotulo.
  static const double xs = 4;

  /// 8 dp — separacao minima entre elementos irmaos.
  static const double sm = 8;

  /// 16 dp — respiro padrao de conteudo.
  static const double md = 16;

  /// 24 dp — separacao entre blocos diferentes.
  static const double lg = 24;

  /// 32 dp — margem de secao.
  static const double xl = 32;

  /// Alvo minimo de toque exigido pelo WCAG e pelo Material: 48x48 dp.
  static const double alvoDeToque = 48;
}

/// Cores base do Garapuvu.
///
/// O garapuvu e uma arvore da Mata Atlantica: a semente da paleta e o verde de
/// mata, com um acento de madeira. O Material 3 deriva o resto do
/// [ColorScheme] a partir destas sementes.
///
/// **Atencao:** os design tokens definitivos (com relatorio de contraste ao
/// vivo provando WCAG AA) entram no **Prompt 3**. O que existe aqui e o minimo
/// para o app compilar e ja apontar para a identidade certa.
abstract final class AppCores {
  /// Verde de mata — semente principal da paleta.
  static const Color verdeMata = Color(0xFF1B5E3F);

  /// Marrom de madeira — acento secundario.
  static const Color madeira = Color(0xFF8D5A2B);
}

/// Fabrica dos temas claro e escuro do aplicativo.
abstract final class AppTheme {
  /// Tema claro, padrao do aplicativo.
  static ThemeData claro() => _construir(Brightness.light);

  /// Tema escuro, usado quando o sistema esta em modo escuro.
  static ThemeData escuro() => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brilho) {
    final ColorScheme esquema = ColorScheme.fromSeed(
      seedColor: AppCores.verdeMata,
      brightness: brilho,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      // Alvo de toque generoso em todo o app: acessibilidade nao e opcional.
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: esquema.primaryContainer,
        foregroundColor: esquema.onPrimaryContainer,
        centerTitle: false,
      ),
    );
  }
}
