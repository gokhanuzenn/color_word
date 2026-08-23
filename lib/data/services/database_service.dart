import 'package:hive/hive.dart';
import '../models/category_model.dart';
import '../models/word_model.dart';
import '../models/coloring_item_model.dart';
import '../models/user_progress_model.dart';
import '../../core/constants/app_constants.dart';

/// Hive veritabanı yönetim servisi
class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();
  DatabaseService._();

  late Box<CategoryModel> _categoryBox;
  late Box<WordModel> _wordsBox;
  late Box<ColoringItemModel> _coloringBox;
  late Box<UserProgressModel> _progressBox;
  late Box _settingsBox;

  /// Kategori bilgileri: id, isim, resim sayısı, renk
  static const Map<String, Map<String, dynamic>> _categoryData = {
    'ciftlik': {'name': 'Çiftlik', 'count': 11, 'color': '#8D6E63', 'emoji': '🐄'},
    'deniz_alti': {'name': 'Deniz Altı', 'count': 11, 'color': '#00BCD4', 'emoji': '🐠'},
    'dinozor': {'name': 'Dinozor', 'count': 22, 'color': '#4CAF50', 'emoji': '🦕'},
    'doga': {'name': 'Doğa', 'count': 11, 'color': '#66BB6A', 'emoji': '🌳'},
    'doga_gokyuzu': {'name': 'Doğa Gökyüzü', 'count': 11, 'color': '#29B6F6', 'emoji': '🌤️'},
    'emoji': {'name': 'Emoji', 'count': 15, 'color': '#FFC107', 'emoji': '😊'},
    'erkek_karakter': {'name': 'Erkek Karakter', 'count': 31, 'color': '#42A5F5', 'emoji': '👦'},
    'harfler': {'name': 'Harfler', 'count': 25, 'color': '#26C6DA', 'emoji': '🔤'},
    'insaat': {'name': 'İnşaat', 'count': 24, 'color': '#FFA726', 'emoji': '🏗️'},
    'kahraman': {'name': 'Kahramanlar', 'count': 19, 'color': '#EF5350', 'emoji': '🦸'},
    'kiz_karakter': {'name': 'Kız Karakter', 'count': 33, 'color': '#EC407A', 'emoji': '👧'},
    'meslekler': {'name': 'Meslekler', 'count': 31, 'color': '#78909C', 'emoji': '👨‍⚕️'},
    'meyveler': {'name': 'Meyveler', 'count': 11, 'color': '#FF7043', 'emoji': '🍎'},
    'okyanus': {'name': 'Okyanus', 'count': 20, 'color': '#0288D1', 'emoji': '🌊'},
    'oyuncak': {'name': 'Oyuncaklar', 'count': 6, 'color': '#FF8A65', 'emoji': '🧸'},
    'robot': {'name': 'Robotlar', 'count': 15, 'color': '#9E9E9E', 'emoji': '🤖'},
    'sayilar': {'name': 'Sayılar', 'count': 21, 'color': '#FF9800', 'emoji': '🔢'},
    'sevimli_dostlar': {'name': 'Sevimli Dostlar', 'count': 22, 'color': '#8BC34A', 'emoji': '🐻'},
    'tamamlayici': {'name': 'Tamamlayıcı', 'count': 22, 'color': '#9C27B0', 'emoji': '✨'},
    'tasitlar': {'name': 'Taşıtlar', 'count': 14, 'color': '#607D8B', 'emoji': '🚗'},
    'uzay': {'name': 'Uzay', 'count': 26, 'color': '#3F51B5', 'emoji': '🚀'},
    'vahsi_dostlar': {'name': 'Vahşi Dostlar', 'count': 22, 'color': '#795548', 'emoji': '🦁'},
    'yiyecekler': {'name': 'Yiyecekler', 'count': 41, 'color': '#F44336', 'emoji': '🍽️'},
  };

  /// Veritabanını başlat
  Future<void> init() async {
    try {
      // Hive adapter'larını kaydet
      Hive.registerAdapter(CategoryModelAdapter());
      Hive.registerAdapter(CategoryTypeAdapter());
      Hive.registerAdapter(WordModelAdapter());
      Hive.registerAdapter(ColoringItemModelAdapter());
      Hive.registerAdapter(UserProgressModelAdapter());

      // Box'ları aç
      _categoryBox = await Hive.openBox<CategoryModel>(AppConstants.progressBox);
      _wordsBox = await Hive.openBox<WordModel>(AppConstants.wordsBox);
      _coloringBox = await Hive.openBox<ColoringItemModel>('coloring_box');
      _progressBox = await Hive.openBox<UserProgressModel>('user_progress');
      _settingsBox = await Hive.openBox('settings');

      // İlk yükleme için varsayılan verileri ekle
      await _seedData();
    } catch (e) {
      // Veritabanı hatası, uygulama çalışmaya devam etsin
      rethrow;
    }
  }

  /// Varsayılan verileri oluştur
  Future<void> _seedData() async {
    if (_categoryBox.isEmpty) {
      await _seedCategories();
    }
    if (_coloringBox.isEmpty) {
      await _seedColoringItems();
    }
    if (_progressBox.isEmpty) {
      await _progressBox.put(
        'current',
        UserProgressModel(),
      );
    }
  }

  Future<void> _seedCategories() async {
    final categories = <CategoryModel>[];

    _categoryData.forEach((id, data) {
      categories.add(CategoryModel(
        id: id,
        name: data['name'] as String,
        type: CategoryType.animals, // Varsayılan
        iconPath: 'assets/images/$id/${id}_001.png',
        colorHex: data['color'] as String,
        totalItems: data['count'] as int,
      ));
    });

    for (final category in categories) {
      await _categoryBox.put(category.id, category);
    }
  }

  Future<void> _seedColoringItems() async {
    final items = <ColoringItemModel>[];

    _categoryData.forEach((categoryId, data) {
      final count = data['count'] as int;
      final name = data['name'] as String;

      for (int i = 1; i <= count; i++) {
        final paddedNum = i.toString().padLeft(3, '0');
        final imagePath = 'assets/images/$categoryId/${categoryId}_$paddedNum.png';

        items.add(ColoringItemModel(
          id: '${categoryId}_$paddedNum',
          name: name,
          category: categoryId,
          imagePath: imagePath,
          associatedWords: [],
          associatedLetters: [],
        ));
      }
    });

    for (final item in items) {
      await _coloringBox.put(item.id, item);
    }
  }

  // === CATEGORY METHODS ===

  List<CategoryModel> getAllCategories() {
    return _categoryBox.values.toList();
  }

  CategoryModel? getCategory(String id) {
    return _categoryBox.get(id);
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _categoryBox.put(category.id, category);
  }

  // === COLORING METHODS ===

  List<ColoringItemModel> getAllColoringItems() {
    return _coloringBox.values.toList();
  }

  List<ColoringItemModel> getColoringItemsByCategory(String category) {
    return _coloringBox.values
        .where((item) => item.category == category)
        .toList();
  }

  ColoringItemModel? getColoringItem(String id) {
    return _coloringBox.get(id);
  }

  Future<void> updateColoringItem(ColoringItemModel item) async {
    await _coloringBox.put(item.id, item);
  }

  // === WORD METHODS ===

  List<WordModel> getAllWords() {
    return _wordsBox.values.toList();
  }

  List<WordModel> getWordsByCategory(String category) {
    return _wordsBox.values
        .where((word) => word.category == category)
        .toList();
  }

  WordModel? getWord(String id) {
    return _wordsBox.get(id);
  }

  Future<void> updateWord(WordModel word) async {
    await _wordsBox.put(word.id, word);
  }

  // === PROGRESS METHODS ===

  UserProgressModel getProgress() {
    return _progressBox.get('current') ?? UserProgressModel();
  }

  Future<void> updateProgress(UserProgressModel progress) async {
    await _progressBox.put('current', progress);
  }

  // === SETTINGS METHODS ===

  bool isMuted() {
    return _settingsBox.get('muted', defaultValue: false);
  }

  Future<void> setMuted(bool muted) async {
    await _settingsBox.put('muted', muted);
  }

  // === UTILITY ===

  Future<void> clearAll() async {
    await _categoryBox.clear();
    await _wordsBox.clear();
    await _coloringBox.clear();
    await _progressBox.clear();
    await _settingsBox.clear();
    await _seedData();
  }
}
