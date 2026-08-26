import 'package:flutter/material.dart';

/// As cores da marca Garapuvu, copiadas do site oficial do projeto.
///
/// **Fonte:** <https://projeto-garapuvu.web.app/> — o site declara sua paleta
/// em CSS custom properties (`--gp-*`), e os nomes abaixo sao os mesmos de la,
/// para quem mexer nos dois lados reconhecer cada cor na hora.
///
/// A identidade vem da propria arvore: o **garapuvu** floresce em **amarelo**,
/// e e esse amarelo que o site usa no botao principal, sobre um fundo
/// azul-noite com texto creme. Por isso o amarelo e a cor de acao do app, e
/// nao um verde generico de mata.
///
/// Regra: **nenhum widget escreve `Color(0x...)` no meio do codigo.** Toda cor
/// sai daqui ou do `ColorScheme` do tema.
abstract final class AppCores {
  /// `--gp-bloom` — o amarelo da flor do garapuvu. A cor de acao do app.
  static const Color flor = Color(0xFFF2B705);

  /// `--gp-bloom-warm` — o amarelo mais quente, para estados de foco.
  static const Color florQuente = Color(0xFFE08A00);

  /// `--gp-bloom-deep` — o ambar escuro, legivel sobre fundo claro.
  static const Color florProfunda = Color(0xFFA85F00);

  /// `--gp-band` e `--gp-text` — o azul-noite das faixas e do texto.
  static const Color azulNoite = Color(0xFF0E1F38);

  /// `--gp-text-soft` — o azul um pouco mais claro, para texto de apoio.
  static const Color azulSuave = Color(0xFF1B3357);

  /// `--gp-page` — o creme do fundo das paginas claras.
  static const Color creme = Color(0xFFFBF7EE);

  /// `--gp-surface-alt` e `--gp-border` — o creme escurecido de cartoes e
  /// bordas.
  static const Color cremeSombra = Color(0xFFF0E9DA);

  /// `--gp-leaf` — o verde da folha do garapuvu.
  static const Color folha = Color(0xFF3E6B4F);

  /// `--gp-branch` — o marrom do galho.
  static const Color galho = Color(0xFF5B4636);
}
