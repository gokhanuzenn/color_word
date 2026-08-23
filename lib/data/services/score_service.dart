import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Yerel skor tablosu servisi
/// Her kullanıcı kendi skorunu görür
/// Kayıt gerekmez, internet gerekmez
class ScoreService {
  static ScoreService? _instance;
  static ScoreService get instance => _instance ??= ScoreService._();
  ScoreService._();

  SharedPreferences? _prefs;

  // === BAŞLATMA ===
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _checkDailyReset();
  }

  SharedPreferences get prefs => _prefs!;

  // === GÜNLÜK GÖREVLER ===

  /// Günlük görevleri kontrol et
  Future<void> _checkDailyReset() async {
    final lastDate = prefs.getString('last_daily_reset') ?? '';
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastDate != today) {
      // Yeni gün - günlük görevleri sıfırla
      await prefs.setInt('daily_colorings', 0);
      await prefs.setInt('daily_stickers', 0);
      await prefs.setInt('daily_texts', 0);
      await prefs.setInt('daily_stars_earned', 0);
      await prefs.setString('last_daily_reset', today);
    }
  }

  /// Günlük boyama sayısını artır
  Future<void> addDailyColoring() async {
    await _checkDailyReset();
    final current = prefs.getInt('daily_colorings') ?? 0;
    await prefs.setInt('daily_colorings', current + 1);

    // Toplam boyama sayısını artır
    final totalColorings = prefs.getInt('total_colorings') ?? 0;
    await prefs.setInt('total_colorings', totalColorings + 1);

    // Günlük görevleri kontrol et
    await _checkDailyTasks();
  }

  /// Günlük sticker kullanımını artır
  Future<void> addDailySticker() async {
    await _checkDailyReset();
    final current = prefs.getInt('daily_stickers') ?? 0;
    await prefs.setInt('daily_stickers', current + 1);
    await _checkDailyTasks();
  }

  /// Günlük metin kullanımını artır
  Future<void> addDailyText() async {
    await _checkDailyReset();
    final current = prefs.getInt('daily_texts') ?? 0;
    await prefs.setInt('daily_texts', current + 1);
    await _checkDailyTasks();
  }

  /// Günlük görevleri kontrol et ve ödül ver
  Future<void> _checkDailyTasks() async {
    final colorings = prefs.getInt('daily_colorings') ?? 0;
    final stickers = prefs.getInt('daily_stickers') ?? 0;
    final texts = prefs.getInt('daily_texts') ?? 0;

    // 3 boyama → 5 yıldız
    if (colorings >= 3 && !(prefs.getBool('task_3_colorings_done') ?? false)) {
      await addStars(5);
      await prefs.setBool('task_3_colorings_done', true);
    }

    // 5 boyama → 10 yıldız
    if (colorings >= 5 && !(prefs.getBool('task_5_colorings_done') ?? false)) {
      await addStars(10);
      await prefs.setBool('task_5_colorings_done', true);
    }

    // 1 sticker → 2 yıldız
    if (stickers >= 1 && !(prefs.getBool('task_1_sticker_done') ?? false)) {
      await addStars(2);
      await prefs.setBool('task_1_sticker_done', true);
    }

    // 1 metin → 2 yıldız
    if (texts >= 1 && !(prefs.getBool('task_1_text_done') ?? false)) {
      await addStars(2);
      await prefs.setBool('task_1_text_done', true);
    }
  }

  // === YILDIZ SİSTEMİ ===

  /// Toplam yıldız sayısını al
  int get totalStars => prefs.getInt('total_stars') ?? 0;

  /// Yıldız ekle
  Future<void> addStars(int count) async {
    final current = totalStars;
    await prefs.setInt('total_stars', current + count);

    // Günlük yıldız sayısını da artır
    await _checkDailyReset();
    final dailyStars = prefs.getInt('daily_stars_earned') ?? 0;
    await prefs.setInt('daily_stars_earned', dailyStars + count);

    // Rozetleri kontrol et
    await _checkBadges();
  }

  // === ROZET SİSTEMİ ===

  /// Tüm rozetler
  static const List<Map<String, dynamic>> allBadges = [
    {'id': 'first_coloring', 'name': 'İlk Boyama', 'icon': '🎨', 'description': 'İlk boyamanı yap', ' requirement': 1, 'type': 'colorings'},
    {'id': '10_stars', 'name': '10 Yıldız', 'icon': '⭐', 'description': '10 yıldız topla', ' requirement': 10, 'type': 'stars'},
    {'id': '25_stars', 'name': '25 Yıldız', 'icon': '🌟', 'description': '25 yıldız topla', ' requirement': 25, 'type': 'stars'},
    {'id': '50_stars', 'name': '50 Yıldız', 'icon': '✨', 'description': '50 yıldız topla', ' requirement': 50, 'type': 'stars'},
    {'id': '100_stars', 'name': '100 Yıldız', 'icon': '💫', 'description': '100 yıldız topla', ' requirement': 100, 'type': 'stars'},
    {'id': '250_stars', 'name': '250 Yıldız', 'icon': '🔥', 'description': '250 yıldız topla', ' requirement': 250, 'type': 'stars'},
    {'id': '500_stars', 'name': '500 Yıldız', 'icon': '💎', 'description': '500 yıldız topla', ' requirement': 500, 'type': 'stars'},
    {'id': '10_colorings', 'name': '10 Boyama', 'icon': '🖼️', 'description': '10 boyama yap', ' requirement': 10, 'type': 'colorings'},
    {'id': '25_colorings', 'name': '25 Boyama', 'icon': '🎭', 'description': '25 boyama yap', ' requirement': 25, 'type': 'colorings'},
    {'id': '50_colorings', 'name': '50 Boyama', 'icon': '🏆', 'description': '50 boyama yap', ' requirement': 50, 'type': 'colorings'},
    {'id': '100_colorings', 'name': '100 Boyama', 'icon': '👑', 'description': '100 boyama yap', ' requirement': 100, 'type': 'colorings'},
    {'id': 'daily_3', 'name': 'Günlük 3', 'icon': '📅', 'description': 'Günde 3 boyama yap', ' requirement': 3, 'type': 'daily_colorings'},
    {'id': 'daily_5', 'name': 'Günlük 5', 'icon': '🎯', 'description': 'Günde 5 boyama yap', ' requirement': 5, 'type': 'daily_colorings'},
  ];

  /// Kazanılan rozetler
  List<String> get earnedBadges {
    return prefs.getStringList('earned_badges') ?? [];
  }

  /// Rozet kontrolü
  Future<void> _checkBadges() async {
    final earnedBadgesList = earnedBadges;
    final colorings = prefs.getInt('total_colorings') ?? 0;
    final stars = totalStars;

    for (final badge in allBadges) {
      if (earnedBadgesList.contains(badge['id'])) continue;

      bool isEarned = false;
      switch (badge['type']) {
        case 'stars':
          isEarned = stars >= badge['requirement'];
          break;
        case 'colorings':
          isEarned = colorings >= badge['requirement'];
          break;
      }

      if (isEarned) {
        await _earnBadge(badge['id']);
      }
    }
  }

  /// Rozet kazan
  Future<void> _earnBadge(String badgeId) async {
    final earned = earnedBadges;
    earned.add(badgeId);
    await prefs.setStringList('earned_badges', earned);
  }

  // === SIRALAMA VERİLERİ ===

  /// Skor verilerini al
  Map<String, dynamic> getScoreData() {
    return {
      'totalStars': totalStars,
      'totalColorings': prefs.getInt('total_colorings') ?? 0,
      'totalSavedDrawings': prefs.getInt('total_saved_drawings') ?? 0,
      'earnedBadges': earnedBadges.length,
      'dailyColorings': prefs.getInt('daily_colorings') ?? 0,
      'dailyStickers': prefs.getInt('daily_stickers') ?? 0,
      'dailyTexts': prefs.getInt('daily_texts') ?? 0,
      'dailyStarsEarned': prefs.getInt('daily_stars_earned') ?? 0,
    };
  }

  /// Günlük görev verilerini al
  Map<String, dynamic> getDailyTasks() {
    return {
      'colorings': prefs.getInt('daily_colorings') ?? 0,
      'stickers': prefs.getInt('daily_stickers') ?? 0,
      'texts': prefs.getInt('daily_texts') ?? 0,
      'tasks': [
        {
          'name': '3 Boyama Yap',
          'current': prefs.getInt('daily_colorings') ?? 0,
          'target': 3,
          'reward': 5,
          'done': prefs.getBool('task_3_colorings_done') ?? false,
          'icon': '🎨',
        },
        {
          'name': '5 Boyama Yap',
          'current': prefs.getInt('daily_colorings') ?? 0,
          'target': 5,
          'reward': 10,
          'done': prefs.getBool('task_5_colorings_done') ?? false,
          'icon': '🎯',
        },
        {
          'name': '1 Sticker Kullan',
          'current': prefs.getInt('daily_stickers') ?? 0,
          'target': 1,
          'reward': 2,
          'done': prefs.getBool('task_1_sticker_done') ?? false,
          'icon': '⭐',
        },
        {
          'name': '1 Metin Ekle',
          'current': prefs.getInt('daily_texts') ?? 0,
          'target': 1,
          'reward': 2,
          'done': prefs.getBool('task_1_text_done') ?? false,
          'icon': '📝',
        },
      ],
    };
  }

  /// Sıralama seviyesini hesapla
  String getRank() {
    final stars = totalStars;
    if (stars >= 500) return '👑 Kral';
    if (stars >= 250) return '💎 Elmas';
    if (stars >= 100) return '🔥 Altın';
    if (stars >= 50) return '⭐ Gümüş';
    if (stars >= 25) return '🌟 Bronz';
    if (stars >= 10) return '✨ Çırak';
    return '🎨 Başlangıç';
  }

  /// Bir sonraki seviyeye kaç yıldız kaldı?
  int getStarsToNextRank() {
    final stars = totalStars;
    if (stars >= 500) return 0;
    if (stars >= 250) return 500 - stars;
    if (stars >= 100) return 250 - stars;
    if (stars >= 50) return 100 - stars;
    if (stars >= 25) return 50 - stars;
    if (stars >= 10) return 25 - stars;
    return 10 - stars;
  }

  /// Bir sonraki rozete kaç yıldız kaldı?
  String getNextBadge() {
    final stars = totalStars;
    if (stars < 10) return '⭐ 10 Yıldız';
    if (stars < 25) return '🌟 25 Yıldız';
    if (stars < 50) return '✨ 50 Yıldız';
    if (stars < 100) return '💫 100 Yıldız';
    if (stars < 250) return '🔥 250 Yıldız';
    if (stars < 500) return '💎 500 Yıldız';
    return '🏆 Tüm Rozetler!';
  }
}
