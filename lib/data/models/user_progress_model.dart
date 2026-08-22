import 'package:hive/hive.dart';

part 'user_progress_model.g.dart';

@HiveType(typeId: 4)
class UserProgressModel extends HiveObject {
  @HiveField(0)
  int totalWordsDiscovered;

  @HiveField(1)
  int totalLettersLearned;

  @HiveField(2)
  int totalColoringsCompleted;

  @HiveField(3)
  int totalPlayTimeSeconds;

  @HiveField(4)
  Map<String, int> categoryProgress;

  @HiveField(5)
  List<String> discoveredWords;

  @HiveField(6)
  List<String> learnedLetters;

  UserProgressModel({
    this.totalWordsDiscovered = 0,
    this.totalLettersLearned = 0,
    this.totalColoringsCompleted = 0,
    this.totalPlayTimeSeconds = 0,
    Map<String, int>? categoryProgress,
    List<String>? discoveredWords,
    List<String>? learnedLetters,
  })  : categoryProgress = categoryProgress ?? {},
        discoveredWords = discoveredWords ?? [],
        learnedLetters = learnedLetters ?? [];

  /// Yeni kelime keşfedildiğinde güncelle
  void discoverWord(String wordId) {
    if (!discoveredWords.contains(wordId)) {
      discoveredWords.add(wordId);
      totalWordsDiscovered++;
      save();
    }
  }

  /// Yeni harf öğrenildiğinde güncelle
  void learnLetter(String letter) {
    if (!learnedLetters.contains(letter.toLowerCase())) {
      learnedLetters.add(letter.toLowerCase());
      totalLettersLearned++;
      save();
    }
  }

  /// Kategoride ilerleme kaydet
  void updateCategoryProgress(String category, int progress) {
    categoryProgress[category] = progress;
    save();
  }

  /// Boyama tamamlandığında güncelle
  void completeColoring() {
    totalColoringsCompleted++;
    save();
  }

  /// Toplam oyun süresini güncelle
  void addPlayTime(int seconds) {
    totalPlayTimeSeconds += seconds;
    save();
  }

  UserProgressModel copyWith({
    int? totalWordsDiscovered,
    int? totalLettersLearned,
    int? totalColoringsCompleted,
    int? totalPlayTimeSeconds,
    Map<String, int>? categoryProgress,
    List<String>? discoveredWords,
    List<String>? learnedLetters,
  }) {
    return UserProgressModel(
      totalWordsDiscovered: totalWordsDiscovered ?? this.totalWordsDiscovered,
      totalLettersLearned: totalLettersLearned ?? this.totalLettersLearned,
      totalColoringsCompleted:
          totalColoringsCompleted ?? this.totalColoringsCompleted,
      totalPlayTimeSeconds:
          totalPlayTimeSeconds ?? this.totalPlayTimeSeconds,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      discoveredWords: discoveredWords ?? this.discoveredWords,
      learnedLetters: learnedLetters ?? this.learnedLetters,
    );
  }
}
