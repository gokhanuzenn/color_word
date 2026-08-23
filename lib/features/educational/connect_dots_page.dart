import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/utils/haptic_helper.dart';

/// Noktaları Birleştirme Sayfası
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

  // Bulmacalar - her biri noktalar ve resim
  final List<Map<String, dynamic>> _puzzles = [
    {
      'name': 'Yıldız',
      'icon': '⭐',
      'color': Colors.amber,
      'dots': [
        Offset(150, 50),   // 1
        Offset(180, 120),  // 2
        Offset(250, 120),  // 3
        Offset(195, 170),  // 4
        Offset(215, 250),  // 5
        Offset(150, 200),  // 6
        Offset(85, 250),   // 7
        Offset(105, 170),  // 8
        Offset(50, 120),   // 9
        Offset(120, 120),  // 10
      ],
      'solution': [0, 2, 4, 6, 8, 1, 3, 5, 7, 9, 0],
    },
    {
      'name': 'Ev',
      'icon': '🏠',
      'color': Colors.brown,
      'dots': [
        Offset(150, 50),   // 1 - çatı tepesi
        Offset(250, 120),  // 2 - çatı sağ
        Offset(250, 250),  // 3 - duvar sağ
        Offset(50, 250),   // 4 - duvar sol
        Offset(50, 120),   // 5 - çatı sol
      ],
      'solution': [0, 1, 2, 3, 4, 0],
    },
    {
      'name': 'Kalp',
      'icon': '❤️',
      'color': Colors.red,
      'dots': [
        Offset(150, 80),   // 1
        Offset(200, 50),   // 2
        Offset(250, 80),   // 3
        Offset(250, 150),  // 4
        Offset(150, 250),  // 5
        Offset(50, 150),   // 6
        Offset(50, 80),    // 7
        Offset(100, 50),   // 8
      ],
      'solution': [0, 1, 2, 3, 4, 5, 6, 7, 0],
    },
    {
      'name': 'Güneş',
      'icon': '☀️',
      'color': Colors.orange,
      'dots': [
        Offset(150, 150),  // 1 - merkez
        Offset(150, 50),   // 2 - üst
        Offset(200, 80),   // 3
        Offset(230, 120),  // 4
        Offset(250, 150),  // 5 - sağ
        Offset(230, 180),  // 6
        Offset(200, 220),  // 7
        Offset(150, 250),  // 8 - alt
        Offset(100, 220),  // 9
        Offset(70, 180),   // 10
        Offset(50, 150),   // 11 - sol
        Offset(70, 120),   // 12
        Offset(100, 80),   // 13
      ],
      'solution': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 0],
    },
    {
      'name': 'Araba',
      'icon': '🚗',
      'color': Colors.blue,
      'dots': [
        Offset(50, 180),   // 1
        Offset(80, 120),   // 2
        Offset(120, 100),  // 3
        Offset(200, 100),  // 4
        Offset(250, 120),  // 5
        Offset(280, 180),  // 6
        Offset(280, 200),  // 7
        Offset(230, 200),  // 8
        Offset(220, 180),  // 9
        Offset(110, 180),  // 10
        Offset(100, 200),  // 11
        Offset(50, 200),   // 12
      ],
      'solution': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 0],
    },
    {
      'name': 'Kelebek',
      'icon': '🦋',
      'color': Colors.purple,
      'dots': [
        Offset(150, 150),  // 1 - gövde
        Offset(100, 80),   // 2 - sol üst kanat
        Offset(50, 50),    // 3
        Offset(80, 120),   // 4
        Offset(50, 200),   // 5 - sol alt kanat
        Offset(80, 250),   // 6
        Offset(100, 200),  // 7
        Offset(200, 200),  // 8 - sağ alt kanat
        Offset(220, 250),  // 9
        Offset(250, 200),  // 10
        Offset(220, 120),  // 11 - sağ üst kanat
        Offset(250, 50),   // 12
        Offset(200, 80),   // 13
      ],
      'solution': [0, 1, 2, 3, 4, 5, 6, 7, 0, 8, 9, 10, 11, 12, 13, 1],
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
            // Header
            _buildHeader(puzzle),

            // Puzzle bilgisi
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(puzzle['icon'], style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        puzzle['name'],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Sıradaki nokta: ${_nextDotIndex + 1}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

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

            // Alt kontroller
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

    // En yakın noktayı bul
    int? nearestIndex;
    double minDistance = 50; // Maksimum tıklama mesafesi

    for (int i = 0; i < dots.length; i++) {
      if (_connectedDots.contains(i)) continue;
      final distance = (tapPosition - dots[i]).distance;
      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }

    if (nearestIndex != null && nearestIndex == _nextDotIndex) {
      // Doğru noktaya tıklandı
      HapticHelper.lightImpact();
      setState(() {
        _connectedDots.add(nearestIndex!);
        _nextDotIndex++;
      });

      // Tamamlandı mı?
      if (_nextDotIndex >= dots.length) {
        setState(() => _isCompleted = true);
        HapticHelper.heavyImpact();
        _showCelebration();
      }
    } else if (nearestIndex != null) {
      // Yanlış noktaya tıklandı
      HapticHelper.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${nearestIndex + 1}. noktaya değil, ${_nextDotIndex + 1}. noktaya tıkla!'),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _showCelebration() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Tebrikler!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_puzzles[_currentPuzzleIndex]['icon'], style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              '${_puzzles[_currentPuzzleIndex]['name']} tamamlandı!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
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

/// Noktaları Birleştirme Painter'ı
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
    // Arka plan
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

      // Nokta rengi
      Color dotColor;
      if (isConnected) {
        dotColor = Colors.green;
      } else if (isNext) {
        dotColor = Colors.orange;
      } else {
        dotColor = Colors.grey[400]!;
      }

      // Nokta
      canvas.drawCircle(dot, 20, Paint()..color = dotColor.withOpacity(0.3));
      canvas.drawCircle(dot, 12, Paint()..color = dotColor);

      // Sayı
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
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
    }

    // Sıradaki nokta ipucu
    if (!isCompleted && nextDotIndex < dots.length) {
      final nextDot = dots[nextDotIndex];
      canvas.drawCircle(
        nextDot,
        25,
        Paint()
          ..color = Colors.orange.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
