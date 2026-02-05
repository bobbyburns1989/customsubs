# Adding a Feature

**Status**: ✅ Complete
**Last Updated**: February 4, 2026
**Relevant to**: Developers

**Step-by-step guide for implementing new features following CustomSubs architecture patterns.**

This guide walks through adding a complete feature with screen, controller, routing, and integration with existing services.

---

## Table of Contents

1. [Before You Start](#before-you-start)
2. [Feature Planning Checklist](#feature-planning-checklist)
3. [Step-by-Step Implementation](#step-by-step-implementation)
4. [Example: Analytics Screen](#example-analytics-screen)
5. [Common Patterns](#common-patterns)
6. [Testing Your Feature](#testing-your-feature)

---

## Before You Start

### Prerequisites

- ✅ Read `docs/architecture/state-management.md` - Understand Riverpod patterns
- ✅ Read `CLAUDE.md` - Understand project specifications
- ✅ Study existing features in `lib/features/` - See patterns in action

### Required Tools

```bash
# Code generation (run after creating controllers/models)
dart run build_runner build --delete-conflicting-outputs

# Or watch mode (auto-rebuild on changes)
dart run build_runner watch --delete-conflicting-outputs
```

---

## Feature Planning Checklist

Before writing code, answer these questions:

### 1. What does this feature do?
- [ ] Clear one-sentence description
- [ ] User story: "As a user, I want to..."
- [ ] Expected inputs and outputs

### 2. What data does it need?
- [ ] Existing models sufficient?
- [ ] New model needed? (requires Hive migration)
- [ ] Data from repository, service, or both?

### 3. What state needs management?
- [ ] Screen-level state (use Riverpod controller)
- [ ] Transient form state (use StatefulWidget)
- [ ] Shared state (use existing providers)

### 4. Does it integrate with existing features?
- [ ] Notifications needed?
- [ ] Repository updates needed?
- [ ] Navigation from/to existing screens?

### 5. Design decisions
- [ ] UI layout and components
- [ ] Error states and loading indicators
- [ ] Empty state design
- [ ] Validation requirements (if form)

---

## Step-by-Step Implementation

### Step 1: Create Feature Directory

**Structure:**
```
lib/features/your_feature/
├── your_feature_screen.dart       # UI
├── your_feature_controller.dart   # State management (if needed)
└── widgets/                       # Feature-specific widgets
    ├── widget_one.dart
    └── widget_two.dart
```

**Example:**
```bash
mkdir -p lib/features/analytics/widgets
touch lib/features/analytics/analytics_screen.dart
touch lib/features/analytics/analytics_controller.dart
```

### Step 2: Create the Controller (if needed)

**When to create a controller:**
- Screen displays async data (from repository/service)
- Screen has mutations that affect app state
- Screen needs computed properties based on state

**When NOT to create a controller:**
- Simple form with local state only
- Static information page
- Settings screen that just calls services directly

**Template:**

```dart
// lib/features/analytics/analytics_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/data/models/subscription_category.dart';

part 'analytics_controller.g.dart';

@riverpod
class AnalyticsController extends _$AnalyticsController {
  @override
  Future<Map<SubscriptionCategory, double>> build() async {
    // Initialize state - load data
    final repository = await ref.watch(subscriptionRepositoryProvider.future);
    return repository.getSpendingByCategory();
  }

  // Add methods for user interactions
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(subscriptionRepositoryProvider.future);
      return repository.getSpendingByCategory();
    });
  }

  // Computed properties
  double getTotalMonthlySpending() {
    final spending = state.value ?? {};
    return spending.values.fold(0.0, (sum, amount) => sum + amount);
  }
}
```

**Run code generation:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 3: Create the Screen

**Template:**

```dart
// lib/features/analytics/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_subs/features/analytics/analytics_controller.dart';
import 'package:custom_subs/app/theme.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(analyticsControllerProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: analyticsState.when(
        data: (spending) => _buildContent(context, ref, spending),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, error),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Map<SubscriptionCategory, double> spending,
  ) {
    if (spending.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(analyticsControllerProvider.notifier).refresh();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTotalCard(context, ref),
          const SizedBox(height: 16),
          _buildCategoryBreakdown(context, spending),
        ],
      ),
    );
  }

  Widget _buildTotalCard(BuildContext context, WidgetRef ref) {
    final controller = ref.read(analyticsControllerProvider.notifier);
    final total = controller.getTotalMonthlySpending();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Monthly Total',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    BuildContext context,
    Map<SubscriptionCategory, double> spending,
  ) {
    final sortedEntries = spending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By Category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...sortedEntries.map((entry) => _buildCategoryTile(
                  context,
                  entry.key,
                  entry.value,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    SubscriptionCategory category,
    double amount,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category.displayName,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No spending data yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add subscriptions to see your analytics',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading analytics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

### Step 4: Add Route

**Location:** `lib/app/router.dart`

```dart
// Add to routes list
GoRoute(
  path: '/analytics',
  name: 'analytics',
  pageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: const AnalyticsScreen(),
  ),
),
```

### Step 5: Add Navigation

**From existing screen (e.g., HomeScreen):**

```dart
ElevatedButton(
  onPressed: () => context.push('/analytics'),
  child: const Text('Analytics'),
),
```

**Or with GoRouter named routes:**

```dart
ElevatedButton(
  onPressed: () => context.pushNamed('analytics'),
  child: const Text('Analytics'),
),
```

### Step 6: Integration (if needed)

#### If the feature needs notifications:

```dart
// In your save/update method
final notificationService = ref.read(notificationServiceProvider);
await notificationService.scheduleNotificationsForSubscription(subscription);
```

#### If the feature modifies subscriptions:

```dart
// Always go through repository
final repository = await ref.read(subscriptionRepositoryProvider.future);
await repository.upsert(subscription);

// Then refresh your controller
await ref.read(yourControllerProvider.notifier).refresh();
```

#### If the feature needs currency conversion:

```dart
import 'package:custom_subs/core/utils/currency_utils.dart';

final converted = CurrencyUtils.convert(
  amount: subscription.amount,
  from: subscription.currencyCode,
  to: 'USD',
);
```

### Step 7: Extract Reusable Widgets

**When to extract:**
- Widget used more than once in the same screen
- Widget is complex (>50 lines)
- Widget represents a domain concept (e.g., "subscription card")

**Create in `widgets/` subdirectory:**

```dart
// lib/features/analytics/widgets/category_chart.dart
import 'package:flutter/material.dart';
import 'package:custom_subs/data/models/subscription_category.dart';

class CategoryChart extends StatelessWidget {
  final Map<SubscriptionCategory, double> spending;

  const CategoryChart({
    super.key,
    required this.spending,
  });

  @override
  Widget build(BuildContext context) {
    // Chart implementation
    return Container();
  }
}
```

**Use in screen:**

```dart
import 'package:custom_subs/features/analytics/widgets/category_chart.dart';

// In build method
CategoryChart(spending: spending),
```

### Step 8: Test

1. **Hot reload** - Test UI changes
2. **Hot restart** - Test state changes
3. **Full restart** - Test initialization and navigation
4. **Device testing** - Test on real device if feature uses native APIs

---

## Example: Analytics Screen

**Complete implementation of Analytics feature following all steps.**

### File Structure

```
lib/features/analytics/
├── analytics_screen.dart        # Main UI (200 lines)
├── analytics_controller.dart    # State management
├── analytics_controller.g.dart  # Generated
└── widgets/
    ├── monthly_total_card.dart  # Total spending card
    └── category_breakdown_card.dart  # Category list
```

### Controller

```dart
// analytics_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/models/subscription.dart';

part 'analytics_controller.g.dart';

class AnalyticsData {
  final double monthlyTotal;
  final double yearlyTotal;
  final Map<SubscriptionCategory, double> byCategory;
  final List<Subscription> topSubscriptions;

  AnalyticsData({
    required this.monthlyTotal,
    required this.yearlyTotal,
    required this.byCategory,
    required this.topSubscriptions,
  });
}

@riverpod
class AnalyticsController extends _$AnalyticsController {
  @override
  Future<AnalyticsData> build() async {
    final repository = await ref.watch(subscriptionRepositoryProvider.future);
    return _calculateAnalytics(repository);
  }

  AnalyticsData _calculateAnalytics(SubscriptionRepository repository) {
    final monthlyTotal = repository.calculateMonthlyTotal();
    final yearlyTotal = monthlyTotal * 12;
    final byCategory = repository.getSpendingByCategory();

    // Get top 5 subscriptions by monthly equivalent
    final allSubs = repository.getAllActive();
    final sorted = List<Subscription>.from(allSubs)
      ..sort((a, b) => b.effectiveMonthlyAmount.compareTo(a.effectiveMonthlyAmount));
    final topSubscriptions = sorted.take(5).toList();

    return AnalyticsData(
      monthlyTotal: monthlyTotal,
      yearlyTotal: yearlyTotal,
      byCategory: byCategory,
      topSubscriptions: topSubscriptions,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(subscriptionRepositoryProvider.future);
      return _calculateAnalytics(repository);
    });
  }
}
```

### Widget Extraction

```dart
// widgets/monthly_total_card.dart
import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class MonthlyTotalCard extends StatelessWidget {
  final double monthlyTotal;
  final double yearlyTotal;
  final int subscriptionCount;

  const MonthlyTotalCard({
    super.key,
    required this.monthlyTotal,
    required this.yearlyTotal,
    required this.subscriptionCount,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Monthly Total',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(monthlyTotal),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '$subscriptionCount active subscriptions',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Yearly forecast: ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  currencyFormat.format(yearlyTotal),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### Route Addition

```dart
// lib/app/router.dart
GoRoute(
  path: '/analytics',
  name: 'analytics',
  pageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: const AnalyticsScreen(),
  ),
),
```

### Navigation Hook

```dart
// In HomeScreen
ElevatedButton.icon(
  onPressed: () => context.push('/analytics'),
  icon: const Icon(Icons.analytics_outlined),
  label: const Text('Analytics'),
),
```

---

## Common Patterns

### Pattern 1: List Screen with Pull-to-Refresh

```dart
class MyListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myControllerProvider);

    return Scaffold(
      body: state.when(
        data: (items) => RefreshIndicator(
          onRefresh: () => ref.read(myControllerProvider.notifier).refresh(),
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(items[index].name),
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorWidget(err),
      ),
    );
  }
}
```

### Pattern 2: Form Screen (No Controller Needed)

```dart
class AddItemScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final item = Item(
      name: _nameController.text,
      category: _selectedCategory!,
    );

    final repository = await ref.read(repositoryProvider.future);
    await repository.add(item);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Required' : null,
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: ['Category A', 'Category B']
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Pattern 3: Detail Screen with Actions

```dart
class DetailScreen extends ConsumerWidget {
  final String itemId;

  const DetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(repositoryProvider.future).then((repo) => repo.getById(itemId)),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final item = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(item.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/edit/$itemId'),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, ref, itemId),
              ),
            ],
          ),
          body: _buildContent(context, item),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final repository = await ref.read(repositoryProvider.future);
      await repository.delete(id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
```

---

## Testing Your Feature

### Checklist

- [ ] **Hot reload works** - UI changes appear without restart
- [ ] **Loading state displays** - Shows spinner while loading
- [ ] **Empty state displays** - Shows friendly message when no data
- [ ] **Error state displays** - Shows error message on failure
- [ ] **Pull-to-refresh works** - Reloads data
- [ ] **Navigation works** - Can navigate to/from feature
- [ ] **Back button works** - Returns to previous screen
- [ ] **Repository integration works** - Data saves/loads correctly
- [ ] **Notifications scheduled** (if applicable) - Verify in notification settings
- [ ] **Real device testing** - Test on physical device
- [ ] **State persists** - Close/reopen app, data still there

### Manual Testing Steps

1. **Navigate to feature** from existing screen
2. **Verify loading state** - Should show spinner initially
3. **Verify empty state** - Clear data, check empty state appears
4. **Add data** - Create items and verify they appear
5. **Pull to refresh** - Drag down, verify refresh works
6. **Tap item** - Navigate to detail (if applicable)
7. **Edit item** - Modify and save, verify changes
8. **Delete item** - Remove and verify gone
9. **Close app** - Force close and reopen
10. **Verify persistence** - Data should still be there

---

## Summary

**Feature implementation checklist:**

1. ✅ Create feature directory: `lib/features/your_feature/`
2. ✅ Create controller (if needed): `your_feature_controller.dart`
3. ✅ Run code generation: `dart run build_runner build`
4. ✅ Create screen: `your_feature_screen.dart`
5. ✅ Add route: Update `lib/app/router.dart`
6. ✅ Add navigation: Link from existing screens
7. ✅ Extract widgets: Move reusable UI to `widgets/` subdirectory
8. ✅ Integrate services: Repository, notifications, etc.
9. ✅ Test thoroughly: All states, navigation, persistence

**See also:**
- `docs/architecture/state-management.md` - Riverpod patterns
- `docs/templates/screen-with-controller.dart` - Full annotated example
- `docs/templates/feature-template.md` - Quick reference template
- Existing features: `lib/features/home/`, `lib/features/settings/`
