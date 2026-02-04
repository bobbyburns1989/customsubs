import 'package:hive/hive.dart';

part 'subscription_category.g.dart';

@HiveType(typeId: 2)
enum SubscriptionCategory {
  @HiveField(0)
  entertainment, // Netflix, Spotify, Disney+

  @HiveField(1)
  productivity, // Notion, Todoist, Office 365

  @HiveField(2)
  fitness, // Gym, Peloton, MyFitnessPal

  @HiveField(3)
  news, // NYT, WSJ, Substack

  @HiveField(4)
  cloud, // iCloud, Google One, Dropbox

  @HiveField(5)
  gaming, // Xbox Game Pass, PS Plus

  @HiveField(6)
  education, // Coursera, Duolingo, Skillshare

  @HiveField(7)
  finance, // Mint, YNAB

  @HiveField(8)
  shopping, // Amazon Prime, Costco

  @HiveField(9)
  utilities, // Phone, internet, rent

  @HiveField(10)
  health, // Insurance, telehealth

  @HiveField(11)
  other;

  String get displayName {
    switch (this) {
      case SubscriptionCategory.entertainment:
        return 'Entertainment';
      case SubscriptionCategory.productivity:
        return 'Productivity';
      case SubscriptionCategory.fitness:
        return 'Fitness';
      case SubscriptionCategory.news:
        return 'News';
      case SubscriptionCategory.cloud:
        return 'Cloud Storage';
      case SubscriptionCategory.gaming:
        return 'Gaming';
      case SubscriptionCategory.education:
        return 'Education';
      case SubscriptionCategory.finance:
        return 'Finance';
      case SubscriptionCategory.shopping:
        return 'Shopping';
      case SubscriptionCategory.utilities:
        return 'Utilities';
      case SubscriptionCategory.health:
        return 'Health';
      case SubscriptionCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case SubscriptionCategory.entertainment:
        return '🎬';
      case SubscriptionCategory.productivity:
        return '💼';
      case SubscriptionCategory.fitness:
        return '💪';
      case SubscriptionCategory.news:
        return '📰';
      case SubscriptionCategory.cloud:
        return '☁️';
      case SubscriptionCategory.gaming:
        return '🎮';
      case SubscriptionCategory.education:
        return '📚';
      case SubscriptionCategory.finance:
        return '💰';
      case SubscriptionCategory.shopping:
        return '🛒';
      case SubscriptionCategory.utilities:
        return '🏠';
      case SubscriptionCategory.health:
        return '🏥';
      case SubscriptionCategory.other:
        return '📦';
    }
  }
}
