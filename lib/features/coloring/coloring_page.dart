import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/haptic_helper.dart';
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

  // Zoom
  final TransformationController _transformationController = TransformationController();

  // Filtre
  int _selectedFilter = 0;

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
    _transformationController.dispose();
    super.dispose();
  }

  // === ÇİZİM ===

  void _startDrawing(Offset localPoint) {
    if (_stickerMode) {
      setState(() {
        _placedStickers.add(StickerItem(
          emoji: _selectedSticker,
          x: localPoint.dx,
          y: localPoint.dy,
        ));
        _hasUnsavedChanges = true;
        _stickerMode = false;
        _showSubTools = false;
      });
      HapticHelper.lightImpact();
      return;
    }

    if (_isTextMode) {
      _showTextInputDialog(localPoint);
      return;
    }

    setState(() {
      _isDrawing = true;
      _redoStack.clear();

      if (_isFilling) {
        _strokes.add(DrawStroke(
          color: _selectedColor,
          size: _brushSize,
          points: [localPoint],
          isFill: true,
        ));
        _hasUnsavedChanges = true;
        _isFilling = false;
        _isDrawing = false;
        HapticHelper.mediumImpact();
      } else if (_isErasing) {
        _eraserPosition = localPoint;
        _eraseAtPoint(localPoint);
      } else {
        _currentStroke = DrawStroke(
          color: _selectedColor,
          size: _selectedTool == 'fırça' ? _brushSize * 1.5 : _brushSize,
          points: [localPoint],
        );
      }
    });
  }

  void _continueDrawing(Offset localPoint) {
    if (!_isDrawing) return;
    setState(() {
      _hasUnsavedChanges = true;
      if (_isErasing) {
        _eraserPosition = localPoint;
        _eraseAtPoint(localPoint);
      } else if (_currentStroke != null) {
        _currentStroke!.points.add(localPoint);
      }
    });
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
      setState(() => _placedStickers.removeLast());
      HapticHelper.lightImpact();
      return;
    }
    if (_placedTexts.isNotEmpty) {
      setState(() => _placedTexts.removeLast());
      HapticHelper.lightImpact();
      return;
    }
    if (_strokes.isNotEmpty) {
      setState(() => _redoStack.add(_strokes.removeLast()));
      HapticHelper.lightImpact();
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      setState(() => _strokes.add(_redoStack.removeLast()));
      HapticHelper.lightImpact();
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
        _transformationController.value = Matrix4.identity();
      });
      HapticHelper.mediumImpact();
    }
  }

  // === TAMAMLAMA ===

  Future<void> _completeDrawing() async {
    if (_strokes.isEmpty && _placedStickers.isEmpty) return;
    final result = await AchievementService.instance.completeDrawing();
    setState(() => _showSparkle = true);
    _sparkleController.forward(from: 0);
    HapticHelper.heavyImpact();
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
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isTextMode = false);
            },
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                setState(() {
                  _placedTexts.add(TextItem(
                    text: textController.text,
                    x: position.dx,
                    y: position.dy,
                    color: _selectedColor,
                    fontSize: 24,
                  ));
                  _isTextMode = false;
                  _selectedTool = 'kalem';
                  _showSubTools = false;
                });
                HapticHelper.lightImpact();
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
      HapticHelper.mediumImpact();
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
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
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
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Sayfa ${_currentPage + 1} / ${widget.imagePaths.isEmpty ? 1 : widget.imagePaths.length}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          _buildSmallButton(icon: Icons.undo, onTap: (_strokes.isNotEmpty || _placedStickers.isNotEmpty || _placedTexts.isNotEmpty) ? _undo : null),
          _buildSmallButton(icon: Icons.redo, onTap: _redoStack.isNotEmpty ? _redo : null),
          _buildSmallButton(icon: Icons.save, onTap: _strokes.isNotEmpty ? _saveDrawing : null),
          _buildSmallButton(
            icon: Icons.delete_outline,
            onTap: (_strokes.isNotEmpty || _placedStickers.isNotEmpty || _placedTexts.isNotEmpty)
                ? () {
                    HapticHelper.heavyImpact();
                    setState(() {
                      _strokes.clear();
                      _redoStack.clear();
                      _placedStickers.clear();
                      _placedTexts.clear();
                      _transformationController.value = Matrix4.identity();
                    });
                  }
                : null,
          ),
          if (!widget.isBlankCanvas && widget.imagePaths.length > 1) ...[
            _buildSmallButton(icon: Icons.chevron_left, onTap: _currentPage > 0 ? () => _changePage(-1) : null),
            _buildSmallButton(icon: Icons.chevron_right, onTap: _currentPage < widget.imagePaths.length - 1 ? () => _changePage(1) : null),
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
        width: 32, height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isActive ? Colors.grey[400]! : Colors.grey[200]!, width: 1),
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
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Zoom katılmanı
              InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 3.0,
                boundaryMargin: const EdgeInsets.all(100),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Stack(
                    children: [
                      // Arka plan
                      if (widget.isBlankCanvas)
                        const Positioned.fill(child: ColoredBox(color: Colors.white)),
                      if (!widget.isBlankCanvas)
                        Positioned.fill(child: IgnorePointer(child: _buildImageWithFallback())),

                      // Çizim katmanı
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onPanStart: (details) => _startDrawing(details.localPosition),
                          onPanUpdate: (details) => _continueDrawing(details.localPosition),
                          onPanEnd: (details) => _endDrawing(),
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: StrokePainter(strokes: _strokes, currentStroke: _currentStroke),
                          ),
                        ),
                      ),

                      // Sticker'lar
                      ..._placedStickers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final sticker = entry.value;
                        return Positioned(
                          left: sticker.x - 24,
                          top: sticker.y - 24,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    sticker.x += details.delta.dx;
                                    sticker.y += details.delta.dy;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: Text(sticker.emoji, style: const TextStyle(fontSize: 40)),
                                ),
                              ),
                              // Çarpı butonu
                              Positioned(
                                right: -8,
                                top: -8,
                                child: GestureDetector(
                                  onTap: () {
                                    HapticHelper.lightImpact();
                                    setState(() => _placedStickers.removeAt(index));
                                  },
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.close, size: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // Metinler
                      ..._placedTexts.asMap().entries.map((entry) {
                        final index = entry.key;
                        final text = entry.value;
                        return Positioned(
                          left: text.x,
                          top: text.y,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    text.x += details.delta.dx;
                                    text.y += details.delta.dy;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    text.text,
                                    style: TextStyle(
                                      fontSize: text.fontSize,
                                      color: text.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              // Çarpı butonu
                              Positioned(
                                right: -8,
                                top: -8,
                                child: GestureDetector(
                                  onTap: () {
                                    HapticHelper.lightImpact();
                                    setState(() => _placedTexts.removeAt(index));
                                  },
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.close, size: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // Silgi imleci
                      if (_isErasing && _eraserPosition != null)
                        Positioned(
                          left: _eraserPosition!.dx - _brushSize * 2,
                          top: _eraserPosition!.dy - _brushSize * 2,
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
                    ],
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2)),
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
          Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.black,
                inactiveTrackColor: Colors.grey[300],
                thumbColor: Colors.black,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(value: _brushSize, min: 1.0, max: maxSize, onChanged: (v) => setState(() => _brushSize = v)),
            ),
          ),
          Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Container(
                width: _brushSize * 2, height: _brushSize * 2,
                decoration: BoxDecoration(
                  color: _isErasing ? Colors.red : _selectedColor,
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
    // Daha canlı renkler
    final colors = [
      Colors.black, Colors.grey[800]!, Colors.grey[500]!, Colors.grey[300]!, Colors.white,
      const Color(0xFFE91E63), const Color(0xFFF44336), const Color(0xFFFF5722), const Color(0xFFFF9800), const Color(0xFFFFC107),
      const Color(0xFF4CAF50), const Color(0xFF8BC34A), const Color(0xFF009688), const Color(0xFF00BCD4), const Color(0xFF03A9F4),
      const Color(0xFF2196F3), const Color(0xFF3F51B5), const Color(0xFF673AB7), const Color(0xFF9C27B0), const Color(0xFFE91E63),
      const Color(0xFF795548), const Color(0xFF607D8B), const Color(0xFF8D6E63), const Color(0xFFD7CCC8), const Color(0xFFF8BBD0),
    ];
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = _selectedColor == color && !_isErasing;
          return GestureDetector(
            onTap: () {
              HapticHelper.selectionClick();
              setState(() {
                _selectedColor = color;
                _isErasing = false;
                _isFilling = false;
                _isTextMode = false;
                _stickerMode = false;
                _selectedTool = 'kalem';
                _showSubTools = false;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 40, height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey[300]!,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: const Offset(0, 1))],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolButton(
            icon: Icons.edit,
            label: 'Kalem',
            isActive: _selectedTool == 'kalem' && !_isErasing && !_isFilling && !_isTextMode && !_stickerMode,
            onTap: () {
              HapticHelper.lightImpact();
              setState(() {
                _selectedTool = 'kalem';
                _isErasing = false;
                _isFilling = false;
                _isTextMode = false;
                _stickerMode = false;
                _showSubTools = !_showSubTools || _selectedTool != 'kalem';
              });
            },
          ),
          _buildToolButton(
            icon: Icons.brush,
            label: 'Fırça',
            isActive: _selectedTool == 'fırça' && !_isErasing,
            onTap: () {
              HapticHelper.lightImpact();
              setState(() {
                _selectedTool = 'fırça';
                _isErasing = false;
                _isFilling = false;
                _isTextMode = false;
                _stickerMode = false;
                _showSubTools = !_showSubTools || _selectedTool != 'fırça';
              });
            },
          ),
          _buildToolButton(
            icon: Icons.auto_fix_high,
            label: 'Silgi',
            isActive: _isErasing,
            onTap: () {
              HapticHelper.lightImpact();
              setState(() {
                _isErasing = !_isErasing;
                _isFilling = false;
                _isTextMode = false;
                _stickerMode = false;
                _showSubTools = false;
              });
            },
          ),
          _buildToolButton(
            icon: Icons.format_color_fill,
            label: 'Kova',
            isActive: _isFilling,
            onTap: () {
              HapticHelper.lightImpact();
              setState(() {
                _isFilling = !_isFilling;
                _isErasing = false;
                _isTextMode = false;
                _stickerMode = false;
                _showSubTools = false;
              });
            },
          ),
          _buildToolButton(
            icon: Icons.text_fields,
            label: 'Metin',
            isActive: _isTextMode,
            onTap: () {
              HapticHelper.lightImpact();
              setState(() {
                _isTextMode = !_isTextMode;
                _isErasing = false;
                _isFilling = false;
                _stickerMode = false;
                _showSubTools = false;
              });
            },
          ),
          _buildToolButton(
            icon: Icons.emoji_emotions,
            label: 'Sticker',
            isActive: _stickerMode,
            onTap: () {
              HapticHelper.lightImpact();
              setState(() {
                _stickerMode = !_stickerMode;
                _isErasing = false;
                _isFilling = false;
                _isTextMode = false;
                _showSubTools = false;
              });
            },
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(2, 2))]
              : [],
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
            onTap: () {
              HapticHelper.lightImpact();
              setState(() {
                _selectedSubTool = tool;
                _showSubTools = false; // Seçim sonrası menüyü kapat
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Center(
                child: Text(
                  tool,
                  style: TextStyle(
                    fontSize: 13,
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

  StrokePainter({required this.strokes, this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.isFill) {
        // Kova aracı - daire çiz
        if (stroke.points.isNotEmpty) {
          final paint = Paint()
            ..color = stroke.color.withOpacity(0.6)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(stroke.points.first, stroke.size * 5, paint);
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
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
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
        ..moveTo(currentStroke!.points.first.dx, currentStroke!.points.first.dy);
      for (int i = 1; i < currentStroke!.points.length; i++) {
        path.lineTo(currentStroke!.points[i].dx, currentStroke!.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
