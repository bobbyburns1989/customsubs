# App Store Configuration Guide

**Status**: ✅ Complete
**Last Updated**: February 26, 2026
**Relevant to**: Developers

---

## ✅ Completed Configuration

### 1. Info.plist - Notification Permission ✅

**File:** `ios/Runner/Info.plist`
**Added:** Notification permission description (required by App Store)

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>CustomSubs needs notification permission to remind you before subscription charges. All reminders are local - no data leaves your device.</string>
```

**Why:** Apple requires a clear explanation of why your app requests notification permission. This description appears when the user is prompted to allow notifications during onboarding.

---

### 2. Privacy Manifest ✅

**File:** `ios/Runner/PrivacyInfo.xcprivacy`
**Created:** Complete privacy manifest (required for 2024+ apps)

**What it declares:**
- ✅ No tracking (`NSPrivacyTracking: false`)
- ✅ No data collection (`NSPrivacyCollectedDataTypes: []`)
- ✅ API usage transparency:
  - System Boot Time (for notification scheduling)
  - File Timestamp (for Hive database)
  - User Defaults (for app settings)

**Why:** Apple's App Privacy Details require apps to declare all data practices. Since CustomSubs is 100% offline and collects NO data, this manifest proves privacy compliance.

---

## 🎯 Required Next Steps in Xcode

### Enable Time Sensitive Notifications (Recommended)

**What it does:**
Ensures billing reminders break through Focus modes and Do Not Disturb. Critical for time-sensitive financial notifications.

**How to enable:**

1. **Open Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Select the Runner target:**
   - Click `Runner` in the left sidebar (blue app icon)
   - Select the `Runner` target under TARGETS

3. **Go to Signing & Capabilities tab:**
   - Click the "Signing & Capabilities" tab at the top

4. **Add the capability:**
   - Click `+ Capability` button (top left)
   - Search for "Time Sensitive Notifications"
   - Click to add it

5. **Save:**
   - The capability is now enabled
   - Xcode will automatically update your entitlements file

**Justification for Apple Review:**
"Subscription billing notifications are time-sensitive financial reminders that users depend on to avoid unwanted charges. Users set these reminders intentionally and expect them to deliver reliably, even during Focus modes."

---

## 📋 Capabilities Summary

### ✅ Required Capabilities: ZERO

CustomSubs requires **no special capabilities** from the standard list because:
- Uses **local notifications** (not push notifications)
- No cloud services (no iCloud capability needed)
- No network access (offline-only)
- No special hardware (camera, location, etc.)

### ⭐ Recommended (Optional):
- **Time Sensitive Notifications** - For reliable billing reminders

### ❌ NOT Needed:
- Push Notifications (we use local notifications)
- iCloud (using local Hive storage + manual export)
- Background Modes (not required for local notifications)
- Network capabilities (app is 100% offline)

---

## 🔐 Privacy & Security Highlights

### Privacy-First Architecture

CustomSubs can claim these privacy advantages:

1. **No Data Collection**
   - Zero analytics
   - Zero tracking
   - Zero telemetry
   - Zero cloud storage

2. **100% Offline**
   - No network calls
   - No server communication
   - All data stored locally (Hive)
   - No login required

3. **User Control**
   - Users can export/import their own data (JSON)
   - Data stays on device
   - Delete data = truly deleted (no cloud copies)

4. **Transparent**
   - Privacy manifest declares all API usage
   - Open source code (if applicable)
   - Clear permission descriptions

---

## 📱 App Store Connect Configuration

When you submit to App Store Connect, you'll declare:

### App Privacy Questionnaire

**Data Collection:** NO
**Data Used to Track You:** NO
**Data Linked to You:** NO
**Data Not Linked to You:** NO

**Explanation:**
"CustomSubs is a privacy-first app that stores all data locally on the user's device. We do not collect, transmit, or store any user data on our servers. The app operates 100% offline and uses only local notifications."

### Age Rating

**Recommended:** 4+ (No objectionable content)

### Category

**Primary:** Finance
**Secondary:** Productivity (optional)

### Keywords (Max 100 chars)

```
subscription,tracker,reminder,billing,budget,expense,privacy,offline,cancel,trial
```

### Description Highlights

Emphasize in your App Store description:
- "Privacy-first: All data stays on your device"
- "100% offline - no account required"
- "No tracking, no analytics, no cloud sync"
- "Export your data anytime as JSON"

---

## 🧪 Testing Before Submission

### Critical Tests

Before submitting to App Store, test these flows:

1. **Fresh Install → Notification Permission:**
   - Delete app completely
   - Reinstall
   - Go through onboarding
   - Verify notification permission prompt shows with correct description
   - Grant permission
   - Create a test subscription with notification in 5 minutes
   - Verify notification fires

2. **Privacy Manifest Validation:**
   ```bash
   # Validate privacy manifest format
   plutil -lint ios/Runner/PrivacyInfo.xcprivacy
   ```

3. **App Store Validation:**
   ```bash
   # Build archive and validate before upload
   flutter build ios --release
   # Then in Xcode: Product → Archive → Validate App
   ```

---

## 🚀 Submission Checklist

Before uploading to App Store Connect:

### Code
- [ ] All deprecation warnings fixed
- [ ] `flutter analyze` shows 0 errors
- [ ] Privacy manifest in place
- [ ] Notification permission description added
- [ ] Time Sensitive Notifications enabled (optional)

### Assets
- [ ] App icon 1024x1024 PNG
- [ ] Screenshots (6.7", 6.5", 5.5" iPhone)
- [ ] App Store preview video (optional)

### Marketing
- [ ] App name: "CustomSubs"
- [ ] Subtitle (max 30 chars): "Privacy-First Sub Tracker"
- [ ] Description (max 4000 chars)
- [ ] Keywords (max 100 chars)
- [ ] Promotional text (max 170 chars)
- [ ] Privacy Policy URL (required)
- [ ] Support URL

### Legal
- [ ] Privacy policy published and accessible
- [ ] Terms of service (optional for free apps)
- [ ] Copyright notice

### Testing
- [ ] Tested on iPhone (physical device)
- [ ] Notifications work reliably
- [ ] All features working in release build
- [ ] No crashes in Xcode Organizer

---

## 📝 Notes for App Review

### Demonstration Account

**Not needed** - app has no login system.

### Review Notes

Consider adding this note for reviewers:

```
CustomSubs is a privacy-first subscription tracker that operates 100% offline.

No account/login required - tap "Get Started" on onboarding and start adding subscriptions immediately.

To test notifications:
1. Grant notification permission during onboarding
2. Add a subscription (tap + button)
3. Use template (e.g., Netflix) or create custom
4. Set billing date to tomorrow
5. Check iOS Settings → Notifications to verify scheduled reminders

All data is stored locally using Hive. No network calls are made.

Time Sensitive Notifications (if enabled): Billing reminders are time-critical
financial notifications that users depend on to avoid unwanted charges.
```

---

## 🔧 Build Commands

### Development Build
```bash
flutter run --release
```

### Archive for App Store

**IMPORTANT:** Always run Flutter commands BEFORE opening Xcode to generate required build files.

**Option 1: Archive in Xcode (Recommended)**

```bash
# Close Xcode if it's open
killall Xcode

# Clean build
flutter clean
flutter pub get

# Generate code (if you modified models/providers)
dart run build_runner build --delete-conflicting-outputs

# Build iOS release (generates all Xcode files)
flutter build ios --release --no-codesign

# Open Xcode workspace
open ios/Runner.xcworkspace
```

Then in Xcode:
1. Select "Any iOS Device (arm64)" as build target
2. Product → Clean Build Folder (⌘⇧K)
3. Product → Archive (⌘⇧B)
4. Wait ~30 seconds (fast because Flutter already built everything)
5. Distribute App → App Store Connect

**Option 2: CLI Build + Xcode Archive (For memory issues)**

If you encounter exit code -9 errors:

```bash
# Build with optimization flags
flutter build ios --release --no-codesign --split-debug-info=build/debug-info

# Then archive in Xcode (will be very fast)
open ios/Runner.xcworkspace
```

**Common Error: package_config.json missing**

If Xcode shows "package_config.json does not exist":
- You forgot to run `flutter pub get` before opening Xcode
- Run `flutter pub get && flutter build ios --release --no-codesign`
- Restart Xcode

---

## 💳 RevenueCat & IAP Configuration

### RevenueCat Setup (Completed Feb 2026)

| Item | Value |
|------|-------|
| SDK | `purchases_flutter: ^9.0.0` (upgraded from 8.x for iOS 26 compatibility) |
| iOS API Key | `appl_rRzabPDSmVyXEYjWSaSuklniHEA` — copy from RC dashboard, never type manually |
| Product ID | `customsubs_premium_monthly` |
| Entitlement ID | `premium` |
| Offering ID | `default` |
| Price | $0.99/month with 3-day free trial |
| App-Specific Shared Secret | Configured in RC → Apps & providers → CustomSubs (App Store) |

### IAP Submission Process (Critical)
- IAP products are **automatically returned** to "Developer Action Needed" when a binary is rejected — this is normal Apple cascade behavior, not a content problem
- IAP **must be submitted with the binary** — go to version page → "In-App Purchases and Subscriptions" → add the product → Submit for Review
- Do NOT submit the IAP product standalone from its own page
- Localization showing "Rejected" after binary rejection = same cascade, content is fine

### Hard-Learned API Key Lessons
The iOS API key was mistyped twice across multiple builds, causing `INVALID_CREDENTIALS` errors. Both were visually ambiguous character swaps:
1. `app1_` (number `1`) instead of `appl_` (lowercase `l`) — prefix typo
2. `Sukt` instead of `Sukl` — character typo in the middle of the key

**Rule: always copy-paste API keys directly from the RevenueCat dashboard. Never type them manually.** When RevenueCat returns `INVALID_CREDENTIALS`, verify the key character-by-character against the dashboard.

### RC Initialization — Known Pitfalls
1. **`_isInitialized` must be set after `configure()`, not after `getCustomerInfo()`**
   - `getCustomerInfo()` can throw due to StoreKit timing or network conditions at launch
   - If it throws and `_isInitialized` hasn't been set yet, RC appears uninitialized even though `configure()` succeeded
   - Fix: set `_isInitialized = true` immediately after `Purchases.configure()`; wrap `getCustomerInfo()` in its own try/catch

2. **Offering fallback must be applied everywhere**
   - Always use `offerings.current ?? offerings.all[RevenueCatConstants.defaultOfferingId]`
   - If only `offerings.current` is used, purchase silently fails when RC sync lags

3. **Never gate the subscribe button on `_offeringError`**
   - Pre-load failure must not permanently disable the button
   - The service layer retries internally — the UI must always allow a purchase attempt

---

## ❓ Common App Review Issues & Solutions

### "Missing Permission Description"
**Solution:** ✅ Already added to Info.plist

### "Privacy Manifest Required"
**Solution:** ✅ Already created PrivacyInfo.xcprivacy

### "App Doesn't Match Description"
**Solution:** Ensure App Store description accurately reflects offline-only nature

### "Time Sensitive Notifications Justification"
**Solution:** See justification text above - financial reminders are legitimately time-critical

---

## 📞 Support

For questions during App Store submission:
- Apple Developer Forums
- App Store Connect Support
- This documentation

---

**Status:** ✅ iOS Configuration Complete
**Next Step:** Open Xcode and enable Time Sensitive Notifications (optional, recommended)
