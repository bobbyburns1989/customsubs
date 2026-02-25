# RevenueCat Configuration Checklist

## The Problem
App Store reviewers see "Purchase failed: Unknown error" because RevenueCat isn't properly configured for sandbox testing.

## Quick Fix Steps (10 minutes)

### Step 1: Log Into RevenueCat Dashboard
1. Go to https://app.revenuecat.com
2. Select your CustomSubs project

### Step 2: Verify Offerings Configuration
1. Click **Offerings** in left sidebar
2. **CRITICAL**: There must be a "default" offering (or you must set a current offering)
3. Click on the offering to verify it contains a package
4. The package MUST include product ID: `customsubs_premium_monthly`

**If no offering exists:**
- Click "Create Offering"
- Name it "default" (lowercase)
- Mark as "Current Offering"
- Add a package with product: `customsubs_premium_monthly`

### Step 3: Verify Product Configuration
1. Click **Products** in left sidebar
2. Find: `customsubs_premium_monthly`
3. Verify:
   - ✅ Product ID exactly matches: `customsubs_premium_monthly`
   - ✅ Platform: iOS (or both iOS and Android)
   - ✅ Type: Subscription

**If product doesn't exist:**
- Click "Add Product"
- Enter Product ID: `customsubs_premium_monthly`
- Select Platform: iOS
- Select Type: Subscription

### Step 4: Verify App Store Configuration
1. Click **Settings** → **Apps**
2. Select your iOS app
3. Verify:
   - ✅ Bundle ID matches Xcode (e.g., com.bobbyburns.customsubs)
   - ✅ App Store Shared Secret is filled in
   - ✅ App Store Connect is linked

**To get Shared Secret:**
- Go to App Store Connect → Your App → In-App Purchases
- Click "App-Specific Shared Secret"
- Copy the key
- Paste into RevenueCat dashboard

### Step 5: Verify API Key Matches Code
1. In RevenueCat: Settings → API Keys
2. Copy the **Public SDK Key** (starts with `app1_` or similar)
3. Check your code has this exact key

**Check in terminal:**
```bash
grep -r "app1_" lib/
```

Should show the key in: `lib/core/constants/revenue_cat_constants.dart`

If the keys don't match, update the code to match the dashboard key.

### Step 6: Test in Sandbox (Required Before Submitting)

**Create Sandbox Tester:**
1. App Store Connect → Users and Access → Sandbox Testers
2. Click "+" to create new tester
3. Use a fake email (e.g., test@example.com) - NOT a real iCloud account
4. Save the credentials

**Test on Real Device:**
1. On your iPhone/iPad: Settings → App Store → Sign Out
2. Build and run app from Xcode (or install TestFlight build)
3. Open app → Tap Premium upgrade
4. Tap "Subscribe for $0.99/month"
5. When App Store prompts, sign in with your sandbox tester account
6. Purchase should complete successfully
7. Check Xcode console for any errors

**If purchase succeeds in sandbox → RevenueCat is configured correctly ✅**

## Common Errors & Fixes

| Error Message | Cause | Fix |
|---------------|-------|-----|
| "No offering available" | No "default" offering exists | Create "default" offering in RevenueCat |
| "Product not found" | Product ID mismatch | Verify `customsubs_premium_monthly` in all 3 places |
| "Invalid API key" | Wrong key in code | Copy key from RevenueCat → Update code |
| "Not entitled" | Entitlement not configured | Check entitlement ID matches code |
| "Sandbox error" | Not using sandbox account | Sign out of App Store, use sandbox tester |

## Verification Checklist

Before submitting to App Store:

- [ ] "default" offering exists in RevenueCat dashboard
- [ ] Product `customsubs_premium_monthly` is in the offering
- [ ] App Store Shared Secret is configured
- [ ] API key in code matches RevenueCat dashboard
- [ ] Tested purchase on real device with sandbox account
- [ ] Purchase completed successfully (no error)
- [ ] Premium features unlocked after purchase

**If all checkboxes are ✅ → Ready to submit to App Store**

## Emergency Contact

If you're stuck:
- RevenueCat Support: https://app.revenuecat.com/settings/support
- RevenueCat Community: https://community.revenuecat.com
- Documentation: https://docs.revenuecat.com

---

**Next Step After Fixing RevenueCat:**
Run the clean/build/archive process and submit to App Store Connect.
