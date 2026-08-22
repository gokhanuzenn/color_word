// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coloring_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ColoringItemModelAdapter extends TypeAdapter<ColoringItemModel> {
  @override
  final int typeId = 3;

  @override
  ColoringItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ColoringItemModel(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      imagePath: fields[3] as String,
      associatedWords: (fields[4] as List).cast<String>(),
      associatedLetters: (fields[5] as List).cast<String>(),
      isCompleted: fields[6] as bool,
      completionPercentage: fields[7] as double,
      coloredRegions: (fields[8] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ColoringItemModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.associatedWords)
      ..writeByte(5)
      ..write(obj.associatedLetters)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.completionPercentage)
      ..writeByte(8)
      ..write(obj.coloredRegions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColoringItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
