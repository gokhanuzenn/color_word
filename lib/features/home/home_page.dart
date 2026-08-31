import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/neubrutal_button.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/neubrutal_card.dart';
import '../categories/categories_page.dart';
import '../settings/settings_page.dart';
import '../settings/admin_page.dart';
import '../score/scoreboard_page.dart';
import '../educational/educational_page.dart';
import '../coloring/numbered_coloring_page.dart';
import '../../l10n/app_localizations.dart';
import '../../data/services/score_service.dart';
import '../../core/utils/responsive_helper.dart';
import '../../data/services/ad_service.dart';

/// Ana sayfa
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _logoTapCount = 0;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // İlk açılışta reklam gösterilmez - sadece periyodik reklamlar başlatılır
      AdService.instance.startPeriodicAds();
    });
  }

  @override
  void dispose() {
    AdService.instance.stopPeriodicAds();
    super.dispose();
  }

  void _onLogoTap() {
    final now = DateTime.now();
    // 2 saniyeden fazla geçtiyse sayacı sıfırla
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _logoTapCount = 0;
    }
    _lastTapTime = now;
    _logoTapCount++;

    // 7 kez tıkladıysa admin sayfasına git
    if (_logoTapCount >= 7) {
      _logoTapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo (gizli tıklama)
              GestureDetector(
                onTap: _onLogoTap,
                child: const AppLogo(size: 100),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.3),

              const SizedBox(height: 8),

              const Text(
                'ColorWord',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.safe(context);
                  return Text(
                    l10n.translate('appDescription'),
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

              const SizedBox(height: AppConstants.paddingExtraLarge),
              const Spacer(),

              // Ana butonlar
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.safe(context);
                  return Column(
                    children: [
                      NeubrutalButton(
                        label: '🚀 ${l10n.translate("start")}',
                        backgroundColor: AppColors.buttonPrimary,
                        width: double.infinity,
                        height: 60,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoriesPage(),
                            ),
                          );
                        },
                      ).animate().fadeIn(delay: 600.ms, duration: 600.ms)
                          .slideY(begin: 0.3),

                      const SizedBox(height: 16),

                      // Skor Tablosu Butonu
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ScoreboardPage(),
                            ),
                          ).then((_) => setState(() {}));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🏆', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Skor Tablosu',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '⭐ ${ScoreService.instance.totalStars} yıldız  •  ${ScoreService.instance.getRank()}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right, color: Colors.white),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 700.ms, duration: 600.ms)
                          .slideY(begin: 0.3),

                      const SizedBox(height: 16),

                      // Eğitim Oyunları Butonu
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EducationalPage(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('📚', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Eğitim Oyunları',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Harf, sayı, şekil öğren',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right, color: Colors.white),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 750.ms, duration: 600.ms)
                          .slideY(begin: 0.3),

                      const SizedBox(height: 16),

                      // Numaralı Boyama Butonu
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NumberedColoringPage(
                                categoryName: 'Boyama Kitabı',
                                categoryIcon: '🎨',
                                categoryColor: Color(0xFFFF6B6B),
                                initialImageIndex: 0,
                                imagePaths: [],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B6B).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🔢', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Numaralı Boyama',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Rakamları eşleştirerek boyama yap',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right, color: Colors.white),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 800.ms, duration: 600.ms)
                          .slideY(begin: 0.3),

                      const SizedBox(height: 16),

                      NeubrutalButton(
                        label: '⚙️ ${l10n.translate("settings")}',
                        backgroundColor: AppColors.buttonSecondary,
                        width: double.infinity,
                        height: 60,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          );
                        },
                      ).animate().fadeIn(delay: 800.ms, duration: 600.ms)
                          .slideY(begin: 0.3),
                    ],
                  );
                },
              ),

              const SizedBox(height: AppConstants.paddingMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
