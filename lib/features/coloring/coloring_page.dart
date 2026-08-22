import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Boyama sayfası - Silgi sadece dokunduğu yeri siler
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

class _ColoringPageState extends State<ColoringPage> {
  late int _currentPage;

  // Çizim durumları
  List<DrawStroke> _strokes = [];
  Color _selectedColor = Colors.black;
  double _brushSize = 6.0;
  bool _isErasing = false;

  // Seçili araç
  String _selectedTool = 'kalem';
  String _selectedSubTool = 'HB';
  bool _showSubTools = false;

  // Çizim yapılıyor mu?
  bool _isDrawing = false;
  DrawStroke? _currentStroke;

  // Kalem varyasyonları
  final List<Map<String, dynamic>> _pencilGrades = [
    {'grade': 'HB', 'desc': 'Standart', 'size': 2.0},
    {'grade': '2B', 'desc': 'Biraz kalın', 'size': 3.0},
    {'grade': '3B', 'desc': 'Orta', 'size': 4.0},
    {'grade': '4B', 'desc': 'Kalın', 'size': 5.0},
    {'grade': '6B', 'desc': 'Çok kalın', 'size': 7.0},
    {'grade': '8B', 'desc': 'En kalın', 'size': 9.0},
  ];

  // Fırça varyasyonları
  final List<Map<String, dynamic>> _brushStyles = [
    {'style': 'Sulu', 'desc': 'Sulu boya', 'size': 12.0},
    {'style': 'Keçeli', 'desc': 'Keçeli', 'size': 5.0},
    {'style': 'Klasik', 'desc': 'Standart', 'size': 8.0},
    {'style': 'Kuru', 'desc': 'Kuru boya', 'size': 7.0},
  ];

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialImageIndex;
  }

  void _startDrawing(Offset point) {
    setState(() {
      _isDrawing = true;
      _currentStroke = DrawStroke(
        color: _isErasing ? Colors.red.withOpacity(0.3) : _selectedColor,
        size: _isErasing ? _brushSize : _brushSize,
        points: [point],
        isEraser: _isErasing,
      );
    });
  }

  void _continueDrawing(Offset point) {
    if (_isDrawing && _currentStroke != null) {
      setState(() {
        _currentStroke!.points.add(point);
      });

      // Silgi modunda - temas ettiği çizimleri böl ve sil
      if (_isErasing) {
        _eraseAtPoint(point);
      }
    }
  }

  void _endDrawing() {
    if (_isDrawing && _currentStroke != null && !_isErasing) {
      if (_currentStroke!.points.length > 1) {
        setState(() {
          _strokes.add(_currentStroke!);
        });
      }
    }
    setState(() {
      _currentStroke = null;
      _isDrawing = false;
    });
  }

  /// Belirli bir noktadaki çizimleri sil (sadece dokunulan kısım)
  void _eraseAtPoint(Offset eraserCenter) {
    final eraserRadius = _brushSize * 2;
    final newStrokes = <DrawStroke>[];

    for (final stroke in _strokes) {
      // Çizgiyi segmentlere böl
      final segments = <DrawStroke>[];
      List<Offset> currentSegment = [];

      for (int i = 0; i < stroke.points.length; i++) {
        final point = stroke.points[i];
        final distance = (point - eraserCenter).distance;
        final isNearEraser = distance <= eraserRadius;

        if (!isNearEraser) {
          // Nokta silgiden uzak - segmente ekle
          currentSegment.add(point);
        } else {
          // Nokta silgiye yakın - mevcut segmenti kaydet
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

      // Son segmenti kaydet
      if (currentSegment.length >= 2) {
        segments.add(DrawStroke(
          color: stroke.color,
          size: stroke.size,
          points: List.from(currentSegment),
        ));
      }

      newStrokes.addAll(segments);
    }

    setState(() {
      _strokes = newStrokes;
    });
  }

  void _clearDrawing() {
    setState(() {
      _strokes.clear();
      _currentStroke = null;
    });
  }

  Future<void> _saveDrawing() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final savedDir = Directory('${directory.path}/saved_drawings');
      
      if (!await savedDir.exists()) {
        await savedDir.create(recursive: true);
      }
      
      final fileName = 'drawing_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${savedDir.path}/$fileName');
      
      // Çizim verilerini kaydet
      final data = _strokes.map((s) => '${s.color.value},${s.size},${s.points.map((p) => '${p.dx},${p.dy}').join(';')}').join('\n');
      await file.writeAsString(data);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Çizim kaydedildi! 💾'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kaydetme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _undoLastStroke() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.removeLast();
      });
    }
  }

  void _changePage(int delta) {
    final newIndex = _currentPage + delta;
    if (newIndex >= 0 && newIndex < widget.imagePaths.length) {
      setState(() {
        _currentPage = newIndex;
        _strokes.clear();
        _currentStroke = null;
      });
    }
  }

  void _selectTool(String tool) {
    setState(() {
      if (tool == 'silgi') {
        _isErasing = true;
        _showSubTools = false;
      } else {
        _isErasing = false;
        _selectedTool = tool;
        _showSubTools = true;
        if (tool == 'kalem') {
          _selectedSubTool = 'HB';
          _brushSize = 2.0;
        } else {
          _selectedSubTool = 'Sulu';
          _brushSize = 12.0;
        }
      }
    });
  }

  void _selectSubTool(String subTool) {
    setState(() {
      _selectedSubTool = subTool;
      _showSubTools = false;

      if (_selectedTool == 'kalem') {
        final pencil = _pencilGrades.firstWhere((p) => p['grade'] == subTool);
        _brushSize = pencil['size'] as double;
      } else {
        final brush = _brushStyles.firstWhere((b) => b['style'] == subTool);
        _brushSize = brush['size'] as double;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Tablet/Desktop için geniş düzen
            final isWideScreen = constraints.maxWidth > 600;

            if (isWideScreen) {
              return _buildWideLayout();
            } else {
              return _buildNarrowLayout();
            }
          },
        ),
      ),
    );
  }

  /// Geniş ekran düzeni (tablet/desktop)
  Widget _buildWideLayout() {
    return Row(
      children: [
        // Sol taraf: Boyama alanı
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(child: _buildDrawingArea()),
            ],
          ),
        ),
        // Sağ taraf: Araçlar
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(color: Colors.black, width: 2)),
          ),
          child: _buildToolsPanel(),
        ),
      ],
    );
  }

  /// Dar ekran düzeni (telefon)
  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(child: _buildDrawingArea()),
        _buildBottomPanel(),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
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
                  'Sayfa ${_currentPage + 1} / ${widget.imagePaths.length}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          _buildSmallButton(icon: Icons.undo, onTap: _strokes.isNotEmpty ? _undoLastStroke : null),
          const SizedBox(width: 6),
          _buildSmallButton(icon: Icons.delete_outline, onTap: _strokes.isNotEmpty ? _clearDrawing : null),
          const SizedBox(width: 6),
          _buildSmallButton(icon: Icons.save, onTap: _strokes.isNotEmpty ? _saveDrawing : null),
          const SizedBox(width: 6),
          if (!widget.isBlankCanvas) ...[
            _buildSmallButton(
              icon: Icons.chevron_left,
              onTap: _currentPage > 0 ? () => _changePage(-1) : null,
            ),
            const SizedBox(width: 4),
            _buildSmallButton(
              icon: Icons.chevron_right,
              onTap: _currentPage < widget.imagePaths.length - 1 ? () => _changePage(1) : null,
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
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.grey[100],
          border: Border.all(color: isActive ? Colors.black : Colors.grey[300]!, width: 2),
        ),
        child: Icon(icon, size: 16, color: isActive ? Colors.black : Colors.grey[400]),
      ),
    );
  }

  Widget _buildDrawingArea() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
        ),
        child: ClipRect(
          child: GestureDetector(
            onPanStart: (details) => _startDrawing(details.localPosition),
            onPanUpdate: (details) => _continueDrawing(details.localPosition),
            onPanEnd: (details) => _endDrawing(),
            child: Stack(
              children: [
                // Boş tuval ise sadece beyaz arka plan
                if (widget.isBlankCanvas)
                  const Positioned.fill(child: ColoredBox(color: Colors.white)),
                
                // Resim varsa arka plan resmi
                if (!widget.isBlankCanvas)
                  Positioned.fill(
                    child: _buildImageWithFallback(),
                  ),

                // Sadece kullanıcının çizdikleri - ClipRect ile sınırlı
                ClipRect(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: StrokePainter(strokes: _strokes, currentStroke: _currentStroke),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black, width: 2)),
      ),
      child: _buildToolsPanel(),
    );
  }

  Widget _buildToolsPanel() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Boyut slider'ı
          _buildSizeSlider(),

          // Renk paleti
          _buildColorPalette(),

          // Araçlar
          _buildToolsRow(),

          // Alt araç menüsü
          if (_showSubTools) _buildSubToolsMenu(),

          const SizedBox(height: 8),
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
          // Küçük daire
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),

          // Slider
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.black,
                inactiveTrackColor: Colors.grey[300],
                thumbColor: Colors.black,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: _brushSize,
                min: 1.0,
                max: maxSize,
                onChanged: (value) {
                  setState(() {
                    _brushSize = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Büyük daire
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
          ),

          const SizedBox(width: 8),

          // Boyut göstergesi
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2),
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
      Colors.amber[700]!, Colors.amber, Colors.amber[200]!,
      Colors.orange[800]!, Colors.orange, Colors.orange[200]!,
      Colors.deepOrange[700]!, Colors.deepOrange, Colors.deepOrange[200]!,
      Colors.brown[800]!, Colors.brown, Colors.brown[200]!,
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = _selectedColor == color && !_isErasing;
          final isBlack = color == Colors.black;
          final isWhite = color == Colors.white;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColor = color;
                _isErasing = false;
                _selectedTool = 'kalem';
              });
            },
            child: Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : (isBlack || isWhite ? Colors.grey : color),
                  width: isSelected ? 3 : 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 12, color: isWhite ? Colors.black : Colors.white)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildToolButton(
            icon: Icons.edit,
            label: 'Kalem',
            subLabel: _selectedTool == 'kalem' ? _selectedSubTool : '',
            isActive: _selectedTool == 'kalem' && !_isErasing,
            onTap: () => _selectTool('kalem'),
          ),
          const SizedBox(width: 8),
          _buildToolButton(
            icon: Icons.brush,
            label: 'Fırça',
            subLabel: _selectedTool == 'fırça' ? _selectedSubTool : '',
            isActive: _selectedTool == 'fırça' && !_isErasing,
            onTap: () => _selectTool('fırça'),
          ),
          const SizedBox(width: 8),
          _buildToolButton(
            icon: Icons.auto_fix_high,
            label: 'Silgi',
            subLabel: _isErasing ? '${_brushSize.toInt()}px' : '',
            isActive: _isErasing,
            onTap: () => _selectTool('silgi'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required String subLabel,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.white : Colors.black),
            const SizedBox(width: 6),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : Colors.black,
                  ),
                ),
                if (subLabel.isNotEmpty)
                  Text(
                    subLabel,
                    style: TextStyle(
                      fontSize: 9,
                      color: isActive ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubToolsMenu() {
    if (_selectedTool == 'kalem') {
      return _buildPencilMenu();
    } else if (_selectedTool == 'fırça') {
      return _buildBrushMenu();
    }
    return const SizedBox.shrink();
  }

  Widget _buildPencilMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✏️ Kalem Kalınlığı', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _pencilGrades.map((p) {
              final grade = p['grade'] as String;
              final isSelected = _selectedSubTool == grade;

              return GestureDetector(
                onTap: () => _selectSubTool(grade),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        grade,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        p['desc'] as String,
                        style: TextStyle(
                          fontSize: 8,
                          color: isSelected ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBrushMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🖌️ Fırça Türü', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _brushStyles.map((b) {
              final style = b['style'] as String;
              final isSelected = _selectedSubTool == style;

              return GestureDetector(
                onTap: () => _selectSubTool(style),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        style,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        b['desc'] as String,
                        style: TextStyle(
                          fontSize: 8,
                          color: isSelected ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWithFallback() {
    // Index kontrolü
    if (_currentPage >= widget.imagePaths.length) {
      return const Center(
        child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
      );
    }
    
    final currentPath = widget.imagePaths[_currentPage];

    // Özel resim ise (dosya yolu - .png veya .jpg)
    if (widget.isCustomImage) {
      return Image.file(
        File(currentPath),
        fit: BoxFit.contain,
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

    // Boş tuval
    if (widget.isBlankCanvas || widget.imagePaths.isEmpty) {
      return const SizedBox.shrink();
    }

    // Path'ten index numarasını çıkar
    final folderName = _getFolderName();
    final regex = RegExp(r'_(\d+)\.png$');
    final match = regex.firstMatch(currentPath);
    
    if (match != null) {
      final imageIndex = int.parse(match.group(1)!);
      
      // Mevcut yolu dene
      return Image.asset(
        currentPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Bulunamadıysa 3 haneli formatı dene
          String path3h = 'assets/images/$folderName/${folderName}_${imageIndex.toString().padLeft(3, '0')}.png';
          return Image.asset(
            path3h,
            fit: BoxFit.contain,
            errorBuilder: (context, error2, stackTrace2) {
              // O da bulunamadıysa 1-2 haneli formatı dene
              String path12h = 'assets/images/$folderName/${folderName}_$imageIndex.png';
              return Image.asset(
                path12h,
                fit: BoxFit.contain,
                errorBuilder: (context, error3, stackTrace3) {
                  return const Center(
                    child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                  );
                },
              );
            },
          );
        },
      );
    }
    
    // Regex eşleşmezse doğrudan yolu dene
    return Image.asset(
      currentPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
        );
      },
    );
  }

  String _getFolderName() {
    const folderMap = {
      'Çiftlik': 'ciftlik', 'Deniz Altı': 'deniz_alti', 'Dinozor': 'dinozor',
      'Doğa': 'doga', 'Doğa Gökyüzü': 'doga_gokyuzu', 'Emoji': 'emoji',
      'Erkek Karakter': 'erkek_karakter', 'Harfler': 'harfler', 'İnşaat': 'insaat',
      'Kahramanlar': 'kahraman', 'Kız Karakter': 'kiz_karakter', 'Meslekler': 'meslekler',
      'Meyveler': 'meyveler', 'Okyanus': 'okyanus', 'Oyuncaklar': 'oyuncak',
      'Robotlar': 'robot', 'Sayılar': 'sayilar', 'Sevimli Dostlar': 'sevimli_dostlar',
      'Tamamlayıcı': 'tamamlayici', 'Taşıtlar': 'tasitlar', 'Uzay': 'uzay',
      'Vahşi Dostlar': 'vahsi_dostlar', 'Yiyecekler': 'yiyecekler',
    };
    return folderMap[widget.categoryName] ?? 'ciftlik';
  }
}

/// Çizim çizgisi
class DrawStroke {
  final Color color;
  final double size;
  final List<Offset> points;
  final bool isEraser;

  DrawStroke({
    required this.color,
    required this.size,
    required this.points,
    this.isEraser = false,
  });
}

/// Çizim painter'ı
class StrokePainter extends CustomPainter {
  final List<DrawStroke> strokes;
  final DrawStroke? currentStroke;

  StrokePainter({required this.strokes, this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    if (currentStroke != null && !currentStroke!.isEraser) {
      _drawStroke(canvas, currentStroke!);
    }
  }

  void _drawStroke(Canvas canvas, DrawStroke stroke) {
    if (stroke.points.length < 2) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.size
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(stroke.points[0].dx, stroke.points[0].dy);

    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
