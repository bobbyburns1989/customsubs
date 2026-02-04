// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionAdapter extends TypeAdapter<Subscription> {
  @override
  final int typeId = 0;

  @override
  Subscription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subscription(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: fields[2] as double,
      currencyCode: fields[3] as String,
      cycle: fields[4] as SubscriptionCycle,
      nextBillingDate: fields[5] as DateTime,
      startDate: fields[6] as DateTime,
      category: fields[7] as SubscriptionCategory,
      isActive: fields[8] as bool,
      isTrial: fields[9] as bool,
      trialEndDate: fields[10] as DateTime?,
      postTrialAmount: fields[11] as double?,
      cancelUrl: fields[12] as String?,
      cancelPhone: fields[13] as String?,
      cancelNotes: fields[14] as String?,
      cancelChecklist: (fields[15] as List).cast<String>(),
      checklistCompleted: (fields[16] as List).cast<bool>(),
      notes: fields[17] as String?,
      iconName: fields[18] as String?,
      colorValue: fields[19] as int,
      reminders: fields[20] as ReminderConfig,
      isPaid: fields[21] as bool,
      lastMarkedPaidDate: fields[22] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Subscription obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.currencyCode)
      ..writeByte(4)
      ..write(obj.cycle)
      ..writeByte(5)
      ..write(obj.nextBillingDate)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.isTrial)
      ..writeByte(10)
      ..write(obj.trialEndDate)
      ..writeByte(11)
      ..write(obj.postTrialAmount)
      ..writeByte(12)
      ..write(obj.cancelUrl)
      ..writeByte(13)
      ..write(obj.cancelPhone)
      ..writeByte(14)
      ..write(obj.cancelNotes)
      ..writeByte(15)
      ..write(obj.cancelChecklist)
      ..writeByte(16)
      ..write(obj.checklistCompleted)
      ..writeByte(17)
      ..write(obj.notes)
      ..writeByte(18)
      ..write(obj.iconName)
      ..writeByte(19)
      ..write(obj.colorValue)
      ..writeByte(20)
      ..write(obj.reminders)
      ..writeByte(21)
      ..write(obj.isPaid)
      ..writeByte(22)
      ..write(obj.lastMarkedPaidDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
