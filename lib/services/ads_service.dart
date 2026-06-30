import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/build_config.dart';

/// Inicialização do SDK AdMob. Gateado por [BuildConfig.adsEnabled]: no build
/// do GitHub (sem ads) vira no-op e o SDK nunca é tocado.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  bool _initialized = false;

  Future<void> init() async {
    if (!BuildConfig.adsEnabled || _initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }
}

/// Banner ancorado. Quando os anúncios estão desligados, ou enquanto o anúncio
/// não carregou, não ocupa nenhum espaço na tela ([SizedBox.shrink]).
class BannerAdView extends StatefulWidget {
  const BannerAdView({super.key});

  @override
  State<BannerAdView> createState() => _BannerAdViewState();
}

class _BannerAdViewState extends State<BannerAdView> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (BuildConfig.adsEnabled) _load();
  }

  void _load() {
    final ad = BannerAd(
      adUnitId: BuildConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
    ad.load();
    _ad = ad;
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!BuildConfig.adsEnabled || !_loaded || _ad == null) {
      return const SizedBox.shrink();
    }
    return SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        height: _ad!.size.height.toDouble(),
        child: Center(
          child: SizedBox(
            width: _ad!.size.width.toDouble(),
            height: _ad!.size.height.toDouble(),
            child: AdWidget(ad: _ad!),
          ),
        ),
      ),
    );
  }
}
