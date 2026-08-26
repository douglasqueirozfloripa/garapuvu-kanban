import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../model/tarefa.dart';
import 'etiqueta_prioridade.dart';

/// Uma tarefa vista de fora: o cartao que a lista repete.
///
/// Mostra, nesta ordem de importancia: o **titulo**, a **prioridade**, quem e
/// o **responsavel** e em que **coluna** a tarefa esta. Descricao e estimativa
/// so aparecem quando existem — campo opcional vazio nao vira linha em branco.
///
/// O cartao nao tem botao ainda: mover a tarefa de coluna e o Prompt 6. Por
/// isso ele e so leitura, e nao finge ser tocavel.
class CartaoDeTarefa extends StatelessWidget {
  /// Cria o cartao de [tarefa].
  const CartaoDeTarefa({required this.tarefa, super.key});

  /// A tarefa mostrada.
  final Tarefa tarefa;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppEspacos.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              tarefa.titulo,
              style: tema.textTheme.titleMedium,
              // Titulo longo quebra em ate duas linhas e so entao vira "...".
              // Corte seco na primeira linha esconderia o assunto da tarefa.
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (tarefa.descricao != null) ...<Widget>[
              const SizedBox(height: AppEspacos.xs),
              Text(
                tarefa.descricao!,
                style: tema.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppEspacos.sm),
            // Wrap: em 320 dp com fonte a 200%, as etiquetas descem de linha
            // em vez de estourar o RenderFlex.
            Wrap(
              spacing: AppEspacos.sm,
              runSpacing: AppEspacos.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                EtiquetaPrioridade(prioridade: tarefa.prioridade),
                _EtiquetaDeTexto(
                  icone: Icons.person_outline,
                  texto: tarefa.responsavel,
                  rotuloParaLeitor: 'Responsavel: ${tarefa.responsavel}',
                ),
                _EtiquetaDeTexto(
                  icone: Icons.view_column_outlined,
                  texto: tarefa.status.rotulo,
                  rotuloParaLeitor: 'Coluna: ${tarefa.status.rotulo}',
                ),
                if (tarefa.estimativaEmHoras != null)
                  _EtiquetaDeTexto(
                    icone: Icons.schedule,
                    texto: '${tarefa.estimativaEmHoras}h',
                    rotuloParaLeitor:
                        'Estimativa: ${tarefa.estimativaEmHoras} horas',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Uma etiqueta discreta de icone + texto, para os dados de apoio do cartao.
///
/// Fica sem cor de fundo de proposito: se responsavel, coluna e estimativa
/// tambem fossem coloridos, a prioridade — que e a informacao que ordena a
/// lista — deixaria de saltar aos olhos.
class _EtiquetaDeTexto extends StatelessWidget {
  const _EtiquetaDeTexto({
    required this.icone,
    required this.texto,
    required this.rotuloParaLeitor,
  });

  final IconData icone;
  final String texto;
  final String rotuloParaLeitor;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final Color cor = tema.colorScheme.onSurfaceVariant;

    return Semantics(
      label: rotuloParaLeitor,
      excludeSemantics: true,
      container: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icone, size: 16, color: cor),
          const SizedBox(width: AppEspacos.xs),
          // Flexible: o nome de quem e responsavel vem de quem digitou e pode
          // ser longo. Sem isto, um nome grande estoura a linha em 320 dp com
          // fonte a 200% — o Row de tamanho minimo nao encolhe o texto sozinho.
          Flexible(
            child: Text(
              texto,
              style: tema.textTheme.bodySmall?.copyWith(color: cor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
