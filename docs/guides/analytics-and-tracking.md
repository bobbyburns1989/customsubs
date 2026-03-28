# Analytics & Tracking

**Status**: Active
**Last Updated**: March 25, 2026 (v1.4.9 — crash analytics, growth events, in-app review)
**Relevant to**: Developers

**Guide for working with PostHog analytics, crash reporting, and in-app review in CustomSubs.**

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Crash Reporting](#crash-reporting)
4. [Tracking Custom Events](#tracking-custom-events)
5. [Screen View Tracking](#screen-view-tracking)
6. [In-App Review](#in-app-review)
7. [Opt-Out Mechanism](#opt-out-mechanism)
8. [Event Reference](#event-reference)
9. [Adding a New Event](#adding-a-new-event)
10. [Testing](#testing)

---

## Overview

CustomSubs uses **PostHog** (`posthog_flutter: ^5.20.0`) for anonymous analytics. It is one of two outbound SDKs (the other is RevenueCat for IAP). Key principles:

- **No PII** — all event properties are categorical/boolean only. Never log subscription names, amounts, or user-entered text.
- **Opt-out available** — users toggle "Share Anonymous Usage Data" in Settings > Privacy. The SDK stops sending events immediately.
- **Fire-and-forget** — PostHog batches events internally. `capture()` calls are synchronous no-ops if opted out.
- **Crash reporting built-in** — PostHog's error tracking autocapture hooks Flutter errors, platform errors, and isolate errors automatically.

### Configuration

| Constant | Value | File |
|----------|-------|------|
| API Key | `phc_Covar...` | `lib/core/constants/posthog_constants.dart` |
| Host | `https://us.i.posthog.com` | same |
| Debug mode | `true` (sends events in debug builds) | same |

---

## Architecture

### Files

| File | Role |
|------|------|
| `lib/data/services/analytics_service.dart` | Singleton wrapper around PostHog SDK. Handles init, capture, opt-out. |
| `lib/core/constants/posthog_constants.dart` | API key, host, debug flag. |
| `lib/data/services/review_service.dart` | In-app review prompt logic (triggers after 5th subscription). |
| `lib/app/router.dart` | `PosthogObserver()` on GoRouter for automatic screen view tracking. |

### Initialization Flow (main.dart)

```
1. WidgetsFlutterBinding.ensureInitialized()
2. Hive.initFlutter()
3. Future.wait([
     FlutterTimezone, CurrencyUtils, RevenueCat,
     AnalyticsService().init()     ← PostHog setup + crash hooks
   ])
4. analyticsService.capture('app_launched', {...})
5. runApp(...)
```

### Access Pattern

```dart
// In widgets/controllers with Riverpod ref:
final analytics = ref.read(analyticsServiceProvider);
analytics.capture('event_name', {'property': 'value'});

// In static utilities without ref (e.g., NotificationRouter):
AnalyticsService().capture('event_name', {'property': 'value'});
// Works because AnalyticsService uses a singleton factory constructor.
```

---

## Crash Reporting

Crash reporting is enabled via three config flags in `AnalyticsService.init()`:

```dart
config.errorTrackingConfig.captureFlutterErrors = true;
config.errorTrackingConfig.capturePlatformDispatcherErrors = true;
config.errorTrackingConfig.captureIsolateErrors = true;
```

This activates PostHog's `PostHogErrorTrackingAutoCaptureIntegration`, which automatically:

1. Hooks `FlutterError.onError` — catches widget build errors, layout errors, rendering errors
2. Hooks `PlatformDispatcher.instance.onError` — catches unhandled async errors
3. Hooks isolate error listener — catches isolate-level errors
4. Chains with existing handlers (calls the original handler after capturing)
5. Sends `$exception` events with full stack traces to PostHog

**No manual `try/catch` needed for crash reporting.** Unhandled exceptions are captured automatically.

**Opt-out respected:** Error tracking goes through the PostHog SDK, so it respects `Posthog().disable()`.

**View crashes:** PostHog dashboard > Error Tracking section.

---

## Tracking Custom Events

### Rules

1. **Event names**: `snake_case`, pattern `{noun}_{past_tense_verb}` (e.g., `subscription_created`)
2. **Properties**: categorical/boolean/int only. **Never** user-entered text, amounts, names, or PII.
3. **No await needed**: `capture()` is fire-and-forget (PostHog batches internally)
4. **Check opt-out**: The SDK handles this — you don't need to check manually

### Example

```dart
// In a widget with ref access:
ref.read(analyticsServiceProvider).capture('subscription_created', {
  'category': _category.name,         // enum name (categorical)
  'cycle': _cycle.name,               // enum name (categorical)
  'is_from_template': true,           // boolean
});

// In a static class without ref:
AnalyticsService().capture('notification_tapped', {
  'action': 'mark_paid',              // string literal (categorical)
  'notification_type': 'reminder1',   // string literal (categorical)
});
```

---

## Screen View Tracking

Handled automatically by `PosthogObserver()` on GoRouter in `lib/app/router.dart`. Every route change sends a `$screen` event with the route name. No manual code needed.

---

## In-App Review

### How It Works

`ReviewService` (`lib/data/services/review_service.dart`) prompts users for an App Store review after a meaningful success moment.

- **Trigger**: After the 5th subscription is created (new subs only, not edits)
- **Frequency**: Once ever (persisted via `has_shown_review_prompt` in Hive settings)
- **Rate limit**: Apple limits to 3 prompts per 365 days per app
- **Tracking**: Fires `review_prompt_shown` event before showing the prompt

### Integration Point

In `add_subscription_screen.dart`, after a successful save:

```dart
if (!isEditing) {
  final reviewService = ReviewService();
  await reviewService.incrementCreateCount();
  await reviewService.maybePromptReview();
}
```

### Hive Keys

| Key | Type | Description |
|-----|------|-------------|
| `subscription_create_count` | int | Incremented on each new subscription |
| `has_shown_review_prompt` | bool | Set to true after prompt fires |

---

## Opt-Out Mechanism

- **UI**: Settings > Privacy > "Share Anonymous Usage Data" toggle
- **Persistence**: Hive `settings` box, key `analytics_opt_out`
- **Effect**: Calls `Posthog().disable()` immediately — all future `capture()` calls are no-ops
- **Crash reporting**: Also disabled when opted out (goes through PostHog SDK)

```dart
// Read opt-out status
final isOptedOut = await analytics.isOptedOut();

// Set opt-out
await analytics.setOptOut(true);  // disables PostHog
await analytics.setOptOut(false); // re-enables PostHog
```

---

## Event Reference

### Automatic Events (PostHog SDK)

| Event | Trigger | Notes |
|-------|---------|-------|
| `$screen` | Every GoRouter navigation | Via `PosthogObserver` |
| `$exception` | Unhandled Flutter/platform/isolate errors | Via error tracking config |
| `Application Opened` | App foreground | Via `captureApplicationLifecycleEvents` |
| `Application Backgrounded` | App background | Via `captureApplicationLifecycleEvents` |

### Custom Events (30 total)

#### App Lifecycle (1)

| Event | Properties | File | Purpose |
|-------|-----------|------|---------|
| `app_launched` | `subscription_count`, `active_count`, `paused_count`, `premium_status`, `app_version` | `main.dart` | Cohort segmentation |

#### Onboarding (2)

| Event | Properties | File | Purpose |
|-------|-----------|------|---------|
| `onboarding_completed` | — | `onboarding_screen.dart` | Funnel completion |
| `notification_permission_result` | `granted` (bool) | `onboarding_screen.dart` | Permission friction |

#### Subscription Management (7)

| Event | Properties | File | Purpose |
|-------|-----------|------|---------|
| `template_selected` | `template_name`, `category` | `add_subscription_screen.dart` | Template popularity |
| `subscription_created` | `category`, `cycle`, `is_from_template`, `template_name` | `add_subscription_screen.dart` | Creation funnel |
| `subscription_edited` | `category`, `cycle` | `add_subscription_screen.dart` | Edit patterns |
| `subscription_deleted` | — | `home_controller.dart` | Churn signal |
| `subscription_marked_paid` | `is_paid` (bool) | `home_controller.dart` | Engagement |
| `subscription_paused` | `has_resume_date` (bool) | `home_controller.dart` | Pause adoption |
| `subscription_resumed` | — | `home_controller.dart` | Resume patterns |

#### Creation Funnel (3)

| Event | Properties | File | Purpose |
|-------|-----------|------|---------|
| `subscription_form_abandoned` | `had_name`, `had_amount`, `was_from_template` (all bool) | `add_subscription_screen.dart` | Drop-off diagnosis |
| `template_search_no_results` | — | `add_subscription_screen.dart` | Template library gaps |
| `premium_limit_reached` | `subscription_count` (int) | `add_subscription_screen.dart` | Free tier ceiling |

#### Notification Engagement (1)

| Event | Properties | File | Purpose |
|-------|-----------|------|---------|
| `notification_tapped` | `action` (mark_paid/view_detail), `notification_type` (reminder1/reminder2/dayof/trial_*) | `notification_router.dart` | Core value proof |

#### Premium / IAP (8)

| Event | Properties | File | Purpose |
|-------|-----------|------|---------|
| `paywall_viewed` | `source` (settings/limit_reached) | `add_subscription_screen.dart`, `settings_screen.dart` | Funnel entry |
| `purchase_started` | `price` | `paywall_screen.dart` | Conversion intent |
| `purchase_completed` | `price` | `paywall_screen.dart` | Revenue |
| `purchase_failed` | `error` | `paywall_screen.dart` | Error diagnosis |
| `purchase_cancelled` | — | `paywall_screen.dart` | Drop-off |
| `restore_started` | — | `paywall_screen.dart` | Restore usage |
| `restore_completed` | — | `paywall_screen.dart` | Restore success |
| `restore_failed` | `error` | `paywall_screen.dart` | Restore errors |

#### Feature Usage (7)

| Event | Properties | File | Purpose |
|-------|-----------|------|---------|
| `calendar_viewed` | `active_sub_count` (int) | `calendar_screen.dart` | Feature engagement |
| `calendar_day_tapped` | `has_subs` (bool), `sub_count` (int) | `calendar_screen.dart` | Calendar interaction |
| `backup_exported` | `subscription_count` (int) | `settings_screen.dart` | Data safety adoption |
| `backup_imported` | `imported_count`, `duplicates_skipped` (int) | `settings_screen.dart` | Migration usage |
| `cancellation_url_opened` | — | `cancellation_card.dart` | Cancellation feature value |
| `smart_insight_tapped` | `insight_type` (service_overlap/annual_savings/bundle_opportunity/high_spend_category) | `smart_insights_card.dart` | Insight engagement |
| `settings_changed` | `setting` (primary_currency/reminder_time/analytics_opt_out) | `settings_screen.dart` | Preference signals |

#### In-App Review (1)

| Event | Properties | File | Purpose |
|-------|-----------|------|---------|
| `review_prompt_shown` | — | `review_service.dart` | Review pipeline |

---

## Adding a New Event

1. **Choose the right place**: Capture in controllers for data mutations, in widgets for UI interactions, in services for background operations.

2. **Name it**: `{noun}_{past_tense_verb}` in `snake_case`. Match existing patterns.

3. **Pick properties**: Categorical/boolean/int only. Ask: "Would this be PII if combined with a user ID?" If yes, don't include it.

4. **Capture it**:
   ```dart
   // With ref:
   ref.read(analyticsServiceProvider).capture('feature_used', {
     'feature': 'some_feature',
   });

   // Without ref (static context):
   AnalyticsService().capture('feature_used', {
     'feature': 'some_feature',
   });
   ```

5. **Update this doc**: Add the event to the reference table above.

6. **Verify**: Check PostHog Live Events view after testing on device.

---

## Testing

### Verify Events Locally

1. Run the app in debug mode (`flutter run`)
2. Perform the action that should trigger the event
3. Open PostHog dashboard > Live Events — events appear within seconds
4. Toggle opt-out in Settings > Privacy and verify events stop

### Verify Crash Reporting

1. Unlock Developer Tools (tap version 11 times in Settings)
2. Add a temporary test crash button, or throw an unhandled exception
3. Check PostHog > Error Tracking for the `$exception` event with stack trace

### Verify In-App Review

1. Create 5 subscriptions on a **real device** (simulators may suppress the prompt)
2. Verify `review_prompt_shown` appears in PostHog Live Events
3. Apple may suppress the UI if the prompt has been shown recently — this is expected

### Verify Notification Tracking

1. Send a test notification from Settings
2. Tap the notification (body or action button)
3. Verify `notification_tapped` appears in PostHog with correct `action` and `notification_type`
