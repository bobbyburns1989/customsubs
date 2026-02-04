# Contributing to CustomSubs

Thank you for your interest in contributing to CustomSubs! This document provides guidelines and instructions for contributing to the project.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Project Architecture](#project-architecture)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)

## Code of Conduct

This project follows a simple code of conduct:
- Be respectful and constructive
- Focus on the technical merit of ideas
- Help maintain a welcoming environment
- Respect privacy-first principles

## Getting Started

### Prerequisites
- Flutter SDK 3.24.0+
- Dart SDK 3.5.0+
- Git
- Code editor (VS Code, Android Studio, or IntelliJ recommended)

### Initial Setup

1. **Fork and clone the repository**
   ```bash
   git clone <your-fork-url>
   cd customsubs
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate required code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Verify everything works**
   - App launches successfully
   - No console errors
   - Onboarding flow displays correctly

## Development Workflow

### Branch Strategy

- `main` - Stable releases only
- `develop` - Main development branch
- `feature/*` - New features
- `fix/*` - Bug fixes
- `docs/*` - Documentation updates

### Creating a Feature Branch

```bash
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
```

### Development Cycle

1. **Make changes** in your feature branch
2. **Test thoroughly** (see Testing Guidelines)
3. **Run code generation** if you modified models/providers:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. **Format code**:
   ```bash
   dart format lib/
   ```
5. **Analyze code**:
   ```bash
   flutter analyze
   ```
6. **Commit changes** with clear messages:
   ```bash
   git add .
   git commit -m "feat: add currency picker screen"
   ```

### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>: <description>

[optional body]

[optional footer]
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks (dependencies, build config)

**Examples**:
```bash
feat: add subscription detail screen
fix: resolve notification cancellation issue
docs: update README with new screenshots
refactor: extract color picker to widget
test: add unit tests for CurrencyUtils
```

## Coding Standards

### Dart Style Guide

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

- Use `lowerCamelCase` for variables, methods, parameters
- Use `UpperCamelCase` for classes, enums, typedefs
- Use `lowercase_with_underscores` for file names
- Prefer `final` over `var` when possible
- Always specify types for public APIs

### Project-Specific Conventions

#### File Organization

```dart
// 1. Imports (Dart SDK first, then packages, then local)
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:custom_subs/data/models/subscription.dart';

// 2. Part directive (if using code generation)
part 'example_screen.g.dart';

// 3. Constants (if any)
const _kDefaultPadding = 16.0;

// 4. Main class/widget
class ExampleScreen extends ConsumerWidget {
  // ...
}

// 5. Helper classes/functions (if small and related)
```

#### Widget Structure

```dart
class MyWidget extends ConsumerWidget {
  // 1. Constructor with named parameters
  const MyWidget({
    super.key,
    required this.title,
    this.onTap,
  });

  // 2. Fields
  final String title;
  final VoidCallback? onTap;

  // 3. Build method
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ...
  }

  // 4. Private helper methods
  void _handleTap() {
    // ...
  }
}
```

#### Riverpod Providers

```dart
// Use @riverpod annotation (code generation)
@riverpod
class MyController extends _$MyController {
  @override
  Future<MyData> build() async {
    // Initialize state
  }

  Future<void> doSomething() async {
    // Mutate state
  }
}
```

#### Error Handling

```dart
// Use try-catch for async operations
Future<void> saveData() async {
  try {
    await repository.save(data);
  } catch (e) {
    debugPrint('Failed to save: $e');
    rethrow; // Let caller handle if needed
  }
}
```

### Code Documentation

**When to document**:
- All public APIs (classes, methods, properties)
- Complex business logic
- Non-obvious code patterns
- Architecture decisions

**When NOT to document**:
- Obvious getters/setters
- Simple private methods
- Self-explanatory code

**Format**:
```dart
/// A service that manages subscription notifications.
///
/// Uses deterministic ID generation to ensure notifications can be
/// reliably canceled even after app restart.
///
/// Example:
/// ```dart
/// await notificationService.scheduleNotificationsForSubscription(sub);
/// ```
class NotificationService {
  /// Schedules all reminders for the given [subscription].
  ///
  /// This includes:
  /// - First reminder (e.g., 7 days before)
  /// - Second reminder (e.g., 1 day before)
  /// - Billing day reminder
  ///
  /// Throws [PlatformException] if notification permissions are denied.
  Future<void> scheduleNotificationsForSubscription(Subscription subscription) async {
    // ...
  }
}
```

## Project Architecture

### Feature-First Structure

Place all feature-related files together:

```
lib/features/my_feature/
├── my_feature_screen.dart        # Main screen
├── my_feature_controller.dart    # Riverpod controller
└── widgets/                      # Feature-specific widgets
    ├── custom_widget_1.dart
    └── custom_widget_2.dart
```

### Naming Conventions

**Files**:
- Screens: `*_screen.dart` (e.g., `home_screen.dart`)
- Controllers: `*_controller.dart` (e.g., `home_controller.dart`)
- Models: `*.dart` (e.g., `subscription.dart`)
- Widgets: `*_widget.dart` or descriptive name (e.g., `color_picker_widget.dart`)

**Classes**:
- Screens: `*Screen` (e.g., `HomeScreen`)
- Controllers: `*Controller` (e.g., `HomeController`)
- Widgets: Descriptive name (e.g., `ColorPickerWidget`, `SubscriptionTile`)

### State Management Rules

1. **Use Riverpod for all state**
2. **Controllers manage feature state**
3. **Services contain reusable business logic**
4. **Repositories handle data access**
5. **Never call repository directly from UI** - always go through controller

### Data Flow

```
UI Event → Controller Method → Repository/Service → Update State → UI Rebuild
```

## Testing Guidelines

### Test Coverage Goals

- **Unit Tests**: Business logic, utilities, extensions (aim for 80%+)
- **Widget Tests**: Complex widgets, screens (aim for 60%+)
- **Integration Tests**: Critical user flows (key scenarios)

### Running Tests

```bash
# All tests
flutter test

# Specific file
flutter test test/core/utils/currency_utils_test.dart

# With coverage
flutter test --coverage
```

### Writing Tests

#### Unit Test Example

```dart
// test/core/utils/currency_utils_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';

void main() {
  group('CurrencyUtils', () {
    test('formats USD correctly', () {
      expect(CurrencyUtils.format(19.99, 'USD'), '\$19.99');
    });

    test('converts EUR to USD', () {
      final result = CurrencyUtils.convert(100, 'EUR', 'USD');
      expect(result, isA<double>());
      expect(result, greaterThan(0));
    });
  });
}
```

#### Widget Test Example

```dart
// test/features/add_subscription/widgets/color_picker_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_subs/features/add_subscription/widgets/color_picker_widget.dart';

void main() {
  testWidgets('ColorPickerWidget shows selected color', (tester) async {
    Color? selectedColor;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ColorPickerWidget(
            selectedColor: Colors.red,
            onColorSelected: (color) => selectedColor = color,
          ),
        ),
      ),
    );

    // Verify selected color shows checkmark
    expect(find.byIcon(Icons.check), findsOneWidget);

    // Tap a different color
    await tester.tap(find.byType(GestureDetector).at(1));
    await tester.pump();

    expect(selectedColor, isNotNull);
  });
}
```

### Test Requirements

Before submitting a PR:
- [ ] All existing tests pass
- [ ] New features have unit tests
- [ ] Complex widgets have widget tests
- [ ] Critical flows have integration tests (if applicable)
- [ ] `flutter analyze` passes with no errors

## Pull Request Process

### Before Submitting

1. **Update from develop**:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout your-feature-branch
   git merge develop
   ```

2. **Run all checks**:
   ```bash
   flutter analyze
   dart format --set-exit-if-changed lib/
   flutter test
   ```

3. **Test on device**:
   - Run on iOS simulator/device
   - Run on Android emulator/device
   - Verify your changes work as expected

4. **Update documentation**:
   - Update README.md if adding new features
   - Update ARCHITECTURE.md if changing structure
   - Add/update code comments
   - Update CHANGELOG.md

### PR Template

When creating a PR, include:

```markdown
## Description
Brief description of what this PR does.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Tested on iOS
- [ ] Tested on Android
- [ ] Manual testing completed

## Screenshots (if applicable)
[Add screenshots showing UI changes]

## Checklist
- [ ] Code follows project style guidelines
- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] No console warnings/errors
```

### Review Process

1. Maintainer reviews code
2. Feedback provided (if needed)
3. Make requested changes
4. Re-review
5. Approval + merge to develop

## Issue Reporting

### Bug Reports

Include:
- **Description**: Clear description of the bug
- **Steps to Reproduce**: Numbered list
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Screenshots**: If applicable
- **Environment**:
  - Flutter version (`flutter --version`)
  - Device/emulator
  - OS version

### Feature Requests

Include:
- **Use Case**: Why is this feature needed?
- **Proposed Solution**: How should it work?
- **Alternatives**: Other approaches considered
- **Privacy Impact**: Does it affect privacy principles?

### Security Issues

**DO NOT** open public issues for security vulnerabilities. Instead, email [security contact] with:
- Description of vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

## Development Tips

### Hot Reload Best Practices

- Use `r` for hot reload (preserves state)
- Use `R` for hot restart (resets state)
- Hot reload doesn't work for:
  - Const constructor changes
  - Enum changes
  - Initialization code

### Code Generation

- Run in watch mode during development:
  ```bash
  dart run build_runner watch
  ```
- Commit generated files (*.g.dart) to git

### Debugging

- Use `debugPrint()` instead of `print()`
- Use Flutter DevTools for profiling
- Use `flutter logs` for device logs

### Common Issues

**"Provider not found"**:
- Ensure ProviderScope wraps app
- Check provider is defined and generated

**"Box not initialized"**:
- Ensure `Hive.initFlutter()` called
- Check box is opened before access

**"Build runner conflicts"**:
- Use `--delete-conflicting-outputs` flag

## Questions?

If you have questions about contributing:
1. Check existing documentation (README, ARCHITECTURE, CLAUDE.md)
2. Search closed issues
3. Open a new issue with "question" label

---

**Thank you for contributing to CustomSubs!** 🎉

Your efforts help make subscription tracking more private and accessible for everyone.
