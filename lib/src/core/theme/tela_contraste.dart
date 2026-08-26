import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'pares_de_contraste.dart';

/// Relatorio de contraste ao vivo do tema (regra 6.3).
///
/// Cada linha mostra um par fundo/texto que o app realmente usa, **desenhado
/// com as cores de verdade**, ao lado da razao calculada e do selo PASSA/FALHA
/// AA. O numero vem de `contraste.dart`, que implementa a formula da WCAG —
/// nao e estimativa nem chute de designer.
///
/// A tela le o tema do proprio `context`, entao ela reflete o modo claro ou
/// escuro em que o aparelho estiver.
class TelaContraste extends StatelessWidget {
  /// Cria o relatorio de contraste.
  const TelaContraste({super.key});

  /// Como a tela e chamada na barra do topo e na navegacao.
  static const String titulo = 'Relatorio de contraste';

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final List<ParDeCores> pares = paresDoTema(tema.colorScheme);
    final int aprovados = pares.where((ParDeCores p) => p.passa).length;

    return Scaffold(
      appBar: AppBar(title: const Text(TelaContraste.titulo)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(AppEspacos.md),
              children: <Widget>[
                _Resumo(aprovados: aprovados, total: pares.length),
                const SizedBox(height: AppEspacos.md),
                Text(
                  'Texto normal precisa de 4,50:1. Texto grande, icone e borda '
                  'precisam de 3,00:1. Os numeros sao calculados pela formula '
                  'da WCAG 2.1 toda vez que esta tela abre.',
                  style: tema.textTheme.bodySmall,
                ),
                const SizedBox(height: AppEspacos.lg),
                for (final ParDeCores par in pares) ...<Widget>[
                  _LinhaDoPar(par: par),
                  const SizedBox(height: AppEspacos.md),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Faixa do topo com o placar geral do relatorio.
class _Resumo extends StatelessWidget {
  const _Resumo({required this.aprovados, required this.total});

  final int aprovados;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final bool tudoPassa = aprovados == total;
    final ColorScheme cores = tema.colorScheme;

    return Card(
      color: tudoPassa ? cores.secondaryContainer : cores.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppEspacos.md),
        child: Text(
          tudoPassa
              ? '$aprovados de $total pares passam no nivel AA.'
              : 'Atencao: $aprovados de $total pares passam. '
                  'Corrija os reprovados antes de seguir.',
          style: tema.textTheme.titleMedium?.copyWith(
            color:
                tudoPassa ? cores.onSecondaryContainer : cores.onErrorContainer,
          ),
        ),
      ),
    );
  }
}

/// Uma linha do relatorio: a amostra desenhada + os numeros.
class _LinhaDoPar extends StatelessWidget {
  const _LinhaDoPar({required this.par});

  final ParDeCores par;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return Semantics(
      // Uma frase so, para o leitor de tela nao soletrar a tabela inteira.
      label: '${par.onde}. Contraste ${par.razaoFormatada}. ${par.selo}.',
      excludeSemantics: true,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppEspacos.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // A amostra usa as cores DE VERDADE do par: se o contraste for
              // ruim, da para ver aqui, nao so ler no numero.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppEspacos.sm),
                color: par.fundo,
                child: Text(
                  'Exemplo de texto',
                  style: tema.textTheme.bodyLarge?.copyWith(color: par.texto),
                ),
              ),
              const SizedBox(height: AppEspacos.sm),
              Text(par.onde, style: tema.textTheme.bodyMedium),
              const SizedBox(height: AppEspacos.xs),
              Text(
                par.nome,
                style: tema.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppEspacos.sm),
              // Wrap: em 320 dp a razao e o selo descem de linha em vez de
              // estourar.
              Wrap(
                spacing: AppEspacos.sm,
                runSpacing: AppEspacos.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    par.razaoFormatada,
                    style: tema.textTheme.titleMedium,
                  ),
                  Chip(
                    label: Text(par.selo),
                    avatar: Icon(
                      par.passa ? Icons.check_circle : Icons.error,
                      // O icone acompanha o texto: o selo nunca depende so da
                      // cor para ser entendido.
                      color: par.passa
                          ? tema.colorScheme.onSecondaryContainer
                          : tema.colorScheme.onErrorContainer,
                    ),
                    backgroundColor: par.passa
                        ? tema.colorScheme.secondaryContainer
                        : tema.colorScheme.errorContainer,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
