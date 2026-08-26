import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/tarefa.dart';
import '../state/quadro_controller.dart';
import 'tela_cadastro_tarefa.dart';

/// Abre o cadastro, guarda a tarefa criada e confirma na tela.
///
/// Existe como funcao solta porque **duas** telas precisam exatamente disto —
/// a inicial e a lista. Duplicar o fluxo faria uma delas esquecer de gravar ou
/// de confirmar quando o codigo mudasse.
///
/// Devolve a tarefa criada, ou `null` se a pessoa desistiu.
///
/// O `ScaffoldMessenger` e o `Navigator` sao capturados **antes** do `await`:
/// depois dele o [context] pode nao valer mais, e usa-lo seria um bug
/// silencioso que so aparece quando a tela e fechada no meio do caminho.
Future<Tarefa?> abrirCadastroDeTarefa(BuildContext context) async {
  final ScaffoldMessengerState mensageiro = ScaffoldMessenger.of(context);
  final NavigatorState navegador = Navigator.of(context);
  final QuadroController quadro = context.read<QuadroController>();

  final Tarefa? criada = await navegador.push<Tarefa>(
    MaterialPageRoute<Tarefa>(
      builder: (BuildContext _) => const TelaCadastroTarefa(),
    ),
  );

  if (criada == null) {
    return null;
  }

  await quadro.adicionar(criada);

  mensageiro.showSnackBar(
    SnackBar(
      content: Text(
        'Tarefa "${criada.titulo}" guardada neste aparelho para '
        '${criada.responsavel}.',
      ),
    ),
  );

  return criada;
}
