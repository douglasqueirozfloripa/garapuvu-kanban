import 'package:flutter_test/flutter_test.dart';
import 'package:garapuvu_kanban/src/core/utils/contraste.dart';

/// Cores de referencia, no formato 0xAARRGGBB.
const int _preto = 0xFF000000;
const int _branco = 0xFFFFFFFF;
const int _cinzaMedio = 0xFF808080;

void main() {
  group('luminanciaRelativa', () {
    test('preto e 0 e branco e 1 — as duas pontas da escala', () {
      expect(luminanciaRelativa(_preto), 0);
      expect(luminanciaRelativa(_branco), 1);
    });

    test('ignora o canal alfa', () {
      expect(
        luminanciaRelativa(0x00FFFFFF),
        luminanciaRelativa(0xFFFFFFFF),
      );
    });

    test('verde pesa mais que vermelho, e vermelho mais que azul', () {
      final double verde = luminanciaRelativa(0xFF00FF00);
      final double vermelho = luminanciaRelativa(0xFFFF0000);
      final double azul = luminanciaRelativa(0xFF0000FF);

      expect(verde, greaterThan(vermelho));
      expect(vermelho, greaterThan(azul));
    });
  });

  group('razaoDeContraste', () {
    test('preto no branco da 21:1, o maximo possivel', () {
      expect(razaoDeContraste(_preto, _branco), closeTo(21, 0.01));
    });

    test('a cor com ela mesma da 1:1, o minimo possivel', () {
      expect(razaoDeContraste(_branco, _branco), closeTo(1, 0.0001));
      expect(razaoDeContraste(_cinzaMedio, _cinzaMedio), closeTo(1, 0.0001));
    });

    test('a ordem dos argumentos nao muda o resultado', () {
      expect(
        razaoDeContraste(_preto, _cinzaMedio),
        closeTo(razaoDeContraste(_cinzaMedio, _preto), 0.0001),
      );
    });

    test('bate com o valor publicado pelo W3C para #767676 no branco', () {
      // 4.54:1 e o exemplo que a propria WCAG usa como o cinza mais claro que
      // ainda passa em AA sobre branco.
      expect(
        razaoDeContraste(0xFF767676, _branco),
        closeTo(4.54, 0.01),
      );
    });
  });

  group('passaAa', () {
    test('4.5 passa para texto normal; 4.49 nao', () {
      expect(passaAa(4.5), isTrue);
      expect(passaAa(4.49), isFalse);
    });

    test('texto grande tem exigencia menor: 3 basta', () {
      expect(passaAa(3, textoGrande: true), isTrue);
      expect(passaAa(2.99, textoGrande: true), isFalse);
      expect(passaAa(3), isFalse, reason: '3 nao basta para texto normal');
    });

    test('nao reprova um valor que o relatorio arredonda para o minimo', () {
      // 4.4996 aparece como "4.50:1" no relatorio. Mostrar 4.50 com selo
      // FALHA confundiria quem le.
      expect(passaAa(4.4996), isTrue);
      expect(formatarRazao(4.4996), '4.50:1');
    });
  });

  group('formatacao do relatorio', () {
    test('mostra duas casas decimais e o sufixo :1', () {
      expect(formatarRazao(21), '21.00:1');
      expect(formatarRazao(4.532), '4.53:1');
    });

    test('o selo diz PASSA ou FALHA AA', () {
      expect(seloAa(21), 'PASSA AA');
      expect(seloAa(1), 'FALHA AA');
      expect(seloAa(3, textoGrande: true), 'PASSA AA');
    });
  });
}
