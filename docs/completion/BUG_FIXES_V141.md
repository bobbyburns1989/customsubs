# Bug Fixes — v1.4.1

**Date:** March 3, 2026
**Status:** ✅ Complete
**`flutter analyze`:** 0 errors (9 pre-existing info warnings, unchanged)

---

## Overview

Four correctness and UX bugs fixed in a single session. No new dependencies, no architectural changes.

---

## Fix 1: "Today" Billing Dates Silently Advanced

**Root cause:** `advanceOverdueBillingDates()` used `isBefore(DateTime.now())` — a time-precise comparison. A subscription set to midnight (the default for date pickers) was already "before" 9 AM and got advanced to the next cycle when the app opened. Users never saw a "Today" billing date.

**Files changed:**
- `lib/data/repositories/subscription_repository.dart` — `advanceOverdueBillingDates()`: changed `isBefore(now)` → `isBefore(today)` where `today = DateTime(now.year, now.month, now.day)`
- `lib/features/home/home_controller.dart` — `getUpcomingSubscriptions()`: changed `isAfter(now)` → `!isBefore(todayStart)` so today's subs are included in the Upcoming list

**Behavior after fix:**
- Subscriptions with billing date today show as "Today" in the Upcoming list
- They are not advanced until the calendar date passes midnight

---

## Fix 2: Invisible Subscriptions Beyond 30 Days

**Root cause:** `getUpcomingSubscriptions()` filtered to `next 30 days` only. Active subscriptions billing in 35, 60, or 90 days contributed to the spending total but were completely absent from the Home screen list — no indicator they existed.

**Files changed:**
- `lib/features/home/home_controller.dart` — new `getLaterSubscriptions({fromDays: 31, toDays: 90})` method
- `lib/features/home/home_screen.dart` — new "Later • 31–90 days" section + new `_LaterSubscriptionTile` widget

**New UI section:** Appears between "Upcoming" and "Paused". Shows a simplified, muted tile with no swipe actions and an absolute date ("Apr 17"). Tappable → navigates to detail screen.

---

## Fix 3: Premium Entitlement Stale After App Foreground

**Root cause:** `isPremiumProvider` (`AutoDisposeFutureProvider<bool>`) was never refreshed when the app resumed from background. If a 3-day RevenueCat trial expired while the app was backgrounded, the Premium badge remained visible indefinitely and the 5-subscription limit stayed bypassed.

**Files changed:**
- `lib/features/home/home_screen.dart` — added `ref.invalidate(isPremiumProvider)` to `didChangeAppLifecycleState(AppLifecycleState.resumed)`

**Note:** RevenueCat's `getCustomerInfo()` reads from its local cache — this is not a network call and is safe to call on every foreground.

---

## Fix 4: iOS `view_details` Notification Action Missing Foreground Option

**Root cause:** The `view_details` iOS notification action was missing `DarwinNotificationActionOption.foreground`. Without it, tapping "View Details" on iOS may not bring the app to the foreground, causing the GoRouter deep link navigation to fail silently. (`mark_paid` already had `foreground` and was unaffected.)

**Files changed:**
- `lib/data/services/notification_service.dart` — added `options: {DarwinNotificationActionOption.foreground}` to the `view_details` `DarwinNotificationAction`

**Why both actions need `foreground`:** The notification tap handler (`NotificationRouter.handleNotificationResponse`) always navigates using GoRouter, which requires the app to be in the foreground. Both `mark_paid` and `view_details` need this option.

---

## Testing

See `docs/testing/TESTING_CHECKLIST.md` for test cases covering all 4 fixes. Rich notification action testing requires a real iOS/Android device (simulators do not support notification action buttons).

---

## Files Modified

| File | Change |
|---|---|
| `lib/data/repositories/subscription_repository.dart` | Calendar-day comparison in `advanceOverdueBillingDates()` |
| `lib/features/home/home_controller.dart` | Fixed `getUpcomingSubscriptions()` + added `getLaterSubscriptions()` |
| `lib/features/home/home_screen.dart` | Later section + `_LaterSubscriptionTile` + entitlement refresh |
| `lib/data/services/notification_service.dart` | `foreground` option on `view_details` iOS action |
| `docs/QUICK-REFERENCE.md` | Date comparison patterns, Later section, premium refresh docs |
| `docs/guides/working-with-notifications.md` | Rich notifications section with action button guide |
| `docs/testing/TESTING_CHECKLIST.md` | New test cases for all 4 fixes |
