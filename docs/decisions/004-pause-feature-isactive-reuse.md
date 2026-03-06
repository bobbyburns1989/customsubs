# ADR 004: Pause Feature — Reuse of `isActive` Field

**Status**: Accepted
**Date**: 2026-01-xx (implemented in v1.2.0)
**Documented**: 2026-03-03

---

## Context

In v1.0.3, the `isActive` field (HiveField 8) was marked as deprecated with the comment:
```dart
// DEPRECATED: Always true as of v1.0.3
```

The original intent was to support a "paused/inactive" state, but that feature was deferred at launch and the field was effectively unused, always stored as `true`.

In v1.2.0, we needed to implement a subscription pause/snooze feature. Users wanted to temporarily stop tracking a subscription (and its notifications) without deleting it.

---

## Decision

**Reuse the existing `isActive` (HiveField 8) field as the pause state flag** rather than adding a new `isPaused` HiveField.

- `isActive = true` → subscription is active (default)
- `isActive = false` → subscription is paused

Three new HiveFields were added alongside it for the full pause feature:
- `HiveField(23)` `pausedDate: DateTime?` — when the subscription was paused
- `HiveField(24)` `resumeDate: DateTime?` — optional auto-resume date
- `HiveField(25)` `pauseCount: int` — number of times paused (history)

A convenience getter was added to the model for clarity:
```dart
bool get isPaused => !isActive;
```

---

## Alternatives Considered

### Option A: Add a new `isPaused: bool` HiveField (rejected)

Adding a new field like `@HiveField(23) final bool isPaused` would require:
1. A default value for existing Hive records (Hive handles new fields gracefully with defaults)
2. Now having two parallel booleans (`isActive` and `isPaused`) that could contradict each other
3. The `isActive` field sitting permanently in the model as a confusing dead field
4. Updating every query that filtered by `isActive` to also check `isPaused`

### Option B: Remove `isActive` and add a new status enum (rejected)

Replacing `isActive: bool` with a `status: SubscriptionStatus` enum (e.g., `active`, `paused`, `cancelled`) would be cleaner semantically but:
1. Requires a data migration for all existing records
2. Adds a new HiveType registration
3. Over-engineers the solution — we only need two states (active / paused)
4. High risk of breaking existing installs with in-progress data

### Option C (chosen): Repurpose `isActive` as the pause flag

Since `isActive` was always `true` in all existing records, changing its semantics to mean "not paused" is:
- **Zero-migration**: All existing records have `isActive = true`, which maps correctly to "not paused"
- **Backward compatible**: Any backup JSON from v1.0.x imports correctly — `isActive: true` still means active
- **Simple**: One field, one meaning, backed by a clear getter

---

## Consequences

### Positive
- No data migration required
- Backward-compatible with all existing backups
- Clear semantics via `isPaused` getter
- Existing queries already filtering `isActive == true` automatically exclude paused subs

### Negative / Risks
- The field name `isActive` is slightly misleading — it sounds like it could mean "cancelled" rather than "paused". The `isPaused` getter mitigates this.
- A future developer (or AI) reading the raw field name without context might try to "fix" it by adding a new `isPaused` field — this ADR exists to prevent that.

---

## IMPORTANT — Do Not Add a New `isPaused` Field

**If you are an AI assistant or developer reading this**: the `isActive` field IS the pause flag. Do NOT add a new `isPaused` HiveField to the `Subscription` model. Doing so would:

1. Create two conflicting booleans in the model
2. Break the existing `isPaused` getter (`bool get isPaused => !isActive;`)
3. Require an unnecessary data migration

The `isPaused` getter on the model (`subscription.isPaused`) is the correct way to check pause state. The raw field is `isActive` — when `false`, the subscription is paused.

---

## Implementation

**Files changed:**
- `lib/data/models/subscription.dart` — added `pausedDate`, `resumeDate`, `pauseCount` fields and convenience getters
- `lib/data/repositories/subscription_repository.dart` — added `pauseSubscription()`, `resumeSubscription()`, `getAllPaused()`, `autoResumeSubscriptions()`; updated `advanceOverdueBillingDates()` to skip paused subs
- `lib/data/services/notification_service.dart` — skip paused subs in `scheduleNotificationsForSubscription()`
- `lib/features/home/home_screen.dart` — added Paused section with `_PausedSubscriptionTile`
- `lib/features/home/home_controller.dart` — added `getPausedSubscriptions()`, `getPausedCount()`

**Auto-resume runs in three places** (same pattern as billing date advancement):
1. App startup (`main.dart`)
2. App foreground (`home_screen.dart` via `didChangeAppLifecycleState`)
3. Pull-to-refresh (`home_screen.dart`)
