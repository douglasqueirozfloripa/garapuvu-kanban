import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/board/model/tarefa.dart';
import 'leitura_json.dart';

/// O que voltou do disco: as tarefas e, se houve problema, o aviso.
///
/// O aviso viaja junto do resultado em vez de virar um `print` ou uma excecao
/// porque quem precisa saber e a **pessoa**, na tela — nao o console. A regra
/// 6.6 pede que todo erro diga o que aconteceu e qual e o proximo passo, e para
/// isso o texto precisa chegar ate a interface.
class ResultadoDaCarga {
  /// Cria o resultado.
  const ResultadoDaCarga({required this.tarefas, this.aviso});

  /// As tarefas que deu para ler.
  final List<Tarefa> tarefas;

  /// Explicacao em portugues, quando algo foi perdido. `null` se correu tudo bem.
  final String? aviso;

  /// `true` quando alguma coisa nao pode ser lida.
  bool get houveProblema => aviso != null;
}

/// Guarda e le o quadro no proprio aparelho.
///
/// Usa `shared_preferences`, o "cofrinho" do aparelho — o equivalente ao
/// `localStorage` do navegador. **Nada sai do celular**: nao ha servidor, conta
/// nem envio (regra de negocio 8).
///
/// O quadro inteiro e gravado como **um** texto JSON, e nao uma chave por
/// tarefa. Assim salvar e uma operacao so, sem risco de meia gravacao deixar o
/// quadro pela metade.
class RepositorioDeTarefas {
  /// Cria o repositorio.
  ///
  /// [preferencias] pode ser injetado nos testes; em producao ele e obtido de
  /// `SharedPreferences.getInstance()` na primeira vez que for preciso.
  RepositorioDeTarefas({SharedPreferences? preferencias})
      : _preferencias = preferencias;

  SharedPreferences? _preferencias;

  /// A chave onde o quadro fica guardado.
  ///
  /// O `v1` no fim e proposital: se um dia o formato mudar, a versao nova le a
  /// chave antiga, converte e grava na nova, sem atropelar quem ainda nao
  /// atualizou.
  static const String chave = 'garapuvu.quadro.v1';

  Future<SharedPreferences> get _cofre async =>
      _preferencias ??= await SharedPreferences.getInstance();

  /// Grava a lista inteira de tarefas.
  Future<void> salvar(List<Tarefa> tarefas) async {
    final SharedPreferences cofre = await _cofre;
    final String texto = jsonEncode(
      tarefas.map((Tarefa tarefa) => tarefa.toJson()).toList(),
    );
    await cofre.setString(chave, texto);
  }

  /// Le as tarefas gravadas.
  ///
  /// **Nunca estoura.** Os tres jeitos de dar errado sao tratados assim:
  ///
  /// 1. **Nao ha nada gravado** — primeira vez que o app abre. Devolve lista
  ///    vazia, sem aviso: nao e problema.
  /// 2. **O texto inteiro nao e JSON valido** — arquivo truncado ou editado na
  ///    mao. Devolve lista vazia **com aviso**.
  /// 3. **Uma tarefa do meio esta estragada** — as boas sao mantidas e o aviso
  ///    diz quantas se perderam. Descartar as 20 tarefas boas por causa de uma
  ///    quebrada seria pior do que o proprio defeito.
  Future<ResultadoDaCarga> carregar() async {
    final SharedPreferences cofre = await _cofre;
    final String? texto = cofre.getString(chave);

    if (texto == null || texto.trim().isEmpty) {
      return const ResultadoDaCarga(tarefas: <Tarefa>[]);
    }

    final Object? bruto;
    try {
      bruto = jsonDecode(texto);
    } on FormatException {
      return const ResultadoDaCarga(
        tarefas: <Tarefa>[],
        aviso: 'Nao foi possivel ler as tarefas guardadas neste aparelho: o '
            'arquivo esta danificado. O quadro comecou vazio. Voce pode criar '
            'as tarefas de novo — nada foi enviado para lugar nenhum.',
      );
    }

    if (bruto is! List) {
      return const ResultadoDaCarga(
        tarefas: <Tarefa>[],
        aviso: 'As tarefas guardadas estavam num formato que este app nao '
            'reconhece. O quadro comecou vazio.',
      );
    }

    final List<Tarefa> lidas = <Tarefa>[];
    int descartadas = 0;

    for (final Object? item in bruto) {
      try {
        lidas.add(Tarefa.fromJson(comoMapa(item, 'tarefa')));
      } on DadoInvalido {
        descartadas++;
      }
    }

    return ResultadoDaCarga(
      tarefas: lidas,
      aviso: descartadas == 0 ? null : _avisoDeDescarte(descartadas),
    );
  }

  /// Apaga tudo o que estiver guardado (usado pelo "apagar meus dados").
  Future<void> apagarTudo() async {
    final SharedPreferences cofre = await _cofre;
    await cofre.remove(chave);
  }

  static String _avisoDeDescarte(int quantas) {
    final String plural = quantas == 1
        ? '1 tarefa guardada estava danificada e nao pode ser aberta'
        : '$quantas tarefas guardadas estavam danificadas e nao puderam ser '
            'abertas';
    return '$plural. As demais foram carregadas normalmente. Se sentir falta '
        'de alguma, sera preciso cria-la de novo.';
  }
}
