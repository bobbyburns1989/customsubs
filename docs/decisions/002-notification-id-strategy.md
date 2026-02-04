# ADR 002: Deterministic Notification ID Strategy

**Status**: Accepted
**Date**: 2024-01-15
**Deciders**: Development Team
**Context**: Notification scheduling and cancellation for subscription reminders

---

## Context and Problem Statement

CustomSubs schedules up to 3 notifications per subscription (first reminder, second reminder, day-of). When a user edits a subscription, we must:
1. Cancel all existing notifications for that subscription
2. Schedule new notifications with updated data

**Problem:** How do we generate notification IDs that allow reliable cancellation without storing IDs in the database?

---

## Decision Drivers

1. **Reliability** - Must cancel the correct notifications, always
2. **Simplicity** - No additional database tables or fields
3. **Collision-Free** - Different subscriptions must have different IDs
4. **Predictable** - Same subscription + type = same ID (for cancellation)
5. **Platform Limits** - IDs must fit in int32 range (−2,147,483,648 to 2,147,483,647)

---

## Considered Options

### Option 1: Random IDs (Naive Approach)

**Example:**
```dart
final id = Random().nextInt(1000000);
await _notifications.zonedSchedule(id, ...);
```

**Pros:**
- Simple to implement
- Low collision risk (if range is large)

**Cons:**
- ❌ **Cannot cancel specific notifications** - Don't know which ID was used
- ❌ Requires storing IDs in database
- ❌ Data model complexity increases
- ❌ No way to recover if ID is lost

**Verdict:** Not viable for our use case.

### Option 2: Auto-Increment IDs

**Example:**
```dart
int _nextId = 1;

int getNextId() {
  return _nextId++;
}
```

**Pros:**
- Guaranteed unique
- Simple to understand

**Cons:**
- ❌ **Cannot cancel without storing** - Must save ID to database
- ❌ Requires persistent counter storage
- ❌ Counter can be lost on app reinstall
- ❌ No relationship between ID and subscription

**Verdict:** Not suitable - requires database changes.

### Option 3: Subscription ID as Notification ID

**Example:**
```dart
final id = subscription.id.hashCode;
```

**Pros:**
- Deterministic
- No storage needed
- Easy to cancel (know subscription ID)

**Cons:**
- ❌ **Only one notification per subscription** - Can't have first, second, day-of reminders
- ❌ Trial subscriptions need separate IDs

**Verdict:** Not sufficient - need multiple notifications per subscription.

### Option 4: Deterministic Composite IDs (CHOSEN)

**Example:**
```dart
int _notificationId(String subscriptionId, String type) {
  return ('$subscriptionId:$type'.hashCode).abs() % 2147483647;
}

// Usage
_notificationId(subscription.id, 'reminder1')  // First reminder
_notificationId(subscription.id, 'reminder2')  // Second reminder
_notificationId(subscription.id, 'dayof')      // Day-of reminder
_notificationId(subscription.id, 'trial_end')  // Trial end
```

**Pros:**
- ✅ **Deterministic** - Same input = same ID every time
- ✅ **Unique** - UUID + type string ensures no collisions
- ✅ **No storage needed** - Compute on-the-fly
- ✅ **Multiple notifications** - Different types = different IDs
- ✅ **Cancellable** - Know subscription ID = can cancel all types

**Cons:**
- Slight risk of hash collisions (negligible with UUIDs)
- More complex than simple increment

**Verdict:** Best solution for our requirements.

---

## Decision Outcome

**Chosen option: Deterministic Composite IDs (Option 4)**

### Implementation

```dart
class NotificationService {
  /// Generates a stable notification ID from subscription UUID and type.
  ///
  /// Types: 'reminder1', 'reminder2', 'dayof', 'trial_3days', 'trial_1day', 'trial_end'
  int _notificationId(String subscriptionId, String type) {
    // Hash the composite key and ensure positive int32
    return ('$subscriptionId:$type'.hashCode).abs() % 2147483647;
  }

  /// Schedule first reminder
  Future<void> _scheduleFirstReminder(Subscription sub) async {
    final id = _notificationId(sub.id, 'reminder1');
    await _notifications.zonedSchedule(id, /* ... */);
  }

  /// Cancel all notifications for a subscription
  Future<void> cancelNotificationsForSubscription(String subscriptionId) async {
    await _notifications.cancel(_notificationId(subscriptionId, 'reminder1'));
    await _notifications.cancel(_notificationId(subscriptionId, 'reminder2'));
    await _notifications.cancel(_notificationId(subscriptionId, 'dayof'));
    await _notifications.cancel(_notificationId(subscriptionId, 'trial_3days'));
    await _notifications.cancel(_notificationId(subscriptionId, 'trial_1day'));
    await _notifications.cancel(_notificationId(subscriptionId, 'trial_end'));
  }
}
```

---

## Rationale

### Why This Works

1. **Deterministic Cancellation**
   ```
   User creates subscription
   → ID: "123e4567-e89b-12d3-a456-426614174000"
   → Schedule notification with ID: _notificationId(id, 'reminder1')
   → ID: 1234567890

   User edits subscription
   → Cancel with ID: _notificationId(id, 'reminder1')
   → ID: 1234567890 (same as before!)
   → Successfully cancels the right notification
   ```

2. **No Collisions**
   - UUIDs are globally unique
   - Type strings differentiate notification types
   - Composite key: "uuid:type" is always unique
   - hashCode collisions extremely rare with UUIDs

3. **No Storage Overhead**
   - IDs computed on-demand
   - No additional database fields
   - No synchronization issues
   - Survives app reinstalls (as long as subscription data persists)

4. **Multiple Notifications Per Subscription**
   ```
   Subscription "abc-123":
     reminder1 → ID 1111111
     reminder2 → ID 2222222
     dayof     → ID 3333333
   ```

### Hash Collision Risk Analysis

**Probability of collision:**
- UUID space: 2^122 possible values
- hashCode space: 2^31 possible values
- With proper UUIDs, collision probability < 0.0000001%

**Mitigation:**
- Use UUID v4 (random) for subscription IDs
- Modulo by 2147483647 (max int32) ensures valid range
- Even with 100,000 subscriptions × 6 notifications = 600,000 IDs
- Collision risk remains negligible

**If collision occurs:**
- Worst case: Wrong notification gets canceled
- User reschedules by editing subscription
- Extremely unlikely given UUID randomness

---

## Consequences

### Positive

1. **Simple Data Model**
   - No notification ID fields in Subscription model
   - No join tables or relationships
   - Clean, minimal schema

2. **Reliable Cancellation**
   - Can cancel specific notification types
   - Can cancel all notifications for a subscription
   - No orphaned notifications

3. **Works Across App Lifecycle**
   - IDs persist through app restarts
   - No state to lose
   - Deterministic generation after reinstall

4. **Testable**
   - Easy to unit test ID generation
   - Predictable IDs make debugging easier

### Negative

1. **Slightly Complex Logic**
   - Requires understanding of hashing
   - Not immediately obvious to new developers
   - Mitigated by: good documentation

2. **Theoretical Collision Risk**
   - Hash collisions possible (though extremely rare)
   - No runtime detection of collisions
   - Acceptable given low probability

3. **Platform Dependency**
   - Relies on Dart's hashCode implementation
   - Assumes stable hash algorithm (it is)

---

## Notification Type Registry

### Regular Subscriptions

| Type | Purpose | When |
|------|---------|------|
| `reminder1` | First reminder | X days before (default: 7) |
| `reminder2` | Second reminder | Y days before (default: 1) |
| `dayof` | Day-of reminder | Morning of billing date |

### Trial Subscriptions

| Type | Purpose | When |
|------|---------|------|
| `trial_3days` | 3-day warning | 3 days before trial ends |
| `trial_1day` | 1-day warning | 1 day before trial ends |
| `trial_end` | End notification | Morning of trial end date |

### Reserved IDs

- **999999**: Test notification (Settings screen)
- **1-1000**: Reserved for future system notifications

---

## Alternatives Considered and Rejected

### Store IDs in Database

```dart
class Subscription {
  final String id;
  final List<int> notificationIds;  // Store generated IDs
}
```

**Why rejected:**
- Adds complexity to data model
- Synchronization issues (what if notification is canceled outside app?)
- Notification IDs tied to platform state, not app state
- Data model should be platform-agnostic

### Use Subscription UUID Directly

```dart
final id = uuid.v4().hashCode % 2147483647;
```

**Why rejected:**
- Can't have multiple notifications per subscription
- Trial vs regular notifications would conflict
- No way to target specific reminder types

### Platform-Specific Solutions

**iOS:** Use UNNotificationRequest identifiers (string-based)
**Android:** Use integer IDs only

**Why rejected:**
- Inconsistent across platforms
- Code duplication
- Harder to test cross-platform logic

---

## Testing Strategy

### Unit Tests

```dart
test('notification IDs are deterministic', () {
  final service = NotificationService();
  final id1 = service._notificationId('abc-123', 'reminder1');
  final id2 = service._notificationId('abc-123', 'reminder1');
  expect(id1, equals(id2));
});

test('different types have different IDs', () {
  final service = NotificationService();
  final id1 = service._notificationId('abc-123', 'reminder1');
  final id2 = service._notificationId('abc-123', 'reminder2');
  expect(id1, isNot(equals(id2)));
});

test('IDs are in valid int32 range', () {
  final service = NotificationService();
  final id = service._notificationId('abc-123', 'reminder1');
  expect(id, greaterThan(0));
  expect(id, lessThanOrEqualTo(2147483647));
});
```

### Integration Tests

1. **Schedule and Cancel**
   - Schedule notification
   - Verify it's scheduled (use getPendingNotifications)
   - Cancel by subscription ID
   - Verify it's gone

2. **Edit Subscription Flow**
   - Create subscription with reminders
   - Edit subscription (change date)
   - Verify old notifications canceled
   - Verify new notifications scheduled

3. **App Restart**
   - Schedule notifications
   - Close and reopen app
   - Verify notifications still scheduled
   - Verify can still cancel by subscription ID

---

## Related Decisions

- See `docs/guides/working-with-notifications.md` for implementation details
- See `lib/data/services/notification_service.dart` for full implementation
- See `docs/architecture/overview.md` for offline-first principles

---

## References

- [flutter_local_notifications Documentation](https://pub.dev/packages/flutter_local_notifications)
- [Dart hashCode Documentation](https://api.dart.dev/stable/dart-core/Object/hashCode.html)
- [UUID Specification RFC 4122](https://www.ietf.org/rfc/rfc4122.txt)

---

## Revision History

| Date | Change | Author |
|------|--------|--------|
| 2024-01-15 | Initial decision | Development Team |
