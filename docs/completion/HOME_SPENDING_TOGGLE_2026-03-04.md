# Home Spending Summary — Tap-to-Toggle Period

**Date:** 2026-03-04
**Status:** ✅ Complete
**Files modified:**
- `lib/features/home/home_screen.dart`

---

## Problem

The `_SpendingSummaryCard` on the home screen showed a static monthly total with a hardcoded `/month` label. Users who think in yearly terms (especially after seeing the Analytics yearly forecast) had to mentally multiply. The yearly and daily values were already calculated elsewhere in the app but not surfaced on the home screen.

---

## Changes

### Single file — `_SpendingSummaryCard` widget only

**Added `_SpendingPeriod` enum** (file-private, above the widget class):
```dart
enum _SpendingPeriod { monthly, yearly, daily }
```

**State added to `_SpendingSummaryCardState`:**
- `_period` — current period (default: `monthly`)
- `_tweenBegin` — animation start point (replaces old `_displayValue`)

**Computed properties:**
- `_targetAmount` — derives the display value from `monthlyTotal` based on current period
- `_periodLabel` — `/month`, `/year`, or `/day`
- `_amountForPeriod(monthly, period)` — formula helper (monthly · 12 → yearly; yearly ÷ 365 → daily)

**Formulas** (consistent with `analytics_controller.dart` and `analytics_screen.dart`):
```dart
yearly = monthlyTotal * 12
daily  = monthlyTotal * 12 / 365
```

**Tap cycling (`_cyclePeriod`):**
```dart
void _cyclePeriod() {
  setState(() {
    _tweenBegin = _targetAmount; // Capture current amount before switching
    _period = _SpendingPeriod.values[
      (_period.index + 1) % _SpendingPeriod.values.length
    ];
  });
}
```
Wraps the entire `Container` in a `GestureDetector(onTap: _cyclePeriod)`.

**Amount animation:** The existing `TweenAnimationBuilder<double>` (800ms, easeOutCubic) now targets `_targetAmount` instead of `widget.monthlyTotal`. Animates naturally on both period toggle and live `monthlyTotal` updates.

**Label animation:** Replaced static `Text('/month')` with `AnimatedSwitcher` (200ms crossfade). `ValueKey(_period)` forces the switcher to recognize the text as a different widget on each toggle.

**Dot page indicator:** 3 `AnimatedContainer` dots (250ms) between the label and the subscription count row. Active dot: 14×4px, 85% white opacity. Inactive: 6×4px, 30% opacity. Hints that the card is tappable without cluttering the UI.

**`didUpdateWidget` updated:** Now computes the old period-adjusted amount via `_amountForPeriod(oldWidget.monthlyTotal, _period)` so a live data refresh animates from the correct baseline regardless of which period is active.

---

## What Did NOT Change

- `_SpendingSummaryCard` constructor — no new parameters
- Home screen call site — untouched
- `HomeController` — no new methods (yearly/daily derived in-widget)
- Analytics screen — untouched
- Data layer, models, repository — untouched

---

## Edge Cases

- **$0 total:** all three periods display `$0.00` — no division by zero
- **Multi-currency:** `monthlyTotal` is already converted to primary currency by `HomeController.calculateMonthlyTotal()` before reaching the card
- **Paused subs:** excluded from `monthlyTotal` by controller — all three periods correctly reflect active-only spending
- **Mid-animation tap:** `_tweenBegin` is set to `_targetAmount` (the computed end of the previous animation intent), so rapidly tapping feels responsive rather than jumping
