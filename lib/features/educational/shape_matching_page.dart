import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/utils/haptic_helper.dart';

class ShapeMatchingPage extends StatefulWidget {
  const ShapeMatchingPage({super.key});

  @override
  State<ShapeMatchingPage> createState() => _ShapeMatchingPageState();
}

class _ShapeMatchingPageState extends State<ShapeMatchingPage> {
  int _currentLevel = 0;
  int _score = 0;
  final Map<int, bool> _matchedShapes = {};
  bool _showCelebration = false;

  final List<Map<String, dynamic>> _levels = [
    {
      'name': 'Temel Şekiller',
      'shapes': [
        {'id': 0, 'type': 'circle', 'color': Colors.red},
        {'id': 1, 'type': 'square', 'color': Colors.blue},
        {'id': 2, 'type': 'triangle', 'color': Colors.green},
      ],
    },
    {
      'name': 'Renkli Şekiller',
      'shapes': [
        {'id': 0, 'type': 'circle', 'color': Colors.red},
        {'id': 1, 'type': 'circle', 'color': Colors.blue},
        {'id': 2, 'type': 'square', 'color': Colors.green},
        {'id': 3, 'type': 'square', 'color': Colors.orange},
        {'id': 4, 'type': 'triangle', 'color': Colors.purple},
        {'id': 5, 'type': 'triangle', 'color': Colors.teal},
      ],
    },
    {
      'name': 'Yıldız ve Kalpler',
      'shapes': [
        {'id': 0, 'type': 'star', 'color': Colors.amber},
        {'id': 1, 'type': 'heart', 'color': Colors.pink},
        {'id': 2, 'type': 'star', 'color': Colors.orange},
        {'id': 3, 'type': 'heart', 'color': Colors.red},
        {'id': 4, 'type': 'star', 'color': Colors.yellow},
      ],
    },
  ];

  late List<Map<String, dynamic>> _currentShapes;
  late List<Map<String, dynamic>> _draggables;

  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  void _loadLevel() {
    final level = _levels[_currentLevel];
    _currentShapes = List.from(level['shapes']);
    _draggables = List.from(level['shapes'])..shuffle();
    _matchedShapes.clear();
    _showCelebration = false;
  }

  void _onShapeMatched(int shapeId) {
    HapticHelper.mediumImpact();
    setState(() {
      _matchedShapes[shapeId] = true;
      _score += 10;
    });

    if (_matchedShapes.length == _currentShapes.length) {
      setState(() => _showCelebration = true);
      HapticHelper.heavyImpact();
      _showLevelComplete();
    }
  }

  void _showLevelComplete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 Tebrikler!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌟', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text('${_levels[_currentLevel]['name']} tamamlandı!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('+50 Yıldız kazandın!', style: TextStyle(fontSize: 16, color: Colors.amber[700])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentLevel = (_currentLevel + 1) % _levels.length;
                _loadLevel();
              });
            },
            child: const Text('Sonraki Seviye →'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const targetSize = 60.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            // Skor
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildScoreItem('⭐', 'Skor', '$_score'),
                  _buildScoreItem('🎯', 'Eşleşen', '${_matchedShapes.length}/${_currentShapes.length}'),
                  _buildScoreItem('🏆', 'Seviye', '${_currentLevel + 1}'),
                ],
              ),
            ),

            // Hedefler - üstte
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Column(
                children: [
                  Text(
                    '⬆️ Şekilleri buraya sürükle ⬆️',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  // Hedef slotları
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: _currentShapes.map((shape) {
                      final isMatched = _matchedShapes[shape['id']] == true;
                      return DragTarget<int>(
                        onAcceptWithDetails: (details) {
                          if (details.data == shape['id']) {
                            _onShapeMatched(shape['id']);
                          } else {
                            HapticHelper.selectionClick();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('❌ Yanlış şekil! Doğru形状i sürükle'),
                                backgroundColor: Colors.red,
                                duration: const Duration(milliseconds: 800),
                              ),
                            );
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          final isHovering = candidateData.isNotEmpty;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: targetSize + 10,
                            height: targetSize + 10,
                            decoration: BoxDecoration(
                              color: isHovering
                                  ? (shape['color'] as Color).withOpacity(0.3)
                                  : isMatched
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.grey[100]!,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isHovering
                                    ? (shape['color'] as Color)
                                    : isMatched
                                        ? Colors.green
                                        : Colors.grey[300]!,
                                width: isHovering ? 3 : 2,
                              ),
                            ),
                            child: isMatched
                                ? Icon(Icons.check_circle, color: Colors.green, size: targetSize * 0.6)
                                : Icon(
                                    Icons.add_circle_outline,
                                    color: isHovering ? (shape['color'] as Color) : Colors.grey[400]!,
                                    size: targetSize * 0.5,
                                  ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Sürüklenebilir şekiller - altta
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: Column(
                  children: [
                    Text(
                      '⬇️ Aşağıdaki şekilleri yukarıya sürükle ⬆️',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: _draggables.map((shape) {
                          final isMatched = _matchedShapes[shape['id']] == true;
                          if (isMatched) return const SizedBox(width: 60, height: 60);

                          return Draggable<int>(
                            data: shape['id'],
                            feedback: Material(
                              color: Colors.transparent,
                              child: _buildShape(shape['type'], shape['color'], 55),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _buildShape(shape['type'], shape['color'], 55),
                            ),
                            child: _buildShape(shape['type'], shape['color'], 55),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🎨 Şekil Eşleştirme', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                Text('Şekilleri doğru yerlere sürükle', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String icon, String label, String value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildShape(String type, Color color, double size) {
    switch (type) {
      case 'circle':
        return Container(
          width: size, height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
          ),
        );
      case 'square':
        return Container(
          width: size, height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
          ),
        );
      case 'triangle':
        return CustomPaint(size: Size(size, size), painter: _TrianglePainter(color: color));
      case 'star':
        return CustomPaint(size: Size(size, size), painter: _StarPainter(color: color));
      case 'heart':
        return CustomPaint(size: Size(size, size), painter: _HeartPainter(color: color));
      default:
        return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
    }
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButton('Önceki', Icons.chevron_left, Colors.grey, () {
            setState(() {
              _currentLevel = (_currentLevel - 1 + _levels.length) % _levels.length;
              _loadLevel();
            });
          }),
          _buildButton('Sıfırla', Icons.refresh, Colors.orange, () {
            HapticHelper.lightImpact();
            setState(() => _loadLevel());
          }),
          _buildButton('Sonraki', Icons.chevron_right, Colors.blue, () {
            setState(() {
              _currentLevel = (_currentLevel + 1) % _levels.length;
              _loadLevel();
            });
          }),
        ],
      ),
    );
  }

  Widget _buildButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticHelper.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarPainter extends CustomPainter {
  final Color color;
  _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;

    final path = Path();
    for (int i = 0; i < 10; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * 36 - 90) * (3.14159 / 180);
      final point = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      if (i == 0) path.moveTo(point.dx, point.dy);
      else path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeartPainter extends CustomPainter {
  final Color color;
  _HeartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(size.width / 2, size.height * 0.35);
    path.cubicTo(size.width * 0.1, size.height * 0.1, size.width * -0.2, size.height * 0.6, size.width / 2, size.height);
    path.cubicTo(size.width * 1.2, size.height * 0.6, size.width * 0.9, size.height * 0.1, size.width / 2, size.height * 0.35);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
