import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Kelime gösterimi için kart
class WordCard extends StatelessWidget {
  final String word;
  final String meaning;
  final bool isDiscovered;
  final List<String> discoveredLetters;
  final VoidCallback? onTap;

  const WordCard({
    super.key,
    required this.word,
    required this.meaning,
    this.isDiscovered = false,
    this.discoveredLetters = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: isDiscovered
              ? AppColors.buttonSecondary.withOpacity(0.2)
              : AppColors.background,
          border: Border.all(
            color: isDiscovered
                ? AppColors.buttonSecondary
                : AppColors.border,
            width: AppConstants.borderWidth,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              offset: Offset(
                AppConstants.shadowOffset,
                AppConstants.shadowOffset,
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Harfler
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: word.split('').map((letter) {
                final isDiscoveredLetter =
                    discoveredLetters.contains(letter.toUpperCase());
                return AnimatedContainer(
                  duration: AppConstants.animNormal,
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDiscoveredLetter
                        ? AppColors.buttonPrimary
                        : Colors.white,
                    border: Border.all(
                      color: AppColors.border,
                      width: 2,
                    ),
                    boxShadow: isDiscoveredLetter
                        ? [
                            const BoxShadow(
                              color: AppColors.shadow,
                              offset: Offset(2, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      isDiscoveredLetter ? letter : '?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDiscoveredLetter
                            ? AppColors.textPrimary
                            : AppColors.textSecondary.withOpacity(0.5),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Anlamı
            if (isDiscovered)
              Text(
                meaning,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              )
            else
              Text(
                'Boyayarak keşfet!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Tek harf kutusu
class LetterBox extends StatelessWidget {
  final String letter;
  final bool isRevealed;
  final bool isActive;

  const LetterBox({
    super.key,
    required this.letter,
    this.isRevealed = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppConstants.animFast,
      width: AppConstants.minTouchTarget,
      height: AppConstants.minTouchTarget,
      decoration: BoxDecoration(
        color: isRevealed
            ? AppColors.buttonPrimary
            : isActive
                ? AppColors.buttonAccent.withOpacity(0.3)
                : Colors.white,
        border: Border.all(
          color: isActive ? AppColors.buttonAccent : AppColors.border,
          width: isActive ? 3 : 2,
        ),
        boxShadow: isRevealed
            ? [
                const BoxShadow(
                  color: AppColors.shadow,
                  offset: Offset(2, 2),
                ),
              ]
            : [],
      ),
      child: Center(
        child: Text(
          isRevealed ? letter : '?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: isRevealed
                ? AppColors.textPrimary
                : AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
