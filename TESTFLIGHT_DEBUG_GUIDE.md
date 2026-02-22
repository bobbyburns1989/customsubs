# TestFlight Debugging Guide - Purchase Flow

**Created:** 2026-02-21
**Issue:** "Purchase failed" message on TestFlight
**Version:** v1.1.1+16

---

## 🔥 IMMEDIATE NEXT STEPS

Since you're testing on **TestFlight** (not Xcode), the debug console isn't available. I've updated the app to show **error details directly on screen**.

### **What to Do Now:**

1. **Archive a new build** with the updated error display code
2. **Upload to TestFlight**
3. **Try the purchase again**
4. **When it fails**, tap the **"Details"** button on the error message
5. **Screenshot the error dialog** and send it to me

The dialog will show EXACTLY what's wrong:
- ❌ No offering found?
- ❌ Package not found?
- ❌ Product ID mismatch?
- ❌ Network issue?

---

## 📋 RevenueCat Configuration Checklist

While waiting for the new build, **verify your RevenueCat setup**:

### **1. RevenueCat Dashboard - Products**

Go to: https://app.revenuecat.com/ → Your Project → Products

- [ ] Product `customsubs_premium_monthly` exists
- [ ] Product Type: "Subscription"
- [ ] Store: "App Store" (iOS)
- [ ] Product Identifier matches: `customsubs_premium_monthly`

**Screenshot the Products page and check:**
```
Product Identifier: customsubs_premium_monthly ✅
```

### **2. RevenueCat Dashboard - Entitlements**

Go to: RevenueCat Dashboard → Entitlements

- [ ] Entitlement named `premium` exists
- [ ] Product `customsubs_premium_monthly` is attached to `premium` entitlement

**Screenshot the Entitlements page and verify:**
```
Entitlement: premium
  └─ Products: customsubs_premium_monthly ✅
```

### **3. RevenueCat Dashboard - Offerings**

Go to: RevenueCat Dashboard → Offerings

- [ ] Offering with identifier `default` exists (or "default" is set)
- [ ] Offering contains the monthly package
- [ ] Package is marked as "Current Offering"

**Expected structure:**
```
Offering: default ✅
  └─ Package: Monthly (or $rc_monthly)
      └─ Product: customsubs_premium_monthly ✅
```

**CRITICAL:** The offering identifier MUST be `default` (or make it the current offering)

### **4. App Store Connect - In-App Purchase**

Go to: App Store Connect → CustomSubs → In-App Purchases

- [ ] Product ID `customsubs_premium_monthly` exists
- [ ] Status: "Ready to Submit" or "Approved"
- [ ] Type: "Auto-Renewable Subscription"
- [ ] Price: $0.99/month
- [ ] Free Trial: 3 days configured

**Check the exact Product ID:**
```
Product ID: customsubs_premium_monthly ✅
```

**Trial configuration:**
```
Introductory Offer: 3 Day Free Trial
Duration: 3 Days
Price: Free
```

### **5. RevenueCat - App Configuration**

Go to: RevenueCat Dashboard → Apps → CustomSubs (iOS)

- [ ] Bundle ID matches your app: `com.customapps.customsubs` (or whatever yours is)
- [ ] Shared Secret configured (App Store Connect → App-Specific Shared Secret)
- [ ] API Key is correct (matches `RevenueCatConstants.iosApiKey`)

---

## 🐛 Common Configuration Mistakes

### **Mistake 1: Offering not named "default"**

❌ **Wrong:**
```
Offering: monthly_subscription
```

✅ **Correct:**
```
Offering: default  ← MUST be "default" or set as current
```

**Fix:** Rename offering to `default` OR mark it as "Current Offering"

---

### **Mistake 2: Product not attached to Entitlement**

❌ **Wrong:**
```
Entitlement: premium
  └─ Products: (empty)
```

✅ **Correct:**
```
Entitlement: premium
  └─ Products: customsubs_premium_monthly
```

**Fix:** Go to Entitlements → premium → Attach Products → Select `customsubs_premium_monthly`

---

### **Mistake 3: Package not in Offering**

❌ **Wrong:**
```
Offering: default
  └─ Packages: (empty)
```

✅ **Correct:**
```
Offering: default
  └─ Package: $rc_monthly
      └─ Product: customsubs_premium_monthly
```

**Fix:** Go to Offerings → default → Add Package → Select monthly product

---

### **Mistake 4: Product ID Mismatch**

❌ **Wrong:**
```
RevenueCat: customsubs.premium.monthly
App Code:    customsubs_premium_monthly
```

✅ **Correct:**
```
RevenueCat: customsubs_premium_monthly
App Code:    customsubs_premium_monthly
App Store:   customsubs_premium_monthly
```

**Fix:** Ensure ALL THREE match exactly (case-sensitive!)

---

## 🧪 Testing the New Build

### **Step 1: Archive New Build**

The code now includes on-screen error display:

```bash
# In Xcode (already open)
1. Product → Archive
2. Upload to TestFlight
3. Wait for processing (~10 min)
```

### **Step 2: Test Purchase Flow**

1. Open app from TestFlight
2. Go to Paywall screen
3. Tap "Start 3-Day Free Trial"
4. **When it fails:**
   - You'll see: "Purchase failed: [specific error]"
   - Tap **"Details"** button
   - Screenshot the dialog
   - Send screenshot to me

### **Step 3: What the Error Dialog Will Show**

**If offering not found:**
```
❌ Error: No RevenueCat offering found

Fix: Check RevenueCat Dashboard → Offerings → Create "default" offering

Total Offerings: 0
```

**If product not found:**
```
❌ Error: Product not found

Expected: customsubs_premium_monthly

Available:
  • some_other_product
  • another_product

Add product "customsubs_premium_monthly" to RevenueCat offering
```

**If everything is configured correctly but still fails:**
```
(We'll see a different error that tells us the real issue)
```

---

## 🔧 Quick Fixes Based on Error

### **Error: "No offering available"**

**Cause:** RevenueCat has no "default" offering configured

**Fix:**
1. Go to RevenueCat Dashboard → Offerings
2. Click "New Offering"
3. Name it exactly: `default`
4. Add a package (monthly)
5. Attach product: `customsubs_premium_monthly`
6. Mark as "Current Offering"

---

### **Error: "Package not found"**

**Cause:** Product ID mismatch or product not in offering

**Fix:**
1. Check error dialog for "Expected" vs "Available" products
2. If expected product not in available list:
   - Go to RevenueCat → Offerings → default
   - Add package with correct product
3. If product names don't match:
   - Verify product ID in App Store Connect
   - Update RevenueCat product identifier to match

---

### **Error: "Purchase cancelled by user"**

**Cause:** You tapped "Cancel" in the App Store purchase dialog

**Fix:** This is normal behavior, not an error

---

### **Error: Unexpected exception**

**Cause:** Various (network, configuration, etc.)

**Fix:**
1. Screenshot the error details dialog
2. Check RevenueCat Dashboard → Customers → Find your test user
3. Look for any error logs
4. Send screenshot to me for analysis

---

## 📞 Next Steps After Testing

### **If you get an error dialog:**

1. ✅ Take screenshot of the error details
2. ✅ Send screenshot to me
3. ✅ Check the RevenueCat configuration checklist above
4. ✅ I'll analyze and provide exact fix

### **If it works (success!):**

1. 🎉 Celebrate! The fix worked!
2. ✅ Verify trial starts (check Settings for Premium badge)
3. ✅ Test other features
4. ✅ Submit to App Store Review

---

## 🎯 What I Changed for TestFlight Debugging

### **Before (v1.1.1+16 original):**
```dart
// Generic error
ScaffoldMessenger.showSnackBar(
  SnackBar(content: Text('Purchase failed')),
);
```

### **After (v1.1.1+16 updated):**
```dart
// Specific error with details dialog
final errorMsg = service.lastErrorMessage; // "Package not found"
final errorDetails = service.lastErrorDetails; // Full diagnostic info

ScaffoldMessenger.showSnackBar(
  SnackBar(
    content: Text('Purchase failed: $errorMsg'),
    action: SnackBarAction(
      label: 'Details',
      onPressed: () {
        // Shows dialog with full diagnostic info
        showDialog(...);
      },
    ),
  ),
);
```

**Now you can see:**
- Exact error type
- Expected vs actual product IDs
- Available offerings/packages
- Specific fix suggestions

---

## 📖 Additional Resources

- **RevenueCat Flutter Docs:** https://docs.revenuecat.com/docs/flutter
- **RevenueCat Dashboard:** https://app.revenuecat.com/
- **App Store Connect:** https://appstoreconnect.apple.com/
- **Testing In-App Purchases:** https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases

---

## ✅ Summary

**What to do RIGHT NOW:**

1. ⏳ Archive new build in Xcode (with updated error display)
2. ⏳ Upload to TestFlight
3. ⏳ Test purchase flow
4. ⏳ Tap "Details" when it fails
5. ⏳ Screenshot the error dialog
6. ⏳ Send screenshot to me

**Meanwhile, check:**
- [ ] RevenueCat offering named `default` exists
- [ ] Product `customsubs_premium_monthly` in offering
- [ ] Entitlement `premium` attached to product
- [ ] App Store Connect has matching product ID

**The new error dialog will tell us EXACTLY what's wrong!** 🔍
