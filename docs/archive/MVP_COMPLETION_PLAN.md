# CustomSubs MVP Completion & Polish Plan

**Document Version:** 2.2
**Date:** February 4, 2026
**Status:** ✅ Phase 0 Complete | ✅ Phase 1 Complete | ✅ Phase 2 Complete | ⏳ Phase 3 Ready to Start

---

## Executive Summary

CustomSubs is currently ~70% complete for Phase 1 MVP. **CRITICAL:** Code review revealed several serious bugs that must be fixed before feature work. The core infrastructure is solid, but notification reliability, billing date calculations, and data persistence have issues that break core functionality.

This revised plan prioritizes **bug fixes first** (Phase 0), then continues with feature completion.

**Estimated Total Effort:** 15-17 hours of focused development + 2-3 hours of testing

**⚠️ BREAKING BUGS FOUND:**
- Notifications schedule in wrong timezone (can miss reminders)
- Same-day reminders are skipped (critical failure)
- Month-end billing dates drift incorrectly (Feb 28 → Apr 28)
- Edit subscription resets paid status and checklist (data loss)
- Multi-currency totals calculate incorrectly (shows wrong amounts)

---

## Current State Assessment

### ✅ Completed & Working

**Infrastructure (100%)**
- Riverpod state management with code generation
- Hive database with type adapters
- GoRouter navigation
- Google Fonts (DM Sans)
- Multi-currency support with bundled exchange rates
- Timezone support for notifications

**Features (Implemented)**
- ✅ Onboarding (3-page flow + permission request)
- ✅ Home screen with spending summary
- ✅ Upcoming subscriptions list with sorting
- ✅ Trial warnings section
- ✅ Add/Edit subscription screen
- ✅ Template picker (40+ services with icons)
- ✅ Color picker (12 colors)
- ✅ Free trial mode support
- ✅ Settings screen (partial)
- ✅ Test notification feature
- ✅ Notification service (fully implemented)
- ✅ Pull-to-refresh on home

### ⚠️ Incomplete or Missing

**Critical Bugs (MUST FIX FIRST - Phase 0)**
- 🔴 Notifications schedule in UTC, not local timezone (breaks reminders)
- 🔴 Same-day reminders skip if after midnight (misses notifications)
- 🔴 Month-end billing dates drift (Jan 31 → Mar 2)
- 🔴 Edit resets isActive, isPaid, checklist (data loss on edit)
- 🔴 Multi-currency totals don't convert (wrong spending amounts)
- 🟡 getById throws instead of returning null (crashes on stale IDs)
- 🟡 "Next 30 days" shows all subscriptions (misleading label)

**Feature Gaps**
- ❌ Subscription Detail Screen (stub only - blocks core UX)
- ❌ Backup/Export service (no implementation)
- ❌ Import/Restore service (no implementation)
- ❌ Analytics screen (empty folder)
- ❌ Cancellation management screen (empty folder)
- ❌ Currency picker (Settings has placeholder)
- ✅ "Mark as Paid" UI (exists but needs detail screen integration)

**Code Quality Issues**
- ⚠️ 40+ deprecation warnings (Color.value, withOpacity)
- ⚠️ No end-to-end notification testing on real devices
- ⚠️ Large files (add_subscription_screen.dart: 600+ lines)
- ⚠️ Template files in docs/ causing analyzer errors
- ⚠️ Documentation drift (CLAUDE.md/README claim features are complete)

---

## Implementation Strategy

### Phase 0: Critical Bug Fixes (Priority: URGENT - DO FIRST)
Fix breaking bugs in notifications, billing dates, and data persistence. **Nothing else can be trusted until these are fixed.**

### Phase 1: Critical Completions (Priority: CRITICAL)
Complete the features that block core user flows.

### Phase 2: Data Safety (Priority: HIGH)
Implement backup/restore to prevent data loss.

### Phase 3: Enhanced Features (Priority: MEDIUM)
Add analytics and polish existing features.

### Phase 4: Quality & Testing (Priority: HIGH)
Fix warnings, refactor, and validate notifications.

---

## Detailed Implementation Plan

---

## 🚨 PHASE 0: Critical Bug Fixes (DO FIRST)

**Goal:** Fix breaking bugs that compromise core functionality
**Estimated Time:** 3-4 hours
**Priority:** URGENT - These bugs break the app's core value proposition

**Status:** ✅ COMPLETE (See docs/PHASE_0_COMPLETE.md)

---

### Task 0.1: Fix Notification Timezone ⚠️ CRITICAL

**Bug:** Notifications schedule in UTC instead of local timezone because `tz.local` is never initialized with the device's actual timezone.

**Impact:**
- User in PST sets reminder for 9 AM
- Notification fires at 5 PM (9 AM UTC)
- Completely breaks notification reliability

**Root Cause:**
- `tz.initializeTimeZones()` is called, but `tz.setLocalLocation()` is never called
- No dependency to get device timezone (need `flutter_timezone` package)

**Fix:**
1. Add `flutter_timezone: ^2.1.0` to pubspec.yaml
2. In main.dart, after `tz.initializeTimeZones()`:
   ```dart
   final String timeZoneName = await FlutterTimezone.getLocalTimezone();
   tz.setLocalLocation(tz.getLocation(timeZoneName));
   ```
3. Test: Schedule notification for 5 minutes from now, verify it fires at correct local time

**Files to Modify:**
- ✏️ `pubspec.yaml` (add dependency)
- ✏️ `lib/main.dart` (initialize timezone)

**Testing:**
- [ ] Schedule test notification for 2 minutes from now
- [ ] Verify it fires at exact local time
- [ ] Test on both iOS and Android
- [ ] Verify timezone survives app restart

**Estimated Time:** 30 minutes

---

### Task 0.2: Fix Same-Day Reminder Skip ⚠️ CRITICAL

**Bug:** If current time is after midnight but before the configured reminder time, the reminder is skipped because code compares `reminderDate` (at midnight) to `DateTime.now()`.

**Impact:**
- User has subscription billing today at 9 AM
- Current time is 6 AM
- Day-of reminder is skipped (because midnight < 6 AM)
- User misses critical reminder

**Root Cause:**
```dart
if (reminderDate.isBefore(DateTime.now())) return;  // Wrong!
```
Should compare `scheduledDate` (which includes time) instead of `reminderDate` (which is midnight).

**Fix:**
Replace all instances of:
```dart
if (reminderDate.isBefore(DateTime.now())) return;
```

With:
```dart
final scheduledDate = tz.TZDateTime(...);
if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;
```

**Affected Methods:**
- `_scheduleFirstReminder` (line ~267)
- `_scheduleSecondReminder` (line ~309)
- `_scheduleDayOfReminder` (line ~352)
- `_scheduleTrialNotifications` (line ~393, ~404, ~414)

**Files to Modify:**
- ✏️ `lib/data/services/notification_service.dart`

**Testing:**
- [ ] Create subscription billing today with reminder at 11:59 PM
- [ ] Verify reminder schedules (not skipped)
- [ ] Create subscription billing today with reminder 5 minutes from now
- [ ] Verify reminder fires

**Estimated Time:** 30 minutes

---

### Task 0.3: Fix Month-End Billing Date Drift 🔴 HIGH

**Bug:** `Subscription.calculateNextBillingDate()` uses `DateTime(year, month + n, day)` which causes month-end dates to drift.

**Impact:**
- Jan 31 monthly subscription → Feb 28 → Mar 28 → Apr 28 (drifts by 3 days)
- May 31 monthly → June 30 → July 30 → Aug 30 (drifts permanently)

**Root Cause:**
```dart
case SubscriptionCycle.monthly:
  nextDate = DateTime(year, month + 1, day);  // Wrong!
```

**Fix:**
Replace month math with `DateTimeExtensions.addMonths()` which already exists:
```dart
case SubscriptionCycle.monthly:
  nextDate = currentDate.addMonths(1);  // Correct!
```

**Files to Modify:**
- ✏️ `lib/data/models/subscription.dart` (lines 197-227)
- ✏️ `lib/data/repositories/subscription_repository.dart` (lines 260-270)

**Testing:**
- [ ] Create subscription on Jan 31, advance 3 times, verify stays on 31st
- [ ] Create subscription on Feb 28 (non-leap year), advance, verify stays on 28/29
- [ ] Test quarterly (Jan 31 → Apr 30 → Jul 31)
- [ ] Test biannual and yearly

**Estimated Time:** 45 minutes

---

### Task 0.4: Fix Edit State Preservation 🔴 HIGH

**Bug:** `AddSubscriptionController.saveSubscription()` builds a new `Subscription` object with default values, wiping out `isActive`, `isPaid`, `lastMarkedPaidDate`, and `checklistCompleted`.

**Impact:**
- User pauses a subscription → edits the name → subscription auto-resumes
- User marks as paid → edits amount → paid status cleared
- User completes 3/5 checklist items → edits URL → checklist reset to 0/5

**Root Cause:**
```dart
final subscription = Subscription(
  id: _editingSubscription?.id ?? const Uuid().v4(),
  // ... all other fields from form ...
  isActive: true,  // ❌ Always true!
  isPaid: false,   // ❌ Always false!
  checklistCompleted: List.filled(cancelChecklist.length, false),  // ❌ Always empty!
);
```

**Fix:**
Preserve existing values when editing:
```dart
final subscription = Subscription(
  id: _editingSubscription?.id ?? const Uuid().v4(),
  // ... form fields ...
  isActive: _editingSubscription?.isActive ?? true,
  isPaid: _editingSubscription?.isPaid ?? false,
  lastMarkedPaidDate: _editingSubscription?.lastMarkedPaidDate,
  checklistCompleted: _editingSubscription?.checklistCompleted ??
    List.filled(cancelChecklist.length, false),
);
```

**Files to Modify:**
- ✏️ `lib/features/add_subscription/add_subscription_controller.dart` (lines 22-68)

**Testing:**
- [ ] Pause subscription → edit name → verify still paused
- [ ] Mark as paid → edit amount → verify still marked paid
- [ ] Complete 2/3 checklist items → edit notes → verify 2/3 still checked
- [ ] Create new subscription → verify defaults to active/unpaid

**Estimated Time:** 30 minutes

---

### Task 0.5: Fix Multi-Currency Totals 🔴 HIGH

**Bug:** `HomeController.calculateMonthlyTotal()` sums raw amounts without converting to primary currency. Display is hardcoded to USD.

**Impact:**
- User has Netflix $15 USD + Spotify €10 EUR
- Total shows "$25.00/month" (wrong! Should be ~$25.90 at exchange rate)
- Analytics and spending summary are completely wrong for multi-currency users

**Root Cause:**
```dart
double calculateMonthlyTotal() {
  return subscriptions.fold(0.0, (sum, sub) => sum + sub.monthlyEquivalent);
  // ❌ Adds raw amounts without conversion
}
```

**Fix:**
1. Get primary currency from settings (default: USD)
2. Convert each subscription to primary currency:
```dart
double calculateMonthlyTotal() {
  final primaryCurrency = 'USD'; // TODO: Get from settings provider
  return subscriptions.fold(0.0, (sum, sub) {
    final converted = CurrencyUtils.convert(
      sub.monthlyEquivalent,
      from: sub.currencyCode,
      to: primaryCurrency,
    );
    return sum + converted;
  });
}
```
3. Update display to use actual primary currency (not hardcoded USD)

**Files to Modify:**
- ✏️ `lib/features/home/home_controller.dart` (lines 31-35)
- ✏️ `lib/features/home/home_screen.dart` (lines 317-334) - use settings currency
- ➕ Create: `lib/core/providers/settings_provider.dart` (for primary currency)

**Testing:**
- [ ] Add subscription in USD, verify total
- [ ] Add subscription in EUR, verify converted total
- [ ] Change primary currency to EUR, verify total recalculates
- [ ] Test with 5+ different currencies

**Estimated Time:** 1 hour

---

### Task 0.6: Fix getById Signature 🟡 MEDIUM

**Bug:** `SubscriptionRepository.getById()` is typed as `Subscription?` (nullable) but throws on missing IDs instead of returning null.

**Impact:**
- Call sites expect null for missing IDs
- Instead, app crashes with exception
- Stale IDs (e.g., from deleted subscription) cause crashes

**Root Cause:**
```dart
Subscription? getById(String id) {
  return _getBox.values.firstWhere(
    (sub) => sub.id == id,
    orElse: () => throw Exception('Subscription not found'),  // ❌ Throws!
  );
}
```

**Fix - Option A (Preferred):**
Make signature non-nullable and document throwing behavior:
```dart
/// Throws [SubscriptionNotFoundException] if not found
Subscription getById(String id) {
  try {
    return _getBox.values.firstWhere((sub) => sub.id == id);
  } catch (e) {
    throw SubscriptionNotFoundException(id);
  }
}
```
Update call sites to handle exceptions.

**Fix - Option B:**
Return null as signature promises:
```dart
Subscription? getById(String id) {
  try {
    return _getBox.values.firstWhere((sub) => sub.id == id);
  } catch (e) {
    return null;
  }
}
```

**Recommendation:** Option B is simpler and matches Flutter conventions.

**Files to Modify:**
- ✏️ `lib/data/repositories/subscription_repository.dart` (lines 72-78)
- ✏️ All call sites (home_screen, subscription_detail, etc.) - add null checks

**Testing:**
- [ ] Call getById with valid ID → returns subscription
- [ ] Call getById with invalid ID → returns null (no crash)
- [ ] Delete subscription, try to access → returns null

**Estimated Time:** 30 minutes

---

### Task 0.7: Fix "Next 30 Days" Filter 🟡 MEDIUM

**Bug:** Home screen section says "Next 30 days" but `getUpcomingSubscriptions()` returns ALL active subscriptions with no date filter.

**Impact:**
- Misleading UI (shows subscriptions billing in 90+ days)
- Long list when user expects short preview

**Root Cause:**
```dart
List<Subscription> getUpcomingSubscriptions() {
  final subs = subscriptions.where((sub) => sub.isActive).toList();
  // ❌ No date filtering!
  return subs..sort(...);
}
```

**Fix:**
```dart
List<Subscription> getUpcomingSubscriptions({int days = 30}) {
  final cutoffDate = DateTime.now().add(Duration(days: days));
  final subs = subscriptions.where((sub) =>
    sub.isActive && sub.nextBillingDate.isBefore(cutoffDate)
  ).toList();
  return subs..sort(...);
}
```

**Files to Modify:**
- ✏️ `lib/features/home/home_controller.dart` (lines 15-29)

**Testing:**
- [ ] Create subscription billing in 15 days → shows in list
- [ ] Create subscription billing in 45 days → does NOT show
- [ ] Verify list updates when dates change

**Estimated Time:** 20 minutes

---

### Task 0.8: Documentation Sync 📝

**Bug:** CLAUDE.md and README.md claim features are complete that don't exist.

**Fix:**
- Update CLAUDE.md Phase 1-3 checkboxes to reflect actual status
- Update README.md to show what's actually implemented
- Add note about Phase 0 bug fixes

**Files to Modify:**
- ✏️ `CLAUDE.md`
- ✏️ `README.md`

**Estimated Time:** 15 minutes

---

## 📋 PHASE 1: Critical Completions

**Goal:** Unblock core user flows and complete MVP feature set
**Estimated Time:** 5-7 hours
**Priority:** CRITICAL - These block the app from being usable

**Status:** ✅ COMPLETE (See docs/PHASE_1_COMPLETE.md)

---

### Task 1.1: Build Subscription Detail Screen

**Why:** Users tap subscriptions on home screen and get a "TODO" stub. This is the most critical UX gap.

**Location:** `lib/features/subscription_detail/subscription_detail_screen.dart`

**Requirements:**

1. **Screen Structure**
   - AppBar with back button, Edit action, Delete action
   - Scrollable body with multiple info cards
   - Hero animation from home screen (use subscription color)

2. **Header Section**
   - Large service icon or colored circle with initials
   - Subscription name (large, bold)
   - Amount + cycle display
   - Status badge: Active (green), Paused (gray), Trial (yellow)

3. **Billing Info Card**
   - Next billing date with countdown ("in 12 days")
   - Billing cycle
   - Currency + amount
   - Start date
   - For trials: "Trial ends [date] — then $X.XX/[cycle]"

4. **Quick Actions Section**
   - "Mark as Paid" button (toggle for current cycle)
   - "Pause/Resume" toggle
   - Visual feedback when toggled (snackbar + state update)

5. **Cancellation Info Card** (conditional - only if data exists)
   - Section header: "How to Cancel"
   - Tappable "Open Cancellation Page" button (url_launcher)
   - Tappable phone number (launches dialer)
   - Display cancellation notes if present
   - Interactive checklist with checkboxes (persist state)
   - Progress indicator: "X of Y steps complete"

6. **General Notes Card** (conditional)
   - Display user notes if present

7. **Actions**
   - Edit → Navigate to Add/Edit screen in edit mode
   - Delete → Confirmation dialog → Delete + cancel notifications + pop back
   - Pause/Resume → Toggle isActive + reschedule notifications

**Implementation Details:**
- Create `subscription_detail_controller.dart` (Riverpod)
- Controller methods:
  - `togglePaid()` - Sets isPaid + lastMarkedPaidDate
  - `togglePause()` - Sets isActive, reschedules notifications
  - `toggleChecklistItem(int index)` - Updates checklist state
  - `deleteSubscription()` - Deletes + cancels notifications
- Use url_launcher for cancel URL and phone
- Update home screen to refresh after returning from detail

**Files to Create/Modify:**
- ✏️ Modify: `lib/features/subscription_detail/subscription_detail_screen.dart`
- ➕ Create: `lib/features/subscription_detail/subscription_detail_controller.dart`
- ➕ Create: `lib/features/subscription_detail/widgets/billing_info_card.dart`
- ➕ Create: `lib/features/subscription_detail/widgets/cancellation_card.dart`
- ➕ Create: `lib/features/subscription_detail/widgets/detail_action_buttons.dart`

**Testing Checklist:**
- [ ] Navigate from home to detail screen
- [ ] Hero animation works smoothly
- [ ] All subscription data displays correctly
- [ ] "Mark as Paid" toggles and persists
- [ ] Pause/Resume works and reschedules notifications
- [ ] Checklist items toggle and persist
- [ ] Delete shows confirmation and removes subscription
- [ ] Cancel URL opens in browser
- [ ] Phone number opens dialer
- [ ] Home screen refreshes after returning

**Estimated Time:** 3-4 hours

---

### Task 1.2: Implement "Mark as Paid" in Home Screen

**Why:** Data model supports it, but no visual indication or toggle in UI.

**Requirements:**
- Add green checkmark badge to paid subscriptions in home list
- Paid subscriptions sort to bottom of upcoming list
- Tapping badge toggles paid state (or use detail screen)
- Reset isPaid to false when nextBillingDate advances

**Implementation:**
- Modify home_screen.dart subscription tile widget
- Add visual badge (small green check icon)
- Integrate with detail screen's togglePaid method

**Files to Modify:**
- ✏️ `lib/features/home/home_screen.dart` (add paid badge to subscription tiles)
- ✏️ `lib/features/home/home_controller.dart` (sorting logic for paid items)

**Estimated Time:** 1 hour

---

### Task 1.3: Add Currency Picker to Settings

**Why:** Settings shows hardcoded "USD". Users need to set their primary currency.

**Requirements:**
- Create a currency picker screen or bottom sheet
- List 30+ supported currencies (USD, EUR, GBP, CAD, AUD, JPY, INR, etc.)
- Search/filter functionality
- Display currency code + full name + symbol
- Save selection to Hive settings box
- Update home screen summary when changed

**Implementation:**
- Create `lib/features/settings/widgets/currency_picker_dialog.dart`
- Create Hive settings box (or use shared_preferences)
- Riverpod provider for primary currency setting
- Update home screen to use primary currency from settings

**Files to Create/Modify:**
- ➕ Create: `lib/features/settings/widgets/currency_picker_dialog.dart`
- ➕ Create: `lib/core/constants/supported_currencies.dart`
- ✏️ Modify: `lib/features/settings/settings_screen.dart`
- ✏️ Modify: `lib/features/home/home_controller.dart` (use primary currency)

**Estimated Time:** 1-2 hours

---

## 📋 PHASE 2: Data Safety Features

**Goal:** Implement backup/restore to prevent data loss
**Estimated Time:** 3-4 hours
**Priority:** HIGH - Critical for user trust

**Status:** ✅ COMPLETE (See docs/PHASE_2_COMPLETE.md)

---

### Task 2.1: Create Backup Service

**Why:** Bobby's biggest weakness is data loss on reinstall. This is a competitive differentiator.

**Location:** `lib/data/services/backup_service.dart`

**Requirements:**

1. **Export Functionality**
   - Serialize all subscriptions to JSON array
   - Add metadata header:
     ```json
     {
       "app": "CustomSubs",
       "version": "1.0.0",
       "exportDate": "2026-02-04T14:30:00Z",
       "subscriptionCount": 12,
       "subscriptions": [...]
     }
     ```
   - Format: `customsubs_backup_YYYY-MM-DD.json`
   - Use `share_plus` to open system share sheet
   - User can save to Files, email, AirDrop, cloud storage

2. **Import Functionality**
   - Use `file_picker` to select `.json` file
   - Parse and validate JSON structure
   - Check app version compatibility
   - Show confirmation dialog with preview:
     - "Found X subscriptions. Import?"
     - List subscription names
     - Option to skip duplicates or merge
   - Duplicate detection: match by name + amount + cycle
   - After import, reschedule all notifications

3. **Settings Integration**
   - "Export Backup" button → trigger export
   - "Import Backup" button → file picker + import flow
   - Display last backup date (store in settings)
   - Show "Never backed up" warning if never exported

4. **Backup Reminder**
   - After user adds 3rd subscription, show one-time dialog:
     - "Tip: Back up your subscriptions in Settings"
     - "Don't show again" checkbox
   - Store reminder shown state in settings

**Implementation Details:**
- Use Riverpod provider for service
- Methods:
  - `Future<String> exportToJson()` - Returns JSON string
  - `Future<void> shareBackup()` - Triggers share sheet
  - `Future<void> importFromFile()` - File picker + import
  - `Future<ParseResult> parseBackupFile(String json)` - Validate + parse (per-item error isolation)
- Handle errors gracefully (invalid JSON, wrong format, etc.)

**Files to Create/Modify:**
- ➕ Create: `lib/data/services/backup_service.dart`
- ➕ Create: `lib/features/settings/widgets/backup_reminder_dialog.dart`
- ✏️ Modify: `lib/features/settings/settings_screen.dart`
- ✏️ Modify: `lib/features/home/home_controller.dart` (trigger reminder)

**Testing Checklist:**
- [ ] Export creates valid JSON file
- [ ] Share sheet opens and allows saving to Files app
- [ ] Import can read exported JSON
- [ ] Import validates JSON structure
- [ ] Import detects and skips duplicates
- [ ] Import reschedules all notifications
- [ ] Last backup date displays correctly
- [ ] Backup reminder shows after 3rd subscription
- [ ] Reminder doesn't show again after dismissed

**Estimated Time:** 3-4 hours

---

## 📋 PHASE 3: Enhanced Features

**Goal:** Complete feature set with analytics and polish
**Estimated Time:** 4-5 hours
**Priority:** MEDIUM - Adds value but not blocking

---

### Task 3.1: Build Analytics Screen

**Why:** Home screen has "Analytics" button that goes nowhere. Users expect spending insights.

**Location:** `lib/features/analytics/analytics_screen.dart`

**Requirements:**

1. **Monthly Total Card**
   - Large number: total monthly equivalent in primary currency
   - Comparison: "Up $X from last month" (or down)
   - Store monthly snapshot in Hive each time analytics opens
   - Calculate comparison from previous month's snapshot

2. **Category Breakdown**
   - Visual representation of spending by category
   - Options:
     - **Simple:** Sorted list with horizontal bars
     - **Advanced:** Pie chart (requires fl_chart package)
   - Show category name, amount, percentage
   - Sorted by highest spend first

3. **Top Subscriptions**
   - Ranked list of 5 most expensive subscriptions
   - Show name, monthly equivalent amount, icon/color
   - Tappable → navigate to detail screen

4. **Yearly Forecast**
   - Simple calculation: monthly total × 12
   - Display: "At this rate, you'll spend $X,XXX/year"

5. **Currency Breakdown** (if multi-currency)
   - Show total spend per currency before conversion
   - Example:
     - $234.50 USD
     - €45.00 EUR
     - Total: ~$279.23 USD (at bundled rates)

6. **Historical Tracking**
   - Create simple Hive box for monthly snapshots
   - Model: `{ month: "2026-02", total: 274.50 }`
   - Store when analytics screen opens (once per month)

**Implementation Options:**

**Option A: Simple (Recommended for MVP)**
- Use basic Flutter widgets (Containers, Rows, Columns)
- Horizontal bar charts using colored containers
- No external chart library
- Faster to implement, easier to maintain
- **Estimated time:** 2-3 hours

**Option B: Advanced Charts**
- Use `fl_chart` package (popular, well-maintained)
- Pie chart for categories
- Line chart for monthly trends
- Better visual appeal
- **Estimated time:** 4-5 hours

**Recommendation:** Start with Option A for MVP. Can upgrade to Option B in Phase 4 (post-launch polish).

**Files to Create/Modify:**
- ➕ Create: `lib/features/analytics/analytics_screen.dart`
- ➕ Create: `lib/features/analytics/analytics_controller.dart`
- ➕ Create: `lib/data/models/monthly_snapshot.dart` (Hive model)
- ➕ Create: `lib/features/analytics/widgets/category_breakdown_card.dart`
- ➕ Create: `lib/features/analytics/widgets/top_subscriptions_card.dart`
- ✏️ Modify: `lib/app/router.dart` (add analytics route)
- ✏️ Modify: `lib/features/home/home_screen.dart` (hook up Analytics button)

**Testing Checklist:**
- [ ] Analytics screen displays correct monthly total
- [ ] Category breakdown shows all categories with subscriptions
- [ ] Percentages add up to 100%
- [ ] Top 5 subscriptions display correctly
- [ ] Yearly forecast calculation is accurate
- [ ] Multi-currency breakdown displays if applicable
- [ ] Monthly snapshot stores correctly
- [ ] Comparison shows correct increase/decrease

**Estimated Time:** 2-3 hours (simple) or 4-5 hours (with charts)

---

### Task 3.2: Cancellation Management Screen (Optional)

**Why:** Spec calls for step-by-step cancellation flow. Currently empty folder.

**Status:** This can be deferred to Phase 4 (post-MVP) since:
- Cancellation info is already captured in subscription form
- Detail screen will display cancellation URL, phone, notes, checklist
- Dedicated cancellation screen adds polish but isn't blocking

**If implementing now:**
- Create `lib/features/cancellation/cancellation_checklist_screen.dart`
- Show full-screen checklist view with progress
- Large checkboxes, clear instructions
- "Open Cancel Page" and "Call Support" buttons
- Confetti animation when all steps complete

**Estimated Time:** 2-3 hours
**Recommendation:** Defer to Phase 4 unless cancellation is a key differentiator you want to highlight at launch.

---

## 📋 PHASE 4: Quality & Testing

**Goal:** Fix warnings, refactor code, validate notifications
**Estimated Time:** 3-4 hours
**Priority:** HIGH - Ensures production quality

---

### Task 4.1: Fix Deprecation Warnings

**Why:** 40+ analyzer warnings make future maintenance harder. Clean code = easier debugging.

**Issues to Fix:**

1. **Color.value → Color.toARGB32()** (7 instances)
   - `lib/features/add_subscription/add_subscription_screen.dart` (line 43, 235)
   - `lib/features/add_subscription/widgets/color_picker_widget.dart` (line 21, 24)
   - `docs/templates/form-screen.dart` (line 235) - can delete this file if it's just a template

2. **withOpacity() → withValues()** (7 instances)
   - `lib/features/add_subscription/widgets/template_grid_item.dart` (line 39)
   - `lib/features/home/home_screen.dart` (lines 97, 327, 334, 402, 441, 499)

3. **Add explicit type annotations**
   - `lib/features/home/home_screen.dart:344` (uninitialized field)

4. **Fix dangling library doc comments** (4 instances)
   - `lib/app/app.dart`
   - `lib/app/router.dart`
   - `lib/core/utils/currency_utils.dart`
   - `lib/core/utils/service_icons.dart`
   - Solution: Move doc comments inside the library tag or remove

5. **Add const constructors** (5 instances)
   - `lib/app/theme.dart` (lines 13, 133)
   - `lib/features/onboarding/onboarding_screen.dart` (lines 78, 79)

6. **Fix deprecated Riverpod ref types** (2 instances)
   - `NotificationServiceRef` → `Ref`
   - `TemplateServiceRef` → `Ref`

7. **Clean up template files causing errors**
   - Move `docs/templates/*.dart` to a non-analyzed location or add to analysis_options.yaml exclude

**Files to Modify:**
- ✏️ All files listed above
- ✏️ `analysis_options.yaml` (exclude templates if keeping them)

**Estimated Time:** 1 hour

---

### Task 4.2: Refactor Large Files

**Why:** Improves maintainability and testability.

**Files Needing Refactoring:**

1. **`lib/features/add_subscription/add_subscription_screen.dart` (600+ lines)**
   - Extract form sections into separate widgets:
     - `_BasicInfoSection` (name, amount, currency, cycle)
     - `_DatesSection` (next billing, start date)
     - `_TrialSection` (trial toggle + fields)
     - `_CancellationSection` (URL, phone, notes, checklist)
     - `_RemindersSection` (already extracted)
   - Keep controller in main screen
   - Benefits: Easier to test, better readability

2. **`lib/features/home/home_screen.dart` (~500 lines)**
   - Already has some widget extraction
   - Consider extracting:
     - `_SubscriptionTile` to separate file
     - `_TrialsEndingSoonCard` to separate file
   - Optional: move to `widgets/` subfolder

**Recommendation:** Only refactor if time permits. Not blocking for MVP, but improves long-term maintainability.

**Estimated Time:** 2-3 hours (if doing full refactor)

---

### Task 4.3: End-to-End Notification Testing

**Why:** Notifications are the #1 feature. They MUST work reliably. This is the competitive advantage.

**Testing Requirements:**

**Device Setup:**
- [ ] iOS physical device (iPhone 12 or newer, iOS 15+)
- [ ] Android physical device (API 33+ for permission flow)
- [ ] Do NOT rely on simulators/emulators for notification testing

**Test Cases:**

1. **Permission Request**
   - [ ] Fresh install → onboarding → permission dialog appears
   - [ ] Granting permission works
   - [ ] Denying permission is handled gracefully
   - [ ] App explains how to re-enable in system settings

2. **Regular Subscription Notifications**
   - [ ] Create subscription with next billing in 10 minutes
   - [ ] Set first reminder: 8 minutes before
   - [ ] Set second reminder: 2 minutes before
   - [ ] Enable day-of reminder
   - [ ] Wait and verify all 3 notifications fire
   - [ ] Check notification content (title, body, formatting)
   - [ ] Tapping notification opens app

3. **Trial Notifications**
   - [ ] Create trial subscription ending in 15 minutes
   - [ ] Verify 3-day, 1-day, and day-of reminders schedule
   - [ ] Wait and verify trial-end notification fires
   - [ ] Check trial notification content

4. **Notification Management**
   - [ ] Edit subscription → verify old notifications canceled
   - [ ] Edit subscription → verify new notifications scheduled
   - [ ] Delete subscription → verify all notifications canceled
   - [ ] Pause subscription → verify notifications canceled
   - [ ] Resume subscription → verify notifications rescheduled

5. **App State Scenarios**
   - [ ] Notifications fire when app is in foreground
   - [ ] Notifications fire when app is in background
   - [ ] Notifications fire when app is killed
   - [ ] Notifications survive device reboot (iOS/Android differ)
   - [ ] Notifications survive app reinstall (should NOT - expected)

6. **Edge Cases**
   - [ ] Scheduling notification in the past (should skip)
   - [ ] Scheduling 100+ subscriptions (performance test)
   - [ ] Changing device timezone (notifications adjust)
   - [ ] Device in low-power mode (may delay on iOS)
   - [ ] Android 12+ exact alarm permissions

7. **Settings Test**
   - [ ] "Test Notification" button fires immediately
   - [ ] Test notification displays correctly

**Known Platform Limitations:**
- **iOS:** Notifications may not fire if app is killed and device is in low-power mode
- **Android 12+:** May require SCHEDULE_EXACT_ALARM permission for precise timing
- **Android Doze:** exactAllowWhileIdle should work, but test with device unplugged

**Bug Reporting:**
- Document any notification failures with:
  - Device model and OS version
  - Notification type (first reminder, day-of, etc.)
  - App state (foreground, background, killed)
  - Expected vs actual behavior
  - adb logcat output (Android) or Xcode console (iOS)

**Estimated Time:** 2-3 hours (testing + fixing issues)

---

## 📊 Success Criteria

### Minimum Viable Product (MVP) Requirements

**Core Functionality:**
- ✅ User can add subscriptions (manual or from template)
- ✅ User can view all subscriptions on home screen
- ✅ User can see upcoming charges sorted by date
- ✅ User receives notifications before billing dates
- ✅ User can edit subscriptions
- ✅ User can delete subscriptions
- ✅ User can view subscription details
- ✅ User can mark subscriptions as paid
- ✅ User can pause/resume subscriptions
- ✅ User can export backup
- ✅ User can import backup
- ✅ User can view spending analytics

**Quality Bars:**
- Zero crashes on happy path flows
- No analyzer errors (warnings acceptable if documented)
- Notifications fire reliably on both iOS and Android
- All data persists across app restarts
- Smooth 60fps performance on lists/scrolling
- Forms validate input properly

**User Experience:**
- Onboarding is clear and fast (<30 seconds)
- Home screen loads instantly (<1 second)
- Adding a subscription takes <60 seconds
- App feels polished and trustworthy
- No dead-end screens or broken buttons

---

## ⚠️ Known Limitations & Trade-offs

### Intentional Limitations (Per Spec)

1. **No dark mode** - Deferred to Phase 4 (post-launch)
2. **No home screen widgets** - Future feature
3. **No cloud sync** - By design (privacy-first)
4. **No bank linking** - By design (privacy-first)
5. **Bundled exchange rates** - Updated with app releases, not real-time
6. **Light mode only** - Simpler for MVP

### Technical Trade-offs

1. **Main.dart notification rescheduling**
   - Current: Reschedules ALL subscriptions on every app launch
   - Trade-off: Simple implementation, but slow with 100+ subscriptions
   - Future optimization: Only reschedule if OS cleared notifications

2. **No automated testing**
   - Current: Manual testing only
   - Trade-off: Faster initial development
   - Future: Add widget tests for critical flows

3. **Simple analytics charts**
   - Current: Basic bars using Container widgets
   - Trade-off: Fast to implement, but less visually impressive
   - Future: Upgrade to fl_chart for better visuals

4. **No in-app subscription editing from detail screen**
   - Current: Edit button navigates to full add/edit screen
   - Trade-off: Reuses existing form, simpler
   - Future: Could add inline editing for quick changes

---

## 🗓️ Estimated Timeline

**Phase 1: Critical Completions** (Days 1-2)
- Task 1.1: Subscription Detail Screen - 4 hours
- Task 1.2: Mark as Paid UI - 1 hour
- Task 1.3: Currency Picker - 2 hours
- **Total: 7 hours**

**Phase 2: Data Safety** (Day 3)
- Task 2.1: Backup Service - 4 hours
- **Total: 4 hours**

**Phase 3: Enhanced Features** (Day 4)
- Task 3.1: Analytics Screen (simple) - 3 hours
- **Total: 3 hours**

**Phase 4: Quality & Testing** (Day 5)
- Task 4.1: Fix Deprecation Warnings - 1 hour
- Task 4.3: E2E Notification Testing - 3 hours
- **Total: 4 hours**

**Grand Total: 18 hours** (2-3 days of focused development)

---

## 📁 File Structure After Completion

```
lib/
├── app/
│   ├── app.dart
│   ├── router.dart ✏️ (add analytics route)
│   └── theme.dart ✏️ (fix const warnings)
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_sizes.dart
│   │   ├── subscription_templates.dart
│   │   └── supported_currencies.dart ➕ NEW
│   ├── extensions/
│   │   ├── date_extensions.dart
│   │   └── currency_extensions.dart
│   └── utils/
│       ├── currency_utils.dart ✏️
│       └── service_icons.dart ✏️
│
├── data/
│   ├── models/
│   │   ├── subscription.dart
│   │   ├── subscription_cycle.dart
│   │   ├── subscription_category.dart
│   │   ├── reminder_config.dart
│   │   └── monthly_snapshot.dart ➕ NEW
│   ├── repositories/
│   │   └── subscription_repository.dart
│   └── services/
│       ├── notification_service.dart ✏️
│       ├── template_service.dart
│       └── backup_service.dart ➕ NEW
│
├── features/
│   ├── onboarding/
│   │   └── onboarding_screen.dart ✏️
│   │
│   ├── home/
│   │   ├── home_screen.dart ✏️ (paid badges, fix warnings)
│   │   └── home_controller.dart ✏️
│   │
│   ├── add_subscription/
│   │   ├── add_subscription_screen.dart ✏️ (fix warnings)
│   │   ├── add_subscription_controller.dart
│   │   └── widgets/ (color picker, reminder config, etc.)
│   │
│   ├── subscription_detail/ ⭐ MAJOR WORK
│   │   ├── subscription_detail_screen.dart ✏️ (full implementation)
│   │   ├── subscription_detail_controller.dart ➕ NEW
│   │   └── widgets/
│   │       ├── billing_info_card.dart ➕ NEW
│   │       ├── cancellation_card.dart ➕ NEW
│   │       └── detail_action_buttons.dart ➕ NEW
│   │
│   ├── analytics/ ⭐ MAJOR WORK
│   │   ├── analytics_screen.dart ➕ NEW
│   │   ├── analytics_controller.dart ➕ NEW
│   │   └── widgets/
│   │       ├── category_breakdown_card.dart ➕ NEW
│   │       ├── top_subscriptions_card.dart ➕ NEW
│   │       └── monthly_total_card.dart ➕ NEW
│   │
│   ├── settings/ ⭐ ENHANCE
│   │   ├── settings_screen.dart ✏️ (hook up backup/currency)
│   │   └── widgets/
│   │       ├── currency_picker_dialog.dart ➕ NEW
│   │       └── backup_reminder_dialog.dart ➕ NEW
│   │
│   └── cancellation/ (OPTIONAL - defer to Phase 4)
│       └── cancellation_checklist_screen.dart
│
└── main.dart
```

**Legend:**
- ✏️ = Modify existing file
- ➕ = Create new file
- ⭐ = Major work required

---

## 🎯 Post-MVP Future Enhancements

**Phase 4: Advanced Features** (Post-Launch)
- Dark mode support
- Dedicated cancellation flow screen
- Advanced charts (fl_chart integration)
- Spending trends over time
- Budget alerts ("You're spending more than usual")
- Category-based insights
- Home screen widgets (iOS/Android)
- iCloud backup option (iOS)
- App shortcuts
- Localization (i18n)

**Phase 5: Long-term Ideas**
- Receipt scanning (OCR)
- Custom recurring patterns (every 3 months, etc.)
- Shared subscriptions (family plans)
- Price change alerts
- Annual subscription vs monthly cost comparison
- Subscription recommendations ("You might be paying too much for X")

---

## 🔧 Development Guidelines

### Code Standards
- Follow existing patterns in the codebase
- Use Riverpod code generation for all providers
- Document all public methods with dartdoc comments
- Prefer composition over inheritance
- Keep widgets small and focused

### Testing Approach
- Manual testing for MVP (automated tests post-launch)
- Test on both iOS and Android physical devices
- Test with various subscription counts (0, 1, 5, 20, 100)
- Test edge cases (past dates, future dates, same-day billing)

### Git Workflow
- Create feature branches for each major task
- Commit messages: "feat: Add subscription detail screen" or "fix: Color deprecation warnings"
- Keep commits atomic (one logical change per commit)
- Run `flutter analyze` before committing

### Performance Targets
- Home screen first render: <1 second
- Add subscription screen: <500ms
- List scrolling: 60fps
- Notification scheduling: <2 seconds for 100 subscriptions

---

## 📞 Questions for Review

Before starting implementation, please review and answer:

1. **Phase Priority:** Do you agree with the phase order (Critical → Data Safety → Enhanced → Quality)?

2. **Analytics:** Simple widgets (2-3 hours) or advanced charts with fl_chart (4-5 hours)?

3. **Cancellation Screen:** Implement now or defer to Phase 4?

4. **File Refactoring:** Full refactor of large files (3 hours) or skip for MVP?

5. **Timeline:** 18-hour estimate acceptable, or should we cut scope to hit a specific deadline?

6. **Testing:** Will you be available to test on physical devices, or should we set up TestFlight/internal testing?

7. **Launch Target:** Do you have a target launch date (App Store / Play Store)?

8. **Feature Cuts:** Anything in this plan you want to cut or defer?

9. **Additional Features:** Anything missing from this plan that's critical for your vision?

10. **Design Polish:** Should we allocate time for visual polish (animations, transitions, micro-interactions)?

---

## ✅ Approval & Sign-off

**Once you review this plan, please approve one of these options:**

- ✅ **Option A: Full Plan** - Implement all phases as outlined (18 hours)
- ✅ **Option B: Critical Only** - Phase 1 + 2 only (11 hours)
- ✅ **Option C: Modified Plan** - Specific changes (document below)
- ✅ **Option D: Hold** - Review needed, questions/concerns below

**Your decision:** _________________

**Modifications/Notes:**
_________________________________________
_________________________________________
_________________________________________

**Approved by:** _________________
**Date:** _________________

---

## 📄 Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-02-04 | Claude | Initial plan created |

---

**Next Steps After Approval:**
1. Create feature branch: `git checkout -b feature/mvp-completion`
2. Update this document with any modifications
3. Begin Phase 1, Task 1.1
4. Commit progress regularly
5. Test each phase before moving to next
6. Update README.md roadmap as features complete

