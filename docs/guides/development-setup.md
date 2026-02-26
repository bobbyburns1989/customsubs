# Development Setup Guide

**Status**: ✅ Complete
**Last Updated**: February 25, 2026
**Relevant to**: Developers, AI Coding Assistants

Quick guide to setting up your development environment for CustomSubs.

---

## Prerequisites

- **Flutter SDK**: 3.4.0 or higher
- **Dart SDK**: Included with Flutter
- **Xcode**: 15.0+ (for iOS development)
- **Android Studio**: Latest stable (for Android development)
- **CocoaPods**: Latest version (for iOS dependencies)

---

## Initial Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd customsubs
```

### 2. Install Dependencies

```bash
# Get Flutter packages
flutter pub get

# Generate code (Riverpod, Hive)
dart run build_runner build --delete-conflicting-outputs

# Install iOS pods
cd ios
pod install
cd ..
```

### 3. Run the App

```bash
# iOS Simulator
flutter run

# Android Emulator
flutter run

# Specific device
flutter run -d <device-id>
```

---

## Claude Code Configuration

CustomSubs uses **Claude Code CLI** for AI-assisted development. The project includes pre-configured permissions for common development tasks.

### Settings File Location

```
.claude/settings.local.json
```

### What's Configured

The settings file includes auto-approved permissions for:

- **Git operations**: `git add`, `git commit`, `git push`
- **Flutter commands**: `flutter pub`, `flutter clean`, `flutter build`
- **Build tools**: `dart run build_runner`
- **Utilities**: `ls`, `grep`, `pkill`, `open`
- **Web search**: Enabled for documentation lookups

### Important Notes

**DO NOT** hardcode specific commit messages in the settings file. Use generic patterns like:

```json
{
  "permissions": {
    "allow": [
      "Bash(git commit:*)"  // ✅ Correct - allows any commit
    ]
  }
}
```

**AVOID** this pattern:

```json
{
  "permissions": {
    "allow": [
      "Bash(git commit -m \"specific message...\")"  // ❌ Wrong - too specific
    ]
  }
}
```

### Claude Code Commands

```bash
# Start interactive session
claude

# Continue previous conversation
claude -c

# Resume specific session
claude -r <session-id>

# Check health
claude doctor

# Get help
claude --help
```

---

## Project Structure

```
lib/
├── app/              # App initialization, routing, theme
├── core/             # Shared utilities, widgets, constants
├── data/             # Models, repositories, services
└── features/         # Feature modules (home, analytics, etc.)

docs/
├── guides/           # Implementation guides (this file)
├── architecture/     # Technical documentation
├── completion/       # Feature completion reports
└── testing/          # Testing documentation
```

See [architecture/overview.md](../architecture/overview.md) for detailed architecture.

---

## Common Development Commands

### Code Generation

```bash
# Generate Riverpod providers and Hive adapters
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file changes)
dart run build_runner watch --delete-conflicting-outputs
```

### Code Quality

```bash
# Run static analysis
flutter analyze

# Format code
flutter format .

# Fix auto-fixable issues
dart fix --apply
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/path/to/test_file.dart

# Run with coverage
flutter test --coverage
```

### Build & Release

```bash
# Clean build artifacts
flutter clean

# Build iOS (no code signing)
flutter build ios --release --no-codesign

# Build Android APK
flutter build apk --release

# Build Android App Bundle
flutter build appbundle --release
```

---

## IDE Integration

### VS Code

**Recommended Extensions**:
- Flutter
- Dart
- Prettier - Code formatter
- Error Lens
- GitLens

### Android Studio / IntelliJ IDEA

**Recommended Plugins**:
- Flutter plugin
- Dart plugin

---

## Troubleshooting

### Build Runner Conflicts

```bash
# Delete generated files and regenerate
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### iOS Pod Issues

```bash
cd ios
pod deintegrate
pod install
cd ..
```

### Xcode Archive Failures

See [technical/BUILD_TROUBLESHOOTING.md](../technical/BUILD_TROUBLESHOOTING.md) for comprehensive solutions.

### Flutter Version Issues

```bash
# Check Flutter version
flutter --version

# Upgrade Flutter
flutter upgrade

# Clean after upgrade
flutter clean
flutter pub get
```

---

## Development Workflow

### Making Changes

1. **Create feature branch** (if using git flow)
2. **Read relevant guides** in `docs/guides/`
3. **Make code changes**
4. **Run `flutter analyze`** to check for errors
5. **Test on device/simulator**
6. **Commit with descriptive message**

### Using Claude Code

1. **Start session**: `claude`
2. **Request feature**: "Implement X following the patterns in CLAUDE.md"
3. **Review changes**: Claude will use Read, Edit, Write tools
4. **Test changes**: Verify on device
5. **Commit**: Claude can help write commit messages

### Pre-Commit Checklist

- [ ] `flutter analyze` shows no errors
- [ ] Code follows patterns in `docs/architecture/`
- [ ] Added tests if applicable
- [ ] Updated documentation if needed
- [ ] Tested on iOS and Android (if UI changes)

---

## Environment Variables

CustomSubs is **100% offline** and requires **no environment variables** for:
- API keys
- Cloud services
- External integrations

**RevenueCat** API key is hardcoded in:
- `lib/data/services/entitlement_service.dart`

For production, this should be moved to a secure configuration.

---

## Documentation

### For Developers

- **[CLAUDE.md](../../CLAUDE.md)** - Complete project specification
- **[QUICK-REFERENCE.md](../QUICK-REFERENCE.md)** - Cheat sheet
- **[adding-a-feature.md](adding-a-feature.md)** - Feature implementation guide
- **[working-with-notifications.md](working-with-notifications.md)** - Notification system (CRITICAL)

### For Architecture

- **[architecture/overview.md](../architecture/overview.md)** - System design
- **[architecture/state-management.md](../architecture/state-management.md)** - Riverpod patterns
- **[architecture/data-layer.md](../architecture/data-layer.md)** - Hive & repositories

### Quick Access

All documentation is indexed in **[docs/INDEX.md](../INDEX.md)**.

---

## Getting Help

### Documentation

1. Check **[docs/INDEX.md](../INDEX.md)** first
2. Read relevant guide in **docs/guides/**
3. Review architecture docs in **docs/architecture/**

### Common Issues

- **Build errors**: See [technical/BUILD_TROUBLESHOOTING.md](../technical/BUILD_TROUBLESHOOTING.md)
- **Notification issues**: See [guides/working-with-notifications.md](working-with-notifications.md)
- **State management**: See [architecture/state-management.md](../architecture/state-management.md)

### Claude Code Issues

```bash
# Check health
claude doctor

# View help
claude --help

# Debug mode
claude --debug
```

---

## Next Steps

Once you've set up your environment:

1. **Read [CLAUDE.md](../../CLAUDE.md)** - Complete project spec (15 min)
2. **Read [architecture/overview.md](../architecture/overview.md)** - System design (20 min)
3. **Read [adding-a-feature.md](adding-a-feature.md)** - Implementation patterns (15 min)
4. **Build the app** - Verify everything works
5. **Start coding** - Follow the patterns documented

---

## Quick Reference Card

```bash
# Setup
flutter pub get                    # Install dependencies
dart run build_runner build        # Generate code
cd ios && pod install && cd ..     # Install iOS pods

# Development
flutter run                        # Run app
flutter analyze                    # Check code quality
dart run build_runner watch        # Auto-generate code

# Claude Code
claude                             # Start session
claude -c                          # Continue previous
claude doctor                      # Health check

# Git
git add .                          # Stage changes
git commit -m "message"            # Commit
git push                           # Push to remote
```

---

**Pro Tip**: Keep [QUICK-REFERENCE.md](../QUICK-REFERENCE.md) open while developing - it contains all the patterns you'll need!

---

**Last Updated**: February 25, 2026
**Maintained By**: Development Team
**Questions**: Check [docs/INDEX.md](../INDEX.md) or relevant guides
