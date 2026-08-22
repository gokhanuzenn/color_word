import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Neubrutalism stilinde kart
class NeubrutalCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final bool showShadow;

  const NeubrutalCard({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.background,
    this.borderColor = AppColors.border,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.onTap,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppConstants.paddingMedium),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: AppConstants.borderWidth,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.shadow,
                  offset: const Offset(
                    AppConstants.shadowOffset,
                    AppConstants.shadowOffset,
                  ),
                ),
              ]
            : [],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// İlerleme çubuğu içeren kart
class ProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final Color progressColor;
  final VoidCallback? onTap;

  const ProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.progressColor = AppColors.buttonSecondary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NeubrutalCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          // İlerleme çubuğu
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(
                color: AppColors.border,
                width: 2,
              ),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                color: progressColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
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
    );
  }
}
