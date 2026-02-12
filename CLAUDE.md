# CLAUDE.md — CustomSubs

## 📚 Documentation Quick Reference

**For AI Coding Sessions** - This file provides project specifications. For detailed implementation guides, see:

### 🎯 Start Here
- **New to this project?** Read this file + [`docs/architecture/overview.md`](docs/architecture/overview.md)
- **Implementing a feature?** See [`docs/guides/adding-a-feature.md`](docs/guides/adding-a-feature.md)
- **Working with state?** See [`docs/architecture/state-management.md`](docs/architecture/state-management.md)

### 🔧 Implementation Guides
| Task | Documentation |
|------|--------------|
| **Notifications (CRITICAL)** | [`docs/guides/working-with-notifications.md`](docs/guides/working-with-notifications.md) |
| **Animations & Polish** | [`docs/design/MICRO_ANIMATIONS.md`](docs/design/MICRO_ANIMATIONS.md) |
| Adding a new feature | [`docs/guides/adding-a-feature.md`](docs/guides/adding-a-feature.md) |
| State management patterns | [`docs/architecture/state-management.md`](docs/architecture/state-management.md) |
| Forms and validation | [`docs/guides/forms-and-validation.md`](docs/guides/forms-and-validation.md) |
| Multi-currency support | [`docs/guides/multi-currency.md`](docs/guides/multi-currency.md) |
| Data layer (Hive, repositories) | [`docs/architecture/data-layer.md`](docs/architecture/data-layer.md) |

### 📐 Architecture & Design
| Topic | Documentation |
|-------|--------------|
| Architecture overview | [`docs/architecture/overview.md`](docs/architecture/overview.md) |
| Design system (colors, typography) | [`docs/architecture/design-system.md`](docs/architecture/design-system.md) |
| Architectural decisions (ADRs) | [`docs/decisions/`](docs/decisions/) |

### 📋 Templates & Examples
| Template | File |
|----------|------|
| Feature implementation checklist | [`docs/templates/feature-template.md`](docs/templates/feature-template.md) |
| Screen with controller (annotated) | [`docs/templates/screen-with-controller.dart`](docs/templates/screen-with-controller.dart) |
| Form screen (annotated) | [`docs/templates/form-screen.dart`](docs/templates/form-screen.dart) |

### ⚡ Quick Reference
- **Cheat sheet**: [`docs/QUICK-REFERENCE.md`](docs/QUICK-REFERENCE.md)
- **README** (for humans): [`README.md`](README.md)

---

## Project Overview

You are building **CustomSubs**, a privacy-first, offline-only subscription tracker for iOS and Android built with Flutter. It is part of the **Custom\*** app family (alongside CustomBank and CustomCrypto). The app helps users track recurring subscriptions, get reliable billing reminders, manage cancellations, and understand their spending — all without linking a bank account, scanning emails, or creating a login.

**Core philosophy:** Do one thing perfectly — track subscriptions and remind users before they get charged. No account. No cloud. No permissions. Just a fast, beautiful, trustworthy utility.

**Primary competitive target:** Bobby (iOS-only, manual-entry subscription tracker by Yummygum). Bobby has a 4.7★ rating but suffers from broken notifications, no Android support, no cancellation management, data loss on reinstall, and an absent developer. CustomSubs wins on: reliability (notifications that always fire), action (cancellation help), reach (cross-platform), and trust (active development, data backup).

---

## Technical Stack & Architecture

### Core Stack
- **Framework:** Flutter (latest stable)
- **Language:** Dart
- **State Management:** Riverpod (flutter_riverpod + riverpod_annotation + riverpod_generator). Use code generation with @riverpod annotations for all providers. Use AsyncNotifier for async state, Notifier for sync state. Never use raw StateProvider for complex state.
- **Local Storage:** Hive (hive_flutter) with TypeAdapters for all models. All data is 100% on-device.
- **Notifications:** flutter_local_notifications + timezone package. This is the single most critical feature — every notification must fire reliably.
- **Navigation:** GoRouter (go_router package) with declarative routing.
- **Date/Time:** intl package for formatting. timezone package for notification scheduling.
- **Currency:** intl NumberFormat for currency display. Store exchange rates in a bundled JSON asset, do NOT fetch from network.
- **Unique IDs:** uuid package for generating subscription IDs.

### Architecture Pattern
Use **feature-first** folder structure with a clean separation:

```
lib/
├── app/
│   ├── app.dart                    # MaterialApp + GoRouter + ProviderScope
│   ├── router.dart                 # All route definitions
│   └── theme.dart                  # Full theme definition
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart         # All color constants
│   │   ├── app_sizes.dart          # Spacing, radius, elevation constants + sectionSpacing
│   │   └── subscription_templates.dart  # Pre-populated subscription catalog
│   ├── extensions/
│   │   ├── date_extensions.dart    # DateTime helpers (nextBillingDate calc, etc.)
│   │   └── currency_extensions.dart # Currency formatting helpers
│   ├── utils/
│   │   ├── currency_utils.dart     # Exchange rate loading, conversion
│   │   └── export_utils.dart       # JSON export/import logic
│   └── widgets/
│       ├── standard_card.dart      # Reusable card with consistent styling (16px radius, 1.5px border)
│       ├── subtle_pressable.dart   # Pressable wrapper with scale animation
│       └── empty_state.dart        # Reusable empty state widget
│
├── data/
│   ├── models/
│   │   ├── subscription.dart       # Core subscription model + HiveType
│   │   ├── subscription_cycle.dart # Enum: weekly, biweekly, monthly, quarterly, biannual, yearly
│   │   ├── subscription_category.dart # Enum: entertainment, productivity, fitness, etc.
│   │   └── reminder_config.dart    # Reminder timing configuration
│   ├── repositories/
│   │   └── subscription_repository.dart # CRUD operations on Hive box
│   └── services/
│       ├── notification_service.dart    # Schedule/cancel all notifications
│       ├── backup_service.dart          # JSON export to device / import from file
│       └── template_service.dart        # Load + search subscription templates
│
├── features/
│   ├── onboarding/
│   │   └── onboarding_screen.dart       # Single-screen intro with feature cards
│   │
│   ├── home/
│   │   ├── home_screen.dart             # Main screen: summary + upcoming list
│   │   ├── home_controller.dart         # Riverpod controller for home state
│   │   └── widgets/
│   │       ├── spending_summary_card.dart
│   │       ├── upcoming_charge_tile.dart
│   │       └── subscription_list_item.dart
│   │
│   ├── add_subscription/
│   │   ├── add_subscription_screen.dart       # Full add/edit form
│   │   ├── add_subscription_controller.dart
│   │   ├── template_picker_screen.dart        # Browse/search pre-populated templates
│   │   └── widgets/
│   │       ├── template_grid_item.dart
│   │       ├── cycle_selector.dart
│   │       ├── reminder_config_widget.dart
│   │       └── category_picker.dart
│   │
│   ├── subscription_detail/
│   │   ├── subscription_detail_screen.dart    # Full detail view + cancel tools
│   │   ├── subscription_detail_controller.dart
│   │   └── widgets/
│   │       ├── header_card.dart               # Icon, name, amount, status badges
│   │       ├── billing_info_card.dart         # Billing cycle, dates, trial info
│   │       ├── cancellation_card.dart         # Cancel URL + phone + checklist
│   │       ├── notes_card.dart                # User notes display
│   │       ├── reminder_info_card.dart        # Reminder settings display
│   │       ├── info_row.dart                  # Reusable label-value row
│   │       └── status_badge.dart              # Animated status badge
│   │
│   ├── cancellation/
│   │   ├── cancellation_checklist_screen.dart  # Step-by-step cancel flow
│   │   └── widgets/
│   │       └── checklist_step_tile.dart
│   │
│   ├── analytics/
│   │   ├── analytics_screen.dart              # Spending breakdown + trends
│   │   ├── analytics_controller.dart
│   │   └── widgets/
│   │       ├── monthly_total_chart.dart
│   │       ├── category_breakdown_card.dart
│   │       └── spending_trend_card.dart
│   │
│   └── settings/
│       ├── settings_screen.dart
│       └── widgets/
│           ├── backup_restore_tile.dart
│           ├── currency_selector_tile.dart
│           └── notification_test_tile.dart
│
└── main.dart                        # Entry point: init Hive, notifications, runApp
```

### Key Architecture Rules
1. **Every screen has its own Riverpod controller** — no business logic in widgets.
2. **Repository pattern** — widgets never touch Hive directly. All DB operations go through `SubscriptionRepository`.
3. **Models are immutable** — use `copyWith` patterns. Generate Hive TypeAdapters with `hive_generator`.
4. **No singletons for services** — wrap NotificationService, BackupService, etc. in Riverpod providers so they're testable and injectable.
5. **No network calls** — this app is 100% offline. Currency exchange rates are bundled as a static JSON asset, not fetched.

---

## Data Models

### Subscription (primary model)
```dart
@HiveType(typeId: 0)
class Subscription extends HiveObject {
  @HiveField(0) final String id;               // UUID
  @HiveField(1) final String name;              // "Netflix"
  @HiveField(2) final double amount;            // 15.99
  @HiveField(3) final String currencyCode;      // "USD", "EUR", "GBP", etc.
  @HiveField(4) final SubscriptionCycle cycle;   // monthly, yearly, etc.
  @HiveField(5) final DateTime nextBillingDate;
  @HiveField(6) final DateTime startDate;        // When user first subscribed
  @HiveField(7) final SubscriptionCategory category;
  @HiveField(8) final bool isActive; // DEPRECATED: Always true as of v1.0.3
  @HiveField(9) final bool isTrial;              // FREE TRIAL MODE
  @HiveField(10) final DateTime? trialEndDate;   // When trial converts to paid
  @HiveField(11) final double? postTrialAmount;  // Amount after trial ends
  @HiveField(12) final String? cancelUrl;        // Direct link to cancellation page
  @HiveField(13) final String? cancelPhone;      // Support phone number
  @HiveField(14) final String? cancelNotes;      // Free-text cancellation instructions
  @HiveField(15) final List<String> cancelChecklist; // ["Log into account", "Go to billing", "Click cancel"]
  @HiveField(16) final List<bool> checklistCompleted; // Parallel array tracking completion
  @HiveField(17) final String? notes;            // General user notes
  @HiveField(18) final String? iconName;         // Template icon identifier or null for custom
  @HiveField(19) final int colorValue;           // Stored as int, converted to Color
  @HiveField(20) final ReminderConfig reminders;
  @HiveField(21) final bool isPaid;              // "Mark as paid" for current cycle
  @HiveField(22) final DateTime? lastMarkedPaidDate; // When user last marked paid
}
```

### SubscriptionCycle
```dart
@HiveType(typeId: 1)
enum SubscriptionCycle {
  @HiveField(0) weekly,
  @HiveField(1) biweekly,
  @HiveField(2) monthly,
  @HiveField(3) quarterly,
  @HiveField(4) biannual,
  @HiveField(5) yearly,
}
```

### SubscriptionCategory
```dart
@HiveType(typeId: 2)
enum SubscriptionCategory {
  @HiveField(0) entertainment,    // Netflix, Spotify, Disney+
  @HiveField(1) productivity,     // Notion, Todoist, Office 365
  @HiveField(2) fitness,          // Gym, Peloton, MyFitnessPal
  @HiveField(3) news,             // NYT, WSJ, Substack
  @HiveField(4) cloud,            // iCloud, Google One, Dropbox
  @HiveField(5) gaming,           // Xbox Game Pass, PS Plus
  @HiveField(6) education,        // Coursera, Duolingo, Skillshare
  @HiveField(7) finance,          // Mint, YNAB (ironic)
  @HiveField(8) shopping,         // Amazon Prime, Costco
  @HiveField(9) utilities,        // Phone, internet, rent
  @HiveField(10) health,          // Insurance, telehealth
  @HiveField(11) other,
}
```

### ReminderConfig
```dart
@HiveType(typeId: 3)
class ReminderConfig {
  @HiveField(0) final int firstReminderDays;   // Default: 7
  @HiveField(1) final int secondReminderDays;  // Default: 1
  @HiveField(2) final bool remindOnBillingDay;  // Default: true
  @HiveField(3) final int reminderHour;         // Default: 9 (9 AM)
  @HiveField(4) final int reminderMinute;       // Default: 0
}
```

---

## Feature Specifications

### 1. Onboarding (first launch only)

Single-screen onboarding with all content visible at once. Minimal, scannable, and fast.

**Layout Structure:**

**Header Section:**
- CustomSubs logo (centered)
- Welcome message: "Welcome to CustomSubs"
- Subheadline: "Your private subscription tracker"

**Features Section (3 cards):**

**Card 1 — "Track Everything"**
- Icon: Dashboard icon in circular green container
- Title: "Track Everything"
- Description: "All your subscriptions in one place. No bank linking. No login."

**Card 2 — "Never Miss a Charge"**
- Icon: Notification bell icon in circular green container
- Title: "Never Miss a Charge"
- Description: "Get notified 7 days before, 1 day before, and the morning of every billing date."

**Card 3 — "Cancel with Confidence"**
- Icon: Exit/cancel icon in circular green container
- Title: "Cancel with Confidence"
- Description: "Step-by-step guides to cancel any subscription quickly."

**CTA Section:**
- Full-width "Get Started" button (primary green)
- Privacy note: "🔒 100% offline • No account required"

**Animations:**
- Subtle staggered fade-in animations for each section (1200ms total duration)
- Each element fades in sequentially with 150ms offset

**Behavior:**
- Store a `hasSeenOnboarding` bool in Hive settings box. Skip onboarding on subsequent launches.
- On "Get Started" tap, trigger notification permission request (iOS/Android).
- Navigate to Home screen after permissions are handled.

### 2. Home Screen

The main screen the user sees every day. It must communicate three things instantly: **how much you're spending**, **what's coming up**, and **what needs attention**.

**Layout (top to bottom):**

**App Bar:**
- Title: "CustomSubs" in brand font
- Leading: None
- Trailing: Settings gear icon → Settings screen

**Spending Summary Card (top):**
- Large monthly total in primary currency (e.g., "$274.50 /month")
- Smaller secondary text: "X active subscriptions"
- If user has multi-currency subs, show converted total with note: "≈ $274.50 at bundled rates"
- Card uses a subtle green gradient background (brand color)

**Quick Actions Row:**
- "Add New" button (primary, filled)
- "Analytics" button (outlined)

**Upcoming Charges Section:**
- Section header: "Upcoming" with a small "next 30 days" label
- List of subscriptions sorted by next billing date (soonest first)
- Each tile shows:
  - Color dot (subscription color) + Icon (if from template) or first letter
  - Subscription name
  - Amount + cycle label (e.g., "$15.99/mo")
  - Days until billing: "in 3 days", "Tomorrow", "Today", "Overdue"
  - "Paid" badge if user marked it paid for this cycle
  - If it's a trial: yellow "Trial ends in X days" badge
- Tapping a tile → Subscription Detail screen
- Swipe left to reveal "Delete" action

**Attention Section (conditional):**
- Only shows if there are items needing attention
- "Trials ending soon" — any trial ending within 7 days
- "Possibly unused" — subs where user hasn't marked paid in 60+ days (soft nudge)

**Empty State (no subscriptions yet):**
- Friendly illustration
- "No subscriptions yet"
- "Tap + to add your first one. We'll remind you before every charge."
- Large "Add Subscription" button

### 3. Add Subscription Screen

Two entry paths: **pick from template** or **create custom**.

**Template Picker (default first tab / top of screen):**
- Search bar at top: filters templates by name
- Grid of popular templates (2 columns): Netflix, Spotify, YouTube Premium, Disney+, Apple Music, iCloud, Google One, Amazon Prime, Hulu, HBO Max, Adobe CC, Microsoft 365, Notion, ChatGPT Plus, Gym (generic), Coursera, Duolingo Plus, Xbox Game Pass, PlayStation Plus, Nintendo Switch Online, Crunchyroll, Paramount+, Peacock, Apple TV+, Dropbox, LinkedIn Premium, Tidal, Audible, Kindle Unlimited, Strava, Headspace, Calm
- Each template shows: icon/logo placeholder, name, default price, default cycle
- Tapping a template pre-fills the form below with name, default amount, category, cancel URL (if known), and a suggested color

**Create Custom (button or tab):**
- Empty form for fully custom subscriptions

**Form Fields (both paths):**

Required:
- **Name** — text input, pre-filled if from template
- **Amount** — numeric input with decimal, pre-filled if from template
- **Currency** — dropdown, defaults to user's primary currency (set in Settings), supports 30+ currencies (USD, EUR, GBP, CAD, AUD, JPY, INR, BRL, MXN, CHF, CNY, KRW, SEK, NOK, DKK, PLN, CZK, HUF, TRY, ZAR, NZD, SGD, HKD, THB, MYR, PHP, IDR, VND, AED, SAR, NGN)
- **Billing Cycle** — selector: Weekly, Biweekly, Monthly, Quarterly, Biannual, Yearly
- **Next Billing Date** — date picker, defaults to 30 days from today
- **Category** — picker from SubscriptionCategory enum

Optional:
- **Free Trial toggle** — when ON, reveals:
  - Trial end date picker
  - Post-trial amount field
  - (Reminders will auto-focus on trial end date instead of billing date)
- **Color** — color picker (grid of 12-16 pre-selected colors)
- **Cancellation URL** — text input, pre-filled for known templates
- **Cancellation phone** — text input
- **Cancellation notes** — multiline text
- **Cancellation checklist** — dynamic list builder. User taps "+ Add step" to add checklist items (e.g., "Log into Netflix.com", "Go to Account > Cancel Membership", "Confirm cancellation"). Reorderable.
- **General notes** — multiline text

**Reminders Section (expandable/collapsible):**
- "First reminder" — dropdown: Off, 1 day, 2 days, 3 days, 5 days, 7 days, 10 days, 14 days before. Default: 7 days.
- "Second reminder" — same options. Default: 1 day.
- "Remind on billing day" — toggle, default ON.
- "Reminder time" — time picker, default 9:00 AM.

**Save button** at bottom. Validates required fields, saves to Hive, schedules notifications, navigates back to Home.

### 4. Subscription Detail Screen

Full detail view for a single subscription. Accessed by tapping any subscription on Home.

**Header:**
- Subscription color as background accent
- Large icon (template icon or first-letter avatar)
- Name, amount, cycle
- Status badge: Trial (yellow), Paid (green)

**Quick Actions:**
- "Mark as Paid" button — full-width button that toggles paid status for current billing cycle. Resets automatically when nextBillingDate advances.
- "Edit" button → Add/Edit screen in edit mode (top bar)
- "Delete" button (top bar, with confirmation dialog)

**Billing Info Card:**
- Next billing date with countdown ("in 12 days")
- Billing cycle
- Currency + amount
- Start date
- If trial: "Trial ends [date] — then $X.XX/[cycle]"

**Cancellation Manager Card:**
- Only shows if any cancellation info exists (URL, phone, notes, or checklist)
- "How to Cancel" header
- If cancelUrl exists: tappable "Open Cancellation Page" button (launches url_launcher)
- If cancelPhone exists: tappable phone number (launches phone dialer)
- If cancelNotes exists: displayed as text
- If cancelChecklist has items: interactive checklist with checkboxes. Progress is persisted. Show "X of Y steps complete" progress indicator.

**Notes Card:**
- Shows general notes if any exist

**Danger Zone:**
- "Delete Subscription" — red text button, confirmation dialog: "This will remove [Name] and cancel all reminders. This cannot be undone."

### 5. Analytics Screen

Visual breakdown of spending. Accessible from Home quick actions.

**Yearly Forecast (Hero Metric):**
- Centered card with green gradient background at the top
- Large prominent yearly total: "At this rate, you'll spend $X,XXX this year on subscriptions"
- Simple multiplication of monthly total × 12
- Daily cost breakdown: "That's $X.XX per day" beneath subscription count for psychological impact
- Shows active subscription count
- Primary focal point of the screen

**Category Breakdown:**
- Horizontal bar chart or proportional segments showing spend per category
- Each segment: category name, total, percentage of overall spend
- Sorted by highest spend first

**Top Subscriptions:**
- Ranked list of most expensive subscriptions (monthly equivalent)
- Show top 5 with amounts
- Tappable to navigate to subscription detail

**Currency Breakdown (if multi-currency):**
- Show total spend per currency before conversion

### 6. Settings Screen

**Sections:**

**General:**
- "Primary Currency" — picker, sets the default currency for new subs and the currency used for totals/analytics
- "Default Reminder Time" — time picker, sets default for new subscriptions

**Data:**
- "Export Backup" — exports all subscriptions as a JSON file to device storage using share sheet (share_plus package). File named `customsubs_backup_YYYY-MM-DD.json`.
- "Import Backup" — opens file picker (file_picker package), reads JSON, confirms with user ("This will add X subscriptions. Duplicates will be skipped."), imports.
- "Delete All Data" — red, double-confirmation ("Are you sure?" → "This will permanently delete all subscriptions and settings. Type DELETE to confirm.")

**Notifications:**
- "Test Notification" — fires a test notification immediately so user can verify their device receives it. This is critical for trust.
- Brief text: "CustomSubs sends reminders at [time] before your billing dates. Make sure notifications are enabled in your device settings."

**About:**
- App version
- "Made with ♥ by Custom*"
- Link to rate on App Store / Play Store (placeholder URL for now)
- Link to privacy policy (placeholder URL)

---

## Design System

### Brand Identity
CustomSubs is part of the **Custom\*** family. The brand is **clean, confident, and trustworthy** — a financial app that respects your attention and your data.

### Colors
```dart
// Primary
static const Color primary = Color(0xFF16A34A);       // Green 600
static const Color primaryLight = Color(0xFF22C55E);   // Green 500
static const Color primaryDark = Color(0xFF15803D);    // Green 700
static const Color primarySurface = Color(0xFFF0FDF4); // Green 50

// Neutrals
static const Color background = Color(0xFFFAFAFA);    // Near-white
static const Color surface = Color(0xFFFFFFFF);        // White cards
static const Color textPrimary = Color(0xFF0F172A);    // Slate 900
static const Color textSecondary = Color(0xFF64748B);  // Slate 500
static const Color textTertiary = Color(0xFF94A3B8);   // Slate 400
static const Color border = Color(0xFFE2E8F0);         // Slate 200
static const Color divider = Color(0xFFF1F5F9);        // Slate 100

// Semantic
static const Color success = Color(0xFF16A34A);        // Same as primary
static const Color warning = Color(0xFFF59E0B);        // Amber 500
static const Color error = Color(0xFFEF4444);          // Red 500
static const Color trial = Color(0xFFF59E0B);          // Amber for trial badges
static const Color inactive = Color(0xFF94A3B8);       // Slate 400 for paused

// Category Colors (for subscription color picker)
static const List<Color> subscriptionColors = [
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

### Typography
Use **Google Fonts** (google_fonts package):
- **Display / Headlines:** `DM Sans` — Bold weight for large numbers and headings
- **Body / UI:** `DM Sans` — Regular and Medium weights for body text, labels, buttons
- **Monospace (amounts):** `DM Mono` or `JetBrains Mono` — for currency amounts to align digits

### Spacing & Sizing
```dart
// Spacing scale
static const double xs = 4;
static const double sm = 8;
static const double md = 12;
static const double base = 16;
static const double lg = 20;
static const double xl = 24;
static const double xxl = 32;
static const double xxxl = 48;

// Semantic spacing (for consistent vertical rhythm)
static const double sectionSpacing = lg; // 20px between major sections

// Border radius
static const double radiusSm = 8;
static const double radiusMd = 12;
static const double radiusLg = 16;  // Standard for all cards
static const double radiusXl = 20;
static const double radiusFull = 999;

// Card elevation
static const double elevationNone = 0;
static const double elevationSm = 1;
static const double elevationMd = 2;
```

### Card Style
Use the **StandardCard** widget (`lib/core/widgets/standard_card.dart`) for all cards to maintain visual consistency:

```dart
StandardCard(
  child: Column(
    children: [
      Text('Card content'),
    ],
  ),
)
```

**StandardCard specifications:**
- White background (or custom via `backgroundColor`)
- 1.5px border (AppColors.border)
- BorderRadius of `radiusLg` (16px) — consistent across all cards
- Padding of `lg` (20px) inside by default
- No drop shadow (flat design — elevation via borders, not shadows)
- Margin defaults to zero (full width in parent)

### General UI Principles
- **Light mode only** for now
- **No bottom navigation bar** — use a single-screen home with drill-down navigation
- **Cards, not lists** — each subscription is a card, not a bare ListTile. Use `StandardCard` for consistency
- **Generous whitespace** — use `sectionSpacing` (20px) between major sections for consistent vertical rhythm
- **Balanced hierarchy** — avoid top-heavy layouts by using consistent padding/font sizes
- **Glass morphism for primary cards** — green summary cards use solid color with 92% opacity + subtle white border
- **Smooth transitions** — use Hero animations between Home tiles and Detail screen
- **Pull-to-refresh** — Home and Analytics screens support pull-to-refresh
- **Subtle micro-interactions** — card press animations (SubtlePressable with 0.99 scale), smooth page transitions
- **Icon depth** — subscription icons use gradient backgrounds with subtle shadows
- **Typography hierarchy** — titleLarge (22pt) for major sections, titleMedium (16pt) for card headers, titleSmall (14pt) for sub-headers

---

## Notification System — CRITICAL

**This is the #1 feature of the app.** Bobby's most common complaint is broken notifications. CustomSubs must have bulletproof, reliable notifications. This is non-negotiable.

### Implementation Requirements

1. **Use `flutter_local_notifications` with `timezone` package.** All scheduled notifications must use `zonedSchedule` with `TZDateTime` — never use plain `DateTime`.

2. **Schedule notifications at the moment a subscription is saved or edited.** Every call to `upsert` in the repository must trigger a re-schedule of all notifications for that subscription.

3. **Cancel all existing notifications for a subscription before re-scheduling.** Use deterministic notification IDs derived from the subscription UUID + reminder type so you can cancel specific notifications without affecting others.

4. **Notification ID generation:**
   ```dart
   // Generate stable, unique int IDs from subscription UUID + type
   int _notificationId(String subscriptionId, String type) {
     return ('$subscriptionId:$type'.hashCode).abs() % 2147483647;
   }
   // Types: 'reminder1', 'reminder2', 'dayof', 'trial_end'
   ```

5. **For trials:** Schedule an additional aggressive reminder set:
   - 3 days before trial ends
   - 1 day before trial ends
   - Morning of trial end date
   - Notification body: "Your [Name] free trial ends today. You'll be charged $X.XX/[cycle] starting tomorrow."

6. **Automatic nextBillingDate advancement:** When the app opens, check all subscriptions. If `nextBillingDate` is in the past and subscription is active, auto-advance it to the next cycle date and reschedule notifications. Also reset `isPaid` to false.

7. **Request permissions properly:**
   - iOS: Request via `IOSFlutterLocalNotificationsPlugin.requestPermissions`
   - Android 13+: Request `POST_NOTIFICATIONS` permission via `AndroidFlutterLocalNotificationsPlugin.requestNotificationsPermission`
   - Do this during onboarding "Get Started" tap

8. **Test notification in Settings:** Must fire an immediate notification so the user can verify the system works. Body: "Notifications are working! You'll be reminded before every charge."

9. **Notification channel setup (Android):**
   - Channel ID: `customsubs_reminders`
   - Channel Name: "Subscription Reminders"
   - Importance: Max
   - Priority: High

### Notification Content

**First reminder (e.g., 7 days before):**
- Title: "📅 [Name] — Billing in [X] days"
- Body: "$[amount]/[cycle] charges on [formatted date]"

**Second reminder (e.g., 1 day before):**
- Title: "⚠️ [Name] — Bills tomorrow"
- Body: "$[amount] will be charged tomorrow, [formatted date]"

**Day-of reminder:**
- Title: "💰 [Name] — Billing today"
- Body: "$[amount]/[cycle] charge expected today"

**Trial ending:**
- Title: "🔔 [Name] — Trial ending soon"
- Body: "Free trial ends [date]. You'll be charged $[amount]/[cycle] after."

---

## Backup & Data Safety

Bobby's biggest trust-killer is data loss on reinstall. CustomSubs must solve this.

### Export
- Serialize all subscriptions to a JSON array
- Include a metadata header: `{ "app": "CustomSubs", "version": "1.0.0", "exportDate": "...", "count": N }`
- Use `share_plus` to open the system share sheet so user can save to Files, email to self, AirDrop, etc.
- File name: `customsubs_backup_YYYY-MM-DD.json`

### Import
- Use `file_picker` to let user select a `.json` file
- Parse and validate structure
- Show confirmation: "Found X subscriptions. Import?" with preview list
- Skip duplicates (match by name + amount + cycle)
- After import, reschedule all notifications

### Encourage Backup
- After the user adds their 3rd subscription, show a one-time prompt: "Tip: You can back up your subscriptions in Settings → Export Backup. Keep a copy safe!"
- In Settings, show last backup date if ever backed up. If never: show "Never backed up" in warning amber.

---

## Subscription Templates

Bundle a JSON asset at `assets/data/subscription_templates.json` with 260+ popular services. Each template:

```json
{
  "id": "netflix",
  "name": "Netflix",
  "defaultAmount": 15.49,
  "defaultCurrency": "USD",
  "defaultCycle": "monthly",
  "category": "entertainment",
  "cancelUrl": "https://www.netflix.com/cancelplan",
  "color": "0xFFE50914",
  "iconName": "netflix"
}
```

Include templates for at minimum: Netflix, Spotify, YouTube Premium, Disney+, Apple Music, Apple TV+, Apple One, iCloud+, Google One, Amazon Prime, Hulu, HBO Max / Max, Paramount+, Peacock, Crunchyroll, Adobe Creative Cloud, Microsoft 365, Notion, ChatGPT Plus, Claude Pro, Midjourney, GitHub Copilot, Figma, Dropbox Plus, LinkedIn Premium, Audible, Kindle Unlimited, Xbox Game Pass, PlayStation Plus, Nintendo Switch Online, Strava, Peloton, Headspace, Calm, Duolingo Plus, Coursera Plus, Skillshare, Medium, Substack, Tidal.

**For icons:** Since we're using placeholders, render the first 1-2 letters of the service name in a colored circle using the template's color. Do NOT depend on any external icon API.

---

## Multi-Currency Support

### Implementation
- Store a `primary_currency` setting in Hive settings box (default: "USD")
- Each subscription stores its own `currencyCode`
- Bundle a static `assets/data/exchange_rates.json` with approximate exchange rates relative to USD. These are static/bundled — not live-fetched.
- When calculating totals and analytics, convert all amounts to the primary currency using bundled rates
- Show a note on analytics: "Converted at approximate bundled rates"

### Display Rules
- On subscription tiles, always show the native currency: "$15.99" or "€12.99" or "¥1,500"
- On summary cards and analytics, show converted total in primary currency
- Use `NumberFormat.currency(locale: ..., symbol: ...)` from `intl` for proper formatting per currency

---

## "Mark as Paid" System

### Logic
- Each subscription has `isPaid` (bool) and `lastMarkedPaidDate` (DateTime?)
- When user taps "Mark as Paid", set `isPaid = true` and `lastMarkedPaidDate = DateTime.now()`
- When billing cycle advances (nextBillingDate passed), automatically reset `isPaid = false`
- On the Home screen, paid subscriptions show a subtle green "Paid" badge (positioned below the billing date on the right)
- Paid subscriptions sort to the bottom of the upcoming list (unpaid items first)

### Date Advancement & isPaid Reset
The `isPaid` status is automatically reset when billing dates advance in three scenarios:

1. **App Startup** (`main.dart:90`)
   - Runs `advanceOverdueBillingDates()` during initialization
   - Catches up on any missed billing cycles when app hasn't been opened

2. **App Resume from Background** (`home_screen.dart`)
   - `WidgetsBindingObserver` detects when app returns to foreground
   - Automatically advances overdue dates via `didChangeAppLifecycleState`
   - Reschedules notifications for updated subscriptions
   - Fixes edge case where app is backgrounded overnight across billing date

3. **Pull-to-Refresh** (`home_screen.dart`)
   - User-triggered refresh also checks for overdue dates
   - Ensures dates stay current even if app is kept open continuously
   - Handles edge case for power users who never background the app

**Implementation**: `_advanceOverdueDatesIfNeeded()` in HomeScreen calls `repository.advanceOverdueBillingDates()`, which resets `isPaid: false` for all subscriptions with past billing dates, then reschedules their notifications.

---

## Build Phases

### Phase 1 — Core MVP (build this first, make it complete and polished)
- [x] Project setup (pubspec, folder structure, theme, router)
- [x] Data models + Hive setup + code generation
- [x] Subscription repository (CRUD)
- [x] Notification service (schedule, cancel, permissions)
- [x] Onboarding screen (single-screen with feature cards + permission request)
- [x] Home screen (summary card, upcoming list, empty state, FAB)
- [x] Add Subscription screen (template picker + custom form)
- [x] Subscription Detail screen (all info + mark as paid + delete)
- [x] Settings screen (primary currency, test notification, about)
- [x] Subscription templates (bundled JSON, 260+ services)
- [x] Multi-currency display
- [x] Date advancement logic (auto-advance past billing dates)

### Phase 2 — Cancellation & Safety (build after Phase 1 is fully working)
- [x] Cancellation manager (URL, phone, notes, interactive checklist)
- [x] Export backup (JSON via share sheet)
- [x] Import backup (file picker + validation + import)
- [x] Backup reminder prompt (after 3rd subscription)
- [x] Free trial mode (trial toggle, trial-specific reminders, trial badges)
- [x] "Mark as Paid" system

### Phase 3 — Analytics & Polish (build after Phase 2)
- [x] Analytics screen (monthly total, category breakdown, yearly forecast)
- [x] Category breakdown visualization
- [x] Top subscriptions ranking
- [x] Monthly spending snapshot storage
- [x] Hero animations between Home and Detail
- [x] Pull-to-refresh on Home
- [x] Swipe actions on subscription tiles (delete)
- [x] Micro-interactions (tap animations, transitions)

---

## pubspec.yaml Dependencies

```yaml
name: custom_subs
description: "CustomSubs — Privacy-first subscription tracker"
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ">=3.4.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Local storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Routing
  go_router: ^14.2.0

  # Notifications
  flutter_local_notifications: ^18.0.1
  timezone: ^0.9.4

  # UI
  google_fonts: ^6.2.1
  intl: ^0.19.0

  # Utilities
  uuid: ^4.4.2
  url_launcher: ^6.3.0
  share_plus: ^9.0.0
  file_picker: ^8.0.6
  path_provider: ^2.1.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.11
  hive_generator: ^2.0.1
  riverpod_generator: ^2.4.0
```

---

## Critical Quality Requirements

1. **Notifications must fire reliably.** Test every code path. This is the app's core value.
2. **No crashes on empty state.** Every screen must gracefully handle zero data.
3. **No data loss.** Hive operations must be awaited. Never fire-and-forget a write.
4. **Fast startup.** App should be interactive within 1 second. Hive is fast — don't add unnecessary delays.
5. **Forms must validate.** Amount must be positive. Name must not be empty. Date must not be in the distant past.
6. **Smooth 60fps.** No jank on list scrolling, page transitions, or animations.
7. **Accessible.** All interactive elements must have semantic labels. Sufficient color contrast ratios. Minimum touch target 48x48.

---

## What NOT to Build

- ❌ No login / authentication
- ❌ No cloud sync / Firebase / Supabase
- ❌ No bank linking / Plaid
- ❌ No email scanning
- ❌ No live exchange rate fetching (use bundled rates)
- ❌ No home screen widgets (future phase)
- ❌ No dark mode (future phase)
- ❌ No paywall / RevenueCat (future phase — the app is fully free for now)
- ❌ No ads
- ❌ No onboarding account creation
- ❌ No receipt/screenshot scanning (future phase)
- ❌ No social features / sharing
- ❌ No web version

---

## Build Instructions

After scaffolding the project:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Run the build_runner after creating or modifying any model with Hive TypeAdapters or Riverpod annotations.

Test with:
```bash
flutter run
```

Target iOS Simulator and/or Android Emulator. Verify notifications on a real device (simulators have limited notification support).