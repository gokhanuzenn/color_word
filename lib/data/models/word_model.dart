import 'package:hive/hive.dart';

part 'word_model.g.dart';

@HiveType(typeId: 2)
class WordModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String word;

  @HiveField(2)
  final String meaning;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String imagePath;

  @HiveField(5)
  final List<String> letters;

  @HiveField(6)
  bool isDiscovered;

  @HiveField(7)
  int discoveryCount;

  WordModel({
    required this.id,
    required this.word,
    required this.meaning,
    required this.category,
    required this.imagePath,
    required this.letters,
    this.isDiscovered = false,
    this.discoveryCount = 0,
  });

  WordModel copyWith({
    String? id,
    String? word,
    String? meaning,
    String? category,
    String? imagePath,
    List<String>? letters,
    bool? isDiscovered,
    int? discoveryCount,
  }) {
    return WordModel(
      id: id ?? this.id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      letters: letters ?? this.letters,
      isDiscovered: isDiscovered ?? this.isDiscovered,
      discoveryCount: discoveryCount ?? this.discoveryCount,
    );
  }

  /// Kelimenin harflerini tek tek döndürür
  List<String> get individualLetters => word.split('');

  /// Benzersiz harfleri döndürür
  List<String> get uniqueLetters => word.split('').toSet().toList();
}
