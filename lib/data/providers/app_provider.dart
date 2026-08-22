import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../models/word_model.dart';
import '../models/coloring_item_model.dart';
import '../models/user_progress_model.dart';
import '../services/database_service.dart';
import '../services/audio_service.dart';
import '../services/custom_image_service.dart';

// === DATABASE PROVIDER ===

/// Veritabanı servisi provider'ı
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

/// Ses servisi provider'ı
final audioServiceProvider = Provider<AppAudioService>((ref) {
  return AppAudioService.instance;
});

/// Özel resim servisi provider'ı
final customImageServiceProvider = Provider<CustomImageService>((ref) {
  return CustomImageService.instance;
});

// === CATEGORY PROVIDERS ===

/// Tüm kategorileri getir
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return db.getAllCategories();
});

/// Seçili kategori
final selectedCategoryProvider = StateProvider<CategoryModel?>((ref) => null);

// === WORD PROVIDERS ===

/// Bir kategorideki kelimeler
final categoryWordsProvider =
    FutureProvider.family<List<WordModel>, String>((ref, category) async {
  final db = ref.watch(databaseServiceProvider);
  return db.getWordsByCategory(category);
});

/// Tüm kelimeler
final allWordsProvider = FutureProvider<List<WordModel>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return db.getAllWords();
});

/// Keşfedilen kelimeler
final discoveredWordsProvider = Provider<List<String>>((ref) {
  final progress = ref.watch(userProgressProvider);
  return progress?.discoveredWords ?? [];
});

// === COLORING PROVIDERS ===

/// Bir kategorideki boyama öğeleri
final categoryColoringItemsProvider =
    FutureProvider.family<List<ColoringItemModel>, String>((ref, category) async {
  final db = ref.watch(databaseServiceProvider);
  return db.getColoringItemsByCategory(category);
});

/// Seçili boyama öğesi
final selectedColoringItemProvider = StateProvider<ColoringItemModel?>((ref) => null);

/// Boyama ilerleme yüzdesi
final coloringProgressProvider = StateProvider<double>((ref) => 0.0);

/// Aktif boyama rengi
final selectedColorProvider = StateProvider<int>((ref) => 0);

// === PROGRESS PROVIDERS ===

/// Kullanıcı ilerlemesi
final userProgressProvider = Provider<UserProgressModel?>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return db.getProgress();
});

/// Toplam ilerleme istatistikleri
final progressStatsProvider = Provider<Map<String, int>>((ref) {
  final progress = ref.watch(userProgressProvider);
  if (progress == null) {
    return {
      'words': 0,
      'letters': 0,
      'colorings': 0,
      'playTime': 0,
    };
  }
  return {
    'words': progress.totalWordsDiscovered,
    'letters': progress.totalLettersLearned,
    'colorings': progress.totalColoringsCompleted,
    'playTime': progress.totalPlayTimeSeconds,
  };
});

// === SETTINGS PROVIDERS ===

/// Sessizlik durumu
final isMutedProvider = StateProvider<bool>((ref) => false);

/// Dark mode (gelecek için)
final isDarkModeProvider = StateProvider<bool>((ref) => false);

// === UI STATE PROVIDERS ===

/// Yükleniyor durumu
final isLoadingProvider = StateProvider<bool>((ref) => false);

/// Hata mesajı
final errorMessageProvider = StateProvider<String?>((ref) => null);
