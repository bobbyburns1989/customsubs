# IAP & Premium — Implementation Guide

**Status**: ✅ Live in production
**Last Updated**: March 4, 2026
**Version**: v1.4.2+ (RevenueCat 9.x, purchases_flutter ^9.0.0)
**Relevant to**: Developers working on paywall, entitlement checks, or purchase flow

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Key Constants](#key-constants)
3. [Entitlement Check Pattern](#entitlement-check-pattern)
4. [Purchase Flow](#purchase-flow)
5. [Paywall Screen](#paywall-screen)
6. [Common Pitfalls](#common-pitfalls)
7. [App Store Connect — IAP Submission](#app-store-connect--iap-submission)
8. [RevenueCat Dashboard Notes](#revenuecat-dashboard-notes)
9. [Testing IAP](#testing-iap)

---

## Architecture Overview

```
User taps "Upgrade"
       ↓
PaywallScreen (lib/features/paywall/paywall_screen.dart)
       ↓
EntitlementService (lib/data/services/entitlement_service.dart)
       ↓
RevenueCat SDK (purchases_flutter: ^9.0.0)
       ↓
Apple StoreKit / Google Play Billing
```

**Two Riverpod providers drive premium state:**

```dart
// Async check — resolves to bool
final isPremiumProvider = AutoDisposeFutureProvider<bool>((ref) async {
  return ref.watch(entitlementServiceProvider).isPremium();
});

// The service itself
final entitlementServiceProvider = Provider<EntitlementService>((ref) {
  return EntitlementService();
});
```

**CRITICAL — `isPremiumProvider` is AutoDispose.** It does NOT stay subscribed between checks.
You must call `ref.invalidate(isPremiumProvider)` to force a fresh check after any purchase or restore.

---

## Key Constants

File: `lib/core/constants/revenue_cat_constants.dart`

```dart
class RevenueCatConstants {
  // API key — ALWAYS copy-paste, NEVER type manually
  // Both previous typos were visually ambiguous characters
  static const String apiKey = 'appl_rRzabPDSmVyXEYjWSaSuklniHEA';

  static const String productId = 'customsubs_premium_monthly';
  static const String entitlementId = 'premium';
  static const String defaultOfferingId = 'default';
  static const int maxFreeSubscriptions = 3; // Free tier limit
}
```

**API key history (do not repeat these mistakes):**
- Build 36: `app1_` (number 1 instead of lowercase L) → silent auth failure
- Build 43: `Sukt` instead of `Sukl` — visually ambiguous near end of key
- Rule: Always copy-paste from RevenueCat dashboard. Verify character by character if typing.

---

## Entitlement Check Pattern

### Checking premium status in a widget

```dart
// Watch the provider — rebuilds when status changes
final isPremiumAsync = ref.watch(isPremiumProvider);

isPremiumAsync.when(
  data: (isPremium) {
    if (!isPremium && subscriptionCount >= RevenueCatConstants.maxFreeSubscriptions) {
      // Show paywall
    }
  },
  loading: () => const SizedBox.shrink(),
  error: (e, _) => const SizedBox.shrink(), // Fail open (don't block user)
);
```

### Where `isPremiumProvider` must be invalidated

After any event that could change premium status, call:
```dart
ref.invalidate(isPremiumProvider);
```

This is required in **4 places**:
1. After a successful purchase — `paywall_screen.dart`
2. After a successful restore — `paywall_screen.dart`
3. After backup import in Settings — `settings_screen.dart`
4. **App foreground** — `home_screen.dart` in `didChangeAppLifecycleState(resumed)`

The app foreground invalidation (point 4) is the most important — it catches the case where a user purchases on another device or their subscription renews while the app is backgrounded.

---

## Purchase Flow

### Offering fallback — always use this pattern

```dart
final offerings = await Purchases.getOfferings();
final offering = offerings.current ?? offerings.all[RevenueCatConstants.defaultOfferingId];
```

**Never use `offerings.current` alone.** If RevenueCat sync lags on first launch, `current` is null and the purchase silently fails. The fallback ensures `all['default']` is used instead.

This fallback must be applied **everywhere** `Purchases.getOfferings()` is called — both in the pre-load and in `purchaseMonthlySubscription()`.

### iOS 18 workaround

```dart
// 500ms delay before presenting StoreKit sheet on iOS 18
// Prevents a race condition where the sheet appears then immediately dismisses
await Future.delayed(const Duration(milliseconds: 500));
final result = await Purchases.purchasePackage(package);
```

### Subscribe button — never permanently disable

The subscribe button must ALWAYS be tappable, even if the offering pre-load fails.

```dart
// WRONG — permanently disables button on pre-load error
onPressed: _isLoading || _offeringError != null ? null : _handlePurchase,

// CORRECT — only disable during active purchase
onPressed: _isLoading ? null : _handlePurchase,
```

The service layer handles retries with a fresh fetch in `_handlePurchase()`. Pre-load is an optimization only, not a requirement.

---

## Paywall Screen

File: `lib/features/paywall/paywall_screen.dart`

### Layout (compact — fits iPhone 14+ without scrolling)

```
[App Icon 56px]
[Title: "Go Premium"]
[Subtitle with price and trial inline]
[4 compact feature rows with checkmarks]
[Subscribe button — full width, always enabled]
[Restore · Terms · Privacy — single row]
```

The screen is wrapped in `SingleChildScrollView` as a fallback for smaller devices (iPhone SE).

### What must NOT change (Apple compliance)

- Price must always be visible (inline with trial info in subtitle)
- Trial terms must be displayed before purchase
- Subscribe button must never be permanently disabled
- Restore Purchases link must be present
- Terms of Service and Privacy Policy links must be present

### Error handling

- Pre-load errors show a "Retry" button but never block the subscribe button
- Purchase errors show a detailed dialog (helpful for TestFlight debugging)
- Restore errors show an alert with the RevenueCat error message

---

## Common Pitfalls

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| API key typo | RC_NOT_INITIALIZED or INVALID_CREDENTIALS | Copy-paste key from dashboard |
| Missing offering fallback | Purchase silently fails on first launch | Use `offerings.current ?? offerings.all['default']` |
| Subscribe button gated on `_offeringError` | Apple reviewer sees permanently disabled button | Remove `_offeringError` from `onPressed` condition |
| `isPremiumProvider` not invalidated on foreground | User purchases on another device, app doesn't reflect it | Add `ref.invalidate(isPremiumProvider)` in `didChangeAppLifecycleState(resumed)` |
| RevenueCat initialization gated on `getCustomerInfo()` | RC fails to initialize if customer fetch fails | Call `Purchases.configure()` unconditionally, don't gate it |

---

## App Store Connect — IAP Submission

### Product Details

- **Product ID**: `customsubs_premium_monthly`
- **Price**: $0.99/month
- **Free trial**: 3 days
- **Regions**: 175
- **Status**: Approved and live

### Critical submission rules

1. **IAP must ride with the binary.** On the version submission page in App Store Connect, add the IAP product in the "In-App Purchases and Subscriptions" section before submitting. Do NOT submit the IAP standalone via its own "Submit for Review" button.

2. **"Developer Action Needed" after binary rejection is normal.** Any time a binary is rejected, Apple automatically resets associated IAP products to "Developer Action Needed". This is not a content problem — resubmit with the next binary.

3. **Localization showing "Rejected" is a cascade effect.** Same root cause as above. Content is fine.

4. **RevenueCat mirrors Apple status.** If RevenueCat dashboard shows "Developer Action Needed", it reflects the Apple status. No RevenueCat config change needed.

### App-Specific Shared Secret

Configured in RevenueCat → Apps & providers → CustomSubs (App Store). Set up 2026-02-26. Labeled "Legacy" in RevenueCat — functions correctly.

**Upgrade path (not urgent)**: StoreKit 2 In-App Purchase Key. In App Store Connect → Users and Access → Keys → In-App Purchase tab → generate `.p8` key → paste Key ID + Issuer ID into RevenueCat.

---

## RevenueCat Dashboard Notes

- **Two apps exist**: "Test Store" and "CustomSubs (App Store)". Always use "CustomSubs (App Store)" for production config.
- **Entitlement**: `premium`
- **Offering**: `default` (ID matches `RevenueCatConstants.defaultOfferingId`)
- **Product**: `customsubs_premium_monthly`
- Trial display in paywall is fully dynamic from StoreKit `introductoryPrice` — no hardcoded trial text.

---

## Testing IAP

### Sandbox testing (TestFlight / Simulator)

1. Use a Sandbox Apple ID (create in App Store Connect → Users and Access → Sandbox Testers)
2. On device: Settings → App Store → SANDBOX ACCOUNT → sign in with sandbox credentials
3. Trigger a purchase — StoreKit sandbox intercepts it, no real charge occurs
4. Sandbox purchases restore to the same sandbox account

### Verifying entitlement refresh

1. Purchase on Sandbox → verify paywall dismisses and premium features unlock
2. Force-close app → reopen → verify premium state persists (cached by RevenueCat)
3. Background app → purchase on another device → foreground → verify `isPremiumProvider` refreshes (requires real device)

### Test notification for subscription state

Use "Test Notification" in Settings to verify the notification system works independently of IAP. These are separate concerns.

### Common sandbox issues

- **"Payment not allowed"**: iCloud not signed in on simulator, or parental controls active
- **"Product not found"**: IAP product not yet propagated from App Store Connect (can take up to 1 hour after creation)
- **Purchase sheet doesn't appear**: 500ms delay may need extending; check iOS version compatibility

---

## v1.4.x Lessons Learned

A summary of hard-won fixes from the v1.4.0 launch cycle (Builds 32–43):

| Build | Issue | Root Cause | Fix |
|-------|-------|------------|-----|
| 32→33 | Subscribe button permanently disabled for Apple reviewer | `_offeringError != null` in `onPressed` condition | Remove from disable condition; service layer retries |
| 36 | RC_NOT_INITIALIZED | API key `app1_` (number 1, not lowercase L) | Copy-paste key; never type manually |
| 38 | RC fails to initialize | `Purchases.configure()` gated on `getCustomerInfo()` | Configure unconditionally; don't gate on any network call |
| 43 | INVALID_CREDENTIALS | `Sukt` vs `Sukl` — visually ambiguous near end of key | Re-verified character-by-character from dashboard |

**SDK version note**: `purchases_flutter` upgraded `^8.x` → `^9.0.0` in Build 34 for iOS 26 compatibility. Version 8.x failed to initialize on iOS 26.3.

**Permanent rule**: The API key must always be copy-pasted from the RevenueCat dashboard. Both typos above were completely invisible at a glance.
