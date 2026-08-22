import 'package:shared_preferences/shared_preferences.dart';

/// Başarı sistemi servisi
class AchievementService {
  static AchievementService? _instance;
  static AchievementService get instance => _instance ??= AchievementService._();
  AchievementService._();

  int _totalStars = 0;
  int _totalBadges = 0;
  int _completedDrawings = 0;
  List<String> _unlockedBadges = [];
  List<String> _savedDrawings = [];

  // Rozet tanımları
  static const Map<String, Map<String, dynamic>> badges = {
    'first_drawing': {'name': 'İlk Boyama', 'icon': '🎨', 'required': 1},
    'star_10': {'name': '10 Yıldız', 'icon': '⭐', 'required': 10},
    'star_25': {'name': '25 Yıldız', 'icon': '🌟', 'required': 25},
    'star_50': {'name': '50 Yıldız', 'icon': '✨', 'required': 50},
    'star_100': {'name': '100 Yıldız', 'icon': '💫', 'required': 100},
    'drawing_10': {'name': '10 Boyama', 'icon': '🖼️', 'required': 10},
    'drawing_25': {'name': '25 Boyama', 'icon': '🎭', 'required': 25},
    'drawing_50': {'name': '50 Boyama', 'icon': '🏆', 'required': 50},
    'share_master': {'name': 'Paylaşma Ustası', 'icon': '📤', 'required': 5},
  };

  /// Başlat
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _totalStars = prefs.getInt('total_stars') ?? 0;
    _completedDrawings = prefs.getInt('completed_drawings') ?? 0;
    _unlockedBadges = prefs.getStringList('unlocked_badges') ?? [];
    _savedDrawings = prefs.getStringList('saved_drawings') ?? [];
    _totalBadges = _unlockedBadges.length;
  }

  /// Boyama tamamlandığında çağır
  Future<Map<String, dynamic>> completeDrawing() async {
    _totalStars++;
    _completedDrawings++;

    final newBadges = <String>[];

    // Rozet kontrolü
    for (final entry in badges.entries) {
      final badgeId = entry.key;
      final badge = entry.value;
      
      if (!_unlockedBadges.contains(badgeId)) {
        final required = badge['required'] as int;
        bool unlocked = false;

        if (badgeId.startsWith('star_') && _totalStars >= required) {
          unlocked = true;
        } else if (badgeId.startsWith('drawing_') && _completedDrawings >= required) {
          unlocked = true;
        } else if (badgeId == 'first_drawing' && _completedDrawings >= 1) {
          unlocked = true;
        }

        if (unlocked) {
          _unlockedBadges.add(badgeId);
          newBadges.add(badgeId);
        }
      }
    }

    _totalBadges = _unlockedBadges.length;
    await _save();

    return {
      'stars': _totalStars,
      'badges': newBadges,
      'totalBadges': _totalBadges,
    };
  }

  /// Kayıtlı çizimleri管理
  Future<void> saveDrawing(String drawingPath) async {
    if (!_savedDrawings.contains(drawingPath)) {
      _savedDrawings.add(drawingPath);
      await _save();
    }
  }

  List<String> getSavedDrawings() => _savedDrawings;

  int get totalStars => _totalStars;
  int get totalBadges => _totalBadges;
  int get completedDrawings => _completedDrawings;
  List<String> get unlockedBadges => _unlockedBadges;

  /// Rozet bilgisini al
  Map<String, dynamic>? getBadgeInfo(String badgeId) {
    return badges[badgeId];
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_stars', _totalStars);
    await prefs.setInt('completed_drawings', _completedDrawings);
    await prefs.setStringList('unlocked_badges', _unlockedBadges);
    await prefs.setStringList('saved_drawings', _savedDrawings);
  }
}
