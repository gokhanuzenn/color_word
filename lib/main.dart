import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/haptic_helper.dart';
import 'data/services/database_service.dart';
import 'data/services/score_service.dart';
import 'data/services/ad_service.dart';
import 'features/home/home_page.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive'ı başlat
  try {
    await Hive.initFlutter();
    await DatabaseService.instance.init();
  } catch (e) {
    debugPrint('Başlatma hatası: $e');
  }

  // Haptic feedback ayarlarını yükle
  await HapticHelper.init();

  // Skor servisini başlat
  await ScoreService.instance.init();

  // Reklam servisini başlat
  await AdService.instance.initialize();

  runApp(
    const ProviderScope(
      child: ColorWordApp(),
    ),
  );
}

/// Ana uygulama widget'ı
class ColorWordApp extends StatelessWidget {
  const ColorWordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ColorWord',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      // Çok dilli destek
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('tr', 'TR');
      },
      // Doğrudan ana sayfaya git (splash screen kaldırıldı)
      home: const HomePage(),
    );
  }
}
