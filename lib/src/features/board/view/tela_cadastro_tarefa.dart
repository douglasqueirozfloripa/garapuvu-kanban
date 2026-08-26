import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../model/prioridade.dart';
import '../model/tarefa.dart';
import '../model/validacoes.dart';
import '../widgets/seletor_prioridade.dart';

/// Tela de cadastro de uma tarefa nova.
///
/// Ao salvar, ela **devolve** a [Tarefa] montada via `Navigator.pop` em vez de
/// gravar sozinha: guardar dados e assunto da camada `data/`, que entra no
/// Prompt 4. Assim esta tela continua testavel sem disco nem banco.
///
/// Nenhuma cor solta: tudo vem do tema e dos tokens de [AppEspacos].
class TelaCadastroTarefa extends StatefulWidget {
  /// Cria a tela de cadastro.
  const TelaCadastroTarefa({super.key});

  /// Como a tela e chamada na barra do topo e na navegacao.
  static const String titulo = 'Nova tarefa';

  @override
  State<TelaCadastroTarefa> createState() => _TelaCadastroTarefaState();
}

class _TelaCadastroTarefaState extends State<TelaCadastroTarefa> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _titulo = TextEditingController();
  final TextEditingController _responsavel = TextEditingController();
  final TextEditingController _estimativa = TextEditingController();

  Prioridade _prioridade = Prioridade.media;

  @override
  void dispose() {
    _titulo.dispose();
    _responsavel.dispose();
    _estimativa.dispose();
    super.dispose();
  }

  void _salvar() {
    // validate() ja mostra a mensagem de cada campo invalido na propria tela.
    if (!_formulario.currentState!.validate()) {
      return;
    }

    final String horas = _estimativa.text.trim();
    final Tarefa nova = Tarefa(
      // Sem banco ainda: o instante da criacao serve de identificador unico.
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      titulo: _titulo.text.trim(),
      responsavel: _responsavel.text.trim(),
      prioridade: _prioridade,
      criadaEm: DateTime.now(),
      estimativaEmHoras: horas.isEmpty ? null : int.parse(horas),
    );

    Navigator.of(context).pop(nova);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return Scaffold(
      // O AppBar traz a seta de voltar sozinho: de qualquer tela da para sair
      // (regra 6.6).
      appBar: AppBar(title: const Text(TelaCadastroTarefa.titulo)),
      body: SafeArea(
        child: Form(
          key: _formulario,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppEspacos.md),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Escreva o que precisa ser feito e quem vai fazer. '
                      'A tarefa nasce na coluna "A fazer".',
                      style: tema.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppEspacos.lg),
                    TextFormField(
                      controller: _titulo,
                      autofocus: true,
                      maxLength: tamanhoMaximoDoTitulo,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Titulo da tarefa',
                        helperText: 'De 3 a 80 caracteres.',
                        border: OutlineInputBorder(),
                        // O contador "0/80" divide a linha com a mensagem de
                        // erro e a corta ao meio na leitura
                        // ("...o que 0/80 precisa ser feito"). Como o
                        // maxLength ja impede passar de 80 e o helperText ja
                        // avisa o limite, o contador so atrapalha.
                        counterText: '',
                      ),
                      validator: validarTitulo,
                    ),
                    const SizedBox(height: AppEspacos.md),
                    TextFormField(
                      controller: _responsavel,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Quem vai fazer',
                        helperText: 'Nome de quem se responsabiliza.',
                        border: OutlineInputBorder(),
                      ),
                      validator: validarResponsavel,
                    ),
                    const SizedBox(height: AppEspacos.lg),
                    Semantics(
                      header: true,
                      child: Text(
                        'Prioridade',
                        style: tema.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: AppEspacos.sm),
                    SeletorPrioridade(
                      selecionada: _prioridade,
                      aoSelecionar: (Prioridade escolhida) {
                        setState(() => _prioridade = escolhida);
                      },
                    ),
                    const SizedBox(height: AppEspacos.lg),
                    TextFormField(
                      controller: _estimativa,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Estimativa em horas (opcional)',
                        helperText: 'Se nao souber, deixe em branco.',
                        border: OutlineInputBorder(),
                      ),
                      validator: validarEstimativa,
                    ),
                    const SizedBox(height: AppEspacos.xl),
                    SizedBox(
                      width: double.infinity,
                      height: AppEspacos.alvoDeToque,
                      child: FilledButton.icon(
                        onPressed: _salvar,
                        icon: const Icon(Icons.check),
                        label: const Text('Salvar tarefa'),
                      ),
                    ),
                    const SizedBox(height: AppEspacos.md),
                    Text(
                      'A tarefa fica somente neste aparelho.',
                      style: tema.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
