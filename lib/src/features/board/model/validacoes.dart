/// Validacoes dos campos de uma tarefa, em Dart puro.
///
/// Toda funcao daqui devolve `null` quando o valor presta, ou a **mensagem de
/// erro em portugues** quando nao. Devolver a mensagem, em vez de
/// `true`/`false`, faz o erro dizer o que aconteceu e qual e o proximo passo
/// (regra 6.6) e encaixa direto no `validator` de um campo de formulario.
///
/// Elas moram longe da tela de proposito: a mesma regra vale para o formulario,
/// para a importacao de dados e para qualquer tela futura, sem copiar texto.
library;

/// Menor titulo aceito, em caracteres (regra de negocio 5).
const int tamanhoMinimoDoTitulo = 3;

/// Maior titulo aceito, em caracteres (regra de negocio 5).
const int tamanhoMaximoDoTitulo = 80;

/// Maior estimativa aceita, em horas.
///
/// 40 horas e uma semana de trabalho. Acima disso a tarefa nao cabe numa
/// sprint curta e precisa ser quebrada — e o app diz isso em vez de aceitar
/// calado.
const int estimativaMaximaEmHoras = 40;

/// Confere o titulo de uma tarefa (regra de negocio 5).
///
/// Devolve `null` quando o titulo presta, ou a **mensagem de erro em
/// portugues** quando nao. Devolver a mensagem, em vez de `true`/`false`, faz o
/// erro dizer o que aconteceu e qual e o proximo passo (regra 6.6) e encaixa
/// direto no `validator` de um campo de formulario.
///
/// Espacos das pontas nao contam: um titulo so de espacos e um titulo vazio.
String? validarTitulo(String? titulo) {
  final String limpo = (titulo ?? '').trim();

  if (limpo.isEmpty) {
    return 'Escreva um titulo para a tarefa: em poucas palavras, o que '
        'precisa ser feito.';
  }
  if (limpo.length < tamanhoMinimoDoTitulo) {
    return 'O titulo esta curto demais. Use pelo menos '
        '$tamanhoMinimoDoTitulo caracteres para o time entender a tarefa.';
  }
  if (limpo.length > tamanhoMaximoDoTitulo) {
    return 'O titulo passou de $tamanhoMaximoDoTitulo caracteres '
        '(tem ${limpo.length}). Encurte o titulo e leve o resto para a '
        'descricao.';
  }
  return null;
}

/// Confere o nome de quem vai fazer a tarefa (regra de negocio 5).
///
/// Devolve `null` quando o nome presta, ou a mensagem de erro em portugues.
/// Toda tarefa tem dono: sem responsavel nao ha como contar o limite de WIP,
/// que e contado **por pessoa**.
String? validarResponsavel(String? responsavel) {
  final String limpo = (responsavel ?? '').trim();

  if (limpo.isEmpty) {
    return 'Diga quem vai fazer esta tarefa. Toda tarefa tem uma pessoa '
        'responsavel.';
  }
  return null;
}

/// Confere a estimativa em horas, que e **opcional** (regra de negocio 5).
///
/// Devolve `null` quando esta em branco (o que e valido) ou quando o numero
/// presta; caso contrario, a mensagem de erro.
String? validarEstimativa(String? estimativa) {
  final String limpo = (estimativa ?? '').trim();

  if (limpo.isEmpty) {
    return null;
  }

  final int? horas = int.tryParse(limpo);
  if (horas == null) {
    return 'A estimativa precisa ser um numero de horas. Ex.: 3. Se nao '
        'souber, deixe em branco.';
  }
  if (horas <= 0) {
    return 'A estimativa precisa ser maior que zero. Se nao souber, deixe '
        'em branco.';
  }
  if (horas > estimativaMaximaEmHoras) {
    return 'Estimativa de mais de $estimativaMaximaEmHoras horas: a tarefa '
        'esta grande demais. Quebre em tarefas menores.';
  }
  return null;
}
