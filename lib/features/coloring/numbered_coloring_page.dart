import 'dart:math';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/utils/haptic_helper.dart';
import '../../data/services/score_service.dart';
import '../../data/services/ad_service.dart';
import 'package:path_provider/path_provider.dart';

/// Numaralı boyama bölgesi
class NumberedRegion {
  final int number;
  final Color color;
  final List<Offset> points; // Bölge sınırları (basitleştirilmiş)
  bool isColored;

  NumberedRegion({
    required this.number,
    required this.color,
    required this.points,
    this.isColored = false,
  });
}

/// Numaralı boyama sayfası (Happy Color tarzı)
class NumberedColoringPage extends StatefulWidget {
  final String categoryName;
  final String categoryIcon;
  final Color categoryColor;
  final int initialImageIndex;
  final List<String> imagePaths;
  final bool isBlankCanvas;

  const NumberedColoringPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.initialImageIndex,
    required this.imagePaths,
    this.isBlankCanvas = false,
  });

  @override
  State<NumberedColoringPage> createState() => _NumberedColoringPageState();
}

class _NumberedColoringPageState extends State<NumberedColoringPage>
    with SingleTickerProviderStateMixin {
  late int _currentPage;
  bool _isPanning = false;
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  double _lastScale = 1.0;
  Offset _lastFocalPoint = Offset.zero;
  Offset _lastOffset = Offset.zero;

  // Numaralı boyama sistemi
  List<NumberedRegion> _regions = [];
  int? _selectedNumber;
  bool _showColorPalette = false;

  // Renk haritası - her numara için bir renk
  final Map<int, Color> _colorMap = {
    1: const Color(0xFFFF0000),
    2: const Color(0xFF00FF00),
    3: const Color(0xFF0000FF),
    4: const Color(0xFFFFFF00),
    5: const Color(0xFFFF00FF),
    6: const Color(0xFF00FFFF),
    7: const Color(0xFFFF6600),
    8: const Color(0xFF9900CC),
    9: const Color(0xFF009900),
    10: const Color(0xFFCC0066),
    11: const Color(0xFF0066CC),
    12: const Color(0xFFCC6600),
    13: const Color(0xFF660099),
    14: const Color(0xFF00CC99),
    15: const Color(0xFFCC0000),
  };

  late AnimationController _sparkleController;
  bool _showSparkle = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialImageIndex;
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _showSparkle = false);
        }
      });
    _generateRegions();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  /// Rastgele bölgeler oluştur (basitleştirilmiş)
  void _generateRegions() {
    final random = Random(_currentPage);
    final regionCount = 8 + random.nextInt(8); // 8-15 arası bölge
    _regions = [];

    for (int i = 0; i < regionCount; i++) {
      final number = i + 1;
      _regions.add(NumberedRegion(
        number: number,
        color: _colorMap[number] ?? Colors.grey,
        points: _generateRandomPoints(random),
      ));
    }

    setState(() {
      _selectedNumber = null;
    });
  }

  List<Offset> _generateRandomPoints(Random random) {
    final points = <Offset>[];
    final center = Offset(
      100 + random.nextDouble() * 400,
      100 + random.nextDouble() * 400,
    );

    // Basit bir çokgen oluştur
    final pointCount = 4 + random.nextInt(4); // 4-7 nokta
    for (int i = 0; i < pointCount; i++) {
      final angle = (2 * pi * i) / pointCount;
      final radius = 30.0 + random.nextDouble() * 50.0;
      points.add(Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      ));
    }

    return points;
  }

  /// Bölgeye dokunulduğunda
  void _onRegionTap(int number) {
    HapticHelper.lightImpact();
    setState(() {
      _selectedNumber = number;
      _showColorPalette = true;
    });
  }

  /// Renk seçildiğinde
  void _onColorSelected(int number) {
    HapticHelper.mediumImpact();
    setState(() {
      for (final region in _regions) {
        if (region.number == number) {
          region.isColored = true;
          break;
        }
      }
      _showColorPalette = false;
      _selectedNumber = null;

      // Tüm bölgeler boyandı mı kontrol et
      if (_regions.every((r) => r.isColored)) {
        _completeColoring();
      }
    });
  }

  void _completeColoring() {
    setState(() => _showSparkle = true);
    _sparkleController.forward(from: 0);
    HapticHelper.heavyImpact();
    ScoreService.instance.addDailyColoring();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Tebrikler! Tüm bölgeleri boyadın! ⭐ +1 Yıldız'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _changePage(int delta) {
    final newIndex = _currentPage + delta;
    if (newIndex >= 0 && newIndex < widget.imagePaths.length) {
      AdService.instance.showInterstitialAd(
        onAdClosed: () {
          setState(() {
            _currentPage = newIndex;
            _generateRegions();
            _scale = 1.0;
            _offset = Offset.zero;
          });
          HapticHelper.mediumImpact();
        },
      );
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.focalPoint;
    _lastScale = _scale;
    _lastOffset = _offset;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount == 2) {
      final newScale = (_lastScale * details.scale).clamp(1.0, 5.0);
      final focalDelta = details.focalPoint - _lastFocalPoint;
      setState(() {
        _scale = newScale;
        _offset = _lastOffset + focalDelta;
      });
    } else if (details.pointerCount == 1) {
      final delta = details.focalPoint - _lastFocalPoint;
      setState(() {
        _offset = _offset + delta;
      });
      _lastFocalPoint = details.focalPoint;
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {}

  void _resetZoom() {
    setState(() {
      _scale = 1.0;
      _offset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildColoringArea()),
            if (_showColorPalette) _buildColorSelectionPanel(),
            _buildBottomInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.categoryIcon} ${widget.categoryName} - Numaralı Boyama',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                Text('Sayfa ${_currentPage + 1}/${widget.imagePaths.length}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              ],
            ),
          ),
          // Boyanan bölge sayısı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_regions.where((r) => r.isColored).length}/${_regions.length}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.green),
            ),
          ),
          const SizedBox(width: 8),
          if (_scale > 1.0)
            GestureDetector(
              onTap: _resetZoom,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Küçült', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ),
          if (!widget.isBlankCanvas && widget.imagePaths.length > 1) ...[
            const SizedBox(width: 4),
            _buildSmallButton(icon: Icons.chevron_left, onTap: _currentPage > 0 ? () => _changePage(-1) : null),
            _buildSmallButton(icon: Icons.chevron_right, onTap: _currentPage < widget.imagePaths.length - 1 ? () => _changePage(1) : null),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallButton({required IconData icon, VoidCallback? onTap}) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: enabled ? Colors.grey[400]! : Colors.grey[200]!, width: 1),
        ),
        child: Icon(icon, size: 16, color: enabled ? Colors.black : Colors.grey[400]),
      ),
    );
  }

  Widget _buildColoringArea() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onScaleEnd: _onScaleEnd,
            child: Stack(
              children: [
                // Beyaz arka plan
                const Positioned.fill(child: ColoredBox(color: Colors.white)),

                // Zoom + Pan
                Transform(
                  alignment: Alignment.topLeft,
                  transform: Matrix4.identity()
                    ..translate(_offset.dx, _offset.dy)
                    ..scale(_scale, _scale),
                  child: Stack(
                    children: [
                      // Arka plan resmi
                      Positioned.fill(child: IgnorePointer(child: _buildImageWithFallback())),

                      // Numaralı bölgeler
                      Positioned.fill(child: CustomPaint(painter: RegionPainter(regions: _regions))),
                    ],
                  ),
                ),

                // Parıltı
                if (_showSparkle) ..._buildSparkles(),

                // Zoom bilgisi
                if (_scale > 1.0)
                  Positioned(
                    left: 8, bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(_scale * 100).toInt()}%',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWithFallback() {
    if (widget.imagePaths.isEmpty) {
      return const ColoredBox(color: Colors.white);
    }
    final path = widget.imagePaths[_currentPage.clamp(0, widget.imagePaths.length - 1)];

    if (path.toLowerCase().endsWith('.svg')) {
      if (path.startsWith('assets/')) {
        return SvgPicture.asset(
          path,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          placeholderBuilder: (context) => const Center(child: CircularProgressIndicator()),
        );
      }
      return SvgPicture.file(
        File(path),
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Resim yüklenemedi', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorSelectionPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _selectedNumber != null
                ? 'Bölge $_selectedNumber için renk seç'
                : 'Bir bölgeye dokunarak boyamaya başla',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colorMap.entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  if (_selectedNumber != null) {
                    _onColorSelected(_selectedNumber!);
                  }
                },
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: entry.value,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: entry.value.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo() {
    final coloredCount = _regions.where((r) => r.isColored).length;
    final totalCount = _regions.length;
    final progress = totalCount > 0 ? coloredCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.palette, size: 16, color: widget.categoryColor),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(widget.categoryColor),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          if (coloredCount == totalCount && totalCount > 0)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '🎉 Tümünü boyadın! Harika!',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildSparkles() {
    final random = Random();
    return List.generate(15, (index) {
      return Positioned(
        left: random.nextDouble() * 400,
        top: random.nextDouble() * 600,
        child: AnimatedBuilder(
          animation: _sparkleController,
          builder: (context, child) {
            return Opacity(
              opacity: (_sparkleController.value * 2 - index * 0.1).clamp(0.0, 1.0),
              child: Text(['✨', '⭐', '🌟', '💫'][index % 4], style: TextStyle(fontSize: 20 + random.nextDouble() * 20)),
            );
          },
        ),
      );
    });
  }
}

/// Bölge çizici
class RegionPainter extends CustomPainter {
  final List<NumberedRegion> regions;

  RegionPainter({required this.regions});

  @override
  void paint(Canvas canvas, Size size) {
    for (final region in regions) {
      _drawRegion(canvas, region);
    }
  }

  void _drawRegion(Canvas canvas, NumberedRegion region) {
    if (region.points.length < 3) return;

    final path = Path()
      ..moveTo(region.points[0].dx, region.points[0].dy);
    for (int i = 1; i < region.points.length; i++) {
      path.lineTo(region.points[i].dx, region.points[i].dy);
    }
    path.close();

    // Bölge dolgusu
    if (region.isColored) {
      final fillPaint = Paint()
        ..color = region.color.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);
    }

    // Bölge çizgisi
    final strokePaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);

    // Numara gösterimi
    final center = Offset(
      region.points.map((p) => p.dx).reduce((a, b) => a + b) / region.points.length,
      region.points.map((p) => p.dy).reduce((a, b) => a + b) / region.points.length,
    );

    // Numara daire
    final numberPaint = Paint()
      ..color = region.isColored ? Colors.white : Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 12, numberPaint);

    // Numara yazısı
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${region.number}',
        style: TextStyle(
          color: region.isColored ? Colors.black : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
