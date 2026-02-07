# Quick Reference

**Status**: ✅ Complete
**Last Updated**: February 7, 2026
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

## 🎨 Service Icons

**Added in v0.1.1** - Display recognizable icons for 50+ popular services

```dart
import 'package:custom_subs/core/utils/service_icons.dart';

// Get icon for service
IconData icon = ServiceIcons.getIconForService('Netflix');
// Returns: Icons.movie

// Check if service has custom icon
bool hasIcon = ServiceIcons.hasCustomIcon('Spotify');
// Returns: true

// Get fallback letter
String letter = ServiceIcons.getDisplayLetter('MyService');
// Returns: "M"
```

### Usage in CircleAvatar

```dart
CircleAvatar(
  backgroundColor: color.withOpacity(0.2),
  child: ServiceIcons.hasCustomIcon(subscription.name)
      ? Icon(
          ServiceIcons.getIconForService(subscription.name),
          color: color,
          size: 24,
        )
      : Text(
          subscription.name[0].toUpperCase(),
          style: TextStyle(color: color),
        ),
)
```

### Supported Services

- **Streaming**: Netflix, Spotify, Disney+, Hulu, HBO Max, YouTube, Apple Music/TV
- **Cloud**: iCloud, Google One, Dropbox, OneDrive
- **Gaming**: Xbox Game Pass, PlayStation Plus, Nintendo Switch Online
- **Productivity**: Microsoft 365, Adobe, Canva, Notion, Evernote
- **Fitness**: Peloton, Strava, Headspace, Calm
- **And 30+ more services!**

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

### GoRouter Routes

```dart
// In lib/app/router.dart
GoRoute(
  path: '/my-screen',
  name: 'myScreen',
  pageBuilder: (context, state) => MaterialPage(
    child: MyScreen(),
  ),
),
```

### Navigate

```dart
context.push('/my-screen');
context.pushNamed('myScreen');
context.go('/my-screen');
Navigator.pop(context);  // Go back
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

## 📚 File Locations

| File | Path |
|------|------|
| **Colors** | `lib/core/constants/app_colors.dart` |
| **Sizes** | `lib/core/constants/app_sizes.dart` |
| **Theme** | `lib/app/theme.dart` |
| **Router** | `lib/app/router.dart` |
| **Currency Utils** | `lib/core/utils/currency_utils.dart` |
| **Service Icons** | `lib/core/utils/service_icons.dart` |
| **Haptic Utils** | `lib/core/utils/haptic_utils.dart` |
| **SnackBar Utils** | `lib/core/utils/snackbar_utils.dart` |
| **Undo Service** | `lib/data/services/undo_service.dart` |
| **Date Extensions** | `lib/core/extensions/date_extensions.dart` |
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

**Need more detail? See the full guides in `/docs`!**
