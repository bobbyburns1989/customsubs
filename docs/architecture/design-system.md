# CustomSubs Design System

**Status**: ✅ Complete
**Last Updated**: February 5, 2026
**Relevant to**: Developers

**Visual language and component patterns for CustomSubs.**

This document defines the design tokens, UI components, and patterns that create a consistent,  accessible, and beautiful user experience.

---

## Table of Contents

1. [Brand Identity](#brand-identity)
2. [Color System](#color-system)
3. [Typography](#typography)
4. [Spacing & Sizing](#spacing--sizing)
5. [Components](#components)
6. [Patterns](#patterns)
7. [Layout Principles](#layout-principles)
8. [Accessibility](#accessibility)

---

## Brand Identity

### Philosophy

CustomSubs is part of the **Custom\*** app family. The brand is:

- **Clean** - No clutter, generous whitespace, flat design
- **Confident** - Professional, trustworthy, reliable
- **Trustworthy** - No dark patterns, clear pricing, honest UX

### Voice & Tone

- **Friendly** without being casual
- **Helpful** without being patronizing
- **Clear** without being cold

**Examples:**
- ✅ "Notifications are working!"
- ❌ "Yay! Your notifs are lit! 🔥"
- ✅ "No subscriptions yet. Tap + to add your first one."
- ❌ "Looks like there's nothing here..."

---

## Color System

### Primary Colors

**Brand Green** - Represents growth, money, trust

```dart
// lib/core/constants/app_colors.dart

AppColors.primary        // #16A34A - Green 600 (main brand color)
AppColors.primaryLight   // #22C55E - Green 500 (hover, active states)
AppColors.primaryDark    // #15803D - Green 700 (pressed states)
AppColors.primarySurface // #F0FDF4 - Green 50  (subtle backgrounds)
```

**Usage:**
- Primary buttons
- Active states
- Success indicators
- Amount displays
- Progress indicators

### Neutral Colors

**Grays** - Text, backgrounds, borders

```dart
AppColors.background     // #FAFAFA - Near-white (app background)
AppColors.surface        // #FFFFFF - White (card backgrounds)
AppColors.textPrimary    // #0F172A - Slate 900 (primary text)
AppColors.textSecondary  // #64748B - Slate 500 (secondary text)
AppColors.textTertiary   // #94A3B8 - Slate 400 (disabled, placeholder)
AppColors.border         // #E2E8F0 - Slate 200 (card borders)
AppColors.divider        // #F1F5F9 - Slate 100 (subtle dividers)
```

**Usage:**
- Text hierarchy (primary > secondary > tertiary)
- Card backgrounds (surface on background)
- Borders and dividers

### Semantic Colors

**State indicators** - Success, warning, error

```dart
AppColors.success  // #16A34A - Green (same as primary)
AppColors.warning  // #F59E0B - Amber 500
AppColors.error    // #EF4444 - Red 500
AppColors.trial    // #F59E0B - Amber 500 (trial badges)
AppColors.inactive // #94A3B8 - Slate 400 (disabled/muted UI elements)
```

**Usage:**
- Success: Completed actions, "paid" badges
- Warning: Trial ending soon, attention needed
- Error: Validation errors, failed operations
- Trial: Free trial badges
- Inactive: Disabled/muted UI elements

### Subscription Colors

**12 vibrant colors** for user-assigned subscription colors

```dart
AppColors.subscriptionColors = [
  Color(0xFFEF4444), // Red
  Color(0xFFF97316), // Orange
  Color(0xFFF59E0B), // Amber
  Color(0xFF84CC16), // Lime
  Color(0xFF22C55E), // Green
  Color(0xFF14B8A6), // Teal
  Color(0xFF06B6D4), // Cyan
  Color(0xFF3B82F6), // Blue
  Color(0xFF6366F1), // Indigo
  Color(0xFF8B5CF6), // Violet
  Color(0xFFEC4899), // Pink
  Color(0xFF78716C), // Stone
];
```

**Usage:**
- Subscription color dots in lists
- Subscription icons/avatars
- Color picker in add/edit forms

---

## Typography

### Font Family

**DM Sans** - Modern, readable, professional

```dart
// Loaded via google_fonts package
import 'package:google_fonts/google_fonts.dart';

// In theme.dart
textTheme: GoogleFonts.dmSansTextTheme(),
```

**Weights used:**
- Regular (400) - Body text
- Medium (500) - Labels, secondary headers
- Bold (700) - Headlines, amounts, emphasis

### Text Styles

Based on Material Design 3 Typography scale:

```dart
// Large displays
displayLarge   // 57px, Bold   - Monthly totals, big numbers
displayMedium  // 45px, Bold   - Section totals
displaySmall   // 36px, Bold   - Card headers (large)

// Headlines
headlineLarge  // 32px, Bold   - Screen titles (rare)
headlineMedium // 28px, Bold   - Section headers
headlineSmall  // 24px, Bold   - Card titles

// Titles
titleLarge     // 22px, Medium - Prominent list items
titleMedium    // 16px, Medium - List item titles, labels
titleSmall     // 14px, Medium - Captions, small labels

// Body
bodyLarge      // 16px, Regular - Primary body text
bodyMedium     // 14px, Regular - Secondary text, descriptions
bodySmall      // 12px, Regular - Captions, helper text

// Labels
labelLarge     // 14px, Medium - Button text
labelMedium    // 12px, Medium - Small buttons, chips
labelSmall     // 11px, Medium - Tiny labels
```

### Typography Usage

**Subscription amounts:**
```dart
Text(
  '\$15.99',
  style: Theme.of(context).textTheme.displayMedium?.copyWith(
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  ),
)
```

**Screen titles:**
```dart
AppBar(title: Text('Analytics'))  // Uses titleLarge by default
```

**List item titles:**
```dart
Text(
  subscription.name,
  style: Theme.of(context).textTheme.titleMedium,
)
```

**Secondary text:**
```dart
Text(
  'in 3 days',
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: AppColors.textSecondary,
  ),
)
```

---

## Spacing & Sizing

### Spacing Scale

**8pt grid system** - All spacing is a multiple of 4px

```dart
// lib/core/constants/app_sizes.dart

AppSizes.xs    // 4px  - Tiny gaps, dense layouts
AppSizes.sm    // 8px  - Compact spacing
AppSizes.md    // 12px - Default inline spacing
AppSizes.base  // 16px - Default padding (most common)
AppSizes.lg    // 20px - Comfortable spacing
AppSizes.xl    // 24px - Section spacing
AppSizes.xxl   // 32px - Large section gaps
AppSizes.xxxl  // 48px - Extra large (rare)

// Semantic spacing for consistent vertical rhythm
AppSizes.sectionSpacing  // 20px (lg) - Between major sections
```

**Usage guidelines:**
- **xs (4px)**: Space between icon and text, chip padding
- **sm (8px)**: ListTile vertical spacing, tight layouts
- **md (12px)**: Form field spacing
- **base (16px)**: Space between cards in a section
- **lg (20px)**: Space between sections within a card, card internal padding
- **sectionSpacing (20px)**: Use this for consistent spacing between major sections (Summary → Quick Actions → Upcoming List)
- **xl (24px)**: Button padding, screen padding
- **xxl (32px)**: Onboarding section spacing
- **xxxl (48px)**: Empty states, hero sections (rare)

**Vertical Rhythm Pattern:**
- Between sections: `AppSizes.sectionSpacing` (20px)
- Between items in section: `AppSizes.base` (16px)
- Inside cards: `AppSizes.lg` padding (20px)

### Border Radius

**Rounded corners** for modern, friendly feel

```dart
AppSizes.radiusSm   // 8px  - Small buttons, chips, badges
AppSizes.radiusMd   // 12px - Input fields, small components
AppSizes.radiusLg   // 16px - Standard for all cards (CONSISTENT)
AppSizes.radiusXl   // 20px - Hero cards, special components
AppSizes.radiusFull // 999px - Fully rounded (avatars, pills)
```

**Card standard:**
- **All cards use `radiusLg` (16px)** for visual consistency
- Use `StandardCard` widget to enforce this automatically

### Elevation

**Flat design** with minimal shadows

```dart
AppSizes.elevationNone  // 0  - Flat (default for cards with borders)
AppSizes.elevationSm    // 1  - Subtle lift
AppSizes.elevationMd    // 2  - Dialogs, modals
```

**Philosophy:** Use borders instead of shadows for separation. Elevation only for modals/dialogs.

---

## Components

### Cards

**Use StandardCard for consistency** - Enforces visual standards

```dart
// lib/core/widgets/standard_card.dart

StandardCard(
  child: Column(
    children: [
      Text('Card Title'),
      Text('Card content'),
    ],
  ),
)
```

**StandardCard specifications:**
- Border radius: Always 16px (`radiusLg`)
- Border: 1.5px solid (`AppColors.border`)
- Default padding: 20px (`AppSizes.lg`)
- Default margin: zero (full width)
- Background: `AppColors.surface` (white) or custom
- Elevation: None (flat design with border separation)

**Custom padding:**
```dart
StandardCard(
  padding: const EdgeInsets.all(AppSizes.xl),
  child: Text('Spacious card'),
)
```

**Colored background:**
```dart
StandardCard(
  backgroundColor: AppColors.primarySurface,
  child: Text('Tinted card'),
)
```

**Usage:**
- Summary cards (spending totals, yearly forecast)
- Subscription tiles
- Section containers (Category Breakdown, Top Subscriptions)
- Detail views
- Settings sections

**Why StandardCard?**
- Eliminates visual consistency drift
- Enforces design system standards
- Single source of truth for card styling
- Easy to update globally

### Buttons

**Primary button** - Filled green

```dart
ElevatedButton(
  onPressed: () {},
  child: const Text('Save'),
)
```

**Secondary button** - Outlined

```dart
OutlinedButton(
  onPressed: () {},
  child: const Text('Cancel'),
)
```

**Text button** - Minimal

```dart
TextButton(
  onPressed: () {},
  child: const Text('Skip'),
)
```

**Button sizing:**
```dart
// Default padding (comfortable)
ElevatedButton(child: Text('Button'))

// Large padding (prominent actions)
ElevatedButton(
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSizes.xl,
      vertical: AppSizes.base,
    ),
  ),
  child: Text('Add Subscription'),
)
```

### Form Fields

**Standard text field**

```dart
TextFormField(
  decoration: const InputDecoration(
    labelText: 'Name',
    hintText: 'e.g., Netflix',
    prefixIcon: Icon(Icons.label_outline),
  ),
  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
)
```

**Dropdown field**

```dart
DropdownButtonFormField<SubscriptionCycle>(
  value: _selectedCycle,
  decoration: const InputDecoration(
    labelText: 'Billing Cycle',
    prefixIcon: Icon(Icons.calendar_today_outlined),
  ),
  items: /* ... */,
  onChanged: (value) => setState(() => _selectedCycle = value!),
)
```

### Badges

**Status badges** - Compact indicators

```dart
// Trial badge
Container(
  padding: const EdgeInsets.symmetric(
    horizontal: AppSizes.sm,
    vertical: AppSizes.xs,
  ),
  decoration: BoxDecoration(
    color: AppColors.trial,
    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
  ),
  child: Text(
    'TRIAL',
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
)

// Paid badge
Icon(Icons.check_circle, color: AppColors.success, size: 16)
```

### List Items

**Subscription tile pattern**

```dart
ListTile(
  leading: CircleAvatar(
    backgroundColor: Color(subscription.colorValue),
    child: Icon(Icons.subscriptions, color: Colors.white),
  ),
  title: Text(subscription.name),
  subtitle: Text(subscription.nextBillingDate.toShortRelativeString()),
  trailing: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        '\$${subscription.amount.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        subscription.cycle.shortName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    ],
  ),
  onTap: () => /* navigate to detail */,
)
```

### Empty States

**Pattern: Icon + Title + Subtitle + Action**

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
        const SizedBox(height: AppSizes.base),
        Text(
          'No subscriptions yet',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          'Tap + to add your first subscription',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.xl),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Add Subscription'),
        ),
      ],
    ),
  ),
)
```

### Error States

**Pattern: Error icon + Title + Message + Retry**

```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.error_outline, size: 64, color: AppColors.error),
      const SizedBox(height: AppSizes.base),
      Text('Error loading data', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: AppSizes.sm),
      Text(
        error.toString(),
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: AppSizes.base),
      ElevatedButton.icon(
        onPressed: () => retry(),
        icon: const Icon(Icons.refresh),
        label: const Text('Retry'),
      ),
    ],
  ),
)
```

---

## Patterns

### Screen Structure

**Standard screen layout:**

```
┌─────────────────────────┐
│      AppBar             │ ← Title + actions
├─────────────────────────┤
│                         │
│   Content               │ ← ListView or Column
│   (with padding)        │    padding: EdgeInsets.all(AppSizes.base)
│                         │
│   • Cards               │
│   • Lists               │
│   • Forms               │
│                         │
└─────────────────────────┘
```

**Implementation:**
```dart
Scaffold(
  appBar: AppBar(title: const Text('Screen Title')),
  body: ListView(
    padding: const EdgeInsets.all(AppSizes.base),
    children: [
      // Content
    ],
  ),
)
```

### Color Dot Pattern

**Colored circle for subscriptions**

```dart
Container(
  width: 12,
  height: 12,
  decoration: BoxDecoration(
    color: Color(subscription.colorValue),
    shape: BoxShape.circle,
  ),
)
```

### Avatar Pattern

**First letter or icon in colored circle**

```dart
CircleAvatar(
  backgroundColor: Color(subscription.colorValue),
  radius: 20,
  child: subscription.iconName != null
      ? Icon(Icons.subscriptions, color: Colors.white)
      : Text(
          subscription.name[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
)
```

### Pull-to-Refresh Pattern

**Standard refresh indicator**

```dart
RefreshIndicator(
  onRefresh: () async {
    await ref.read(controllerProvider.notifier).refresh();
  },
  child: ListView(/* ... */),
)
```

### Loading State Pattern

**Centered spinner**

```dart
const Center(child: CircularProgressIndicator())
```

### Currency Display Pattern

**Format with intl package**

```dart
import 'package:intl/intl.dart';

final currencyFormat = NumberFormat.currency(
  symbol: '\$',
  decimalDigits: 2,
);

Text(currencyFormat.format(15.99))  // "$15.99"
```

---

## Layout Principles

### 1. Generous Whitespace

- Don't crowd elements
- Use AppSizes.base (16px) as default padding
- Leave breathing room around cards and sections

### 2. Hierarchy Through Size, Weight, Color

```dart
// Primary information - large, bold, dark
Text('$274.50', style: displayLarge, color: primary)

// Secondary information - medium, medium weight, dark
Text('Netflix', style: titleMedium)

// Tertiary information - small, regular, gray
Text('in 3 days', style: bodyMedium, color: textSecondary)
```

### 3. Consistent Alignment

- Left-align text content
- Right-align amounts/numbers
- Center-align empty states and modals

### 4. Predictable Navigation

- Back button in top-left (automatic)
- Actions in top-right (edit, settings)
- Primary action at bottom or in AppBar

### 5. Touch Targets

- Minimum 48x48 logical pixels
- Adequate spacing between tappable elements
- Visual feedback on press (ripple effect)

---

## Accessibility

### Color Contrast

All text colors meet WCAG AA standards:

- textPrimary on surface: 14.5:1 ✅
- textSecondary on surface: 4.6:1 ✅
- textTertiary on surface: 3.1:1 ✅ (large text only)
- primary on white: 3.8:1 ✅ (large text, not for body)

### Semantic Labels

**Always provide semantic labels for icons and interactive elements:**

```dart
IconButton(
  icon: const Icon(Icons.settings),
  onPressed: () {},
  tooltip: 'Settings',  // Screen reader + long-press hint
)
```

### Focus Management

- Use autofocus: true for first form field
- Test tab order makes sense
- Ensure keyboard navigation works

### Font Scaling

- Use Theme.of(context).textTheme (respects user font size)
- Don't use fixed font sizes
- Test with large text settings

### Screen Reader Support

- Proper widget semantics (Semantics widget when needed)
- Meaningful labels for all interactive elements
- Announce state changes (e.g., "Added to list")

---

## Quick Reference

### Common Patterns

| Need | Use |
|------|-----|
| Screen padding | `EdgeInsets.all(AppSizes.base)` |
| Card border radius | `BorderRadius.circular(AppSizes.radiusMd)` |
| Card padding | `EdgeInsets.all(AppSizes.base)` |
| Section spacing | `SizedBox(height: AppSizes.base)` |
| Primary button | `ElevatedButton` |
| Secondary button | `OutlinedButton` |
| Subscription color | `AppColors.subscriptionColors[index]` |
| Amount display | `NumberFormat.currency(...)` |
| Date display | `date.toRelativeString()` |
| Empty state icon size | `64` |
| Avatar radius | `20` |

### Files to Reference

- `lib/core/constants/app_colors.dart` - All colors
- `lib/core/constants/app_sizes.dart` - All spacing/sizing
- `lib/app/theme.dart` - Complete Material3 theme
- `lib/core/extensions/date_extensions.dart` - Date formatting
- `lib/core/utils/currency_utils.dart` - Currency conversion

---

## Summary

**CustomSubs design system:**

- **Brand:** Clean, confident, trustworthy
- **Colors:** Green primary, neutral grays, semantic colors
- **Typography:** DM Sans, Material Design 3 scale
- **Spacing:** 8pt grid, generous whitespace
- **Components:** Cards, buttons, forms, badges, lists
- **Patterns:** Consistent structure, clear hierarchy, accessibility-first

**Always:**
- Use constants (AppColors, AppSizes) instead of hardcoded values
- Follow typography scale (Theme.of(context).textTheme)
- Provide empty and error states
- Ensure minimum 48x48 touch targets
- Test with large text settings

**See also:**
- `CLAUDE.md` - Full design system specification
- `docs/templates/` - Code examples following design system
