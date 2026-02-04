// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_cycle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionCycleAdapter extends TypeAdapter<SubscriptionCycle> {
  @override
  final int typeId = 1;

  @override
  SubscriptionCycle read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SubscriptionCycle.weekly;
      case 1:
        return SubscriptionCycle.biweekly;
      case 2:
        return SubscriptionCycle.monthly;
      case 3:
        return SubscriptionCycle.quarterly;
      case 4:
        return SubscriptionCycle.biannual;
      case 5:
        return SubscriptionCycle.yearly;
      default:
        return SubscriptionCycle.weekly;
    }
  }

  @override
  void write(BinaryWriter writer, SubscriptionCycle obj) {
    switch (obj) {
      case SubscriptionCycle.weekly:
        writer.writeByte(0);
        break;
      case SubscriptionCycle.biweekly:
        writer.writeByte(1);
        break;
      case SubscriptionCycle.monthly:
        writer.writeByte(2);
        break;
      case SubscriptionCycle.quarterly:
        writer.writeByte(3);
        break;
      case SubscriptionCycle.biannual:
        writer.writeByte(4);
        break;
      case SubscriptionCycle.yearly:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionCycleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
