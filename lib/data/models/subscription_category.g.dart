// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionCategoryAdapter extends TypeAdapter<SubscriptionCategory> {
  @override
  final int typeId = 2;

  @override
  SubscriptionCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SubscriptionCategory.entertainment;
      case 1:
        return SubscriptionCategory.productivity;
      case 2:
        return SubscriptionCategory.fitness;
      case 3:
        return SubscriptionCategory.news;
      case 4:
        return SubscriptionCategory.cloud;
      case 5:
        return SubscriptionCategory.gaming;
      case 6:
        return SubscriptionCategory.education;
      case 7:
        return SubscriptionCategory.finance;
      case 8:
        return SubscriptionCategory.shopping;
      case 9:
        return SubscriptionCategory.utilities;
      case 10:
        return SubscriptionCategory.health;
      case 11:
        return SubscriptionCategory.other;
      default:
        return SubscriptionCategory.entertainment;
    }
  }

  @override
  void write(BinaryWriter writer, SubscriptionCategory obj) {
    switch (obj) {
      case SubscriptionCategory.entertainment:
        writer.writeByte(0);
        break;
      case SubscriptionCategory.productivity:
        writer.writeByte(1);
        break;
      case SubscriptionCategory.fitness:
        writer.writeByte(2);
        break;
      case SubscriptionCategory.news:
        writer.writeByte(3);
        break;
      case SubscriptionCategory.cloud:
        writer.writeByte(4);
        break;
      case SubscriptionCategory.gaming:
        writer.writeByte(5);
        break;
      case SubscriptionCategory.education:
        writer.writeByte(6);
        break;
      case SubscriptionCategory.finance:
        writer.writeByte(7);
        break;
      case SubscriptionCategory.shopping:
        writer.writeByte(8);
        break;
      case SubscriptionCategory.utilities:
        writer.writeByte(9);
        break;
      case SubscriptionCategory.health:
        writer.writeByte(10);
        break;
      case SubscriptionCategory.other:
        writer.writeByte(11);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
