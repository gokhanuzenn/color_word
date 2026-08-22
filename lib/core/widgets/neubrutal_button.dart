import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Neubrutalism stilinde buton
class NeubrutalButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final bool isActive;
  final bool isLoading;

  const NeubrutalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor = AppColors.buttonPrimary,
    this.borderColor = AppColors.border,
    this.icon,
    this.width,
    this.height = AppConstants.minTouchTarget,
    this.isActive = true,
    this.isLoading = false,
  });

  @override
  State<NeubrutalButton> createState() => _NeubrutalButtonState();
}

class _NeubrutalButtonState extends State<NeubrutalButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.isActive && !widget.isLoading) {
          widget.onPressed?.call();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        width: widget.width,
        height: widget.height,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: widget.isActive
              ? widget.backgroundColor
              : widget.backgroundColor.withOpacity(0.5),
          border: Border.all(
            color: widget.borderColor,
            width: AppConstants.borderWidth,
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: AppColors.shadow,
                    offset: const Offset(
                      AppConstants.shadowOffset,
                      AppConstants.shadowOffset,
                    ),
                  ),
                ],
        ),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.textPrimary,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 24),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
