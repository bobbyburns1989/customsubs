# Release Ready - v1.3.0 Build 28

**Date:** February 25, 2026
**Status:** ✅ READY TO ARCHIVE
**Changes:** IAP configuration resubmission (no code changes)

---

## 📋 Pre-Archive Checklist

### ✅ Preparation Complete
- [x] Flutter clean executed
- [x] Dependencies fetched (`flutter pub get`)
- [x] iOS pods installed
- [x] Version: 1.3.0 (unchanged)
- [x] Build: 28 (incremented from 27)
- [x] CHANGELOG updated

### ⚠️ App Store Connect Requirements
Before archiving, verify in App Store Connect:

**Subscription Configuration:**
1. Navigate to: Your App → Subscriptions → Premium → Premium Monthly
2. Verify Status field shows:
   - ✅ "Ready to Submit" (yellow) OR
   - ✅ "Waiting for Review" (orange) OR
   - ✅ "Approved" (green)
   - ❌ NOT "Developer Action Needed"

3. Verify all fields are complete:
   - ✅ Product ID: `customsubs_premium_monthly`
   - ✅ Price: $0.99/month (United States)
   - ✅ Free Trial: 3 days
   - ✅ English (U.S.) Localization: Complete (not "Rejected")
   - ✅ No red/yellow warning icons visible

**RevenueCat Sync:**
1. Go to: https://app.revenuecat.com
2. Navigate to: Products
3. Click: Sync button (refresh icon)
4. Wait: 1 minute for sync to complete
5. Verify: `customsubs_premium_monthly` shows green checkmark

---

## 🎯 Next Steps

### 1. Open in Xcode
```bash
open ios/Runner.xcworkspace
```

### 2. Archive Process
1. **Select Device:** Any iOS Device (Generic iOS Device)
2. **Product Menu:**
   - Product → Clean Build Folder (⇧⌘K)
   - Wait for clean to complete
3. **Archive:**
   - Product → Archive
   - Wait for build (~3-5 minutes)
4. **Organizer Window Opens:**
   - Select: CustomSubs 1.3.0 (28)
   - Click: "Distribute App"
5. **Distribution Method:**
   - Select: "App Store Connect"
   - Click: Next
6. **Destination:**
   - Select: "Upload"
   - Click: Next
7. **Distribution Options:**
   - ✅ Include bitcode for iOS content: NO
   - ✅ Upload your app's symbols: YES
   - ✅ Manage Version and Build Number: YES (Xcode will increment if needed)
   - Click: Next
8. **Automatic Signing:**
   - Select: "Automatically manage signing"
   - Click: Next
9. **Review:**
   - Review archive contents
   - Click: Upload
10. **Wait for Processing:**
    - Upload: ~2-5 minutes
    - Processing in App Store Connect: ~10-30 minutes

### 3. After Upload Completes

**Add to TestFlight (optional):**
1. App Store Connect → TestFlight
2. Select Build 28
3. Add to Internal Testing
4. Test the purchase flow one more time

**Submit for Review:**
1. App Store Connect → Your App → App Store tab
2. Click: "+ Version" or "Add for Review"
3. Select Build: 1.3.0 (28)
4. Review Information:
   - **What's New in This Version:**
     ```
     Bug fixes and performance improvements for in-app purchases.
     ```
5. Submit for Review
6. Wait for Apple review (~24-48 hours typically)

---

## 🐛 What Changed Since Build 27?

**Code Changes:** NONE
**Configuration Changes:**
- App Store Connect: Subscription product fully configured
- Pricing: $0.99/month with 3-day free trial set
- Localization: English (U.S.) completed
- Status: Changed from "Developer Action Needed" to "Ready to Submit"

**Why a New Build?**
Even though no code changed, incrementing the build number is best practice when resubmitting to App Store Connect. It helps:
- Track which build corresponds to which submission
- Avoid confusion in TestFlight
- Maintain clear audit trail in App Store Connect

---

## 📊 What Apple Reviewers Will Test

1. **Download app on iPad**
2. **Navigate to paywall** (tap "Add Subscription" 6+ times to hit limit)
3. **Verify legal links visible** (should see Terms and Privacy above Subscribe button)
4. **Tap Subscribe**
5. **Complete sandbox purchase** (Apple uses sandbox test accounts)
6. **Verify premium activates** (can add unlimited subscriptions)
7. **Check Terms/Privacy links open** (https://customsubs.us/terms and /privacy)

**Expected Result:** All steps work correctly ✅

---

## ⚠️ Known Issues (Not Blockers)

**TestFlight IAP Testing:**
- If you test in TestFlight before submission, you may still see "No subscription available" error
- This is OK if App Store Connect status is still processing
- Once status changes to "Ready to Submit" and Apple syncs (~15-30 min), it should work
- Apple reviewers test in a different sandbox environment that always works for properly configured products

**CocoaPods Warning:**
- Warning about base configuration during `pod install` is normal
- Does not affect build or archive process
- Safe to ignore

---

## 📞 If Build/Archive Fails

**Common Issues:**

1. **Signing Error:**
   - Xcode → Preferences → Accounts
   - Verify your Apple ID is added
   - Download Manual Profiles
   - Try archive again

2. **"No such module" Error:**
   ```bash
   cd ios
   pod deintegrate
   pod install
   cd ..
   ```
   - Then try archive again in Xcode

3. **Build Number Already Used:**
   - App Store Connect already has build 28
   - Increment to 29:
     ```bash
     # In pubspec.yaml, change version: 1.3.0+28 to version: 1.3.0+29
     ```
   - Try archive again

---

## ✅ Success Criteria

**You know everything worked when:**
1. ✅ Archive completes without errors
2. ✅ Upload completes successfully
3. ✅ Build 28 appears in App Store Connect → TestFlight (within 30 min)
4. ✅ No email from Apple about invalid binary
5. ✅ You can select Build 28 when submitting for review

---

## 🎯 Final Confidence Check

Before clicking "Submit for Review":

- ✅ Subscription product status: "Ready to Submit" or better
- ✅ All subscription fields completed (price, trial, localization)
- ✅ RevenueCat synced
- ✅ Build 28 uploaded successfully
- ✅ TestFlight build shows "Ready to Submit" status
- ✅ Legal links (terms/privacy) are live and accessible
- ✅ All previous rejection issues addressed:
  - iPad layout: Legal links visible without scrolling ✅
  - IAP reliability: Offering pre-load + retry logic ✅
  - IAP configuration: Subscription fully configured in ASC ✅

**If all checks pass:** Submit with confidence! ✅

---

## 📞 Need Help?

**App Store Connect Issues:**
- https://developer.apple.com/support/app-store-connect/

**RevenueCat Setup:**
- https://www.revenuecat.com/docs

**StoreKit Sandbox:**
- https://developer.apple.com/documentation/storekit/testing-in-app-purchases-with-sandbox

Good luck! 🚀
