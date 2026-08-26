# Atalhos de comando — equivalente aos scripts do package.json no template web.
#
#   Qualidade : make prepare | format | lint | test | check | e2e
#   Rodar     : make rodar | parar | run APARELHO=android | build-local
#   Emulador  : make emulador-android | emulador-ios
#   Marca     : make icones
#   Buildar   : make build | build-android | build-ios | build-web
#   Publicar  : make build-deploy | build-ipa | artefatos
#   Ajuda     : make ajuda   (lista todos os comandos com uma linha cada)

.PHONY: prepare format lint test check e2e run clean bootstrap doctor ajuda \
        emulador-ios emulador-android rodar parar icones \
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

# Aparelho do "make run". Vazio = o proprio Flutter pergunta qual usar.
#   Exemplo:  make run APARELHO=android
APARELHO ?=

## run: roda o app em UM aparelho, com hot reload
##      (make run APARELHO=android | ios | web | mac)
run:
	@case "$(APARELHO)" in \
	  '') \
	    printf '\n==> Sem APARELHO=, o Flutter vai perguntar qual usar.\n'; \
	    printf '    Para ir direto:  make run APARELHO=android|ios|web|mac\n\n'; \
	    flutter run ;; \
	  android) \
	    id=$$($(ID_EMULADOR_ANDROID)); \
	    test -n "$$id" || { printf '\nERRO: nenhum emulador Android esta aberto.\n      Abra com:  make emulador-android\n\n'; exit 1; }; \
	    flutter run -d "$$id" ;; \
	  ios) \
	    $(GUARDA_MAC); \
	    id=$$($(ID_EMULADOR_IOS)); \
	    test -n "$$id" || { printf '\nERRO: nenhum Simulador de iPhone esta aberto.\n      Abra com:  make emulador-ios\n\n'; exit 1; }; \
	    flutter run -d "$$id" ;; \
	  web) flutter run -d chrome ;; \
	  mac) $(GUARDA_MAC); flutter run -d macos ;; \
	  *) \
	    printf '\nERRO: APARELHO="%s" nao existe.\n' "$(APARELHO)"; \
	    printf '      Use um destes:  android | ios | web | mac\n'; \
	    printf '      Ou veja o que esta conectado com:  flutter devices\n\n'; \
	    exit 1 ;; \
	esac

## clean: limpa artefatos de build
clean:
	flutter clean

## bootstrap: completa as pastas de plataforma (android/ios/web) sem apagar o codigo
bootstrap:
	bash scripts/bootstrap.sh

## doctor: mostra o que ainda falta instalar para buildar (Android SDK, Xcode...)
doctor:
	flutter doctor

## icones: redesenha o icone do app (Android e iOS) a partir da flor do Garapuvu
##         Rode depois de mexer nas cores da marca. Precisa de: pip install Pillow
icones:
	@python3 scripts/gerar_icones.py
	@printf 'O icone so troca no aparelho apos reinstalar:  make parar && make rodar\n\n'

# ===========================================================================
# EMULADORES — abrir um "celular de mentira" dentro do computador
#
# Emulador (Android) e Simulador (iOS) sao celulares que rodam em uma janela do
# seu computador. Servem para ver o app sem precisar de aparelho fisico e para
# rodar o "make e2e". A sequencia normal e:
#
#   1. make emulador-android   (ou make emulador-ios)  <- abre o celular
#   2. make run                (em outro terminal)     <- instala o app nele
#
# Escolher outro aparelho:
#   make emulador-android EMULADOR=Resizable_Experimental   (ids: flutter emulators)
#   make emulador-ios     EMULADOR="iPhone SE (3rd generation)"
#                                  (nomes: xcrun simctl list devices available)
#
# Computador lento? Aumente a espera:  make emulador-android ESPERA=240
# ===========================================================================

# Aparelho escolhido na linha de comando. Vazio = o Makefile decide (abaixo).
EMULADOR ?=

# Sem EMULADOR=, preferimos o emulador criado para este projeto; se ele nao
# existir nesta maquina, cai no primeiro emulador Android da lista.
EMULADOR_PREFERIDO ?= garapuvu

# Quantos segundos esperar o celular acabar de ligar antes de desistir.
ESPERA ?= 180

# IDS_DE: lista, um por linha, os ids dos emuladores de uma plataforma
# ($(1) = ios | android). Le a tabela do "flutter emulators", cujas colunas sao
# separadas por "•":   id • nome • fabricante • plataforma
IDS_DE = flutter emulators 2>/dev/null | awk -F'•' 'NF>=4 { gsub(/^[ \t]+|[ \t]+$$/,"",$$1); gsub(/^[ \t]+|[ \t]+$$/,"",$$4); if ($$4=="$(1)") print $$1 }'

# ESPERA_DISPOSITIVO: aguarda o celular aparecer em "flutter devices". Sem isso o
# "make run" logo depois falha so porque o aparelho ainda estava ligando.
#   $(1) = pedaco de texto que identifica a plataforma na lista de dispositivos
#   $(2) = nome amigavel, usado nas mensagens
ESPERA_DISPOSITIVO = printf 'Aguardando o %s ficar pronto (ate %ss)' "$(2)" "$(ESPERA)"; \
	voltas=$$(( $(ESPERA) / 3 )); i=0; \
	while [ $$i -lt $$voltas ]; do \
	  if flutter devices 2>/dev/null | grep -q '$(1)'; then \
	    printf '\n\nOK: %s pronto. Agora, em outro terminal:  make run\n\n' "$(2)"; \
	    exit 0; \
	  fi; \
	  printf '.'; sleep 3; i=$$((i+1)); \
	done; \
	printf '\n\nAVISO: o %s abriu, mas ainda nao aparece em "flutter devices".\n' "$(2)"; \
	printf '       Espere a tela do celular carregar e confira com:  flutter devices\n'; \
	printf '       Se o computador for lento, tente:  make $@ ESPERA=300\n\n'

## emulador-android: abre o emulador Android e espera ele ficar pronto
emulador-android:
	@ids=$$($(call IDS_DE,android)); \
	if [ -z "$$ids" ]; then \
	  printf '\nERRO: nenhum emulador Android existe nesta maquina.\n'; \
	  printf '      1. veja o que falta instalar:  make doctor\n'; \
	  printf '      2. crie um emulador:           flutter emulators --create --name garapuvu\n'; \
	  printf '      3. rode este comando de novo:  make emulador-android\n\n'; \
	  exit 1; \
	fi; \
	id="$(EMULADOR)"; \
	if [ -z "$$id" ]; then \
	  id=$$(printf '%s\n' "$$ids" | grep -i '$(EMULADOR_PREFERIDO)' | head -1); \
	  [ -n "$$id" ] || id=$$(printf '%s\n' "$$ids" | head -1); \
	elif ! printf '%s\n' "$$ids" | grep -qx "$$id"; then \
	  printf '\nERRO: nao existe emulador Android com o id "%s" nesta maquina.\n' "$$id"; \
	  printf '      Ids validos:\n'; \
	  printf '%s\n' "$$ids" | sed 's/^/        - /'; \
	  printf '\n      Exemplo:  make emulador-android EMULADOR=%s\n\n' "$$(printf '%s\n' "$$ids" | head -1)"; \
	  exit 1; \
	fi; \
	printf '\n==> Abrindo o emulador Android: %s\n\n' "$$id"; \
	flutter emulators --launch "$$id" || { \
	  printf '\nERRO: o emulador "%s" nao abriu.\n' "$$id"; \
	  printf '      Tente abrir pelo Android Studio (Device Manager) para ver o motivo.\n\n'; \
	  exit 1; }; \
	$(call ESPERA_DISPOSITIVO,android-,emulador Android)

## emulador-ios: abre o Simulador do iPhone e espera ele ficar pronto (so no macOS)
emulador-ios:
	$(EXIGE_MAC)
	@command -v xcrun >/dev/null 2>&1 || { \
	  printf '\nERRO: as ferramentas de linha de comando do Xcode nao estao instaladas.\n'; \
	  printf '      1. instale o Xcode pela App Store;\n'; \
	  printf '      2. rode:  sudo xcode-select --install\n'; \
	  printf '      3. confira com:  make doctor\n\n'; \
	  exit 1; }
	@alvo="$(EMULADOR)"; \
	if [ -z "$$alvo" ] && ! xcrun simctl list devices booted 2>/dev/null | grep -q Booted; then \
	  alvo=$$(xcrun simctl list devices available 2>/dev/null | sed -n 's/^ *\(iPhone[^(]*[^ (]\) (.*/\1/p' | head -1); \
	  if [ -z "$$alvo" ]; then \
	    printf '\nERRO: nenhum iPhone de simulador esta instalado.\n'; \
	    printf '      Abra o Xcode > Settings > Components e baixe uma versao do iOS.\n'; \
	    printf '      Depois confira com:  xcrun simctl list devices available\n\n'; \
	    exit 1; \
	  fi; \
	fi; \
	if [ -n "$$alvo" ]; then \
	  printf '\n==> Abrindo o Simulador: %s\n\n' "$$alvo"; \
	  saida=$$(xcrun simctl boot "$$alvo" 2>&1) || case "$$saida" in \
	    *Booted*) printf 'Ele ja estava ligado.\n' ;; \
	    *) printf '\nERRO: nao consegui ligar o simulador "%s".\n      %s\n' "$$alvo" "$$saida"; \
	       printf '      Veja os nomes validos com:  xcrun simctl list devices available\n'; \
	       printf '      Exemplo:  make emulador-ios EMULADOR="iPhone 16"\n\n'; \
	       exit 1 ;; \
	  esac; \
	else \
	  printf '\n==> Trazendo de volta o Simulador que ja estava ligado\n'; \
	  printf '    Para escolher outro:  make emulador-ios EMULADOR="iPhone 16"\n\n'; \
	fi; \
	open -a Simulator || { \
	  printf '\nERRO: a janela do Simulador nao abriu.\n'; \
	  printf '      Abra o Xcode uma vez (ele termina de instalar o simulador) e tente de novo.\n'; \
	  printf '      Confira o que falta com:  make doctor\n\n'; \
	  exit 1; }; \
	$(call ESPERA_DISPOSITIVO,simulator,Simulador do iPhone)

# ===========================================================================
# RODAR E PARAR — o app nos emuladores ja abertos
#
#   make rodar    liga o app nos DOIS emuladores ao mesmo tempo
#   make parar    encerra o app e as sessoes de execucao
#
# Diferenca para o "make run": o "rodar" sobe os dois em SEGUNDO PLANO, entao o
# terminal fica livre e o hot reload (a tecla "r") nao esta disponivel. Para
# programar com hot reload, use um aparelho por vez:
#
#   make run APARELHO=android     (ou ios, web, mac)
#
# Antes de qualquer um deles os emuladores precisam estar abertos:
#   make emulador-android
#   make emulador-ios
# ===========================================================================

# Identificadores do app em cada plataforma. Eles sao DIFERENTES: o Android usa
# snake_case e o iOS, camelCase — foi assim que o "flutter create" gerou.
ID_ANDROID := br.org.garapuvu.garapuvu_kanban
ID_IOS     := br.org.garapuvu.garapuvuKanban

# O adb quase nunca esta no PATH. Procuramos nos lugares onde o SDK do Android
# costuma ficar e, se nao acharmos, deixamos "adb" mesmo (que falha com uma
# mensagem clara em vez de um erro cifrado do shell).
ADB := $(firstword $(wildcard $(ANDROID_HOME)/platform-tools/adb) \
                   $(wildcard $(HOME)/Library/Android/Sdk/platform-tools/adb) adb)

# Onde os logs do "make rodar" sao gravados. build/ ja e ignorado pelo git.
LOGS := build/logs

# Descobre o id de cada emulador ligado. Perguntamos ao adb e ao simctl (e nao
# ao "flutter devices") porque a saida deles e estavel e facil de recortar.
ID_EMULADOR_ANDROID = $(ADB) devices 2>/dev/null | awk '/^emulator-[0-9]+[[:space:]]+device$$/ {print $$1; exit}'
ID_EMULADOR_IOS = xcrun simctl list devices booted 2>/dev/null | sed -n 's/.*(\([0-9A-Fa-f-]\{36\}\)) (Booted).*/\1/p' | head -1

## rodar: liga o app nos DOIS emuladores ao mesmo tempo (segundo plano)
rodar:
	@mkdir -p $(LOGS)
	@android=$$($(ID_EMULADOR_ANDROID)); ios=$$($(ID_EMULADOR_IOS)); \
	if [ -z "$$android" ] && [ -z "$$ios" ]; then \
	  printf '\nERRO: nenhum emulador esta aberto.\n'; \
	  printf '      Abra um (ou os dois) e rode este comando de novo:\n'; \
	  printf '        make emulador-android\n'; \
	  printf '        make emulador-ios\n\n'; \
	  exit 1; \
	fi; \
	printf '\n'; \
	if [ -n "$$android" ]; then \
	  nohup flutter run -d "$$android" > $(LOGS)/android.log 2>&1 & \
	  printf '==> Android  (%s): subindo... log em %s/android.log\n' "$$android" "$(LOGS)"; \
	else \
	  printf '==> Android  : pulado, nenhum emulador aberto (make emulador-android)\n'; \
	fi; \
	if [ -n "$$ios" ]; then \
	  nohup flutter run -d "$$ios" > $(LOGS)/ios.log 2>&1 & \
	  printf '==> iPhone   (%s): subindo... log em %s/ios.log\n' "$$ios" "$(LOGS)"; \
	else \
	  printf '==> iPhone   : pulado, nenhum simulador aberto (make emulador-ios)\n'; \
	fi; \
	printf '\nO primeiro build demora alguns minutos. Acompanhe com:\n'; \
	printf '   tail -f %s/android.log\n' "$(LOGS)"; \
	printf '\nPara encerrar tudo depois:  make parar\n\n'

## parar: encerra o app e as sessoes de execucao nos dois emuladores
##        (os emuladores continuam abertos)
parar:
	@achou=0; \
	android=$$($(ID_EMULADOR_ANDROID)); ios=$$($(ID_EMULADOR_IOS)); \
	printf '\n'; \
	if [ -n "$$android" ] && $(ADB) -s "$$android" shell pidof $(ID_ANDROID) >/dev/null 2>&1; then \
	  $(ADB) -s "$$android" shell am force-stop $(ID_ANDROID) >/dev/null 2>&1; \
	  printf '==> App fechado no Android (%s).\n' "$$android"; achou=1; \
	fi; \
	if [ -n "$$ios" ] && xcrun simctl terminate "$$ios" $(ID_IOS) >/dev/null 2>&1; then \
	  printf '==> App fechado no iPhone (%s).\n' "$$ios"; achou=1; \
	fi; \
	sleep 1; \
	for id in "$$android" "$$ios"; do \
	  [ -n "$$id" ] || continue; \
	  if pgrep -f "run -d $$id" >/dev/null 2>&1; then \
	    pkill -f "run -d $$id" >/dev/null 2>&1 || true; \
	    printf '==> Sessao "flutter run -d %s" encerrada.\n' "$$id"; achou=1; \
	  fi; \
	done; \
	if [ $$achou -eq 0 ]; then \
	  printf 'Nada estava rodando nos emuladores — nao havia o que encerrar.\n'; \
	  printf 'Para ligar o app:  make rodar\n\n'; \
	else \
	  printf '\nOs emuladores continuam abertos. Para ligar de novo:  make rodar\n\n'; \
	fi

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
GUARDA_MAC = test "$$(uname -s)" = "Darwin" || { printf '\nERRO: iOS so roda no macOS, com o Xcode instalado.\n      No Linux/Windows, use a versao Android.\n\n'; exit 1; }
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
