import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob reklam servisi
/// - İlk açılışta 7 sn interstitial
/// - Her 2 dakikada bir 7 sn interstitial
/// - Premium alanlarda reklam yok
class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();
  AdService._();

  // === ADMOB ID'LERİ ===
  // Test modunda test ID'leri kullanılıyor
  static const String appId = 'ca-app-pub-9171283684710932~8151502461';
  
  // Test reklam ID'leri (geliştirme için - uygulama yayınlanmadan önce)
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  // Gerçek reklam ID'leri (uygulama yayınlandıktan sonra)
  // static const String bannerAdUnitId = 'ca-app-pub-9171283684710932/9463594451';
  // static const String interstitialAdUnitId = 'ca-app-pub-9171283684710932/9407859330';

  bool _isPremium = false;
  bool _showAds = true;
  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;

  // === ZAMANLAMA ===
  DateTime? _lastInterstitialTime;
  bool _firstAdShown = false;
  Timer? _periodicTimer;
  VoidCallback? _onAdReady;

  /// AdMob'u başlat
  Future<void> initialize() async {
    // Test cihazı ayarla (geliştirme için)
    await MobileAds.instance.initialize();
    
    // Debug modunda test reklamları için
    if (kDebugMode) {
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: ['YOUR_TEST_DEVICE_ID'],
        ),
      );
    }
    
    await _loadInterstitialAd();
    _checkPremiumStatus();
  }

  /// Premium durumunu kontrol et
  Future<void> _checkPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;
    _showAds = !_isPremium;
  }

  Future<bool> isPremium() async {
    await _checkPremiumStatus();
    return _isPremium;
  }

  Future<void> setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', value);
    _isPremium = value;
    _showAds = !value;
  }

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
    if (!shouldShowAds()) return;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print('✅ Interstitial reklam yüklendi');
          _onAdReady?.call();
        },
        onAdFailedToLoad: (error) {
          print('❌ Interstitial reklam yüklenemedi: $error');
          _interstitialAd = null;
          // 30 saniye sonra tekrar dene
          Future.delayed(const Duration(seconds: 30), () => _loadInterstitialAd());
        },
      ),
    );
  }

  /// İlk açılışta reklam göster
  void showFirstAdIfReady({VoidCallback? onAdClosed}) {
    if (!shouldShowAds()) {
      onAdClosed?.call();
      return;
    }

    if (!_firstAdShown && _interstitialAd != null) {
      _firstAdShown = true;
      _lastInterstitialTime = DateTime.now();
      showInterstitialAd(onAdClosed: onAdClosed);
    } else {
      onAdClosed?.call();
    }
  }

  /// Periyodik reklamları başlat (her 2 dakika)
  void startPeriodicAds() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (shouldShowAds() && _lastInterstitialTime != null) {
        final elapsed = DateTime.now().difference(_lastInterstitialTime!);
        if (elapsed.inMinutes >= 2) {
          showInterstitialAd();
        }
      }
    });
  }

  void stopPeriodicAds() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// Interstitial reklam göster
  void showInterstitialAd({VoidCallback? onAdClosed}) {
    if (_interstitialAd != null && shouldShowAds()) {
      _lastInterstitialTime = DateTime.now();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
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

  /// Reklam hazır mı?
  bool isAdReady() {
    return _interstitialAd != null && shouldShowAds();
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
    _periodicTimer?.cancel();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}
