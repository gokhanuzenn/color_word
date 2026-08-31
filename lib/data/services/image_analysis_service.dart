import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tespit edilen bir boyama bölgesi
class ColoringRegion {
  final int number;
  final Color displayColor;
  bool isColored;
  Color? fillColor;

  ColoringRegion({
    required this.number,
    required this.displayColor,
    this.isColored = false,
    this.fillColor,
  });
}

/// Resim analiz sonucu
class ImageAnalysisResult {
  final ui.Image image;
  final List<ColoringRegion> regions;
  final Uint8List regionGrid; // Her piksel için region ID
  final int gridWidth;
  final int gridHeight;
  final int imageWidth;
  final int imageHeight;
  final int downsampleFactor;

  ImageAnalysisResult({
    required this.image,
    required this.regions,
    required this.regionGrid,
    required this.gridWidth,
    required this.gridHeight,
    required this.imageWidth,
    required this.imageHeight,
    required this.downsampleFactor,
  });

  /// Ekran koordinatını region grid'e çevir
  int? getRegionAt(double x, double y, double displayWidth, double displayHeight) {
    // Resim display_WIDTH x display_HEIGHT alanına contain ile çiziliyor
    // offsetX/Y resmin sol üst köşesinin konumu
    final scaleX = imageWidth / displayWidth;
    final scaleY = imageHeight / displayHeight;
    final scale = scaleX > scaleY ? scaleX : scaleY;

    final renderedWidth = imageWidth / scale;
    final renderedHeight = imageHeight / scale;
    final offsetX = (displayWidth - renderedWidth) / 2;
    final offsetY = (displayHeight - renderedHeight) / 2;

    // Ekran koordinatından resim piksel koordinatına çevir
    final imgX = (x - offsetX) * scale;
    final imgY = (y - offsetY) * scale;

    if (imgX < 0 || imgY < 0 || imgX >= imageWidth || imgY >= imageHeight) return null;

    // Resim pikselinden grid indeksine çevir
    final gx = (imgX / downsampleFactor).floor();
    final gy = (imgY / downsampleFactor).floor();

    if (gx < 0 || gy < 0 || gx >= gridWidth || gy >= gridHeight) return null;

    return regionGrid[gy * gridWidth + gx];
  }
}

class ImageAnalysisService {
  static final ImageAnalysisService instance = ImageAnalysisService._();
  ImageAnalysisService._();

  /// Bir resmi analiz et ve bölgeleri tespit et
  Future<ImageAnalysisResult?> analyzeImage(String assetPath) async {
    try {
      // Resmi yükle
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final imgWidth = image.width;
      final imgHeight = image.height;

      // Piksel verilerini oku
      final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return null;
      final pixels = byteData.buffer.asUint8List();

      // Downscale faktörü (1000px üstünde küçült)
      final downsample = imgWidth > 1000 || imgHeight > 1000 ? 2 : 1;
      final gw = (imgWidth / downsample).ceil();
      final gh = (imgHeight / downsample).ceil();

      // Grid oluştur - her piksel çizgi mi değil mi
      // Uint8List: 0=beyaz(boş), 1=çizgi, 2+=region ID
      final grid = Uint8List(gw * gh);

      // Pikselleri grid'e dönüştür
      for (int gy = 0; gy < gh; gy++) {
        for (int gx = 0; gx < gw; gx++) {
          final px = (gx * downsample).clamp(0, imgWidth - 1);
          final py = (gy * downsample).clamp(0, imgHeight - 1);
          final idx = (py * imgWidth + px) * 4;
          final r = pixels[idx];
          final g = pixels[idx + 1];
          final b = pixels[idx + 2];
          final brightness = (r * 0.299 + g * 0.587 + b * 0.114).round();

          // Siyah çizgiler = 1, beyaz bölgeler = 0
          grid[gy * gw + gx] = brightness < 180 ? 1 : 0;
        }
      }

      // Region renkleri - canlı ve çeşitli
      final regionColors = [
        const Color(0xFFE74C3C), // Koyu kırmızı
        const Color(0xFF2ECC71), // Yeşil
        const Color(0xFF3498DB), // Mavi
        const Color(0xFFF39C12), // Turuncu
        const Color(0xFF9B59B6), // Mor
        const Color(0xFF1ABC9C), // Turkuaz
        const Color(0xFFE91E63), // Pembe
        const Color(0xFF00BCD4), // Cyan
        const Color(0xFFFF5722), // Koyu turuncu
        const Color(0xFF607D8B), // Blue Grey
        const Color(0xFF8BC34A), // Light Green
        const Color(0xFFFF9800), // Orange
        const Color(0xFF795548), // Brown
        const Color(0xFFCDDC39), // Lime
        const Color(0xFF673AB7), // Deep Purple
        const Color(0xFF009688), // Teal
        const Color(0xFFF44336), // Red
        const Color(0xFF4CAF50), // Green
        const Color(0xFF2196F3), // Blue
        const Color(0xFFFFEB3B), // Yellow
      ];

      // Flood fill ile bölgeleri tespit et
      final regions = <ColoringRegion>[];
      int nextRegionId = 2; // 0=beyaz, 1=çizgi, 2+=region

      for (int gy = 0; gy < gh; gy++) {
        for (int gx = 0; gx < gw; gx++) {
          final idx = gy * gw + gx;
          if (grid[idx] == 0) {
            // Yeni beyaz bölge bulundu
            final regionPixelCount = _floodFill(grid, gw, gh, gx, gy, nextRegionId);

            // Çok küçük bölgeleri atla (gürültü)
            if (regionPixelCount > 20) {
              regions.add(ColoringRegion(
                number: regions.length + 1,
                displayColor: regionColors[regions.length % regionColors.length],
              ));
              nextRegionId++;
            } else {
              // Küçük bölgeyi çizgi olarak işaretle
              _floodFill(grid, gw, gh, gx, gy, 1);
            }
          }
        }
      }

      return ImageAnalysisResult(
        image: image,
        regions: regions,
        regionGrid: grid,
        gridWidth: gw,
        gridHeight: gh,
        imageWidth: imgWidth,
        imageHeight: imgHeight,
        downsampleFactor: downsample,
      );
    } catch (e) {
      debugPrint('Image analysis error: $e');
      return null;
    }
  }

  /// Flood fill - BFS tabanlı
  int _floodFill(Uint8List grid, int w, int h, int startX, int startY, int fillValue) {
    final target = grid[startY * w + startX];
    if (target == fillValue) return 0;

    int count = 0;
    final queue = <int>[];
    queue.add(startY * w + startX);
    final visited = <int>{startY * w + startX};
    grid[startY * w + startX] = fillValue;
    count++;

    // 4-connected flood fill
    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      final cx = current % w;
      final cy = current ~/ w;

      // 4 yön: yukarı, aşağı, sol, sağ
      const dx = [0, 0, -1, 1];
      const dy = [-1, 1, 0, 0];

      for (int i = 0; i < 4; i++) {
        final nx = cx + dx[i];
        final ny = cy + dy[i];
        if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
        final nIdx = ny * w + nx;
        if (visited.contains(nIdx)) continue;
        if (grid[nIdx] != target) continue;

        visited.add(nIdx);
        grid[nIdx] = fillValue;
        queue.add(nIdx);
        count++;
      }
    }

    return count;
  }
}
