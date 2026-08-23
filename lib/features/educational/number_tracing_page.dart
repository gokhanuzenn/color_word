import 'package:flutter/material.dart';
import '../../core/utils/haptic_helper.dart';

class NumberTracingPage extends StatefulWidget {
  const NumberTracingPage({super.key});

  @override
  State<NumberTracingPage> createState() => _NumberTracingPageState();
}

class _NumberTracingPageState extends State<NumberTracingPage> {
  int _currentNumberIndex = 0;
  final List<List<Offset>> _allStrokes = [];
  List<Offset> _currentStrokePoints = [];
  double _completion = 0.0;
  bool _showCelebration = false;
  bool _hasCompleted = false; // Mesaj tekrar tekrar gösterilmesin

  final Map<String, List<Offset>> _numberPaths = {
    '0': [
      Offset(250, 100), Offset(310, 130), Offset(340, 200), Offset(340, 280),
      Offset(310, 350), Offset(250, 380), Offset(190, 350), Offset(160, 280),
      Offset(160, 200), Offset(190, 130), Offset(250, 100),
    ],
    '1': [
      Offset(200, 150), Offset(250, 100), Offset(250, 380),
    ],
    '2': [
      Offset(190, 140), Offset(230, 100), Offset(290, 100), Offset(330, 140),
      Offset(330, 180), Offset(250, 260), Offset(170, 340), Offset(170, 380),
      Offset(330, 380),
    ],
    '3': [
      Offset(180, 130), Offset(250, 100), Offset(310, 130), Offset(310, 190),
      Offset(260, 220), Offset(320, 260), Offset(330, 310), Offset(300, 360),
      Offset(240, 380), Offset(190, 360),
    ],
    '4': [
      Offset(320, 100), Offset(320, 380), Offset(170, 270), Offset(340, 270),
    ],
    '5': [
      Offset(310, 100), Offset(190, 100), Offset(190, 200), Offset(290, 180),
      Offset(330, 240), Offset(330, 300), Offset(300, 360), Offset(230, 380),
      Offset(180, 360),
    ],
    '6': [
      Offset(310, 130), Offset(260, 100), Offset(200, 130), Offset(170, 220),
      Offset(170, 300), Offset(200, 360), Offset(260, 380), Offset(310, 350),
      Offset(330, 280), Offset(310, 220), Offset(250, 200), Offset(200, 220),
    ],
    '7': [
      Offset(170, 100), Offset(330, 100), Offset(330, 140), Offset(220, 380),
    ],
    '8': [
      Offset(250, 240), Offset(210, 190), Offset(210, 140), Offset(250, 100),
      Offset(300, 100), Offset(340, 140), Offset(340, 190), Offset(300, 240),
      Offset(250, 240),
      Offset(200, 290), Offset(180, 340), Offset(220, 380), Offset(280, 380),
      Offset(320, 340), Offset(300, 290), Offset(250, 240),
    ],
    '9': [
      Offset(300, 360), Offset(250, 380), Offset(200, 350), Offset(180, 280),
      Offset(190, 220), Offset(250, 200), Offset(310, 220), Offset(330, 280),
      Offset(310, 340), Offset(250, 380),
    ],
  };

  final List<String> _numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  @override
  void initState() {
    super.initState();
    _loadNumber();
  }

  void _loadNumber() {
    setState(() {
      _allStrokes.clear();
      _currentStrokePoints = [];
      _completion = 0.0;
      _showCelebration = false;
      _hasCompleted = false;
    });
  }

  void _checkCompletion() {
    if (_hasCompleted) return;

    final number = _numbers[_currentNumberIndex];
    final guidePoints = _numberPaths[number] ?? [];
    if (guidePoints.isEmpty) return;

    final allUserPoints = <Offset>[];
    for (final stroke in _allStrokes) {
      allUserPoints.addAll(stroke);
    }
    allUserPoints.addAll(_currentStrokePoints);

    // En az 20 nokta çizilmeli
    if (allUserPoints.length < 20) return;

    int matchedPoints = 0;
    for (final guidePoint in guidePoints) {
      for (final userPoint in allUserPoints) {
        if ((guidePoint - userPoint).distance < 40) {
          matchedPoints++;
          break;
        }
      }
    }

    final newCompletion = (matchedPoints / guidePoints.length).clamp(0.0, 1.0);
    if (newCompletion > _completion) {
      setState(() => _completion = newCompletion);
    }

    if (_completion >= 0.9 && allUserPoints.length > 50 && !_hasCompleted) {
      _hasCompleted = true;
      HapticHelper.heavyImpact();
      // Sadece bir kez göster
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Harika! Sayı ${_numbers[_currentNumberIndex]} tamamlandı!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
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
            _buildHeader(),

            // ÜST: Sayı gösterimi + talimat
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.touch_app, color: Colors.orange[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '☝️ Parmakla $currentNumber sayısını çiz!',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.orange[700]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentNumber,
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
                      color: Colors.orange[400],
                      shadows: [Shadow(color: Colors.orange[200]!, blurRadius: 10, offset: const Offset(4, 4))],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _completion,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(_completion >= 0.8 ? Colors.green : Colors.orange),
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(_completion * 100).toInt()}%',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _completion >= 0.8 ? Colors.green : Colors.orange),
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
                    onPanStart: (details) {
                      setState(() {
                        _currentStrokePoints = [details.localPosition];
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _currentStrokePoints.add(details.localPosition);
                      });
                      _checkCompletion();
                    },
                    onPanEnd: (details) {
                      setState(() {
                        if (_currentStrokePoints.length >= 2) {
                          _allStrokes.add(List.from(_currentStrokePoints));
                        }
                        _currentStrokePoints = [];
                      });
                    },
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: NumberTracingPainter(
                        guidePoints: guidePoints,
                        allStrokes: _allStrokes,
                        currentStroke: _currentStrokePoints,
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
                Text('🔢 Sayı Çizme', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                Text('Sayıları izleyerek çiz', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(20)),
            child: Text(
              '${_currentNumberIndex + 1} / ${_numbers.length}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.orange[700]),
            ),
          ),
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

class NumberTracingPainter extends CustomPainter {
  final List<Offset> guidePoints;
  final List<List<Offset>> allStrokes;
  final List<Offset> currentStroke;
  final String number;

  NumberTracingPainter({
    required this.guidePoints,
    required this.allStrokes,
    required this.currentStroke,
    required this.number,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);

    // Sayı gölgesi
    final textPainter = TextPainter(
      text: TextSpan(text: number, style: TextStyle(fontSize: 200, fontWeight: FontWeight.w900, color: Colors.orange[50]!)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2));

    // Kılavuz çizgi
    if (guidePoints.length >= 2) {
      final guidePaint = Paint()
        ..color = Colors.orange[200]!
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final guidePath = Path()..moveTo(guidePoints.first.dx, guidePoints.first.dy);
      for (int i = 1; i < guidePoints.length; i++) {
        guidePath.lineTo(guidePoints[i].dx, guidePoints[i].dy);
      }
      canvas.drawPath(guidePath, guidePaint);

      for (int i = 0; i < guidePoints.length; i++) {
        final isFirst = i == 0;
        canvas.drawCircle(
          guidePoints[i],
          isFirst ? 10 : 7,
          Paint()..color = isFirst ? Colors.red[400]! : Colors.orange[300]!,
        );
        if (isFirst) {
          canvas.drawCircle(guidePoints[i], 5, Paint()..color = Colors.white);
        }
      }
    }

    // Kaydedilmiş çizgiler
    for (final stroke in allStrokes) {
      if (stroke.length >= 2) {
        final userPaint = Paint()
          ..color = Colors.green
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

        final userPath = Path()..moveTo(stroke.first.dx, stroke.first.dy);
        for (int i = 1; i < stroke.length; i++) {
          userPath.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(userPath, userPaint);
      }
    }

    // Aktif çizgi
    if (currentStroke.length >= 2) {
      final activePaint = Paint()
        ..color = Colors.orange
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final activePath = Path()..moveTo(currentStroke.first.dx, currentStroke.first.dy);
      for (int i = 1; i < currentStroke.length; i++) {
        activePath.lineTo(currentStroke[i].dx, currentStroke[i].dy);
      }
      canvas.drawPath(activePath, activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
