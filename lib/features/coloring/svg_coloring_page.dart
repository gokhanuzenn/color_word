import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/utils/haptic_helper.dart';
import '../../data/services/score_service.dart';
import '../../data/services/achievement_service.dart';

/// SVG tabanlı boyama sayfası
/// Her alan ayrı ayrı boyanabilir
class SvgColoringPage extends StatefulWidget {
  final String categoryName;
  final String categoryIcon;
  final Color categoryColor;
  final int initialImageIndex;
  final List<String> svgPaths;

  const SvgColoringPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.initialImageIndex,
    required this.svgPaths,
  });

  @override
  State<SvgColoringPage> createState() => _SvgColoringPageState();
}

class _SvgColoringPageState extends State<SvgColoringPage>
    with SingleTickerProviderStateMixin {
  late int _currentPage;
  Color _selectedColor = Colors.black;
  double _brushSize = 6.0;
  double _opacity = 1.0;
  
  // Her alanın rengi (alan ID'si → renk)
  final Map<String, Color> _areaColors = {};
  
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
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  void _colorArea(String areaId) {
    setState(() {
      _areaColors[areaId] = _selectedColor.withOpacity(_opacity);
      _hasUnsavedChanges = true;
    });
    HapticHelper.lightImpact();
  }

  void _changePage(int delta) {
    final newIndex = _currentPage + delta;
    if (newIndex >= 0 && newIndex < widget.svgPaths.length) {
      setState(() {
        _currentPage = newIndex;
        _areaColors.clear();
      });
      HapticHelper.mediumImpact();
    }
  }

  void _undo() {
    if (_areaColors.isNotEmpty) {
      setState(() {
        _areaColors.removeLast();
      });
      HapticHelper.lightImpact();
    }
  }

  void _saveDrawing() {
    // TODO: Kaydetme mantığı
    HapticHelper.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💾 Kaydedildi!'),
        backgroundColor: Colors.green,
      ),
    );
  }

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
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.categoryIcon} ${widget.categoryName}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                Text('Sayfa ${_currentPage + 1} / ${widget.svgPaths.length}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
          _buildSmallButton(icon: Icons.undo, onTap: _areaColors.isNotEmpty ? _undo : null),
          _buildSmallButton(icon: Icons.save, onTap: _saveDrawing),
          if (widget.svgPaths.length > 1) ...[
            _buildSmallButton(icon: Icons.chevron_left, onTap: _currentPage > 0 ? () => _changePage(-1) : null),
            _buildSmallButton(icon: Icons.chevron_right, onTap: _currentPage < widget.svgPaths.length - 1 ? () => _changePage(1) : null),
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

  Widget _buildDrawingArea() {
    final svgPath = widget.svgPaths[_currentPage.clamp(0, widget.svgPaths.length - 1)];
    
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: _buildSvgWidget(svgPath),
          ),
        ),
      ),
    );
  }

  Widget _buildSvgWidget(String svgPath) {
    // SVG dosyasını oku veher alanı tıklanabilir yap
    return FutureBuilder<String>(
      future: _loadSvg(svgPath),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Basit SVG gösterimi (gerçek implementasyonda
          // SVG parser kullanılmalı)
          return GestureDetector(
            onTapUp: (details) {
              // Tıklanan alanı bul ve boyay
              // Gerçek implementasyonda SVG parsing gerekir
              _showColorPicker();
            },
            child: SvgPicture.asset(
              svgPath,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<String> _loadSvg(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsString();
      }
      // Asset'ten yükle
      return await rootBundle.loadString(path);
    } catch (e) {
      return '';
    }
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Renk Seç', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _presetColors.length,
                itemBuilder: (context, index) {
                  final color = _presetColors[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedColor = color);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!, width: 2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<Color> _presetColors = [
    Colors.black, Colors.white, Colors.red, Colors.pink,
    Colors.purple, Colors.deepPurple, Colors.indigo, Colors.blue,
    Colors.lightBlue, Colors.cyan, Colors.teal, Colors.green,
    Colors.lightGreen, Colors.lime, Colors.yellow, Colors.amber,
    Colors.orange, Colors.deepOrange, Colors.brown, Colors.grey,
  ];

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        children: [
          // Renk seçici
          GestureDetector(
            onTap: _showColorPicker,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _selectedColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Boyut slider
          Expanded(
            child: Slider(
              value: _brushSize,
              min: 1,
              max: 20,
              onChanged: (v) => setState(() => _brushSize = v),
            ),
          ),
          const SizedBox(width: 8),
          // Opaklık slider
          Icon(Icons.opacity, size: 16, color: Colors.grey[600]),
          SizedBox(
            width: 80,
            child: Slider(
              value: _opacity,
              min: 0.1,
              max: 1.0,
              onChanged: (v) => setState(() => _opacity = v),
            ),
          ),
        ],
      ),
    );
  }
}
