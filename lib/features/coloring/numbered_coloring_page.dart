import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/utils/haptic_helper.dart';
import '../../data/services/score_service.dart';
import '../../data/services/ad_service.dart';
import '../../data/services/image_analysis_service.dart';

/// Numaralı boyama sayfası - Happy Color tarzı
/// Resmi analiz eder, çizgiler arasındaki bölgeleri tespit edip boyama yaptırır
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
  bool _isLoading = true;
  String? _errorMessage;

  // Analiz sonucu
  ImageAnalysisResult? _analysisResult;

  // Seçili renk indeksi (paletten)
  int? _selectedPaletteIndex;

  // Zoom/Pan
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  double _lastScale = 1.0;
  Offset _lastFocalPoint = Offset.zero;
  Offset _lastOffset = Offset.zero;

  // Tamamlanma efekti
  bool _showSparkle = false;
  late AnimationController _sparkleController;

  // Boyama için kullanılan renkler (palet)
  late List<Color> _colorPalette;

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
    _generateColorPalette();
    _loadAndAnalyzeImage();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _analysisResult?.image.dispose();
    super.dispose();
  }

  void _generateColorPalette() {
    _colorPalette = [
      const Color(0xFFE74C3C), // Kırmızı
      const Color(0xFF2ECC71), // Yeşil
      const Color(0xFF3498DB), // Mavi
      const Color(0xFFF39C12), // Turuncu
      const Color(0xFF9B59B6), // Mor
      const Color(0xFF1ABC9C), // Turkuaz
      const Color(0xFFE91E63), // Pembe
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFF5722), // Koyu turuncu
      const Color(0xFF8BC34A), // Açık yeşil
      const Color(0xFFFF9800), // Orange
      const Color(0xFF795548), // Kahverengi
      const Color(0xFFCDDC39), // Lime
      const Color(0xFF673AB7), // Deep Purple
      const Color(0xFF009688), // Teal
      const Color(0xFFF44336), // Red
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFFEB3B), // Sarı
      const Color(0xFF607D8B), // Blue Grey
    ];
  }

  Future<void> _loadAndAnalyzeImage() async {
    if (widget.isBlankCanvas || widget.imagePaths.isEmpty) {
      setState(() {
        _isLoading = false;
        _analysisResult = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final path = widget.imagePaths[_currentPage.clamp(0, widget.imagePaths.length - 1)];
      final result = await ImageAnalysisService.instance.analyzeImage(path);

      if (mounted) {
        setState(() {
          _analysisResult = result;
          _isLoading = false;
          if (result == null) {
            _errorMessage = 'Resim analiz edilemedi';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Hata: $e';
        });
      }
    }
  }

  void _onRegionTap(TapUpDetails details) {
    if (_analysisResult == null || _selectedPaletteIndex == null) return;

    final RenderBox? renderBox =
        context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Tap pozisyonunu coloring area içindeki koordinata çevir
    final localPos = renderBox.globalToLocal(details.globalPosition);

    // Coloring area top bar + padding sonrası başlıyor
    // Yaklaşık hesaplama
    final appBarHeight = 60.0;
    final topPadding = 8.0;
    final bottomPanelHeight = 120.0;
    final availableHeight = renderBox.size.height - appBarHeight - topPadding * 2 - bottomPanelHeight;
    final availableWidth = renderBox.size.width - topPadding * 2;

    final drawingX = localPos.dx - topPadding;
    final drawingY = localPos.dy - appBarHeight - topPadding;

    if (drawingX < 0 || drawingY < 0 || drawingX > availableWidth || drawingY > availableHeight) return;

    // Region grid'den hangi bölgeye dokunulduğunu bul
    final regionId = _analysisResult!.getRegionAt(
      drawingX,
      drawingY,
      availableWidth,
      availableHeight,
    );

    if (regionId == null || regionId <= 1) return; // Çizgi veya boş

    final regionIndex = regionId - 2; // 0'dan başlayan index
    if (regionIndex < 0 || regionIndex >= _analysisResult!.regions.length) return;

    final region = _analysisResult!.regions[regionIndex];
    if (region.isColored) return; // Zaten boyanmış

    // Bölgeyi boyandı olarak işaretle
    setState(() {
      region.isColored = true;
      region.fillColor = _colorPalette[_selectedPaletteIndex!];
    });

    HapticHelper.mediumImpact();

    // Tüm bölgeler boyandı mı?
    if (_analysisResult!.regions.every((r) => r.isColored)) {
      _onAllRegionsColored();
    }
  }

  void _onAllRegionsColored() {
    setState(() => _showSparkle = true);
    _sparkleController.forward(from: 0);
    HapticHelper.heavyImpact();
    ScoreService.instance.addDailyColoring();

    if (mounted) {
      final scoreData = ScoreService.instance.getScoreData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Tebrikler! Tümünü boyadın! ⭐ +1 Yıldız  |  Toplam: ${scoreData['totalStars']}'),
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
            _analysisResult = null;
            _scale = 1.0;
            _offset = Offset.zero;
            _selectedPaletteIndex = null;
          });
          _loadAndAnalyzeImage();
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
    } else if (details.pointerCount == 1 && _scale > 1.0) {
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
            _buildColorPalette(),
            _buildBottomInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final coloredCount = _analysisResult?.regions.where((r) => r.isColored).length ?? 0;
    final totalCount = _analysisResult?.regions.length ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 22),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.categoryIcon} ${widget.categoryName}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                Text(
                  _analysisResult != null
                      ? 'Sayfa ${_currentPage + 1}/${widget.imagePaths.length}  •  $coloredCount/$totalCount bölge'
                      : 'Sayfa ${_currentPage + 1}/${widget.imagePaths.length}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Geri al
          _buildSmallButton(
            icon: Icons.undo,
            onTap: coloredCount > 0 ? () => _undoLastRegion() : null,
          ),
          // Sıfırla
          _buildSmallButton(
            icon: Icons.refresh,
            onTap: coloredCount > 0 ? () => _resetAllRegions() : null,
          ),
          // Zoom küçült
          if (_scale > 1.0)
            _buildSmallButton(icon: Icons.zoom_out, onTap: _resetZoom),
          // Sayfa değiştirme
          if (!widget.isBlankCanvas && widget.imagePaths.length > 1) ...[
            _buildSmallButton(
              icon: Icons.chevron_left,
              onTap: _currentPage > 0 ? () => _changePage(-1) : null,
            ),
            _buildSmallButton(
              icon: Icons.chevron_right,
              onTap: _currentPage < widget.imagePaths.length - 1 ? () => _changePage(1) : null,
            ),
          ],
        ],
      ),
    );
  }

  void _undoLastRegion() {
    if (_analysisResult == null) return;
    final lastColored = _analysisResult!.regions.lastWhere(
      (r) => r.isColored,
      orElse: () => ColoringRegion(number: 0, displayColor: Colors.transparent),
    );
    if (lastColored.number > 0) {
      setState(() {
        lastColored.isColored = false;
        lastColored.fillColor = null;
      });
      HapticHelper.lightImpact();
    }
  }

  void _resetAllRegions() {
    if (_analysisResult == null) return;
    HapticHelper.heavyImpact();
    setState(() {
      for (final region in _analysisResult!.regions) {
        region.isColored = false;
        region.fillColor = null;
      }
    });
  }

  Widget _buildSmallButton({required IconData icon, VoidCallback? onTap}) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 2),
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
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Ana çizim alanı
              GestureDetector(
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onScaleEnd: _onScaleEnd,
                onTapUp: _onRegionTap,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..translate(_offset.dx, _offset.dy)
                    ..scale(_scale, _scale),
                  child: Stack(
                    children: [
                      // Beyaz arka plan
                      const Positioned.fill(child: ColoredBox(color: Colors.white)),

                      // Resim
                      if (!widget.isBlankCanvas && widget.imagePaths.isNotEmpty)
                        Positioned.fill(
                          child: _buildImage(),
                        ),

                      // Boyanmış bölgeler + Numaralar
                      if (_analysisResult != null)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _RegionPainter(
                              analysisResult: _analysisResult!,
                              displayWidth: double.infinity,
                              displayHeight: double.infinity,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Loading
              if (_isLoading)
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Resim analiz ediliyor...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),

              // Hata
              if (_errorMessage != null && !_isLoading)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                      const SizedBox(height: 8),
                      Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadAndAnalyzeImage,
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                ),

              // Seçili renk göstergesi
              if (_selectedPaletteIndex != null)
                Positioned(
                  left: 8, top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            color: _colorPalette[_selectedPaletteIndex!],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Dokunarak boyayın',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

              // Zoom bilgisi
              if (_scale > 1.0)
                Positioned(
                  left: 8, bottom: 8,
                  child: GestureDetector(
                    onTap: _resetZoom,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(_scale * 100).toInt()}% • Dokun',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),

              // Parıltı efekti
              if (_showSparkle) ..._buildSparkles(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
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

  Widget _buildColorPalette() {
    if (_analysisResult == null) return const SizedBox.shrink();

    final uncoloredCount = _analysisResult!.regions.where((r) => !r.isColored).length;
    if (uncoloredCount == 0) return const SizedBox.shrink();

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedPaletteIndex != null ? 'Bir bölgeye dokunarak boyayın ↓' : 'Bir renk seçin ↓',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _colorPalette.length,
              itemBuilder: (context, index) {
                final color = _colorPalette[index];
                final isSelected = _selectedPaletteIndex == index;
                return GestureDetector(
                  onTap: () {
                    HapticHelper.selectionClick();
                    setState(() => _selectedPaletteIndex = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey[300]!,
                        width: isSelected ? 3 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2))]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
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

  Widget _buildBottomInfo() {
    final coloredCount = _analysisResult?.regions.where((r) => r.isColored).length ?? 0;
    final totalCount = _analysisResult?.regions.length ?? 0;
    final progress = totalCount > 0 ? coloredCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Icon(Icons.palette, size: 16, color: widget.categoryColor),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(widget.categoryColor),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$coloredCount/$totalCount',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          if (coloredCount == totalCount && totalCount > 0) ...[
            const SizedBox(width: 8),
            const Text('🎉', style: TextStyle(fontSize: 16)),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildSparkles() {
    final random = Random();
    return List.generate(20, (index) {
      return Positioned(
        left: random.nextDouble() * 400,
        top: random.nextDouble() * 600,
        child: AnimatedBuilder(
          animation: _sparkleController,
          builder: (context, child) {
            final progress = _sparkleController.value;
            final opacity = (progress * 2 - index * 0.08).clamp(0.0, 1.0);
            final scale = 0.5 + progress * 0.5;
            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Text(
                  ['✨', '⭐', '🌟', '💫', '🎉'][index % 5],
                  style: TextStyle(fontSize: 18 + random.nextDouble() * 16),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

/// Bölge çizici - boyanmış bölgeleri ve numaraları çizer
class _RegionPainter extends CustomPainter {
  final ImageAnalysisResult analysisResult;
  final double displayWidth;
  final double displayHeight;

  _RegionPainter({
    required this.analysisResult,
    required this.displayWidth,
    required this.displayHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (analysisResult.regions.isEmpty) return;

    final imgW = analysisResult.imageWidth.toDouble();
    final imgH = analysisResult.imageHeight.toDouble();
    final gw = analysisResult.gridWidth;
    final gh = analysisResult.gridHeight;

    // Resmin ekranda nasıl çizildiğini hesapla (BoxFit.contain)
    final scaleX = size.width / imgW;
    final scaleY = size.height / imgH;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    final renderedW = imgW * scale;
    final renderedH = imgH * scale;
    final offsetX = (size.width - renderedW) / 2;
    final offsetY = (size.height - renderedH) / 2;

    // Her region için boundary bul ve çiz
    final regionBoundaries = <int, List<Offset>>{};

    // Grid tara - her region için boundary noktalarını topla
    for (int gy = 0; gy < gh; gy++) {
      for (int gx = 0; gx < gw; gx++) {
        final pixel = analysisResult.regionGrid[gy * gw + gx];
        if (pixel <= 1) continue; // Çizgi veya boş

        // Bu piksel bir region'a ait - boundary kontrolü
        bool isBoundary = false;
        const dx = [0, 0, -1, 1];
        const dy = [-1, 1, 0, 0];
        for (int d = 0; d < 4; d++) {
          final nx = gx + dx[d];
          final ny = gy + dy[d];
          if (nx < 0 || ny < 0 || nx >= gw || ny >= gh) {
            isBoundary = true;
            break;
          }
          if (analysisResult.regionGrid[ny * gw + nx] != pixel) {
            isBoundary = true;
            break;
          }
        }

        if (isBoundary) {
          final screenX = offsetX + (gx * analysisResult.downsampleFactor) * scale + analysisResult.downsampleFactor * scale / 2;
          final screenY = offsetY + (gy * analysisResult.downsampleFactor) * scale + analysisResult.downsampleFactor * scale / 2;
          regionBoundaries.putIfAbsent(pixel, () => []).add(Offset(screenX, screenY));
        }
      }
    }

    // Her region'ı doldur
    for (final entry in regionBoundaries.entries) {
      final regionId = entry.key;
      final points = entry.value;
      if (points.isEmpty) continue;

      final regionIndex = regionId - 2;
      if (regionIndex < 0 || regionIndex >= analysisResult.regions.length) continue;
      final region = analysisResult.regions[regionIndex];

      if (region.isColored && region.fillColor != null) {
        // Boyanmış bölgeyi doldur - boundary points ile basit çokgen
        final paint = Paint()
          ..color = region.fillColor!.withOpacity(0.85)
          ..style = PaintingStyle.fill;

        // Convex hull basit yaklaşımı: boundary points'i kullanarak dolgu
        // Daha basit: tüm noktaları küçük daireler olarak çiz
        for (final point in points) {
          canvas.drawCircle(point, analysisResult.downsampleFactor * scale * 0.8, paint);
        }
      } else {
        // Boyanmamış bölge - numara göster
        // Bölge merkezini hesapla
        double cx = 0, cy = 0;
        for (final p in points) {
          cx += p.dx;
          cy += p.dy;
        }
        cx /= points.length;
        cy /= points.length;

        // Sadece yeterince büyük bölgelerde numara göster
        if (points.length > 15) {
          // Sayı arka planı
          final bgPaint = Paint()..color = region.displayColor.withOpacity(0.85);
          canvas.drawCircle(Offset(cx, cy), 10, bgPaint);

          // Sayı yazısı
          final textPainter = TextPainter(
            text: TextSpan(
              text: '${region.number}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
