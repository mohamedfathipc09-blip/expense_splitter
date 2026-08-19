// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArchiveModelAdapter extends TypeAdapter<ArchiveModel> {
  @override
  final int typeId = 1;

  @override
  ArchiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArchiveModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      totalAmount: fields[2] as double,
      settlementSummary: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ArchiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.totalAmount)
      ..writeByte(3)
      ..write(obj.settlementSummary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArchiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
