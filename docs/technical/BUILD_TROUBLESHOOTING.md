# Build Troubleshooting Guide

**Last Updated:** 2026-02-22
**Status:** ✅ Complete
**Relevant to:** Developers, CI/CD

This guide covers common build errors and their solutions for the CustomSubs Flutter iOS project.

---

## Table of Contents

1. [Exit Code -9 Errors](#exit-code--9-errors)
2. [Dart Snapshot Generator Failed](#dart-snapshot-generator-failed)
3. [Shader Compilation Failed](#shader-compilation-failed)
4. [Pod Install Issues](#pod-install-issues)
5. [Prevention Best Practices](#prevention-best-practices)

---

## Exit Code -9 Errors

### What It Means

**Exit code -9** indicates the build process was **killed by the operating system**, typically due to:
- Memory pressure (system ran out of RAM)
- Corrupted build cache
- Process timeout

### Common Scenarios

1. **Dart snapshot generator failed with exit code -9**
2. **Shader compilation failed with exit code -9**
3. **Pod installation failed with exit code -9**

---

## Dart Snapshot Generator Failed

### Error Message

```
Runner
Target release_ios_bundle_flutter_assets failed:
Dart snapshot generator failed with exit code -9
```

### Root Causes

1. **Stale build cache** - Multiple version bumps without cleaning
2. **Pod cache mismatch** - pubspec.yaml changes not reflected in Pods
3. **Corrupted Xcode Derived Data** - Incomplete builds

### Solution (Complete Clean)

```bash
# Navigate to project root
cd /Users/bobbyburns/Projects/customsubs

# Clean Flutter build cache
flutter clean

# Remove iOS build artifacts
rm -rf ios/build
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec

# Clean Xcode Derived Data
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Reinstall dependencies
flutter pub get

# Reinstall CocoaPods
cd ios
pod deintegrate
pod install
cd ..

# Regenerate code (Riverpod + Hive)
dart run build_runner build --delete-conflicting-outputs

# Optional: Precache iOS artifacts
flutter precache --ios
```

### Verification

```bash
# Test with debug build first (faster, less memory)
flutter build ios --debug --no-codesign
```

**Expected Output:**
```
✓ Built build/ios/iphoneos/Runner.app
```

**Time:** ~60-90 seconds for debug build

---

## Shader Compilation Failed

### Error Message

```
ShaderCompilerException: Shader compilation of
"/Users/bobbyburns/Documents/flutter/packages/flutter/lib/src/material/shaders/ink_sparkle.frag"
to "/path/to/flutter_assets/shaders/ink_sparkle.frag"
failed with exit code -9
```

### Root Causes

1. **Memory pressure** - Release builds compile Material shaders for GPU optimization
2. **Insufficient RAM** - Other apps consuming memory during build
3. **Corrupted shader cache** - Previous failed builds left incomplete cache

### Solution (Memory Optimization)

**Step 1: Free Up RAM**
- Close memory-intensive apps:
  - Browsers (Safari, Chrome)
  - Communication apps (Slack, Teams)
  - Other Xcode projects
- Keep only Xcode open

**Step 2: Clean Derived Data**
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

**Step 3: Precache Shaders**
```bash
flutter precache --ios
```

**Step 4: Archive in Xcode (Better Memory Management)**
1. Open project: `open ios/Runner.xcworkspace`
2. Wait for indexing to complete
3. Select target: "Any iOS Device (arm64)"
4. Clean: Product → Clean Build Folder (⌘⇧K)
5. Archive: Product → Archive
6. Wait 3-5 minutes

### Alternative: Build with Optimization Flags

If Xcode Archive still fails:

```bash
# Reduce memory usage with split debug info
flutter build ios --release --split-debug-info=build/debug-info --obfuscate
```

Then in Xcode:
- Product → Archive (will use pre-built release)

### Verification

```bash
# Debug build should always work (no shader compilation)
flutter build ios --debug --no-codesign
```

**Expected:** ✅ Success in ~60-90 seconds

**If debug succeeds but release fails:** Memory pressure is the issue

---

## Pod Install Issues

### Error Message

```
[!] Invalid `Podfile` file:
/Users/bobbyburns/Projects/customsubs/ios/Flutter/Generated.xcconfig must exist.
```

### Root Cause

CocoaPods requires Flutter-generated files that are created during `flutter pub get`.

### Solution

**Always run in this order:**

```bash
# 1. Get Flutter dependencies FIRST
flutter pub get

# 2. THEN install pods
cd ios
pod install
cd ..
```

### Common Mistake

```bash
# ❌ WRONG ORDER - Will fail
cd ios
pod install  # Fails - no Generated.xcconfig yet

# ✅ CORRECT ORDER
flutter pub get  # Generates Flutter config
cd ios
pod install     # Now works
```

---

## Prevention Best Practices

### Before Every Archive

1. **Version Bump Check:**
   ```bash
   # If you bumped version in pubspec.yaml, run:
   flutter clean
   flutter pub get
   cd ios && pod install
   ```

2. **Periodic Derived Data Cleanup:**
   ```bash
   # Once a week or before important builds:
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```

3. **Memory Management:**
   - Close unused apps before archiving
   - Monitor Activity Monitor during builds
   - Ensure 4GB+ free RAM available

### After Dependency Changes

If you modified `pubspec.yaml`:

```bash
flutter clean
flutter pub get
cd ios && pod install
dart run build_runner build --delete-conflicting-outputs
```

### Build Order Recommendation

For cleanest builds:

```bash
# 1. Clean everything
flutter clean
rm -rf ios/Pods ios/build

# 2. Dependencies
flutter pub get
cd ios && pod install && cd ..

# 3. Code generation
dart run build_runner build --delete-conflicting-outputs

# 4. Verify with debug
flutter build ios --debug --no-codesign

# 5. Archive in Xcode
open ios/Runner.xcworkspace
```

---

## Quick Reference

### Exit Code -9 Checklist

When you see exit code -9:

- [ ] Close memory-intensive apps
- [ ] Run `flutter clean`
- [ ] Delete `~/Library/Developer/Xcode/DerivedData/*`
- [ ] Run `flutter pub get`
- [ ] Run `cd ios && pod install`
- [ ] Try debug build first
- [ ] If debug works, archive in Xcode (not CLI)

### Estimated Times

| Operation | Time |
|-----------|------|
| `flutter clean` | 2-3 seconds |
| `flutter pub get` | 5-10 seconds |
| `pod install` | 10-20 seconds |
| `build_runner` | 60-90 seconds |
| Debug build | 60-90 seconds |
| Archive build | 3-5 minutes |

### Success Indicators

**Debug Build Success:**
```
✓ Built build/ios/iphoneos/Runner.app
```

**Archive Success:**
- Xcode Organizer opens
- Archive appears in list
- "Distribute App" button enabled

---

## Common Error Patterns

### Pattern 1: After Version Bump

**Symptom:** Build fails after changing version in pubspec.yaml

**Cause:** Cached build artifacts reference old version

**Fix:** Full clean + rebuild

---

### Pattern 2: After Adding Dependency

**Symptom:** Build fails after adding package to pubspec.yaml

**Cause:** Pods or generated code not updated

**Fix:**
```bash
flutter pub get
cd ios && pod install
dart run build_runner build --delete-conflicting-outputs
```

---

### Pattern 3: After Git Pull

**Symptom:** Build fails after pulling latest code

**Cause:** Other developer's pod/build changes not synced

**Fix:**
```bash
flutter clean
flutter pub get
cd ios && pod install
```

---

## Debugging Tools

### Check Available Memory

```bash
# Before archiving, check free memory:
vm_stat | grep "Pages free"
```

Ideal: 500,000+ pages free (~2GB+)

### Monitor Build Process

```bash
# Watch memory usage during build:
top -o mem
```

Look for processes using >1GB RAM

### Validate Pods

```bash
cd ios
pod update
pod install --repo-update
```

---

## Emergency Recovery

If nothing works:

### Nuclear Option (Full Reset)

```bash
# 1. Delete everything
flutter clean
rm -rf ios/build ios/Pods ios/.symlinks
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf .dart_tool

# 2. Reinstall Flutter
flutter doctor
flutter upgrade

# 3. Rebuild from scratch
flutter pub get
cd ios && pod install && cd ..
dart run build_runner build --delete-conflicting-outputs

# 4. Verify
flutter build ios --debug --no-codesign
```

### Last Resort: Different Machine

If local machine consistently fails:
- Try archiving on different Mac (if available)
- Use cloud CI/CD (Codemagic, GitHub Actions)
- Check for macOS system issues (disk space, permissions)

---

## Success Stories

### v1.1.5 Build Resolution

**Date:** 2026-02-22

**Errors Encountered:**
1. Dart snapshot generator failed (exit code -9)
2. Shader compilation failed (exit code -9)

**Solution Applied:**
- Complete clean (Flutter + Xcode + Pods)
- Memory optimization (closed other apps)
- Xcode Archive instead of CLI

**Result:**
- Debug build: ✅ 66.5 seconds
- Archive build: ✅ 3-5 minutes
- Upload to TestFlight: ✅ Success

**Documented In:**
- `RELEASE_READY_v1.1.5.md`
- `CHANGELOG.md` v1.1.5 entry

---

## Additional Resources

### Flutter Documentation
- [Building iOS Apps](https://docs.flutter.dev/deployment/ios)
- [iOS Build Modes](https://docs.flutter.dev/testing/build-modes)

### Xcode Resources
- [Xcode Build System Guide](https://developer.apple.com/documentation/xcode)
- [Managing Derived Data](https://developer.apple.com/documentation/xcode/customizing-the-build-schemes-for-a-project)

### Project Documentation
- [CLAUDE.md](../../CLAUDE.md) - Project specification
- [CHANGELOG.md](../../CHANGELOG.md) - Version history
- [Build release instructions](../../prepare_release.sh)

---

**Maintained By:** Development Team
**Last Build Success:** v1.1.5 Build 20 (2026-02-22)
**Status:** Production-ready build process ✅
