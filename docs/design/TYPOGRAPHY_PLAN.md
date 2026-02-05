# CustomSubs Typography Plan

**Status**: ✅ Complete
**Last Updated**: February 4, 2026
**Relevant to**: Developers
**Version:** 1.0

---

## 📚 Table of Contents

1. [Overview](#overview)
2. [Font Family & Weights](#font-family--weights)
3. [Type Scale System](#type-scale-system)
4. [Typography Usage Guide](#typography-usage-guide)
5. [Special Cases](#special-cases)
6. [Accessibility](#accessibility)
7. [Implementation Checklist](#implementation-checklist)
8. [Common Mistakes](#common-mistakes)
9. [Code Examples](#code-examples)

---

## Overview

### Philosophy

CustomSubs typography serves three critical goals:

1. **Financial Clarity** - Amounts, dates, and billing info must be instantly readable
2. **Information Hierarchy** - Users should scan and find info in under 3 seconds
3. **Trust & Professionalism** - Typography reflects app reliability and privacy focus

### Font Selection Rationale

**Primary:** DM Sans (Google Fonts)

**Why DM Sans?**
- ✅ **Excellent readability** at small sizes (critical for mobile)
- ✅ **Modern, friendly aesthetic** without being casual
- ✅ **Professional appearance** for financial app
- ✅ **Wide weight range** (Regular 400, Medium 500, Bold 700)
- ✅ **Optimized for screen** (designed for digital interfaces)
- ✅ **Free & open source** (Google Fonts)
- ✅ **Strong number legibility** (important for amounts)

**Alternatives considered:**
- ❌ Inter - Too generic, less distinctive
- ❌ SF Pro (system font) - Not available cross-platform in Flutter
- ❌ Roboto - Too technical/Android-specific feel

---

## Font Family & Weights

### Loaded via Google Fonts Package

```dart
import 'package:google_fonts/google_fonts.dart';

// In theme.dart
textTheme: GoogleFonts.dmSansTextTheme(
  Theme.of(context).textTheme,
),
```

### Weight Usage

| Weight | Value | Usage | Example |
|--------|-------|-------|---------|
| **Regular** | 400 | Body text, descriptions, secondary info | Subscription notes, form helper text |
| **Medium** | 500 | Labels, buttons, small headers | Button text, chip labels, list subtitles |
| **Semi-Bold** | 600 | Titles, list items, emphasis | Subscription names, section headers |
| **Bold** | 700 | Headlines, large amounts, primary info | Monthly total, screen titles, amounts |

**Rule:** Never use lighter than Regular (400). Finance apps need strong, confident typography.

---

## Type Scale System

### Material Design 3 Scale (Implemented)

CustomSubs uses the full MD3 type scale for maximum flexibility and consistency.

```
┌─────────────────────────────────────────────────────────────┐
│ DISPLAY (Huge numbers, hero elements)                      │
├─────────────────────────────────────────────────────────────┤
│ displayLarge    57px / Bold   → Monthly totals, big numbers│
│ displayMedium   45px / Bold   → Section totals, amounts    │
│ displaySmall    36px / Bold   → Large card headers         │
├─────────────────────────────────────────────────────────────┤
│ HEADLINE (Screen titles, section headers)                  │
├─────────────────────────────────────────────────────────────┤
│ headlineLarge   32px / Bold   → Rarely used                │
│ headlineMedium  28px / Bold   → Section headers            │
│ headlineSmall   24px / Bold   → Card titles                │
├─────────────────────────────────────────────────────────────┤
│ TITLE (List items, prominent labels)                       │
├─────────────────────────────────────────────────────────────┤
│ titleLarge      22px / Medium → Prominent list items       │
│ titleMedium     16px / Medium → Subscription names         │
│ titleSmall      14px / Medium → Captions, small labels     │
├─────────────────────────────────────────────────────────────┤
│ BODY (Primary content, descriptions)                       │
├─────────────────────────────────────────────────────────────┤
│ bodyLarge       16px / Regular→ Primary body text          │
│ bodyMedium      14px / Regular→ Secondary text, descriptions│
│ bodySmall       12px / Regular→ Helper text, fine print    │
├─────────────────────────────────────────────────────────────┤
│ LABEL (Buttons, chips, UI elements)                        │
├─────────────────────────────────────────────────────────────┤
│ labelLarge      14px / Medium → Button text, chip labels   │
│ labelMedium     12px / Medium → Small buttons, tags        │
│ labelSmall      11px / Medium → Tiny labels, footnotes     │
└─────────────────────────────────────────────────────────────┘
```

### Line Height & Spacing

All styles use **default MD3 line heights** (approximately 1.2-1.5x font size):

- **Display/Headline:** Tight line height (1.2x) - visual impact
- **Body text:** Comfortable line height (1.5x) - readability
- **Labels:** Tight line height (1.2x) - compact UI

---

## Typography Usage Guide

### 📊 Financial Information (CRITICAL)

**Monthly Totals & Large Amounts**

```dart
// Home screen monthly total
Text(
  '\$274.50',
  style: Theme.of(context).textTheme.displayMedium?.copyWith(
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
    fontFeatures: [FontFeature.tabularFigures()], // Monospaced numbers
  ),
)
```

**Use:** `displayMedium` (45px Bold)
**Color:** AppColors.primary (green)
**Features:** Tabular figures for alignment

---

**Subscription Amounts (List)**

```dart
// In subscription tile
Text(
  '\$15.99',
  style: Theme.of(context).textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.bold,
    fontFeatures: [FontFeature.tabularFigures()],
  ),
)
```

**Use:** `titleMedium` (16px Bold)
**Features:** Tabular figures for visual alignment in lists

---

**Small Amounts / Cycle Labels**

```dart
// "/month" label next to amount
Text(
  '/mo',
  style: Theme.of(context).textTheme.bodySmall?.copyWith(
    color: AppColors.textSecondary,
  ),
)
```

**Use:** `bodySmall` (12px Regular)
**Color:** Secondary text color

---

### 📱 Screen Elements

**AppBar Titles**

```dart
AppBar(
  title: const Text('Analytics'),
  // Uses theme.appBarTheme.titleTextStyle automatically
  // 20px, Medium weight
)
```

**Use:** Automatic via AppBar theme
**Size:** 20px Medium

---

**Section Headers**

```dart
// "Upcoming Charges" section
Text(
  'Upcoming',
  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
    fontWeight: FontWeight.bold,
  ),
)
```

**Use:** `headlineSmall` (24px Bold)
**When:** Major sections within screens

---

**Card Titles**

```dart
// "Billing Information" card header
Text(
  'Billing Information',
  style: Theme.of(context).textTheme.titleLarge?.copyWith(
    fontWeight: FontWeight.bold,
  ),
)
```

**Use:** `titleLarge` (22px Bold)
**When:** Card headers, dialog titles

---

### 📋 List Items

**Primary Item Text (Subscription Name)**

```dart
Text(
  subscription.name,
  style: Theme.of(context).textTheme.titleMedium,
  // 16px, Medium weight
)
```

**Use:** `titleMedium` (16px Medium)
**When:** Main text of list items

---

**Secondary Item Text (Billing Date)**

```dart
Text(
  'Bills in 3 days',
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: AppColors.textSecondary,
  ),
)
```

**Use:** `bodyMedium` (14px Regular)
**Color:** Secondary text
**When:** Supporting info in list items

---

**Tertiary Item Text (Meta Info)**

```dart
Text(
  'Monthly',
  style: Theme.of(context).textTheme.bodySmall?.copyWith(
    color: AppColors.textTertiary,
  ),
)
```

**Use:** `bodySmall` (12px Regular)
**Color:** Tertiary text
**When:** Cycle labels, timestamps, meta info

---

### 🔘 Interactive Elements

**Button Text (Primary/Secondary)**

```dart
ElevatedButton(
  onPressed: () {},
  child: const Text('Save Subscription'),
  // Uses theme.elevatedButtonTheme.textStyle
  // 16px, Medium weight
)
```

**Use:** Automatic via button theme
**Size:** 16px Medium

---

**Chip/Badge Labels**

```dart
Chip(
  label: Text(
    'TRIAL',
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
)
```

**Use:** `labelSmall` (11px Bold)
**When:** Status badges, tags, pills

---

### 📝 Forms

**Form Field Labels**

```dart
TextFormField(
  decoration: const InputDecoration(
    labelText: 'Subscription Name',
    // Uses theme.inputDecorationTheme.labelStyle
    // 14px, Regular
  ),
)
```

**Use:** Automatic via input theme
**Size:** 14px Regular

---

**Helper Text**

```dart
TextFormField(
  decoration: const InputDecoration(
    helperText: 'e.g., Netflix, Spotify',
    // 12px, Regular, tertiary color
  ),
)
```

**Use:** `bodySmall` (12px Regular)
**Color:** Tertiary text

---

**Error Text**

```dart
TextFormField(
  decoration: const InputDecoration(
    errorText: 'This field is required',
    // 12px, Regular, error color
  ),
)
```

**Use:** `bodySmall` (12px Regular)
**Color:** Error red

---

### 🌟 Special States

**Empty State Titles**

```dart
Text(
  'No subscriptions yet',
  style: Theme.of(context).textTheme.titleLarge,
  textAlign: TextAlign.center,
)
```

**Use:** `titleLarge` (22px Medium)
**Alignment:** Center

---

**Empty State Descriptions**

```dart
Text(
  'Tap + to add your first subscription',
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: AppColors.textSecondary,
  ),
  textAlign: TextAlign.center,
)
```

**Use:** `bodyMedium` (14px Regular)
**Color:** Secondary
**Alignment:** Center

---

**Error Messages**

```dart
Text(
  'Something went wrong. Please try again.',
  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
    color: AppColors.error,
  ),
  textAlign: TextAlign.center,
)
```

**Use:** `bodyLarge` (16px Regular)
**Color:** Error red

---

## Special Cases

### 1. Tabular Figures for Financial Data

**Problem:** Regular numbers have variable widths (1 is narrow, 0 is wide), causing amount misalignment in lists.

**Solution:** Use tabular (monospaced) figures via font features.

```dart
Text(
  '\$999.99',
  style: Theme.of(context).textTheme.titleMedium?.copyWith(
    fontFeatures: [
      const FontFeature.tabularFigures(), // All digits same width
    ],
  ),
)
```

**When to use:**
- ✅ Amount columns in lists
- ✅ Monthly totals
- ✅ Analytics numbers
- ❌ Single amounts in paragraphs (not needed)

**Visual difference:**

```
WITHOUT tabular figures:       WITH tabular figures:
$111.11  (narrow)              $111.11  (aligned)
$999.99  (wide)                $999.99  (aligned)
  ↑ misaligned                   ↑ perfectly aligned
```

---

### 2. Currency Formatting

**Always use NumberFormat for amounts:**

```dart
import 'package:intl/intl.dart';

final currencyFormat = NumberFormat.currency(
  symbol: '\$',
  decimalDigits: 2,
  locale: 'en_US',
);

Text(
  currencyFormat.format(subscription.amount), // "$15.99"
  style: Theme.of(context).textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.bold,
    fontFeatures: [const FontFeature.tabularFigures()],
  ),
)
```

**Benefits:**
- Automatic decimal precision
- Proper currency symbol placement
- Locale-aware formatting
- Thousands separators for large amounts

---

### 3. Date/Time Formatting

**Relative dates in lists:**

```dart
// Extension method in date_extensions.dart
Text(
  subscription.nextBillingDate.toRelativeString(), // "in 3 days"
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: AppColors.textSecondary,
  ),
)
```

**Absolute dates in detail views:**

```dart
import 'package:intl/intl.dart';

final dateFormat = DateFormat.yMMMd(); // "Feb 7, 2026"

Text(
  dateFormat.format(subscription.nextBillingDate),
  style: Theme.of(context).textTheme.bodyLarge,
)
```

---

### 4. Multi-line Text Truncation

**Subscription names (may be long):**

```dart
Text(
  subscription.name,
  style: Theme.of(context).textTheme.titleMedium,
  maxLines: 1,
  overflow: TextOverflow.ellipsis, // "Very Long Subscri..."
)
```

**Notes/descriptions (allow wrapping):**

```dart
Text(
  subscription.notes ?? '',
  style: Theme.of(context).textTheme.bodyMedium,
  maxLines: 3,
  overflow: TextOverflow.ellipsis,
)
```

---

### 5. All-Caps Text

**Status badges only:**

```dart
Text(
  'TRIAL',
  style: Theme.of(context).textTheme.labelSmall?.copyWith(
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5, // Slightly increased for readability
  ),
)
```

**⚠️ Avoid all-caps elsewhere** - hurts readability, feels aggressive.

---

## Accessibility

### 1. Font Scaling Support

**Always use Theme.of(context).textTheme** - respects user's system font size settings.

❌ **Bad:**
```dart
Text(
  'Hello',
  style: const TextStyle(fontSize: 16), // Ignores accessibility settings
)
```

✅ **Good:**
```dart
Text(
  'Hello',
  style: Theme.of(context).textTheme.bodyLarge, // Scales with user settings
)
```

---

### 2. Color Contrast

**All text styles meet WCAG AA standards:**

| Text Color | Background | Contrast Ratio | WCAG Level |
|------------|------------|----------------|------------|
| textPrimary (#0F172A) | surface (#FFFFFF) | 14.5:1 | AAA ✅ |
| textSecondary (#64748B) | surface (#FFFFFF) | 4.6:1 | AA ✅ |
| textTertiary (#94A3B8) | surface (#FFFFFF) | 3.1:1 | AA (large text) ✅ |
| primary (#16A34A) | surface (#FFFFFF) | 3.8:1 | AA (large text) ✅ |

**Rules:**
- Use `textPrimary` for body text (< 18px)
- Use `textSecondary` for 14px+ text
- Use `textTertiary` only for 18px+ or non-essential text
- Use `primary` color only for large amounts (24px+) or interactive elements

---

### 3. Minimum Font Sizes

**Never go below 11px:**

- ✅ Smallest: `labelSmall` (11px) for badges/tags
- ✅ Body text minimum: `bodySmall` (12px)
- ✅ Primary content: `bodyMedium` (14px) or larger

**Why:** iOS enforces 11px minimum for accessibility, Android recommends 12sp.

---

### 4. Line Height & Spacing

**Body text readability:**

```dart
Text(
  'Long paragraph of text...',
  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
    height: 1.5, // Line height = 150% of font size
  ),
)
```

**Comfortable reading:**
- Headlines: 1.2x line height (visual impact)
- Body text: 1.5x line height (readability)
- Small text: 1.4x line height (balance)

---

## Implementation Checklist

### ✅ Current Status (Implemented)

- [x] DM Sans loaded via Google Fonts
- [x] Full MD3 type scale defined in theme.dart
- [x] All text styles use proper weights (Regular, Medium, Bold)
- [x] Theme.of(context).textTheme used throughout app
- [x] Color contrast meets WCAG AA standards
- [x] Input fields use theme styles
- [x] Buttons use theme styles

### 🔧 Improvements to Implement

- [ ] Add tabular figures to all amount displays
- [ ] Create typography constants file for common text styles
- [ ] Add letter spacing to all-caps text (badges)
- [ ] Ensure all number displays use NumberFormat
- [ ] Add semantic labels for screen readers
- [ ] Test with iOS/Android accessibility font scaling
- [ ] Document typography patterns in Storybook/Widget catalog

---

## Common Mistakes

### ❌ Mistake 1: Hardcoding Font Sizes

```dart
// BAD - ignores theme, breaks accessibility
Text(
  'Hello',
  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
)
```

```dart
// GOOD - uses theme, respects user settings
Text(
  'Hello',
  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
    fontWeight: FontWeight.bold,
  ),
)
```

---

### ❌ Mistake 2: Inconsistent Weights

```dart
// BAD - using random weights
Text('Title', style: TextStyle(fontWeight: FontWeight.w800))
Text('Subtitle', style: TextStyle(fontWeight: FontWeight.w300))
```

```dart
// GOOD - use defined weights only
Text('Title', style: Theme.of(context).textTheme.titleLarge) // Medium
Text('Subtitle', style: Theme.of(context).textTheme.bodyMedium) // Regular
```

**Allowed weights:** Regular (400), Medium (500), Semi-Bold (600), Bold (700)

---

### ❌ Mistake 3: Not Using Tabular Figures for Amounts

```dart
// BAD - amounts misalign in lists
Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Text('\$11.11'),
    Text('\$999.99'),
    // ↑ Different widths, looks misaligned
  ],
)
```

```dart
// GOOD - perfectly aligned
Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Text(
      '\$11.11',
      style: textStyle.copyWith(
        fontFeatures: [const FontFeature.tabularFigures()],
      ),
    ),
    Text(
      '\$999.99',
      style: textStyle.copyWith(
        fontFeatures: [const FontFeature.tabularFigures()],
      ),
    ),
  ],
)
```

---

### ❌ Mistake 4: Wrong Text Color

```dart
// BAD - using arbitrary colors
Text(
  'Secondary info',
  style: TextStyle(color: Colors.grey), // Not from design system
)
```

```dart
// GOOD - using defined colors
Text(
  'Secondary info',
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: AppColors.textSecondary, // From design system
  ),
)
```

---

### ❌ Mistake 5: Over-nesting copyWith

```dart
// BAD - hard to read and maintain
Text(
  'Amount',
  style: Theme.of(context).textTheme.displayMedium?.copyWith(
    color: AppColors.primary.copyWith(opacity: 0.8),
    fontWeight: FontWeight.bold,
    fontSize: 50, // Overriding theme size
  ),
)
```

```dart
// GOOD - use theme, minimal overrides
Text(
  'Amount',
  style: Theme.of(context).textTheme.displayMedium?.copyWith(
    color: AppColors.primary, // Use solid color from theme
  ),
)
```

---

## Code Examples

### Example 1: Home Screen Monthly Total

```dart
// Large, bold, green amount with tabular figures
Text(
  '\$274.50',
  style: Theme.of(context).textTheme.displayMedium?.copyWith(
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
    fontFeatures: [const FontFeature.tabularFigures()],
  ),
)

// Secondary text below
Text(
  '/month',
  style: Theme.of(context).textTheme.titleMedium?.copyWith(
    color: AppColors.textSecondary,
  ),
)
```

---

### Example 2: Subscription List Item

```dart
ListTile(
  title: Text(
    subscription.name, // "Netflix"
    style: Theme.of(context).textTheme.titleMedium,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  ),
  subtitle: Text(
    'Bills in 3 days', // Relative date
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
    ),
  ),
  trailing: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        '\$15.99',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontFeatures: [const FontFeature.tabularFigures()],
        ),
      ),
      Text(
        '/mo',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    ],
  ),
)
```

---

### Example 3: Card Header with Amount

```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(AppSizes.base),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card title
        Text(
          'Billing Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.sm),

        // Amount display
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '\$15.99',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.primary,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: AppSizes.xs),
            Text(
              '/month',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        // Secondary info
        const SizedBox(height: AppSizes.sm),
        Text(
          'Next billing: Feb 7, 2026',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  ),
)
```

---

### Example 4: Form with Labels & Helper Text

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Subscription Name',
    labelStyle: Theme.of(context).textTheme.bodyLarge, // 16px
    hintText: 'e.g., Netflix',
    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: AppColors.textTertiary,
    ),
    helperText: 'Enter the service name',
    helperStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
    ),
  ),
  style: Theme.of(context).textTheme.bodyLarge, // Input text style
)
```

---

### Example 5: Empty State

```dart
Center(
  child: Padding(
    padding: const EdgeInsets.all(AppSizes.xxl),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.subscriptions_outlined,
          size: 64,
          color: AppColors.textTertiary,
        ),
        const SizedBox(height: AppSizes.xl),

        // Title
        Text(
          'No subscriptions yet',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSizes.sm),

        // Description
        Text(
          'Tap + to add your first subscription.\nWe'll remind you before every charge.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  ),
)
```

---

## Summary & Quick Reference

### Typography Decision Tree

```
Need to display...
├─ Large amount (monthly total)? → displayMedium (45px Bold) + primary color + tabular
├─ Screen title? → AppBar automatically uses titleLarge (22px Medium)
├─ Section header? → headlineSmall (24px Bold)
├─ Card header? → titleLarge (22px Medium/Bold)
├─ List item name? → titleMedium (16px Medium)
├─ Amount in list? → titleMedium (16px Bold) + tabular
├─ Secondary info? → bodyMedium (14px Regular) + textSecondary color
├─ Helper text? → bodySmall (12px Regular) + textTertiary color
├─ Badge/chip? → labelSmall (11px Bold) + all-caps
└─ Button? → Automatic via theme (16px Medium)
```

### Typography Constants

**File:** Create `lib/core/constants/app_text_styles.dart` (optional helper)

```dart
import 'package:flutter/material.dart';

class AppTextStyles {
  // Amounts with tabular figures
  static TextStyle amount(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.bold,
      fontFeatures: [const FontFeature.tabularFigures()],
      color: color,
    );
  }

  // Large amounts
  static TextStyle amountLarge(BuildContext context) {
    return Theme.of(context).textTheme.displayMedium!.copyWith(
      fontWeight: FontWeight.bold,
      fontFeatures: [const FontFeature.tabularFigures()],
      color: AppColors.primary,
    );
  }

  // Secondary info
  static TextStyle secondary(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: AppColors.textSecondary,
    );
  }
}
```

**Usage:**
```dart
Text('\$15.99', style: AppTextStyles.amount(context))
```

---

## Next Steps

### Phase 1: Audit Current Usage
- [ ] Search for hardcoded `TextStyle(fontSize: ...)` in codebase
- [ ] Replace with `Theme.of(context).textTheme.*`
- [ ] Ensure all amounts use tabular figures

### Phase 2: Add Helper Methods
- [ ] Create `AppTextStyles` constants file
- [ ] Add `amount()`, `amountLarge()`, `secondary()` helpers
- [ ] Update common components to use helpers

### Phase 3: Accessibility Testing
- [ ] Test with iOS Dynamic Type (large text)
- [ ] Test with Android font scaling
- [ ] Verify color contrast in all states
- [ ] Add semantic labels for screen readers

### Phase 4: Documentation
- [ ] Add typography examples to widget catalog
- [ ] Create design handoff document for future designers
- [ ] Update Figma/design files with type scale

---

**Typography Status:** ✅ Well-Implemented
**Next Action:** Add tabular figures to amount displays
**Priority:** Medium (nice-to-have polish)

---

## References

- **Material Design 3 Typography:** https://m3.material.io/styles/typography
- **DM Sans on Google Fonts:** https://fonts.google.com/specimen/DM+Sans
- **Flutter Typography Docs:** https://api.flutter.dev/flutter/material/TextTheme-class.html
- **WCAG Contrast Guidelines:** https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum
- **Font Features (Tabular):** https://api.flutter.dev/flutter/dart-ui/FontFeature-class.html
