import 'package:flutter/foundation.dart';

import '../../../data/repositorio_de_tarefas.dart';
import '../model/regras_quadro.dart';
import '../model/status.dart';
import '../model/tarefa.dart';

/// O estado do quadro: quem guarda as tarefas enquanto o app esta aberto.
///
/// E um [ChangeNotifier] — o objeto que **avisa** quem estiver escutando quando
/// algo muda. As telas escutam via `Provider` e se redesenham sozinhas; nenhuma
/// tela precisa saber que existe disco por baixo.
///
/// Ele e a unica porta entre a interface e as duas camadas de baixo:
///
/// - as **regras** (`model/regras_quadro.dart`), que dizem o que pode;
/// - o **repositorio** (`data/`), que grava.
///
/// Toda mudanca segue o mesmo ritmo: muda em memoria, avisa a tela, grava no
/// disco. A gravacao vem **por ultimo** de proposito — a tela responde na hora,
/// sem esperar o disco.
class QuadroController extends ChangeNotifier {
  /// Cria o controller.
  QuadroController({RepositorioDeTarefas? repositorio})
      : _repositorio = repositorio ?? RepositorioDeTarefas();

  final RepositorioDeTarefas _repositorio;
  final List<Tarefa> _tarefas = <Tarefa>[];

  bool _carregando = false;
  String? _aviso;

  /// As tarefas do quadro, em modo somente leitura.
  ///
  /// A lista devolvida nao pode ser alterada: quem quiser mudar o quadro passa
  /// pelos metodos daqui, que aplicam as regras e gravam.
  List<Tarefa> get tarefas => List<Tarefa>.unmodifiable(_tarefas);

  /// `true` enquanto as tarefas estao sendo lidas do aparelho.
  ///
  /// E o que a tela usa para mostrar a flor girando (`IndicadorFlor`).
  bool get carregando => _carregando;

  /// Recado pendente para a pessoa, ou `null` se nao ha nenhum.
  ///
  /// Vem do repositorio (dado danificado) ou das regras (limite de WIP).
  String? get aviso => _aviso;

  /// **Todas** as tarefas do quadro na ordem em que a lista as mostra:
  /// prioridade primeiro e, no empate, a mais antiga na frente (regra de
  /// negocio 4).
  ///
  /// E uma lista so, atravessando as quatro colunas de proposito: a pergunta
  /// que ela responde e "o que e mais urgente agora?", e essa resposta nao
  /// muda de acordo com a coluna. A visao separada por coluna e [daColuna], e
  /// e ela que vira o quadro no Prompt 6.
  List<Tarefa> get emOrdemDePrioridade => ordenarPorPrioridade(_tarefas);

  /// As tarefas de uma coluna, na ordem de prioridade (regra de negocio 4).
  List<Tarefa> daColuna(Status status) => ordenarPorPrioridade(
        _tarefas.where((Tarefa t) => t.status == status).toList(),
      );

  /// Le do aparelho as tarefas guardadas.
  ///
  /// Chamado uma vez, quando o app abre. Se o dado estiver danificado, o quadro
  /// comeca vazio e [aviso] explica o que houve — o app nunca quebra por causa
  /// disso.
  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();

    final ResultadoDaCarga resultado = await _repositorio.carregar();

    _tarefas
      ..clear()
      ..addAll(resultado.tarefas);
    _aviso = resultado.aviso;
    _carregando = false;
    notifyListeners();
  }

  /// Acrescenta uma tarefa nova ao quadro.
  Future<void> adicionar(Tarefa tarefa) async {
    _tarefas.add(tarefa);
    _aviso = null;
    notifyListeners();
    await _gravar();
  }

  /// Remove a tarefa de [id]. Nada acontece se ela nao existir.
  Future<void> remover(String id) async {
    _tarefas.removeWhere((Tarefa t) => t.id == id);
    notifyListeners();
    await _gravar();
  }

  /// Empurra a tarefa para a proxima coluna.
  ///
  /// Devolve `true` quando andou. Devolve `false` — **sem mudar nada** — nos
  /// dois casos em que a regra nao deixa: a tarefa ja esta na ultima coluna, ou
  /// a pessoa responsavel ja atingiu o limite de WIP. No segundo caso, [aviso]
  /// passa a explicar o porque (regra de negocio 3).
  Future<bool> avancar(String id) async {
    final Tarefa? tarefa = _porId(id);
    if (tarefa == null) {
      return false;
    }

    final Status? destino = avancarStatus(tarefa.status);
    if (destino == null) {
      return false;
    }

    if (destino == Status.fazendo &&
        !podeEntrarEmFazendo(
          tarefasDoQuadro: _tarefas,
          responsavel: tarefa.responsavel,
        )) {
      _aviso = motivoDoLimiteDeWip(tarefa.responsavel);
      notifyListeners();
      return false;
    }

    return _mover(tarefa, destino);
  }

  /// Puxa a tarefa de volta para a coluna anterior.
  ///
  /// Voltar **nao** passa pelo limite de WIP quando sai de `Fazendo`: tirar
  /// trabalho de cima de alguem nunca pode ser bloqueado. Ao voltar PARA
  /// `Fazendo` (vindo de `Em revisao`), o limite vale — senao ele teria uma
  /// porta dos fundos.
  Future<bool> voltar(String id) async {
    final Tarefa? tarefa = _porId(id);
    if (tarefa == null) {
      return false;
    }

    final Status? destino = voltarStatus(tarefa.status);
    if (destino == null) {
      return false;
    }

    if (destino == Status.fazendo &&
        !podeEntrarEmFazendo(
          tarefasDoQuadro: _tarefas,
          responsavel: tarefa.responsavel,
        )) {
      _aviso = motivoDoLimiteDeWip(tarefa.responsavel);
      notifyListeners();
      return false;
    }

    return _mover(tarefa, destino);
  }

  /// Esquece o recado pendente, depois de a tela te-lo mostrado.
  void limparAviso() {
    if (_aviso == null) {
      return;
    }
    _aviso = null;
    notifyListeners();
  }

  /// Apaga todas as tarefas, do quadro e do aparelho (Prompt 10, LGPD).
  Future<void> apagarTudo() async {
    _tarefas.clear();
    _aviso = null;
    notifyListeners();
    await _repositorio.apagarTudo();
  }

  Tarefa? _porId(String id) {
    for (final Tarefa tarefa in _tarefas) {
      if (tarefa.id == id) {
        return tarefa;
      }
    }
    return null;
  }

  Future<bool> _mover(Tarefa tarefa, Status destino) async {
    _tarefas[_tarefas.indexOf(tarefa)] = tarefa.copyWith(status: destino);
    _aviso = null;
    notifyListeners();
    await _gravar();
    return true;
  }

  Future<void> _gravar() => _repositorio.salvar(_tarefas);
}
