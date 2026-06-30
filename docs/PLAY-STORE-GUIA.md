# Lucro do Dia — Guia Play Store (teste fechado → produção)

Passo a passo para tirar o app da trava dos testers e publicar. Marque os itens
conforme avança.

---

## 0. Onde está cada coisa (código já pronto)

| O quê | Onde |
|---|---|
| Flag de build (ads on/OTA off na Play) | `lib/config/build_config.dart` |
| AdMob (init + banner) | `lib/services/ads_service.dart` |
| App ID AdMob (de teste) | `android/app/src/main/AndroidManifest.xml` |
| Workflow que gera o AAB assinado | `.github/workflows/play-release.yml` |
| Política de privacidade | `PRIVACIDADE.md` |
| Keystore | `G:\My Drive\chaves-keystores\lucro_dia-release.jks` |

**Comando do build (na nuvem):** Actions → *Play AAB (closed testing)* → Run workflow
→ baixar o artifact `lucro-dia-play-aab` (arquivo `.aab`).

> Pré-requisito: os secrets `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`
> precisam existir no repo (Settings → Secrets and variables → Actions). O README
> diz que já estão; confirme antes de rodar.

---

## 1. Gerar o AAB

1. [ ] Rodar o workflow *Play AAB (closed testing)* no GitHub Actions.
2. [ ] Baixar o `.aab` do artifact do run.

## 2. Criar/abrir o app no Play Console

1. [ ] https://play.google.com/console → **Criar app**.
2. [ ] Nome: **Lucro do Dia** · Idioma padrão: Português (Brasil) · App · Gratuito.
3. [ ] Aceitar as declarações.

## 3. Ficha da loja (Store listing) — textos prontos

- [ ] **Nome do app (≤30):** `Lucro do Dia`
- [ ] **Descrição curta (≤80):**
  `Registre vendas e compras e veja na hora se está lucrando. Dados só no celular.`
- [ ] **Descrição completa (≤4000):**

```
Lucro do Dia é o jeito mais simples de saber se o seu negócio está dando lucro.

Feito para quem vende e compra todo dia — feirante, doceira, revendedor, MEI,
autônomo, pequeno comércio — sem planilha, sem complicação e sem termos difíceis.

COMO FUNCIONA
• Registrar venda: entrou dinheiro.
• Registrar compra: saiu dinheiro.
• O app mostra na hora o resultado do mês: "Você está lucrando" ou "Você está no
  prejuízo".
• Veja quanto vendeu, quanto gastou e o saldo até hoje.
• Histórico de todos os registros, com edição e exclusão.
• Navegue por qualquer mês para comparar.

PRIVACIDADE DE VERDADE
Seus registros ficam SÓ no seu celular. Não tem login, não tem conta, não tem
nuvem. Ninguém vê o seu dinheiro além de você.

LEVE E OFFLINE
Funciona sem internet e roda até em celular antigo (Android 7.0 ou superior).

Baixe, comece a registrar hoje e descubra se você está realmente lucrando.
```

- [ ] **Ícone (512×512 PNG):** gerar a partir de `assets/icon/ic_full.png`.
- [ ] **Feature graphic (1024×500 PNG):** obrigatório. Fundo verde (#1B7F5C),
  nome "Lucro do Dia" + subtítulo "Está lucrando ou no prejuízo?".
- [ ] **Screenshots (mín. 2, máx. 8 — celular):** tela inicial (lucro do mês),
  tela de registrar venda/compra, histórico. Tirar no emulador ou no seu celular.
- [ ] **Categoria:** Finanças · **Tags:** finanças, negócios, MEI.
- [ ] **E-mail de contato:** abobicaduco@gmail.com
- [ ] **URL da política de privacidade:** publicar `PRIVACIDADE.md` e colar o link
  (ver seção 7).

## 4. Data Safety (Segurança dos dados) — respostas certas com AdMob

> Isso PRECISA bater com a realidade (AdMob coleta Advertising ID), senão suspende.

- [ ] O app coleta ou compartilha dados? **Sim.**
- [ ] **Tipo:** *Identificadores do dispositivo ou outros* → **ID de publicidade**.
  - Coletado? **Sim.** · Compartilhado? **Sim** (com a Google/AdMob).
  - Finalidade: **Publicidade ou marketing** + **Análise**.
  - Obrigatório? Sim (faz parte do funcionamento com anúncios).
- [ ] Dados financeiros que o usuário digita: **NÃO são coletados** (ficam locais,
  não saem do aparelho) → não declarar como coletados.
- [ ] Dados criptografados em trânsito? **Sim** (tráfego do AdMob via HTTPS).
- [ ] Usuário pode pedir exclusão? O ID de publicidade é redefinível nas
  configurações do Android (informar isso).

## 5. Conteúdo do app (App content)

- [ ] Classificação indicativa (questionário): app de finanças, sem conteúdo
  sensível → **Livre / L**.
- [ ] Público-alvo: **18+** (ou 13+) — NÃO marcar "para crianças".
- [ ] Anúncios: **Sim, o app contém anúncios.**
- [ ] Declaração de permissão AD_ID: já incluída no Manifest; confirmar no form.

## 6. TESTE FECHADO (a trava dos 12 testers)

> Regra atual (conta pessoal): **mínimo 12 testers** que **entraram pelo opt-in** e
> permaneceram **14 dias corridos contínuos**. Depois disso libera pedir produção.
> O que conta é entrar pela lista e **não desinstalar** — uso diário não é exigido.

1. [ ] **Testes → Teste fechado → Criar faixa** (ex.: "alpha").
2. [ ] **Testadores:** criar uma lista. Melhor caminho: criar um **Grupo do Google**
   (ex.: `lucro-dia-testers@googlegroups.com`) e adicionar o grupo como lista —
   assim você adiciona/remove gente sem mexer no Console.
3. [ ] Subir o `.aab` nessa faixa → revisar → **lançar para teste fechado**.
4. [ ] Copiar o **link de opt-in** ("Como os testadores ingressam") — é esse link
   que você divulga (ver `docs/CAMPANHA-TESTERS.md`).
5. [ ] Cada tester precisa: (a) entrar no grupo/opt-in, (b) abrir o link, (c)
   tocar em "Tornar-se testador", (d) baixar pela Play e **deixar instalado**.
6. [ ] Acompanhar a contagem em **Testes → Teste fechado** (precisa ≥12 por 14 dias).

## 7. Hospedar a política de privacidade (URL público)

Opção rápida: o arquivo `PRIVACIDADE.md` no GitHub já tem URL público
(`https://github.com/abobicaduco/lucro-dia/blob/main/PRIVACIDADE.md`) — a Play
aceita. Opção melhor: publicar uma página `/lucro-dia/privacidade` em
**abobiferramentas.com** e usar essa URL.

## 8. ANTES DE PRODUÇÃO — trocar IDs de teste do AdMob pelos reais

> Enquanto está em teste fechado, **mantenha os IDs de teste** (usar IDs reais em
> teste = "tráfego inválido" = risco de ban da conta AdMob). Só troque ao promover
> para produção:

1. [ ] AdMob → criar app "Lucro do Dia" (Android) → copiar o **App ID**
   (`ca-app-pub-XXXX~YYYY`) → colar em `AndroidManifest.xml` (substituir o
   `ca-app-pub-3940256099942544~3347511713`).
2. [ ] AdMob → criar bloco **Banner** → copiar o ID (`ca-app-pub-XXXX/ZZZZ`) →
   colar em `_bannerAdUnitIdProd` em `lib/config/build_config.dart`.
3. [ ] Subir `version:` no `pubspec.yaml`, gerar novo AAB, subir em **Produção**.

## 9. Depois dos 14 dias

1. [ ] Play Console mostra o app elegível → **Solicitar acesso à produção**.
2. [ ] Responder o questionário de produção.
3. [ ] Promover o AAB de teste fechado para produção (ou subir um novo com os IDs
   reais do AdMob).
4. [ ] Aguardar revisão (costuma levar de horas a alguns dias).
