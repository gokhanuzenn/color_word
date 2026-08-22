import 'package:hive/hive.dart';

part 'coloring_item_model.g.dart';

@HiveType(typeId: 3)
class ColoringItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String imagePath;

  @HiveField(4)
  final List<String> associatedWords;

  @HiveField(5)
  final List<String> associatedLetters;

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  double completionPercentage;

  @HiveField(8)
  List<String> coloredRegions;

  ColoringItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.imagePath,
    required this.associatedWords,
    required this.associatedLetters,
    this.isCompleted = false,
    this.completionPercentage = 0.0,
    this.coloredRegions = const [],
  });

  ColoringItemModel copyWith({
    String? id,
    String? name,
    String? category,
    String? imagePath,
    List<String>? associatedWords,
    List<String>? associatedLetters,
    bool? isCompleted,
    double? completionPercentage,
    List<String>? coloredRegions,
  }) {
    return ColoringItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      associatedWords: associatedWords ?? this.associatedWords,
      associatedLetters: associatedLetters ?? this.associatedLetters,
      isCompleted: isCompleted ?? this.isCompleted,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      coloredRegions: coloredRegions ?? this.coloredRegions,
    );
  }

  /// İlerleme yüzdesini günceller
  void updateProgress(double percentage) {
    completionPercentage = percentage.clamp(0.0, 1.0);
    isCompleted = completionPercentage >= 1.0;
    save();
  }
}
