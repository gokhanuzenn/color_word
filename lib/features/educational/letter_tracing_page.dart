import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/haptic_helper.dart';

class LetterTracingPage extends StatefulWidget {
  const LetterTracingPage({super.key});

  @override
  State<LetterTracingPage> createState() => _LetterTracingPageState();
}

class _LetterTracingPageState extends State<LetterTracingPage>
    with SingleTickerProviderStateMixin {
  int _currentLetterIndex = 0;
  final List<List<Offset>> _allStrokes = []; // Her parmak kaldırmada yeni stroke
  List<Offset> _currentStrokePoints = [];
  bool _isTracing = false;
  double _completion = 0.0;
  bool _showCelebration = false;

  final Map<String, List<Offset>> _letterPaths = {
    'A': [Offset(150, 350), Offset(250, 100), Offset(350, 350), Offset(195, 230), Offset(305, 230)],
    'B': [Offset(150, 100), Offset(150, 350), Offset(150, 100), Offset(280, 100), Offset(310, 170), Offset(280, 225), Offset(150, 225), Offset(150, 225), Offset(300, 225), Offset(320, 290), Offset(280, 350), Offset(150, 350)],
    'C': [Offset(330, 150), Offset(250, 100), Offset(170, 150), Offset(150, 225), Offset(170, 300), Offset(250, 350), Offset(330, 300)],
    'D': [Offset(150, 100), Offset(150, 350), Offset(150, 100), Offset(270, 120), Offset(330, 225), Offset(270, 330), Offset(150, 350)],
    'E': [Offset(320, 100), Offset(150, 100), Offset(150, 350), Offset(320, 350), Offset(150, 225), Offset(280, 225)],
    'F': [Offset(320, 100), Offset(150, 100), Offset(150, 350), Offset(150, 225), Offset(280, 225)],
    'G': [Offset(330, 150), Offset(250, 100), Offset(170, 150), Offset(150, 225), Offset(170, 300), Offset(250, 350), Offset(330, 300), Offset(330, 225), Offset(260, 225)],
    'H': [Offset(150, 100), Offset(150, 350), Offset(350, 100), Offset(350, 350), Offset(150, 225), Offset(350, 225)],
    'I': [Offset(200, 100), Offset(300, 100), Offset(250, 100), Offset(250, 350), Offset(200, 350), Offset(300, 350)],
    'J': [Offset(200, 100), Offset(320, 100), Offset(280, 100), Offset(280, 280), Offset(240, 340), Offset(190, 320)],
    'K': [Offset(150, 100), Offset(150, 350), Offset(320, 100), Offset(150, 225), Offset(320, 350)],
    'L': [Offset(150, 100), Offset(150, 350), Offset(320, 350)],
    'M': [Offset(150, 350), Offset(150, 100), Offset(250, 250), Offset(350, 100), Offset(350, 350)],
    'N': [Offset(150, 350), Offset(150, 100), Offset(350, 350), Offset(350, 100)],
    'O': [Offset(250, 100), Offset(330, 160), Offset(330, 290), Offset(250, 350), Offset(170, 290), Offset(170, 160), Offset(250, 100)],
    'P': [Offset(150, 350), Offset(150, 100), Offset(300, 100), Offset(330, 170), Offset(300, 225), Offset(150, 225)],
    'Q': [Offset(250, 100), Offset(330, 160), Offset(330, 290), Offset(250, 350), Offset(170, 290), Offset(170, 160), Offset(250, 100), Offset(290, 320), Offset(340, 370)],
    'R': [Offset(150, 350), Offset(150, 100), Offset(300, 100), Offset(330, 170), Offset(300, 225), Offset(150, 225), Offset(320, 350)],
    'S': [Offset(320, 150), Offset(250, 100), Offset(180, 130), Offset(200, 190), Offset(300, 260), Offset(320, 300), Offset(250, 350), Offset(180, 310)],
    'T': [Offset(150, 100), Offset(350, 100), Offset(250, 100), Offset(250, 350)],
    'U': [Offset(150, 100), Offset(150, 280), Offset(200, 340), Offset(300, 340), Offset(350, 280), Offset(350, 100)],
    'V': [Offset(150, 100), Offset(250, 350), Offset(350, 100)],
    'W': [Offset(150, 100), Offset(200, 350), Offset(250, 200), Offset(300, 350), Offset(350, 100)],
    'X': [Offset(150, 100), Offset(350, 350), Offset(350, 100), Offset(150, 350)],
    'Y': [Offset(150, 100), Offset(250, 220), Offset(350, 100), Offset(250, 220), Offset(250, 350)],
    'Z': [Offset(150, 100), Offset(350, 100), Offset(150, 350), Offset(350, 350)],
  };

  final List<String> _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _loadLetter();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _loadLetter() {
    setState(() {
      _allStrokes.clear();
      _currentStrokePoints = [];
      _completion = 0.0;
      _showCelebration = false;
      _isTracing = false;
    });
  }

  void _checkCompletion() {
    final letter = _letters[_currentLetterIndex];
    final guidePoints = _letterPaths[letter] ?? [];
    if (guidePoints.isEmpty) return;

    // Minimum çizim uzunluğu kontrolü
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

    // %90 eşleşme ve en az 3 farklı yer çizilmeli
    if (_completion >= 0.9 && allUserPoints.length > 50 && !_showCelebration) {
      _celebrate();
    }
  }

  void _celebrate() {
    setState(() => _showCelebration = true);
    _celebrationController.forward(from: 0);
    HapticHelper.heavyImpact();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _nextLetter();
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
            _buildHeader(),

            // ÜST KISIM: Harf gösterimi + talimat
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                children: [
                  // Talimat
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.touch_app, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '☝️ Parmakla $currentLetter harfini çiz!',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.blue[700]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Büyük harf
                  Text(
                    currentLetter,
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
                      color: Colors.blue[400],
                      shadows: [Shadow(color: Colors.blue[200]!, blurRadius: 10, offset: const Offset(4, 4))],
                    ),
                  ),
                  const SizedBox(height: 8),
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
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(_completion * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _completion >= 0.8 ? Colors.green : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ÇİZİM ALANI
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
                        _isTracing = false;
                      });
                    },
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: LetterTracingPainter(
                        guidePoints: _letterPaths[_letters[_currentLetterIndex]] ?? [],
                        allStrokes: _allStrokes,
                        currentStroke: _currentStrokePoints,
                        letter: _letters[_currentLetterIndex],
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
                Text('📝 Harf Çizme', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                Text('Harfleri izleyerek çiz', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
            child: Text(
              '${_currentLetterIndex + 1} / ${_letters.length}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.blue[700]),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(icon: Icons.chevron_left, label: 'Önceki', color: Colors.grey, onTap: _previousLetter),
          _buildControlButton(
            icon: Icons.refresh,
            label: 'Sıfırla',
            color: Colors.orange,
            onTap: () {
              HapticHelper.lightImpact();
              _loadLetter();
            },
          ),
          _buildControlButton(icon: Icons.chevron_right, label: 'Sonraki', color: Colors.blue, onTap: _nextLetter),
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

class LetterTracingPainter extends CustomPainter {
  final List<Offset> guidePoints;
  final List<List<Offset>> allStrokes;
  final List<Offset> currentStroke;
  final String letter;

  LetterTracingPainter({
    required this.guidePoints,
    required this.allStrokes,
    required this.currentStroke,
    required this.letter,
  });

  // Noktaları canvas ortasına taşı
  List<Offset> _centerPoints(List<Offset> points, Size canvasSize) {
    if (points.isEmpty) return points;
    
    // Noktaların sınırlarını bul
    double minX = points.first.dx, maxX = points.first.dx;
    double minY = points.first.dy, maxY = points.first.dy;
    for (final p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    
    // Noktaların merkezi
    final pointsCenter = Offset((minX + maxX) / 2, (minY + maxY) / 2);
    // Canvas'ın merkezi
    final canvasCenter = Offset(canvasSize.width / 2, canvasSize.height / 2);
    // Offset hesapla
    final offset = canvasCenter - pointsCenter;
    
    return points.map((p) => p + offset).toList();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);

    // Noktaları ortala
    final centeredGuide = _centerPoints(guidePoints, size);
    
    // Kılavuz çizgi
    if (centeredGuide.length >= 2) {
      final guidePaint = Paint()
        ..color = Colors.grey[300]!
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final guidePath = Path()..moveTo(centeredGuide.first.dx, centeredGuide.first.dy);
      for (int i = 1; i < centeredGuide.length; i++) {
        guidePath.lineTo(centeredGuide[i].dx, centeredGuide[i].dy);
      }
      canvas.drawPath(guidePath, guidePaint);

      // Kılavuz noktalar
      for (int i = 0; i < centeredGuide.length; i++) {
        final isFirst = i == 0;
        canvas.drawCircle(
          centeredGuide[i],
          isFirst ? 10 : 7,
          Paint()..color = isFirst ? Colors.red[400]! : Colors.blue[200]!,
        );
        if (isFirst) {
          canvas.drawCircle(centeredGuide[i], 5, Paint()..color = Colors.white);
        }
      }
    }

    // Kaydedilmiş çizgiler (yeşil)
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

    // Aktif çizgi (mavi)
    if (currentStroke.length >= 2) {
      final activePaint = Paint()
        ..color = Colors.blue
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
