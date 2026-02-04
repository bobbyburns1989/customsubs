# Data Layer Architecture

**Complete guide to data persistence, models, and repository patterns in CustomSubs.**

This document explains how data is stored, accessed, and managed using Hive and the repository pattern.

---

## Table of Contents

1. [Overview](#overview)
2. [Hive Setup](#hive-setup)
3. [Model Pattern](#model-pattern)
4. [Repository Pattern](#repository-pattern)
5. [Data Migrations](#data-migrations)
6. [Best Practices](#best-practices)

---

## Overview

### Architecture

```
Widgets (UI)
    ↓
Controllers (State Management)
    ↓
Repositories (Data Access)
    ↓
Hive Boxes (Persistence)
```

**Key principle:** Widgets never access Hive directly. All data operations go through repositories.

### Why Hive?

- **Offline-first** - No network dependency
- **Fast** - Synchronous reads, lazy loading
- **Type-safe** - Code generation for adapters
- **Lightweight** - ~100KB, no SQLite overhead
- **Key-value store** - Simple, NoSQL

### Hive vs Alternatives

| Feature | Hive | SQLite | Shared Preferences |
|---------|------|--------|-------------------|
| **Offline** | ✅ | ✅ | ✅ |
| **Type-safe** | ✅ Code gen | ❌ Manual | ❌ Primitives only |
| **Performance** | ✅ Fast | ⚠️ Slower | ✅ Fast |
| **Complex models** | ✅ | ✅ SQL | ❌ |
| **Queries** | ❌ Filter in Dart | ✅ SQL | ❌ |
| **Setup** | Simple | Complex | Simple |

**Verdict:** Hive perfect for CustomSubs (simple models, fast access, offline).

---

## Hive Setup

### Initialization

**In `main.dart`:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register type adapters (MUST be in order by typeId)
  Hive.registerAdapter(SubscriptionAdapter());  // typeId: 0
  Hive.registerAdapter(SubscriptionCycleAdapter());  // typeId: 1
  Hive.registerAdapter(SubscriptionCategoryAdapter());  // typeId: 2
  Hive.registerAdapter(ReminderConfigAdapter());  // typeId: 3

  // Open boxes (or let repository handle it)
  // await Hive.openBox<Subscription>('subscriptions');

  runApp(MyApp());
}
```

### Box Types

**Subscription box:**
```dart
Box<Subscription> subscriptions;  // Stores subscription objects
```

**Settings box:**
```dart
Box<dynamic> settings;  // Stores key-value pairs (strings, ints, bools)
```

**Why separate boxes?**
- Type safety (Subscription box only accepts Subscription objects)
- Performance (smaller boxes load faster)
- Organization (clear separation of concerns)

---

## Model Pattern

### Defining Models

**All models must be annotated with `@HiveType` and `@HiveField`:**

```dart
import 'package:hive/hive.dart';

part 'subscription.g.dart';  // Generated file

@HiveType(typeId: 0)  // Unique ID (0-223, never reuse!)
class Subscription extends HiveObject {
  @HiveField(0)  // Field index (must be unique within model)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String currencyCode;

  // Constructor
  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.currencyCode,
  });

  // copyWith for immutability
  Subscription copyWith({
    String? id,
    String? name,
    double? amount,
    String? currencyCode,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}
```

### TypeId Rules

**CRITICAL:** TypeIds must be:
- Unique across all models
- Never reused (even if model is deleted)
- Between 0-223
- Registered in order

```dart
// ✅ CORRECT
Subscription          // typeId: 0
SubscriptionCycle     // typeId: 1
SubscriptionCategory  // typeId: 2

// ❌ WRONG - Duplicate typeId
Subscription          // typeId: 0
ReminderConfig        // typeId: 0  // Collision!
```

### Field Index Rules

**Field indices must be:**
- Unique within the model
- Never reused (even if field is deleted)
- Any integer (no limit)

```dart
@HiveField(0) final String id;
@HiveField(1) final String name;
@HiveField(2) final double amount;

// Adding new field later:
@HiveField(10) final String? newField;  // Skip indices OK
```

### Enum Models

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

### Code Generation

**After defining models, run:**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Generates:**
- `subscription.g.dart` - Contains `SubscriptionAdapter`
- Must be committed to version control

**Watch mode** (auto-rebuild):
```bash
dart run build_runner watch --delete-conflicting-outputs
```

---

## Repository Pattern

### Repository Structure

```dart
class SubscriptionRepository {
  static const String _boxName = 'subscriptions';
  Box<Subscription>? _box;

  /// Initialize repository (opens Hive box)
  Future<void> init() async {
    _box = await Hive.openBox<Subscription>(_boxName);
  }

  /// Get box (throws if not initialized)
  Box<Subscription> get _getBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Repository not initialized');
    }
    return _box!;
  }

  // CRUD methods...
}
```

### CRUD Operations

**Create/Update (Upsert):**
```dart
Future<void> upsert(Subscription subscription) async {
  // Find by ID
  final existingKey = _getBox.keys.firstWhere(
    (key) => _getBox.get(key)?.id == subscription.id,
    orElse: () => null,
  );

  if (existingKey != null) {
    // Update
    await _getBox.put(existingKey, subscription);
  } else {
    // Create
    await _getBox.add(subscription);
  }
}
```

**Read:**
```dart
// Get all
List<Subscription> getAll() {
  return _getBox.values.toList();
}

// Get by ID
Subscription? getById(String id) {
  return _getBox.values.firstWhere(
    (sub) => sub.id == id,
    orElse: () => null,
  );
}

// Get filtered
List<Subscription> getAllActive() {
  return _getBox.values.where((sub) => sub.isActive).toList();
}
```

**Delete:**
```dart
Future<void> delete(String id) async {
  final key = _getBox.keys.firstWhere(
    (key) => _getBox.get(key)?.id == id,
    orElse: () => null,
  );

  if (key != null) {
    await _getBox.delete(key);
  }
}
```

### Reactive Data (Streams)

**Watch for changes:**
```dart
Stream<List<Subscription>> watchActive() {
  return _getBox.watch().map((_) => getAllActive());
}
```

**Usage in Riverpod:**
```dart
@riverpod
Stream<List<Subscription>> activeSubscriptions(Ref ref) async* {
  final repository = await ref.watch(subscriptionRepositoryProvider.future);
  yield* repository.watchActive();
}
```

### Repository Provider

**Wrap in Riverpod provider:**
```dart
@riverpod
Future<SubscriptionRepository> subscriptionRepository(Ref ref) async {
  final repository = SubscriptionRepository();
  await repository.init();  // Opens box
  return repository;
}
```

**Usage:**
```dart
// In widget/controller
final repository = await ref.read(subscriptionRepositoryProvider.future);
await repository.upsert(subscription);
```

---

## Data Migrations

### Adding New Fields

**Safe to add anytime:**

```dart
@HiveType(typeId: 0)
class Subscription {
  @HiveField(0) final String id;
  @HiveField(1) final String name;

  // New field added in v1.1
  @HiveField(10) final String? tags;  // Nullable for backward compat

  Subscription({
    required this.id,
    required this.name,
    this.tags,  // Optional
  });
}
```

**Rules:**
- Use new field index (never reuse old ones)
- Make field nullable or provide default
- Existing data loads fine (new field = null)

### Removing Fields

**Option 1: Leave field, stop using it**
```dart
@HiveField(5) final String? oldField;  // Keep but unused
```

**Option 2: Remove field, keep index reserved**
```dart
// Field 5 removed - DON'T REUSE INDEX 5!
@HiveField(0) final String id;
@HiveField(1) final String name;
// Index 5 permanently reserved
@HiveField(6) final String newField;
```

### Changing Field Types

**NOT SAFE - Requires migration:**

```dart
// Before
@HiveField(2) final int amount;

// After
@HiveField(2) final double amount;  // ❌ Breaking change!
```

**Migration strategy:**
```dart
// Add new field with new index
@HiveField(2) final int oldAmount;  // Keep old
@HiveField(20) final double amount;  // New field

// Migrate on load
double get actualAmount => amount ?? oldAmount.toDouble();
```

### Complex Migrations

**Strategy:**
1. Add new fields with new indices
2. Load old data
3. Transform and save with new fields
4. Remove old fields in next version

**Example:**
```dart
Future<void> migrateV1ToV2() async {
  final box = await Hive.openBox<Subscription>('subscriptions');

  for (var i = 0; i < box.length; i++) {
    final sub = box.getAt(i);
    if (sub != null && sub.version == 1) {
      // Migrate
      final updated = sub.copyWith(
        newField: transformOldField(sub.oldField),
        version: 2,
      );
      await box.putAt(i, updated);
    }
  }
}
```

---

## Best Practices

### 1. Always Initialize Repository

```dart
// ✅ CORRECT - Initialize via provider
@riverpod
Future<SubscriptionRepository> subscriptionRepository(Ref ref) async {
  final repo = SubscriptionRepository();
  await repo.init();
  return repo;
}

// ❌ WRONG - Use without initializing
final repo = SubscriptionRepository();
repo.getAll();  // Throws!
```

### 2. Never Access Hive from Widgets

```dart
// ✅ CORRECT - Use repository
final repository = await ref.read(subscriptionRepositoryProvider.future);
final subs = repository.getAllActive();

// ❌ WRONG - Direct Hive access
final box = Hive.box<Subscription>('subscriptions');
final subs = box.values.toList();
```

### 3. Use Immutable Models with copyWith

```dart
// ✅ CORRECT - Immutable with copyWith
final updated = subscription.copyWith(name: 'New Name');

// ❌ WRONG - Mutable (can cause bugs)
subscription.name = 'New Name';
```

### 4. Make New Fields Nullable

```dart
// ✅ CORRECT - Nullable for backward compat
@HiveField(10) final String? newField;

// ❌ WRONG - Required field breaks old data
@HiveField(10) final String newField;  // Can't load old data!
```

### 5. Never Reuse TypeIds or Field Indices

```dart
// ❌ WRONG - Reused typeId
Subscription        // typeId: 0
DeletedModel        // typeId: 1 (deleted)
NewModel            // typeId: 1  // Collision!

// ✅ CORRECT - Skip deleted typeIds
Subscription        // typeId: 0
// typeId 1 permanently reserved
NewModel            // typeId: 2
```

### 6. Close Boxes on App Exit

```dart
// In app lifecycle
@override
void dispose() {
  Hive.close();  // Closes all boxes
  super.dispose();
}
```

### 7. Await All Hive Operations

```dart
// ✅ CORRECT - Await writes
await repository.upsert(subscription);
await notificationService.schedule(subscription);

// ❌ WRONG - Fire and forget (data loss risk)
repository.upsert(subscription);  // Not awaited!
Navigator.pop(context);  // Might close before save completes
```

---

## Quick Reference

| Task | Code |
|------|------|
| Initialize Hive | `await Hive.initFlutter()` |
| Register adapter | `Hive.registerAdapter(SubscriptionAdapter())` |
| Open box | `await Hive.openBox<T>('boxName')` |
| Get all | `box.values.toList()` |
| Get by key | `box.get(key)` |
| Add item | `await box.add(item)` |
| Update item | `await box.put(key, item)` |
| Delete item | `await box.delete(key)` |
| Clear box | `await box.clear()` |
| Watch box | `box.watch()` |
| Close box | `await box.close()` |
| Run codegen | `dart run build_runner build` |

---

## Summary

**Data layer checklist:**

1. ✅ Define models with `@HiveType` and `@HiveField`
2. ✅ Use unique typeIds (0-223, never reuse)
3. ✅ Use unique field indices (never reuse)
4. ✅ Run build_runner after model changes
5. ✅ Wrap repositories in Riverpod providers
6. ✅ Always initialize repository before use
7. ✅ Never access Hive directly from widgets
8. ✅ Use immutable models with copyWith
9. ✅ Make new fields nullable for migrations
10. ✅ Await all Hive write operations

**See also:**
- `lib/data/models/` - Model implementations
- `lib/data/repositories/` - Repository implementations
- `docs/architecture/overview.md` - Overall architecture
- Hive documentation: https://docs.hivedb.dev/
