import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Desteklenen diller
const List<Locale> supportedLocales = [
  Locale('tr', 'TR'),  // Türkçe
  Locale('en', ''),    // İngilizce
  Locale('de', ''),    // Almanca
  Locale('fr', ''),    // Fransızca
  Locale('es', ''),    // İspanyolca
  Locale('ar', ''),    // Arapça
  Locale('zh', ''),    // Çince
  Locale('ja', ''),    // Japonca
  Locale('ko', ''),    // Korece
  Locale('pt', ''),    // Portekizce
  Locale('ru', ''),    // Rusça
];

/// Dil kodlarını ARB dosyalarına eşle
const Map<String, String> _localeFiles = {
  'tr': 'app_tr',
  'en': 'app_en',
  'de': 'app_de',
  'fr': 'app_fr',
  'es': 'app_es',
  'ar': 'app_ar',
  'zh': 'app_zh',
  'ja': 'app_ja',
  'ko': 'app_ko',
  'pt': 'app_pt',
  'ru': 'app_ru',
};

/// Çeviri sınıfı
class AppLocalizations {
  final Locale locale;
  late Map<String, dynamic> _translations;

  AppLocalizations(this.locale);

  /// Mevcut AppLocalizations'ı al
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Dil dosyasını yükle
  Future<bool> load() async {
    final langCode = locale.languageCode;
    final fileName = _localeFiles[langCode] ?? 'app_en';
    
    try {
      final jsonString = await rootBundle.loadString('lib/l10n/$fileName.arb');
      _translations = json.decode(jsonString);
      return true;
    } catch (e) {
      // Hata olursa İngilizce'ye dön
      final fallback = await rootBundle.loadString('lib/l10n/app_en.arb');
      _translations = json.decode(fallback);
      return false;
    }
  }

  /// Çeviri metni al
  String translate(String key, {Map<String, dynamic>? params}) {
    String? value;
    
    // Önce doğrudan anahtarı dene
    value = _translations[key]?.toString();
    
    // Bulamazsan iç içe haritalarda dene
    if (value == null) {
      for (final mapKey in _translations.keys) {
        if (_translations[mapKey] is Map) {
          value = (_translations[mapKey] as Map)[key]?.toString();
          if (value != null) break;
        }
      }
    }
    
    // Hala bulamazsan İngilizce'ye dön
    value ??= key;
    
    // Parametreleri değiştir
    if (params != null) {
      for (final entry in params.entries) {
        value = value!.replaceAll('@${entry.key}', entry.value.toString());
      }
    }
    
    return value!;
  }

  /// Kategori adını çevir
  String getCategoryName(String categoryId) {
    final categories = _translations['categories_${locale.languageCode}'];
    if (categories is Map) {
      return categories[categoryId]?.toString() ?? categoryId;
    }
    return categoryId;
  }
}

/// Localization delegesi
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return supportedLocales.any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
