# ADR 001: Riverpod Code Generation

**Status**: Accepted
**Date**: 2024-01-15
**Deciders**: Development Team
**Context**: State management pattern for CustomSubs

---

## Context and Problem Statement

CustomSubs needs a state management solution that is:
- Type-safe (catch errors at compile time)
- Testable (easy to mock and test)
- Reactive (UI updates automatically)
- Maintainable (clear, concise code)
- Performant (minimal rebuilds)

We need to decide between **manual Riverpod providers** vs **code generation with annotations**.

---

## Decision Drivers

1. **Developer Experience** - Reduce boilerplate and cognitive load
2. **Type Safety** - Compile-time errors over runtime crashes
3. **Maintainability** - Easy for new developers to understand
4. **Performance** - Efficient provider lifecycle management
5. **Flutter Ecosystem** - Use recommended patterns

---

## Considered Options

### Option 1: Manual Provider Definitions

**Example:**
```dart
final homeProvider = StateNotifierProvider<HomeController, AsyncValue<List<Subscription>>>((ref) {
  return HomeController(ref.watch(subscriptionRepositoryProvider));
});

class HomeController extends StateNotifier<AsyncValue<List<Subscription>>> {
  HomeController(this.repository) : super(const AsyncValue.loading()) {
    _init();
  }

  final SubscriptionRepository repository;

  Future<void> _init() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return repository.getAllActive();
    });
  }
}
```

**Pros:**
- No build_runner dependency
- Explicit provider definitions
- No generated files to manage

**Cons:**
- Verbose boilerplate code
- Easy to make mistakes in provider definitions
- Manual provider disposal
- Type-safety depends on correct generics
- More code to write and maintain

### Option 2: Code Generation with Annotations (CHOSEN)

**Example:**
```dart
@riverpod
class HomeController extends _$HomeController {
  @override
  Future<List<Subscription>> build() async {
    final repository = await ref.watch(subscriptionRepositoryProvider.future);
    return repository.getAllActive();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(subscriptionRepositoryProvider.future);
      return repository.getAllActive();
    });
  }
}
```

**Pros:**
- Less boilerplate (40-60% less code)
- Type-safe by default (compiler enforces correct types)
- Automatic provider generation and disposal
- Consistent patterns across codebase
- Better IDE support and autocomplete
- Official Riverpod recommendation
- Easier to refactor

**Cons:**
- Requires build_runner (adds ~5 seconds to build)
- Generated files need version control (.g.dart files)
- Learning curve for annotation syntax
- Dependency on code generation tooling

---

## Decision Outcome

**Chosen option: Code Generation with Annotations (Option 2)**

### Rationale

1. **Reduced Boilerplate**
   - 40-60% less code to write and maintain
   - Focus on business logic, not provider wiring

2. **Better Type Safety**
   - Compiler enforces correct provider types
   - Catch errors at compile time, not runtime
   - Example: Forgetting to return a value in build() is a compile error

3. **Recommended by Riverpod**
   - Official documentation recommends code generation
   - Future-proof (new Riverpod features target annotations)
   - Community best practice

4. **Easier Onboarding**
   - New developers see less "magic"
   - Clear separation: controller logic vs generated provider
   - Consistent patterns across all controllers

5. **AI-Friendly**
   - Claude Code and other AI tools understand annotations
   - Less context needed in prompts
   - Easier to generate correct code

### Build_Runner Impact

**Acceptable trade-offs:**
- **Build time**: Adds ~5 seconds. Run once, then use watch mode.
- **CI/CD**: Add `dart run build_runner build` step. Minimal impact.
- **Generated files**: Commit `.g.dart` files to avoid rebuilds.

**Commands:**
```bash
# One-time build
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-rebuild on changes)
dart run build_runner watch --delete-conflicting-outputs
```

---

## Consequences

### Positive

1. **Faster Development**
   - Less time writing boilerplate
   - More time on features

2. **Fewer Bugs**
   - Type system catches errors
   - Less manual provider management

3. **Better Maintainability**
   - Consistent code patterns
   - Easier to refactor
   - Self-documenting code structure

4. **Future-Proof**
   - Aligned with Riverpod roadmap
   - Easy to adopt new Riverpod features

### Negative

1. **Build Step Required**
   - Must run build_runner after changes
   - Watch mode mitigates this in development

2. **Generated Files**
   - `.g.dart` files in version control
   - Can confuse new developers initially
   - IDE shows extra files in file tree

3. **Learning Curve**
   - Team needs to understand annotations
   - Different from traditional Flutter patterns
   - Mitigated by: clear documentation and examples

---

## Implementation Notes

### When to Use Code Generation

**Always use `@riverpod` annotation for:**
- Screen controllers (AsyncNotifier)
- Service providers (FutureProvider, Provider)
- Repository providers (FutureProvider)
- Stream providers (StreamProvider)

**Example patterns:**

```dart
// AsyncNotifier - Screen state with async initialization
@riverpod
class HomeController extends _$HomeController {
  @override
  Future<List<Item>> build() async { /* ... */ }
}

// FutureProvider - Async service/repository
@riverpod
Future<SubscriptionRepository> subscriptionRepository(Ref ref) async {
  final repo = SubscriptionRepository();
  await repo.init();
  return repo;
}

// Provider - Sync service
@riverpod
NotificationService notificationService(Ref ref) {
  return NotificationService();
}

// StreamProvider - Reactive data
@riverpod
Stream<List<Subscription>> activeSubscriptions(Ref ref) async* {
  final repo = await ref.watch(subscriptionRepositoryProvider.future);
  yield* repo.watchActive();
}
```

### Don't Use Code Generation For

- Form state (use StatefulWidget + local state)
- Transient UI state (use StatefulWidget)
- One-off widgets without state

### Team Workflow

1. **Write controller with annotation**
2. **Save file** - build_runner watch detects change (if running)
3. **If not running watch**: `dart run build_runner build`
4. **Import generated file** in your code if needed
5. **Commit `.g.dart` files** to version control

---

## Related Decisions

- See `docs/architecture/state-management.md` for Riverpod patterns
- See `docs/templates/screen-with-controller.dart` for complete example
- See `docs/guides/adding-a-feature.md` for feature implementation

---

## References

- [Riverpod Code Generation Docs](https://riverpod.dev/docs/concepts/about_code_generation)
- [Riverpod Best Practices](https://riverpod.dev/docs/essentials/first_request)
- [Flutter State Management Comparison](https://docs.flutter.dev/data-and-backend/state-mgmt/options)

---

## Revision History

| Date | Change | Author |
|------|--------|--------|
| 2024-01-15 | Initial decision | Development Team |
