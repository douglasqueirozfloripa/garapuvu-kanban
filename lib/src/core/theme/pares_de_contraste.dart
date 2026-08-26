import 'package:flutter/material.dart';

import 'app_cores.dart';
import '../utils/contraste.dart';

/// Um par fundo/texto do tema, com o contraste ja calculado.
///
/// Existe para o relatorio de contraste e o app olharem para a **mesma** lista:
/// se um par novo entrar no tema e nao entrar aqui, ele nunca seria conferido.
class ParDeCores {
  /// Cria um par para o relatorio.
  const ParDeCores({
    required this.nome,
    required this.onde,
    required this.fundo,
    required this.texto,
    this.textoGrande = false,
  });

  /// Nome tecnico do par, como aparece no `ColorScheme`.
  final String nome;

  /// Onde este par e usado na tela, em portugues.
  final String onde;

  /// Cor de fundo.
  final Color fundo;

  /// Cor do texto ou do icone desenhado sobre [fundo].
  final Color texto;

  /// `true` quando o par so carrega texto grande ou icone, que a WCAG permite
  /// com exigencia menor.
  final bool textoGrande;

  /// A razao de contraste calculada, de 1 a 21.
  double get razao => razaoDeContraste(fundo.value, texto.value);

  /// `true` quando o par atinge o minimo AA para o seu tipo de texto.
  bool get passa => passaAa(razao, textoGrande: textoGrande);

  /// O selo mostrado no relatorio: `'PASSA AA'` ou `'FALHA AA'`.
  String get selo => seloAa(razao, textoGrande: textoGrande);

  /// A razao formatada, como `'4.53:1'`.
  String get razaoFormatada => formatarRazao(razao);
}

/// Todos os pares fundo/texto que o app realmente usa, para um dado [esquema].
///
/// A lista e a fonte unica do relatorio de contraste (regra 6.3) **e** do teste
/// que exige AA nos temas claro e escuro. Ao criar uma combinacao nova de
/// cores na interface, acrescente-a aqui — e o teste passa a cobri-la sozinho.
List<ParDeCores> paresDoTema(ColorScheme esquema) {
  return <ParDeCores>[
    ParDeCores(
      nome: 'surface / onSurface',
      onde: 'Texto comum sobre o fundo da tela',
      fundo: esquema.surface,
      texto: esquema.onSurface,
    ),
    ParDeCores(
      nome: 'surface / onSurfaceVariant',
      onde: 'Texto secundario, como o aviso de privacidade',
      fundo: esquema.surface,
      texto: esquema.onSurfaceVariant,
    ),
    const ParDeCores(
      nome: 'azulNoite / creme',
      onde: 'Barra do topo do app (a faixa da marca)',
      fundo: AppCores.azulNoite,
      texto: AppCores.creme,
    ),
    ParDeCores(
      nome: 'primaryContainer / onPrimaryContainer',
      onde: 'Fundo de destaque suave',
      fundo: esquema.primaryContainer,
      texto: esquema.onPrimaryContainer,
    ),
    ParDeCores(
      nome: 'secondary / onSecondary',
      onde: 'Botao de apoio, em verde folha',
      fundo: esquema.secondary,
      texto: esquema.onSecondary,
    ),
    ParDeCores(
      nome: 'tertiary / onTertiary',
      onde: 'Etiqueta em marrom galho',
      fundo: esquema.tertiary,
      texto: esquema.onTertiary,
    ),
    ParDeCores(
      nome: 'primary / onPrimary',
      onde: 'Botao principal, como "Salvar tarefa"',
      fundo: esquema.primary,
      texto: esquema.onPrimary,
    ),
    ParDeCores(
      nome: 'secondaryContainer / onSecondaryContainer',
      onde: 'Etiqueta de coluna e de prioridade media',
      fundo: esquema.secondaryContainer,
      texto: esquema.onSecondaryContainer,
    ),
    // A etiqueta de prioridade usa tres pares — um por nivel. Os de prioridade
    // alta (errorContainer) e baixa (secondaryContainer) ja estavam nesta
    // lista; o da media entrou junto com a lista do Prompt 5.
    ParDeCores(
      nome: 'tertiaryContainer / onTertiaryContainer',
      onde: 'Etiqueta de prioridade baixa',
      fundo: esquema.tertiaryContainer,
      texto: esquema.onTertiaryContainer,
    ),
    ParDeCores(
      nome: 'surfaceContainerHighest / onSurface',
      onde: 'Texto dentro de cartao e de campo de formulario',
      fundo: esquema.surfaceContainerHighest,
      texto: esquema.onSurface,
    ),
    ParDeCores(
      nome: 'errorContainer / onErrorContainer',
      onde: 'Aviso do limite de tarefas em andamento',
      fundo: esquema.errorContainer,
      texto: esquema.onErrorContainer,
    ),
    ParDeCores(
      nome: 'surface / error',
      onde: 'Mensagem de erro embaixo do campo',
      fundo: esquema.surface,
      texto: esquema.error,
    ),
    // Este par foi acrescentado depois de a diretriz de contraste do
    // flutter_test reprovar o botao de contorno: o relatorio so confere os
    // pares que estao NESTA lista, entao um par esquecido aqui e um par nao
    // conferido.
    ParDeCores(
      nome: 'surface / texto de botao de contorno',
      onde: 'Texto de botao sem preenchimento',
      fundo: esquema.surface,
      texto: esquema.brightness == Brightness.light
          ? AppCores.florProfunda
          : AppCores.flor,
    ),
    ParDeCores(
      nome: 'surface / outline',
      onde: 'Borda de campo e de cartao',
      fundo: esquema.surface,
      texto: esquema.outline,
      textoGrande: true,
    ),
  ];
}
