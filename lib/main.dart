import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/haptic_helper.dart';
import 'data/services/database_service.dart';
import 'data/services/score_service.dart';
import 'data/services/ad_service.dart';
import 'features/splash/splash_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive'ı başlat
  try {
    await Hive.initFlutter();
    await DatabaseService.instance.init();
  } catch (e) {
    // Hive hatası, uygulama çalışmaya devam etsin
  }

  // Haptic feedback ayarlarını yükle
  try {
    await HapticHelper.init();
  } catch (e) {
    // Haptic hatası, devam et
  }

  // Skor servisini başlat
  try {
    await ScoreService.instance.init();
  } catch (e) {
    // Skor hatası, devam et
  }

  // Reklam servisini başlat
  try {
    await AdService.instance.initialize();
  } catch (e) {
    // Reklam hatası, uygulama çalışmaya devam etsin
  }

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
      // Hata yakalayıcı
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
