import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Seçilebilir renk paleti
class ColorPalette extends StatelessWidget {
  final int selectedIndex;
  final Function(int index) onColorSelected;

  const ColorPalette({
    super.key,
    required this.selectedIndex,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          color: AppColors.border,
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
          const Text(
            '🎨 Renk Seç',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              AppColors.paintingPalette.length,
              (index) {
                final color = AppColors.paintingPalette[index];
                final isSelected = index == selectedIndex;
                return GestureDetector(
                  onTap: () => onColorSelected(index),
                  child: AnimatedContainer(
                    duration: AppConstants.animFast,
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.border
                            : AppColors.border.withOpacity(0.3),
                        width: isSelected ? 4 : 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              const BoxShadow(
                                color: AppColors.shadow,
                                offset: Offset(3, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: AppColors.textPrimary,
                            size: 28,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
