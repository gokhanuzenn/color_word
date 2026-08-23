import 'package:flutter/material.dart';

/// Ekran boyutuna göre responsive ayarlar
class ResponsiveHelper {
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  
  /// Cihaz türü
  static DeviceType getDeviceType(BuildContext context) {
    final width = screenWidth(context);
    if (width < 600) return DeviceType.phone;
    if (width < 900) return DeviceType.tablet;
    return DeviceType.desktop;
  }
  
  /// Grid kolon sayısı
  static int getGridColumns(BuildContext context) {
    final width = screenWidth(context);
    if (width < 400) return 2;
    if (width < 600) return 3;
    if (width < 900) return 4;
    return 5;
  }
  
  /// Kategori grid kolon sayısı
  static int getCategoryGridColumns(BuildContext context) {
    final width = screenWidth(context);
    if (width < 400) return 2;
    if (width < 600) return 3;
    if (width < 900) return 4;
    return 5;
  }
  
  /// Font boyutu çarpanı
  static double getFontScale(BuildContext context) {
    final width = screenWidth(context);
    if (width < 400) return 0.9;
    if (width < 600) return 1.0;
    if (width < 900) return 1.1;
    return 1.2;
  }
  
  /// Padding
  static double getPadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < 400) return 12;
    if (width < 600) return 16;
    return 24;
  }
  
  /// Kart boyutu
  static double getCardSize(BuildContext context) {
    final width = screenWidth(context);
    if (width < 400) return 100;
    if (width < 600) return 120;
    return 150;
  }
  
  /// Boyama alanı boyutu
  static double getDrawingAreaHeight(BuildContext context) {
    final height = screenHeight(context);
    return height * 0.5; // Ekranın %50'si
  }
}

enum DeviceType { phone, tablet, desktop }
