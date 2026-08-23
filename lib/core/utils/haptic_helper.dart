import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Haptic feedback yöneticisi
class HapticHelper {
  static bool _isEnabled = true;
  static bool _isInitialized = false;

  /// Başlatma
  static Future<void> init() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('haptic_enabled') ?? true;
    _isInitialized = true;
  }

  /// Hapticfeedback aktif mi?
  static bool get isEnabled => _isEnabled;

  /// Aç/Kapat
  static Future<void> toggle() async {
    _isEnabled = !_isEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic_enabled', _isEnabled);
  }

  /// Ayarla
  static Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic_enabled', enabled);
  }

  /// Hafif dokunma
  static void lightImpact() {
    if (_isEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Orta dokunma
  static void mediumImpact() {
    if (_isEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Şiddetli dokunma
  static void heavyImpact() {
    if (_isEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Seçim dokunma
  static void selectionClick() {
    if (_isEnabled) {
      HapticFeedback.selectionClick();
    }
  }
}
