import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Kategori seçim kartı
class CategoryCard extends StatelessWidget {
  final String title;
  final String icon;
  final Color color;
  final double progress;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.progress = 0.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // İkon
            Text(
              icon,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            // Başlık
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // İlerleme çubuğu
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '%${(progress * 100).toInt()}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
