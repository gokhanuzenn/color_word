import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 0)
enum CategoryType {
  @HiveField(0)
  space,
  @HiveField(1)
  animals,
  @HiveField(2)
  food,
  @HiveField(3)
  nature,
  @HiveField(4)
  vehicles,
}

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final CategoryType type;

  @HiveField(3)
  final String iconPath;

  @HiveField(4)
  final String colorHex;

  @HiveField(5)
  final int totalItems;

  @HiveField(6)
  int completedItems;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.iconPath,
    required this.colorHex,
    required this.totalItems,
    this.completedItems = 0,
  });

  double get progress =>
      totalItems > 0 ? completedItems / totalItems : 0.0;

  bool get isCompleted => completedItems >= totalItems;

  CategoryModel copyWith({
    String? id,
    String? name,
    CategoryType? type,
    String? iconPath,
    String? colorHex,
    int? totalItems,
    int? completedItems,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconPath: iconPath ?? this.iconPath,
      colorHex: colorHex ?? this.colorHex,
      totalItems: totalItems ?? this.totalItems,
      completedItems: completedItems ?? this.completedItems,
    );
  }
}
