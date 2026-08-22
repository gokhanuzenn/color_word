// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProgressModelAdapter extends TypeAdapter<UserProgressModel> {
  @override
  final int typeId = 4;

  @override
  UserProgressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProgressModel(
      totalWordsDiscovered: fields[0] as int,
      totalLettersLearned: fields[1] as int,
      totalColoringsCompleted: fields[2] as int,
      totalPlayTimeSeconds: fields[3] as int,
      categoryProgress: (fields[4] as Map?)?.cast<String, int>(),
      discoveredWords: (fields[5] as List?)?.cast<String>(),
      learnedLetters: (fields[6] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProgressModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.totalWordsDiscovered)
      ..writeByte(1)
      ..write(obj.totalLettersLearned)
      ..writeByte(2)
      ..write(obj.totalColoringsCompleted)
      ..writeByte(3)
      ..write(obj.totalPlayTimeSeconds)
      ..writeByte(4)
      ..write(obj.categoryProgress)
      ..writeByte(5)
      ..write(obj.discoveredWords)
      ..writeByte(6)
      ..write(obj.learnedLetters);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProgressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
