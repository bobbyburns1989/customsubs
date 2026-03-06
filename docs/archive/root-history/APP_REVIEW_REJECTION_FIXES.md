# 🔴 App Review Rejection - Fixes Required

**Date:** 2026-02-22
**Version Rejected:** 1.7 (1.1.5+20)
**Submission ID:** 9b3bf918-6774-4e4e-9255-7b4fe4de17df
**Next Version:** 1.8 (1.1.6+21)

---

## 📋 **3 Issues to Fix**

### **Issue 1: Missing Legal Links** ⚠️ (EASY - 5 minutes)
**Guideline:** 3.1.2 - Business - Payments - Subscriptions

**What Apple Wants:**
- Functional link to Terms of Use (EULA)
- Functional link to Privacy Policy

---

### **Issue 2: Paywall Design Violation** ⚠️ (FIXED IN CODE)
**Guideline:** 3.1.2 - Business - Payments - Subscriptions

**Problem:**
> "The auto-renewable subscription promotes the free trial more clearly and conspicuously than the billed amount."

**What Was Wrong:**
- "3-Day Free Trial" was TOO PROMINENT (large green box)
- "$0.99/month" was subordinate (small gray text)

**Fix Applied:** ✅ Code updated
- Price now MOST prominent: Large "$0.99/month" in bordered box
- Trial now subordinate: Small "Includes 3-day free trial" text
- Button changed: "Subscribe for $0.99/month" (not "Start 3-Day Free Trial")

---

### **Issue 3: IAP Purchase Failed** ⚠️ (WAITING FOR APPROVAL)
**Guideline:** 2.1 - Performance - App Completeness

**Problem:**
> "We received an error on IAP"

**Root Cause:** Subscription status is "Waiting for Review"
- Apple reviewer tried to purchase
- Subscription not approved yet
- Purchase failed with "Unknown error"

**Fix:** Will resolve automatically when subscription is approved

---

## ✅ **What I Fixed (Code Changes)**

### **File Modified:** `lib/features/paywall/paywall_screen.dart`

**Changes Made:**

1. **Price Box - Now MOST Prominent:**
```dart
// Large bordered box with primary color
Container(
  // Green border, larger padding
  child: Text(
    '\$0.99/month',  // 36px font, bold, primary color
    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
  ),
)
```

2. **Trial - Now Subordinate:**
```dart
// Small gray text below price
Text(
  'Includes 3-day free trial',  // 14px font, gray color
  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
)
```

3. **Removed Large Trial Box:**
- Deleted the green-bordered "3-Day Free Trial" feature box
- Was competing for attention with price

4. **Button Text Changed:**
```dart
// Before: 'Start 3-Day Free Trial'
// After:  'Subscribe for $0.99/month'
```

**Result:** Price is now clearly the most prominent element ✅

---

## 🎯 **What YOU Need to Do**

### **Step 1: Add Legal Links to App Store Connect** 🔴 CRITICAL

#### **Privacy Policy URL:**

1. **Go to:** App Store Connect → CustomSubs → App Information
2. **Find:** Privacy Policy URL field
3. **Option A - Use Your Domain (BEST):**
   - **Enter:** `https://customsubs.us/privacy`
   - **Action Required:** Host the PRIVACY_POLICY.md file at this URL
   - **How:** Upload to your website or use GitHub Pages

4. **Option B - Use Placeholder (TEMPORARY):**
   - **Enter:** `https://pages.github.com/bobbyburns1989/customsubs/privacy`
   - **Note:** GitHub Pages link (if you have it)

5. **Option C - Use Standard Apple Terms (EASIEST):**
   - Leave blank and use Apple's standard privacy policy
   - **BUT ALSO:** Add this line to App Description (see Step 2)

#### **Terms of Use (EULA):**

1. **Go to:** App Store Connect → CustomSubs 1.8 → App Information
2. **Option A - Add to App Description:**
   - Scroll to **App Description** field
   - Add this AT THE END:
   ```
   Terms of Use: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
   Privacy Policy: https://customsubs.us/privacy
   ```

3. **Option B - Upload Custom EULA:**
   - Find **"Custom EULA"** section
   - Upload TERMS_OF_SERVICE.md file
   - **Format:** Plain text or PDF

---

### **Step 2: Update App Description** (5 minutes)

1. **Go to:** App Store Connect → CustomSubs 1.8 → Version Information
2. **Scroll to:** App Description field
3. **Add to the END:**

```
LEGAL

Terms of Use: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
Privacy Policy: https://customsubs.us/privacy

SUPPORT

For help or questions: bobby@customapps.us
```

4. **Click:** Save

---

### **Step 3: Host Privacy Policy** (Optional but Recommended)

**If you own customsubs.us domain:**

1. **Create:** `privacy.html` file from PRIVACY_POLICY.md
2. **Upload to:** Your web hosting at customsubs.us/privacy
3. **Test:** Visit https://customsubs.us/privacy in browser
4. **Verify:** Page loads correctly

**If you don't have hosting yet:**
- **Quick fix:** Use Apple's standard privacy terms
- **Or:** Use GitHub Pages (free)
- **Or:** Use a service like PrivacyPolicies.com

---

### **Step 4: Create New Version 1.8** (After I build)

1. **Wait for me to:** Build version 1.1.6+21 with fixed paywall
2. **Then in App Store Connect:**
   - Create **new version: 1.8**
   - Upload Build 21
   - Add subscription to "In-App Purchases and Subscriptions"
   - Add Privacy Policy URL
   - Update App Description with legal links
   - Submit for review

---

## 📊 **Checklist Before Resubmission**

### **App Store Connect:**
- [ ] Privacy Policy URL added (App Information)
- [ ] Terms of Use link in App Description (or Custom EULA uploaded)
- [ ] New version 1.8 created
- [ ] Build 21 uploaded and attached
- [ ] Subscription attached to version
- [ ] Legal links functional (test URLs)

### **Code (I'll Do This):**
- [x] Paywall redesigned (price most prominent)
- [x] Trial subordinate (smaller, less emphasis)
- [x] Button text changed to show price
- [ ] Build new version 1.1.6+21
- [ ] Archive and upload to TestFlight

### **Testing:**
- [ ] Test paywall displays correctly
- [ ] Test purchase flow (after subscription approved)
- [ ] Verify legal links work

---

## 🚨 **Common Mistakes to Avoid**

### **❌ Don't Do This:**
1. Don't use broken/placeholder URLs
2. Don't forget to test privacy policy link
3. Don't submit without legal links
4. Don't use same build number (must be 21, not 20)

### **✅ Do This:**
1. Use working, live URLs
2. Test all links before submitting
3. Add links to BOTH Privacy Policy field AND App Description
4. Create new version number (1.8)

---

## 📝 **Quick Copy-Paste**

### **For App Description (add at end):**
```
LEGAL
Terms of Use: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
Privacy Policy: https://customsubs.us/privacy
```

### **For Privacy Policy URL Field:**
```
https://customsubs.us/privacy
```

*Note: Replace with actual URL once hosted*

---

## ⏰ **Timeline**

### **Today (Your Tasks):**
1. Add Privacy Policy URL to App Store Connect (5 min)
2. Add legal links to App Description (2 min)
3. Host privacy policy if possible (or use Apple's) (15 min)
4. Total: ~20 minutes

### **Today (My Tasks):**
1. Build new version 1.1.6+21 (5 min)
2. Test paywall design (5 min)
3. Archive in Xcode (5 min)
4. Upload to TestFlight (10 min)
5. Total: ~25 minutes

### **After Upload:**
1. You: Create version 1.8 in App Store Connect (10 min)
2. You: Attach Build 21 and subscription (5 min)
3. You: Submit for review (2 min)
4. Apple: Process review (1-3 days)

---

## 🎯 **Expected Outcome**

### **After Fixes:**
✅ Legal links: Compliant
✅ Paywall design: Price-prominent (Apple compliant)
✅ Purchase: Will work once subscription approved

### **Apple Will See:**
1. Functional Privacy Policy URL ✅
2. Terms of Use link in description ✅
3. Price ($0.99/month) as most prominent element ✅
4. Trial (3-day) as subordinate element ✅
5. Button showing price, not just trial ✅

---

## 📞 **Need Help?**

**If stuck:**
1. Screenshot the issue
2. Tell me what step you're on
3. I'll guide you through it

**Common questions:**
- "Don't have customsubs.us hosting?" → Use Apple's standard EULA for now
- "Can't upload privacy policy?" → Link to GitHub or use placeholder
- "What if subscription still pending?" → It will auto-approve with app approval

---

## ✅ **Summary**

**My Job (Code):** ✅ DONE
- Fixed paywall design (price prominent)
- Removed trial emphasis
- Changed button text
- Ready to build version 1.1.6+21

**Your Job (App Store Connect):** ⏳ TO DO
- Add Privacy Policy URL
- Add legal links to App Description
- Create version 1.8
- Attach Build 21
- Resubmit

**Time Required:** ~20 minutes of your time + build/upload time

---

**Once you've added the legal links, let me know and I'll build version 1.1.6! 🚀**
