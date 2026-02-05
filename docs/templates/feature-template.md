# Feature Implementation Template

**Status**: ✅ Complete
**Last Updated**: February 4, 2026
**Relevant to**: Developers

**Quick-reference checklist for implementing a new feature in CustomSubs.**

Copy this template and fill in the blanks as you work through implementation.

---

## Feature Name: [Your Feature Name]

### 1. Planning

**Feature Description:**
```
[One-sentence description of what this feature does]
```

**User Story:**
```
As a [user type],
I want to [action],
So that [benefit].
```

**Acceptance Criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

---

### 2. Data Requirements

**Existing Models:** [List models you'll use]
- [ ] Subscription
- [ ] SubscriptionCategory
- [ ] ReminderConfig
- [ ] Other: _______________

**New Models Needed?** [Yes/No]
- [ ] If yes, what fields are needed?
- [ ] Will it require Hive migration?

**Data Sources:**
- [ ] SubscriptionRepository
- [ ] NotificationService
- [ ] Other: _______________

---

### 3. State Management

**Does this feature need a controller?** [Yes/No]

**If yes:**
- [ ] AsyncNotifier (async data loading)
- [ ] Notifier (sync state only)

**If no, why not?**
- [ ] Simple form with local state
- [ ] Static information page
- [ ] Settings page calling services directly

---

### 4. Implementation Checklist

#### Step 1: Create Directory Structure
```bash
mkdir -p lib/features/[feature_name]/widgets
touch lib/features/[feature_name]/[feature_name]_screen.dart
# If needed:
touch lib/features/[feature_name]/[feature_name]_controller.dart
```

- [ ] Directory created
- [ ] Screen file created
- [ ] Controller file created (if needed)

#### Step 2: Implement Controller (if needed)

```dart
// lib/features/[feature_name]/[feature_name]_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
// ... other imports

part '[feature_name]_controller.g.dart';

@riverpod
class [FeatureName]Controller extends _$[FeatureName]Controller {
  @override
  FutureOr<[DataType]> build() async {
    // Initialize state
  }

  // Methods for user interactions
}
```

- [ ] Controller implemented
- [ ] build() method defined
- [ ] Mutation methods added
- [ ] Computed properties added (if needed)
- [ ] Code generation run: `dart run build_runner build`

#### Step 3: Implement Screen

```dart
// lib/features/[feature_name]/[feature_name]_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class [FeatureName]Screen extends ConsumerWidget {
  const [FeatureName]Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Implementation
  }
}
```

- [ ] Screen implemented
- [ ] AppBar configured
- [ ] Loading state handled
- [ ] Error state handled
- [ ] Empty state handled (if applicable)
- [ ] Main content implemented

#### Step 4: Add Route

```dart
// lib/app/router.dart
GoRoute(
  path: '/[feature-name]',
  name: '[featureName]',
  pageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: const [FeatureName]Screen(),
  ),
),
```

- [ ] Route added to router.dart
- [ ] Route tested (can navigate to screen)

#### Step 5: Add Navigation

**From:** [Which screen(s) navigate to this feature?]

```dart
// Example: In HomeScreen
ElevatedButton(
  onPressed: () => context.push('/[feature-name]'),
  child: const Text('[Button Label]'),
),
```

- [ ] Navigation added from relevant screen(s)
- [ ] Navigation tested (can get to feature)
- [ ] Back navigation works

#### Step 6: Extract Reusable Widgets

**Widgets to extract:** [List complex/reused widgets]
- [ ] Widget 1: _______________
- [ ] Widget 2: _______________

```bash
touch lib/features/[feature_name]/widgets/[widget_name].dart
```

- [ ] Widgets extracted to `/widgets` subdirectory
- [ ] Widgets imported and used in screen

#### Step 7: Integration

**Repository Integration:**
- [ ] CRUD operations implemented
- [ ] Error handling added
- [ ] Loading states managed

**Notification Integration** (if applicable):
- [ ] Notifications scheduled after save
- [ ] Notifications canceled after delete

**Other Services:**
- [ ] Currency conversion (if needed)
- [ ] Template service (if needed)
- [ ] Other: _______________

---

### 5. UI States Checklist

- [ ] **Loading State** - Shows spinner while data loads
- [ ] **Empty State** - Friendly message when no data
- [ ] **Error State** - Clear error message with recovery option
- [ ] **Success State** - Data displays correctly
- [ ] **Pull-to-Refresh** - User can refresh data (if applicable)

---

### 6. Testing Checklist

#### Manual Testing
- [ ] Navigate to feature from existing screen
- [ ] Loading state displays correctly
- [ ] Empty state displays correctly (clear data first)
- [ ] Add/create data works
- [ ] Data displays correctly
- [ ] Edit/update data works
- [ ] Delete data works
- [ ] Pull-to-refresh works (if applicable)
- [ ] Error handling works (force error conditions)
- [ ] Back navigation works
- [ ] Close app and reopen - data persists

#### Device Testing
- [ ] Test on iOS Simulator
- [ ] Test on Android Emulator
- [ ] Test on real iOS device (if using native APIs)
- [ ] Test on real Android device (if using native APIs)

#### Edge Cases
- [ ] No internet connection (should still work - offline-first)
- [ ] Very long text inputs
- [ ] Maximum/minimum values
- [ ] Rapid button taps (loading state prevents duplicate actions)
- [ ] Device rotation (if applicable)

---

### 7. Code Quality Checklist

- [ ] **No hardcoded strings** - Use constants or localization
- [ ] **Proper error handling** - Try-catch where needed
- [ ] **Loading states** - User feedback during async operations
- [ ] **Null safety** - All nullable types properly handled
- [ ] **Code generation** - Run `dart run build_runner build` if needed
- [ ] **Comments** - Complex logic explained
- [ ] **Consistent styling** - Follows CustomSubs design system
- [ ] **Accessibility** - Semantic labels, sufficient contrast

---

### 8. Documentation Checklist

- [ ] **Inline comments** - Complex methods documented
- [ ] **Class-level docs** - Controller/service purpose explained
- [ ] **README updated** - If feature changes setup/usage
- [ ] **CLAUDE.md updated** - If feature changes architecture

---

### 9. Files Changed

**New Files:**
- `lib/features/[feature_name]/[feature_name]_screen.dart`
- `lib/features/[feature_name]/[feature_name]_controller.dart`
- `lib/features/[feature_name]/[feature_name]_controller.g.dart` (generated)
- `lib/features/[feature_name]/widgets/[widget].dart`

**Modified Files:**
- `lib/app/router.dart` (added route)
- `lib/features/[navigation_source]/[source]_screen.dart` (added navigation)
- [Other modified files]

---

### 10. Completion Checklist

- [ ] All acceptance criteria met
- [ ] All testing checklist items passed
- [ ] Code quality checklist complete
- [ ] No console errors or warnings
- [ ] Feature works on both iOS and Android
- [ ] Data persists across app restarts
- [ ] Pull request created (if using version control)
- [ ] Feature demonstrated to stakeholder

---

## Notes

[Any additional notes, gotchas, or decisions made during implementation]

---

## See Also

- `docs/guides/adding-a-feature.md` - Detailed implementation guide
- `docs/architecture/state-management.md` - Riverpod patterns
- `docs/templates/screen-with-controller.dart` - Full code example
- `docs/templates/form-screen.dart` - Form implementation example
