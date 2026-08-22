import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/theme/app_theme.dart';
import 'data/services/database_service.dart';
import 'data/services/audio_service.dart';
import 'data/services/custom_image_service.dart';
import 'data/services/ad_service.dart';
import 'features/home/home_page.dart';
import 'core/widgets/app_logo.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive'ı başlat
  await Hive.initFlutter();

  // AdMob'u başlat
  await MobileAds.instance.initialize();

  // Servisleri başlat
  await DatabaseService.instance.init();
  await AppAudioService.instance.init();
  await CustomImageService.instance.init();
  await AdService.instance.isPremium(); // Premium durumunu kontrol et

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
      // Otomatik dil algılama - cihazın dilini kullan
      localeResolutionCallback: (locale, supportedLocales) {
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('tr', 'TR'); // Varsayılan: Türkçe
      },
      home: const SplashScreen(),
    );
  }
}

/// Açılış ekranı
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    // Ana sayfaya yönlendir
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo - Yeni Modern Logo
              const AppLogoLarge(size: 160),
              const SizedBox(height: 32),
              const Text(
                'ColorWord',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 8),
              // Çevrilmiş alt başlık
              const Text(
                'Renklerle kelime öğren!',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF6B6B6B),
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                strokeWidth: 4,
                color: Color(0xFF1E1E1E),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
