import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/haptic_helper.dart';

/// Harf Çizme Sayfası
/// Çocuklar harfleri izleyerek öğrenir
class LetterTracingPage extends StatefulWidget {
  const LetterTracingPage({super.key});

  @override
  State<LetterTracingPage> createState() => _LetterTracingPageState();
}

class _LetterTracingPageState extends State<LetterTracingPage>
    with SingleTickerProviderStateMixin {
  int _currentLetterIndex = 0;
  final List<Offset> _userPoints = [];
  List<Offset> _guidePoints = [];
  bool _isTracing = false;
  double _completion = 0.0;
  bool _showCelebration = false;

  // Harfler ve çizim noktaları
  final Map<String, List<Offset>> _letterPaths = {
    'A': [
      Offset(100, 300), Offset(150, 100), Offset(200, 300),
      Offset(125, 220), Offset(175, 220),
    ],
    'B': [
      Offset(100, 100), Offset(100, 300),
      Offset(100, 100), Offset(180, 100), Offset(200, 150), Offset(180, 200), Offset(100, 200),
      Offset(100, 200), Offset(190, 200), Offset(210, 250), Offset(190, 300), Offset(100, 300),
    ],
    'C': [
      Offset(200, 120), Offset(150, 100), Offset(120, 150), Offset(120, 250), Offset(150, 300), Offset(200, 280),
    ],
    'D': [
      Offset(100, 100), Offset(100, 300),
      Offset(100, 100), Offset(170, 120), Offset(200, 200), Offset(170, 280), Offset(100, 300),
    ],
    'E': [
      Offset(200, 100), Offset(100, 100), Offset(100, 300), Offset(200, 300),
      Offset(100, 200), Offset(170, 200),
    ],
    'F': [
      Offset(200, 100), Offset(100, 100), Offset(100, 300),
      Offset(100, 200), Offset(170, 200),
    ],
    'G': [
      Offset(200, 120), Offset(150, 100), Offset(120, 150), Offset(120, 250), Offset(150, 300), Offset(200, 280), Offset(200, 200), Offset(170, 200),
    ],
    'H': [
      Offset(100, 100), Offset(100, 300),
      Offset(200, 100), Offset(200, 300),
      Offset(100, 200), Offset(200, 200),
    ],
    'I': [
      Offset(150, 100), Offset(150, 300),
      Offset(120, 100), Offset(180, 100),
      Offset(120, 300), Offset(180, 300),
    ],
    'J': [
      Offset(180, 100), Offset(180, 250), Offset(150, 300), Offset(120, 280),
    ],
    'K': [
      Offset(100, 100), Offset(100, 300),
      Offset(200, 100), Offset(100, 200), Offset(200, 300),
    ],
    'L': [
      Offset(100, 100), Offset(100, 300), Offset(200, 300),
    ],
    'M': [
      Offset(100, 300), Offset(100, 100), Offset(150, 200), Offset(200, 100), Offset(200, 300),
    ],
    'N': [
      Offset(100, 300), Offset(100, 100), Offset(200, 300), Offset(200, 100),
    ],
    'O': [
      Offset(150, 100), Offset(200, 150), Offset(200, 250), Offset(150, 300), Offset(100, 250), Offset(100, 150), Offset(150, 100),
    ],
    'P': [
      Offset(100, 300), Offset(100, 100), Offset(180, 100), Offset(200, 150), Offset(180, 200), Offset(100, 200),
    ],
    'Q': [
      Offset(150, 100), Offset(200, 150), Offset(200, 250), Offset(150, 300), Offset(100, 250), Offset(100, 150), Offset(150, 100),
      Offset(170, 280), Offset(200, 320),
    ],
    'R': [
      Offset(100, 300), Offset(100, 100), Offset(180, 100), Offset(200, 150), Offset(180, 200), Offset(100, 200),
      Offset(150, 200), Offset(200, 300),
    ],
    'S': [
      Offset(190, 120), Offset(150, 100), Offset(110, 130), Offset(130, 180), Offset(170, 220), Offset(190, 270), Offset(150, 300), Offset(110, 280),
    ],
    'T': [
      Offset(100, 100), Offset(200, 100),
      Offset(150, 100), Offset(150, 300),
    ],
    'U': [
      Offset(100, 100), Offset(100, 250), Offset(150, 300), Offset(200, 250), Offset(200, 100),
    ],
    'V': [
      Offset(100, 100), Offset(150, 300), Offset(200, 100),
    ],
    'W': [
      Offset(100, 100), Offset(125, 300), Offset(150, 200), Offset(175, 300), Offset(200, 100),
    ],
    'X': [
      Offset(100, 100), Offset(200, 300),
      Offset(200, 100), Offset(100, 300),
    ],
    'Y': [
      Offset(100, 100), Offset(150, 200), Offset(200, 100),
      Offset(150, 200), Offset(150, 300),
    ],
    'Z': [
      Offset(100, 100), Offset(200, 100), Offset(100, 300), Offset(200, 300),
    ],
  };

  final List<String> _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _celebrationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
    _loadLetter();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _loadLetter() {
    final letter = _letters[_currentLetterIndex];
    setState(() {
      _guidePoints = _letterPaths[letter] ?? [];
      _userPoints.clear();
      _completion = 0.0;
      _showCelebration = false;
    });
  }

  void _checkCompletion() {
    if (_guidePoints.isEmpty) return;

    // Kullanıcı noktalarının kılavuz noktalara olan uzaklıklarını kontrol et
    int matchedPoints = 0;
    for (final guidePoint in _guidePoints) {
      for (final userPoint in _userPoints) {
        if ((guidePoint - userPoint).distance < 50) {
          matchedPoints++;
          break;
        }
      }
    }

    final newCompletion = matchedPoints / _guidePoints.length;
    if (newCompletion > _completion) {
      setState(() => _completion = newCompletion);
    }

    // Tamamlandı mı?
    if (_completion >= 0.8 && !_showCelebration) {
      _celebrate();
    }
  }

  void _celebrate() {
    setState(() => _showCelebration = true);
    _celebrationController.forward(from: 0);
    HapticHelper.heavyImpact();

    // 2 saniye bekle, sonra sonraki harfe geç
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _nextLetter();
      }
    });
  }

  void _nextLetter() {
    setState(() {
      _currentLetterIndex = (_currentLetterIndex + 1) % _letters.length;
    });
    _loadLetter();
  }

  void _previousLetter() {
    setState(() {
      _currentLetterIndex = (_currentLetterIndex - 1 + _letters.length) % _letters.length;
    });
    _loadLetter();
  }

  @override
  Widget build(BuildContext context) {
    final currentLetter = _letters[_currentLetterIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Harf gösterimi
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                children: [
                  // Harf
                  Text(
                    currentLetter,
                    style: TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.w900,
                      color: Colors.blue[400],
                      shadows: [
                        Shadow(color: Colors.blue[200]!, blurRadius: 10, offset: const Offset(4, 4)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // İlerleme
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _completion,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _completion >= 0.8 ? Colors.green : Colors.blue,
                            ),
                            minHeight: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(_completion * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _completion >= 0.8 ? Colors.green : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Çizim alanı
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GestureDetector(
                    onPanStart: (details) {
                      setState(() {
                        _isTracing = true;
                        _userPoints.add(details.localPosition);
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _userPoints.add(details.localPosition);
                      });
                      _checkCompletion();
                    },
                    onPanEnd: (details) {
                      setState(() => _isTracing = false);
                    },
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: TracingPainter(
                        guidePoints: _guidePoints,
                        userPoints: _userPoints,
                        letter: currentLetter,
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

  Widget _buildHeader() {
    return Container(
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
                Text(
                  '📝 Harf Çizme',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Harfleri izleyerek çiz',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Harf sayacı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentLetterIndex + 1} / ${_letters.length}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.blue[700],
              ),
            ),
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Önceki harf
          _buildControlButton(
            icon: Icons.chevron_left,
            label: 'Önceki',
            color: Colors.grey,
            onTap: _previousLetter,
          ),
          // Sıfırla
          _buildControlButton(
            icon: Icons.refresh,
            label: 'Sıfırla',
            color: Colors.orange,
            onTap: () {
              HapticHelper.lightImpact();
              _loadLetter();
            },
          ),
          // Sonraki harf
          _buildControlButton(
            icon: Icons.chevron_right,
            label: 'Sonraki',
            color: Colors.blue,
            onTap: _nextLetter,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
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
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Çizim Painter'ı
class TracingPainter extends CustomPainter {
  final List<Offset> guidePoints;
  final List<Offset> userPoints;
  final String letter;

  TracingPainter({
    required this.guidePoints,
    required this.userPoints,
    required this.letter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Arka plan
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    // Kılavuz çizgi (gri)
    if (guidePoints.length >= 2) {
      final guidePaint = Paint()
        ..color = Colors.grey[300]!
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final guidePath = Path()
        ..moveTo(guidePoints.first.dx, guidePoints.first.dy);
      for (int i = 1; i < guidePoints.length; i++) {
        guidePath.lineTo(guidePoints[i].dx, guidePoints[i].dy);
      }
      canvas.drawPath(guidePath, guidePaint);

      // Kılavuz noktalar
      for (final point in guidePoints) {
        canvas.drawCircle(
          point,
          12,
          Paint()..color = Colors.blue[100]!,
        );
        canvas.drawCircle(
          point,
          6,
          Paint()..color = Colors.blue[400]!,
        );
      }
    }

    // Kullanıcı çizgisi (yeşil)
    if (userPoints.length >= 2) {
      final userPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final userPath = Path()
        ..moveTo(userPoints.first.dx, userPoints.first.dy);
      for (int i = 1; i < userPoints.length; i++) {
        userPath.lineTo(userPoints[i].dx, userPoints[i].dy);
      }
      canvas.drawPath(userPath, userPaint);
    }

    // Harf gölgesi
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: 200,
          fontWeight: FontWeight.w900,
          color: Colors.blue[50]!,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
