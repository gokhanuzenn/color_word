/// Uygulama genelinde kullanılacak sabitler
class AppConstants {
  AppConstants._();

  // Uygulama Bilgileri
  static const String appName = 'ColorWord';
  static const String appVersion = '1.0.0';

  // Boyutlar
  static const double minTouchTarget = 48.0;
  static const double borderWidth = 3.0;
  static const double shadowOffset = 4.0;
  static const double shadowOffsetLarge = 8.0;
  static const double borderRadius = 12.0;
  static const double borderRadiusSmall = 8.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Animasyon Süreleri
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // Boyama Ayarları
  static const double coloringLineWidth = 12.0;
  static const double wordRevealThreshold = 0.5; // %50 boyandığında harf açılır
  static const int maxColorPalette = 8;

  // Kategori İsimleri
  static const String categorySpace = 'Uzay';
  static const String categoryAnimals = 'Hayvanlar';
  static const String categoryFood = 'Yiyecekler';
  static const String categoryNature = 'Doğa';
  static const String categoryVehicles = 'Taşıtlar';

  // Hive Box İsimleri
  static const String progressBox = 'progress_box';
  static const String settingsBox = 'settings_box';
  static const String wordsBox = 'words_box';
}
