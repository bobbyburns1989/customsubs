# Xcode Universal App Setup Instructions

**CRITICAL:** You must manually enable Universal App support (iPhone + iPad) in Xcode before archiving.

---

## ⚠️ Why This Is Required

Apple rejected the app because it was configured as **iPhone-only** (`TARGETED_DEVICE_FAMILY = 1`). The iPad Air runs it in compatibility mode, which causes StoreKit purchase failures in sandbox.

**Fix:** Change to **Universal** (`TARGETED_DEVICE_FAMILY = "1,2"`) to natively support both iPhone and iPad.

---

## 📋 Step-by-Step Instructions

### 1. Open Xcode Workspace

```bash
open ios/Runner.xcworkspace
```

**IMPORTANT:** Open the `.xcworkspace` file, NOT `.xcodeproj`

---

### 2. Select Runner Target

1. In the left sidebar (Project Navigator), click on **"Runner"** (the blue app icon at the top)
2. In the main editor area, under **TARGETS**, select **"Runner"**

You should now see several tabs: General, Signing & Capabilities, Resource Tags, Info, Build Settings, Build Phases, Build Rules

---

### 3. Go to General Tab

Click on the **"General"** tab (should be selected by default)

---

### 4. Change Device Support to Universal

Look for the **"Deployment Info"** section (usually near the top).

Find the **"Devices"** dropdown. It currently says: **"iPhone"**

**Change it to:** **"Universal"**

This single change will automatically update `TARGETED_DEVICE_FAMILY` from `1` to `"1,2"` in the project file.

---

### 5. Verify the Change

You should see:
- **Devices:** Universal ✅
- **Deployment Target:** iOS 12.0 (unchanged)
- **Supports multiple windows:** Unchecked (leave as is)

---

### 6. Clean Build Folder

**Menu:** Product → Clean Build Folder (⌘⇧K)

Wait for "Clean Finished" message in Xcode.

---

### 7. Close Xcode

Close Xcode completely. You're done with the manual step!

---

## ✅ Verification

After archiving and uploading to App Store Connect:

1. Go to **App Store Connect** → Your App → **TestFlight**
2. Select the new build (Build 27)
3. Under **"Build Information"** → **"Supported Devices"**
4. **✅ MUST SHOW:** "iPhone, iPad"
5. **❌ If it shows:** "iPhone" only → The setting didn't apply, repeat steps above

---

## 🔄 Next Steps

After completing this manual Xcode change:

1. Return to the terminal
2. Run the build commands:

```bash
# Generate Flutter build files
flutter clean
flutter pub get
flutter build ios --release --no-codesign

# Open Xcode (optional - you already have it open)
# Just go back to Xcode and archive
```

3. In Xcode: Product → Archive (⌘⇧B)
4. Wait for archive to complete (~3-5 minutes)
5. Distribute to App Store Connect

---

## 📸 Visual Guide

**Before (iPhone Only):**
```
Deployment Info
  ├─ iPhone    ← WRONG
  └─ iOS 12.0
```

**After (Universal):**
```
Deployment Info
  ├─ Universal ← CORRECT
  └─ iOS 12.0
```

---

## ❓ Troubleshooting

### "I don't see the Devices dropdown"
- Make sure you're in the **General** tab
- Make sure you selected **Runner** under TARGETS (not Runner under PROJECTS)
- Try closing and reopening Xcode

### "Archive fails after this change"
- Clean Build Folder (⌘⇧K)
- Close Xcode
- Run `flutter clean && flutter pub get && flutter build ios --release --no-codesign`
- Reopen Xcode and try archive again

### "App Store Connect still shows iPhone only"
- The change didn't save in Xcode
- Verify `ios/Runner.xcodeproj/project.pbxproj` contains `TARGETED_DEVICE_FAMILY = "1,2";` (you can search this file)
- If it still shows `1`, repeat the steps above and ensure you save the project

---

**Status:** ⚠️ USER ACTION REQUIRED
**Time Required:** 2 minutes
**Difficulty:** Easy (just change one dropdown)
