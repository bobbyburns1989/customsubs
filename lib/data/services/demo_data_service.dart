import 'package:uuid/uuid.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/models/reminder_config.dart';

/// Service for generating and identifying demo subscriptions.
///
/// Demo subscriptions are tagged with [demoTag] in the notes field
/// so they can be identified and bulk-removed without affecting
/// real user data. All dates are computed relative to today so
/// demo data always looks fresh regardless of when it's loaded.
class DemoDataService {
  DemoDataService._(); // Prevent instantiation

  /// Tag inserted into [Subscription.notes] to identify demo entries.
  static const String demoTag = '[DEMO]';

  /// Returns true if [sub] was created by [generateDemoSubscriptions].
  static bool isDemoSubscription(Subscription sub) {
    return sub.notes?.contains(demoTag) ?? false;
  }

  /// Generates 18 realistic demo subscriptions covering:
  /// - 10 of 13 categories
  /// - 3 billing cycles (weekly, monthly, yearly)
  /// - All 3 icon tiers (SimpleIcons, local SVG, letter avatar)
  /// - Edge cases: trial, paused w/ auto-resume, already paid,
  ///   billing today, "Later" section entries (31-90 days out)
  static List<Subscription> generateDemoSubscriptions() {
    const uuid = Uuid();
    final now = DateTime.now();
    // Strip time component per project date-comparison rules
    final today = DateTime(now.year, now.month, now.day);

    return [
      // 1. Netflix — SimpleIcons, billing tomorrow
      Subscription(
        id: uuid.v4(),
        name: 'Netflix',
        amount: 17.99,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.monthly,
        nextBillingDate: today.add(const Duration(days: 1)),
        startDate: today.subtract(const Duration(days: 60)),
        category: SubscriptionCategory.entertainment,
        colorValue: 0xFFE50914,
        reminders: ReminderConfig(),
        iconName: 'netflix',
        notes: demoTag,
      ),

      // 2. Spotify — SimpleIcons, billing in 3 days
      Subscription(
        id: uuid.v4(),
        name: 'Spotify',
        amount: 12.99,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.monthly,
        nextBillingDate: today.add(const Duration(days: 3)),
        startDate: today.subtract(const Duration(days: 90)),
        category: SubscriptionCategory.entertainment,
        colorValue: 0xFF1DB954,
        reminders: ReminderConfig(),
        iconName: 'spotify',
        notes: demoTag,
      ),

      // 3. Disney+ — local SVG icon, billing in 7 days
      Subscription(
        id: uuid.v4(),
        name: 'Disney+',
        amount: 11.99,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.monthly,
        nextBillingDate: today.add(const Duration(days: 7)),
        startDate: today.subtract(const Duration(days: 120)),
        category: SubscriptionCategory.entertainment,
        colorValue: 0xFF113CCF,
        reminders: ReminderConfig(),
        iconName: 'disney',
        notes: demoTag,
      ),

      // 4. iCloud+ 2TB — cloud category, billing in 14 days
      Subscription(
        id: uuid.v4(),
        name: 'iCloud+ 2TB',
        amount: 9.99,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.monthly,
        nextBillingDate: today.add(const Duration(days: 14)),
        startDate: today.subtract(const Duration(days: 365)),
        category: SubscriptionCategory.cloud,
        colorValue: 0xFF3B82F6,
        reminders: ReminderConfig(),
        iconName: 'icloud',
        notes: demoTag,
      ),

      // 5. ChatGPT Plus — AI/productivity, billing in 5 days
      Subscription(
        id: uuid.v4(),
        name: 'ChatGPT Plus',
        amount: 20.00,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.monthly,
        nextBillingDate: today.add(const Duration(days: 5)),
        startDate: today.subtract(const Duration(days: 180)),
        category: SubscriptionCategory.productivity,
        colorValue: 0xFF10A37F,
        reminders: ReminderConfig(),
        iconName: 'chatgpt',
        notes: demoTag,
      ),

      // 6. Xbox Game Pass — local SVG, gaming category, billing in 21 days
      Subscription(
        id: uuid.v4(),
        name: 'Xbox Game Pass',
        amount: 19.99,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.monthly,
        nextBillingDate: today.add(const Duration(days: 21)),
        startDate: today.subtract(const Duration(days: 150)),
        category: SubscriptionCategory.gaming,
        colorValue: 0xFF107C10,
        reminders: ReminderConfig(),
        iconName: 'xbox',
        notes: demoTag,
      ),

      // 7. Gym Membership — letter avatar fallback (no icon), fitness, billing in 10 days
      Subscription(
        id: uuid.v4(),
        name: 'Gym Membership',
        amount: 49.99,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.monthly,
        nextBillingDate: today.add(const Duration(days: 10)),
        startDate: today.subtract(const Duration(days: 200)),
        category: SubscriptionCategory.fitness,
        colorValue: 0xFF84CC16,
        reminders: ReminderConfig(),
        iconName: 'gym',
        notes: demoTag,
      ),

      // 8. NYT Digital — weekly cycle, news category, billing in 2 days
      Subscription(
        id: uuid.v4(),
        name: 'NYT Digital',
        amount: 4.25,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.weekly,
        nextBillingDate: today.add(const Duration(days: 2)),
        startDate: today.subtract(const Duration(days: 365)),
        category: SubscriptionCategory.news,
        colorValue: 0xFF000000,
        reminders: ReminderConfig(),
        iconName: 'nyt',
        notes: demoTag,
      ),

      // 9. Adobe CC — local SVG, expensive, productivity, billing in 28 days
      Subscription(
        id: uuid.v4(),
        name: 'Adobe Creative Cloud',
        amount: 59.99,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.monthly,
        nextBillingDate: today.add(const Duration(days: 28)),
        startDate: today.subtract(const Duration(days: 730)),
        category: SubscriptionCategory.productivity,
        colorValue: 0xFFDA1F26,
        reminders: ReminderConfig(),
        iconName: 'adobe',
        notes: demoTag,
      ),

      // 10. Amazon Prime — shopping category, billing in 12 days
      Subscription(
        id: uuid.v4(),
        name: 'Amazon Prime',
        amount: 14.99,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.monthly,
        nextBillingDate: today.add(const Duration(days: 12)),
        startDate: today.subtract(const Duration(days: 400)),
        category: SubscriptionCategory.shopping,
        colorValue: 0xFFFF9900,
        reminders: ReminderConfig(),
        iconName: 'amazon',
        notes: demoTag,
      ),

      // 11. Duolingo Plus — yearly cycle, education, billing in 45 days ("Later" section)
      Subscription(
        id: uuid.v4(),
        name: 'Duolingo Plus',
        amount: 83.99,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.yearly,
        nextBillingDate: today.add(const Duration(days: 45)),
        startDate: today.subtract(const Duration(days: 320)),
        category: SubscriptionCategory.education,
        colorValue: 0xFF58CC02,
        reminders: ReminderConfig(),
        iconName: 'duolingo',
        notes: demoTag,
      ),

      // 12. Claude Pro — billing today (0 days out), tests "Today" badge
      Subscription(
        id: uuid.v4(),
        name: 'Claude Pro',
        amount: 20.00,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.monthly,
        nextBillingDate: today,
        startDate: today.subtract(const Duration(days: 90)),
        category: SubscriptionCategory.productivity,
        colorValue: 0xFFCC785C,
        reminders: ReminderConfig(),
        iconName: 'claude',
        notes: demoTag,
      ),

      // 13. NordVPN — already marked as paid for this cycle
      Subscription(
        id: uuid.v4(),
        name: 'NordVPN',
        amount: 12.99,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.monthly,
        nextBillingDate: today.add(const Duration(days: 18)),
        startDate: today.subtract(const Duration(days: 240)),
        category: SubscriptionCategory.utilities,
        colorValue: 0xFF4687FF,
        reminders: ReminderConfig(),
        iconName: 'nordvpn',
        isPaid: true,
        lastMarkedPaidDate: today,
        notes: demoTag,
      ),

      // 14. ESPN+ — sports category, billing in 8 days
      Subscription(
        id: uuid.v4(),
        name: 'ESPN+',
        amount: 11.99,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.monthly,
        nextBillingDate: today.add(const Duration(days: 8)),
        startDate: today.subtract(const Duration(days: 100)),
        category: SubscriptionCategory.sports,
        colorValue: 0xFFFF0033,
        reminders: ReminderConfig(),
        iconName: 'espn',
        notes: demoTag,
      ),

      // 15. Hulu — active trial, converts in 5 days, tests trial badge
      Subscription(
        id: uuid.v4(),
        name: 'Hulu',
        amount: 0.00,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.monthly,
        nextBillingDate: today.add(const Duration(days: 5)),
        startDate: today.subtract(const Duration(days: 2)),
        category: SubscriptionCategory.entertainment,
        colorValue: 0xFF1CE783,
        reminders: ReminderConfig(),
        iconName: 'hulu',
        isTrial: true,
        trialEndDate: today.add(const Duration(days: 5)),
        postTrialAmount: 11.99,
        notes: demoTag,
      ),

      // 16. T-Mobile — no iconName (letter avatar fallback), utilities
      Subscription(
        id: uuid.v4(),
        name: 'T-Mobile',
        amount: 75.00,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.monthly,
        nextBillingDate: today.add(const Duration(days: 15)),
        startDate: today.subtract(const Duration(days: 500)),
        category: SubscriptionCategory.utilities,
        colorValue: 0xFFE20074,
        reminders: ReminderConfig(),
        notes: demoTag,
      ),

      // 17. Notion — paused with auto-resume in 16 days, tests paused section
      Subscription(
        id: uuid.v4(),
        name: 'Notion',
        amount: 10.00,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.monthly,
        nextBillingDate: today.add(const Duration(days: 16)),
        startDate: today.subtract(const Duration(days: 300)),
        category: SubscriptionCategory.productivity,
        colorValue: 0xFF000000,
        reminders: ReminderConfig(),
        iconName: 'notion',
        isActive: false,
        pausedDate: today.subtract(const Duration(days: 14)),
        resumeDate: today.add(const Duration(days: 16)),
        pauseCount: 1,
        notes: demoTag,
      ),

      // 18. Costco — yearly cycle, shopping, billing in 70 days ("Later" section)
      Subscription(
        id: uuid.v4(),
        name: 'Costco Gold Star',
        amount: 65.00,
        currencyCode: 'USD',
        cycle: SubscriptionCycle.yearly,
        nextBillingDate: today.add(const Duration(days: 70)),
        startDate: today.subtract(const Duration(days: 295)),
        category: SubscriptionCategory.shopping,
        colorValue: 0xFF0063A6,
        reminders: ReminderConfig(),
        iconName: 'costco',
        notes: demoTag,
      ),
    ];
  }
}
