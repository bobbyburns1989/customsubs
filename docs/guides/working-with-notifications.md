# Working with Notifications

**⚠️ CRITICAL: This is the #1 feature of CustomSubs.**

Reliable notifications are the app's primary value proposition. This guide explains how to implement, schedule, and test notifications correctly.

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Initialization](#initialization)
4. [Scheduling Notifications](#scheduling-notifications)
5. [Notification Types](#notification-types)
6. [Notification ID Strategy](#notification-id-strategy)
7. [Testing Notifications](#testing-notifications)
8. [Platform Differences](#platform-differences)
9. [Common Issues & Solutions](#common-issues--solutions)
10. [Critical Rules](#critical-rules)

---

## Overview

### Why Notifications Matter

CustomSubs's primary competitor (Bobby) has a 4.7★ rating but suffers from **broken notifications**. Users frequently complain that reminders don't fire. **This is our opportunity to win.**

Our notification system must be:
- **Reliable** - Notifications fire 100% of the time
- **Accurate** - Scheduled at the correct date/time
- **Persistent** - Survive app restarts and device reboots
- **Testable** - Easy to verify they work

### Key Components

1. **NotificationService** (`lib/data/services/notification_service.dart`) - Handles all notification operations
2. **flutter_local_notifications** - Platform-specific notification API
3. **timezone** package - Ensures notifications fire at correct local time
4. **ReminderConfig** model - User-configurable reminder settings

---

## Architecture

### Notification Flow

```
User saves subscription
    ↓
SubscriptionRepository.upsert()
    ↓
NotificationService.scheduleNotificationsForSubscription()
    ↓
1. Cancel existing notifications (deterministic IDs)
    ↓
2. Schedule new notifications based on ReminderConfig
    ↓
3. Use TZDateTime for timezone-aware scheduling
    ↓
4. Set AndroidScheduleMode.exactAllowWhileIdle for reliability
```

### Three Notification Sets

**Regular Subscriptions:**
- First reminder (default: 7 days before billing)
- Second reminder (default: 1 day before billing)
- Day-of reminder (morning of billing date)

**Free Trials:**
- 3 days before trial ends
- 1 day before trial ends
- Morning of trial end date

---

## Initialization

### When to Initialize

Initialize NotificationService in `main.dart` **before** `runApp()`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  // ... register adapters ...

  // Initialize NotificationService
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const CustomSubsApp(),
    ),
  );
}
```

### What init() Does

From `notification_service.dart:15-53`:

1. **Initialize timezone data** - Required for TZDateTime
2. **Configure Android settings** - Uses app icon for notifications
3. **Configure iOS settings** - Permissions requested separately
4. **Create notification channel** (Android) - ID: `customsubs_reminders`, Importance: Max

**Critical:** Without `tz.initializeTimeZones()`, all scheduled notifications will fail silently.

---

## Scheduling Notifications

### The One Method You Need

```dart
Future<void> scheduleNotificationsForSubscription(Subscription subscription) async
```

**Location:** `notification_service.dart:80-109`

### How It Works

1. **Cancels existing notifications** - Prevents duplicates
2. **Checks if subscription is active** - Inactive subs get no notifications
3. **Routes to appropriate scheduler:**
   - Trial subscriptions → `_scheduleTrialNotifications()`
   - Regular subscriptions → Individual reminder schedulers

### Usage Example

```dart
// In AddSubscriptionScreen after saving
Future<void> _save() async {
  final subscription = /* build subscription from form */;

  // 1. Save to repository
  final repository = await ref.read(subscriptionRepositoryProvider.future);
  await repository.upsert(subscription);

  // 2. Schedule notifications
  final notificationService = ref.read(notificationServiceProvider);
  await notificationService.scheduleNotificationsForSubscription(subscription);

  // 3. Navigate back
  if (mounted) {
    Navigator.pop(context);
  }
}
```

### When to Call This Method

**ALWAYS call after:**
- Creating a new subscription
- Editing an existing subscription
- Changing reminder settings
- Marking a subscription as active/inactive

**Example: Repository Integration**

```dart
// In SubscriptionRepository
Future<void> upsert(Subscription subscription) async {
  // Save to Hive
  await _saveToBox(subscription);

  // Reschedule notifications
  final notificationService = /* get from provider */;
  await notificationService.scheduleNotificationsForSubscription(subscription);
}
```

---

## Notification Types

### First Reminder (7 days before)

**When:** Configurable days before billing (default: 7)
**Time:** User-configured time (default: 9:00 AM)
**Notification ID type:** `'reminder1'`

**Content:**
```
Title: 📅 [Name] — Billing in [X] days
Body: $[amount]/[cycle] charges on [date]
```

**Implementation:** `notification_service.dart:112-151`

**Key logic:**
```dart
final reminderDate = subscription.nextBillingDate.subtract(
  Duration(days: subscription.reminders.firstReminderDays),
);

// Skip if reminder date is in the past
if (reminderDate.isBefore(DateTime.now())) return;

final scheduledDate = tz.TZDateTime(
  tz.local,
  reminderDate.year,
  reminderDate.month,
  reminderDate.day,
  subscription.reminders.reminderHour,  // User's preferred time
  subscription.reminders.reminderMinute,
);
```

### Second Reminder (1 day before)

**When:** Configurable days before billing (default: 1)
**Notification ID type:** `'reminder2'`

**Content:**
```
Title: ⚠️ [Name] — Bills tomorrow  (if 1 day)
       ⚠️ [Name] — Bills in [X] days  (if > 1 day)
Body: $[amount] will be charged on [date]
```

**Implementation:** `notification_service.dart:154-196`

### Day-of Reminder

**When:** Morning of billing date
**Time:** User-configured time (default: 9:00 AM)
**Notification ID type:** `'dayof'`

**Content:**
```
Title: 💰 [Name] — Billing today
Body: $[amount] charge expected today
```

**Implementation:** `notification_service.dart:199-234`

### Trial Notifications

**Three notifications for trial subscriptions:**

1. **3 days before** - Type: `'trial_3days'`
2. **1 day before** - Type: `'trial_1day'`
3. **Day of trial end** - Type: `'trial_end'`

**Content:**
```
Title: 🔔 [Name] — Trial ending in [X] days / tomorrow / today
Body: Free trial ends [date]. You'll be charged $[amount]/[cycle] after.
```

**Implementation:** `notification_service.dart:237-316`

**Key differences:**
- Uses `trialEndDate` instead of `nextBillingDate`
- Uses `postTrialAmount` instead of `amount`
- All three notifications are scheduled if dates are in the future

---

## Notification ID Strategy

### Why Deterministic IDs?

**Problem:** If we use random IDs, we can't cancel specific notifications when rescheduling.

**Solution:** Generate stable IDs from subscription UUID + notification type.

### Implementation

From `notification_service.dart:75-77`:

```dart
int _notificationId(String subscriptionId, String type) {
  return ('$subscriptionId:$type'.hashCode).abs() % 2147483647;
}
```

**Notification types:**
- Regular: `'reminder1'`, `'reminder2'`, `'dayof'`
- Trial: `'trial_3days'`, `'trial_1day'`, `'trial_end'`

### Why This Works

1. **Deterministic** - Same subscription + type = same ID every time
2. **Collision-free** - UUIDs + type strings are unique
3. **Cancellable** - We can cancel specific notifications by ID
4. **No storage needed** - IDs computed on-the-fly, not stored

### Example

```dart
// Subscription ID: "123e4567-e89b-12d3-a456-426614174000"

_notificationId(subscriptionId, 'reminder1')  // → 1234567890
_notificationId(subscriptionId, 'reminder2')  // → 2345678901
_notificationId(subscriptionId, 'dayof')      // → 3456789012
```

When rescheduling, we cancel all three and recreate with the **same IDs**.

---

## Testing Notifications

### 1. Test Notification Button

**Location:** Settings screen

**Implementation:**
```dart
final notificationService = ref.read(notificationServiceProvider);
await notificationService.showTestNotification();
```

**What it does:**
- Fires immediately (no scheduling)
- ID: `999999` (fixed, doesn't conflict with subscription IDs)
- Content: "✅ Notifications are working! You'll be reminded before every charge."

**User benefit:** Proves notifications work on their device.

### 2. Manual Testing on Device

**⚠️ Simulators have limited notification support. Always test on real devices.**

#### iOS Testing

1. Run app on real iPhone
2. Go to Settings → Test Notification
3. Tap "Send Test Notification"
4. Notification should appear immediately
5. Create a subscription with billing date tomorrow
6. Wait for scheduled notification (or change device time to test)

#### Android Testing

1. Run app on real Android device
2. Ensure "Exact alarms" permission is granted (Android 12+)
   - Settings → Apps → CustomSubs → Alarms & reminders → Allow
3. Test immediate notification (Settings screen)
4. Test scheduled notification (create subscription with near-future date)

### 3. Debugging Scheduled Notifications

**Check scheduled notifications (Android only):**

```dart
final pendingNotifications = await _notifications.pendingNotificationRequests();
print('Scheduled: ${pendingNotifications.length} notifications');
for (var notification in pendingNotifications) {
  print('ID: ${notification.id}, Title: ${notification.title}');
}
```

**Common issues:**
- No notifications scheduled → Check if subscription is active
- Wrong count → Check if `cancelNotificationsForSubscription()` was called first
- Notifications not firing → Check timezone initialization

### 4. Testing Timezone Handling

**Critical:** Notifications must fire at the **user's local time**, not UTC.

```dart
// ✅ CORRECT - Uses local timezone
final scheduledDate = tz.TZDateTime(
  tz.local,  // User's timezone
  reminderDate.year,
  reminderDate.month,
  reminderDate.day,
  9,  // 9 AM local time
  0,
);

// ❌ WRONG - Uses UTC
final scheduledDate = tz.TZDateTime.from(
  DateTime(reminderDate.year, reminderDate.month, reminderDate.day, 9, 0),
  tz.UTC,  // Wrong! Will fire at wrong time for non-UTC users
);
```

---

## Platform Differences

### iOS

**Permissions:**
- Must request explicitly via `requestPermissions()`
- User sees system dialog
- Can be denied - handle gracefully

**Exact timing:**
- iOS batches notifications for battery optimization
- May fire slightly before/after scheduled time
- Use `UILocalNotificationDateInterpretation.absoluteTime` for best accuracy

**Testing:**
- Must test on real device
- Simulator doesn't show notifications reliably

**Code:** `notification_service.dart:56-64`

### Android

**Permissions:**
- Android 12 and below: No permission needed
- Android 13+: Must request `POST_NOTIFICATIONS` permission
- Android 12+: "Exact alarms" permission for precise timing

**Exact timing:**
- Use `AndroidScheduleMode.exactAllowWhileIdle`
- Ensures notifications fire even in Doze mode
- Requires "Alarms & reminders" permission on Android 12+

**Notification channel:**
- Required for Android 8.0+
- ID: `customsubs_reminders`
- Importance: Max (highest priority)
- User can change importance in system settings

**Code:**
- Permissions: `notification_service.dart:66-72`
- Channel: `notification_service.dart:38-50`
- Scheduling: `notification_service.dart:147` (AndroidScheduleMode)

---

## Common Issues & Solutions

### Issue 1: Notifications Not Firing

**Symptoms:**
- Test notification works
- Scheduled notifications never appear

**Solutions:**

1. **Check timezone initialization:**
   ```dart
   // Must be called before scheduling
   tz.initializeTimeZones();
   ```

2. **Check scheduled date is in future:**
   ```dart
   if (reminderDate.isBefore(DateTime.now())) return; // Skip past dates
   ```

3. **Check Android exact alarm permission:**
   - Android 12+: Settings → Apps → CustomSubs → Alarms & reminders
   - Must be enabled for reliable scheduling

4. **Check subscription is active:**
   ```dart
   if (!subscription.isActive) return; // No notifications for inactive subs
   ```

### Issue 2: Duplicate Notifications

**Symptoms:**
- Multiple notifications for same subscription
- Notification count grows over time

**Solution:**

Always cancel before rescheduling:

```dart
// ✅ CORRECT
await cancelNotificationsForSubscription(subscription.id);
await scheduleNotificationsForSubscription(subscription);

// ❌ WRONG - Creates duplicates
await scheduleNotificationsForSubscription(subscription);
```

**Implementation:** `notification_service.dart:86` (automatic in main schedule method)

### Issue 3: Notifications Fire at Wrong Time

**Symptoms:**
- Notification scheduled for 9 AM fires at different time
- Timezone issues

**Solution:**

Use `tz.local` for user's timezone:

```dart
// ✅ CORRECT
final scheduledDate = tz.TZDateTime(
  tz.local,  // User's local timezone
  year, month, day, hour, minute,
);

// ❌ WRONG
final scheduledDate = tz.TZDateTime.from(
  DateTime(...),
  tz.UTC,  // Wrong timezone
);
```

### Issue 4: Notifications Disappear After App Reinstall

**Symptoms:**
- Notifications stop firing after reinstall
- No notifications for existing subscriptions

**Solution:**

Reschedule all notifications on app launch:

```dart
// In main() or splash screen
final repository = await ref.read(subscriptionRepositoryProvider.future);
final notificationService = ref.read(notificationServiceProvider);

for (final subscription in repository.getAllActive()) {
  await notificationService.scheduleNotificationsForSubscription(subscription);
}
```

**Note:** Hive data persists on reinstall (iOS/Android), but scheduled notifications do not.

### Issue 5: Permission Denied

**Symptoms:**
- `requestPermissions()` returns false
- Notifications don't appear

**Solution:**

Handle denial gracefully:

```dart
final granted = await notificationService.requestPermissions();

if (!granted) {
  // Show dialog explaining why notifications matter
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Notifications Required'),
      content: Text(
        'CustomSubs needs notification permission to remind you before charges. '
        'Without this, you might miss important billing reminders.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            // Open app settings (requires url_launcher or app_settings package)
            await openAppSettings();
          },
          child: Text('Open Settings'),
        ),
      ],
    ),
  );
}
```

---

## Critical Rules

### 1. Always Use TZDateTime

```dart
// ✅ CORRECT
tz.TZDateTime(tz.local, year, month, day, hour, minute);

// ❌ WRONG
DateTime(year, month, day, hour, minute);
```

**Why:** `DateTime` doesn't carry timezone info. `TZDateTime` ensures correct local time.

### 2. Always Cancel Before Rescheduling

```dart
// ✅ CORRECT
await cancelNotificationsForSubscription(subscription.id);
await scheduleNotificationsForSubscription(subscription);
```

**Why:** Prevents duplicate notifications.

### 3. Skip Past Dates

```dart
if (reminderDate.isBefore(DateTime.now())) return;
```

**Why:** Can't schedule notifications in the past. App will crash or fail silently.

### 4. Use Exact Alarm Mode (Android)

```dart
androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
```

**Why:** Ensures notifications fire even when device is in Doze mode.

### 5. Initialize Before Scheduling

```dart
await notificationService.init();
// Now safe to schedule
```

**Why:** Timezone data and platform plugins must be initialized first.

### 6. Check Active Status

```dart
if (!subscription.isActive) return;
```

**Why:** Paused/inactive subscriptions shouldn't send notifications.

### 7. Handle Trial Subscriptions Separately

```dart
if (subscription.isTrial && subscription.trialEndDate != null) {
  await _scheduleTrialNotifications(subscription);
} else {
  // Regular billing notifications
}
```

**Why:** Trials have different reminder logic (3 reminders around trial end, not billing date).

---

## Code Reference

### Key Methods

| Method | Purpose | Line |
|--------|---------|------|
| `init()` | Initialize notification system | 15-53 |
| `requestPermissions()` | Ask for notification permissions | 56-72 |
| `scheduleNotificationsForSubscription()` | Main scheduling method | 80-109 |
| `cancelNotificationsForSubscription()` | Cancel all notifications for a sub | 319-326 |
| `showTestNotification()` | Immediate test notification | 334-350 |
| `_notificationId()` | Generate deterministic ID | 75-77 |
| `_scheduleFirstReminder()` | 7-day reminder | 112-151 |
| `_scheduleSecondReminder()` | 1-day reminder | 154-196 |
| `_scheduleDayOfReminder()` | Day-of reminder | 199-234 |
| `_scheduleTrialNotifications()` | All trial reminders | 237-272 |

### Example: Full Implementation

```dart
// 1. Initialize in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(ProviderScope(
    overrides: [
      notificationServiceProvider.overrideWithValue(notificationService),
    ],
    child: const CustomSubsApp(),
  ));
}

// 2. Request permissions in onboarding
class OnboardingScreen extends ConsumerWidget {
  Future<void> _completeOnboarding() async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.requestPermissions();

    // Mark onboarding complete and navigate to home
    context.go('/');
  }
}

// 3. Schedule when saving subscription
class AddSubscriptionScreen extends ConsumerStatefulWidget {
  Future<void> _save() async {
    final subscription = _buildSubscription();

    // Save to repository
    final repository = await ref.read(subscriptionRepositoryProvider.future);
    await repository.upsert(subscription);

    // Schedule notifications
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.scheduleNotificationsForSubscription(subscription);

    if (mounted) Navigator.pop(context);
  }
}

// 4. Test notification in settings
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text('Test Notification'),
      onTap: () async {
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.showTestNotification();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Test notification sent!')),
        );
      },
    );
  }
}
```

---

## Summary

**Critical checklist for reliable notifications:**

- ✅ Initialize NotificationService in `main()` before `runApp()`
- ✅ Call `tz.initializeTimeZones()` in `init()`
- ✅ Request permissions during onboarding
- ✅ Always use `tz.TZDateTime` with `tz.local`
- ✅ Cancel existing notifications before rescheduling
- ✅ Check if reminder date is in the future before scheduling
- ✅ Use `AndroidScheduleMode.exactAllowWhileIdle` for Android
- ✅ Handle trials separately with trial-specific notifications
- ✅ Test on real devices, not simulators
- ✅ Provide test notification feature in Settings

**This is the #1 feature. Do not compromise on notification reliability.**

---

**See also:**
- `lib/data/services/notification_service.dart` - Full implementation
- `docs/architecture/data-layer.md` - Integrating notifications with repository
- `docs/decisions/002-notification-id-strategy.md` - Why deterministic IDs
