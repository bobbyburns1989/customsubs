# ⚠️ URGENT: Action Required Before Resubmission

## App Store Review Rejection - Immediate Actions

### 🚨 CRITICAL - Do This FIRST (Blocks Resubmission)

**Upload Terms and Privacy Pages to Your Website**

The 404 error screenshot shows that these URLs don't exist:
- ❌ https://customsubs.us/terms (404 Not Found)
- ❌ https://customsubs.us/privacy (404 Not Found)

**What to do:**
1. Convert `TERMS_OF_SERVICE.md` to HTML
2. Convert `PRIVACY_POLICY.md` to HTML
3. Upload to your web server at customsubs.us
4. Test URLs in browser - both must work!

**If you don't have web hosting:**
- Use GitHub Pages (free)
- Use Netlify (free)
- Or temporarily use Apple's standard EULA: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

---

### 🔧 IMPORTANT - Fix RevenueCat Configuration

The "Purchase failed: Unknown error" means RevenueCat isn't configured for sandbox testing.

**Quick Check:**
1. Log into RevenueCat: https://app.revenuecat.com
2. Go to Offerings → Check "default" offering exists
3. Verify product `customsubs_premium_monthly` is in the offering
4. Go to Settings → API Keys → Copy public key
5. Verify key in code matches dashboard

**Full instructions:** See `APP_STORE_REVIEW_FIX_v1.7.md`

---

### ✅ Already Fixed in Code

- Added Terms of Use link to paywall screen
- Added Privacy Policy link to paywall screen
- Build number incremented to 24

---

## Quick Resubmission Steps

1. **Upload terms/privacy to customsubs.us** ⚠️ MUST DO FIRST
2. Fix RevenueCat config (see APP_STORE_REVIEW_FIX_v1.7.md)
3. Test purchase in sandbox on real device
4. Run: `flutter clean && flutter pub get && cd ios && pod install`
5. Archive in Xcode
6. Submit to App Store Connect
7. Reply to Apple's review message

---

**Read full details:** `APP_STORE_REVIEW_FIX_v1.7.md`
