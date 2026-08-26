# Arquivos instaláveis do Garapuvu Kanban

Gerados a partir da versão **0.1.0** (`pubspec.yaml`), todos em modo **release**
(otimizados, sem ferramenta de desenvolvedor).

| Arquivo | Para que serve | Como usar |
| --- | --- | --- |
| `garapuvu-kanban-0.1.0.apk` | Instalar direto num celular **Android**, sem passar por loja | Copie para o aparelho e toque no arquivo. É preciso permitir "instalar de fontes desconhecidas" |
| `garapuvu-kanban-0.1.0.aab` | Enviar ao **Google Play** | O Play recebe este arquivo e monta, a partir dele, o APK sob medida para cada celular. **Não** dá para instalar direto no aparelho |
| `garapuvu-kanban-0.1.0-SEM-ASSINATURA.ipa` | Arquivo de app do **iPhone** | ⚠️ **Não instala num iPhone comum como está** — veja abaixo |

## Por que o `.ipa` está sem assinatura

A Apple exige um **carimbo digital** (*code signing*) para instalar qualquer app
num iPhone, e esse carimbo depende de uma conta Apple Developer. Este Mac não
tem nenhum certificado de assinatura (`security find-identity` devolve
`0 valid identities found`), então o `flutter build ipa` recusa gerar o arquivo.

O que está aqui é o app compilado de verdade (`flutter build ios --release
--no-codesign`), empacotado no formato `.ipa` (uma pasta `Payload/` compactada).
Ele serve para **guardar, conferir e assinar depois** — não para instalar agora.

Para gerar um `.ipa` que instala de verdade:

1. `open ios/Runner.xcworkspace`
2. No alvo **Runner** → *Signing & Capabilities* → escolha o seu **Team**
3. `make build-ipa`

Se você só quer conferir que o app iOS compila, sem assinar: `make build-ios`.

## Como gerar tudo de novo

```bash
make build-android   # gera o .apk e o .aab em build/
make build-ipa       # gera o .ipa (precisa de assinatura)
make artefatos       # mostra quais arquivos já existem
```

Depois é só copiar de `build/` para cá.

## Privacidade

O app não envia nada para servidor nenhum: as tarefas ficam **somente no
aparelho** de quem usa. Estes arquivos não contêm dado de pessoa alguma.
