# App Store Review Notes - Version 1.8 (Build 21)

**App Name:** CustomSubs
**Bundle ID:** com.customsubs.app
**Version:** 1.8 (1.1.6+21)
**Submission Date:** February 22, 2026
**Previous Rejection:** Version 1.7 (Build 20) - February 22, 2026

---

## 📋 Resubmission Summary

This is a **resubmission** of CustomSubs addressing all 3 issues identified in the rejection of Version 1.7 (Build 20).

**Rejection ID:** 9b3bf918-6774-4e4e-9255-7b4fe4de17df

---

## ✅ Issues Resolved

### **Issue 1: Missing Legal Links** ✅ FIXED

**Original Issue:**
- Guideline 3.1.2 - Business - Payments - Subscriptions
- Missing functional Privacy Policy and Terms of Use links

**Resolution:**
- ✅ **Privacy Policy URL added** in App Information section
- ✅ **Terms of Use link added** to App Description
- ✅ **Privacy Policy link added** to App Description
- ✅ Both links are functional and accessible

**Links Added:**
- Privacy Policy: https://customsubs.us/privacy
- Terms of Use: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

---

### **Issue 2: Paywall Design Violation** ✅ FIXED

**Original Issue:**
- Guideline 3.1.2 - Business - Payments - Subscriptions
- "The auto-renewable subscription promotes the free trial more clearly and conspicuously than the billed amount."

**What Was Wrong:**
- "3-Day Free Trial" was displayed too prominently (large green bordered box)
- "$0.99/month" price was subordinate (small gray text)
- Primary CTA button emphasized trial over price ("Start 3-Day Free Trial")

**Resolution Applied:**
- ✅ **Price is now MOST prominent:**
  - Large "$0.99/month" in 36px bold font
  - Displayed in green-bordered container with primary color
  - First element user sees after app icon
- ✅ **Trial is now subordinate:**
  - Small "Includes 3-day free trial" in 14px gray text
  - Positioned below price as supplementary information
- ✅ **Button text updated:**
  - Changed from "Start 3-Day Free Trial"
  - Now reads "Subscribe for $0.99/month"
- ✅ **Removed competing elements:**
  - Deleted large green "3-Day Free Trial" feature box
  - Eliminated visual competition between price and trial messaging

**File Modified:** `lib/features/paywall/paywall_screen.dart`

---

### **Issue 3: IAP Purchase Failed** ✅ RESOLVED

**Original Issue:**
- Guideline 2.1 - Performance - App Completeness
- "We received an error on IAP"
- Purchase failed with unknown error

**Root Cause:**
- Subscription status was "Waiting for Review" during initial submission
- Apple reviewer attempted purchase before subscription was approved
- RevenueCat could not complete transaction due to pending subscription status

**Resolution:**
- ✅ **Subscription is now "Ready to Submit"** (attached to app version)
- ✅ Purchase flow will work correctly once subscription is approved alongside app
- ✅ Subscription has been properly configured in App Store Connect:
  - Product ID: `customsubs_premium_monthly`
  - Subscription Group: Premium (ID: 21943395)
  - Price: $0.99/month
  - Free Trial: 3 days
  - Localization: English (U.S.) with review screenshot
  - Family Sharing: Enabled

**Expected Behavior:**
- Subscription and app version will be approved together
- Purchase flow will function correctly in production
- No additional changes required

---

## 🎯 What's New in This Build

**Version 1.8 (Build 21) includes:**

1. **Redesigned Paywall Screen**
   - Price-prominent layout per Apple guidelines
   - Trial information displayed as subordinate
   - Clear subscription terms and pricing

2. **Legal Compliance**
   - Privacy Policy and Terms of Use links added
   - Accessible from App Description and Settings screen

3. **No Functional Changes**
   - Core app features remain unchanged from v1.7
   - Same subscription offering ($0.99/month with 3-day trial)
   - All existing features working as tested in v1.7

---

## 📱 App Overview (For Context)

**CustomSubs** is a privacy-first subscription tracker that helps users manage recurring subscriptions without bank linking or account creation. All data is stored locally on the device.

**Core Features:**
- Manual subscription tracking with billing reminders
- Local notifications (7-day, 1-day, and day-of reminders)
- Analytics and spending insights
- Cancellation assistance tools
- Backup/restore (JSON export to device)

**Monetization:**
- Free tier: Up to 5 subscriptions
- Premium ($0.99/month): Unlimited subscriptions
- RevenueCat integration for cross-platform subscription management
- 3-day free trial for new subscribers

---

## 🧪 Testing the IAP Purchase Flow

**To verify the subscription works during review:**

1. **Access Paywall:**
   - Launch app → Add 6th subscription
   - Or: Settings → Premium section → "Upgrade to Premium"

2. **Expected Paywall Display:**
   - ✅ "$0.99/month" displayed prominently (large, bold, green-bordered box)
   - ✅ "Includes 3-day free trial" shown as subordinate text (small, gray)
   - ✅ Button reads "Subscribe for $0.99/month"
   - ✅ Features list: unlimited subscriptions, notifications, analytics, backups

3. **Expected Purchase Flow:**
   - Tap "Subscribe for $0.99/month" button
   - Apple purchase sheet appears
   - Shows: "$0.99 for 1 month" with "3 days free" trial notation
   - Sandbox account completes purchase successfully
   - User returns to app with "Premium" badge visible

4. **Post-Purchase Verification:**
   - Home screen shows "Premium" badge next to subscription count
   - Settings shows "Current Tier: Premium"
   - User can now add unlimited subscriptions (no 5-subscription limit)

**Sandbox Test Account:**
- Not required - use your standard App Review sandbox account
- Purchase will use sandbox environment automatically

---

## 📝 Additional Review Notes

### **Why This App is Different:**
CustomSubs competes with "Bobby" (iOS-only subscription tracker by Yummygum). Our advantages:
- **Reliability:** Bobby has widespread notification failures - we have comprehensive notification testing
- **Cross-platform:** Flutter app will support both iOS and Android
- **Active development:** Bobby's developer is absent - we provide regular updates
- **Data safety:** Full backup/restore system prevents data loss on reinstall

### **Privacy & Permissions:**
- ✅ **No account required** - completely offline app
- ✅ **No network calls** - all data stored in local Hive database
- ✅ **No tracking** - zero analytics or third-party SDKs (except RevenueCat for IAP)
- ✅ **Minimal permissions:**
  - Notifications (required for billing reminders - core feature)
  - File access (optional, for backup export/import)

### **RevenueCat Integration:**
- Used solely for cross-platform subscription management
- No user data sent to RevenueCat beyond Apple-provided purchase data
- Premium entitlement checked locally after purchase
- SDK configured with App Store Connect credentials

### **Legal Compliance:**
- Privacy Policy: Hosted at https://customsubs.us/privacy
- Terms of Service: Apple Standard EULA
- GDPR/CCPA compliant (no data collection)
- Contact: bobby@customapps.us
- Company: CustomApps LLC, Boston, MA

---

## ✅ Pre-Submission Checklist

Before submitting, verify:

- [x] Privacy Policy URL added to App Information
- [x] Terms of Use and Privacy Policy links in App Description
- [x] Paywall redesigned (price prominent, trial subordinate)
- [x] Subscription attached to app version (In-App Purchases and Subscriptions)
- [x] Build 21 uploaded to TestFlight
- [x] Version 1.8 created in App Store Connect
- [x] Subscription status: Ready to Submit
- [x] All legal links functional and accessible

---

## 📞 Contact Information

**Developer:** Bobby Burns
**Email:** bobby@customapps.us
**Company:** CustomApps LLC
**Location:** Boston, Massachusetts, USA

**Support URL:** https://customsubs.us/support
**Privacy Policy:** https://customsubs.us/privacy

---

## 🙏 Thank You

Thank you for reviewing CustomSubs. We've carefully addressed all 3 issues from the previous rejection:

1. ✅ Legal links added and functional
2. ✅ Paywall redesigned to comply with Guideline 3.1.2 (price prominence)
3. ✅ Subscription properly configured and ready for approval

We appreciate your time and feedback in helping us deliver a high-quality, compliant app to users.

---

**Submission Ready:** ✅
**Build:** 21
**Version:** 1.8
**Date:** February 22, 2026
