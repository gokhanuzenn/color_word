import 'package:flutter/material.dart';
import '../../core/utils/haptic_helper.dart';

/// Sayı Çizme Sayfası
class NumberTracingPage extends StatefulWidget {
  const NumberTracingPage({super.key});

  @override
  State<NumberTracingPage> createState() => _NumberTracingPageState();
}

class _NumberTracingPageState extends State<NumberTracingPage> {
  int _currentNumberIndex = 0;
  final List<Offset> _userPoints = [];
  double _completion = 0.0;

  // Sayılar ve çizim noktaları
  final Map<String, List<Offset>> _numberPaths = {
    '0': [
      Offset(150, 100), Offset(200, 150), Offset(200, 250), Offset(150, 300), Offset(100, 250), Offset(100, 150), Offset(150, 100),
    ],
    '1': [
      Offset(150, 100), Offset(150, 300),
      Offset(120, 130), Offset(150, 100),
    ],
    '2': [
      Offset(120, 120), Offset(150, 100), Offset(190, 130), Offset(150, 200), Offset(100, 300), Offset(200, 300),
    ],
    '3': [
      Offset(110, 120), Offset(150, 100), Offset(180, 130), Offset(150, 180),
      Offset(180, 220), Offset(150, 300), Offset(110, 280),
    ],
    '4': [
      Offset(180, 100), Offset(180, 300),
      Offset(100, 200), Offset(180, 200),
    ],
    '5': [
      Offset(180, 100), Offset(120, 100), Offset(120, 180), Offset(170, 160), Offset(190, 220), Offset(150, 300), Offset(110, 280),
    ],
    '6': [
      Offset(180, 120), Offset(150, 100), Offset(120, 150), Offset(100, 250), Offset(120, 300), Offset(170, 300), Offset(190, 250), Offset(170, 200), Offset(120, 200),
    ],
    '7': [
      Offset(100, 100), Offset(200, 100), Offset(150, 300),
    ],
    '8': [
      Offset(150, 200), Offset(120, 150), Offset(120, 120), Offset(150, 100), Offset(180, 120), Offset(180, 150), Offset(150, 200),
      Offset(180, 250), Offset(180, 280), Offset(150, 300), Offset(120, 280), Offset(120, 250), Offset(150, 200),
    ],
    '9': [
      Offset(180, 200), Offset(170, 100), Offset(150, 100), Offset(120, 150), Offset(100, 250), Offset(120, 280), Offset(150, 300), Offset(180, 280),
    ],
  };

  final List<String> _numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  @override
  void initState() {
    super.initState();
    _loadNumber();
  }

  void _loadNumber() {
    final number = _numbers[_currentNumberIndex];
    setState(() {
      _userPoints.clear();
      _completion = 0.0;
    });
  }

  void _checkCompletion() {
    final number = _numbers[_currentNumberIndex];
    final guidePoints = _numberPaths[number] ?? [];
    if (guidePoints.isEmpty) return;

    int matchedPoints = 0;
    for (final guidePoint in guidePoints) {
      for (final userPoint in _userPoints) {
        if ((guidePoint - userPoint).distance < 50) {
          matchedPoints++;
          break;
        }
      }
    }

    final newCompletion = matchedPoints / guidePoints.length;
    if (newCompletion > _completion) {
      setState(() => _completion = newCompletion);
    }

    if (_completion >= 0.8) {
      HapticHelper.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Harika! Sayı $_numbers[_currentNumberIndex] tamamlandı!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentNumber = _numbers[_currentNumberIndex];
    final guidePoints = _numberPaths[currentNumber] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                ],
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
                        Text('🔢 Sayı Çizme', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                        Text('Sayıları izleyerek çiz', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '${_currentNumberIndex + 1} / ${_numbers.length}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),

            // Sayı gösterimi
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Column(
                children: [
                  Text(
                    currentNumber,
                    style: TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.w900,
                      color: Colors.orange[400],
                      shadows: [Shadow(color: Colors.orange[200]!, blurRadius: 10, offset: const Offset(4, 4))],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _completion,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(_completion >= 0.8 ? Colors.green : Colors.orange),
                            minHeight: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(_completion * 100).toInt()}%',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _completion >= 0.8 ? Colors.green : Colors.orange),
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
                    onPanStart: (details) => setState(() => _userPoints.add(details.localPosition)),
                    onPanUpdate: (details) {
                      setState(() => _userPoints.add(details.localPosition));
                      _checkCompletion();
                    },
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: NumberTracingPainter(
                        guidePoints: guidePoints,
                        userPoints: _userPoints,
                        number: currentNumber,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Alt kontroller
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton('Önceki', Icons.chevron_left, Colors.grey, () {
                    setState(() => _currentNumberIndex = (_currentNumberIndex - 1 + _numbers.length) % _numbers.length);
                    _loadNumber();
                  }),
                  _buildButton('Sıfırla', Icons.refresh, Colors.orange, () {
                    HapticHelper.lightImpact();
                    _loadNumber();
                  }),
                  _buildButton('Sonraki', Icons.chevron_right, Colors.blue, () {
                    setState(() => _currentNumberIndex = (_currentNumberIndex + 1) % _numbers.length);
                    _loadNumber();
                  }),
                ],
              ),
            ),
          ],
        ),
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

/// Sayı Çizim Painter'ı
class NumberTracingPainter extends CustomPainter {
  final List<Offset> guidePoints;
  final List<Offset> userPoints;
  final String number;

  NumberTracingPainter({
    required this.guidePoints,
    required this.userPoints,
    required this.number,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Arka plan
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);

    // Kılavuz çizgi
    if (guidePoints.length >= 2) {
      final guidePaint = Paint()
        ..color = Colors.orange[200]!
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final guidePath = Path()..moveTo(guidePoints.first.dx, guidePoints.first.dy);
      for (int i = 1; i < guidePoints.length; i++) {
        guidePath.lineTo(guidePoints[i].dx, guidePoints[i].dy);
      }
      canvas.drawPath(guidePath, guidePaint);

      for (final point in guidePoints) {
        canvas.drawCircle(point, 12, Paint()..color = Colors.orange[100]!);
        canvas.drawCircle(point, 6, Paint()..color = Colors.orange[400]!);
      }
    }

    // Kullanıcı çizgisi
    if (userPoints.length >= 2) {
      final userPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final userPath = Path()..moveTo(userPoints.first.dx, userPoints.first.dy);
      for (int i = 1; i < userPoints.length; i++) {
        userPath.lineTo(userPoints[i].dx, userPoints[i].dy);
      }
      canvas.drawPath(userPath, userPaint);
    }

    // Sayı gölgesi
    final textPainter = TextPainter(
      text: TextSpan(text: number, style: TextStyle(fontSize: 200, fontWeight: FontWeight.w900, color: Colors.orange[50]!)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
