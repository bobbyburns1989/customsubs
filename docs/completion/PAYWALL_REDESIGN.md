# Paywall Redesign — Compact Single-Screen Layout

**Date:** February 26, 2026
**Status:** ✅ Complete
**Version:** v1.4.x
**File changed:** `lib/features/paywall/paywall_screen.dart` (only)

---

## Objective

Make the paywall fit on a single iPhone screen (iPhone 14+) without scrolling, while preserving all Apple compliance requirements and purchase logic.

---

## Problem: Why It Was Too Tall

The original layout overflowed iPhone 14 (730px usable height) by ~146px:

| Element | Height |
|---------|--------|
| Large icon (80px) + xl spacing | ~104px |
| Tall bordered price box (20px padding, 36px font) | ~110px |
| Trial text + `xxxl` gap (48px) | ~68px |
| 4 feature rows (tall icon container + 2-line text) × 4 | ~320px |
| Amber warning banner + `xxxl` gap | ~100px |
| Subscribe button + terms + restore + legal + fine print | ~174px |
| **Total** | **~876px** |

---

## Solution: What Changed

Only `build()` and helper methods were rewritten. All logic (`_handlePurchase`, `_handleRestore`, `_preloadOffering`, `_openUrl`) is byte-for-byte identical.

### Space Savings

| Change | Saved |
|--------|-------|
| Icon: 80px → 56px | ~24px |
| Tall price box → inline subtitle line | ~50px |
| Removed amber warning banner (info moved to fine print) | ~100px |
| Feature rows: tall (80px) → compact checkmarks (32px) × 4 | ~192px |
| `xxxl` (48px) spacers × 3 → `xl`/`md` | ~84px |
| Restore + Terms + Privacy → single bottom row | ~40px |
| **Total saved** | **~490px** |

**New estimated height:** ~580px — fits iPhone 14+ with comfortable margin.

### New Layout

```
[X]          Go Premium              ← AppBar
────────────────────────────────────
         ⭐  (56px icon)
      Go Premium
   $0.99/month · 3-day free trial   ← price + trial inline (green, 16px bold)

✓  Unlimited subscriptions          ← compact checkmark rows
✓  All reminders — 7-day, 1-day, day-of
✓  Spending analytics & yearly forecast
✓  Backup & restore your data

[  Subscribe for $0.99/month  ]     ← big green button

Free for 3 days, then $0.99/month. Renews monthly. Cancel anytime.

Restore  ·  Terms  ·  Privacy       ← single row
Managed through App Store. Free tier: 7 subscriptions.
────────────────────────────────────
```

---

## What Did NOT Change

- All purchase logic: `_handlePurchase()`, `_handleRestore()`, `_preloadOffering()`
- Subscribe button never disabled by `_offeringError` (Build 33 Apple fix preserved)
- Dynamic pricing from StoreKit (`_monthlyPackage?.storeProduct.priceString`)
- Dynamic trial period from StoreKit (`introductoryPrice.period`)
- All error dialogs, snackbars, and structured error details
- `_isTablet()` helper retained (available for future tablet-specific layout)
- `SingleChildScrollView` retained — iPhone SE can still scroll if needed
- `EntitlementService`, `revenue_cat_constants.dart`, `router.dart` — untouched

---

## New Helper: `_buildCompactFeatureRow()`

Replaces the old `_buildFeatureItem()` (which had a 48px icon container + 2-line subtitle).

```dart
Widget _buildCompactFeatureRow(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
    child: Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ),
      ],
    ),
  );
}
```

---

## Apple Compliance

All App Store subscription disclosure requirements remain satisfied:

- **Price prominent**: Shown as bold green text (`fontSize: 16, fontWeight: w600`) directly under the title — always visible without scrolling
- **Trial terms**: Full disclosure below subscribe button: "Free for X days, then $X.XX/month. Renews monthly. Cancel anytime."
- **Subscribe button**: Never gated on `_offeringError` (Build 33 fix preserved)
- **Restore Purchases**: Accessible in the bottom row
- **Terms + Privacy**: Accessible in the bottom row

---

## Testing

1. Run on iPhone 14 simulator — screen fully visible without scrolling
2. Run on iPhone SE (2nd gen) simulator — minimal scroll if any
3. Loading state: inline spinner below title while `_isLoadingOffering`
4. Error state: inline warning with "Retry" link if `_offeringError != null`
5. Subscribe: confirm purchase flow works end-to-end
6. Restore: confirm restore flow works
7. Legal links: Terms and Privacy open in browser
