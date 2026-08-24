import 'dart:math';
import 'package:flutter/material.dart';
import '../home/home_page.dart';

/// Çocuklar için animasyonlu splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animasyon kontrolcüleri
  late AnimationController _logoController;
  late AnimationController _titleController;
  late AnimationController _starsController;
  late AnimationController _balloonsController;
  late AnimationController _paintDropsController;
  late AnimationController _rainbowController;

  // Logo animasyonları
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<Offset> _logoSlide;

  // Başlık animasyonu
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;

  // Yıldız animasyonu
  late Animation<double> _starsOpacity;

  // Balon animasyonları
  late Animation<double> _balloonsOpacity;

  // Boya damlacıkları
  late Animation<double> _paintDropsOpacity;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    // Logo animasyonu (0-1.5 saniye)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.bounceOut),
    );

    // Başlık animasyonu (0.5-2 saniye)
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeIn),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutBack),
    );

    // Yıldız animasyonu (1-2.5 saniye)
    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _starsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _starsController, curve: Curves.easeIn),
    );

    // Balon animasyonu (0.8-2.3 saniye)
    _balloonsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _balloonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _balloonsController, curve: Curves.easeIn),
    );

    // Boya damlacıkları (1.2-2.7 saniye)
    _paintDropsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _paintDropsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _paintDropsController, curve: Curves.easeIn),
    );

    // Gökkuşağı animasyonu (0.3-1.8 saniye)
    _rainbowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  void _startAnimations() async {
    // Animasyonları sırayla başlat
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _titleController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _starsController.forward();
    _balloonsController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _paintDropsController.forward();
    _rainbowController.forward();

    // 3 saniye bekle, sonra ana sayfaya geç
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _titleController.dispose();
    _starsController.dispose();
    _balloonsController.dispose();
    _paintDropsController.dispose();
    _rainbowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final random = Random();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // Açık mavi gökyüzü
              Color(0xFFB0E0E6), // Açık turkuaz
              Color(0xFFE0F7FA), // Çok açık mavi
            ],
          ),
        ),
        child: Stack(
          children: [
            // Gökkuşağı arka plan
            AnimatedBuilder(
              animation: _rainbowController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(size.width, size.height),
                  painter: _RainbowPainter(
                    progress: _rainbowController.value,
                  ),
                );
              },
            ),

            // Uçan yıldızlar
            AnimatedBuilder(
              animation: _starsOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _starsOpacity.value,
                  child: Stack(
                    children: List.generate(20, (index) {
                      final x = random.nextDouble() * size.width;
                      final y = random.nextDouble() * size.height * 0.6;
                      final delay = index * 0.1;
                      final animValue = (_starsController.value - delay).clamp(0.0, 1.0);
                      return Positioned(
                        left: x,
                        top: y - (animValue * 50),
                        child: Text(
                          ['⭐', '✨', '🌟', '💫'][index % 4],
                          style: TextStyle(
                            fontSize: 16 + random.nextDouble() * 16,
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),

            // Uçan balonlar
            AnimatedBuilder(
              animation: _balloonsOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _balloonsOpacity.value,
                  child: Stack(
                    children: List.generate(8, (index) {
                      final colors = [
                        Colors.red,
                        Colors.blue,
                        Colors.green,
                        Colors.yellow,
                        Colors.purple,
                        Colors.orange,
                        Colors.pink,
                        Colors.teal,
                      ];
                      final x = (index * size.width / 8) + 20;
                      final startY = size.height + 50;
                      final endY = size.height * 0.3;
                      final animValue = _balloonsController.value;
                      final y = startY - (startY - endY) * animValue;
                      final sway = sin(animValue * pi * 2 + index) * 20;

                      return Positioned(
                        left: x + sway,
                        top: y,
                        child: _buildBalloon(colors[index], 30 + index * 3.0),
                      );
                    }),
                  ),
                );
              },
            ),

            // Boya damlacıkları
            AnimatedBuilder(
              animation: _paintDropsOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _paintDropsOpacity.value,
                  child: Stack(
                    children: List.generate(6, (index) {
                      final colors = [
                        const Color(0xFFFF6B6B),
                        const Color(0xFF4ECDC4),
                        const Color(0xFFFFE66D),
                        const Color(0xFF95E1D3),
                        const Color(0xFFF38181),
                        const Color(0xFFAA96DA),
                      ];
                      final x = random.nextDouble() * size.width;
                      final delay = index * 0.15;
                      final animValue = (_paintDropsController.value - delay).clamp(0.0, 1.0);
                      return Positioned(
                        left: x,
                        top: -50 + (animValue * (size.height + 100)),
                        child: _buildPaintDrop(colors[index]),
                      );
                    }),
                  ),
                );
              },
            ),

            // Ana içerik - Logo ve Başlık
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo (Aslan)
                  SlideTransition(
                    position: _logoSlide,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: RotationTransition(
                        turns: _logoRotation,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '🦁',
                              style: TextStyle(fontSize: 80),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // "Color Word" Başlığı
                  SlideTransition(
                    position: _titleSlide,
                    child: FadeTransition(
                      opacity: _titleOpacity,
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [
                              Colors.red,
                              Colors.orange,
                              Colors.yellow,
                              Colors.green,
                              Colors.blue,
                              Colors.purple,
                            ],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'Color Word',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Alt yazı
                  FadeTransition(
                    opacity: _titleOpacity,
                    child: Text(
                      '🎨 Renklerle Öğren 🌈',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Yükleme göstergesi
                  FadeTransition(
                    opacity: _titleOpacity,
                    child: SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue[400]!,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Köşeden köşeye giden renkli çizgi
            AnimatedBuilder(
              animation: _rainbowController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(size.width, size.height),
                  painter: _RainbowLinePainter(
                    progress: _rainbowController.value,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalloon(Color color, double size) {
    return Container(
      width: size,
      height: size * 1.2,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            color.withOpacity(1.0),
            color.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Parıltı
          Positioned(
            left: size * 0.2,
            top: size * 0.2,
            child: Container(
              width: size * 0.2,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // İp
          Positioned(
            bottom: -15,
            left: size * 0.45,
            child: Container(
              width: 2,
              height: 20,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaintDrop(Color color) {
    return Container(
      width: 20,
      height: 25,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

/// Gökkuşağı painter
class _RainbowPainter extends CustomPainter {
  final double progress;

  _RainbowPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final colors = [
      Colors.red.withOpacity(0.3),
      Colors.orange.withOpacity(0.3),
      Colors.yellow.withOpacity(0.3),
      Colors.green.withOpacity(0.3),
      Colors.blue.withOpacity(0.3),
      Colors.purple.withOpacity(0.3),
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerY = size.height * 0.4;
    final radius = size.width * 0.6;

    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i];
      final currentRadius = radius + (i * 12);
      final rect = Rect.fromCenter(
        center: Offset(size.width / 2, centerY + 100),
        width: currentRadius * 2,
        height: currentRadius,
      );

      // Sadece görünür kısmı çiz
      final startAngle = pi;
      final sweepAngle = pi * progress;
      path.addArc(rect, startAngle, sweepAngle);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Gökkuşağı çizgi painter
class _RainbowLinePainter extends CustomPainter {
  final double progress;

  _RainbowLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFFFFE66D),
      const Color(0xFF4ECDC4),
      const Color(0xFF95E1D3),
      const Color(0xFFAA96DA),
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final startX = -50.0;
    final endX = size.width + 50;
    final currentX = startX + (endX - startX) * progress;

    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i].withOpacity(0.6);
      path.reset();

      for (double x = startX; x < currentX; x += 2) {
        final y = size.height * 0.85 + sin(x * 0.02 + i * 0.5) * 15 + (i * 8);
        if (x == startX) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
