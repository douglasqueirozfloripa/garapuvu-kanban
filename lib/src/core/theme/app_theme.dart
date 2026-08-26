import 'package:flutter/material.dart';

import 'app_cores.dart';

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

/// Fabrica dos temas claro e escuro do aplicativo.
///
/// O tema nasce de `ColorScheme.fromSeed`, que deriva uma paleta inteira e
/// harmonica a partir de uma cor semente — mas os papeis que a marca **define**
/// sao fixados por cima, para o app parecer o Garapuvu e nao um app generico:
///
/// | Papel do Material | Cor da marca | Onde o site usa |
/// | --- | --- | --- |
/// | `primary` / `onPrimary` | flor amarela / azul-noite | o botao "Quero participar" |
/// | `secondary` | verde folha | apoio |
/// | `tertiary` | marrom galho | apoio |
/// | `surface` / `onSurface` | creme / azul-noite | o corpo das paginas |
/// | barra do topo | azul-noite / creme | a faixa do cabecalho |
///
/// Cada par fundo/texto daqui entra em `pares_de_contraste.dart` e e conferido
/// por teste nos dois temas: identidade nao vale reprovar em acessibilidade.
abstract final class AppTheme {
  /// Tema claro, padrao do aplicativo.
  static ThemeData claro() => _construir(Brightness.light);

  /// Tema escuro, usado quando o sistema esta em modo escuro.
  static ThemeData escuro() => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brilho) {
    final bool claro = brilho == Brightness.light;

    final ColorScheme esquema = ColorScheme.fromSeed(
      seedColor: AppCores.flor,
      brightness: brilho,
      // A acao principal e o amarelo da flor com texto azul-noite — a mesma
      // combinacao do botao principal do site.
      primary: AppCores.flor,
      onPrimary: AppCores.azulNoite,
      secondary: AppCores.folha,
      onSecondary: AppCores.creme,
      tertiary: AppCores.galho,
      onTertiary: AppCores.creme,
      // No claro, o fundo e o creme do site; no escuro, o azul-noite da faixa.
      surface: claro ? AppCores.creme : AppCores.azulNoite,
      onSurface: claro ? AppCores.azulNoite : AppCores.creme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: esquema.surface,
      // Alvo de toque generoso em todo o app: acessibilidade nao e opcional.
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      // O Flutter corta a mensagem de erro em UMA linha por padrao, e as
      // nossas explicam o proximo passo — cortadas, elas nao cumprem a regra
      // 6.6 ("todo erro diz o que aconteceu e qual e o proximo passo").
      // Fica no tema, e nao em cada campo, para nenhum formulario novo
      // nascer com o defeito de volta.
      inputDecorationTheme: const InputDecorationTheme(
        errorMaxLines: 4,
        helperMaxLines: 2,
      ),
      // O amarelo da flor so funciona como FUNDO (com texto azul-noite). Como
      // COR DE TEXTO sobre o creme ele da 1,70:1 — ilegivel. O site ja prevê
      // isso e oferece o ambar escuro (`--gp-bloom-deep`) para texto sobre
      // fundo claro; no tema escuro, o amarelo vivo volta a servir.
      // Sem isto, o botao "Relatorio de contraste" reprovava na diretriz de
      // contraste do proprio flutter_test.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: claro ? AppCores.florProfunda : AppCores.flor,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: claro ? AppCores.florProfunda : AppCores.flor,
        ),
      ),
      // A faixa do topo e azul-noite com texto creme nos DOIS temas, como no
      // site: e ela que da identidade imediata ao app.
      appBarTheme: const AppBarTheme(
        backgroundColor: AppCores.azulNoite,
        foregroundColor: AppCores.creme,
        centerTitle: false,
      ),
    );
  }
}
