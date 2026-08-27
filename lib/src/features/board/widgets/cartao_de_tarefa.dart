import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../model/status.dart';
import '../model/tarefa.dart';
import 'etiqueta_prioridade.dart';

/// Uma tarefa vista de fora: o cartao que a lista repete.
///
/// Mostra, nesta ordem de importancia: o **titulo**, a **prioridade**, quem e
/// o **responsavel** e em que **coluna** a tarefa esta. Descricao e estimativa
/// so aparecem quando existem — campo opcional vazio nao vira linha em branco.
///
/// Os botoes de mover so aparecem quando [aoAvancar] e [aoVoltar] sao
/// informados — na lista (Prompt 5) o cartao e so leitura, e no quadro
/// (Prompt 6) ele caminha. Um cartao que parecesse tocavel sem fazer nada seria
/// um beco (regra 6.6).
class CartaoDeTarefa extends StatelessWidget {
  /// Cria o cartao de [tarefa].
  const CartaoDeTarefa({
    required this.tarefa,
    this.aoAvancar,
    this.aoVoltar,
    this.mostrarColuna = true,
    super.key,
  });

  /// A tarefa mostrada.
  final Tarefa tarefa;

  /// Empurra a tarefa para a proxima coluna. `null` deixa o cartao so leitura.
  final VoidCallback? aoAvancar;

  /// Puxa a tarefa para a coluna anterior. `null` deixa o cartao so leitura.
  final VoidCallback? aoVoltar;

  /// Mostra em que coluna a tarefa esta.
  ///
  /// O quadro passa `false`: la o cabecalho da coluna ja diz isso, e repetir a
  /// informacao dentro de cada cartao so gastaria a largura que os titulos
  /// precisam.
  final bool mostrarColuna;

  /// `true` quando este cartao carrega os botoes de mover.
  bool get _temAcoes => aoAvancar != null || aoVoltar != null;

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
                if (mostrarColuna)
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
            if (_temAcoes) ...<Widget>[
              const SizedBox(height: AppEspacos.sm),
              _BotoesDeMover(
                tarefa: tarefa,
                aoAvancar: aoAvancar,
                aoVoltar: aoVoltar,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Os dois botoes que fazem a tarefa caminhar pelo quadro.
///
/// Cada um so fica ativo quando existe coluna para aquele lado (regra de
/// negocio 2: uma coluna por vez, sem pulo). Na ponta do quadro o botao aparece
/// **desabilitado**, e nao some: sumir faria os botoes dancarem de lugar a cada
/// movimento, e quem usa perderia a referencia.
class _BotoesDeMover extends StatelessWidget {
  const _BotoesDeMover({
    required this.tarefa,
    required this.aoAvancar,
    required this.aoVoltar,
  });

  final Tarefa tarefa;
  final VoidCallback? aoAvancar;
  final VoidCallback? aoVoltar;

  @override
  Widget build(BuildContext context) {
    final bool podeVoltar = tarefa.status.temAnterior && aoVoltar != null;
    final bool podeAvancar = tarefa.status.temProxima && aoAvancar != null;

    return Row(
      children: <Widget>[
        _BotaoDeMover(
          icone: Icons.arrow_back,
          // O rotulo diz para ONDE a tarefa vai, e nao so "voltar": quem usa
          // leitor de tela nao ve as colunas para deduzir o destino.
          rotulo: podeVoltar
              ? 'Voltar "${tarefa.titulo}" para '
                  '${Status.values[tarefa.status.index - 1].rotulo}'
              : '"${tarefa.titulo}" ja esta na primeira coluna',
          aoTocar: podeVoltar ? aoVoltar : null,
        ),
        const SizedBox(width: AppEspacos.xs),
        _BotaoDeMover(
          icone: Icons.arrow_forward,
          rotulo: podeAvancar
              ? 'Avancar "${tarefa.titulo}" para '
                  '${Status.values[tarefa.status.index + 1].rotulo}'
              : '"${tarefa.titulo}" ja esta na ultima coluna',
          aoTocar: podeAvancar ? aoAvancar : null,
        ),
      ],
    );
  }
}

/// Um botao de mover, com alvo de toque de 48 dp e rotulo para leitor de tela.
class _BotaoDeMover extends StatelessWidget {
  const _BotaoDeMover({
    required this.icone,
    required this.rotulo,
    required this.aoTocar,
  });

  final IconData icone;
  final String rotulo;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppEspacos.alvoDeToque,
      height: AppEspacos.alvoDeToque,
      child: IconButton(
        onPressed: aoTocar,
        icon: Icon(icone),
        // tooltip vira o rotulo do leitor de tela E a dica de quem usa mouse.
        tooltip: rotulo,
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
