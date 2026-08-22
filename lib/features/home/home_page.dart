import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/neubrutal_button.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/neubrutal_card.dart';
import '../../data/providers/app_provider.dart';
import '../categories/categories_page.dart';
import '../settings/settings_page.dart';
import '../settings/admin_page.dart';
import '../../l10n/app_localizations.dart';

/// Ana sayfa
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _logoTapCount = 0;
  DateTime? _lastTapTime;

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
    final progress = ref.watch(userProgressProvider);
    final stats = ref.watch(progressStatsProvider);

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

              // İstatistikler
              if (progress != null)
                NeubrutalCard(
                  child: Column(
                    children: [
                      const Text(
                        '📊 İlerlemem',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            icon: '🔤',
                            label: 'Harf',
                            value: '${stats['letters']}',
                          ),
                          _StatItem(
                            icon: '📝',
                            label: 'Kelime',
                            value: '${stats['words']}',
                          ),
                          _StatItem(
                            icon: '🎨',
                            label: 'Boyama',
                            value: '${stats['colorings']}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

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
