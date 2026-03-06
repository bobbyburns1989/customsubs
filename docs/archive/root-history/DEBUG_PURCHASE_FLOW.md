# Purchase Flow Debug Guide

**Created:** 2026-02-21
**Purpose:** Diagnose "purchase failed" issue with 3-day free trial

---

## 🔍 What Was Added

### Enhanced Debug Logging in `entitlement_service.dart`

I've added comprehensive debug logging throughout the entire purchase flow:

#### 1. **Initialization Logging** (lines ~35-75)
- Platform detection (iOS/Android)
- API key verification (masked for security)
- Debug mode status
- Customer info retrieval confirmation

#### 2. **Purchase Flow Start** (lines ~264-280)
- Purchase initiation timestamp
- Platform confirmation
- Target product ID
- RevenueCat initialization status

#### 3. **Offering Details** (lines ~293-360)
- Complete offering structure
- All available packages with full details
- **Three different package matching methods:**
  - Method 1: `storeProduct.identifier` (CORRECT - fixed bug)
  - Method 2: `package.identifier` (fallback)
  - Method 3: `PackageType.monthly` (last resort)
- Visual indicators showing which package matches

#### 4. **Purchase Execution** (lines ~370-420)
- Purchase initiation confirmation
- Response analysis
- Entitlement verification
- Trial status detection
- Success/failure determination

#### 5. **Enhanced Error Handling** (lines ~422-465)
- Detailed PlatformException breakdown
- Specific error code interpretation
- Stack trace capture
- Actionable error messages

---

## 🐛 The Bug That Was Fixed

### **Original Problem:**
```dart
// ❌ WRONG - This was causing "Monthly package not found"
final monthlyPackage = offering.availablePackages.firstWhere(
  (package) => package.identifier == RevenueCatConstants.monthlyProductId,
  orElse: () => throw Exception('Monthly package not found'),
);
```

**Why it failed:**
- `package.identifier` = RevenueCat's internal ID (e.g., `"$rc_monthly"`)
- `RevenueCatConstants.monthlyProductId` = App Store product ID (`"customsubs_premium_monthly"`)
- **These never match!**

### **The Fix:**
The new code tries **three methods** to find the package (with debug output for each):

```dart
// ✅ Method 1: Correct approach
monthlyPackage = offering.availablePackages.firstWhere(
  (package) => package.storeProduct.identifier == RevenueCatConstants.monthlyProductId,
);

// ✅ Method 2: Fallback
monthlyPackage = offering.availablePackages.firstWhere(
  (package) => package.identifier == RevenueCatConstants.monthlyProductId,
);

// ✅ Method 3: Last resort
monthlyPackage = offering.availablePackages.firstWhere(
  (package) => package.packageType == PackageType.monthly,
);
```

---

## 📱 How to Test & Read Debug Output

### **Step 1: Run the app with debug console visible**

```bash
# Terminal 1 - Run the app
flutter run

# OR if using VS Code
# Press F5 or use Debug > Start Debugging
```

### **Step 2: Trigger the purchase flow**

1. Open the app
2. Navigate to the paywall screen
3. Tap **"Start 3-Day Free Trial"**

### **Step 3: Monitor the debug output**

You'll see structured output like this:

```
╔════════════════════════════════════════════════╗
║   REVENUECAT INITIALIZATION                    ║
╚════════════════════════════════════════════════╝
Platform: iOS
API Key: app1_rRzab...HEA
Debug Mode: ENABLED
Setting RevenueCat log level to DEBUG...
Configuring RevenueCat SDK...
Customer Info Retrieved: $RCAnonymousID:abc123...

✅ RevenueCat initialized successfully
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

╔════════════════════════════════════════════════╗
║   PURCHASE FLOW INITIATED                      ║
╚════════════════════════════════════════════════╝
Platform: iOS
RevenueCat Initialized: true
Target Product: customsubs_premium_monthly

📡 Fetching offerings from RevenueCat...
Total Offerings: 1
Current Offering: default

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 PURCHASE FLOW DEBUG - Available Offerings
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Offering ID: default
Total Packages: 1
Looking for Product ID: customsubs_premium_monthly

📋 All Available Packages:

Package #1:
  ├─ Package Identifier: "$rc_monthly"
  ├─ Product ID: "customsubs_premium_monthly"
  ├─ Price: $0.99
  ├─ Package Type: PackageType.monthly
  ├─ Matches by package.identifier? false
  ├─ Matches by storeProduct.identifier? true  ← THIS IS THE KEY!
  ├─ 🆓 Trial Available: YES
  │  ├─ Trial Price: $0.00
  │  ├─ Trial Period: P3D (3 days)
  │  └─ Trial Cycles: 1
  ✅ THIS IS THE PACKAGE WE WANT!

🔍 Searching for package...
✅ Found package using storeProduct.identifier

✅ Package Selected:
  ├─ Package ID: $rc_monthly
  ├─ Product ID: customsubs_premium_monthly
  └─ Price: $0.99
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💳 Initiating purchase with App Store/Play Store...
   Product: customsubs_premium_monthly
   Price: $0.99

[User completes purchase in App Store]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📥 PURCHASE RESPONSE RECEIVED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Premium Entitlement Active: true
Total Entitlements: 1

All Entitlements:
  - premium: ACTIVE ✅

Trial Status: ACTIVE 🆓
  ├─ Days Remaining: 3
  └─ Expires: 2026-02-24 09:00:00.000

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ PURCHASE SUCCESSFUL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🔧 What to Look For in Debug Output

### **If Purchase Succeeds:**
✅ Look for:
- `✅ Found package using storeProduct.identifier`
- `Premium Entitlement Active: true`
- `Trial Status: ACTIVE 🆓`
- `✅ PURCHASE SUCCESSFUL`

### **If Purchase Fails - Scenario 1: Package Not Found**
❌ Look for:
```
❌ Method 1 failed: storeProduct.identifier not found
❌ Method 2 failed: package.identifier not found
❌ Method 3 failed: No monthly package type found
❌ CRITICAL ERROR: Monthly package not found!
Expected Product ID: customsubs_premium_monthly
Available Products:
  - [list of actual product IDs]
```

**What this means:**
- Product `customsubs_premium_monthly` is NOT configured in RevenueCat
- Check RevenueCat Dashboard → Products
- Check App Store Connect → In-App Purchases

### **If Purchase Fails - Scenario 2: Configuration Error**
❌ Look for:
```
❌ CRITICAL: No current offering available
   Check RevenueCat dashboard configuration
   Ensure default offering exists and has products
```

**What this means:**
- RevenueCat offering not configured
- Go to RevenueCat Dashboard → Offerings
- Ensure "default" offering exists with packages

### **If Purchase Fails - Scenario 3: Platform Error**
❌ Look for:
```
❌ PLATFORM EXCEPTION DURING PURCHASE
Error Code: PurchasesErrorCode.xyz
Error Message: [specific error]
Reason: [human-readable explanation]
```

**Common reasons:**
- `purchaseCancelledError` → User tapped cancel
- `productAlreadyPurchasedError` → Already subscribed (try Restore)
- `storeProblemError` → App Store connection issue
- `purchaseNotAllowedError` → Device restrictions
- `purchaseInvalidError` → Product misconfigured in App Store Connect

---

## 📋 Diagnostic Checklist

Use this checklist to verify your RevenueCat configuration:

### **1. App Store Connect / Play Console**
- [ ] Product ID `customsubs_premium_monthly` exists
- [ ] Product type is "Auto-Renewable Subscription"
- [ ] 3-day free trial is configured as introductory offer
- [ ] Product is in "Ready to Submit" or "Approved" status
- [ ] Pricing is set ($0.99/month)

### **2. RevenueCat Dashboard**
- [ ] App is configured with correct bundle ID
- [ ] iOS API key matches `RevenueCatConstants.iosApiKey`
- [ ] Android API key matches `RevenueCatConstants.androidApiKey`
- [ ] Product `customsubs_premium_monthly` is added to RevenueCat
- [ ] Entitlement "premium" exists
- [ ] Product is mapped to "premium" entitlement
- [ ] Offering "default" exists
- [ ] Offering contains a package with the monthly product

### **3. App Configuration**
- [ ] RevenueCat initializes successfully (check debug output)
- [ ] API keys are correct in `revenue_cat_constants.dart`
- [ ] Product ID is correct in `revenue_cat_constants.dart`
- [ ] Entitlement ID is correct (`"premium"`)

---

## 🚀 Next Steps After Testing

### **If It Works:**
1. Share the successful debug output
2. We can remove/reduce debug logging for production
3. Ready to test on TestFlight/release

### **If It Still Fails:**
1. **Copy the ENTIRE debug output** from initialization to error
2. Send it to me (I'll analyze the exact issue)
3. Check the diagnostic checklist above
4. Verify RevenueCat dashboard configuration

### **Common Quick Fixes:**

#### Problem: "No offering available"
**Fix:** Go to RevenueCat Dashboard → Offerings → Create "default" offering

#### Problem: "Monthly package not found"
**Fix:**
1. Verify product ID in App Store Connect
2. Add product to RevenueCat
3. Add product to "default" offering

#### Problem: "Product already purchased"
**Fix:** Use "Restore Purchases" button instead of buying again

#### Problem: "Purchases not allowed"
**Fix:**
- Check device parental controls
- Ensure testing on real device (not simulator for actual purchases)
- Verify sandbox account for testing

---

## 📊 Testing Environments

### **Development (Sandbox)**
- Use sandbox test account
- Free trial works immediately
- Can reset purchases by deleting/reinstalling

### **TestFlight**
- Uses sandbox environment
- Good for real-world testing
- Can test purchase flow end-to-end

### **Production**
- Real App Store purchases
- Real money transactions
- Trial actually lasts 3 days

---

## 🔒 Security Note

The debug logging includes:
- ✅ Masked API keys (shows first 10 + last 4 chars only)
- ✅ No customer payment info
- ✅ No sensitive user data
- ✅ Safe to share debug output for troubleshooting

**However:** Remove or reduce debug logging before production release to minimize log file size.

---

## 📞 Support Resources

If you still encounter issues:

1. **RevenueCat Documentation:** https://docs.revenuecat.com/docs/flutter
2. **RevenueCat Support:** support@revenuecat.com
3. **RevenueCat Dashboard:** https://app.revenuecat.com/
4. **Apple IAP Guide:** https://developer.apple.com/in-app-purchase/

---

## ✅ Summary

**What Changed:**
1. ✅ Fixed package identifier bug (was using wrong field)
2. ✅ Added 3 fallback methods to find packages
3. ✅ Added comprehensive debug logging
4. ✅ Added detailed error explanations
5. ✅ Created diagnostic checklist

**Expected Result:**
- Trial purchase should work if RevenueCat is configured correctly
- Debug output will show EXACTLY what's wrong if it doesn't
- Three different methods ensure maximum compatibility

**Next Action:**
Run the app, attempt purchase, and send me the debug output! 🚀
