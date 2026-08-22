import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Boyama tuvali widget'ı
class ColoringCanvas extends StatefulWidget {
  final List<CanvasRegion> regions;
  final int selectedColorIndex;
  final Function(String regionId, Color color) onRegionTapped;
  final Function(double progress) onProgressChanged;

  const ColoringCanvas({
    super.key,
    required this.regions,
    required this.selectedColorIndex,
    required this.onRegionTapped,
    required this.onProgressChanged,
  });

  @override
  State<ColoringCanvas> createState() => _ColoringCanvasState();
}

class _ColoringCanvasState extends State<ColoringCanvas> {
  final Map<String, Color> _coloredRegions = {};

  Color get _currentColor =>
      AppColors.paintingPalette[widget.selectedColorIndex];

  double get _progress {
    if (widget.regions.isEmpty) return 0.0;
    return _coloredRegions.length / widget.regions.length;
  }

  void _onRegionTapped(String regionId) {
    setState(() {
      _coloredRegions[regionId] = _currentColor;
    });
    widget.onRegionTapped(regionId, _currentColor);
    widget.onProgressChanged(_progress);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Stack(
          children: [
            // Arka plan (çizim)
            CustomPaint(
              size: Size.infinite,
              painter: ColoringPainter(
                regions: widget.regions,
                coloredRegions: _coloredRegions,
              ),
            ),
            // Tıklanabilir bölgeler
            ...widget.regions.map((region) {
              final isColored = _coloredRegions.containsKey(region.id);
              return Positioned(
                left: region.x,
                top: region.y,
                child: GestureDetector(
                  onTap: () => _onRegionTapped(region.id),
                  child: Container(
                    width: region.width,
                    height: region.height,
                    decoration: BoxDecoration(
                      color: isColored
                          ? _coloredRegions[region.id]
                          : Colors.transparent,
                      border: isColored
                          ? null
                          : Border.all(
                              color: AppColors.border.withOpacity(0.3),
                              width: 1,
                            ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Boyama bölgesi verisi
class CanvasRegion {
  final String id;
  final double x;
  final double y;
  final double width;
  final double height;
  final Path? path;

  const CanvasRegion({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.path,
  });
}

/// Boyama painter'ı
class ColoringPainter extends CustomPainter {
  final List<CanvasRegion> regions;
  final Map<String, Color> coloredRegions;

  ColoringPainter({
    required this.regions,
    required this.coloredRegions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppConstants.borderWidth;

    // Her bölgeyi çiz
    for (final region in regions) {
      final isColored = coloredRegions.containsKey(region.id);
      final rect = Rect.fromLTWH(region.x, region.y, region.width, region.height);

      if (isColored) {
        // Renkli bölge
        final fillPaint = Paint()..color = coloredRegions[region.id]!;
        canvas.drawRect(rect, fillPaint);
      } else {
        // Boş bölge (sadece kenarlık)
        canvas.drawRect(rect, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
