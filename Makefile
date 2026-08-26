# Atalhos de comando — equivalente aos scripts do package.json no template web.
#
#   Qualidade : make prepare | format | lint | test | check | e2e
#   Rodar     : make run | build-local
#   Buildar   : make build | build-android | build-ios | build-web
#   Publicar  : make build-deploy | build-ipa | artefatos
#   Ajuda     : make ajuda   (lista todos os comandos com uma linha cada)

.PHONY: prepare format lint test check e2e run clean bootstrap doctor ajuda \
        build build-local build-android build-ios build-ipa build-web \
        build-deploy artefatos

## prepare: instala dependencias e ATIVA o hook de pre-commit (rode uma vez)
prepare:
	flutter pub get
	git config core.hooksPath .githooks
	chmod +x .githooks/pre-commit
	@echo "OK: dependencias instaladas e hook de pre-commit ativo."

## format: formata todo o codigo (equivalente ao Prettier --write)
format:
	dart format .

## lint: analise estatica (equivalente ao ESLint)
lint:
	flutter analyze

## test: testes unitarios + de widget
test:
	flutter test

## check: o par que o pre-commit repete + os testes. RODAR ANTES DE ENCERRAR.
check:
	dart format --set-exit-if-changed .
	flutter analyze
	flutter test

## e2e: testes ponta a ponta (precisa de um dispositivo/emulador conectado)
e2e:
	flutter test integration_test

## run: roda o app
run:
	flutter run

## clean: limpa artefatos de build
clean:
	flutter clean

## bootstrap: completa as pastas de plataforma (android/ios/web) sem apagar o codigo
bootstrap:
	bash scripts/bootstrap.sh

## doctor: mostra o que ainda falta instalar para buildar (Android SDK, Xcode...)
doctor:
	flutter doctor

# ===========================================================================
# BUILD — transformar o codigo em arquivo instalavel
#
# "Buildar" (ou "compilar") e pegar o codigo Dart e gerar o arquivo que o
# aparelho sabe abrir:
#
#   Android : .apk  (instala direto no celular)  e  .aab  (envio para a Play)
#   iOS     : .app  (sem assinatura, so para testar)  e  .ipa  (App Store)
#   Web     : uma pasta com o site pronto (build/web/)
#
# Tudo o que for gerado cai na pasta build/, que o .gitignore ja ignora —
# arquivo compilado NAO entra no historico do Git.
# ===========================================================================

# Versao opcional na hora do build. Sem elas, vale o que esta no pubspec.yaml
# (version: 0.1.0+1). VERSAO e o que a pessoa ve; NUMERO e o contador interno
# que as lojas exigem que cresca a cada envio.
#   Exemplo:  make build-android VERSAO=0.2.0 NUMERO=7
VERSAO ?=
NUMERO ?=
MARCA_VERSAO := $(if $(VERSAO),--build-name=$(VERSAO)) $(if $(NUMERO),--build-number=$(NUMERO))

# Plataforma usada pelo "make build-local". O padrao e web porque compila em
# qualquer maquina, sem depender do SDK do Android nem do Xcode.
#   Exemplo:  make build-local PLATAFORMA=android
PLATAFORMA ?= web

# Guardas: em vez de deixar o Flutter falhar com uma mensagem cifrada, o
# Makefile explica o que aconteceu e qual e o proximo passo (nenhum beco sem saida).
# GUARDA_* e o teste em si (serve dentro de um "case" do shell);
# EXIGE_* e o mesmo teste como linha de receita (o @ esconde o eco do comando).
GUARDA_PASTA = test -d "$(1)" || { printf '\nERRO: a pasta %s/ nao existe neste projeto.\n      Ela e criada uma unica vez pelo comando:  make bootstrap\n\n' "$(1)"; exit 1; }
GUARDA_MAC = test "$$(uname -s)" = "Darwin" || { printf '\nERRO: build de iOS so roda no macOS, com o Xcode instalado.\n      No Linux/Windows, use:  make build-android\n\n'; exit 1; }
EXIGE_PASTA = @$(call GUARDA_PASTA,$(1))
EXIGE_MAC = @$(GUARDA_MAC)

## build: (a) gera o app em modo release para TODAS as plataformas
build: build-android build-ios build-web
	@$(MAKE) --no-print-directory artefatos

## build-local: (b) compilacao rapida em modo debug, so para conferir que o app
##              compila NESTA maquina. Nao serve para loja.
##              Escolha a plataforma: make build-local PLATAFORMA=web|android|ios
build-local:
	@printf '\n==> Compilacao local (debug) para: %s\n\n' "$(PLATAFORMA)"
	@case "$(PLATAFORMA)" in \
	  web) flutter build web --profile $(MARCA_VERSAO) ;; \
	  android) $(call GUARDA_PASTA,android); flutter build apk --debug $(MARCA_VERSAO) ;; \
	  ios) $(GUARDA_MAC); $(call GUARDA_PASTA,ios); flutter build ios --simulator $(MARCA_VERSAO) ;; \
	  *) printf '\nERRO: PLATAFORMA="%s" nao existe.\n      Use uma destas:  web | android | ios\n\n' "$(PLATAFORMA)"; exit 1 ;; \
	esac
	@printf '\nOK: o app compila nesta maquina. Para rodar de verdade: make run\n\n'

## build-deploy: (c) prepara o pacote de DEPLOY (lojas): checa qualidade, limpa o
##               build antigo e gera AAB (Google Play) + IPA (App Store) + web.
build-deploy: check
	@printf '\n==> Limpando o build anterior para nao misturar arquivo velho...\n\n'
	flutter clean
	flutter pub get
	@$(MAKE) --no-print-directory build-android
	@$(MAKE) --no-print-directory build-ipa
	@$(MAKE) --no-print-directory build-web
	@$(MAKE) --no-print-directory artefatos
	@printf 'Antes de enviar para as lojas, confira:\n'
	@printf '  1. o NUMERO da versao subiu (make build-deploy VERSAO=0.2.0 NUMERO=8);\n'
	@printf '  2. a chave de assinatura do Android esta em android/key.properties;\n'
	@printf '  3. o certificado da Apple esta configurado no Xcode.\n\n'

## build-ios: (d) gera a versao iOS em release, SEM assinatura (para conferir que
##            compila e testar no aparelho de desenvolvimento).
build-ios:
	$(EXIGE_MAC)
	$(call EXIGE_PASTA,ios)
	flutter build ios --release --no-codesign $(MARCA_VERSAO)
	@printf '\nOK iOS: build/ios/iphoneos/Runner.app  (sem assinatura)\n      Para a App Store, use:  make build-ipa\n\n'

## build-ipa: (d+) gera o .ipa ASSINADO para a App Store (exige conta Apple
##            Developer configurada no Xcode).
build-ipa:
	$(EXIGE_MAC)
	$(call EXIGE_PASTA,ios)
	@flutter build ipa --release $(MARCA_VERSAO) || { \
	  printf '\nERRO: o .ipa nao foi gerado — quase sempre e assinatura faltando.\n'; \
	  printf '      1. abra ios/Runner.xcworkspace no Xcode;\n'; \
	  printf '      2. em Signing & Capabilities, escolha o seu Team;\n'; \
	  printf '      3. rode este comando de novo.\n'; \
	  printf '      Para so conferir que compila, sem assinar:  make build-ios\n\n'; \
	  exit 1; }
	@printf '\nOK iOS: o .ipa esta em build/ios/ipa/\n\n'

## build-android: (e) gera a versao Android: APK (instalar direto no aparelho)
##                e AAB (formato que o Google Play exige).
build-android:
	$(call EXIGE_PASTA,android)
	flutter build apk --release $(MARCA_VERSAO)
	flutter build appbundle --release $(MARCA_VERSAO)
	@printf '\nOK Android:\n  APK: build/app/outputs/flutter-apk/app-release.apk\n  AAB: build/app/outputs/bundle/release/app-release.aab\n\n'

## build-web: gera o site do app (bonus: o time abre no navegador, sem instalar)
build-web:
	$(call EXIGE_PASTA,web)
	flutter build web --release $(MARCA_VERSAO)
	@printf '\nOK Web: build/web/ (suba essa pasta em qualquer hospedagem estatica)\n\n'

## artefatos: mostra quais arquivos de build ja existem e para que serve cada um
artefatos:
	@printf '\n== Arquivos gerados em build/ ==\n'
	@mostrar() { if [ -n "$$2" ] && [ -e "$$2" ]; then printf '  [x] %-32s %s\n' "$$1" "$$2"; else printf '  [ ] %-32s (ainda nao gerado)\n' "$$1"; fi; }; \
	mostrar "APK - instalar no Android" "build/app/outputs/flutter-apk/app-release.apk"; \
	mostrar "AAB - enviar ao Google Play" "build/app/outputs/bundle/release/app-release.aab"; \
	mostrar "APP - iOS sem assinatura" "build/ios/iphoneos/Runner.app"; \
	mostrar "IPA - enviar a App Store" "$$(ls build/ios/ipa/*.ipa 2>/dev/null | head -1)"; \
	mostrar "WEB - site pronto" "build/web/index.html"
	@printf '\n'

## ajuda: lista todos os comandos deste Makefile
ajuda:
	@printf '\nComandos do Garapuvu Kanban:\n\n'
	@grep -E '^## ' $(MAKEFILE_LIST) | sed -e 's/^##  /        /' -e 's/^## /  make /'
	@printf '\n'
