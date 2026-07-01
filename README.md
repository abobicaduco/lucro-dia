# 💰 Lucro do Dia

**App Android gratuito para saber, sem complicação, se você está no lucro ou no prejuízo.**

Feito para quem lida com dinheiro todo dia: dono de comércio (feirante, MEI,
revendedor, autônomo) **ou** qualquer pessoa que queira organizar as finanças
pessoais. Você anota o que entrou e o que saiu, e o app responde na hora.

Funciona **offline**, sem cadastro e sem nuvem. Seus dados ficam **só no seu
celular**. Roda em **Android 7.0 ou superior**.

<!-- Sugestão: adicionar aqui um print da tela inicial e do carrossel de telas. -->

---

## ✨ O que o app faz

- **Dois modos de uso** (você escolhe ao abrir, e pode trocar depois):
  - 🏪 **Comércio** — registra *vendas* e *compras* e mostra o **lucro do mês**.
  - 👤 **Pessoal** — registra *entradas* e *gastos* e mostra o **saldo do mês**.
- Resposta na hora, em palavras simples: "Você está lucrando" / "Você está no
  prejuízo" (ou "no positivo" / "no negativo").
- Resumo do mês, do "até hoje" e histórico completo (editar e apagar registros).
- Navegue por qualquer mês para comparar.
- **100% offline**, sem login, sem propaganda invasiva.

## 📥 Como baixar e instalar (passo a passo)

1. Abra a página de **[Releases](../../releases/latest)** no celular.
2. Baixe o arquivo que termina em **`.apk`** (o `universal` funciona em qualquer
   aparelho).
3. Toque no arquivo baixado e, se pedir, permita **"instalar de fontes
   desconhecidas"**.
4. Pronto! Abra o app e escolha se vai usar para *comércio* ou *finanças
   pessoais*.

> 📱 Também será publicado na **Google Play** em breve.

## 🔄 Atualizações

O próprio app **avisa quando sai uma versão nova** (no máximo uma vez por dia, até
você atualizar) e baixa o APK certo para o seu aparelho. Nada dos seus dados é
enviado nesse processo.

## 🔒 Privacidade

Todos os registros ficam **apenas no seu celular** (banco local SQLite). Não há
login, conta, nuvem nem coleta de dados financeiros. A versão da Play Store exibe
anúncios (Google AdMob), que usam o identificador de publicidade do aparelho —
detalhes na [Política de Privacidade](PRIVACIDADE.md).

---

## 🛠️ Para desenvolvedores

App **Flutter** (Android), pensado para ser simples de manter e fácil de publicar.

**Stack:** Flutter · Dart · SQLite (`sqflite`) · Material 3 · GitHub Actions (CI).

**Destaques de arquitetura:**
- **Dados 100% locais** em SQLite (`services/database_service.dart`), sem backend.
- **Modo de uso** (comércio/pessoal) via `config/app_mode.dart`: um único conjunto
  de `Labels` troca toda a terminologia sem mexer no modelo de dados.
- **Flag de build** (`--dart-define=DISTRO=play`) que liga o AdMob e desliga a
  auto-atualização OTA na versão da Play (política da loja), mantendo a versão do
  GitHub com anúncios desligados e OTA ativo.
- **CI que assina e publica:** ao enviar uma tag `v*`, o GitHub Actions compila os
  APKs por arquitetura, assina com o keystore de release (via *secrets*) e cria a
  Release automaticamente.

```bash
flutter pub get
flutter build apk --release                         # versão do GitHub
flutter build appbundle --release --dart-define=DISTRO=play   # versão da Play
```

**Estrutura:**
```
lib/
  main.dart                     # app, tema, localização pt_BR
  config/app_mode.dart          # modos comércio/pessoal + textos
  config/build_config.dart      # flags de distribuição (ads, OTA)
  models/transaction.dart       # transação e resumo do mês
  services/database_service.dart# SQLite local (CRUD + cálculo do resumo)
  services/ads_service.dart     # AdMob (só na versão da Play)
  services/update_service.dart  # checagem opcional de nova versão
  screens/                      # início, registrar, histórico, sobre, doação
```

## 📄 Licença

MIT © 2026 Carlos Eduardo (@abobicaduco)
