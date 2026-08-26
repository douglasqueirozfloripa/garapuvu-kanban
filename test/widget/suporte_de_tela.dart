import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garapuvu_kanban/src/core/theme/app_theme.dart';
import 'package:garapuvu_kanban/src/features/board/state/quadro_controller.dart';
import 'package:provider/provider.dart';

/// Tamanhos de tela em que TODA tela deste projeto precisa funcionar.
///
/// Regra 6.4 do arquivo de instrucoes: telefone pequeno, telefone comum e
/// tablet. Fica aqui, e nao em cada arquivo de teste, para uma tela nova nunca
/// ser conferida em menos tamanhos que as outras.
const Map<String, Size> tamanhosDeTela = <String, Size>{
  'telefone pequeno (320 dp)': Size(320, 640),
  'telefone comum (390 dp)': Size(390, 844),
  'tablet (768 dp)': Size(768, 1024),
};

/// O tamanho usado nos testes que nao sao sobre layout.
Size get tamanhoPadrao => tamanhosDeTela['telefone comum (390 dp)']!;

/// Monta [tela] sozinha, dentro de um `MaterialApp` com o tema do projeto.
///
/// [escalaDeFonte] simula a pessoa que aumentou a letra do sistema: o projeto
/// exige aguentar 200% sem quebrar.
Future<void> montarTela(
  WidgetTester tester,
  Widget tela, {
  Size? tamanho,
  double escalaDeFonte = 1,
  Brightness brilho = Brightness.light,
  bool aguardarEstabilizar = true,
  QuadroController? quadro,
}) async {
  tester.view.physicalSize = tamanho ?? tamanhoPadrao;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  // Telas que leem o quadro precisam do controller acima delas. Passar um
  // controller no teste deixa o estado explicito, em vez de depender do que o
  // aparelho tiver guardado.
  Widget comQuadro(Widget filho) => quadro == null
      ? filho
      : ChangeNotifierProvider<QuadroController>.value(
          value: quadro,
          child: filho,
        );

  await tester.pumpWidget(
    comQuadro(
      MaterialApp(
        theme:
            brilho == Brightness.light ? AppTheme.claro() : AppTheme.escuro(),
        home: Builder(
          builder: (BuildContext context) {
            return MediaQuery(
              // fromView preserva o tamanho real da tela de teste; so o
              // textScaler muda. Um MediaQueryData vazio daria Size.zero e
              // quebraria o layout inteiro.
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(escalaDeFonte),
              ),
              child: tela,
            );
          },
        ),
      ),
    ),
  );
  // pumpAndSettle espera TODA animacao terminar — e trava para sempre em tela
  // com animacao que se repete, como a flor girando do indicador de espera.
  // Nesses casos, passe `aguardarEstabilizar: false` e avance o relogio com
  // `tester.pump(duracao)`.
  if (aguardarEstabilizar) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

/// A folga vertical, em dp, entre a base de [acima] e o topo de [abaixo].
///
/// O projeto exige folga > 0,5 dp entre elementos vizinhos (regra 6.5): nada
/// pode colar nem se sobrepor.
double folgaVertical(WidgetTester tester, Finder acima, Finder abaixo) {
  return tester.getRect(abaixo).top - tester.getRect(acima).bottom;
}

/// `true` quando o texto encontrado por [finder] esta CORTADO na tela.
///
/// Um `find.textContaining(...)` passa mesmo com o texto truncado em "...",
/// porque ele olha o widget, nao o que a pessoa consegue ler. Esta funcao olha
/// o texto ja desenhado — e foi escrita depois de um screenshot mostrar
/// mensagens de erro cortadas que os testes tinham deixado passar.
bool textoFoiCortado(WidgetTester tester, Finder finder) {
  return tester.renderObject<RenderParagraph>(finder).didExceedMaxLines;
}
