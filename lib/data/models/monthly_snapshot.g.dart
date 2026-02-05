// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_snapshot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonthlySnapshotAdapter extends TypeAdapter<MonthlySnapshot> {
  @override
  final int typeId = 4;

  @override
  MonthlySnapshot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonthlySnapshot(
      month: fields[0] as String,
      totalMonthlySpend: fields[1] as double,
      currencyCode: fields[2] as String,
      snapshotDate: fields[3] as DateTime,
      activeSubscriptionCount: fields[4] as int,
      categoryTotals: (fields[5] as Map).cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, MonthlySnapshot obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.month)
      ..writeByte(1)
      ..write(obj.totalMonthlySpend)
      ..writeByte(2)
      ..write(obj.currencyCode)
      ..writeByte(3)
      ..write(obj.snapshotDate)
      ..writeByte(4)
      ..write(obj.activeSubscriptionCount)
      ..writeByte(5)
      ..write(obj.categoryTotals);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlySnapshotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
