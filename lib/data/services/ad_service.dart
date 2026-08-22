import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob reklam servisi
class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();
  AdService._();

  // === GERÇEK ADMOB ID'LERİ ===
  static const String appId = 'ca-app-pub-9171283684710932~8151502461';
  static const String bannerAdUnitId = 'ca-app-pub-9171283684710932/9463594451';
  static const String interstitialAdUnitId = 'ca-app-pub-9171283684710932/9407859330';

  bool _isPremium = false;
  bool _showAds = true;
  int _interstitialCounter = 0;

  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;

  /// AdMob'u başlat
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await _loadInterstitialAd();
  }

  /// Premium durumunu kontrol et
  Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;
    return _isPremium;
  }

  /// Premium yap
  Future<void> setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', value);
    _isPremium = value;
    _showAds = !value;
  }

  /// Reklam gösterilmeli mi?
  bool shouldShowAds() {
    return !_isPremium && _showAds;
  }

  // === BANNER REKLAM ===
  BannerAd createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => print('✅ Banner reklam yüklendi'),
        onAdFailedToLoad: (ad, error) {
          print('❌ Banner reklam yüklenemedi: $error');
          ad.dispose();
        },
      ),
    )..load();
    return _bannerAd!;
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  // === INTERSTITIAL REKLAM ===
  Future<void> _loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print('✅ Interstitial reklam yüklendi');
        },
        onAdFailedToLoad: (error) {
          print('❌ Interstitial reklam yüklenemedi: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Interstitial reklam göster (her 3 boyamada bir)
  void incrementInterstitialCounter() {
    _interstitialCounter++;
  }

  bool shouldShowInterstitial() {
    return _interstitialCounter % 3 == 0 && shouldShowAds();
  }

  void showInterstitialAd({VoidCallback? onAdClosed}) {
    if (_interstitialAd != null && shouldShowAds()) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd(); // Yeni reklam yükle
          onAdClosed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadInterstitialAd();
          onAdClosed?.call();
        },
      );
      _interstitialAd!.show();
    } else {
      onAdClosed?.call();
    }
  }

  // === PROMO KOD ===
  Future<bool> validatePromoCode(String code) async {
    final validCodes = [
      'COLORWORD2024',
      'BEDAVA',
      'PREMIUM',
      'REKLAMSIZ',
      'CODERBUFF',
      'GOKHAN',
    ];

    if (validCodes.contains(code.toUpperCase())) {
      await setPremium(true);
      return true;
    }
    return false;
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}
