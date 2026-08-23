import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/utils/haptic_helper.dart';

class ColorMatchingPage extends StatefulWidget {
  const ColorMatchingPage({super.key});

  @override
  State<ColorMatchingPage> createState() => _ColorMatchingPageState();
}

class _ColorMatchingPageState extends State<ColorMatchingPage> {
  int _currentLevel = 0;
  int _score = 0;
  int? _selectedColorIndex;
  bool _showCelebration = false;

  final List<Map<String, dynamic>> _levels = [
    {
      'name': 'Temel Renkler',
      'colors': [
        {'name': 'Kırmızı', 'color': Colors.red},
        {'name': 'Mavi', 'color': Colors.blue},
        {'name': 'Yeşil', 'color': Colors.green},
        {'name': 'Sarı', 'color': Colors.yellow},
      ],
    },
    {
      'name': 'Pastel Renkler',
      'colors': [
        {'name': 'Pembe', 'color': Colors.pink},
        {'name': 'Mor', 'color': Colors.purple},
        {'name': 'Turuncu', 'color': Colors.orange},
        {'name': 'Turkuaz', 'color': Colors.teal},
        {'name': 'Lila', 'color': Colors.deepPurple},
      ],
    },
    {
      'name': 'Koyu Renkler',
      'colors': [
        {'name': 'Kahverengi', 'color': Colors.brown},
        {'name': 'Gri', 'color': Colors.grey},
        {'name': 'Koyu Kırmızı', 'color': Colors.red[900]!},
        {'name': 'Koyu Mavi', 'color': Colors.blue[900]!},
        {'name': 'Koyu Yeşil', 'color': Colors.green[900]!},
        {'name': 'Siyah', 'color': Colors.black},
      ],
    },
  ];

  late List<Map<String, dynamic>> _currentColors;
  late List<Map<String, dynamic>> _shuffledNames;

  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  void _loadLevel() {
    final level = _levels[_currentLevel];
    _currentColors = List.from(level['colors']);
    _shuffledNames = List.from(level['colors'])..shuffle();
    _selectedColorIndex = null;
    _showCelebration = false;
  }

  void _selectColor(int index) {
    HapticHelper.lightImpact();
    setState(() {
      _selectedColorIndex = index;
    });
  }

  void _tryMatch(int nameIndex) {
    if (_selectedColorIndex == null) return;

    final selectedColor = _currentColors[_selectedColorIndex!];
    final targetColor = _shuffledNames[nameIndex];

    if (selectedColor['name'] == targetColor['name']) {
      // Doğru eşleşme!
      HapticHelper.mediumImpact();
      setState(() {
        _score += 10;
        _currentColors.removeAt(_selectedColorIndex!);
        _shuffledNames.removeAt(nameIndex);
        _selectedColorIndex = null;
      });

      if (_currentColors.isEmpty) {
        setState(() => _showCelebration = true);
        HapticHelper.heavyImpact();
        _showLevelComplete();
      }
    } else {
      // Yanlış eşleşme
      HapticHelper.selectionClick();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Yanlış renk! Tekrar dene'),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 800),
        ),
      );
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
            const Text('🌈', style: TextStyle(fontSize: 60)),
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
                  _buildScoreItem('🎨', 'Kalan', '${_currentColors.length}'),
                  _buildScoreItem('🏆', 'Seviye', '${_currentLevel + 1}'),
                ],
              ),
            ),
            // Talimat
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Text(
                    '☝️ Bir renge tıkla, sonra adına tıkla',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Renkler - solda
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
                    Text('🎨 Renkleri seç', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Center(
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: _currentColors.asMap().entries.map((entry) {
                            final index = entry.key;
                            final colorData = entry.value;
                            final isSelected = _selectedColorIndex == index;

                            return GestureDetector(
                              onTap: () => _selectColor(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: colorData['color'] as Color,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? Colors.black : Colors.grey[300]!,
                                    width: isSelected ? 4 : 2,
                                  ),
                                  boxShadow: isSelected
                                      ? [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))]
                                      : [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // İsimler - sağda
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
                    Text('📝 İsimleri eşleştir', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Center(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: _shuffledNames.asMap().entries.map((entry) {
                            final index = entry.key;
                            final colorData = entry.value;

                            return GestureDetector(
                              onTap: () => _tryMatch(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!, width: 2),
                                ),
                                child: Text(
                                  colorData['name'] as String,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
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
                Text('🎨 Renk Eşleştirme', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                Text('Renkleri isimleriyle eşleştir', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
