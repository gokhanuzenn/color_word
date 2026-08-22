import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Premium satın alma servisi
class PurchaseService {
  static PurchaseService? _instance;
  static PurchaseService get instance => _instance ??= PurchaseService._();
  PurchaseService._();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Ürün ID'leri (Google Play Console'da tanımlanacak)
  static const String premiumProductId = 'colorword_premium';
  static const String promoCodeProductId = 'colorword_promo';
  
  // Ürünler
  ProductDetails? _premiumProduct;
  ProductDetails? get premiumProduct => _premiumProduct;
  
  // Satın alma durumu
  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;
  
  bool _purchasePending = false;
  bool get purchasePending => _purchasePending;
  
  String? _queryProductError;
  String? get queryProductError => _queryProductError;

  /// Servisi başlat
  Future<void> init() async {
    // Satın alma akışını dinle
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        handlePurchaseError(error);
      },
    );
    
    // Ürünleri sorgula
    await _loadProducts();
  }

  /// Ürünleri yükle
  Future<void> _loadProducts() async {
    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      
      if (!_isAvailable) {
        _queryProductError = 'Mağaza kullanılamıyor';
        return;
      }
      
      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails({premiumProductId});
      
      if (response.error != null) {
        _queryProductError = response.error!.message;
        return;
      }
      
      if (response.productDetails.isEmpty) {
        _queryProductError = 'Ürün bulunamadı';
        return;
      }
      
      _premiumProduct = response.productDetails.first;
      _queryProductError = null;
      
      debugPrint('✅ Premium ürün yüklendi: ${_premiumProduct!.title}');
    } catch (e) {
      _queryProductError = 'Ürünler yüklenirken hata: $e';
      debugPrint('❌ Ürün yükleme hatası: $e');
    }
  }

  /// Satın alma akışını güncelle
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  /// Satın almayı işle
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      // Satın alma başarılı
      await _grantPremiumAccess();
      debugPrint('✅ Premium satın alma başarılı');
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      // Satın alma hatası
      handlePurchaseError(purchaseDetails.error!);
    } else if (purchaseDetails.status == PurchaseStatus.canceled) {
      // Satın alma iptal edildi
      _purchasePending = false;
      debugPrint('⚠️ Satın alma iptal edildi');
    }

    // Satın almayı tamamla (sandbox/test için gerekli)
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  /// Premium erişim sağla
  Future<void> _grantPremiumAccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', true);
    await prefs.setString('premium_activated_at', DateTime.now().toIso8601String());
    _purchasePending = false;
  }

  /// Premium satın al
  Future<bool> buyPremium() async {
    if (!_isAvailable || _premiumProduct == null) {
      debugPrint('❌ Mağaza kullanılamıyor veya ürün bulunamadı');
      return false;
    }

    _purchasePending = true;

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: _premiumProduct!,
    );

    // Tekli satın alma
    final bool success = await _inAppPurchase.buyNonConsumable(
      purchaseParam: purchaseParam,
    );

    if (!success) {
      _purchasePending = false;
      debugPrint('❌ Satın alma başlatılamadı');
    }

    return success;
  }

  /// Daha önce satın alınanları geri yükle
  Future<bool> restorePurchases() async {
    if (!_isAvailable) {
      debugPrint('❌ Mağaza kullanılamıyor');
      return false;
    }

    try {
      await _inAppPurchase.restorePurchases();
      debugPrint('✅ Satın alımlar geri yüklendi');
      return true;
    } catch (e) {
      debugPrint('❌ Satın alma geri yükleme hatası: $e');
      return false;
    }
  }

  /// Kullanıcının premium olup olmadığını kontrol et
  Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_premium') ?? false;
  }

  /// Premium durumunu ayarla (promo kod için)
  Future<void> setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', value);
    if (value) {
      await prefs.setString('premium_activated_at', DateTime.now().toIso8601String());
    }
  }

  /// Promo kodu doğrula
  Future<bool> validatePromoCode(String code) async {
    // Geçerli promo kodları
    final validCodes = {
      'COLORWORD2024': 'Genel kod',
      'BEDAVA': 'Ücretsiz erişim',
      'PREMIUM': 'Premium aktif',
      'REKLAMSIZ': 'Reklamsız erişim',
      'CODERBUFF': 'Özel kod',
      'GOKHAN': 'Kişisel kod',
      'FREE2024': '2024 ücretsiz',
      'LAUNCH': 'Lansman kodu',
    };

    if (validCodes.containsKey(code.toUpperCase())) {
      await setPremium(true);
      debugPrint('✅ Promo kodu geçerli: ${validCodes[code.toUpperCase()]}');
      return true;
    }
    
    debugPrint('❌ Geçersiz promo kodu: $code');
    return false;
  }

  /// Satın alma hatasını işle
  void handlePurchaseError(IAPError error) {
    _purchasePending = false;
    debugPrint('❌ Satın alma hatası: ${error.message}');
  }

  /// Servisi temizle
  void dispose() {
    _subscription?.cancel();
  }
}
