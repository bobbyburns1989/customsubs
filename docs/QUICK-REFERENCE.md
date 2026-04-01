# Quick Reference

**Status**: ✅ Complete
**Last Updated**: March 25, 2026 (v1.4.9 — crash analytics, growth events, in-app review)
**Relevant to**: Developers

**Fast lookup for common tasks and patterns in CustomSubs.**

Bookmark this page for quick access during development.

---

## 🚀 Common Commands

```bash
# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-rebuild)
dart run build_runner watch

# Run app
flutter run

# Analyze code
flutter analyze

# Format code
dart format .

# Clean build
flutter clean && flutter pub get
```

---

## 📁 Project Structure

```
lib/
├── app/                    # Config, router, theme
├── core/
│   ├── constants/         # AppColors, AppSizes
│   ├── extensions/        # DateTime, currency helpers
│   └── utils/             # CurrencyUtils, etc.
├── data/
│   ├── models/            # Hive models (@HiveType)
│   ├── repositories/      # Data access (CRUD)
│   └── services/          # NotificationService, etc.
└── features/
    └── [feature_name]/
        ├── [feature]_screen.dart
        ├── [feature]_controller.dart
        └── widgets/
```

---

## 🎨 Colors & Styling

```dart
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';

// Colors
AppColors.primary              // Green 600
AppColors.textPrimary          // Slate 900
AppColors.textSecondary        // Slate 500
AppColors.error                // Red 500
AppColors.warning              // Amber 500

// Spacing
AppSizes.xs      // 4px
AppSizes.sm      // 8px
AppSizes.base    // 16px (most common)
AppSizes.xl      // 24px
AppSizes.xxl     // 32px

// Border Radius
AppSizes.radiusMd    // 12px (cards)
AppSizes.radiusFull  // 999px (circles)
```

---

## 🔄 Riverpod Patterns

### AsyncNotifier (Screen Controller)

```dart
@riverpod
class HomeController extends _$HomeController {
  @override
  Future<List<Item>> build() async {
    final repo = await ref.watch(repositoryProvider.future);
    return repo.getAll();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(repositoryProvider.future);
      return repo.getAll();
    });
  }
}
```

### Watch State in Widget

```dart
final state = ref.watch(homeControllerProvider);

state.when(
  data: (items) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

### Call Controller Method

```dart
onPressed: () {
  ref.read(homeControllerProvider.notifier).deleteItem(id);
}
```

### Optimistic State Update (avoid skeleton flash)

For mutations where you only need to patch one field in the list (e.g., `markAsPaid`), update state in-place rather than calling `refresh()`:

```dart
// Patch only the affected item — avoids AsyncValue.loading() skeleton flash
final currentSubs = state.value ?? [];
state = AsyncValue.data(
  currentSubs.map((sub) {
    if (sub.id == targetId) return sub.copyWith(isPaid: true);
    return sub;
  }).toList(),
);
```

---

## 💾 Hive / Repository

### Define Model

```dart
@HiveType(typeId: 0)
class MyModel extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String name;

  MyModel({required this.id, required this.name});

  MyModel copyWith({String? id, String? name}) {
    return MyModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
```

### Repository Provider

```dart
@riverpod
Future<MyRepository> myRepository(Ref ref) async {
  final repo = MyRepository();
  await repo.init();
  return repo;
}
```

### Use Repository

```dart
final repo = await ref.read(myRepositoryProvider.future);

// CRUD
await repo.upsert(item);
final items = repo.getAll();
final item = repo.getById(id);
await repo.delete(id);
```

---

## 🔔 Notifications

### Schedule Notifications

```dart
final notificationService = ref.read(notificationServiceProvider);
await notificationService.scheduleNotificationsForSubscription(subscription);
```

### Cancel Notifications

```dart
await notificationService.cancelNotificationsForSubscription(subscription.id);
```

### Test Notification

```dart
await notificationService.showTestNotification();
```

---

## 💰 Currency

### Load Exchange Rates (in main)

```dart
await CurrencyUtils.loadExchangeRates();
```

### Convert Currency

```dart
final usd = CurrencyUtils.convert(100.0, 'EUR', 'USD');
```

### Format Amount

```dart
final formatted = CurrencyUtils.formatAmount(15.99, 'USD');
// Result: "$15.99"
```

### Get Symbol

```dart
final symbol = CurrencyUtils.getCurrencySymbol('EUR');
// Result: "€"
```

---

## 🎨 Brand Icons (SubscriptionIcon)

**Updated in v1.4.0** — Real brand logos via `simple_icons` (~80 services) + bundled SVG logos for trademark-removed brands

### Use the widget — don't call ServiceIcons directly

```dart
import 'package:custom_subs/core/widgets/subscription_icon.dart';

// Home screen tile (circle, 48px)
SubscriptionIcon(
  name: subscription.name,
  iconName: subscription.iconName,   // from template JSON, null for custom subs
  color: Color(subscription.colorValue),
  size: 48,
  isCircle: true,
)

// Detail header (rounded rect, 80px)
SubscriptionIcon(
  name: subscription.name,
  iconName: subscription.iconName,
  color: subscriptionColor,
  size: 80,
  isCircle: false,
)

// Template grid (circle, 56px)
SubscriptionIcon(
  name: template.name,
  iconName: template.iconName,
  color: Color(template.color),
  size: 56,
  isCircle: true,
)
```

### Icon resolution order (three tiers)

1. **Local SVG asset** (`assets/logos/{iconName}.svg`) — for brands removed from Simple Icons
2. **SimpleIcons** — `iconName` → `SimpleIcons.netflix` etc., then name-based fuzzy match
3. **Letter avatar** — first character of `name` in brand color

### Brands with bundled SVG logos (`assets/logos/`)

| Brand | File | Design |
|---|---|---|
| Disney+ | `disney.svg` | #113CCF blue, white "D+" |
| Hulu | `hulu.svg` | #1CE783 green, white "h" |
| Microsoft | `microsoft.svg` | white bg, 4 Windows squares |
| Adobe | `adobe.svg` | #FA0F00 red, white "A" |
| LinkedIn | `linkedin.svg` | #0077B5 blue, white "in" |
| Xbox | `xbox.svg` | #107C10 green, white "X" |
| Nintendo | `nintendo.svg` | #E4000F red, white "N" |
| Bumble | `bumble.svg` | #FFC629 yellow, dark "B" |

### Adding a logo for a new missing brand

```dart
// 1. Create assets/logos/{iconName}.svg  (100×100 viewBox, brand-color bg, white icon)
// 2. Add iconName to _localLogoIconNames in service_icons.dart
// 3. Run flutter pub get
static const Set<String> _localLogoIconNames = {
  'disney', 'hulu', 'microsoft', 'adobe', 'linkedin', 'xbox', 'nintendo', 'bumble',
  'hinge',  // after adding assets/logos/hinge.svg
};
```

### ServiceIcons API (used internally by SubscriptionIcon)

```dart
import 'package:custom_subs/core/utils/service_icons.dart';

// Check if local SVG exists (tier 1)
bool hasLogo = ServiceIcons.hasLocalLogo('disney');      // true
String path  = ServiceIcons.getLocalLogoPath('disney');  // 'assets/logos/disney.svg'

// SimpleIcons lookup (tier 2)
IconData? icon = ServiceIcons.getIconForIconName('netflix');  // SimpleIcons.netflix
IconData? icon = ServiceIcons.getIconByName('Netflix');       // name-based fuzzy match
```

### Mapped services via SimpleIcons (~80 total)

- **Streaming**: Netflix, Spotify, YouTube, Apple Music, Apple TV+, HBO, Crunchyroll, Tidal, Twitch, Pandora
- **Apple**: Apple Music, Apple TV+, Apple Arcade, iCloud
- **AI**: ChatGPT (OpenAI icon), Claude, Perplexity
- **Productivity**: Notion, Figma, Canva, Sketch, Framer, Miro, Loom, Airtable, Trello, Asana, ClickUp, Linear, Basecamp, Slack, Zoom, Discord
- **Developer**: GitHub, JetBrains, Replit, Webflow, Zapier
- **Finance**: Coinbase, Dashlane, NordVPN, ExpressVPN, Xero, Quickbooks
- **Gaming**: PlayStation, EA, Ubisoft
- **Fitness/Health**: Strava, Peloton, Headspace, Duolingo, Coursera, Skillshare
- **News**: Medium, Substack, New York Times
- **Social**: Discord, Snapchat, X, Patreon, OnlyFans, Tinder
- **Retail**: Target, Walmart, Amazon, Audible, Instacart, DoorDash, Uber, Tesla, Ring
- **And more**: Shopify, Mailchimp, HubSpot, Salesforce, Zendesk, Calendly, Typeform, Intercom, SurveyMonkey, 1Password, Paramount+

### Still falling back to letter avatar

Hinge, MyFitnessPal, ESPN, SiriusXM, Monday.com, Midjourney, Discovery, WSJ, Washington Post — no SVG file yet. Add one to `assets/logos/` to cover them.

---

## 🎬 Micro-Animations

**Added in v0.2.0** - Subtle animations for polish and feedback

### Button Press Animation

```dart
import 'package:custom_subs/core/widgets/subtle_pressable.dart';

SubtlePressable(
  onPressed: () => doSomething(),
  child: ElevatedButton(
    onPressed: null, // Set to null
    child: const Text('Press Me'),
  ),
)
```

### Badge Fade In/Out

```dart
AnimatedOpacity(
  opacity: isVisible ? 1.0 : 0.0,
  duration: const Duration(milliseconds: 250),
  curve: Curves.easeOut,
  child: YourBadge(),
)
```

### Smooth Width/Color Transition

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: isActive ? 24 : 8,
  color: isActive ? activeColor : inactiveColor,
  child: YourWidget(),
)
```

**Guidelines:**
- Keep animations < 300ms
- Use 2% scale for button press (0.98)
- Use `Curves.easeOut` for fades
- See `docs/design/MICRO_ANIMATIONS.md` for full guide

---

## 📊 Analytics & Crash Reporting

**Full guide:** [`docs/guides/analytics-and-tracking.md`](analytics-and-tracking.md)

### Track an Event

```dart
// With Riverpod ref (controllers, widgets):
ref.read(analyticsServiceProvider).capture('event_name', {
  'property': 'categorical_value',  // No PII, no user text, no amounts
  'is_flag': true,                  // Boolean OK
  'count': 5,                       // Int OK
});

// Without ref (static utilities, services):
AnalyticsService().capture('event_name', {'property': 'value'});
```

### Event Naming Convention

```
{noun}_{past_tense_verb}  in snake_case

subscription_created     ✅
template_selected        ✅
notification_tapped      ✅
create_subscription      ❌  (wrong verb tense)
```

### Crash Reporting (automatic)

Enabled via `errorTrackingConfig` in `AnalyticsService.init()`. Captures unhandled Flutter errors, platform errors, and isolate errors as `$exception` events. No manual setup needed.

### Screen Views (automatic)

`PosthogObserver()` on GoRouter sends `$screen` events on every route change. No manual code needed.

### In-App Review

```dart
// Triggers after 5th subscription created — wired in add_subscription_screen.dart
final reviewService = ReviewService();
await reviewService.incrementCreateCount();
await reviewService.maybePromptReview();  // Shows prompt if threshold met
```

### Opt-Out

```dart
final analytics = ref.read(analyticsServiceProvider);
await analytics.setOptOut(true);   // Stops all events + crash reporting
await analytics.setOptOut(false);  // Re-enables
```

---

## 📳 Haptic Feedback

**Added in v1.0.6** - Comprehensive tactile feedback for all interactions

```dart
import 'package:custom_subs/core/utils/haptic_utils.dart';

// Light haptic (10-20ms) - Navigation, icon buttons, taps
await HapticUtils.light();

// Medium haptic (30-40ms) - Primary buttons, toggles, state changes
await HapticUtils.medium();

// Heavy haptic (50ms) - Delete, destructive actions, pull-to-refresh
await HapticUtils.heavy();

// Selection haptic - Checkboxes, radio buttons, switches
await HapticUtils.selection();
```

### Usage Examples

```dart
// Navigation button
IconButton(
  icon: Icon(Icons.arrow_back),
  onPressed: () async {
    await HapticUtils.light();
    context.pop();
  },
)

// Primary action button
ElevatedButton(
  onPressed: () async {
    await HapticUtils.medium();
    await saveData();
  },
  child: Text('Save'),
)

// Delete action
onPressed: () async {
  await HapticUtils.heavy();
  await deleteItem();
}

// Checkbox
Checkbox(
  value: isChecked,
  onChanged: (value) async {
    await HapticUtils.selection();
    setState(() => isChecked = value);
  },
)

// Pull-to-refresh
RefreshIndicator(
  onRefresh: () async {
    await HapticUtils.heavy();
    await refreshData();
  },
  child: ListView(...),
)
```

**Guidelines:**
- Light: Navigation, list taps, icon buttons
- Medium: Primary buttons, save actions, mark as paid
- Heavy: Delete, pull-to-refresh, destructive actions
- Selection: Checkboxes, switches, toggles
- Always use `await` to ensure haptic fires before action
- Haptics require physical device (don't work in simulators)

---

## 🎨 Modern SnackBars

**Added in v1.0.6** - Aesthetic, floating snackbars with UNDO support

```dart
import 'package:custom_subs/core/utils/snackbar_utils.dart';

// Success snackbar (green, checkmark, 2s duration)
SnackBarUtils.show(
  context,
  SnackBarUtils.success('Subscription added!'),
);

// Error snackbar (red, error icon, 4s duration)
SnackBarUtils.show(
  context,
  SnackBarUtils.error('Failed to save data'),
);

// Warning snackbar (amber, warning icon, 3s duration)
SnackBarUtils.show(
  context,
  SnackBarUtils.warning('Please enter a valid amount'),
);

// Info snackbar (grey, info icon, 3s duration)
SnackBarUtils.show(
  context,
  SnackBarUtils.info('Data restored'),
);
```

### With UNDO Action

```dart
// Success with undo
SnackBarUtils.show(
  context,
  SnackBarUtils.success(
    'Subscription deleted',
    onUndo: () async {
      await HapticUtils.medium();
      await restoreSubscription();
    },
  ),
);
```

**Features:**
- Floating behavior with 16px border radius (matches StandardCard)
- Material icons for visual feedback
- Color-coded: green (success), red (error), amber (warning), grey (info)
- Optional UNDO action with white text button
- Consistent with app design system

---

## ↩️ Undo Service

**Added in v1.0.6** - 5-second memory cache for quick restoration

```dart
import 'package:custom_subs/data/services/undo_service.dart';

final undoService = UndoService();

// Cache before deletion
undoService.cacheDeletedSubscription(subscription);

// Retrieve within 5 seconds
final cached = undoService.getDeletedSubscription();
if (cached != null) {
  // Restore subscription
  await repository.upsert(cached);
}
```

### Supported Operations

**1. Subscription Deletion**
```dart
// Before delete
undoService.cacheDeletedSubscription(subscription);

// In UNDO callback
final cached = undoService.getDeletedSubscription();
if (cached != null) {
  await repository.upsert(cached);
  await notificationService.scheduleNotificationsForSubscription(cached);
}
```

**2. Currency Change**
```dart
// Before change
undoService.cacheCurrencyChange(previousCurrency);

// In UNDO callback
final previous = undoService.getPreviousCurrency();
if (previous != null) {
  await settingsRepository.setPrimaryCurrency(previous);
}
```

**3. Reminder Time Change**
```dart
// Before change
undoService.cacheReminderTimeChange(previousTime);

// In UNDO callback
final previous = undoService.getPreviousReminderTime();
if (previous != null) {
  await settingsRepository.setDefaultReminderTime(
    previous.hour,
    previous.minute,
  );
}
```

**Guidelines:**
- Cache expires after 5 seconds
- Singleton pattern (one instance across app)
- Returns null if expired or not cached
- Always check for null before restoring
- Use with SnackBarUtils.success() for best UX

---

## 📊 Analytics (PostHog)

**Added in v1.4.7** — Anonymous, privacy-first event tracking with opt-out toggle

### Track an Event

```dart
import 'package:custom_subs/data/services/analytics_service.dart';

// In a ConsumerWidget/ConsumerStatefulWidget
ref.read(analyticsServiceProvider).capture('event_name', {
  'category': 'entertainment',
  'cycle': 'monthly',
});

// Fire-and-forget — PostHog batches internally
// No-ops if not initialized or user opted out
```

### Event Schema (18 events)

| Event | Properties | Location |
|-------|-----------|----------|
| `app_launched` | `subscription_count`, `active_count`, `paused_count`, `app_mode`, `app_version` | `main.dart` |
| `$set` (person props) | `active_subscription_count`, `monthly_spend_usd`, `categories_used`, `top_category` | `main.dart` |
| `subscription_created` | `category`, `cycle`, `is_from_template`, `template_name`, `active_subscription_count` | `add_subscription_screen.dart` |
| `subscription_edited` | `category`, `cycle` | `add_subscription_screen.dart` |
| `subscription_deleted` | — | `home_controller.dart` |
| `subscription_marked_paid` | `is_paid` | `home_controller.dart` |
| `subscription_paused` | `has_resume_date` | `home_controller.dart` |
| `subscription_resumed` | — | `home_controller.dart` |
| `template_selected` | `template_name`, `category` | `add_subscription_screen.dart` |
| `onboarding_completed` | — | `onboarding_screen.dart` |

**Automatic events** (no code needed): `Application Opened`, `Application Backgrounded`, `$screen` (all GoRouter navigations)

### Opt-Out Toggle

```dart
// Check opt-out status
final isOptedOut = await ref.read(analyticsServiceProvider).isOptedOut();

// Set opt-out (persists in Hive, immediately disables PostHog SDK)
await ref.read(analyticsServiceProvider).setOptOut(true);
```

### Rules

- **No PII** — never include subscription names, amounts, or user-entered text in properties
- **Categorical properties only** — category names, cycle types, booleans, template names
- **Opt-out respected** — `capture()` no-ops when user has opted out
- **Constants**: `lib/core/constants/posthog_constants.dart` (API key, host, debug flag)
- **Service**: `lib/data/services/analytics_service.dart` (wrapper + opt-out)

---

## 📅 Date Extensions

```dart
import 'package:custom_subs/core/extensions/date_extensions.dart';

final date = DateTime(2024, 3, 15);

// Relative strings
date.toRelativeString()       // "in 10 days"
date.toShortRelativeString()  // "Mar 15"

// Formatting
date.toFormattedString()      // "Mar 15, 2024"
date.toShortFormattedString() // "Mar 15"

// Checks
date.isToday      // bool
date.isTomorrow   // bool
date.isPast       // bool
date.isFuture     // bool

// Calculations
date.daysUntil    // int
date.addMonths(1) // DateTime (handles month overflow)
```

---

## 🎯 Navigation

### GoRouter Routes — Page Transition Patterns

```dart
// Content push — iOS slide (CupertinoPage)
// Use for: screens the user drills into (detail, add, edit, analytics)
GoRoute(
  path: '/my-screen',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    child: const MyScreen(),
  ),
),

// Modal-style — Fade (AppRouter._fadePage)
// Use for: utility/overlay screens (settings, paywall)
GoRoute(
  path: '/my-modal',
  pageBuilder: (context, state) => AppRouter._fadePage(
    key: state.pageKey,
    child: const MyModalScreen(),
  ),
),

// Root/stack-replacement — Default (builder)
// Use for: home, onboarding (no visible transition needed)
GoRoute(
  path: '/',
  builder: (context, state) => const HomeScreen(),
),
```

### Navigate

```dart
context.push('/my-screen');   // Push onto stack (shows transition)
context.go('/my-screen');     // Replace stack (no transition)
context.pop();                // Go back
```

---

## 📝 Forms

### Form Key

```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: /* form fields */,
)
```

### Text Field with Validation

```dart
TextFormField(
  controller: _nameController,
  decoration: InputDecoration(labelText: 'Name'),
  validator: (value) =>
      value?.isEmpty ?? true ? 'Required' : null,
)
```

### Submit Form

```dart
Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSaving = true);

  try {
    await HapticUtils.medium(); // Save action feedback

    // Save logic
    final repo = await ref.read(repositoryProvider.future);
    await repo.upsert(item);

    if (mounted) {
      SnackBarUtils.show(
        context,
        SnackBarUtils.success('Saved successfully!'),
      );
      context.pop();
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isSaving = false);
      SnackBarUtils.show(
        context,
        SnackBarUtils.error('Error: $e'),
      );
    }
  }
}
```

---

## 🎨 Common Widgets

### Card

```dart
Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
  ),
  child: Padding(
    padding: EdgeInsets.all(AppSizes.base),
    child: /* content */,
  ),
)
```

### Empty State

```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.inbox, size: 64, color: AppColors.textTertiary),
      SizedBox(height: AppSizes.base),
      Text('No items yet', style: Theme.of(context).textTheme.titleLarge),
      SizedBox(height: AppSizes.sm),
      Text('Tap + to add your first item'),
    ],
  ),
)
```

### Skeleton Loading States

```dart
import 'package:custom_subs/core/widgets/skeleton_widgets.dart';

// Base skeleton box
SkeletonBox(
  width: 120,
  height: 16,
  borderRadius: AppSizes.radiusSm,
)

// Pre-built skeleton tiles
const SkeletonSubscriptionTile()  // Matches subscription list item
const SkeletonCategoryBar()       // Matches analytics category bar
const SkeletonTemplateItem()      // Matches template grid item

// Usage in AsyncValue loading state
loading: () => ListView(
  children: [
    const SkeletonSubscriptionTile(),
    const SkeletonSubscriptionTile(),
    const SkeletonSubscriptionTile(),
  ],
)
```

### Hero Animations

```dart
// Wrap icons/widgets for shared element transitions
Hero(
  tag: 'subscription-icon-${subscription.id}',  // Must be unique
  child: Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(shape: BoxShape.circle),
    child: Icon(Icons.star),
  ),
)

// Destination screen uses same tag
Hero(
  tag: 'subscription-icon-${subscription.id}',  // Same tag!
  child: Container(
    width: 80,
    height: 80,
    // Different size/shape - animates automatically
  ),
)
```

### Interactive Donut Chart

```dart
import 'package:custom_subs/features/analytics/widgets/category_donut_chart.dart';

CategoryDonutChart(
  categoryBreakdown: analytics.categoryBreakdown,  // Map<Category, CategoryData>
  currencySymbol: '\$',
)

// Features:
// - Touch interaction (sections expand on tap)
// - Animated legend with highlighting
// - Shows subscription count badges
// - 250ms smooth animations
```

### Pull to Refresh

```dart
RefreshIndicator(
  onRefresh: () async {
    await HapticUtils.heavy(); // Pull-to-refresh feedback
    await ref.read(controllerProvider.notifier).refresh();
  },
  child: ListView(...),
)
```

---

## 🏠 Home Screen

### Spending Summary Card

`_SpendingSummaryCard` (home_screen.dart) — tappable card at the top of the home feed.

- **Tap to cycle:** Monthly → Yearly → Daily → Monthly (loops)
- **Formulas:** yearly = `monthlyTotal * 12`, daily = `monthlyTotal * 12 / 365` (matches analytics_screen)
- **State:** `_SpendingPeriod` enum + `_tweenBegin` tracked in `_SpendingSummaryCardState`
- **Animation:** `TweenAnimationBuilder` (800ms) animates the number; `AnimatedSwitcher` (200ms) crossfades the label; `AnimatedContainer` dots indicate active period
- **Source data:** `HomeController.calculateMonthlyTotal()` — active subs only, converted to primary currency
- **No controller changes needed** — yearly/daily derived in-widget

### Home Screen Sections

The Home screen has **three subscription list sections** — all must stay in sync:

| Section | Method | Range | Notes |
|---|---|---|---|
| **Upcoming** | `getUpcomingSubscriptions(days: 31)` | Today → +30 days (inclusive) | Swipe actions; paid tiles at 55% opacity with "Paid · N of M" divider |
| **Later** | `getLaterSubscriptions(fromDays: 31)` | +31 → +90 days | Read-only, muted tile |
| **Paused** | `getPausedSubscriptions()` | N/A | Sorted by pause date |

> **Boundary note:** `getUpcomingSubscriptions` is called with `days: 31` so that its exclusive upper bound (`isBefore(today + 31)`) correctly includes subscriptions billing exactly 30 days from now. `getLaterSubscriptions` starts at `fromDays: 31` to match.

```dart
// All use calendar-day boundaries (not current time):
final todayStart = DateTime(now.year, now.month, now.day);
```

---

## ⏸️ Subscription Pause / Snooze

**Rule:** `isActive` is the pause flag. `isActive = false` means paused. Use the `isPaused` getter — never add a new `isPaused` field (see ADR 004).

```dart
// Check pause state — always use the getter, not the raw field
subscription.isPaused          // true if paused
subscription.isResumingSoon    // true if resumeDate is within 7 days
subscription.shouldAutoResume  // true if resumeDate has passed

// Pause a subscription (with optional auto-resume date)
await repository.pauseSubscription(id, resumeDate: DateTime(2026, 4, 1));

// Resume manually
await repository.resumeSubscription(id);

// Get all paused subscriptions
final paused = await repository.getAllPaused();

// Auto-resume any with past resumeDate (called on startup, foreground, refresh)
await repository.autoResumeSubscriptions();
```

**Three rules for paused subscriptions:**
1. **Upcoming/Later queries exclude paused** — always filter `sub.isActive &&`
2. **Billing dates freeze while paused** — `advanceOverdueBillingDates()` skips paused subs
3. **Notifications skip paused** — `scheduleNotificationsForSubscription()` returns early if `!sub.isActive`

**Auto-resume runs in 3 places** (same pattern as billing date advancement):
- App startup → `main.dart`
- App foreground → `home_screen.dart` → `didChangeAppLifecycleState(resumed)`
- Pull-to-refresh → `home_screen.dart`

---

## 📅 Date Comparison — Calendar Day vs Exact Time

**Always strip time when comparing billing dates at the day level.**

```dart
// ❌ WRONG — advances midnight-dated subs at 9am (user never sees "Today")
if (nextBillingDate.isBefore(DateTime.now())) { ... }

// ✅ CORRECT — only advances dates strictly before today
final today = DateTime(now.year, now.month, now.day);
if (nextBillingDate.isBefore(today)) { ... }

// ✅ CORRECT — includes today's subs in the upcoming list
final todayStart = DateTime(now.year, now.month, now.day);
if (!nextBillingDate.isBefore(todayStart)) { ... }
```

This pattern is used in:
- `subscription_repository.dart` → `advanceOverdueBillingDates()`
- `home_controller.dart` → `getUpcomingSubscriptions()`, `getLaterSubscriptions()`

---

## 💎 Premium Entitlement — Currently Free Mode

As of v1.5.0, the app is free (`RevenueCatConstants.isFreeMode = true`). `isPremiumProvider` always returns `true` — no subscription limits.

RevenueCat SDK still initializes for passive tracking. Paywall code preserved but dormant (route removed).

**To re-monetize:** Set `isFreeMode = false`, re-add `/paywall` route, re-add Premium UI. See `docs/guides/iap-and-premium.md`.

`ref.invalidate(isPremiumProvider)` is still called on app foreground (`home_screen.dart`) for re-monetization readiness.

---

## ⚠️ Common Pitfalls

### ❌ Don't Access Hive Directly from Widgets

```dart
// WRONG
final box = Hive.box<Subscription>('subscriptions');

// CORRECT
final repo = await ref.read(subscriptionRepositoryProvider.future);
```

### ❌ Don't Forget to Dispose Controllers

```dart
@override
void dispose() {
  _controller.dispose();  // Always dispose!
  super.dispose();
}
```

### ❌ Don't Use ref.watch() in Event Handlers

```dart
// WRONG
onPressed: () {
  ref.watch(provider).method();
}

// CORRECT
onPressed: () {
  ref.read(provider.notifier).method();
}
```

### ❌ Don't Forget Code Generation

```bash
# After adding @riverpod or @HiveType:
dart run build_runner build --delete-conflicting-outputs
```

---

## 📦 Subscription Templates

**File:** `assets/data/subscription_templates.json` — 329 services

### Price Convention (established March 2026)
- **Tier:** Most popular individual paid plan (not cheapest, not premium)
- **Cycle:** Monthly billing rate (exception: annual-only services use `yearly` cycle)
- **Currency:** USD
- **Last verified:** March 2026 — next review Q3 2026

### Key tier decisions
| Service | Tier | Why |
|---------|------|-----|
| Netflix | Standard | Most popular non-ads tier |
| Disney+ | Standard (with ads) | Most popular by subscriber count |
| Hulu | Standard (with ads) | Most popular entry point |
| Max | Standard (ad-free) | Primary product positioning |
| Paramount+ | Essential (with ads) | Most popular entry tier |
| PlayStation Plus | Essential | Most popular; Extra/Premium are niche |

### Adding/updating a template
```json
{
  "id": "service_name",          // lowercase snake_case, unique
  "name": "Display Name",        // as shown in app
  "defaultAmount": 9.99,         // most popular plan, USD monthly
  "defaultCurrency": "USD",
  "defaultCycle": "monthly",     // weekly/monthly/quarterly/biannual/yearly
  "category": "entertainment",   // entertainment/productivity/fitness/news/cloud/gaming/education/finance/shopping/utilities/health/other/sports
  "cancelUrl": "https://...",    // direct cancel page, null if unknown
  "color": "0xFFRRGGBB",        // hex ARGB
  "iconName": "service_name"    // must match ServiceIcons mapping or falls back to letter
}
```

---

## 📚 File Locations

| File | Path |
|------|------|
| **Colors** | `lib/core/constants/app_colors.dart` |
| **Sizes** | `lib/core/constants/app_sizes.dart` |
| **Theme** | `lib/app/theme.dart` |
| **Router** | `lib/app/router.dart` |
| **Currency Utils** | `lib/core/utils/currency_utils.dart` |
| **Service Icons** | `lib/core/utils/service_icons.dart` |
| **Subscription Icon Widget** | `lib/core/widgets/subscription_icon.dart` |
| **Haptic Utils** | `lib/core/utils/haptic_utils.dart` |
| **SnackBar Utils** | `lib/core/utils/snackbar_utils.dart` |
| **Undo Service** | `lib/data/services/undo_service.dart` |
| **Date Extensions** | `lib/core/extensions/date_extensions.dart` |
| **Analytics Service** | `lib/data/services/analytics_service.dart` |
| **PostHog Constants** | `lib/core/constants/posthog_constants.dart` |
| **Notification Service** | `lib/data/services/notification_service.dart` |
| **Subscription Repository** | `lib/data/repositories/subscription_repository.dart` |
| **Exchange Rates** | `assets/data/exchange_rates.json` |
| **Templates** | `assets/data/subscription_templates.json` |

---

## 🔗 Documentation Links

| Topic | Link |
|-------|------|
| **Full Spec** | [CLAUDE.md](../CLAUDE.md) |
| **Architecture** | [docs/architecture/overview.md](architecture/overview.md) |
| **State Management** | [docs/architecture/state-management.md](architecture/state-management.md) |
| **Data Layer** | [docs/architecture/data-layer.md](architecture/data-layer.md) |
| **Adding Features** | [docs/guides/adding-a-feature.md](guides/adding-a-feature.md) |
| **Notifications** | [docs/guides/working-with-notifications.md](guides/working-with-notifications.md) |
| **Forms** | [docs/guides/forms-and-validation.md](guides/forms-and-validation.md) |
| **Currency** | [docs/guides/multi-currency.md](guides/multi-currency.md) |
| **Templates** | [docs/templates/](templates/) |
| **ADRs** | [docs/decisions/](decisions/) |

---

## 🎯 Quick Checklist: Adding a Feature

- [ ] Create directory: `lib/features/[feature_name]/`
- [ ] Create screen: `[feature]_screen.dart`
- [ ] Create controller (if needed): `[feature]_controller.dart`
- [ ] Run: `dart run build_runner build`
- [ ] Add route in `lib/app/router.dart`
- [ ] Add navigation from existing screens
- [ ] Test: loading, data, error, empty states
- [ ] Verify data persists (close/reopen app)

---

## 🐛 Debugging Tips

**App won't build?**
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

**Notifications not firing?**
- Test on real device (not simulator)
- Check: Settings → Test Notification
- Verify: `await notificationService.scheduleNotificationsForSubscription()`

**State not updating?**
- Use `ref.watch()` in build(), not `ref.read()`
- Call `refresh()` after mutations
- Check: Did you run code generation?

**Hive errors?**
- Did you call `repository.init()`?
- Did you register type adapters in `main()`?
- Check typeId and field indices are unique

**Subscriptions not appearing after save?** *(Fixed in v0.1.1)*
- Add `ref.invalidate(homeControllerProvider)` after save
- This forces the home screen to refresh

**Subscription billing today not showing as "Today"?** *(Fixed in v1.4.1)*
- Check that `advanceOverdueBillingDates()` uses `isBefore(today)` not `isBefore(now)`
- Check that `getUpcomingSubscriptions()` uses `!isBefore(todayStart)` not `isAfter(now)`
- See: `subscription_repository.dart` and `home_controller.dart`

**Premium badge not clearing after trial expires?** *(Fixed in v1.4.1, now moot — app is free as of v1.5.0)*
- `ref.invalidate(isPremiumProvider)` is still called in `didChangeAppLifecycleState(resumed)` for re-monetization readiness

**Yearly subscription invisible on Home screen?** *(Fixed in v1.4.1)*
- Subs billing 31–90 days out now appear in the "Later" section
- `getLaterSubscriptions(fromDays: 31)` in `HomeController` handles this range

**Subscription billing in exactly 30 days showing in "Later" instead of "Upcoming"?** *(Fixed post-v1.4.1)*
- `getUpcomingSubscriptions` uses an exclusive upper bound — `days: 31` ensures day 30 is included
- `getLaterSubscriptions` starts at `fromDays: 31` to avoid overlap

**Mark as Paid causes a skeleton flash + jarring list reorder?** *(Fixed post-v1.4.1)*
- `markAsPaid()` in `home_controller.dart` was calling `refresh()` which sets `AsyncValue.loading()`, triggering the skeleton screen before re-rendering the reordered list
- Fix: use an optimistic in-place state update (see "Optimistic State Update" pattern above) — patches only the affected item, no loading state, smooth single-frame reorder
- Paid tiles now fade to 55% opacity, sort below a "Paid · N of M" divider, and show an undo snackbar (2s)
- Notifications are cancelled for paid subs; swipe indicator changes to amber/undo on paid tiles

**NotificationService not initialized?** *(Fixed in v0.1.1)*
```dart
// Wrong
final service = ref.read(notificationServiceProvider);

// Correct (use .future for async providers)
final service = await ref.read(notificationServiceProvider.future);
```

**UI overflow errors?**
- Check GridView `childAspectRatio` (lower = taller cells)
- Verify padding doesn't exceed available space
- Use `MainAxisSize.min` in Column/Row when needed

---

## 🔔 Notification Permission Check (v1.4.2+)

Check if OS notifications are enabled before firing a test notification. Android exposes a public API; iOS is optimistic (no public check without `permission_handler`).

```dart
// In NotificationService
Future<bool> areNotificationsEnabled() async {
  if (Platform.isAndroid) {
    final plugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await plugin?.areNotificationsEnabled() ?? true;
  }
  return true; // iOS: optimistic — trust that user configured on first launch
}

// Usage in settings_screen.dart
final enabled = await notificationService.areNotificationsEnabled();
if (!enabled) {
  // Show dialog with AppSettings.openAppSettings(type: AppSettingsType.notification)
} else {
  // Fire test notification
  await notificationService.showTestNotification();
}
```

**Package**: `app_settings: ^5.2.0` — use `AppSettings.openAppSettings(type: AppSettingsType.notification)` on both platforms. Note: `openNotificationSettings()` was removed in v5.x; use the typed `openAppSettings()` API instead.

---

## 💰 Spending Period Toggle Pattern (v1.4.2+)

Tap-to-cycle between spending periods. Used in the home spending summary card.

```dart
// File-private enum — add above the widget class
enum _SpendingPeriod { monthly, yearly, daily }

// In State class
_SpendingPeriod _period = _SpendingPeriod.monthly;
double _tweenBegin = 0.0;

double _amountForPeriod(double monthly, _SpendingPeriod p) => switch (p) {
  _SpendingPeriod.monthly => monthly,
  _SpendingPeriod.yearly  => monthly * 12,
  _SpendingPeriod.daily   => monthly * 12 / 365,
};

void _cyclePeriod() {
  setState(() {
    _tweenBegin = _amountForPeriod(widget.monthlyTotal, _period); // morph from current
    _period = _SpendingPeriod.values[(_period.index + 1) % 3];
  });
}
```

- **Number animation**: `TweenAnimationBuilder<double>` (800ms, `Curves.easeOutCubic`)
- **Label animation**: `AnimatedSwitcher` (200ms) for the `/month` → `/year` → `/day` label
- **Page indicator**: `AnimatedContainer` (250ms) for the 3-dot indicator

---

**Need more detail? See the full guides in `/docs`!**
