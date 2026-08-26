#!/usr/bin/env python3
"""Gera os icones do app a partir da flor do Garapuvu.

Por que este script existe
--------------------------
O icone do app precisa existir em ~25 tamanhos diferentes (Android e iOS), e
refazer isso na mao a cada ajuste da marca seria trabalhoso e sujeito a erro.
Aqui a flor e DESENHADA por codigo, com a mesma geometria do
`assets/images/favicon-garapuvu.svg` — cinco petalas giradas de 72 graus em
torno de um miolo ambar — e todos os tamanhos saem de uma vez.

Nao usamos o pacote `flutter_launcher_icons` de proposito: ele resolveria o
mesmo problema, mas acrescentaria uma dependencia e esconderia a conta. Aqui da
para ler o desenho.

Uso:
    make icones          (ou: python3 scripts/gerar_icones.py)
"""

from __future__ import annotations

import json
import math
import pathlib
import sys

try:
    from PIL import Image, ImageDraw
except ImportError:
    sys.exit(
        'ERRO: falta a biblioteca Pillow, que desenha as imagens.\n'
        '      Instale com:  python3 -m pip install --user Pillow\n'
        '      Depois rode de novo:  make icones'
    )

RAIZ = pathlib.Path(__file__).resolve().parent.parent

# --- Cores da marca, iguais as de lib/src/core/theme/app_cores.dart ---------
AZUL_NOITE = (0x0E, 0x1F, 0x38, 255)  # --gp-band
FLOR = (0xF2, 0xB7, 0x05, 255)        # --gp-bloom
FLOR_QUENTE = (0xE0, 0x8A, 0x00, 255) # --gp-bloom-warm

# --- Geometria do favicon.svg, numa arte de 100x100 ------------------------
PETALAS = 5
PETALA_CENTRO_Y = -22.0
PETALA_RAIO_X = 12.0
PETALA_RAIO_Y = 24.0
MIOLO_EXTERNO = 11.0
MIOLO_INTERNO = 4.5
CANTO_ARREDONDADO = 22.0

# Desenhamos ampliado e reduzimos no fim: e o que deixa a borda lisa, sem
# serrilhado. 4x ja e suficiente e mantem o script rapido.
SUPERAMOSTRAGEM = 4


def _desenhar_flor(desenho: ImageDraw.ImageDraw, centro: float, escala: float) -> None:
    """Desenha a flor centrada em (centro, centro), na escala dada."""
    for i in range(PETALAS):
        angulo = 2 * math.pi * i / PETALAS
        # Roda o centro da petala em torno do miolo.
        x = -PETALA_CENTRO_Y * math.sin(angulo)
        y = PETALA_CENTRO_Y * math.cos(angulo)

        # A petala e uma elipse inclinada; o Pillow so desenha elipse "reta",
        # entao ela e desenhada numa camada propria e girada.
        largura = int(PETALA_RAIO_X * 2 * escala)
        altura = int(PETALA_RAIO_Y * 2 * escala)
        petala = Image.new('RGBA', (largura, altura), (0, 0, 0, 0))
        ImageDraw.Draw(petala).ellipse((0, 0, largura - 1, altura - 1), fill=FLOR)
        girada = petala.rotate(
            -math.degrees(angulo), resample=Image.BICUBIC, expand=True
        )

        desenho._image.paste(  # type: ignore[attr-defined]
            girada,
            (
                int(centro + x * escala - girada.width / 2),
                int(centro + y * escala - girada.height / 2),
            ),
            girada,
        )

    for raio, cor in ((MIOLO_EXTERNO, FLOR_QUENTE), (MIOLO_INTERNO, FLOR)):
        r = raio * escala
        desenho.ellipse(
            (centro - r, centro - r, centro + r, centro + r), fill=cor
        )


def _tela(lado: int) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    imagem = Image.new('RGBA', (lado, lado), (0, 0, 0, 0))
    desenho = ImageDraw.Draw(imagem)
    desenho._image = imagem  # type: ignore[attr-defined]
    return imagem, desenho


def icone_completo(lado: int, *, com_fundo: bool = True, ocupacao: float = 0.92) -> Image.Image:
    """O icone quadrado: fundo azul-noite arredondado + a flor.

    [ocupacao] e a fatia do quadrado que a flor ocupa. No favicon original ela
    toma quase tudo (0,92); no icone adaptativo do Android ela precisa ser
    menor, porque o sistema recorta as bordas.
    """
    grande = lado * SUPERAMOSTRAGEM
    imagem, desenho = _tela(grande)

    if com_fundo:
        desenho.rounded_rectangle(
            (0, 0, grande - 1, grande - 1),
            radius=CANTO_ARREDONDADO / 100 * grande,
            fill=AZUL_NOITE,
        )

    # A flor do SVG mede 2*(22+24) = 92 unidades numa arte de 100.
    escala = grande * ocupacao / 92.0
    _desenhar_flor(desenho, grande / 2, escala)

    return imagem.resize((lado, lado), Image.LANCZOS)


def _gravar(imagem: Image.Image, caminho: pathlib.Path) -> None:
    caminho.parent.mkdir(parents=True, exist_ok=True)
    imagem.save(caminho, 'PNG')
    print(f'    + {caminho.relative_to(RAIZ)}')


def gerar_android() -> None:
    """Icone classico + icone adaptativo (Android 8+ e a abertura do Android 12+)."""
    print('==> Android')
    densidades = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}
    res = RAIZ / 'android/app/src/main/res'

    for nome, fator in densidades.items():
        # Classico: 48 dp, com fundo.
        _gravar(
            icone_completo(round(48 * fator)),
            res / f'mipmap-{nome}/ic_launcher.png',
        )
        # Adaptativo: a arte tem 108 dp e o sistema mostra so os 72 dp do meio.
        # Por isso a flor ocupa ~55%: o resto e margem de recorte.
        _gravar(
            icone_completo(round(108 * fator), com_fundo=False, ocupacao=0.55),
            res / f'mipmap-{nome}/ic_launcher_foreground.png',
        )

    # O fundo do icone adaptativo e uma cor solida, nao uma imagem.
    _texto(
        res / 'values/ic_launcher_background.xml',
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<!-- Fundo do icone adaptativo: o azul-noite da marca Garapuvu. -->\n'
        '<resources>\n'
        '    <color name="ic_launcher_background">#0E1F38</color>\n'
        '</resources>\n',
    )
    # A camada `monochrome` e o que o Android 13+ usa no tema do sistema.
    _texto(
        res / 'mipmap-anydpi-v26/ic_launcher.xml',
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background" />\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
        '    <monochrome android:drawable="@mipmap/ic_launcher_foreground" />\n'
        '</adaptive-icon>\n',
    )


def gerar_ios() -> None:
    """Todos os tamanhos que o Contents.json do Xcode declara."""
    print('==> iOS')
    pasta = RAIZ / 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    conteudo = json.loads((pasta / 'Contents.json').read_text())

    for entrada in conteudo['images']:
        arquivo = entrada.get('filename')
        if not arquivo:
            continue
        lado_base = float(entrada['size'].split('x')[0])
        fator = float(entrada['scale'].rstrip('x'))
        # O iOS NAO aceita transparencia no icone e arredonda o canto sozinho:
        # por isso o quadrado vai cheio, sem canto arredondado nosso.
        icone = icone_completo(round(lado_base * fator))
        _gravar(icone.convert('RGB'), pasta / arquivo)


def gerar_referencia() -> None:
    """Uma copia grande, para slides e para o README."""
    print('==> Referencia')
    _gravar(icone_completo(512), RAIZ / 'docs/screenshots/icone-garapuvu.png')


def _texto(caminho: pathlib.Path, conteudo: str) -> None:
    caminho.parent.mkdir(parents=True, exist_ok=True)
    caminho.write_text(conteudo)
    print(f'    + {caminho.relative_to(RAIZ)}')


if __name__ == '__main__':
    print('\nGerando os icones a partir da flor do Garapuvu...\n')
    gerar_android()
    gerar_ios()
    gerar_referencia()
    print('\nPronto. Para ver no aparelho:  make parar && make rodar\n')
