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

## Privacidade — dados 100% locais

Todos os registros ficam **apenas no celular** do usuário, num banco SQLite
(`lucro_dia_local.db`). Não há login, conta, nuvem nem analytics. Nenhum dado financeiro
é enviado para o desenvolvedor ou para qualquer servidor.

A **única** conexão com a internet é opcional: verificar se existe uma versão nova do app
(somente número de versão + link do APK). Nada do usuário é transmitido.

## Atualizações

Ao abrir com internet, o app consulta um arquivo de versão público:

```
https://abobiferramentas.com/api/lucro-dia-version.json
```

Modelo em [`version-check/lucro-dia-version.json`](version-check/lucro-dia-version.json).
Quando uma versão nova é publicada (com `version_code` maior), o usuário vê um diálogo e
**escolhe** se quer atualizar ou não ("Atualizar" abre o link do APK; "Agora não" adia).

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
