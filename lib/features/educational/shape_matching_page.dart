import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/utils/haptic_helper.dart';

/// Şekil Eşleştirme Sayfası
class ShapeMatchingPage extends StatefulWidget {
  const ShapeMatchingPage({super.key});

  @override
  State<ShapeMatchingPage> createState() => _ShapeMatchingPageState();
}

class _ShapeMatchingPageState extends State<ShapeMatchingPage> {
  int _currentLevel = 0;
  int _score = 0;
  final Map<int, Offset> _matchedShapes = {};
  bool _showCelebration = false;

  // Seviyeler
  final List<Map<String, dynamic>> _levels = [
    {
      'name': 'Temel Şekiller',
      'shapes': [
        {'id': 0, 'type': 'circle', 'color': Colors.red, 'target': Offset(100, 200)},
        {'id': 1, 'type': 'square', 'color': Colors.blue, 'target': Offset(200, 200)},
        {'id': 2, 'type': 'triangle', 'color': Colors.green, 'target': Offset(300, 200)},
      ],
    },
    {
      'name': 'Renkli Şekiller',
      'shapes': [
        {'id': 0, 'type': 'circle', 'color': Colors.red, 'target': Offset(80, 150)},
        {'id': 1, 'type': 'circle', 'color': Colors.blue, 'target': Offset(200, 150)},
        {'id': 2, 'type': 'square', 'color': Colors.green, 'target': Offset(320, 150)},
        {'id': 3, 'type': 'square', 'color': Colors.orange, 'target': Offset(80, 300)},
        {'id': 4, 'type': 'triangle', 'color': Colors.purple, 'target': Offset(200, 300)},
        {'id': 5, 'type': 'triangle', 'color': Colors.teal, 'target': Offset(320, 300)},
      ],
    },
    {
      'name': 'Yıldız ve Kalpler',
      'shapes': [
        {'id': 0, 'type': 'star', 'color': Colors.amber, 'target': Offset(100, 180)},
        {'id': 1, 'type': 'heart', 'color': Colors.pink, 'target': Offset(200, 180)},
        {'id': 2, 'type': 'star', 'color': Colors.orange, 'target': Offset(300, 180)},
        {'id': 3, 'type': 'heart', 'color': Colors.red, 'target': Offset(150, 320)},
        {'id': 4, 'type': 'star', 'color': Colors.yellow, 'target': Offset(250, 320)},
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

  void _checkMatch(int shapeId, Offset position) {
    final shape = _currentShapes.firstWhere((s) => s['id'] == shapeId);
    final target = shape['target'] as Offset;

    // Hedefe yeterince yakın mı?
    if ((position - target).distance < 50) {
      HapticHelper.mediumImpact();
      setState(() {
        _matchedShapes[shapeId] = target;
        _score += 10;
      });

      // Tüm şekiller eşleşti mi?
      if (_matchedShapes.length == _currentShapes.length) {
        setState(() => _showCelebration = true);
        HapticHelper.heavyImpact();
        _showLevelComplete();
      }
    }
  }

  void _showLevelComplete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Tebrikler!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌟', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              '${_levels[_currentLevel]['name']} tamamlandı!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '+50 Yıldız kazandın!',
              style: TextStyle(fontSize: 16, color: Colors.amber[700]),
            ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
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

            // Şekiller alanı
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Hedefler
                      CustomPaint(
                        size: Size.infinite,
                        painter: ShapeTargetPainter(shapes: _currentShapes),
                      ),

                      // Sürüklenebilir şekiller
                      ..._draggables.map((shape) {
                        final isMatched = _matchedShapes.containsKey(shape['id']);
                        if (isMatched) return const SizedBox();

                        return Positioned(
                          left: shape['startX'] ?? (shape['id'] * 80.0 + 50),
                          top: shape['startY'] ?? 400,
                          child: Draggable<int>(
                            data: shape['id'],
                            onDragEnd: (details) {
                              // DraggableDetails posición
                              final renderBox = context.findRenderObject() as RenderBox;
                              final position = renderBox.localToGlobal(Offset.zero);
                              _checkMatch(shape['id'], position);
                            },
                            feedback: Material(
                              color: Colors.transparent,
                              child: _buildShape(shape['type'], shape['color'], 50),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _buildShape(shape['type'], shape['color'], 50),
                            ),
                            child: _buildShape(shape['type'], shape['color'], 50),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // Alt kontroller
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
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
          ),
        );
      case 'square':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
          ),
        );
      case 'triangle':
        return CustomPaint(
          size: Size(size, size),
          painter: _TrianglePainter(color: color),
        );
      case 'star':
        return CustomPaint(
          size: Size(size, size),
          painter: _StarPainter(color: color),
        );
      case 'heart':
        return CustomPaint(
          size: Size(size, size),
          painter: _HeartPainter(color: color),
        );
      default:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Şekil Hedefleri Painter'ı
class ShapeTargetPainter extends CustomPainter {
  final List<Map<String, dynamic>> shapes;

  ShapeTargetPainter({required this.shapes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final shape in shapes) {
      final target = shape['target'] as Offset;
      final color = shape['color'] as Color;

      // Hedef gölgesi
      canvas.drawCircle(
        target,
        30,
        Paint()
          ..color = color.withOpacity(0.15)
          ..style = PaintingStyle.fill,
      );

      // Hedef çerçevesi
      canvas.drawCircle(
        target,
        30,
        Paint()
          ..color = color.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Üçgen Painter'ı
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

/// Yıldız Painter'ı
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
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Kalp Painter'ı
class _HeartPainter extends CustomPainter {
  final Color color;
  _HeartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    path.moveTo(size.width / 2, size.height * 0.35);
    path.cubicTo(
      size.width * 0.1, size.height * 0.1,
      size.width * -0.2, size.height * 0.6,
      size.width / 2, size.height,
    );
    path.cubicTo(
      size.width * 1.2, size.height * 0.6,
      size.width * 0.9, size.height * 0.1,
      size.width / 2, size.height * 0.35,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
