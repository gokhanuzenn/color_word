import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/services/purchase_service.dart';

/// Premium sayfası - $2.99 ile reklamları kaldır
class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  final TextEditingController _promoController = TextEditingController();
  bool _isPremium = false;
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;
  bool _isPurchaseAvailable = false;

  @override
  void initState() {
    super.initState();
    _initPurchase();
  }

  Future<void> _initPurchase() async {
    // Purchase servisini başlat
    await PurchaseService.instance.init();
    
    // Premium durumunu kontrol et
    final isPremium = await PurchaseService.instance.isPremium();
    final isAvailable = PurchaseService.instance.isAvailable;
    
    setState(() {
      _isPremium = isPremium;
      _isPurchaseAvailable = isAvailable;
    });
  }

  /// Gerçek satın alma işlemi ($2.99)
  Future<void> _buyPremium() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final success = await PurchaseService.instance.buyPremium();
      
      if (success) {
        // Satın alma başladı - dinleyici devam edecek
        setState(() {
          _message = 'Satın alma işlemi devam ediyor...';
        });
      } else {
        setState(() {
          _isLoading = false;
          _message = 'Satın alma başlatılamadı. Lütfen tekrar deneyin.';
          _isSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Bir hata oluştu: $e';
        _isSuccess = false;
      });
    }
  }

  /// Satın alımları geri yükle
  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    final success = await PurchaseService.instance.restorePurchases();
    
    setState(() {
      _isLoading = false;
      if (success) {
        _message = 'Satın alımlar kontrol ediliyor...';
      } else {
        _message = 'Satın alımlar geri yüklenemedi';
        _isSuccess = false;
      }
    });
  }

  /// Promo kodu uygula
  Future<void> _applyPromoCode() async {
    final code = _promoController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _message = 'Lütfen bir promo kod girin';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final isValid = await PurchaseService.instance.validatePromoCode(code);

    setState(() {
      _isLoading = false;
      if (isValid) {
        _isPremium = true;
        _message = 'Kod aktif edildi! Reklamsız kullanım 🎉';
        _isSuccess = true;
      } else {
        _message = 'Geçersiz promo kodu ❌';
        _isSuccess = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('⭐ Premium'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Premium durumu
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isPremium ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                border: Border.all(
                  color: _isPremium ? Colors.green : Colors.orange,
                  width: 3,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(3, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    _isPremium ? Icons.check_circle : Icons.star,
                    size: 64,
                    color: _isPremium ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isPremium ? 'Premium Üye 🎉' : 'Premium Değilsiniz',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _isPremium ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isPremium
                        ? 'Reklamsız kullanım aktif!'
                        : 'Reklamları kaldır ve sınırsız kullan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Reklamları Kaldır - $2.99
            if (!_isPremium) ...[
              // Satın Alma Butonu
              GestureDetector(
                onTap: _isLoading ? null : _buyPremium,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(3, 3),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'REKLAMLARI KALDIR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: const Text(
                                '\$2.99',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.pink,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Geri Yükle Butonu
              GestureDetector(
                onTap: _isLoading ? null : _restorePurchases,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Text(
                    'Satın Alımları Geri Yükle',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Promo Kod Bölümü
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PROMO KOD:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoController,
                            decoration: InputDecoration(
                              hintText: 'Kodu yaz...',
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _isLoading ? null : _applyPromoCode,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.lime,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text(
                                    'OK',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Mesaj gösterimi
            if (_message != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  border: Border.all(
                    color: _isSuccess ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isSuccess ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Premium avantajları
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⭐ Premium Avantajları:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAdvantage('✅', 'Reklamsız kullanım'),
                  _buildAdvantage('✅', 'Sınırsız boyama'),
                  _buildAdvantage('✅', 'Tüm kategorilere erişim'),
                  _buildAdvantage('✅', 'Özel boyama araçları'),
                  _buildAdvantage('✅', 'Reklamsız deneyim'),
                  _buildAdvantage('✅', 'Ömür boyu erişim'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Fiyat bilgisi
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: const Text(
                '💡 Tek seferlik ödeme ile ömür boyu reklamsız kullanım!\n'
                'Yıllık abonelik yok, gizli ücret yok.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvantage(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }
}
