import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/services/achievement_service.dart';
import '../../data/services/ad_service.dart';

/// Boyama sayfası
class ColoringPage extends StatefulWidget {
  final String categoryName;
  final String categoryIcon;
  final Color categoryColor;
  final int initialImageIndex;
  final List<String> imagePaths;
  final bool isCustomImage;
  final bool isBlankCanvas;

  const ColoringPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.initialImageIndex,
    required this.imagePaths,
    this.isCustomImage = false,
    this.isBlankCanvas = false,
  });

  @override
  State<ColoringPage> createState() => _ColoringPageState();
}

class _ColoringPageState extends State<ColoringPage> with SingleTickerProviderStateMixin {
  late int _currentPage;
  List<DrawStroke> _strokes = [];
  List<DrawStroke> _redoStack = [];
  Color _selectedColor = Colors.black;
  double _brushSize = 6.0;
  bool _isErasing = false;
  String _selectedTool = 'kalem';
  String _selectedSubTool = 'HB';
  bool _showSubTools = false;
  bool _isDrawing = false;
  DrawStroke? _currentStroke;

  // Sticker
  bool _stickerMode = false;
  String _selectedSticker = '⭐';
  final List<StickerItem> _placedStickers = [];

  // Filtre
  int _selectedFilter = 0;
  final List<String> _filterNames = ['Orijinal', 'Retro', 'Pastel', 'Neon'];

  bool _hasUnsavedChanges = false;
  bool _showSparkle = false;

  // Silgi imleci konumu
  Offset? _eraserPosition;
  late AnimationController _sparkleController;

  final List<Map<String, dynamic>> _pencilGrades = [
    {'grade': 'HB', 'desc': 'Standart', 'size': 2.0},
    {'grade': '2B', 'desc': 'Biraz kalın', 'size': 3.0},
    {'grade': '3B', 'desc': 'Orta', 'size': 4.0},
    {'grade': '4B', 'desc': 'Kalın', 'size': 5.0},
    {'grade': '6B', 'desc': 'Çok kalın', 'size': 7.0},
    {'grade': '8B', 'desc': 'En kalın', 'size': 9.0},
  ];

  final List<Map<String, dynamic>> _brushStyles = [
    {'style': 'Sulu', 'desc': 'Sulu boya', 'size': 12.0},
    {'style': 'Keçeli', 'desc': 'Keçeli', 'size': 5.0},
    {'style': 'Klasik', 'desc': 'Standart', 'size': 8.0},
    {'style': 'Kuru', 'desc': 'Kuru boya', 'size': 7.0},
  ];

  final List<String> _stickers = [
    '⭐', '🌟', '💫', '✨', '🌈', '🦄', '🐱', '🐶', '🐰', '🐻',
    '❤️', '💖', '💝', '🎉', '🎈', '🦋', '🌸', '🌺', '🌻', '🍀',
    '🍎', '🍕', '🍦', '🎂', '🎀', '👑', '💎', '🎵', '🎨', '🦋',
  ];

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialImageIndex;
    _sparkleController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _startAutoSave();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  // === ÇİZİM ===

  void _startDrawing(Offset point) {
    if (_stickerMode) {
      // Sticker modundaysa sticker koy
      setState(() {
        _placedStickers.add(StickerItem(
          emoji: _selectedSticker,
          x: point.dx,
          y: point.dy,
        ));
        _hasUnsavedChanges = true;
      });
      return;
    }
    setState(() {
      _isDrawing = true;
      _redoStack.clear();
      if (_isErasing) {
        // Silgi modunda beyaz çizgi oluşturma, sadece silme yap
        _eraserPosition = point;
        _eraseAtPoint(point);
      } else {
        _currentStroke = DrawStroke(
          color: _selectedColor,
          size: _brushSize,
          points: [point],
        );
      }
    });
  }  void _continueDrawing(Offset point) {
    if (_isDrawing) {
      setState(() {
        _hasUnsavedChanges = true;
        if (_isErasing) {
          // Silgi modunda sadece çizimleri sil, beyaz çizgi oluşturma
          _eraserPosition = point;
          _eraseAtPoint(point);
        } else if (_currentStroke != null) {
          _currentStroke!.points.add(point);
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
    final eraserRadius = _brushSize * 2;
    final newStrokes = <DrawStroke>[];
    for (final stroke in _strokes) {
      if (stroke.isEraser) continue;
      final segments = <DrawStroke>[];
      List<Offset> currentSegment = [];
      for (final point in stroke.points) {
        if ((point - eraserCenter).distance > eraserRadius) {
          currentSegment.add(point);
        } else {
          if (currentSegment.length >= 2) {
            segments.add(DrawStroke(color: stroke.color, size: stroke.size, points: List.from(currentSegment)));
          }
          currentSegment = [];
        }
      }
      if (currentSegment.length >= 2) {
        segments.add(DrawStroke(color: stroke.color, size: stroke.size, points: List.from(currentSegment)));
      }
      newStrokes.addAll(segments);
    }
    setState(() => _strokes = newStrokes);
  }

  // === GERİ AL / İLERİ AL ===

  void _undo() {
    if (_placedStickers.isNotEmpty) {
      setState(() {
        _undoStickers.add(_placedStickers.removeLast());
      });
      return;
    }
    if (_strokes.isNotEmpty) {
      setState(() => _redoStack.add(_strokes.removeLast()));
    }
  }

  final List<StickerItem> _undoStickers = [];

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
        _undoStickers.clear();
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
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSparkle = false);
    });
  }

  // === KAYDETME ===

  void _saveDrawing() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final savedDir = Directory('${directory.path}/saved_drawings');
      if (!await savedDir.exists()) await savedDir.create(recursive: true);
      final fileName = 'drawing_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${savedDir.path}/$fileName');
      final data = _strokes.map((s) => '${s.color.value},${s.size},${s.points.map((p) => '${p.dx},${p.dy}').join(';')}').join('\n');
      await file.writeAsString(data);
      await AchievementService.instance.saveDrawing(file.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('💾 Kaydedildi!'), backgroundColor: Colors.green, duration: Duration(milliseconds: 800)),
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
      final data = _strokes.map((s) => '${s.color.value},${s.size},${s.points.map((p) => '${p.dx},${p.dy}').join(';')}').join('\n');
      await file.writeAsString(data);
      await AchievementService.instance.saveDrawing(file.path);
    } catch (e) {}
  }

  // === ANA SAYFA ===

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.black, width: 2))),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, size: 20), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.categoryIcon} ${widget.categoryName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                Text('Sayfa ${_currentPage + 1} / ${widget.imagePaths.isEmpty ? 1 : widget.imagePaths.length}', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              ],
            ),
          ),
          _buildSmallButton(icon: Icons.undo, onTap: (_strokes.isNotEmpty || _placedStickers.isNotEmpty) ? _undo : null),
          _buildSmallButton(icon: Icons.redo, onTap: _redoStack.isNotEmpty ? _redo : null),
          _buildSmallButton(icon: Icons.save, onTap: _strokes.isNotEmpty ? _saveDrawing : null),
          _buildSmallButton(icon: Icons.delete_outline, onTap: (_strokes.isNotEmpty || _placedStickers.isNotEmpty) ? () => setState(() { _strokes.clear(); _redoStack.clear(); _placedStickers.clear(); _undoStickers.clear(); }) : null),
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
        width: 28, height: 28, margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(color: isActive ? Colors.white : Colors.grey[100], border: Border.all(color: isActive ? Colors.black : Colors.grey[300]!, width: 1)),
        child: Icon(icon, size: 14, color: isActive ? Colors.black : Colors.grey[400]),
      ),
    );
  }

  // === ÇİZİM ALANI ===

  Widget _buildDrawingArea() {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
        ),
        child: ClipRect(
          child: Stack(
            children: [
              // Arka plan resmi - KİLİTLİ
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

              // Sticker'lar - sürüklenebilir ve silinebilir
              ..._placedStickers.asMap().entries.map((entry) {
                final index = entry.key;
                final sticker = entry.value;
                return Positioned(
                  left: sticker.x - 20,
                  top: sticker.y - 20,
                  child: GestureDetector(
                    // Sürükleme
                    onPanUpdate: (details) {
                      setState(() {
                        sticker.x += details.delta.dx;
                        sticker.y += details.delta.dy;
                      });
                    },
                    // Uzun basarak silme
                    onLongPress: () {
                      setState(() {
                        _placedStickers.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sticker silindi'), backgroundColor: Colors.orange, duration: Duration(milliseconds: 500)),
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

              // Parıltı efekti
              if (_showSparkle) ..._buildSparkles(),
            ],
          ),
        ),
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

  // === BOTTOM PANEL ===

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black, width: 2))),
      child: _buildToolsPanel(),
    );
  }

  Widget _buildToolsPanel() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSizeSlider(),
          _buildColorPalette(),
          _buildToolsRow(),
          if (_stickerMode) _buildStickerBar(),
          if (_showSubTools) _buildSubToolsMenu(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildSizeSlider() {
    final maxSize = _isErasing ? 30.0 : (_selectedTool == 'fırça' ? 20.0 : 12.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(activeTrackColor: Colors.black, inactiveTrackColor: Colors.grey[300], thumbColor: Colors.black, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6)),
              child: Slider(value: _brushSize, min: 1.0, max: maxSize, onChanged: (v) => setState(() => _brushSize = v)),
            ),
          ),
          Container(width: 16, height: 16, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 1)),
            child: Center(child: Container(width: _brushSize * 2, height: _brushSize * 2, decoration: BoxDecoration(color: _isErasing ? Colors.red : Colors.black, shape: BoxShape.circle))),
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
      Colors.amber[700]!, Colors.amber, Colors.amber[200]!,
      Colors.orange[800]!, Colors.orange, Colors.orange[200]!,
      Colors.deepOrange[700]!, Colors.deepOrange, Colors.deepOrange[200]!,
      Colors.brown[800]!, Colors.brown, Colors.brown[200]!,
    ];
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = _selectedColor == color && !_isErasing;
          return GestureDetector(
            onTap: () => setState(() { _selectedColor = color; _isErasing = false; _selectedTool = 'kalem'; _stickerMode = false; }),
            child: Container(
              width: 26, height: 26, margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: isSelected ? Colors.black : Colors.grey, width: isSelected ? 2 : 1)),
              child: isSelected ? Icon(Icons.check, size: 10, color: color == Colors.white ? Colors.black : Colors.white) : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildToolButton(icon: Icons.edit, label: 'Kalem', subLabel: _selectedTool == 'kalem' ? _selectedSubTool : '', isActive: _selectedTool == 'kalem' && !_isErasing, onTap: () => setState(() { _selectedTool = 'kalem'; _isErasing = false; _stickerMode = false; _showSubTools = true; })),
          const SizedBox(width: 4),
          _buildToolButton(icon: Icons.brush, label: 'Fırça', subLabel: _selectedTool == 'fırça' ? _selectedSubTool : '', isActive: _selectedTool == 'fırça' && !_isErasing, onTap: () => setState(() { _selectedTool = 'fırça'; _isErasing = false; _stickerMode = false; _showSubTools = true; })),
          const SizedBox(width: 4),
          _buildToolButton(icon: Icons.auto_fix_high, label: 'Silgi', subLabel: '', isActive: _isErasing, onTap: () => setState(() { _isErasing = true; _stickerMode = false; _showSubTools = false; })),
          const SizedBox(width: 4),
          _buildToolButton(icon: Icons.emoji_emotions, label: 'Sticker', subLabel: '', isActive: _stickerMode, onTap: () => setState(() { _stickerMode = !_stickerMode; _isErasing = false; _showSubTools = false; })),
        ],
      ),
    );
  }

  Widget _buildToolButton({required IconData icon, required String label, required String subLabel, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: isActive ? Colors.black : Colors.white, border: Border.all(color: Colors.black, width: 1)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: isActive ? Colors.white : Colors.black),
            const SizedBox(width: 2),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: isActive ? Colors.white : Colors.black)),
                if (subLabel.isNotEmpty) Text(subLabel, style: TextStyle(fontSize: 7, color: isActive ? Colors.grey[300] : Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickerBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: Colors.yellow[50], border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, top: 2),
            child: Text('📍 Ekrana dokunarak sticker koy, sürükleerek taşı, uzun basarak sil', style: TextStyle(fontSize: 8, color: Colors.grey)),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _stickers.length,
              itemBuilder: (context, index) {
                final sticker = _stickers[index];
                final isSelected = _selectedSticker == sticker;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSticker = sticker),
                  child: Container(
                    width: 36, height: 36, margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.yellow[200] : Colors.white,
                      border: Border.all(color: isSelected ? Colors.black : Colors.grey, width: isSelected ? 2 : 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(child: Text(sticker, style: const TextStyle(fontSize: 20))),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubToolsMenu() {
    if (_selectedTool == 'kalem') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.grey[100], border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: _pencilGrades.map((p) {
          final grade = p['grade'] as String;
          final isSelected = _selectedSubTool == grade;
          return GestureDetector(
            onTap: () => setState(() { _selectedSubTool = grade; _brushSize = p['size'] as double; _showSubTools = false; }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.white, border: Border.all(color: Colors.black, width: 1)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(grade, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : Colors.black)),
                Text(p['desc'] as String, style: TextStyle(fontSize: 6, color: isSelected ? Colors.grey[300] : Colors.grey[600])),
              ]),
            ),
          );
        }).toList()),
      );
    } else if (_selectedTool == 'fırça') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.grey[100], border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: _brushStyles.map((b) {
          final style = b['style'] as String;
          final isSelected = _selectedSubTool == style;
          return GestureDetector(
            onTap: () => setState(() { _selectedSubTool = style; _brushSize = b['size'] as double; _showSubTools = false; }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.white, border: Border.all(color: Colors.black, width: 1)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(style, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : Colors.black)),
                Text(b['desc'] as String, style: TextStyle(fontSize: 6, color: isSelected ? Colors.grey[300] : Colors.grey[600])),
              ]),
            ),
          );
        }).toList()),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildImageWithFallback() {
    if (_currentPage >= widget.imagePaths.length) {
      return const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey));
    }
    final currentPath = widget.imagePaths[_currentPage];
    if (widget.isCustomImage) {
      return Image.file(File(currentPath), fit: BoxFit.contain, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey)));
    }
    if (widget.isBlankCanvas || widget.imagePaths.isEmpty) return const SizedBox.shrink();
    final folderName = _getFolderName();
    final regex = RegExp(r'_(\d+)\.png$');
    final match = regex.firstMatch(currentPath);
    if (match != null) {
      final imageIndex = int.parse(match.group(1)!);
      return Image.asset(currentPath, fit: BoxFit.contain, errorBuilder: (c, e, s) {
        return Image.asset('assets/images/$folderName/${folderName}_${imageIndex.toString().padLeft(3, '0')}.png', fit: BoxFit.contain, errorBuilder: (c2, e2, s2) {
          return Image.asset('assets/images/$folderName/${folderName}_$imageIndex.png', fit: BoxFit.contain, errorBuilder: (c3, e3, s3) => const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey)));
        });
      });
    }
    return Image.asset(currentPath, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey)));
  }

  String _getFolderName() {
    const folderMap = {
      'Çiftlik': 'ciftlik', 'Deniz Altı': 'deniz_alti', 'Dinozor': 'dinozor',
      'Doğa Gökyüzü': 'doga_gokyuzu', 'Emoji': 'emoji', 'Erkek Karakter': 'erkek_karakter',
      'Harfler': 'harfler', 'İnşaat': 'insaat', 'Kahramanlar': 'kahraman', 'Kız Karakter': 'kiz_karakter',
      'Meslekler': 'meslekler', 'Meyveler': 'meyveler', 'Okyanus': 'okyanus', 'Oyuncaklar': 'oyuncak',
      'Robotlar': 'robot', 'Sayılar': 'sayilar', 'Sevimli Dostlar': 'sevimli_dostlar', 'Tamamlayıcı': 'tamamlayici',
      'Taşıtlar': 'tasitlar', 'Uzay': 'uzay', 'Vahşi Dostlar': 'vahsi_dostlar', 'Yiyecekler': 'yiyecekler',
    };
    return folderMap[widget.categoryName] ?? 'ciftlik';
  }
}

// === MODELLER ===

class StickerItem {
  String emoji;
  double x;
  double y;
  StickerItem({required this.emoji, required this.x, required this.y});
}

class DrawStroke {
  final Color color;
  final double size;
  final List<Offset> points;
  final bool isEraser;
  DrawStroke({required this.color, required this.size, required this.points, this.isEraser = false});
}

class StrokePainter extends CustomPainter {
  final List<DrawStroke> strokes;
  final DrawStroke? currentStroke;
  StrokePainter({required this.strokes, this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.length < 2) continue;
      final paint = Paint()..color = stroke.color..strokeWidth = stroke.size..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
      final path = Path()..moveTo(stroke.points[0].dx, stroke.points[0].dy);
      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
    if (currentStroke != null && currentStroke!.points.length >= 2) {
      final paint = Paint()..color = currentStroke!.color..strokeWidth = currentStroke!.size..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
      final path = Path()..moveTo(currentStroke!.points[0].dx, currentStroke!.points[0].dy);
      for (int i = 1; i < currentStroke!.points.length; i++) {
        path.lineTo(currentStroke!.points[i].dx, currentStroke!.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
