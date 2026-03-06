# ✅ Ready to Archive - Version 1.1.6 Build 21

**Date:** February 22, 2026
**Status:** ✅ All preparation complete - Ready for Xcode Archive
**Version:** 1.8 (1.1.6+21)
**Previous Build:** 1.7 (1.1.5+20)

---

## ✅ Preparation Completed

**All steps completed successfully:**

1. ✅ **Full project clean**
   - Flutter clean completed
   - iOS build artifacts removed
   - Pods removed
   - Xcode Derived Data cleared

2. ✅ **Version bumped**
   - Version: 1.1.5+20 → **1.1.6+21**
   - Updated in `pubspec.yaml`

3. ✅ **Dependencies refreshed**
   - `flutter pub get` completed
   - 14 pods installed successfully
   - All dependencies up to date

4. ✅ **Code generation**
   - `build_runner` completed (81 outputs, 324 actions)
   - All Riverpod providers generated
   - All Hive TypeAdapters generated

5. ✅ **Xcode opened**
   - Workspace ready: `ios/Runner.xcworkspace`

---

## 🎯 Next Steps - Xcode Archive

### **⚠️ CRITICAL: Free Up RAM First**

**BEFORE archiving, you MUST free up system memory to avoid exit code -9 errors:**

1. **Close memory-intensive apps:**
   - ✅ Close ALL web browsers (Chrome, Safari, Firefox, Edge)
   - ✅ Quit Slack, Discord, Teams, or any chat apps
   - ✅ Quit Mail, Photos, or any large apps
   - ✅ Close any other development tools (VS Code, terminals, etc.)

2. **Verify available RAM:**
   - Open **Activity Monitor** (Applications → Utilities)
   - Click **Memory** tab
   - Check **Memory Pressure** graph at bottom
   - **MUST be GREEN** (not yellow or red)
   - If yellow/red: Close more apps until it's green
   - **Goal:** At least 4-5GB free RAM

3. **Why this matters:**
   - Release builds compile GPU shaders (memory-intensive)
   - macOS kills processes using too much RAM (exit code -9)
   - Archive process needs ~4GB peak memory
   - This is the #1 cause of archive failures

---

**In Xcode (after freeing RAM):**

### **Step 1: Select Target Device**
1. At the top toolbar, click the device dropdown (next to "Runner")
2. Select: **"Any iOS Device (arm64)"**
   - Do NOT select a simulator
   - Do NOT select a specific device
   - Must be "Any iOS Device" for App Store distribution

### **Step 2: Clean Build Folder**
1. Menu: **Product → Clean Build Folder** (⌘⇧K)
2. Wait for "Clean Finished" message (~5 seconds)

### **Step 3: Archive**
1. Menu: **Product → Archive**
2. **Do NOT touch your computer** during archive
3. Let it run uninterrupted for 3-5 minutes
4. Watch for "Archive succeeded" in Xcode
5. Organizer window will open automatically

### **Step 4: Distribute to App Store**
1. Organizer window opens automatically (or: Window → Organizer)
2. Select the newest archive (Build 21, today's date)
3. Click: **"Distribute App"**
4. Select: **"App Store Connect"**
5. Click: **"Next"**
6. Select: **"Upload"**
7. Click: **"Next"** through all remaining steps
8. Wait for upload to complete (~10-20 minutes)

---

## 📋 What Changed in This Version

### **Code Changes:**
- ✅ Paywall redesigned (price prominent per Apple Guideline 3.1.2)
- ✅ Trial messaging changed to subordinate position
- ✅ Button text updated to show price

### **Legal Compliance:**
- ✅ Privacy Policy URL added to App Store Connect
- ✅ Terms of Use link added to App Description
- ✅ All legal links functional

### **No Other Changes:**
- Core features unchanged
- RevenueCat integration unchanged
- Subscription offering unchanged ($0.99/month, 3-day trial)

---

## 📝 After Upload Completes

### **In App Store Connect:**

**Step 1: Create Version 1.8**
1. Go to: **App Store Connect → CustomSubs**
2. Click: **"+ Version or Platform"**
3. Enter version: **1.8**
4. Click: **"Create"**

**Step 2: Attach Build 21**
1. In version 1.8 page, scroll to: **"Build"**
2. Click: **"+ Add Build"** (or "Select a build before you submit")
3. Select: **Build 21** (1.1.6)
4. Click: **"Done"**

**Step 3: Attach Subscription**
1. Scroll to: **"In-App Purchases and Subscriptions"**
2. Click: **"+ Add"**
3. Search: `customsubs_premium_monthly`
4. Check the box next to it
5. Click: **"Done"**

**Step 4: Verify App Description has Legal Links**
1. Scroll to: **"Description"**
2. Confirm the following text is at the END:
   ```
   LEGAL

   Terms of Use: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
   Privacy Policy: https://customsubs.us/privacy
   ```
3. If not present, add it now
4. Click: **"Save"**

**Step 5: Add Review Notes**
1. Scroll to: **"App Review Information"**
2. Click: **"Notes"** field
3. Copy the contents from: `APP_STORE_REVIEW_NOTES_v1.8.md`
4. Paste into the Notes field
5. Click: **"Save"**

**Step 6: Submit for Review**
1. Scroll to top of version 1.8 page
2. Click: **"Add for Review"** or **"Submit for Review"**
3. Confirm all information is correct
4. Click: **"Submit"**

---

## 🎯 Review Notes Summary

**Copy this into App Store Connect Review Notes:**

See full notes in: `APP_STORE_REVIEW_NOTES_v1.8.md`

**Key points to include:**
- This is a resubmission addressing all 3 rejection issues
- Issue 1 (Legal links): ✅ Fixed - URLs added and functional
- Issue 2 (Paywall design): ✅ Fixed - Price now most prominent
- Issue 3 (IAP error): ✅ Resolved - Subscription properly configured
- Purchase flow testing instructions included
- Contact: bobby@customapps.us

---

## ⏰ Expected Timeline

**Archive & Upload:** ~15-30 minutes
- Archive: 3-5 minutes
- Upload: 10-20 minutes
- Processing: 5-10 minutes

**App Store Connect Setup:** ~15 minutes
- Create version 1.8: 2 minutes
- Attach build and subscription: 3 minutes
- Review notes: 5 minutes
- Submit: 2 minutes

**Apple Review:** 1-3 days
- Typical review time: 24-48 hours
- Resubmissions often faster

**Total:** ~30-45 minutes of your time, then wait for Apple

---

## 🚨 Common Archive Issues (and Fixes)

### **Issue 1: "Dart snapshot generator failed with exit code -9"**

**Cause:** Insufficient RAM, stale cache, or process killed by macOS

**Solution:**
1. Close Xcode completely
2. Run aggressive clean:
   ```bash
   flutter clean
   rm -rf ios/build ios/Pods ios/.symlinks ios/Podfile.lock
   rm -rf build .dart_tool
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   flutter pub get
   cd ios && pod install && cd ..
   flutter precache --ios
   ```
3. **Close ALL browsers and memory-intensive apps**
4. Check Activity Monitor - Memory Pressure must be GREEN
5. Reopen Xcode and try archive again

---

### **Issue 2: "ShaderCompilerException: Shader compilation failed with exit code -9"**

**Cause:** Insufficient RAM during GPU shader compilation (release builds only)

**Solution:**
1. **Close ALL browsers** (Chrome uses 2-4GB easily)
2. Quit Slack, Discord, Mail, Photos
3. Open Activity Monitor → Memory tab
4. Verify Memory Pressure is **GREEN**
5. Try archive again
6. **Do NOT touch computer** during archive

**Alternative Method (Command Line):**
```bash
# Close Xcode first
flutter build ios --release --no-codesign
```
Then in Xcode: Product → Archive (much faster since build is done)

---

### **Issue 3: Archive takes forever (>10 minutes)**

**Solution:**
- This is normal if RAM is low
- macOS swaps to disk (very slow)
- Close more apps to free RAM
- Or use command-line build method above

---

### **Issue 4: Can't select "Any iOS Device"**

**Solution:**
- Disconnect any connected iOS devices
- Restart Xcode
- Should now show "Any iOS Device (arm64)" option

---

### **Issue 5: Upload fails after successful archive**

**Solution:**
- Check internet connection
- Xcode → Preferences → Accounts → Download Manual Profiles
- Try uploading again from Organizer

---

## ✅ Success Indicators

**You'll know it worked when:**

1. ✅ **Archive succeeds** - "Archive succeeded" message in Xcode
2. ✅ **Organizer shows Build 21** - With today's date
3. ✅ **Upload completes** - "Upload Successful" dialog
4. ✅ **TestFlight shows Build 21** - In App Store Connect (after 10-20 min)
5. ✅ **Version 1.8 created** - With Build 21 attached
6. ✅ **Submission complete** - Status changes to "Waiting for Review"

---

## 📞 Need Help?

**If something goes wrong:**
1. Screenshot the error
2. Note what step you were on
3. Let me know and I'll guide you through it

**Common questions:**
- "Archive taking too long?" → Normal, can take 3-5 minutes
- "Upload stuck?" → Check Activity Monitor for Xcode network usage
- "Can't find Build 21?" → Wait 10-20 minutes after upload completes

---

## 🎉 Summary

**Status:** ✅ Ready to Archive
**Xcode:** ✅ Already open with workspace loaded
**Next action:** Select "Any iOS Device (arm64)" → Product → Archive

**After archive:** Upload to TestFlight → Create version 1.8 → Submit for review

**Review notes ready:** `APP_STORE_REVIEW_NOTES_v1.8.md`

---

**Good luck with the archive! 🚀**

**Once you submit, Apple typically reviews resubmissions within 24-48 hours.**
