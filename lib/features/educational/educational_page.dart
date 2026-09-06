import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'letter_tracing_page.dart';
import 'number_tracing_page.dart';
import 'connect_dots_page.dart';
import 'shape_matching_page.dart';
import 'color_matching_page.dart';
import 'memory_game_page.dart';
import '../../data/services/ad_service.dart';

/// Eğitim Oyunları Sayfası
class EducationalPage extends StatelessWidget {
  const EducationalPage({super.key});

  void _navigateWithAd(BuildContext context, Widget page) {
    AdService.instance.showInterstitialAd(
      onAdClosed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildGameCard(
                      context: context,
                      icon: '📝',
                      title: 'Harf Çizme',
                      subtitle: 'A\'dan Z\'ye harfleri çizerek öğren',
                      color: const Color(0xFF4CAF50),
                      onTap: () => _navigateWithAd(context, const LetterTracingPage()),
                    ),
                    const SizedBox(height: 16),
                    _buildGameCard(
                      context: context,
                      icon: '🔢',
                      title: 'Sayı Çizme',
                      subtitle: '0\'dan 9\'a kadar sayıları çiz',
                      color: const Color(0xFF2196F3),
                      onTap: () => _navigateWithAd(context, const NumberTracingPage()),
                    ),
                    const SizedBox(height: 16),
                    _buildGameCard(
                      context: context,
                      icon: '🎯',
                      title: 'Noktaları Birleştir',
                      subtitle: 'Noktaları bağlayarak resim oluştur',
                      color: const Color(0xFFFF9800),
                      onTap: () => _navigateWithAd(context, const ConnectDotsPage()),
                    ),
                    const SizedBox(height: 16),
                    _buildGameCard(
                      context: context,
                      icon: '🎨',
                      title: 'Şekil Eşleştirme',
                      subtitle: 'Şekilleri doğru yerlere yerleştir',
                      color: const Color(0xFF9C27B0),
                      onTap: () => _navigateWithAd(context, const ShapeMatchingPage()),
                    ),
                    const SizedBox(height: 16),
                    _buildGameCard(
                      context: context,
                      icon: '🌈',
                      title: 'Renk Eşleştirme',
                      subtitle: 'Renkleri isimleriyle eşleştir',
                      color: const Color(0xFFE91E63),
                      onTap: () => _navigateWithAd(context, const ColorMatchingPage()),
                    ),
                    const SizedBox(height: 16),
                    _buildGameCard(
                      context: context,
                      icon: '🧠',
                      title: 'Hafıza Oyunu',
                      subtitle: 'Kartları eşleştirerek hafızanı geliştir',
                      color: const Color(0xFF00BCD4),
                      onTap: () => _navigateWithAd(context, const MemoryGamePage()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                  '📚 Eğitim Oyunları',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Oynayarak öğren!',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white, size: 30),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1);
  }
}
