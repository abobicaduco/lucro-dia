# Lucro do Dia

App de finanças simples para quem vende e compra no dia a dia (feirantes, doceiras,
revendedores, autônomos) registrar movimentações e entender, sem complicação, se está
**lucrando** ou no **prejuízo** no mês.

Feito em Flutter, funciona em Android **7.0+** (aparelhos antigos e recentes).

## O que o app faz

- **Registrar venda** (entrou dinheiro) e **compra** (saiu dinheiro) com valor, data e
  descrição opcional — linguagem para leigos, sem jargão financeiro.
- **Resumo do mês**: total de vendas, total de compras e o lucro/prejuízo, com uma frase
  clara ("Você está lucrando" / "Você está no prejuízo neste mês").
- **Até hoje**: quanto vendeu, quanto gastou e o saldo até a data atual.
- **Histórico**: lista de todos os registros do mês. Toque para editar, segure para apagar.
- **Navegação por meses**: veja o resultado de qualquer mês.
- **Tela Sobre**: explicação do app, privacidade, **doações via Pix** (chave, copia e cola
  e QR Code gerados no próprio aparelho) e **contato** por e-mail para sugestões/ajuda.

## Privacidade — dados 100% locais

Todos os registros ficam **apenas no celular** do usuário, num banco SQLite
(`lucro_dia_local.db`). Não há login, conta, nuvem nem analytics. Nenhum dado financeiro
é enviado para o desenvolvedor ou para qualquer servidor.

A **única** conexão com a internet é opcional: verificar se existe uma versão nova do app
(somente número de versão + link do APK). Nada do usuário é transmitido.

## Atualizações (OTA via GitHub Releases)

Ao abrir com internet, o app consulta a API pública de releases do GitHub
(`/repos/abobicaduco/lucro-dia/releases/latest`). Se a última versão publicada for mais
nova que a instalada, o usuário vê um diálogo e **escolhe** se quer atualizar ("Atualizar"
baixa o APK; "Agora não" adia). O app escolhe automaticamente o APK que combina com a
arquitetura do aparelho (arm64-v8a, armeabi-v7a, x86_64) e, se não achar, usa o universal.

O lembrete aparece **no máximo uma vez por dia, mas volta todo dia** até a pessoa
atualizar — sem incomodar a cada abertura.

### Como publicar uma nova versão

1. Suba `version:` em [`pubspec.yaml`](pubspec.yaml) (ex.: `1.0.1+2`).
2. Crie e envie a tag correspondente:
   ```bash
   git tag v1.0.1 && git push origin v1.0.1
   ```
3. O workflow [`.github/workflows/release.yml`](.github/workflows/release.yml) compila os
   APKs (arm64-v8a, armeabi-v7a, x86_64 e universal), **assina com a chave de release** e
   cria a Release no GitHub com os arquivos anexados.
4. Pronto: quem tem o app instalado recebe o aviso de atualização ao abrir com internet.

> **Assinatura:** todos os APKs são assinados com o mesmo keystore (guardado fora do repo,
> nos secrets do GitHub `KEYSTORE_BASE64` / `KEYSTORE_PASSWORD` / `KEY_ALIAS`). Isso é o que
> permite a atualização instalar por cima da versão anterior.

## Build

```bash
flutter pub get
flutter build apk --release   # build/app/outputs/flutter-apk/app-release.apk
```

## Estrutura

```
lib/
  main.dart                       # app + tema + localização pt_BR
  models/transaction.dart         # modelo de transação e resumo do mês
  services/database_service.dart  # SQLite local (CRUD + cálculo do resumo)
  services/update_service.dart    # checagem opcional de versão nova
  screens/                        # home, registrar, histórico, privacidade
  utils/currency.dart             # formatação e parsing de R$
```

## Privacidade legal

O app não coleta dados pessoais. Por isso o desenvolvedor fica isento de obrigações de
tratamento de dados (LGPD) — não há dado do usuário sob sua guarda.
