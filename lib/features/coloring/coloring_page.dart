import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/services/achievement_service.dart';

// === MODELLER ===

class DrawStroke {
  final Color color;
  final double size;
  final List<Offset> points;
  final bool isEraser;
  final bool isFill;
  DrawStroke({
    required this.color,
    required this.size,
    required this.points,
    this.isEraser = false,
    this.isFill = false,
  });
}

class StickerItem {
  String emoji;
  double x, y;
  StickerItem({required this.emoji, required this.x, required this.y});
}

class TextItem {
  String text;
  double x, y;
  Color color;
  double fontSize;
  TextItem({
    required this.text,
    required this.x,
    required this.y,
    this.color = Colors.black,
    this.fontSize = 24,
  });
}

// === BOYAMA SAYFASI ===

class ColoringPage extends StatefulWidget {
  final String categoryName;
  final String categoryIcon;
  final Color categoryColor;
  final int initialImageIndex;
  final List<String> imagePaths;
  final bool isBlankCanvas;
  final bool isCustomImage;

  const ColoringPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.initialImageIndex,
    required this.imagePaths,
    this.isBlankCanvas = false,
    this.isCustomImage = false,
  });

  @override
  State<ColoringPage> createState() => _ColoringPageState();
}

class _ColoringPageState extends State<ColoringPage>
    with SingleTickerProviderStateMixin {
  // Sayfa
  late int _currentPage;

  // Çizim
  List<DrawStroke> _strokes = [];
  List<DrawStroke> _redoStack = [];
  Color _selectedColor = Colors.black;
  double _brushSize = 6.0;
  bool _isErasing = false;
  bool _isFilling = false;
  bool _isTextMode = false;
  String _selectedTool = 'kalem';
  String _selectedSubTool = 'HB';
  bool _showSubTools = false;
  bool _isDrawing = false;
  DrawStroke? _currentStroke;
  Offset? _eraserPosition;

  // Sticker
  bool _stickerMode = false;
  String _selectedSticker = '⭐';
  final List<StickerItem> _placedStickers = [];

  // Metin
  final List<TextItem> _placedTexts = [];
  String _inputText = '';
  double _textSize = 24;

  // Zoom
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;
  bool _isScaling = false;

  // Filtre
  int _selectedFilter = 0;
  final List<String> _filterNames = ['Orijinal', 'Retro', 'Pastel', 'Neon'];

  bool _hasUnsavedChanges = false;
  bool _showSparkle = false;
  late AnimationController _sparkleController;

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
    _startAutoSave();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  // === ÇİZİM ===

  void _startDrawing(Offset point) {
    if (_isScaling) return;
    if (_stickerMode) {
      setState(() {
        _placedStickers.add(StickerItem(
          emoji: _selectedSticker,
          x: (point.dx - _offset.dx) / _scale,
          y: (point.dy - _offset.dy) / _scale,
        ));
        _hasUnsavedChanges = true;
        _stickerMode = false;
      });
      return;
    }

    // Metin modunda
    if (_isTextMode) {
      _showTextInputDialog(point);
      return;
    }

    setState(() {
      _isDrawing = true;
      _redoStack.clear();

      if (_isFilling) {
        // Kova aracı - alan doldurma
        final adjustedPoint = Offset(
          (point.dx - _offset.dx) / _scale,
          (point.dy - _offset.dy) / _scale,
        );
        _strokes.add(DrawStroke(
          color: _selectedColor,
          size: _brushSize,
          points: [adjustedPoint],
          isFill: true,
        ));
        _isFilling = false;
        _isDrawing = false;
      } else if (_isErasing) {
        final adjustedPoint = Offset(
          (point.dx - _offset.dx) / _scale,
          (point.dy - _offset.dy) / _scale,
        );
        _eraserPosition = adjustedPoint;
        _eraseAtPoint(adjustedPoint);
      } else {
        final adjustedPoint = Offset(
          (point.dx - _offset.dx) / _scale,
          (point.dy - _offset.dy) / _scale,
        );
        _currentStroke = DrawStroke(
          color: _selectedColor,
          size: _brushSize,
          points: [adjustedPoint],
        );
      }
    });
  }

  void _continueDrawing(Offset point) {
    if (_isDrawing && !_isScaling) {
      setState(() {
        _hasUnsavedChanges = true;
        final adjustedPoint = Offset(
          (point.dx - _offset.dx) / _scale,
          (point.dy - _offset.dy) / _scale,
        );
        if (_isErasing) {
          _eraserPosition = adjustedPoint;
          _eraseAtPoint(adjustedPoint);
        } else if (_currentStroke != null) {
          _currentStroke!.points.add(adjustedPoint);
        }
      });
    }
  }

  void _endDrawing() {
    if (_isDrawing && _currentStroke != null && !_isErasing) {
      if (_currentStroke!.points.length > 1) {
        setState(() => _strokes.add(_currentStroke!));
      }
    }
    setState(() {
      _currentStroke = null;
      _isDrawing = false;
      _eraserPosition = null;
    });
  }

  void _eraseAtPoint(Offset eraserCenter) {
    final eraserRadius = _brushSize * 3;
    final newStrokes = <DrawStroke>[];
    for (final stroke in _strokes) {
      if (stroke.isEraser || stroke.isFill) {
        newStrokes.add(stroke);
        continue;
      }
      final segments = <DrawStroke>[];
      List<Offset> currentSegment = [];
      for (final point in stroke.points) {
        if ((point - eraserCenter).distance > eraserRadius) {
          currentSegment.add(point);
        } else {
          if (currentSegment.length >= 2) {
            segments.add(DrawStroke(
              color: stroke.color,
              size: stroke.size,
              points: List.from(currentSegment),
            ));
          }
          currentSegment = [];
        }
      }
      if (currentSegment.length >= 2) {
        segments.add(DrawStroke(
          color: stroke.color,
          size: stroke.size,
          points: List.from(currentSegment),
        ));
      }
      newStrokes.addAll(segments);
    }
    setState(() => _strokes = newStrokes);
  }

  // === GERİ AL / İLERİ AL ===

  void _undo() {
    if (_placedStickers.isNotEmpty) {
      setState(() {
        _placedStickers.removeLast();
      });
      return;
    }
    if (_placedTexts.isNotEmpty) {
      setState(() {
        _placedTexts.removeLast();
      });
      return;
    }
    if (_strokes.isNotEmpty) {
      setState(() => _redoStack.add(_strokes.removeLast()));
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      setState(() => _strokes.add(_redoStack.removeLast()));
    }
  }

  // === SAYFA DEĞİŞTİRME ===

  void _changePage(int delta) {
    final newIndex = _currentPage + delta;
    if (newIndex >= 0 && newIndex < widget.imagePaths.length) {
      _completeDrawing();
      setState(() {
        _currentPage = newIndex;
        _strokes.clear();
        _redoStack.clear();
        _placedStickers.clear();
        _placedTexts.clear();
        _scale = 1.0;
        _offset = Offset.zero;
      });
    }
  }

  // === TAMAMLAMA ===

  Future<void> _completeDrawing() async {
    if (_strokes.isEmpty && _placedStickers.isEmpty) return;
    final result = await AchievementService.instance.completeDrawing();
    setState(() => _showSparkle = true);
    _sparkleController.forward(from: 0);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⭐ +1 Yıldız! Toplam: ${result['stars']}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // === METİN EKLEME ===

  void _showTextInputDialog(Offset position) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Metin Ekle'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Yazınızı girin...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                setState(() {
                  _placedTexts.add(TextItem(
                    text: textController.text,
                    x: (position.dx - _offset.dx) / _scale,
                    y: (position.dy - _offset.dy) / _scale,
                    color: _selectedColor,
                    fontSize: _textSize,
                  ));
                  _isTextMode = false;
                  _selectedTool = 'kalem';
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  // === KAYDETME ===

  void _saveDrawing() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final savedDir = Directory('${directory.path}/saved_drawings');
      if (!await savedDir.exists()) await savedDir.create(recursive: true);
      final fileName = 'drawing_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${savedDir.path}/$fileName');
      final data = _strokes
          .map((s) =>
              '${s.color.value},${s.size},${s.points.map((p) => '${p.dx},${p.dy}').join(';')}')
          .join('\n');
      await file.writeAsString(data);
      await AchievementService.instance.saveDrawing(file.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('💾 Kaydedildi!'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startAutoSave() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(minutes: 2));
      if (_hasUnsavedChanges && _strokes.isNotEmpty) {
        _saveDrawingSilently();
        _hasUnsavedChanges = false;
      }
      return true;
    });
  }

  void _saveDrawingSilently() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final savedDir = Directory('${directory.path}/saved_drawings');
      if (!await savedDir.exists()) await savedDir.create(recursive: true);
      final fileName = 'drawing_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${savedDir.path}/$fileName');
      final data = _strokes
          .map((s) =>
              '${s.color.value},${s.size},${s.points.map((p) => '${p.dx},${p.dy}').join(';')}')
          .join('\n');
      await file.writeAsString(data);
      await AchievementService.instance.saveDrawing(file.path);
    } catch (e) {}
  }

  // === ANA SAYFA ===

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildDrawingArea()),
            _buildBottomPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
                Text(
                  '${widget.categoryIcon} ${widget.categoryName}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Sayfa ${_currentPage + 1} / ${widget.imagePaths.isEmpty ? 1 : widget.imagePaths.length}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Zoom göstergesi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(_scale * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
          ),
          _buildSmallButton(
            icon: Icons.undo,
            onTap: (_strokes.isNotEmpty || _placedStickers.isNotEmpty || _placedTexts.isNotEmpty) ? _undo : null,
          ),
          _buildSmallButton(
            icon: Icons.redo,
            onTap: _redoStack.isNotEmpty ? _redo : null,
          ),
          _buildSmallButton(
            icon: Icons.save,
            onTap: _strokes.isNotEmpty ? _saveDrawing : null,
          ),
          _buildSmallButton(
            icon: Icons.delete_outline,
            onTap: (_strokes.isNotEmpty || _placedStickers.isNotEmpty || _placedTexts.isNotEmpty)
                ? () => setState(() {
                      _strokes.clear();
                      _redoStack.clear();
                      _placedStickers.clear();
                      _placedTexts.clear();
                      _scale = 1.0;
                      _offset = Offset.zero;
                    })
                : null,
          ),
          if (!widget.isBlankCanvas && widget.imagePaths.length > 1) ...[
            _buildSmallButton(
              icon: Icons.chevron_left,
              onTap: _currentPage > 0 ? () => _changePage(-1) : null,
            ),
            _buildSmallButton(
              icon: Icons.chevron_right,
              onTap: _currentPage < widget.imagePaths.length - 1
                  ? () => _changePage(1)
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallButton({required IconData icon, VoidCallback? onTap}) {
    final isActive = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? Colors.grey[400]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Icon(icon, size: 16, color: isActive ? Colors.black : Colors.grey[400]),
      ),
    );
  }

  // === ÇİZİM ALANI (ZOOM DESTEKLİ) ===

  Widget _buildDrawingArea() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onScaleStart: (details) {
              _previousScale = _scale;
              _previousOffset = _offset;
            },
            onScaleUpdate: (details) {
              if (details.pointerCount == 2) {
                // İki parmakla yakınlaştırma
                setState(() {
                  _isScaling = true;
                  _scale = (_previousScale * details.scale).clamp(0.5, 3.0);
                  _offset = _previousOffset + (details.focalPoint - details.localFocalPoint);
                });
              } else if (details.pointerCount == 1 && !_isDrawing) {
                // Tek parmakla çizim
                _startDrawing(details.focalPoint);
              }
            },
            onScaleEnd: (details) {
              if (_isScaling) {
                setState(() => _isScaling = false);
              }
              _endDrawing();
            },
            child: Stack(
              children: [
                // Arka plan
                if (widget.isBlankCanvas)
                  const Positioned.fill(child: ColoredBox(color: Colors.white)),
                if (!widget.isBlankCanvas)
                  Positioned.fill(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..scale(_scale, _scale)
                        ..translate(_offset.dx / _scale, _offset.dy / _scale),
                      child: IgnorePointer(child: _buildImageWithFallback()),
                    ),
                  ),

                // Çizim katmanı
                Positioned.fill(
                  child: CustomPaint(
                    painter: StrokePainter(
                      strokes: _strokes,
                      currentStroke: _currentStroke,
                      scale: _scale,
                      offset: _offset,
                    ),
                  ),
                ),

                // Sticker'lar
                ..._placedStickers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final sticker = entry.value;
                  return Positioned(
                    left: sticker.x * _scale + _offset.dx - 20,
                    top: sticker.y * _scale + _offset.dy - 20,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          sticker.x += details.delta.dx / _scale;
                          sticker.y += details.delta.dy / _scale;
                        });
                      },
                      onLongPress: () {
                        setState(() => _placedStickers.removeAt(index));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sticker silindi'),
                            backgroundColor: Colors.orange,
                            duration: Duration(milliseconds: 500),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(sticker.emoji, style: const TextStyle(fontSize: 36)),
                      ),
                    ),
                  );
                }),

                // Metinler
                ..._placedTexts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final text = entry.value;
                  return Positioned(
                    left: text.x * _scale + _offset.dx,
                    top: text.y * _scale + _offset.dy,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          text.x += details.delta.dx / _scale;
                          text.y += details.delta.dy / _scale;
                        });
                      },
                      onLongPress: () {
                        setState(() => _placedTexts.removeAt(index));
                      },
                      child: Text(
                        text.text,
                        style: TextStyle(
                          fontSize: text.fontSize * _scale,
                          color: text.color,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              blurRadius: 2,
                              color: Colors.white,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Silgi imleci
                if (_isErasing && _eraserPosition != null)
                  Positioned(
                    left: _eraserPosition!.dx * _scale + _offset.dx - _brushSize * 2,
                    top: _eraserPosition!.dy * _scale + _offset.dy - _brushSize * 2,
                    child: IgnorePointer(
                      child: Container(
                        width: _brushSize * 4,
                        height: _brushSize * 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 2),
                          color: Colors.red.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),

                // Kova aracı göstergesi
                if (_isFilling)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '🪣 Bölgeye dokunarak boyayın',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),

                // Parıltı efekti
                if (_showSparkle) ..._buildSparkles(),
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
    final file = File(path);
    return Image.file(
      file,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        final name = path.split(Platform.pathSeparator).last;
        final category = widget.categoryName.toLowerCase()
            .replaceAll(' ', '_')
            .replaceAll('ğ', 'g').replaceAll('ü', 'u')
            .replaceAll('ş', 's').replaceAll('ı', 'i')
            .replaceAll('ö', 'o').replaceAll('ç', 'c');
        return Image.asset(
          'assets/images/$category/$name',
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(name, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          },
        );
      },
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
              child: Text(
                ['✨', '⭐', '🌟', '💫'][index % 4],
                style: TextStyle(fontSize: 20 + random.nextDouble() * 20),
              ),
            );
          },
        ),
      );
    });
  }

  // === ALT PANEL ===

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSizeSlider(),
          _buildColorPalette(),
          _buildToolsRow(),
          if (_showSubTools) _buildSubToolsMenu(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildSizeSlider() {
    final maxSize = _isErasing ? 30.0 : (_selectedTool == 'fırça' ? 20.0 : 12.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.black,
                inactiveTrackColor: Colors.grey[300],
                thumbColor: Colors.black,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: _brushSize,
                min: 1.0,
                max: maxSize,
                onChanged: (v) => setState(() => _brushSize = v),
              ),
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Container(
                width: _brushSize * 2,
                height: _brushSize * 2,
                decoration: BoxDecoration(
                  color: _isErasing ? Colors.red : Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPalette() {
    final colors = [
      Colors.black, Colors.grey[800]!, Colors.grey[500]!, Colors.grey[300]!, Colors.white,
      Colors.red[900]!, Colors.red[600]!, Colors.red, Colors.red[300]!,
      Colors.pink[800]!, Colors.pink, Colors.pink[200]!,
      Colors.purple[800]!, Colors.purple, Colors.purple[200]!,
      Colors.indigo[800]!, Colors.indigo, Colors.indigo[200]!,
      Colors.blue[800]!, Colors.blue, Colors.blue[200]!,
      Colors.cyan[700]!, Colors.cyan, Colors.cyan[200]!,
      Colors.teal[700]!, Colors.teal, Colors.teal[200]!,
      Colors.green[800]!, Colors.green, Colors.green[200]!,
      Colors.lightGreen[600]!, Colors.lightGreen, Colors.lightGreen[200]!,
      Colors.yellow[800]!, Colors.yellow, Colors.yellow[200]!,
      Colors.orange[800]!, Colors.orange, Colors.orange[200]!,
      Colors.brown, Colors.brown[300]!,
    ];
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = _selectedColor == color && !_isErasing;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedColor = color;
              _isErasing = false;
              _isFilling = false;
              _isTextMode = false;
              _stickerMode = false;
              _selectedTool = 'kalem';
            }),
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey[300]!,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolButton(
            icon: Icons.edit,
            label: 'Kalem',
            isActive: _selectedTool == 'kalem' && !_isErasing && !_isFilling && !_isTextMode,
            onTap: () => setState(() {
              _selectedTool = 'kalem';
              _isErasing = false;
              _isFilling = false;
              _isTextMode = false;
              _stickerMode = false;
              _showSubTools = true;
            }),
          ),
          _buildToolButton(
            icon: Icons.brush,
            label: 'Fırça',
            isActive: _selectedTool == 'fırça' && !_isErasing,
            onTap: () => setState(() {
              _selectedTool = 'fırça';
              _isErasing = false;
              _isFilling = false;
              _isTextMode = false;
              _stickerMode = false;
              _showSubTools = true;
            }),
          ),
          _buildToolButton(
            icon: Icons.auto_fix_high,
            label: 'Silgi',
            isActive: _isErasing,
            onTap: () => setState(() {
              _isErasing = !_isErasing;
              _isFilling = false;
              _isTextMode = false;
              _stickerMode = false;
              _showSubTools = false;
            }),
          ),
          _buildToolButton(
            icon: Icons.format_color_fill,
            label: 'Kova',
            isActive: _isFilling,
            onTap: () => setState(() {
              _isFilling = !_isFilling;
              _isErasing = false;
              _isTextMode = false;
              _stickerMode = false;
              _showSubTools = false;
            }),
          ),
          _buildToolButton(
            icon: Icons.text_fields,
            label: 'Metin',
            isActive: _isTextMode,
            onTap: () => setState(() {
              _isTextMode = !_isTextMode;
              _isErasing = false;
              _isFilling = false;
              _stickerMode = false;
              _showSubTools = false;
            }),
          ),
          _buildToolButton(
            icon: Icons.emoji_emotions,
            label: 'Sticker',
            isActive: _stickerMode,
            onTap: () => setState(() {
              _stickerMode = !_stickerMode;
              _isErasing = false;
              _isFilling = false;
              _isTextMode = false;
              _showSubTools = false;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: isActive ? Colors.white : Colors.black),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubToolsMenu() {
    final subTools = _selectedTool == 'kalem'
        ? ['HB', '2B', '4B', '6B', '8B']
        : ['Normal', 'Sulu Boya', 'Pastel', 'Yağlı Boya', 'Kuru Boya'];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: subTools.length,
        itemBuilder: (context, index) {
          final tool = subTools[index];
          final isSelected = _selectedSubTool == tool;
          return GestureDetector(
            onTap: () => setState(() => _selectedSubTool = tool),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Center(
                child: Text(
                  tool,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// === ÇİZİCİ ===

class StrokePainter extends CustomPainter {
  final List<DrawStroke> strokes;
  final DrawStroke? currentStroke;
  final double scale;
  final Offset offset;

  StrokePainter({
    required this.strokes,
    this.currentStroke,
    this.scale = 1.0,
    this.offset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.isFill) {
        // Kova aracı - daire çiz
        if (stroke.points.isNotEmpty) {
          final paint = Paint()
            ..color = stroke.color.withOpacity(0.6)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(
            stroke.points.first,
            stroke.size * 5,
            paint,
          );
        }
        continue;
      }

      if (stroke.points.length < 2) continue;
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.size
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path()
        ..moveTo(
          stroke.points.first.dx * scale + offset.dx,
          stroke.points.first.dy * scale + offset.dy,
        );
      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(
          stroke.points[i].dx * scale + offset.dx,
          stroke.points[i].dy * scale + offset.dy,
        );
      }
      canvas.drawPath(path, paint);
    }

    if (currentStroke != null && currentStroke!.points.length >= 2) {
      final paint = Paint()
        ..color = currentStroke!.color
        ..strokeWidth = currentStroke!.size
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path()
        ..moveTo(
          currentStroke!.points.first.dx * scale + offset.dx,
          currentStroke!.points.first.dy * scale + offset.dy,
        );
      for (int i = 1; i < currentStroke!.points.length; i++) {
        path.lineTo(
          currentStroke!.points[i].dx * scale + offset.dx,
          currentStroke!.points[i].dy * scale + offset.dy,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
