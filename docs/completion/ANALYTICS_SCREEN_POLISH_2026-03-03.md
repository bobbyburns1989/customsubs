# Analytics Screen Polish

**Date:** 2026-03-03
**Status:** ✅ Complete
**Files modified:**
- `lib/features/analytics/analytics_screen.dart`
- `lib/features/analytics/widgets/category_donut_chart.dart`

---

## Changes

### 1. Yearly Forecast Card — Layout & Hierarchy

**Problems fixed:**
- Card had `margin: EdgeInsets.symmetric(horizontal: AppSizes.lg)` (20px extra) making it 16px narrower on each side than every other card on the screen.
- Three identical-weight stat lines below the big number ("At current rate", sub count, daily cost) had no visual separation from the hero amount.
- Monthly total was not shown — users had to mentally divide yearly by 12.
- `monthlyChange` was calculated by the controller but never displayed.

**Changes:**
- Removed extra horizontal margin — card now fills content area consistently.
- Added `$X.XX/mo` secondary line directly below the animated yearly number.
- Replaced 3 stat lines with one compact line: `"N subscriptions · $X.XX/day"`.
- Added a `Container(height: 1, color: white 18%)` divider between the number block and stats.
- Added `_buildChangeChip()` — renders `↑ $X.XX/mo from last month` (orange) or `↓ $X.XX/mo from last month` (green) only when `analytics.monthlyChange != null`. Null on first launch (no prior snapshot), so no broken UI.

### 2. Donut Chart — Center Overlay + Clipping Fix

**Problem:** `PieChartSectionData.title` rendered the `"100.0%"` percentage label on the slice face. With a single category (full circle), the label rendered at the 9 o'clock position and was clipped by the chart bounds.

**Fix:** Moved all percentage information to a **center text overlay** using a `Stack`.

- `PieChartSectionData.title` is now `''` on all sections — no on-slice labels.
- `_buildBadge()` removed (was showing subscription count as a floating chip outside the chart).
- Center overlay (`IgnorePointer` + `AnimatedSwitcher`):
  - **Default state**: "Monthly" label + total amount
  - **Touched state**: Category name + amount + percentage (crossfades via `AnimatedSwitcher` keyed on label+amount string)
- `centerSpaceRadius` 60 → 65 (larger hole for text readability).
- Chart `SizedBox` height 240 → 210px.
- Section touch radius unchanged: 46px default, 52px on touch.

---

## No controller changes

`AnalyticsData.monthlyChange` and `AnalyticsData.monthlyTotal` were already calculated. This was purely a UI-layer fix.

---

## Testing

- Single category: center shows total, no clipping
- Multiple categories: tap each slice to see name/amount/% in center
- Month-over-month chip: only visible after second calendar month opens analytics (snapshot saved on first visit)
- Card alignment: forecast card now visually flush with category + top subs cards below it
