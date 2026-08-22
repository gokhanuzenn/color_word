import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Boyama türü
enum BrushType {
  water,
  felt,
  classic,
  dry,
}

/// Araç türü
enum ToolType {
  pencil,
  brush,
  eraser,
}

/// Kalem kalınlığı
enum PencilGrade {
  hb,
  b2,
  b3,
  b4,
  b6,
  b8,
}

/// Fırça stili
enum BrushStyle {
  watercolor,
  acrylic,
  oil,
  pastel,
  ink,
}

/// Tam boyama paneli widget'ı
class ColoringToolbar extends StatefulWidget {
  final Function(BrushType brushType) onBrushTypeChanged;
  final Function(ToolType toolType) onToolTypeChanged;
  final Function(double size) onSizeChanged;
  final Function(Color color) onColorSelected;
  final Function(PencilGrade? grade) onPencilGradeChanged;
  final Function(BrushStyle? style) onBrushStyleChanged;
  final Function() onEraserSelected;

  const ColoringToolbar({
    super.key,
    required this.onBrushTypeChanged,
    required this.onToolTypeChanged,
    required this.onSizeChanged,
    required this.onColorSelected,
    required this.onPencilGradeChanged,
    required this.onBrushStyleChanged,
    required this.onEraserSelected,
  });

  @override
  State<ColoringToolbar> createState() => _ColoringToolbarState();
}

class _ColoringToolbarState extends State<ColoringToolbar> {
  BrushType _selectedBrushType = BrushType.classic;
  ToolType _selectedToolType = ToolType.brush;
  double _brushSize = 8.0;
  Color _selectedColor = Colors.black;

  // Geniş renk paleti
  static const List<Color> _colorPalette = [
    Colors.black,
    Color(0xFF333333),
    Color(0xFF555555),
    Color(0xFF888888),
    Color(0xFFAAAAAA),
    Color(0xFFCCCCCC),
    Colors.white,
    Color(0xFFD32F2F),
    Color(0xFFE53935),
    Color(0xFFEF5350),
    Color(0xFFFF8A80),
    Color(0xFFF57C00),
    Color(0xFFFF9800),
    Color(0xFFFFB74D),
    Color(0xFFFFCC80),
    Color(0xFFFBC02D),
    Color(0xFFFFEB3B),
    Color(0xFFFFF176),
    Color(0xFF388E3C),
    Color(0xFF4CAF50),
    Color(0xFF81C784),
    Color(0xFFA5D6A7),
    Color(0xFF00796B),
    Color(0xFF009688),
    Color(0xFF4DB6AC),
    Color(0xFF1565C0),
    Color(0xFF2196F3),
    Color(0xFF64B5F6),
    Color(0xFF90CAF9),
    Color(0xFF7B1FA2),
    Color(0xFF9C27B0),
    Color(0xFFBA68C8),
    Color(0xFFCE93D8),
    Color(0xFFC2185B),
    Color(0xFFE91E63),
    Color(0xFFF06292),
    Color(0xFFF48FB1),
    Color(0xFF4E342E),
    Color(0xFF6D4C41),
    Color(0xFF8D6E63),
    Color(0xFFFFAB91),
    Color(0xFFFF8A65),
    Color(0xFFFF7043),
  ];

  // Boyama türleri
  static const Map<BrushType, String> _brushTypes = {
    BrushType.water: 'Sulu',
    BrushType.felt: 'Keçeli',
    BrushType.classic: 'Klasik',
    BrushType.dry: 'Kuru',
  };

  /// Kalem menüsünü göster
  void _showPencilMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PencilMenu(
        onSelected: (grade) {
          Navigator.pop(context);
        },
      ),
    );
  }

  /// Fırça menüsünü göster
  void _showBrushMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _BrushMenu(
        onSelected: (style) {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          color: AppColors.border,
          width: AppConstants.borderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Satır: Boyama Türü
          _buildBrushTypeRow(),

          const SizedBox(height: 10),

          // 2. Satır: Boyut Slider'ı
          _buildSizeSlider(),

          const SizedBox(height: 10),

          // 3. Satır: Araçlar
          _buildToolRow(),

          const SizedBox(height: 10),

          // 4. Satır: Renk Paleti (yuvarlak)
          _buildColorPalette(),
        ],
      ),
    );
  }

  /// Boyama türü seçimi
  Widget _buildBrushTypeRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: BrushType.values.map((type) {
          final isSelected = _selectedBrushType == type;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedBrushType = type);
              widget.onBrushTypeChanged(type);
            },
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              width: 70,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.buttonPrimary : Colors.white,
                border: Border.all(
                  color: AppColors.border,
                  width: isSelected ? 3 : 2,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: isSelected
                    ? [
                        const BoxShadow(
                          color: AppColors.shadow,
                          offset: Offset(2, 2),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  _brushTypes[type]!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Boyut slider'ı - daha oval ve küçük
  Widget _buildSizeSlider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Text(
            'BOYUT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: AppColors.border,
                inactiveTrackColor: AppColors.border.withOpacity(0.3),
                thumbColor: AppColors.border,
                overlayColor: AppColors.border.withOpacity(0.1),
              ),
              child: Slider(
                value: _brushSize,
                min: 1,
                max: 50,
                onChanged: (value) {
                  setState(() => _brushSize = value);
                  widget.onSizeChanged(value);
                },
              ),
            ),
          ),
          Container(
            width: 32,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${_brushSize.toInt()}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Araç seçimi
  Widget _buildToolRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolButton(
            icon: Icons.edit,
            label: 'KALEM',
            isSelected: _selectedToolType == ToolType.pencil,
            onTap: () {
              setState(() => _selectedToolType = ToolType.pencil);
              widget.onToolTypeChanged(ToolType.pencil);
              _showPencilMenu();
            },
          ),
          _buildToolButton(
            icon: Icons.brush,
            label: 'FIRÇA',
            isSelected: _selectedToolType == ToolType.brush,
            onTap: () {
              setState(() => _selectedToolType = ToolType.brush);
              widget.onToolTypeChanged(ToolType.brush);
              _showBrushMenu();
            },
          ),
          _buildToolButton(
            icon: Icons.delete_outline,
            label: 'SİLGİ',
            isSelected: _selectedToolType == ToolType.eraser,
            onTap: () {
              setState(() => _selectedToolType = ToolType.eraser);
              widget.onEraserSelected();
            },
          ),
        ],
      ),
    );
  }

  /// Araç butonu
  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        width: 80,
        height: 65,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttonPrimary : Colors.white,
          border: Border.all(
            color: AppColors.border,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: AppColors.shadow,
                    offset: Offset(3, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: AppColors.textPrimary),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Renk paleti - YUVARLAK
  Widget _buildColorPalette() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _colorPalette.length,
        itemBuilder: (context, index) {
          final color = _colorPalette[index];
          final isSelected = _selectedColor == color;
          final isWhite = color == Colors.white;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedColor = color);
                widget.onColorSelected(color);
              },
              child: AnimatedContainer(
                duration: AppConstants.animFast,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.border
                        : isWhite
                            ? AppColors.border.withOpacity(0.5)
                            : Colors.transparent,
                    width: isSelected ? 4 : 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          const BoxShadow(
                            color: AppColors.shadow,
                            offset: Offset(2, 2),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            offset: const Offset(1, 1),
                          ),
                        ],
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 18,
                        color: color == Colors.black ||
                                color == const Color(0xFF333333) ||
                                color == const Color(0xFF555555)
                            ? Colors.white
                            : Colors.black,
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Kalem menüsü (Popup) - Scroll edilebilir
class _PencilMenu extends StatelessWidget {
  final Function(PencilGrade) onSelected;

  const _PencilMenu({required this.onSelected});

  static const Map<PencilGrade, Map<String, dynamic>> _pencilData = {
    PencilGrade.hb: {
      'label': 'HB',
      'subtitle': 'Standart',
      'thickness': 1.0,
      'color': Color(0xFF424242),
    },
    PencilGrade.b2: {
      'label': '2B',
      'subtitle': 'Biraz kalın',
      'thickness': 1.5,
      'color': Color(0xFF333333),
    },
    PencilGrade.b3: {
      'label': '3B',
      'subtitle': 'Orta kalınlık',
      'thickness': 2.0,
      'color': Color(0xFF222222),
    },
    PencilGrade.b4: {
      'label': '4B',
      'subtitle': 'Kalın',
      'thickness': 2.5,
      'color': Color(0xFF1A1A1A),
    },
    PencilGrade.b6: {
      'label': '6B',
      'subtitle': 'Çok kalın',
      'thickness': 3.5,
      'color': Color(0xFF111111),
    },
    PencilGrade.b8: {
      'label': '8B',
      'subtitle': 'En kalın',
      'thickness': 5.0,
      'color': Color(0xFF000000),
    },
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border, width: 3),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '✏️ Kalem Kalınlığı',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _pencilData.length,
              itemBuilder: (context, index) {
                final entry = _pencilData.entries.elementAt(index);
                final data = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => onSelected(entry.key),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 3,
                            color: data['color'],
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['label'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                data['subtitle'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Fırça menüsü (Popup) - Scroll edilebilir
class _BrushMenu extends StatelessWidget {
  final Function(BrushStyle) onSelected;

  const _BrushMenu({required this.onSelected});

  static const Map<BrushStyle, Map<String, dynamic>> _brushData = {
    BrushStyle.watercolor: {
      'label': 'Sulu Boya',
      'subtitle': 'Şeffaf ve yumuşak',
      'icon': Icons.water_drop,
      'color': Color(0xFF64B5F6),
    },
    BrushStyle.acrylic: {
      'label': 'Akrilik',
      'subtitle': 'Canlı ve parlak',
      'icon': Icons.format_paint,
      'color': Color(0xFFEF5350),
    },
    BrushStyle.oil: {
      'label': 'Yağlı Boya',
      'subtitle': 'Kalın ve dokulu',
      'icon': Icons.palette,
      'color': Color(0xFFFF9800),
    },
    BrushStyle.pastel: {
      'label': 'Pastel',
      'subtitle': 'Yumuşak ve hafif',
      'icon': Icons.brush,
      'color': Color(0xFFF48FB1),
    },
    BrushStyle.ink: {
      'label': 'Mürekkep',
      'subtitle': 'Koyu ve net',
      'icon': Icons.draw,
      'color': Color(0xFF212121),
    },
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border, width: 3),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🖌️ Fırça Türü',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _brushData.length,
              itemBuilder: (context, index) {
                final entry = _brushData.entries.elementAt(index);
                final data = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => onSelected(entry.key),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: (data['color'] as Color).withOpacity(0.2),
                              border: Border.all(
                                color: AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              data['icon'] as IconData,
                              color: data['color'] as Color,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['label'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                data['subtitle'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
