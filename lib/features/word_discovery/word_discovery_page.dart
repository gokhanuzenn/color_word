import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/neubrutal_button.dart';
import '../../core/widgets/neubrutal_card.dart';
import '../../core/widgets/word_card.dart';
import '../../data/providers/app_provider.dart';

/// Kelime keşfetme sayfası
class WordDiscoveryPage extends ConsumerStatefulWidget {
  const WordDiscoveryPage({super.key});

  @override
  ConsumerState<WordDiscoveryPage> createState() => _WordDiscoveryPageState();
}

class _WordDiscoveryPageState extends ConsumerState<WordDiscoveryPage> {
  int _currentWordIndex = 0;
  List<String> _discoveredLetters = [];

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final wordsAsync = ref.watch(
      categoryWordsProvider(selectedCategory?.id ?? ''),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('📝 Kelimeler'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: wordsAsync.when(
        data: (words) {
          if (words.isEmpty) {
            return const Center(
              child: Text(
                'Bu kategoride henüz kelime yok',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              children: [
                // Başlık
                const Text(
                  '🔤 Harfleri Keşfet!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 8),

                Text(
                  'Boyayarak harfleri aç ve kelimeleri öğren',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: AppConstants.paddingLarge),

                // Kelime kartı
                Expanded(
                  child: PageView.builder(
                    itemCount: words.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentWordIndex = index;
                        _discoveredLetters.clear();
                      });
                    },
                    itemBuilder: (context, index) {
                      final word = words[index];
                      return WordCard(
                        word: word.word,
                        meaning: word.meaning,
                        isDiscovered: word.isDiscovered,
                        discoveredLetters: _discoveredLetters,
                      )
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: 100 * index))
                          .slideX(begin: 0.1);
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Alt bilgi
                NeubrutalCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '📝 ${_currentWordIndex + 1} / ${words.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '🔤 ${_discoveredLetters.length} harf',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.buttonAccent,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Butonlar
                Row(
                  children: [
                    Expanded(
                      child: NeubrutalButton(
                        label: '🎯 İpucu Ver',
                        backgroundColor: AppColors.buttonAccent,
                        onPressed: () {
                          // Rastgele bir harf aç
                          if (words.isNotEmpty) {
                            final word = words[_currentWordIndex];
                            final undiscovered = word.word
                                .split('')
                                .where(
                                    (l) => !_discoveredLetters.contains(l))
                                .toList();
                            if (undiscovered.isNotEmpty) {
                              setState(() {
                                _discoveredLetters.add(
                                  undiscovered.first,
                                );
                              });
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: NeubrutalButton(
                        label: '✅ Tamamla',
                        backgroundColor: AppColors.buttonSecondary,
                        onPressed: () {
                          // Tüm harfleri aç
                          if (words.isNotEmpty) {
                            setState(() {
                              _discoveredLetters =
                                  words[_currentWordIndex].word.split('');
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Hata: $error')),
      ),
    );
  }
}
