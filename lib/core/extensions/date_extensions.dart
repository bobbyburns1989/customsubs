import 'package:intl/intl.dart';

/// DateTime extensions for subscription billing date calculations and formatting.
///
/// **Used throughout the app** for displaying billing dates, calculating cycles,
/// and determining when to show reminders.
///
/// ## Key Methods
/// - `toRelativeString()` - Human-readable relative dates ("in 3 days", "Tomorrow")
/// - `toShortRelativeString()` - Compact version for subscription tiles
/// - `addMonths()` - Correctly handles month overflow for billing cycles
/// - `daysUntil` - Calculate days until billing date
///
/// ## Usage Example
/// ```dart
/// final billingDate = DateTime(2024, 3, 15);
///
/// // Display in UI
/// Text(billingDate.toRelativeString());  // "in 12 days"
/// Text(billingDate.toShortFormattedString());  // "Mar 15"
///
/// // Check status
/// if (billingDate.isToday) {
///   // Show "billing today" badge
/// }
///
/// // Calculate next billing
/// final nextMonth = billingDate.addMonths(1);  // Apr 15, 2024
/// ```
extension DateTimeExtensions on DateTime {
  /// Converts a DateTime to a human-readable relative time string.
  ///
  /// **Primary display format** for billing dates throughout the app.
  ///
  /// ## Format Rules
  /// **Past dates:**
  /// - Today → "Today"
  /// - Yesterday → "Yesterday"
  /// - 2-6 days ago → "X days ago"
  /// - 7-29 days ago → "X weeks ago"
  /// - 30+ days ago → Formatted date (e.g., "Jan 15, 2024")
  ///
  /// **Future dates:**
  /// - Today → "Today"
  /// - Tomorrow → "Tomorrow"
  /// - 2-6 days → "in X days"
  /// - 7-29 days → "in X weeks"
  /// - 30-364 days → "in X months"
  /// - 365+ days → Formatted date (e.g., "Jan 15, 2025")
  ///
  /// ## Usage
  /// ```dart
  /// final billingDate = DateTime(2024, 3, 20);
  /// Text(billingDate.toRelativeString());  // "in 5 days" (if today is Mar 15)
  /// ```
  ///
  /// **Perfect for:** Subscription detail screens, analytics, anywhere you have space
  String toRelativeString() {
    final now = DateTime.now();
    final difference = this.difference(now);

    if (difference.isNegative) {
      // Past dates
      final absDiff = difference.abs();
      if (absDiff.inDays == 0) {
        return 'Today';
      } else if (absDiff.inDays == 1) {
        return 'Yesterday';
      } else if (absDiff.inDays < 7) {
        return '${absDiff.inDays} days ago';
      } else if (absDiff.inDays < 30) {
        final weeks = (absDiff.inDays / 7).floor();
        return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
      } else {
        return DateFormat.yMMMd().format(this);
      }
    } else {
      // Future dates
      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Tomorrow';
      } else if (difference.inDays < 7) {
        return 'in ${difference.inDays} days';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return weeks == 1 ? 'in 1 week' : 'in $weeks weeks';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return months == 1 ? 'in 1 month' : 'in $months months';
      } else {
        return DateFormat.yMMMd().format(this);
      }
    }
  }

  /// Converts a DateTime to a compact relative time string.
  ///
  /// **Use for subscription list tiles** where space is limited.
  ///
  /// ## Format Rules
  /// - Past → "Overdue" (red flag!)
  /// - Today → "Today"
  /// - Tomorrow → "Tomorrow"
  /// - 2-6 days → "in X days"
  /// - 7+ days → Formatted date (e.g., "Mar 15")
  ///
  /// ## Usage
  /// ```dart
  /// // In subscription list tile
  /// ListTile(
  ///   title: Text(subscription.name),
  ///   subtitle: Text(subscription.nextBillingDate.toShortRelativeString()),
  /// );
  /// ```
  ///
  /// **Perfect for:** List items, compact UI, mobile screens
  String toShortRelativeString() {
    final now = DateTime.now();
    final difference = this.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays < 7) {
      return 'in ${difference.inDays} days';
    } else {
      return DateFormat.MMMd().format(this);
    }
  }

  /// Format as "Jan 15, 2024"
  String toFormattedString() {
    return DateFormat.yMMMd().format(this);
  }

  /// Format as "January 15"
  String toShortFormattedString() {
    return DateFormat.MMMd().format(this);
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Check if date is in the past
  bool get isPast {
    return isBefore(DateTime.now());
  }

  /// Check if date is in the future
  bool get isFuture {
    return isAfter(DateTime.now());
  }

  /// Get start of day (00:00:00)
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get end of day (23:59:59)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Adds months to a date, correctly handling month/day overflow.
  ///
  /// **Critical for calculating next billing dates** in monthly/quarterly/biannual cycles.
  ///
  /// ## Edge Case Handling
  /// Handles month-end dates gracefully:
  /// - Jan 31 + 1 month = Feb 28 (or 29 in leap years)
  /// - Jan 31 + 2 months = Mar 31
  /// - Jan 31 + 13 months = Feb 28 next year
  ///
  /// ## Usage
  /// ```dart
  /// final billingDate = DateTime(2024, 1, 31);
  ///
  /// // Calculate next monthly billing
  /// final nextMonth = billingDate.addMonths(1);  // Feb 29, 2024 (leap year!)
  ///
  /// // Calculate quarterly billing
  /// final nextQuarter = billingDate.addMonths(3);  // Apr 30, 2024
  ///
  /// // Calculate yearly billing
  /// final nextYear = billingDate.addMonths(12);  // Jan 31, 2025
  /// ```
  ///
  /// **Why not just use Duration?**
  /// `Duration(days: 30)` doesn't account for month length variations.
  /// This method ensures "same day next month" semantics.
  ///
  /// **Used by:** Subscription.calculateNextBillingDate(), billing cycle calculations
  DateTime addMonths(int months) {
    final newMonth = month + months;
    final yearsToAdd = (newMonth - 1) ~/ 12;
    final finalMonth = ((newMonth - 1) % 12) + 1;

    // Handle day overflow (e.g., Jan 31 + 1 month = Feb 28/29)
    final newYear = year + yearsToAdd;
    final daysInTargetMonth = DateTime(newYear, finalMonth + 1, 0).day;
    final finalDay = day > daysInTargetMonth ? daysInTargetMonth : day;

    return DateTime(
      newYear,
      finalMonth,
      finalDay,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  /// Get the number of days until this date
  int get daysUntil {
    final now = DateTime.now();
    return difference(now).inDays;
  }

  /// Get the number of days since this date
  int get daysSince {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }

  /// Get human-readable string for days until this date ("in 3 days", "Tomorrow", "Today", etc.)
  String relativeDaysUntil() {
    final now = DateTime.now();
    final difference = this.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays < 7) {
      return 'in ${difference.inDays} days';
    } else {
      return 'in ${difference.inDays} days';
    }
  }
}
