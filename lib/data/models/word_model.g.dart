// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WordModelAdapter extends TypeAdapter<WordModel> {
  @override
  final int typeId = 2;

  @override
  WordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WordModel(
      id: fields[0] as String,
      word: fields[1] as String,
      meaning: fields[2] as String,
      category: fields[3] as String,
      imagePath: fields[4] as String,
      letters: (fields[5] as List).cast<String>(),
      isDiscovered: fields[6] as bool,
      discoveryCount: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WordModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.word)
      ..writeByte(2)
      ..write(obj.meaning)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.imagePath)
      ..writeByte(5)
      ..write(obj.letters)
      ..writeByte(6)
      ..write(obj.isDiscovered)
      ..writeByte(7)
      ..write(obj.discoveryCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
