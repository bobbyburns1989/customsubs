# Data Models Reference

**Status**: ✅ Complete (v1.4.0)
**Last Updated**: March 2026

Complete HiveField definitions for all models. When adding fields, always use a new index — never reuse old ones.

---

## Subscription (typeId: 0)

```dart
@HiveType(typeId: 0)
class Subscription extends HiveObject {
  @HiveField(0)  final String id;               // UUID
  @HiveField(1)  final String name;              // "Netflix"
  @HiveField(2)  final double amount;            // 15.99
  @HiveField(3)  final String currencyCode;      // "USD", "EUR", "GBP", etc.
  @HiveField(4)  final SubscriptionCycle cycle;
  @HiveField(5)  final DateTime nextBillingDate;
  @HiveField(6)  final DateTime startDate;       // When user first subscribed
  @HiveField(7)  final SubscriptionCategory category;
  @HiveField(8)  final bool isActive;            // ⚠️ false = PAUSED (repurposed v1.2.0 — see ADR 004)
  @HiveField(9)  final bool isTrial;
  @HiveField(10) final DateTime? trialEndDate;
  @HiveField(11) final double? postTrialAmount;  // Amount after trial ends
  @HiveField(12) final String? cancelUrl;
  @HiveField(13) final String? cancelPhone;
  @HiveField(14) final String? cancelNotes;
  @HiveField(15) final List<String> cancelChecklist;
  @HiveField(16) final List<bool> checklistCompleted; // Parallel to cancelChecklist
  @HiveField(17) final String? notes;
  @HiveField(18) final String? iconName;         // Template icon key, null for custom
  @HiveField(19) final int colorValue;           // Stored as int, convert with Color(colorValue)
  @HiveField(20) final ReminderConfig reminders;
  @HiveField(21) final bool isPaid;              // Resets on billing date advance
  @HiveField(22) final DateTime? lastMarkedPaidDate;
  @HiveField(23) final DateTime? pausedDate;     // When paused (null if active)
  @HiveField(24) final DateTime? resumeDate;     // null = manual resume only
  @HiveField(25) final int pauseCount;           // Incremented each pause (available for analytics)

  // Convenience getters (NOT stored in Hive)
  bool get isPaused => !isActive;
  bool get isResumingSoon =>
      isPaused && resumeDate != null &&
      resumeDate!.difference(DateTime.now()).inDays <= 7;
  bool get shouldAutoResume =>
      isPaused && resumeDate != null && resumeDate!.isBefore(DateTime.now());
}
```

### ⚠️ `isActive` is the pause flag

`isActive = false` means **paused**, not deleted or inactive. This field was repurposed in v1.2.0 to avoid a Hive migration. See [ADR 004](../decisions/004-pause-feature-isactive-reuse.md). Never add a separate `isPaused` field.

### Next available HiveField index: 26

---

## SubscriptionCycle (typeId: 1)

```dart
@HiveType(typeId: 1)
enum SubscriptionCycle {
  @HiveField(0) weekly,
  @HiveField(1) biweekly,
  @HiveField(2) monthly,
  @HiveField(3) quarterly,
  @HiveField(4) biannual,
  @HiveField(5) yearly,
}
```

---

## SubscriptionCategory (typeId: 2)

```dart
@HiveType(typeId: 2)
enum SubscriptionCategory {
  @HiveField(0)  entertainment,  // Netflix, Spotify, Disney+
  @HiveField(1)  productivity,   // Notion, Todoist, Office 365
  @HiveField(2)  fitness,        // Gym, Peloton, MyFitnessPal
  @HiveField(3)  news,           // NYT, WSJ, Substack
  @HiveField(4)  cloud,          // iCloud, Google One, Dropbox
  @HiveField(5)  gaming,         // Xbox Game Pass, PS Plus
  @HiveField(6)  education,      // Coursera, Duolingo, Skillshare
  @HiveField(7)  finance,        // Mint, YNAB
  @HiveField(8)  shopping,       // Amazon Prime, Costco
  @HiveField(9)  utilities,      // Phone, internet, rent
  @HiveField(10) health,         // Insurance, telehealth
  @HiveField(11) other,
  @HiveField(12) sports,         // ESPN+, NBA League Pass, DAZN — added v1.4.3
}
```

---

## ReminderConfig (typeId: 3)

```dart
@HiveType(typeId: 3)
class ReminderConfig {
  @HiveField(0) final int firstReminderDays;   // Default: 7
  @HiveField(1) final int secondReminderDays;  // Default: 1
  @HiveField(2) final bool remindOnBillingDay; // Default: true
  @HiveField(3) final int reminderHour;        // Default: 9 (9 AM)
  @HiveField(4) final int reminderMinute;      // Default: 0
}
```

---

## Template JSON Format

`assets/data/subscription_templates.json` — 290 services bundled (as of March 2026).

```json
{
  "id": "netflix",
  "name": "Netflix",
  "defaultAmount": 17.99,
  "defaultCurrency": "USD",
  "defaultCycle": "monthly",
  "category": "entertainment",
  "cancelUrl": "https://www.netflix.com/cancelplan",
  "color": "0xFFE50914",
  "iconName": "netflix"
}
```

`iconName` is the primary lookup key for brand icons. Used by `ServiceIcons.getIconForIconName()` and `ServiceIcons.hasLocalLogo()`.

---

## Pause / Snooze System (v1.2.0)

Pause uses `isActive` (HiveField 8): `true` = active, `false` = paused.

### Repository Methods
- `pauseSubscription(id, {resumeDate})` — sets `isActive = false`, records `pausedDate`
- `resumeSubscription(id)` — sets `isActive = true`, clears `pausedDate` and `resumeDate`
- `getAllPaused()` — returns all where `isActive == false`
- `autoResumeSubscriptions()` — resumes all whose `resumeDate` has passed

### Auto-Resume Triggers (3 places)
1. App startup — `main.dart`
2. App foreground — `home_screen.dart` via `didChangeAppLifecycleState(resumed)`
3. Pull-to-refresh — `home_screen.dart`

### Effects While Paused
- Billing dates do NOT advance (`advanceOverdueBillingDates()` skips paused subs)
- Notifications are NOT scheduled (`scheduleNotificationsForSubscription()` skips paused subs)
- Sub does NOT appear in Upcoming or Later sections

---

## Mark as Paid System

- `isPaid` (HiveField 21) + `lastMarkedPaidDate` (HiveField 22)
- Set `isPaid = true` + `lastMarkedPaidDate = DateTime.now()` on tap
- Reset `isPaid = false` when `nextBillingDate` advances (via `advanceOverdueBillingDates()`)
- Paid subs show green "Paid" badge; sort to bottom of Upcoming list
- Use **optimistic state update** in `home_controller.dart` — do NOT call `refresh()` (causes skeleton flash)

---

## Hive TypeId Registry

| typeId | Model |
|--------|-------|
| 0 | Subscription |
| 1 | SubscriptionCycle |
| 2 | SubscriptionCategory |
| 3 | ReminderConfig |

Never reuse a typeId, even if a model is deleted.

---

## See Also

- `lib/data/models/` — actual model files
- `docs/architecture/data-layer.md` — Hive patterns, repository pattern, migrations
- `docs/decisions/004-pause-feature-isactive-reuse.md` — why `isActive` is reused
