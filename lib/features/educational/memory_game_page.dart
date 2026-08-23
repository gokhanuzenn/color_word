import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/utils/haptic_helper.dart';

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  int _currentLevel = 0;
  int _score = 0;
  int _moves = 0;
  int? _firstFlippedIndex;
  int? _secondFlippedIndex;
  bool _isProcessing = false;
  final Set<int> _matchedCards = {};
  bool _showCelebration = false;

  final List<Map<String, dynamic>> _levels = [
    {
      'name': 'Kolay (4 Çift)',
      'cards': ['🌟', '❤️', '🎈', '🎵'],
    },
    {
      'name': 'Orta (6 Çift)',
      'cards': ['🌟', '❤️', '🎈', '🎵', '🌸', '🦋'],
    },
    {
      'name': 'Zor (8 Çift)',
      'cards': ['🌟', '❤️', '🎈', '🎵', '🌸', '🦋', '🎨', '🍭'],
    },
  ];

  late List<String> _cardValues;
  late List<bool> _isFlipped;

  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  void _loadLevel() {
    final level = _levels[_currentLevel];
    final cards = List<String>.from(level['cards'] as List);
    _cardValues = [...cards, ...cards]..shuffle();
    _isFlipped = List.generate(_cardValues.length, (_) => false);
    _firstFlippedIndex = null;
    _secondFlippedIndex = null;
    _isProcessing = false;
    _matchedCards.clear();
    _moves = 0;
    _showCelebration = false;
  }

  void _flipCard(int index) {
    if (_isProcessing) return;
    if (_isFlipped[index]) return;
    if (_matchedCards.contains(index)) return;

    HapticHelper.lightImpact();

    setState(() {
      _isFlipped[index] = true;

      if (_firstFlippedIndex == null) {
        _firstFlippedIndex = index;
      } else {
        _secondFlippedIndex = index;
        _moves++;
        _isProcessing = true;

        // Eşleşme kontrolü
        Future.delayed(const Duration(milliseconds: 800), () {
          if (_cardValues[_firstFlippedIndex!] == _cardValues[_secondFlippedIndex!]) {
            // Eşleşti!
            HapticHelper.mediumImpact();
            setState(() {
              _matchedCards.add(_firstFlippedIndex!);
              _matchedCards.add(_secondFlippedIndex!);
              _score += 20;
              _firstFlippedIndex = null;
              _secondFlippedIndex = null;
              _isProcessing = false;
            });

            // Tüm kartlar eşleşti mi?
            if (_matchedCards.length == _cardValues.length) {
              setState(() => _showCelebration = true);
              HapticHelper.heavyImpact();
              _showLevelComplete();
            }
          } else {
            // Eşleşmedi - geri çevir
            setState(() {
              _isFlipped[_firstFlippedIndex!] = false;
              _isFlipped[_secondFlippedIndex!] = false;
              _firstFlippedIndex = null;
              _secondFlippedIndex = null;
              _isProcessing = false;
            });
          }
        });
      }
    });
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
            const Text('🧠', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text('${_levels[_currentLevel]['name']} tamamlandı!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('$_moves hamlede tamamladın!', style: TextStyle(fontSize: 16, color: Colors.blue[700])),
            const SizedBox(height: 4),
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
    final cards = _levels[_currentLevel]['cards'] as List;
    final gridSize = cards.length <= 4 ? 2 : (cards.length <= 6 ? 3 : 4);

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
                  _buildScoreItem('👆', 'Hamle', '$_moves'),
                  _buildScoreItem('✅', 'Eşleşen', '${_matchedCards.length ~/ 2}/${cards.length}'),
                ],
              ),
            ),
            // Talimat
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Colors.purple[600]),
                  const SizedBox(width: 8),
                  Text(
                    '🧠 Kartlara tıklayarak eşleştir',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.purple[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Kartlar
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _cardValues.length,
                  itemBuilder: (context, index) {
                    final isFlipped = _isFlipped[index] || _matchedCards.contains(index);
                    final isMatched = _matchedCards.contains(index);

                    return GestureDetector(
                      onTap: () => _flipCard(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isFlipped
                              ? (isMatched ? Colors.green[50] : Colors.white)
                              : Colors.purple,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isMatched ? Colors.green : Colors.purple[300]!,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isFlipped
                              ? Text(
                                  _cardValues[index],
                                  style: TextStyle(fontSize: gridSize == 2 ? 48 : (gridSize == 3 ? 36 : 28)),
                                )
                              : const Icon(Icons.question_mark, color: Colors.white, size: 32),
                        ),
                      ),
                    );
                  },
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
                Text('🧠 Hafıza Oyunu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                Text('Kartları eşleştir', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
