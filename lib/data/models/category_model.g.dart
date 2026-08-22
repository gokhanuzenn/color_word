// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 1;

  @override
  CategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryModel(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as CategoryType,
      iconPath: fields[3] as String,
      colorHex: fields[4] as String,
      totalItems: fields[5] as int,
      completedItems: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.iconPath)
      ..writeByte(4)
      ..write(obj.colorHex)
      ..writeByte(5)
      ..write(obj.totalItems)
      ..writeByte(6)
      ..write(obj.completedItems);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CategoryTypeAdapter extends TypeAdapter<CategoryType> {
  @override
  final int typeId = 0;

  @override
  CategoryType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CategoryType.space;
      case 1:
        return CategoryType.animals;
      case 2:
        return CategoryType.food;
      case 3:
        return CategoryType.nature;
      case 4:
        return CategoryType.vehicles;
      default:
        return CategoryType.space;
    }
  }

  @override
  void write(BinaryWriter writer, CategoryType obj) {
    switch (obj) {
      case CategoryType.space:
        writer.writeByte(0);
        break;
      case CategoryType.animals:
        writer.writeByte(1);
        break;
      case CategoryType.food:
        writer.writeByte(2);
        break;
      case CategoryType.nature:
        writer.writeByte(3);
        break;
      case CategoryType.vehicles:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
