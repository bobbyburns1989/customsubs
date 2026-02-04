# Quick Reference

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
    // Save logic
    final repo = await ref.read(repositoryProvider.future);
    await repo.upsert(item);

    if (mounted) {
      Navigator.pop(context);
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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

### Loading Spinner

```dart
Center(child: CircularProgressIndicator())
```

### Pull to Refresh

```dart
RefreshIndicator(
  onRefresh: () async {
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
