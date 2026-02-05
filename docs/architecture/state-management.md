# State Management Guide

**Status**: ✅ Complete
**Last Updated**: February 4, 2026
**Relevant to**: Developers

**CustomSubs uses Riverpod with code generation for all state management.**

This guide explains our Riverpod patterns, conventions, and when to use each approach.

---

## Table of Contents

1. [Core Principles](#core-principles)
2. [Provider Types & When to Use](#provider-types--when-to-use)
3. [AsyncNotifier Pattern](#asyncnotifier-pattern)
4. [Service Providers](#service-providers)
5. [Accessing State in Widgets](#accessing-state-in-widgets)
6. [Common Patterns](#common-patterns)
7. [Pitfalls to Avoid](#pitfalls-to-avoid)

---

## Core Principles

### 1. Always Use Code Generation

**Never create providers manually.** Always use `@riverpod` annotation and code generation.

```dart
// ✅ CORRECT
@riverpod
class HomeController extends _$HomeController {
  @override
  FutureOr<List<Subscription>> build() async {
    // ...
  }
}

// ❌ WRONG - Never do this
final homeProvider = StateNotifierProvider<HomeController, AsyncValue<List<Subscription>>>(...);
```

**Why?** Code generation provides:
- Type safety
- Automatic disposal
- Better performance
- Compile-time errors vs runtime errors
- Less boilerplate

### 2. Separation of Concerns

- **Controllers** (`features/**/` directories) - UI state and user interactions
- **Repositories** (`data/repositories/` directory) - Data access and CRUD operations
- **Services** (`data/services/` directory) - Cross-cutting concerns (notifications, backup, templates)

### 3. Repository First

Widgets should **never** access Hive boxes directly. All data operations go through the repository.

```dart
// ✅ CORRECT
final repository = await ref.read(subscriptionRepositoryProvider.future);
await repository.upsert(subscription);

// ❌ WRONG - Never access Hive directly from widgets
final box = Hive.box<Subscription>('subscriptions');
await box.add(subscription);
```

---

## Provider Types & When to Use

### AsyncNotifier (For Screen Controllers)

**Use when:** Managing complex UI state that requires async initialization and user interactions.

**Pattern:** Stateful controller that holds data and provides methods for mutations.

**Example:** `HomeController` (see `lib/features/home/home_controller.dart`)

```dart
@riverpod
class HomeController extends _$HomeController {
  @override
  FutureOr<List<Subscription>> build() async {
    // Initialize async data
    final repository = await ref.watch(subscriptionRepositoryProvider.future);
    return repository.getAllActive();
  }

  // Mutation methods
  Future<void> deleteSubscription(String id) async {
    final repository = await ref.read(subscriptionRepositoryProvider.future);
    await repository.delete(id);
    await refresh(); // Reload state
  }

  // Computed properties (pure functions)
  double calculateMonthlyTotal() {
    final subs = state.value ?? [];
    return subs.fold(0.0, (sum, sub) => sum + sub.effectiveMonthlyAmount);
  }
}
```

**Key points:**
- `build()` runs once on initialization
- Use `state = ...` to update state
- Use `ref.watch()` for reactive dependencies
- Use `ref.read()` for one-time reads in methods
- Call `refresh()` to reload data after mutations

### FutureProvider (For Async Services)

**Use when:** Providing asynchronous services or data that needs initialization.

**Pattern:** Service that requires async setup (e.g., opening Hive box).

**Example:** `subscriptionRepositoryProvider` (see `lib/data/repositories/subscription_repository.dart:224-229`)

```dart
@riverpod
Future<SubscriptionRepository> subscriptionRepository(Ref ref) async {
  final repository = SubscriptionRepository();
  await repository.init(); // Opens Hive box
  return repository;
}
```

**Accessing in widgets:**
```dart
// Option 1: Watch and handle loading state
ref.watch(subscriptionRepositoryProvider).when(
  data: (repo) => /* use repo */,
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);

// Option 2: In async methods (most common)
final repository = await ref.read(subscriptionRepositoryProvider.future);
await repository.upsert(subscription);
```

### StreamProvider (For Reactive Data)

**Use when:** UI needs to react to data changes automatically (live updates).

**Pattern:** Stream that emits new data when underlying data changes.

**Example:** `activeSubscriptionsProvider` (see `lib/data/repositories/subscription_repository.dart:232-236`)

```dart
@riverpod
Stream<List<Subscription>> activeSubscriptions(Ref ref) async* {
  final repository = await ref.watch(subscriptionRepositoryProvider.future);
  yield* repository.watchActive(); // Hive box watch stream
}
```

**When to use StreamProvider:**
- You need live updates when data changes
- Multiple screens need to react to the same data
- Example: Subscription list that updates when user edits from another screen

**When NOT to use:**
- Simple data fetching (use FutureProvider or AsyncNotifier)
- Data that doesn't change often (use AsyncNotifier + manual refresh)

### Provider (For Sync Services)

**Use when:** Providing synchronous services or utilities.

**Pattern:** Service with no async initialization.

**Example:** `templateService` (if it only loads bundled JSON)

```dart
@riverpod
TemplateService templateService(Ref ref) {
  return TemplateService(); // No async init needed
}
```

---

## AsyncNotifier Pattern

### State Management

AsyncNotifier uses `AsyncValue<T>` which has three states:

```dart
// Loading
state = const AsyncValue.loading();

// Success
state = AsyncValue.data(subscriptions);

// Error
state = AsyncValue.error(error, stackTrace);
```

### The build() Method

- Runs **once** when the provider is first accessed
- Must return `FutureOr<T>` (can be sync or async)
- Use `ref.watch()` to create reactive dependencies
- Automatically rebuilds when dependencies change

```dart
@override
FutureOr<List<Subscription>> build() async {
  // This line makes the controller rebuild when repository emits new data
  final repository = await ref.watch(subscriptionRepositoryProvider.future);
  return repository.getAllActive();
}
```

### Mutation Methods

Methods that modify state should:
1. Update the repository (single source of truth)
2. Refresh the controller state
3. Use `AsyncValue.guard()` for error handling

```dart
Future<void> deleteSubscription(String id) async {
  // 1. Update repository
  final repository = await ref.read(subscriptionRepositoryProvider.future);
  await repository.delete(id);

  // 2. Refresh state
  await refresh();
}

// Or with explicit loading state
Future<void> deleteSubscription(String id) async {
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(() async {
    final repository = await ref.read(subscriptionRepositoryProvider.future);
    await repository.delete(id);
    return repository.getAllActive();
  });
}
```

### Computed Properties

Pure functions that derive data from current state:

```dart
double calculateMonthlyTotal() {
  final subs = state.value ?? [];
  return subs.fold(0.0, (sum, sub) => sum + sub.effectiveMonthlyAmount);
}
```

**Key point:** These are **not cached**. Call them when needed, but don't call them repeatedly in the same build cycle.

---

## Service Providers

Services (like NotificationService, BackupService) should be wrapped in providers for:
- Testability (easy to mock)
- Lifecycle management
- Dependency injection

```dart
@riverpod
NotificationService notificationService(Ref ref) {
  return NotificationService();
}
```

**Usage in controllers:**
```dart
Future<void> scheduleReminders(Subscription sub) async {
  final notificationService = ref.read(notificationServiceProvider);
  await notificationService.scheduleNotificationsForSubscription(sub, sub.reminders);
}
```

---

## Accessing State in Widgets

### ref.watch() - For Reactive UI

**Use when:** Widget needs to rebuild when data changes.

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final homeState = ref.watch(homeControllerProvider);

  return homeState.when(
    data: (subscriptions) => ListView.builder(...),
    loading: () => CircularProgressIndicator(),
    error: (err, stack) => Text('Error: $err'),
  );
}
```

**When to use:**
- Displaying data in UI
- Showing loading/error states
- Any time UI should react to state changes

### ref.read() - For One-Time Reads

**Use when:** Calling methods, not displaying state.

```dart
onPressed: () {
  final controller = ref.read(homeControllerProvider.notifier);
  controller.deleteSubscription(subscription.id);
}
```

**When to use:**
- Event handlers (onPressed, onChanged)
- One-time data fetches
- Calling controller methods

**When NOT to use:**
- In `build()` method for displaying data (use `watch` instead)

### ref.listen() - For Side Effects

**Use when:** You need to react to state changes with side effects (navigation, snackbars).

```dart
ref.listen(homeControllerProvider, (previous, next) {
  next.whenOrNull(
    error: (err, stack) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $err')),
      );
    },
  );
});
```

---

## Common Patterns

### Pattern 1: List Screen with Controller

**File structure:**
```
features/home/
├── home_screen.dart       # UI
├── home_controller.dart   # State + logic
└── home_controller.g.dart # Generated
```

**Controller:**
```dart
@riverpod
class HomeController extends _$HomeController {
  @override
  FutureOr<List<Item>> build() async {
    return await fetchItems();
  }

  Future<void> deleteItem(String id) async {
    await repository.delete(id);
    await refresh();
  }
}
```

**Screen:**
```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);

    return state.when(
      data: (items) => ListView.builder(...),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => ErrorWidget(err),
    );
  }
}
```

### Pattern 2: Form with Local State + Repository

**For forms, use a combination:**
- Local state (TextEditingController, selected values) - managed by StatefulWidget
- Repository calls - via ref.read()

```dart
class AddSubscriptionScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> {
  final _nameController = TextEditingController();
  SubscriptionCycle _selectedCycle = SubscriptionCycle.monthly;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repository = await ref.read(subscriptionRepositoryProvider.future);
    await repository.upsert(subscription);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: Column(
          children: [
            TextField(controller: _nameController),
            DropdownButton(
              value: _selectedCycle,
              onChanged: (cycle) => setState(() => _selectedCycle = cycle),
            ),
            ElevatedButton(
              onPressed: _save,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Why not use a controller for forms?**
- Form state is transient (only exists while editing)
- TextEditingControllers work well with StatefulWidget
- No need for the overhead of Riverpod state management
- Use Riverpod only for data persistence (repository calls)

### Pattern 3: Refresh on Action

```dart
Future<void> refresh() async {
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(() async {
    final repository = await ref.read(subscriptionRepositoryProvider.future);
    return repository.getAllActive();
  });
}
```

---

## Pitfalls to Avoid

### ❌ Don't use ref.watch() in Event Handlers

```dart
// WRONG - Will cause unnecessary rebuilds
onPressed: () {
  final controller = ref.watch(homeControllerProvider.notifier);
  controller.delete(id);
}

// CORRECT - Use ref.read()
onPressed: () {
  final controller = ref.read(homeControllerProvider.notifier);
  controller.delete(id);
}
```

### ❌ Don't Access state.value Without Null Check

```dart
// WRONG - Can throw if loading or error
final subscriptions = state.value;
subscriptions.forEach(...);

// CORRECT - Handle all states
final subscriptions = state.value ?? [];
```

Or use `.when()`:
```dart
state.when(
  data: (subs) => /* use subs */,
  loading: () => /* handle loading */,
  error: (err, stack) => /* handle error */,
);
```

### ❌ Don't Create Stateful Logic in Widgets

```dart
// WRONG - Business logic in widget
class HomeScreen extends ConsumerWidget {
  double calculateTotal(List<Subscription> subs) {
    return subs.fold(0.0, (sum, sub) => sum + sub.amount);
  }
}

// CORRECT - Logic in controller
class HomeController extends _$HomeController {
  double calculateMonthlyTotal() {
    final subs = state.value ?? [];
    return subs.fold(0.0, (sum, sub) => sum + sub.effectiveMonthlyAmount);
  }
}
```

### ❌ Don't Forget to Refresh After Mutations

```dart
// WRONG - State won't update
Future<void> deleteSubscription(String id) async {
  final repository = await ref.read(subscriptionRepositoryProvider.future);
  await repository.delete(id);
  // Missing: await refresh();
}

// CORRECT
Future<void> deleteSubscription(String id) async {
  final repository = await ref.read(subscriptionRepositoryProvider.future);
  await repository.delete(id);
  await refresh(); // ✅ Reload state
}
```

### ❌ Don't Mix Sync and Async in build()

```dart
// WRONG - build() must be consistently sync or async
@override
FutureOr<List<Subscription>> build() {
  if (someCondition) {
    return Future.value([]); // async
  } else {
    return []; // sync
  }
}

// CORRECT - Pick one approach
@override
Future<List<Subscription>> build() async {
  // Always async
  return await fetchData();
}
```

---

## Running Code Generation

After creating or modifying any file with `@riverpod` annotation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**When to run:**
- After creating a new controller
- After modifying any `@riverpod` annotation
- When you see errors about missing `.g.dart` files

**Watch mode** (auto-rebuild on file changes):
```bash
dart run build_runner watch --delete-conflicting-outputs
```

---

## Quick Reference

| Task | Use This |
|------|----------|
| Screen state management | `@riverpod class XController extends _$XController` |
| Async service (needs init) | `@riverpod Future<Service> service(Ref ref) async { ... }` |
| Sync service | `@riverpod Service service(Ref ref) { ... }` |
| Live data updates | `@riverpod Stream<T> data(Ref ref) async* { ... }` |
| Display data in UI | `ref.watch(provider)` |
| Call methods | `ref.read(provider.notifier).method()` |
| Side effects on change | `ref.listen(provider, (prev, next) { ... })` |
| Access data value | `state.value` or `state.when(...)` |
| Update state | `state = AsyncValue.data(newData)` |
| Reload data | `await refresh()` |

---

## Examples in Codebase

**Study these files for reference:**

- `lib/features/home/home_controller.dart` - AsyncNotifier pattern
- `lib/data/repositories/subscription_repository.dart` - FutureProvider and StreamProvider
- `lib/features/home/home_screen.dart` - Using ref.watch() and ref.read()

---

## Summary

1. **Always use code generation** with `@riverpod`
2. **AsyncNotifier** for screen controllers with complex state
3. **FutureProvider** for async services (repository, notification service)
4. **StreamProvider** for live data updates
5. **ref.watch()** in build() for reactive UI
6. **ref.read()** in methods for one-time access
7. **Refresh after mutations** to reload state
8. **Keep business logic in controllers**, not widgets

**See also:**
- `docs/guides/adding-a-feature.md` - Step-by-step feature implementation
- `docs/architecture/data-layer.md` - Working with Hive and repositories
- `docs/templates/screen-with-controller.dart` - Full annotated example
