# Final Resubmission Steps - CustomSubs v1.2.0 Build 24

## Status Summary

### ✅ Completed
- [x] **Issue #1 Fixed**: Terms of Use link added to paywall
- [x] **Issue #1 Fixed**: Privacy Policy link added to paywall
- [x] **Issue #1 Fixed**: Terms uploaded to customsubs.us/terms
- [x] Build number incremented to 24
- [x] Code changes complete

### ⚠️ Before You Submit
- [ ] Verify customsubs.us/privacy still works
- [ ] Fix RevenueCat configuration (see REVENUECAT_CHECKLIST.md)
- [ ] Test purchase in sandbox
- [ ] Clean build and archive
- [ ] Submit to App Store Connect
- [ ] Reply to Apple's review message

---

## Step-by-Step Resubmission Process

### Step 1: Verify Web Links (2 minutes)

Open in browser and confirm both load (NO 404):
- ✅ https://customsubs.us/terms (confirmed working)
- ❓ https://customsubs.us/privacy (verify this)

**If privacy shows 404:**
- Upload your privacy policy HTML to the server
- Or temporarily point to: https://www.apple.com/legal/privacy/

---

### Step 2: Fix RevenueCat (10-15 minutes)

**This is what's causing the "Unknown error"**

Follow the complete guide: **`REVENUECAT_CHECKLIST.md`**

**Quick summary:**
1. Log into https://app.revenuecat.com
2. Verify "default" offering exists
3. Verify product `customsubs_premium_monthly` is in the offering
4. Verify API key in code matches dashboard
5. Test purchase on real device with sandbox tester

**Don't skip testing in sandbox!** If it fails in sandbox for you, it will fail for Apple reviewers.

---

### Step 3: Clean Build (5 minutes)

```bash
cd /Users/bobbyburns/Projects/customsubs

# Clean everything
flutter clean

# Get dependencies
flutter pub get

# Install iOS pods
cd ios && pod install && cd ..
```

---

### Step 4: Archive in Xcode (10 minutes)

1. Open Xcode workspace:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Wait for Xcode to finish indexing

3. Select **Any iOS Device (arm64)** as destination (NOT simulator)

4. Product → Archive

5. Wait for archive to complete (~2-5 minutes)

6. Xcode Organizer will open automatically

---

### Step 5: Distribute to App Store Connect (5 minutes)

In Xcode Organizer:

1. Select your archive
2. Click **Distribute App**
3. Choose **App Store Connect**
4. Click **Upload**
5. Accept defaults (include symbols, manage version)
6. Click **Upload**
7. Wait for upload to complete

---

### Step 6: Submit for Review in App Store Connect (5 minutes)

1. Go to https://appstoreconnect.apple.com
2. Select CustomSubs
3. Click on version (should see new build 24)
4. If build doesn't appear:
   - Wait 5-10 minutes for processing
   - Refresh the page
5. Select build 24
6. **Don't change anything else** (screenshots, description, etc.)
7. Click **Save**
8. Click **Submit for Review**

---

### Step 7: Reply to Apple's Review Message (IMPORTANT)

In App Store Connect:

1. Go to **App Review** → **Resolution Center**
2. Find the rejection message from Apple
3. Click **Reply**
4. Copy/paste this response:

```
Hello Apple Review Team,

Thank you for the detailed feedback. I have addressed both issues:

Issue #1: Terms of Use (EULA) Link - FIXED ✅
I have added functional links to both Terms of Use and Privacy Policy in the subscription purchase flow (paywall screen). Both documents are now accessible at:
• Terms of Use: https://customsubs.us/terms
• Privacy Policy: https://customsubs.us/privacy

The links are visible on the paywall screen below the "Restore Purchases" button, formatted as: "Terms of Use • Privacy Policy"

Issue #2: Purchase Error - FIXED ✅
The "Unknown error" occurred due to a RevenueCat configuration issue in the sandbox environment. I have:
1. Verified the product configuration in App Store Connect (Product ID: customsubs_premium_monthly)
2. Verified the RevenueCat offering configuration includes the monthly product
3. Tested the purchase flow successfully in sandbox with a test account
4. Confirmed the purchase completes without errors

The purchase flow now works correctly for both sandbox testing and production.

I have submitted version 1.2.0 (build 24) which includes these fixes.

Please let me know if you need any additional information.

Best regards
```

5. Click **Send**

---

## Pre-Submission Testing (CRITICAL)

### Test in App Before Submitting:

**On Real Device (iPhone/iPad):**

1. Build from Xcode or install TestFlight
2. Open app
3. Go to Settings → Premium (or wherever upgrade is)
4. Tap "Subscribe for $0.99/month"
5. **VERIFY**: No "Unknown error" appears
6. **VERIFY**: Purchase completes successfully (or you can cancel)
7. Tap "Terms of Use" link at bottom of paywall
8. **VERIFY**: Opens browser to customsubs.us/terms
9. Tap "Privacy Policy" link
10. **VERIFY**: Opens browser to customsubs.us/privacy

**If ANY of these fail → Fix before submitting**

---

## What Apple Will Test

Apple reviewers will:
1. ✅ Look for Terms of Use link in subscription flow (NOW PRESENT)
2. ✅ Tap the Terms link and verify it loads (customsubs.us/terms WORKS)
3. ✅ Tap "Subscribe for $0.99/month" button
4. ❓ Verify purchase completes without error (NEEDS REVENUECAT FIX)

**You MUST fix RevenueCat and test in sandbox before resubmitting!**

---

## Estimated Timeline

| Step | Time | Total |
|------|------|-------|
| Verify web links | 2 min | 2 min |
| Fix RevenueCat config | 10 min | 12 min |
| Test sandbox purchase | 5 min | 17 min |
| Clean build | 5 min | 22 min |
| Archive in Xcode | 10 min | 32 min |
| Upload to ASC | 5 min | 37 min |
| Submit for review | 5 min | 42 min |
| Reply to Apple | 3 min | **45 min total** |

**You can complete the entire resubmission in under 1 hour.**

---

## Files Reference

- **REVENUECAT_CHECKLIST.md** - Complete RevenueCat fix guide
- **APP_STORE_REVIEW_FIX_v1.7.md** - Full technical details
- **URGENT_ACTION_REQUIRED.md** - Quick summary
- **TERMS_OF_USE_WEB.html** - Terms uploaded to website
- **This file** - Final step-by-step checklist

---

## Quick Checklist (Copy This)

```
PRE-SUBMISSION:
[ ] customsubs.us/terms loads (no 404)
[ ] customsubs.us/privacy loads (no 404)
[ ] RevenueCat "default" offering exists
[ ] Product customsubs_premium_monthly in offering
[ ] Tested purchase in sandbox - SUCCESS
[ ] Terms/Privacy links work in app

BUILD & SUBMIT:
[ ] flutter clean
[ ] flutter pub get
[ ] cd ios && pod install
[ ] Archive in Xcode
[ ] Upload to App Store Connect
[ ] Submit for review
[ ] Reply to Apple's message

DONE!
```

---

## Next Step Right Now

🎯 **Go to REVENUECAT_CHECKLIST.md and fix the RevenueCat configuration**

That's the only blocker remaining. Once that's working in sandbox, you're ready to submit!

---

**Good luck! You're almost there. 🚀**
