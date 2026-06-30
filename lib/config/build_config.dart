/// Configuração que muda conforme o canal de distribuição.
///
/// Compile a versão da Google Play com:
///   flutter build appbundle --release --dart-define=DISTRO=play
///
/// Sem a flag, o padrão é `github` — o APK distribuído pelo site / GitHub
/// Releases, que continua sem anúncios e com auto-atualização OTA.
class BuildConfig {
  BuildConfig._();

  static const String distro =
      String.fromEnvironment('DISTRO', defaultValue: 'github');

  /// true quando o build é para a Google Play.
  static const bool isPlay = distro == 'play';

  /// Mostra anúncios AdMob (apenas no build da Play).
  static const bool adsEnabled = isPlay;

  /// Auto-atualização via GitHub Releases. PROIBIDA na Play (política de
  /// "baixar/instalar apps de fora da Play"), por isso só no build do GitHub.
  static const bool selfUpdateEnabled = !isPlay;

  // ---------------------------------------------------------------------------
  // AdMob — IDs de TESTE oficiais do Google (seguros durante o teste fechado).
  //
  // TODO(produção): trocar pelos IDs REAIS da sua conta AdMob ANTES de promover
  // o app para produção:
  //   1. bannerAdUnitIdProd abaixo  ← AdMob > Blocos de anúncios > Banner
  //   2. APPLICATION_ID no AndroidManifest.xml ← AdMob > App > App ID
  // Usar IDs reais em testes gera "tráfego inválido" e pode banir a conta;
  // por isso mantemos os de teste até a publicação em produção.
  // ---------------------------------------------------------------------------

  /// Banner de teste oficial do Google (Android).
  static const String _bannerAdUnitIdTest =
      'ca-app-pub-3940256099942544/6300978111';

  /// Banner REAL — cole aqui quando for para produção (deixe vazio até lá).
  static const String _bannerAdUnitIdProd = '';

  static String get bannerAdUnitId => _bannerAdUnitIdProd.isNotEmpty
      ? _bannerAdUnitIdProd
      : _bannerAdUnitIdTest;
}
