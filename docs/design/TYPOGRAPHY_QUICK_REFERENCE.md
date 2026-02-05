# Typography Quick Reference

**Status**: ✅ Complete
**Last Updated**: February 4, 2026
**Relevant to**: Developers

**One-page cheat sheet for CustomSubs typography**

---

## 🎯 Font Family

**DM Sans** (Google Fonts)
- Regular 400 | Medium 500 | Semi-Bold 600 | Bold 700

---

## 📐 Type Scale

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| **displayLarge** | 57px | Bold | Rarely used |
| **displayMedium** | 45px | Bold | 💰 **Monthly totals** |
| **displaySmall** | 36px | Bold | Large amounts |
| **headlineLarge** | 32px | Bold | Rarely used |
| **headlineMedium** | 28px | Bold | Section headers |
| **headlineSmall** | 24px | Bold | Card titles |
| **titleLarge** | 22px | Medium | AppBar, prominent items |
| **titleMedium** | 16px | Medium | 📝 **Subscription names** |
| **titleSmall** | 14px | Medium | Captions |
| **bodyLarge** | 16px | Regular | Primary body text |
| **bodyMedium** | 14px | Regular | Secondary text |
| **bodySmall** | 12px | Regular | Helper text |
| **labelLarge** | 14px | Medium | Button text |
| **labelMedium** | 12px | Medium | Small buttons |
| **labelSmall** | 11px | Medium | 🏷️ **Badges** |

---

## 💡 Common Patterns

### Monthly Total (Home Screen)
```dart
Text(
  '\$274.50',
  style: Theme.of(context).textTheme.displayMedium?.copyWith(
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
    fontFeatures: [const FontFeature.tabularFigures()],
  ),
)
```

### Subscription Amount (List)
```dart
Text(
  '\$15.99',
  style: Theme.of(context).textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.bold,
    fontFeatures: [const FontFeature.tabularFigures()],
  ),
)
```

### Subscription Name
```dart
Text(
  subscription.name,
  style: Theme.of(context).textTheme.titleMedium,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
)
```

### Secondary Info (Billing Date)
```dart
Text(
  'Bills in 3 days',
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: AppColors.textSecondary,
  ),
)
```

### Card Header
```dart
Text(
  'Billing Information',
  style: Theme.of(context).textTheme.titleLarge?.copyWith(
    fontWeight: FontWeight.bold,
  ),
)
```

### Status Badge
```dart
Text(
  'TRIAL',
  style: Theme.of(context).textTheme.labelSmall?.copyWith(
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  ),
)
```

---

## 🎨 Color Pairings

| Text Type | Color | Usage |
|-----------|-------|-------|
| Primary text | `AppColors.textPrimary` | Names, titles, main content |
| Secondary text | `AppColors.textSecondary` | Dates, descriptions, meta |
| Tertiary text | `AppColors.textTertiary` | Helper text, placeholders |
| Amounts | `AppColors.primary` | Financial amounts (green) |
| Errors | `AppColors.error` | Validation errors |
| Success | `AppColors.success` | Confirmation messages |

---

## ✅ Rules

1. **Always use `Theme.of(context).textTheme`** - Never hardcode font sizes
2. **Use tabular figures for amounts** - Add `FontFeature.tabularFigures()`
3. **Respect color hierarchy** - Primary → Secondary → Tertiary
4. **Minimum 11px** - Never go below `labelSmall`
5. **Use bold for emphasis** - Not underlining or all-caps
6. **Format currencies** - Use `NumberFormat.currency()`

---

## ❌ Don't

- ❌ `TextStyle(fontSize: 16)` - Hardcoding sizes
- ❌ `Colors.grey` - Using arbitrary colors
- ❌ `fontWeight: FontWeight.w800` - Using undefined weights
- ❌ Displaying amounts without tabular figures
- ❌ All-caps text except badges

---

## ✅ Do

- ✅ `Theme.of(context).textTheme.bodyLarge` - Use theme
- ✅ `AppColors.textSecondary` - Use design system colors
- ✅ Regular, Medium, Semi-Bold, Bold - Use defined weights
- ✅ `FontFeature.tabularFigures()` for amounts
- ✅ Sentence case for most UI text

---

**Full Documentation:** `docs/design/TYPOGRAPHY_PLAN.md`
