import 'package:flutter/material.dart';

/// ColorWord uygulaması için Neubrutalism renk paleti
class AppColors {
  AppColors._();

  // Ana Renkler
  static const Color background = Color(0xFFFDFBF7); // Krem/kağıt dokusu
  static const Color border = Color(0xFF1E1E1E); // Yüksek kontrast kenarlık
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF6B6B6B);

  // Buton Renkleri
  static const Color buttonPrimary = Color(0xFFFFD93D); // Sarı
  static const Color buttonSecondary = Color(0xFF6BCB77); // Yeşil
  static const Color buttonAccent = Color(0xFF4D96FF); // Mavi
  static const Color buttonDanger = Color(0xFFFF6B6B); // Kırmızı

  // Boyama Paleti (Pastel, yüksek kontrastlı)
  static const Color paletteRed = Color(0xFFFF6B6B);
  static const Color paletteOrange = Color(0xFFFFB347);
  static const Color paletteYellow = Color(0xFFFFD93D);
  static const Color paletteGreen = Color(0xFF6BCB77);
  static const Color paletteBlue = Color(0xFF4D96FF);
  static const Color palettePurple = Color(0xFF9B59B6);
  static const Color palettePink = Color(0xFFFF69B4);
  static const Color paletteBrown = Color(0xFF8B4513);

  // Kategori Renkleri
  static const Color categorySpace = Color(0xFF2C3E50);
  static const Color categoryAnimals = Color(0xFF27AE60);
  static const Color categoryFood = Color(0xFFE74C3C);
  static const Color categoryNature = Color(0xFF1ABC9C);
  static const Color categoryVehicles = Color(0xFF3498DB);

  // Gölge Rengi
  static const Color shadow = Color(0xFF1E1E1E);

  /// Tüm boyama renklerini liste olarak döndürür
  static List<Color> get paintingPalette => [
        paletteRed,
        paletteOrange,
        paletteYellow,
        paletteGreen,
        paletteBlue,
        palettePurple,
        palettePink,
        paletteBrown,
      ];
}
