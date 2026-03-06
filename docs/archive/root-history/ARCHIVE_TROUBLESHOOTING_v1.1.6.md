# Archive Troubleshooting - Version 1.1.6

**Date:** February 22, 2026
**Issue:** Exit code -9 errors during Xcode archive
**Status:** ✅ Resolved with memory optimization

---

## 🔴 Problem Encountered

**Error Messages:**
1. "Dart snapshot generator failed with exit code -9"
2. "ShaderCompilerException: Shader compilation of ink_sparkle.frag failed with exit code -9"
3. "Failed to package /Users/bobbyburns/Projects/customsubs"

**Build Status:** Build Failed in Xcode

---

## 🔍 Root Cause Analysis

### **What is Exit Code -9?**

Exit code -9 = **Process killed by macOS** due to:
- Insufficient available RAM
- Process exceeding memory limits
- System memory pressure (yellow/red)

### **Why Does This Happen During Archive?**

**Release builds (archives) are MUCH more memory-intensive than debug builds:**

1. **GPU Shader Compilation:**
   - Flutter compiles Material shaders for GPU optimization
   - Shaders: `ink_sparkle.frag`, `ink_sparkle.vert`, etc.
   - This happens ONLY in release builds
   - Memory usage peaks at ~4GB during shader compilation

2. **Dart Snapshot Generation:**
   - Release mode creates optimized Dart snapshots
   - Requires significant memory for AOT compilation
   - Can spike to 2-3GB

3. **Total Memory Needed:**
   - Xcode: ~2GB base
   - Flutter build: ~4GB peak
   - macOS system: ~2GB
   - **Total: ~8GB minimum system RAM**
   - **Available free: ~4-5GB needed**

---

## ✅ Solution Applied

### **Step 1: Aggressive Clean**

```bash
# Close Xcode completely
killall Xcode

# Full Flutter clean
flutter clean

# Remove iOS build artifacts
rm -rf ios/build ios/Pods ios/.symlinks ios/Podfile.lock

# Remove Flutter build cache
rm -rf build .dart_tool

# Clear Xcode Derived Data
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Reinstall dependencies
flutter pub get
cd ios && pod install && cd ..

# Precache iOS artifacts (reduces memory pressure)
flutter precache --ios

# Reopen Xcode
open ios/Runner.xcworkspace
```

---

### **Step 2: Memory Optimization (CRITICAL)**

**Before archiving, free up RAM:**

1. **Close ALL web browsers:**
   - Chrome: ~2-4GB
   - Safari: ~1-2GB
   - Firefox: ~1-3GB
   - **Close ALL browser windows**

2. **Quit memory-intensive apps:**
   - Slack: ~500MB - 1GB
   - Discord: ~500MB
   - Microsoft Teams: ~1GB
   - Mail.app: ~500MB
   - Photos.app: ~1GB
   - VS Code: ~500MB - 1GB
   - Any other IDEs or dev tools

3. **Verify Memory Pressure:**
   - Open **Activity Monitor** (⌘ + Space → "Activity Monitor")
   - Click **Memory** tab
   - Look at **Memory Pressure** graph (bottom right)
   - **MUST be GREEN** (not yellow or red)
   - If yellow/red: Close more apps

4. **Check Free RAM:**
   - In Activity Monitor → Memory tab
   - Look at **Physical Memory** section
   - **Free RAM should be 4-5GB or more**
   - If less: Restart computer and try again

---

### **Step 3: Archive with Optimized Settings**

1. Select: **"Any iOS Device (arm64)"** (NOT simulator)
2. Menu: **Product → Clean Build Folder** (⌘⇧K)
3. Menu: **Product → Archive**
4. **Do NOT touch computer** during archive
5. Wait 3-5 minutes
6. Success: "Archive succeeded" message

---

## 🎯 Alternative Method (If Still Failing)

**Command-Line Build (More Memory Efficient):**

```bash
# Close Xcode first
flutter build ios --release --no-codesign
```

This builds in the background with better memory management. Then:

1. Open Xcode workspace
2. Select "Any iOS Device (arm64)"
3. Product → Archive
4. Will complete MUCH faster (~30 seconds) since build is done

---

## ⚠️ Package Config Error (New)

**Error Message in Xcode:**
```
/Users/bobbyburns/Projects/customsubs/.dart_tool/package_config.json does not exist.
```

### Root Cause

Xcode needs Flutter-generated files before it can build/archive. If you open Xcode directly without running Flutter commands first, these files won't exist.

### Solution

**Before opening Xcode, always run:**

```bash
# Generate Flutter build files
flutter clean
flutter pub get

# Build iOS to generate all necessary files
flutter build ios --release --no-codesign
```

**Then open Xcode:**

```bash
open ios/Runner.xcworkspace
```

Now in Xcode:
1. Product → Clean Build Folder (⌘⇧K)
2. Select "Any iOS Device (arm64)"
3. Product → Archive

The archive will complete much faster since Flutter already built everything.

---

## 📊 Verification Steps

**After clean and before archive:**

1. ✅ Xcode Derived Data cleared
2. ✅ Flutter build and .dart_tool removed
3. ✅ iOS Pods and build folders removed
4. ✅ Dependencies reinstalled fresh
5. ✅ iOS artifacts precached
6. ✅ Memory Pressure is GREEN
7. ✅ Free RAM is 4-5GB+
8. ✅ All browsers closed
9. ✅ Heavy apps quit

---

## 🔄 What We Learned

### **Debug vs Release Builds:**

| Aspect | Debug Build | Release Build (Archive) |
|--------|-------------|------------------------|
| Shader compilation | ❌ Skipped | ✅ Full GPU optimization |
| Dart compilation | Interpreted | AOT compiled |
| Memory usage | ~2GB | ~4GB peak |
| Build time | 1-2 min | 3-5 min |
| Sensitivity to RAM | Low | **HIGH** |

### **Critical Insights:**

1. **Exit code -9 is ALWAYS a memory issue** - Either:
   - Insufficient free RAM
   - Process killed by macOS
   - Memory pressure yellow/red

2. **Browsers are the #1 memory hog:**
   - Chrome with 10+ tabs: 4-6GB
   - Safari with many tabs: 2-3GB
   - **ALWAYS close all browsers before archiving**

3. **Precaching helps:**
   - `flutter precache --ios` downloads artifacts ahead of time
   - Reduces peak memory during build
   - Recommended before all release builds

4. **Xcode Archive > CLI for final build:**
   - Xcode handles code signing automatically
   - Better integration with Organizer
   - But if memory issues persist, build with CLI first

---

## 📋 Quick Reference Checklist

**Before Every Archive:**

- [ ] Close ALL web browsers (Chrome, Safari, Firefox, etc.)
- [ ] Quit Slack, Discord, Teams
- [ ] Quit Mail, Photos, large apps
- [ ] Open Activity Monitor
- [ ] Verify Memory Pressure is **GREEN**
- [ ] Verify free RAM is **4-5GB+**
- [ ] Select "Any iOS Device (arm64)" in Xcode
- [ ] Product → Clean Build Folder
- [ ] Product → Archive
- [ ] Don't touch computer for 3-5 minutes

**If Archive Fails:**

- [ ] Check error message for "exit code -9"
- [ ] If -9: Close MORE apps
- [ ] Restart computer to free all RAM
- [ ] Run aggressive clean (commands above)
- [ ] Try archive again
- [ ] If still fails: Use command-line build method

---

## 🎉 Success Indicators

**You'll know the archive succeeded when:**

1. ✅ No red error messages in Xcode
2. ✅ "Archive succeeded" notification appears
3. ✅ Organizer window opens automatically
4. ✅ Build 21 appears in Archives list
5. ✅ Archive shows today's date and time

**Then you can:**

1. Click "Distribute App"
2. Select "App Store Connect"
3. Upload to TestFlight

---

## 📝 Documentation Updated

**Files modified to include this info:**

1. ✅ `READY_TO_ARCHIVE_v1.1.6.md` - Added memory optimization section
2. ✅ `CHANGELOG.md` - Documented archive issues and solutions
3. ✅ `ARCHIVE_TROUBLESHOOTING_v1.1.6.md` (this file) - Complete guide

---

## 💡 Prevention for Future Releases

**Before starting any release build:**

1. **Check system RAM:** 16GB recommended minimum for Flutter development
2. **Close browsers first:** Make it a habit
3. **Run precache:** `flutter precache --ios` before archiving
4. **Monitor memory:** Keep Activity Monitor open during build
5. **Don't multitask:** Let the archive run without other work

**If you regularly encounter memory issues:**
- Consider upgrading to 32GB RAM
- Or use command-line builds exclusively
- Or build on a separate machine with more RAM

---

**Last Updated:** February 22, 2026
**Status:** ✅ Archive successful after memory optimization
**Build:** 21 (1.1.6)
**Next Step:** Upload to TestFlight
