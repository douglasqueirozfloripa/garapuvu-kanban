#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# bootstrap.sh — completa o projeto com as pastas de PLATAFORMA.
#
# Por que este script existe:
#   O codigo Dart, os testes, a documentacao e o ferramental deste repositorio
#   ja estao prontos. Faltam apenas as pastas geradas pelo proprio Flutter para
#   cada plataforma (android/, ios/, web/...). Rodar `flutter create .` direto
#   aqui funcionaria, mas ele SOBRESCREVE pubspec.yaml, lib/main.dart e
#   analysis_options.yaml — apagando o que ja foi escrito.
#
#   Entao o script cria um projeto limpo num diretorio TEMPORARIO e copia de la
#   somente as pastas de plataforma. Nada do seu codigo e tocado.
#
# Uso:
#   make bootstrap        (ou: bash scripts/bootstrap.sh)
# ---------------------------------------------------------------------------
set -euo pipefail

NOME_PROJETO="garapuvu_kanban"
ORG="br.org.garapuvu"
PLATAFORMAS="${PLATAFORMAS:-android,ios,web}"

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$RAIZ"

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERRO: o comando 'flutter' nao foi encontrado no PATH."
  echo "      Instale o SDK (veja a secao 'Instalando o Flutter' do README.md)"
  echo "      e rode 'flutter doctor' antes de tentar de novo."
  exit 1
fi

TEMP="$(mktemp -d)"
trap 'rm -rf "$TEMP"' EXIT

echo "==> Gerando o esqueleto de plataforma em um diretorio temporario..."
flutter create \
  --project-name "$NOME_PROJETO" \
  --org "$ORG" \
  --platforms "$PLATAFORMAS" \
  --description "Quadro Scrum/Kanban do projeto social Garapuvu" \
  "$TEMP/$NOME_PROJETO" >/dev/null

echo "==> Copiando SOMENTE as pastas de plataforma para o projeto..."
for pasta in android ios web macos linux windows; do
  if [ -d "$TEMP/$NOME_PROJETO/$pasta" ] && [ ! -d "$RAIZ/$pasta" ]; then
    cp -R "$TEMP/$NOME_PROJETO/$pasta" "$RAIZ/$pasta"
    echo "    + $pasta/"
  elif [ -d "$RAIZ/$pasta" ]; then
    echo "    = $pasta/ ja existe, mantido como esta"
  fi
done

if [ ! -f "$RAIZ/.metadata" ]; then
  cp "$TEMP/$NOME_PROJETO/.metadata" "$RAIZ/.metadata"
  echo "    + .metadata"
fi

echo "==> Instalando dependencias e ativando o hook de pre-commit..."
flutter pub get

echo "==> Normalizando a formatacao (dart format)..."
# Roda uma vez aqui para o PRIMEIRO commit ja passar no hook de pre-commit.
dart format .
git config core.hooksPath .githooks 2>/dev/null || true
chmod +x .githooks/pre-commit

echo ""
echo "Pronto. Confira com:"
echo "   make check     # formatacao + analise + testes"
echo "   make run       # roda o app"
