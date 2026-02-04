// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderConfigAdapter extends TypeAdapter<ReminderConfig> {
  @override
  final int typeId = 3;

  @override
  ReminderConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReminderConfig(
      firstReminderDays: fields[0] as int,
      secondReminderDays: fields[1] as int,
      remindOnBillingDay: fields[2] as bool,
      reminderHour: fields[3] as int,
      reminderMinute: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderConfig obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.firstReminderDays)
      ..writeByte(1)
      ..write(obj.secondReminderDays)
      ..writeByte(2)
      ..write(obj.remindOnBillingDay)
      ..writeByte(3)
      ..write(obj.reminderHour)
      ..writeByte(4)
      ..write(obj.reminderMinute);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
