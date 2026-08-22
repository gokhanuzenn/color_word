import 'package:hive/hive.dart';

/// Kullanıcının kendi yüklediği resimleri yöneten servis
class CustomImageService {
  static CustomImageService? _instance;
  static CustomImageService get instance =>
      _instance ??= CustomImageService._();
  CustomImageService._();

  late Box _customImagesBox;

  /// Servisi başlat
  Future<void> init() async {
    _customImagesBox = await Hive.openBox('custom_images');
  }

  /// Yeni boyama resmi ekle
  Future<Map<String, String>> addColoringImage({
    required String sourcePath,
    required String category,
    required String name,
  }) async {
    // Benzersiz ID oluştur
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final extension = sourcePath.split('.').last;
    final fileName = '$id.$extension';

    // Resmi uygulama dizinine kopyala
    // (Bu işlem主 sayfada yapılacak, burada sadece kaydetme var)
    final imageData = {
      'id': id,
      'name': name,
      'category': category,
      'fileName': fileName,
      'sourcePath': sourcePath,
      'addedAt': DateTime.now().toIso8601String(),
    };

    await _customImagesBox.put(id, imageData);

    return imageData;
  }

  /// Bir kategorideki tüm özel resimleri getir
  List<Map<String, String>> getImagesByCategory(String category) {
    final allImages = getAllCustomImages();
    return allImages
        .where((img) => img['category'] == category)
        .toList();
  }

  /// Tüm özel resimleri getir
  List<Map<String, String>> getAllCustomImages() {
    final images = <Map<String, String>>[];
    for (final key in _customImagesBox.keys) {
      final data = _customImagesBox.get(key);
      if (data != null) {
        final map = Map<String, String>.from(data);
        images.add(map);
      }
    }
    return images;
  }

  /// Resmi sil
  Future<void> deleteImage(String id) async {
    await _customImagesBox.delete(id);
  }

  /// Kategorideki resim sayısını getir
  int getImageCount(String category) {
    return getImagesByCategory(category).length;
  }

  /// Toplam resim sayısını getir
  int get totalImages => _customImagesBox.length;
}
