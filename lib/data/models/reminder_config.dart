import 'package:hive/hive.dart';

part 'reminder_config.g.dart';

@HiveType(typeId: 3)
class ReminderConfig extends HiveObject {
  @HiveField(0)
  final int firstReminderDays; // Default: 7

  @HiveField(1)
  final int secondReminderDays; // Default: 1

  @HiveField(2)
  final bool remindOnBillingDay; // Default: true

  @HiveField(3)
  final int reminderHour; // Default: 9 (9 AM)

  @HiveField(4)
  final int reminderMinute; // Default: 0

  ReminderConfig({
    this.firstReminderDays = 7,
    this.secondReminderDays = 1,
    this.remindOnBillingDay = true,
    this.reminderHour = 9,
    this.reminderMinute = 0,
  });

  ReminderConfig copyWith({
    int? firstReminderDays,
    int? secondReminderDays,
    bool? remindOnBillingDay,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return ReminderConfig(
      firstReminderDays: firstReminderDays ?? this.firstReminderDays,
      secondReminderDays: secondReminderDays ?? this.secondReminderDays,
      remindOnBillingDay: remindOnBillingDay ?? this.remindOnBillingDay,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }

  static ReminderConfig defaultConfig() {
    return ReminderConfig();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReminderConfig &&
        other.firstReminderDays == firstReminderDays &&
        other.secondReminderDays == secondReminderDays &&
        other.remindOnBillingDay == remindOnBillingDay &&
        other.reminderHour == reminderHour &&
        other.reminderMinute == reminderMinute;
  }

  @override
  int get hashCode {
    return Object.hash(
      firstReminderDays,
      secondReminderDays,
      remindOnBillingDay,
      reminderHour,
      reminderMinute,
    );
  }

  /// Convert to JSON for backup export
  Map<String, dynamic> toJson() {
    return {
      'firstReminderDays': firstReminderDays,
      'secondReminderDays': secondReminderDays,
      'remindOnBillingDay': remindOnBillingDay,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
    };
  }

  /// Create from JSON for backup import
  factory ReminderConfig.fromJson(Map<String, dynamic> json) {
    return ReminderConfig(
      firstReminderDays: json['firstReminderDays'] as int? ?? 7,
      secondReminderDays: json['secondReminderDays'] as int? ?? 1,
      remindOnBillingDay: json['remindOnBillingDay'] as bool? ?? true,
      reminderHour: json['reminderHour'] as int? ?? 9,
      reminderMinute: json['reminderMinute'] as int? ?? 0,
    );
  }
}
