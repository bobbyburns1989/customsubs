# TestFlight IAP Troubleshooting - Session Log

**Date:** February 25, 2026
**Build:** 1.3.0 (27)
**Status:** 🔄 IN PROGRESS - Troubleshooting subscription configuration

---

## 📊 Current Situation

### ✅ Completed Steps

1. **Code Implementation** ✅
   - iPad legal link visibility fixes
   - Offering pre-loading
   - Retry logic with exponential backoff
   - iOS 18 StoreKit workaround
   - Version bumped to 1.3.0+27

2. **Build & Archive** ✅
   - Full clean executed
   - iOS build completed (83.2MB)
   - Uploaded to TestFlight
   - Build 27 available in TestFlight

3. **App Store Connect - Subscription Setup** ✅
   - Subscription Group created: "Premium"
   - Subscription created: "Premium Monthly"
   - Product ID: `customsubs_premium_monthly`
   - Duration: 1 month
   - Subscription Group localization configured

4. **Subscription Configuration Fixes** ✅
   - Fixed English (U.S.) localization (was Rejected)
   - Added Subscription Display Name: "Premium Monthly"
   - Added Description: "Unlimited subscriptions..."
   - Configured pricing (should be $0.99/month)
   - Configured free trial (should be 3 days)

---

## ⚠️ Current Issue

**Error in TestFlight:**
```
No subscription available. Please try again later.
```

**Location:** Paywall screen, below grayed-out Subscribe button

**Meaning:** Offering pre-load is failing - RevenueCat can't find the subscription product

---

## 🔍 Possible Root Causes

### 1. Product Status Still "Developer Action Needed"
**Symptoms:**
- Status field shows red X icon
- Subscription not fully configured
- Missing required fields

**How to Check:**
- App Store Connect → Premium Monthly → Status field at top
- Should say "Ready to Submit" (yellow) or "Waiting for Review" (orange)
- If still "Developer Action Needed" (red), configuration incomplete

**Solution:**
- Review all sections on Premium Monthly page
- Look for red/yellow warning icons
- Fill in missing fields:
  - Subscription Prices (must include United States at $0.99)
  - Introductory Offer (3-day free trial)
  - Localization (English U.S. must not be Rejected)

---

### 2. RevenueCat Offering Not Configured
**Symptoms:**
- Product exists in RevenueCat Products
- But not in any Offering
- App can't fetch it because it's not in "default" offering

**How to Check:**
- RevenueCat Dashboard → Offerings
- Look for "default" offering
- Check if `customsubs_premium_monthly` is listed as a package

**Solution:**
1. RevenueCat Dashboard → Offerings
2. If no "default" offering exists → Create it:
   - Click "+ Create Offering"
   - Identifier: `default`
   - Name: "Default Offering"
   - Click Create
3. Add product to offering:
   - Click on "default" offering
   - Click "+ Add Package"
   - Select: `customsubs_premium_monthly`
   - Package Identifier: `$rc_monthly` or `monthly`
   - Click Add
4. Make it current:
   - Ensure "default" has "Current" badge
   - If not, click "Make Current"

---

### 3. App Store Connect Not Synced to RevenueCat
**Symptoms:**
- Product configured in App Store Connect
- But RevenueCat hasn't synced yet
- Product appears but no pricing/details

**How to Check:**
- RevenueCat Dashboard → Products → `customsubs_premium_monthly`
- Look for sync status icon (should be green checkmark)
- Check "Last Synced" timestamp

**Solution:**
1. RevenueCat Dashboard → Products
2. Click Sync button (refresh icon)
3. Wait 1-2 minutes
4. Refresh page
5. Verify product shows green checkmark
6. Check offering still contains the product

---

### 4. App Store Connect Processing Delay
**Symptoms:**
- Everything configured correctly
- But changes not yet propagated to StoreKit
- Typically happens within 15 minutes but can take longer

**How to Check:**
- Wait 30-60 minutes after saving changes
- Try again

**Solution:**
- Wait longer (up to 2 hours in rare cases)
- Force quit TestFlight app
- Restart device
- Try again

---

### 5. RevenueCat API Key Mismatch
**Symptoms:**
- Product configured but app can't access it
- RevenueCat API key in app doesn't match dashboard

**How to Check:**
```bash
grep -r "iosApiKey" lib/core/constants/
```

Expected: `app1_rRzabPDSmVyXEYjWSaSuktniHEA`

**Solution:**
- RevenueCat Dashboard → Settings → API Keys
- Copy iOS SDK Key (App-specific)
- Compare with `revenue_cat_constants.dart`
- If mismatch, update code and rebuild

---

## 🧪 Diagnostic Steps

### Test 1: Check Console Logs
If device connected to Mac with Xcode open:

1. Window → Devices and Simulators
2. Select device
3. Open Console
4. Filter: "PAYWALL" or "RevenueCat"
5. Look for error messages

**Expected logs if working:**
```
✅ PAYWALL: Offering pre-loaded successfully
   Packages: 1
```

**Error logs if broken:**
```
❌ PAYWALL: Offering pre-load failed: [error details]
❌ Error fetching offerings: [RevenueCat error]
```

---

### Test 2: Verify Product in RevenueCat Dashboard

**Products Page:**
- [ ] Product exists: `customsubs_premium_monthly`
- [ ] Store: App Store ✓
- [ ] Status: Green checkmark (synced)
- [ ] Price: $0.99/month shown
- [ ] Trial: 3 days shown

**Offerings Page:**
- [ ] "default" offering exists
- [ ] "default" is marked as Current
- [ ] Contains package with `customsubs_premium_monthly`
- [ ] Package type: Monthly or $rc_monthly

---

### Test 3: Verify App Store Connect Status

**Premium Monthly Page:**
- [ ] Status: "Ready to Submit" or "Waiting for Review"
- [ ] NOT "Developer Action Needed"
- [ ] Pricing set: $0.99 for United States
- [ ] Free trial: 3 days configured
- [ ] Localization: English (U.S.) NOT rejected

---

## 📋 Troubleshooting Checklist

Run through this checklist:

1. **App Store Connect Configuration:**
   - [ ] Premium Monthly status = "Ready to Submit" (not "Developer Action Needed")
   - [ ] Subscription Prices → United States → $0.99/month
   - [ ] Introductory Offers → Free Trial → 3 days
   - [ ] Localization → English (U.S.) → Green checkmark (not Rejected)
   - [ ] All changes saved

2. **RevenueCat Configuration:**
   - [ ] Logged into RevenueCat dashboard
   - [ ] Products → `customsubs_premium_monthly` exists
   - [ ] Product shows green checkmark (synced)
   - [ ] Clicked Sync button recently
   - [ ] Offerings → "default" offering exists
   - [ ] "default" offering contains `customsubs_premium_monthly`
   - [ ] "default" offering marked as Current

3. **Testing Steps:**
   - [ ] Waited 30+ minutes after saving changes
   - [ ] Force quit TestFlight app completely
   - [ ] Restarted device
   - [ ] Opened TestFlight → CustomSubs
   - [ ] Navigated to paywall
   - [ ] Waited 3-5 seconds for pre-load
   - [ ] Checked if error message disappeared

---

## 🎯 Decision Point: To Submit or Not?

### ❌ DO NOT SUBMIT if:
- Purchase doesn't work in TestFlight
- Status still "Developer Action Needed"
- RevenueCat offering not configured
- Error message still appears

**Submitting with broken IAP = immediate rejection**

### ✅ READY TO SUBMIT if:
- Purchase works in TestFlight
- Status = "Ready to Submit" or "Waiting for Review"
- RevenueCat offering properly configured
- No error message on paywall
- Can complete sandbox purchase successfully

---

## 📞 Next Steps

**Current Status:** Awaiting verification of:
1. App Store Connect subscription status (screenshot needed)
2. RevenueCat offering configuration (screenshot needed)
3. Console logs from TestFlight test (if available)

**Action Items:**
1. User to verify subscription status in App Store Connect
2. User to check RevenueCat offering configuration
3. User to wait 30-60 minutes if recently saved changes
4. User to test again after verification

**Once Verified Working:**
1. Complete sandbox purchase test
2. Verify premium unlocks
3. Test on iPad as well
4. Archive new build if needed (only if code changes required)
5. Submit to App Review with comprehensive notes

---

## 📊 Technical Details

**Product Configuration:**
- Product ID: `customsubs_premium_monthly`
- Price: $0.99 USD/month
- Trial: 3 days free
- Group: Premium (21943395)
- Store: Apple App Store

**RevenueCat Configuration:**
- API Key: `app1_rRzabPDSmVyXEYjWSaSuktniHEA`
- Offering: default
- Package Type: Monthly ($rc_monthly)

**App Code:**
- Product ID constant: `lib/core/constants/revenue_cat_constants.dart:19`
- Offering fetch: `lib/data/services/entitlement_service.dart:getOfferingsWithRetry()`
- Paywall pre-load: `lib/features/paywall/paywall_screen.dart:_preloadOffering()`

---

**Last Updated:** February 25, 2026
**Status:** 🔄 Troubleshooting in progress
**Next Update:** After user verifies subscription status
