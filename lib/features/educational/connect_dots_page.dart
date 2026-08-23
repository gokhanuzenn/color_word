import 'package:flutter/material.dart';
import '../../core/utils/haptic_helper.dart';

class ConnectDotsPage extends StatefulWidget {
  const ConnectDotsPage({super.key});

  @override
  State<ConnectDotsPage> createState() => _ConnectDotsPageState();
}

class _ConnectDotsPageState extends State<ConnectDotsPage> {
  int _currentPuzzleIndex = 0;
  int _nextDotIndex = 0;
  final List<int> _connectedDots = [];
  bool _isCompleted = false;

  final List<Map<String, dynamic>> _puzzles = [
    {
      'name': 'Yıldız',
      'icon': '⭐',
      'color': Colors.amber,
      'dots': [
        Offset(150, 60),   // 0
        Offset(185, 130),  // 1
        Offset(260, 130),  // 2
        Offset(200, 175),  // 3
        Offset(220, 250),  // 4
        Offset(150, 210),  // 5
        Offset(80, 250),   // 6
        Offset(100, 175),  // 7
        Offset(40, 130),   // 8
        Offset(115, 130),  // 9
      ],
      'solution': [0, 9, 2, 4, 6, 8, 1, 3, 5, 7, 0],
    },
    {
      'name': 'Ev',
      'icon': '🏠',
      'color': Colors.brown,
      'dots': [
        Offset(150, 60),   // 0 - çatı tepesi
        Offset(260, 130),  // 1 - çatı sağ
        Offset(260, 260),  // 2 - duvar sağ
        Offset(40, 260),   // 3 - duvar sol
        Offset(40, 130),   // 4 - çatı sol
      ],
      'solution': [0, 1, 2, 3, 4, 0],
    },
    {
      'name': 'Kalp',
      'icon': '❤️',
      'color': Colors.red,
      'dots': [
        Offset(150, 90),   // 0
        Offset(200, 55),   // 1
        Offset(255, 80),   // 2
        Offset(255, 155),  // 3
        Offset(150, 255),  // 4
        Offset(45, 155),   // 5
        Offset(45, 80),    // 6
        Offset(100, 55),   // 7
      ],
      'solution': [0, 1, 2, 3, 4, 5, 6, 7, 0],
    },
    {
      'name': 'Güneş',
      'icon': '☀️',
      'color': Colors.orange,
      'dots': [
        Offset(150, 155),  // 0 - merkez
        Offset(150, 55),   // 1 - üst
        Offset(200, 85),   // 2
        Offset(230, 125),  // 3
        Offset(250, 155),  // 4 - sağ
        Offset(230, 185),  // 5
        Offset(200, 225),  // 6
        Offset(150, 255),  // 7 - alt
        Offset(100, 225),  // 8
        Offset(70, 185),   // 9
        Offset(50, 155),   // 10 - sol
        Offset(70, 125),   // 11
        Offset(100, 85),   // 12
      ],
      'solution': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 0],
    },
    {
      'name': 'Araba',
      'icon': '🚗',
      'color': Colors.blue,
      'dots': [
        Offset(55, 195),   // 0
        Offset(85, 135),   // 1
        Offset(125, 110),  // 2
        Offset(205, 110),  // 3
        Offset(255, 135),  // 4
        Offset(285, 195),  // 5
        Offset(285, 210),  // 6
        Offset(235, 210),  // 7
        Offset(225, 195),  // 8
        Offset(115, 195),  // 9
        Offset(105, 210),  // 10
        Offset(55, 210),   // 11
      ],
      'solution': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 0],
    },
    {
      'name': 'Kelebek',
      'icon': '🦋',
      'color': Colors.purple,
      'dots': [
        Offset(150, 155),  // 0 - gövde
        Offset(105, 85),   // 1
        Offset(55, 55),    // 2
        Offset(85, 125),   // 3
        Offset(55, 205),   // 4
        Offset(85, 255),   // 5
        Offset(105, 205),  // 6
        Offset(195, 205),  // 7
        Offset(215, 255),  // 8
        Offset(245, 205),  // 9
        Offset(215, 125),  // 10
        Offset(245, 55),   // 11
        Offset(195, 85),   // 12
      ],
      'solution': [0, 1, 2, 3, 4, 5, 6, 7, 0, 8, 9, 10, 11, 12, 1, 0],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final puzzle = _puzzles[_currentPuzzleIndex];
    final dots = puzzle['dots'] as List<Offset>;
    final color = puzzle['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(puzzle),

            // Talimat
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(puzzle['icon'], style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(puzzle['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      Text(
                        '☝️ ${_nextDotIndex + 1}. noktaya dokunarak çizgi çek',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Çizim alanı
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
                  child: GestureDetector(
                    onTapUp: (details) => _handleTap(details.localPosition, dots),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: ConnectDotsPainter(
                        dots: dots,
                        connectedDots: _connectedDots,
                        nextDotIndex: _nextDotIndex,
                        color: color,
                        isCompleted: _isCompleted,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> puzzle) {
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
                Text('🎯 Noktaları Birleştir', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                Text('Sayıları sırayla tıkla', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(20)),
            child: Text(
              '${_currentPuzzleIndex + 1} / ${_puzzles.length}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.orange[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(Offset tapPosition, List<Offset> dots) {
    if (_isCompleted) return;

    int? nearestIndex;
    double minDistance = 50;

    for (int i = 0; i < dots.length; i++) {
      if (_connectedDots.contains(i)) continue;
      final distance = (tapPosition - dots[i]).distance;
      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }

    if (nearestIndex != null && nearestIndex == _nextDotIndex) {
      HapticHelper.lightImpact();
      setState(() {
        _connectedDots.add(nearestIndex!);
        _nextDotIndex++;
      });

      if (_nextDotIndex >= dots.length) {
        setState(() => _isCompleted = true);
        HapticHelper.heavyImpact();
        _showCelebration();
      }
    } else if (nearestIndex != null) {
      HapticHelper.selectionClick();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Şimdi ${_nextDotIndex + 1}. noktaya tıkla!'),
          backgroundColor: Colors.orange,
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  void _showCelebration() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 Tebrikler!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_puzzles[_currentPuzzleIndex]['icon'], style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text('${_puzzles[_currentPuzzleIndex]['name']} tamamlandı!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('⭐ +3 Yıldız kazandın!', style: TextStyle(fontSize: 16, color: Colors.amber)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentPuzzleIndex = (_currentPuzzleIndex + 1) % _puzzles.length;
                _connectedDots.clear();
                _nextDotIndex = 0;
                _isCompleted = false;
              });
            },
            child: const Text('Sonraki →'),
          ),
        ],
      ),
    );
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
              _currentPuzzleIndex = (_currentPuzzleIndex - 1 + _puzzles.length) % _puzzles.length;
              _connectedDots.clear();
              _nextDotIndex = 0;
              _isCompleted = false;
            });
          }),
          _buildButton('Sıfırla', Icons.refresh, Colors.orange, () {
            HapticHelper.lightImpact();
            setState(() {
              _connectedDots.clear();
              _nextDotIndex = 0;
              _isCompleted = false;
            });
          }),
          _buildButton('Sonraki', Icons.chevron_right, Colors.blue, () {
            setState(() {
              _currentPuzzleIndex = (_currentPuzzleIndex + 1) % _puzzles.length;
              _connectedDots.clear();
              _nextDotIndex = 0;
              _isCompleted = false;
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

class ConnectDotsPainter extends CustomPainter {
  final List<Offset> dots;
  final List<int> connectedDots;
  final int nextDotIndex;
  final Color color;
  final bool isCompleted;

  ConnectDotsPainter({
    required this.dots,
    required this.connectedDots,
    required this.nextDotIndex,
    required this.color,
    required this.isCompleted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);

    // Bağlantı çizgileri
    if (connectedDots.length >= 2) {
      final linePaint = Paint()
        ..color = isCompleted ? Colors.green : color
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(dots[connectedDots.first].dx, dots[connectedDots.first].dy);
      for (int i = 1; i < connectedDots.length; i++) {
        path.lineTo(dots[connectedDots[i]].dx, dots[connectedDots[i]].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // Noktalar
    for (int i = 0; i < dots.length; i++) {
      final dot = dots[i];
      final isConnected = connectedDots.contains(i);
      final isNext = i == nextDotIndex && !isCompleted;

      Color dotColor;
      if (isConnected) {
        dotColor = Colors.green;
      } else if (isNext) {
        dotColor = Colors.orange;
      } else {
        dotColor = Colors.grey[400]!;
      }

      // Dış çember (nümerik etiket)
      canvas.drawCircle(
        dot,
        isNext ? 18 : 14,
        Paint()..color = dotColor.withOpacity(0.3),
      );

      // İç çember
      canvas.drawCircle(dot, isNext ? 14 : 10, Paint()..color = dotColor);

      // Sayı etiketi
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            fontSize: isNext ? 16 : 12,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(dot.dx - textPainter.width / 2, dot.dy - textPainter.height / 2),
      );

      // Sıradaki nokta animasyonu
      if (isNext) {
        canvas.drawCircle(
          dot,
          24,
          Paint()
            ..color = Colors.orange.withOpacity(0.2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
