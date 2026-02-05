# Test Data Scenarios for CustomSubs

**Status**: ✅ Complete
**Last Updated**: February 4, 2026
**Relevant to**: Testers

This document provides ready-to-use test data for comprehensive app testing. Use these scenarios during device testing to verify all features and edge cases.

---

## See Also

- [TESTING_CHECKLIST.md](TESTING_CHECKLIST.md) - Complete test checklist with 300+ cases
- [READY_FOR_TESTING.md](READY_FOR_TESTING.md) - Testing quick start guide
- [guides/multi-currency.md](../guides/multi-currency.md) - Multi-currency testing guidance

---

## Quick Test Scenarios

### Scenario 1: New User Experience (5 minutes)
**Purpose**: Test onboarding and first subscription

1. **Fresh Install**
   - Uninstall app (if installed)
   - Install from Xcode/Android Studio
   - Launch app

2. **Expected Flow**:
   - ✓ Onboarding appears (3 pages)
   - ✓ Notification permission requested
   - ✓ Home shows empty state

3. **Add First Subscription**:
   ```
   Template: Netflix
   Amount: $15.49
   Cycle: Monthly
   Next Billing: [Tomorrow's date]
   Category: Entertainment
   Reminders: Default (7 days, 1 day, day-of)
   ```

4. **Verify**:
   - ✓ Subscription appears on home
   - ✓ Monthly total shows $15.49
   - ✓ "Billing tomorrow" badge shows
   - ✓ Can open detail screen
   - ✓ Can mark as paid

---

### Scenario 2: Multi-Currency Power User (10 minutes)
**Purpose**: Test currency conversion and analytics

**Add these 5 subscriptions**:

1. **Netflix** (USD)
   - Amount: $15.49
   - Cycle: Monthly
   - Next Billing: 15 days from today
   - Category: Entertainment

2. **Spotify** (USD)
   - Amount: $10.99
   - Cycle: Monthly
   - Next Billing: 5 days from today
   - Category: Entertainment

3. **Amazon Prime** (GBP)
   - Amount: £8.99
   - Cycle: Monthly
   - Next Billing: 20 days from today
   - Category: Shopping

4. **iCloud+** (EUR)
   - Amount: €2.99
   - Cycle: Monthly
   - Next Billing: 10 days from today
   - Category: Cloud

5. **Disney+** (USD)
   - Amount: $13.99
   - Cycle: Monthly
   - Next Billing: 25 days from today
   - Category: Entertainment

**Verify**:
- ✓ Home shows converted total in primary currency
- ✓ Note appears: "Converted at bundled rates"
- ✓ Subscriptions sorted by billing date
- ✓ Analytics shows currency breakdown card
- ✓ Top subscriptions ranked correctly

---

### Scenario 3: Free Trial Testing (5 minutes)
**Purpose**: Test trial mode and trial notifications

**Add Trial Subscription**:
```
Custom Name: "YouTube Premium Trial"
Amount: $0.00
Cycle: Monthly
Trial Toggle: ON
Trial End Date: 3 days from today
Post-Trial Amount: $11.99
Category: Entertainment
Next Billing Date: [Trial end date]
```

**Verify**:
- ✓ Yellow trial badge on home: "Trial ends in 3 days"
- ✓ Detail screen shows trial info
- ✓ Test notification fires (Settings)
- ✓ After 3 days (advance device date): converts to regular billing

---

### Scenario 4: Cancellation Management (5 minutes)
**Purpose**: Test cancellation tools

**Add Subscription with Cancel Info**:
```
Template: Gym Membership (Custom)
Amount: $50.00
Cycle: Monthly
Next Billing: 10 days from today
Category: Fitness

Cancellation URL: https://example.com/cancel
Cancellation Phone: 1-800-555-0100
Cancellation Notes: "Call during business hours (M-F 9am-5pm)"

Cancellation Checklist:
1. Call customer service
2. Request cancellation
3. Get confirmation number
4. Verify email confirmation
```

**Verify**:
- ✓ Cancellation card shows on detail screen
- ✓ URL link opens browser
- ✓ Phone link opens dialer
- ✓ Notes display correctly
- ✓ Checklist is interactive
- ✓ Progress shows "0 of 4 complete"
- ✓ Checking items updates progress

---

### Scenario 5: Different Billing Cycles (10 minutes)
**Purpose**: Test all cycle types and calculations

**Add these subscriptions**:

1. **Weekly Meal Kit**
   - Amount: $75.00
   - Cycle: **Weekly**
   - Next Billing: 3 days from today
   - Monthly Equivalent: $75 × 4.33 = $324.75

2. **Biweekly House Cleaning**
   - Amount: $120.00
   - Cycle: **Biweekly**
   - Next Billing: 10 days from today
   - Monthly Equivalent: $120 × 2.167 = $260.04

3. **Quarterly Insurance**
   - Amount: $300.00
   - Cycle: **Quarterly**
   - Next Billing: 45 days from today
   - Monthly Equivalent: $300 ÷ 3 = $100.00

4. **Biannual Membership**
   - Amount: $120.00
   - Cycle: **Biannual**
   - Next Billing: 90 days from today
   - Monthly Equivalent: $120 ÷ 6 = $20.00

5. **Yearly Software License**
   - Amount: $240.00
   - Cycle: **Yearly**
   - Next Billing: 180 days from today
   - Monthly Equivalent: $240 ÷ 12 = $20.00

**Verify**:
- ✓ All cycles display correctly
- ✓ Home shows correct sort order (by date)
- ✓ Analytics converts to monthly equivalents
- ✓ Total monthly spend is sum of equivalents

---

### Scenario 6: Backup & Restore (10 minutes)
**Purpose**: Test data safety

**Setup**:
1. Add 10 subscriptions (use templates)
2. Go to Settings → Export Backup
3. Share to Files app (save locally)
4. Note the filename: `customsubs_backup_YYYY-MM-DD.json`

**Test Export**:
- ✓ Share sheet appears
- ✓ Can save to Files
- ✓ Can view file (valid JSON)
- ✓ File contains all subscriptions

**Test Import**:
1. Delete all subscriptions (Settings → Delete All Data)
2. Verify home shows empty state
3. Settings → Import Backup
4. Select the exported file
5. Confirm import dialog

**Verify**:
- ✓ All 10 subscriptions restored
- ✓ All data intact (amounts, dates, colors, notes)
- ✓ Notifications re-scheduled
- ✓ Analytics recalculated

---

## Edge Case Scenarios

### Edge Case 1: Month-End Date Handling
**Purpose**: Verify date advancement doesn't drift

**Add Subscription**:
```
Name: "Month-End Test"
Amount: $10.00
Cycle: Monthly
Next Billing Date: January 31, 2026
```

**Test**:
1. Advance device date to February 1, 2026
2. Open app
3. Verify auto-advancement

**Expected Result**:
- ✓ Next billing: February 28, 2026 (not Feb 1 or 2)
- ✓ March advancement: March 31, 2026
- ✓ Date stays at month-end

---

### Edge Case 2: Same-Day Multiple Subscriptions
**Purpose**: Test multiple charges same day

**Add 3 Subscriptions**:
```
1. Netflix - $15.49 - Next Billing: Tomorrow
2. Spotify - $10.99 - Next Billing: Tomorrow
3. Hulu - $14.99 - Next Billing: Tomorrow
```

**Verify**:
- ✓ All 3 show "Tomorrow" badge
- ✓ All 3 sorted alphabetically (same date)
- ✓ Total reflects all 3 ($41.47)
- ✓ 3 separate notifications scheduled

---

### Edge Case 3: Very Large Amount
**Purpose**: Test large number display

**Add Subscription**:
```
Name: "Expensive Software License"
Amount: $9,999.99
Cycle: Yearly
```

**Verify**:
- ✓ Amount displays with proper formatting
- ✓ No overflow or truncation
- ✓ Analytics handles large numbers
- ✓ Monthly equivalent: $833.33

---

### Edge Case 4: Zero/Free Trial
**Purpose**: Test $0 subscriptions

**Add Subscription**:
```
Name: "Free Tier"
Amount: $0.00
Cycle: Monthly
Trial: OFF
```

**Verify**:
- ✓ Displays "$0.00/mo"
- ✓ Included in count (active subscriptions)
- ✓ NOT included in monthly total
- ✓ Analytics excludes from spending

---

### Edge Case 5: Rapid Actions
**Purpose**: Test for race conditions

**Test Steps**:
1. Add subscription
2. Immediately open detail
3. Immediately mark paid
4. Immediately edit
5. Immediately delete

**Verify**:
- ✓ No crashes
- ✓ State updates correctly
- ✓ No duplicate entries
- ✓ Notifications properly managed

---

## Stress Test Scenarios

### Stress Test 1: 100 Subscriptions
**Purpose**: Test performance with large dataset

**Setup Method**:
1. Use templates to add 50 subscriptions quickly
2. Use custom entries for another 50
3. Vary billing dates (spread over 365 days)
4. Mix currencies (USD, EUR, GBP, JPY)

**Verify**:
- ✓ Home screen scrolls smoothly (60fps)
- ✓ Search/filter works
- ✓ Analytics calculates correctly
- ✓ Export/import handles all 100
- ✓ No performance degradation

---

### Stress Test 2: Long Subscription Names
**Purpose**: Test UI overflow

**Add Subscription**:
```
Name: "Super Ultra Premium Deluxe Enterprise Professional Business Subscription Service Plan Plus"
Amount: $99.99
Cycle: Monthly
```

**Verify**:
- ✓ Name truncates properly on home
- ✓ Full name shows on detail
- ✓ Notification title handles length
- ✓ No layout breaks

---

### Stress Test 3: Rapid Notifications
**Purpose**: Test notification system under load

**Add 20 Subscriptions**:
- All with billing date = 2 minutes from now
- Use different templates

**Verify**:
- ✓ All notifications schedule
- ✓ All notifications fire at correct time
- ✓ No duplicates
- ✓ Notification list doesn't overflow

---

## Notification Testing Scenarios

### Notification Test 1: Basic Reminder
**Setup**:
```
Name: "Test Notification"
Amount: $10.00
Next Billing: [Set to 2 minutes from now]
Reminders:
  - First: 1 day before (will skip, too late)
  - Second: 1 day before (will skip, too late)
  - Day-of: YES (should fire in 2 minutes)
Reminder Time: [Current time + 2 minutes]
```

**Verify**:
- ✓ Notification fires in 2 minutes
- ✓ Title: "💰 Test Notification — Billing today"
- ✓ Body: "$10.00/mo charge expected today"
- ✓ Tapping opens app

---

### Notification Test 2: Trial Ending
**Setup**:
```
Name: "Trial Test"
Amount: $0.00
Trial: ON
Trial End: [Set to 3 minutes from now]
Post-Trial: $9.99
Reminder Time: [Current time]
```

**Verify**:
- ✓ Notification fires in ~3 minutes
- ✓ Title contains "Trial ending soon"
- ✓ Body mentions trial end and post-trial charge

---

### Notification Test 3: Multiple Reminders
**Setup**:
```
Name: "Full Reminder Test"
Next Billing: 8 days from now
First Reminder: 7 days before → fires tomorrow
Second Reminder: 1 day before → fires in 7 days
Day-of: YES → fires in 8 days
Reminder Time: 9:00 AM
```

**Fast Forward Testing**:
- Advance device date to trigger each notification
- Verify content and timing for each

---

## Analytics Testing Scenarios

### Analytics Test 1: Month-Over-Month
**Purpose**: Test MoM comparison

**Month 1** (January 2026):
- Add 5 subscriptions totaling $100/month
- Open Analytics → creates January snapshot
- Total: $100/mo, MoM: "No previous data"

**Month 2** (February 2026):
- Advance device date to February 1
- Add 2 more subscriptions totaling $50/month
- Open Analytics → creates February snapshot
- Total: $150/mo, MoM: "↑ $50 from last month" (red)

**Month 3** (March 2026):
- Advance device date to March 1
- Delete 3 subscriptions totaling $60/month
- Open Analytics → creates March snapshot
- Total: $90/mo, MoM: "↓ $60 from last month" (green)

---

### Analytics Test 2: Category Breakdown
**Purpose**: Test category distribution

**Add subscriptions across all 11 categories**:
```
Entertainment: Netflix ($15), Spotify ($11), Disney+ ($14) = $40
Productivity: Notion ($10), Office 365 ($10) = $20
Fitness: Gym ($50) = $50
News: NYT ($20) = $20
Cloud: iCloud ($3) = $3
Gaming: Xbox ($15) = $15
Education: Coursera ($49) = $49
Finance: YNAB ($15) = $15
Shopping: Amazon Prime ($15) = $15
Utilities: Phone ($50) = $50
Health: Insurance ($200) = $200

Total: $487/mo
```

**Verify Analytics**:
- ✓ Category bars sorted by amount (Health first, Cloud last)
- ✓ Percentages sum to ~100%
- ✓ Each bar shows: amount, percentage, subscription count
- ✓ Bar widths proportional to spend

---

## Platform-Specific Scenarios

### iOS-Specific Test
**Setup**: iPhone 14 or newer, iOS 16+

1. **Notification Settings**:
   - System Settings → Notifications → Custom Subs
   - Verify: Alerts enabled, Sound enabled, Badges enabled

2. **File Sharing**:
   - Export backup → AirDrop to Mac
   - Export backup → Save to iCloud Drive
   - Export backup → Email to self

3. **Deep Press** (if 3D Touch available):
   - Long press subscription tile
   - Verify haptic feedback

---

### Android-Specific Test
**Setup**: Android 13+ device or emulator

1. **Notification Channel**:
   - System Settings → Apps → Custom Subs → Notifications
   - Verify: "Subscription Reminders" channel exists
   - Importance: High

2. **File Sharing**:
   - Export backup → Google Drive
   - Export backup → Gmail
   - Import from Downloads folder

3. **Back Navigation**:
   - Verify system back button works on all screens
   - Verify back button exits app from home

---

## Recommended Testing Order

### Day 1: Core Features (2 hours)
1. ✅ Scenario 1: New User Experience
2. ✅ Scenario 2: Multi-Currency
3. ✅ Scenario 3: Free Trial
4. ✅ Scenario 4: Cancellation
5. ✅ Scenario 5: Billing Cycles

### Day 2: Notifications (2-3 hours)
1. ✅ Notification Test 1: Basic Reminder
2. ✅ Notification Test 2: Trial Ending
3. ✅ Notification Test 3: Multiple Reminders
4. ✅ Real device testing (iPhone + Android via LambdaTest)

### Day 3: Edge Cases & Stress (1-2 hours)
1. ✅ All 5 Edge Case Scenarios
2. ✅ Stress Test 1: 100 Subscriptions
3. ✅ Scenario 6: Backup & Restore
4. ✅ Analytics Testing

---

## Quick Test Data Template

**For rapid testing, copy/paste these into the app**:

```
Name: Netflix
Amount: 15.49
Currency: USD
Cycle: Monthly
Category: Entertainment

Name: Spotify
Amount: 10.99
Currency: USD
Cycle: Monthly
Category: Entertainment

Name: Amazon Prime
Amount: 14.99
Currency: USD
Cycle: Monthly
Category: Shopping

Name: Gym Membership
Amount: 50.00
Currency: USD
Cycle: Monthly
Category: Fitness

Name: iCloud+
Amount: 2.99
Currency: USD
Cycle: Monthly
Category: Cloud
```

---

**Happy Testing! 🧪**

For questions or issues found during testing, document them with:
- Expected behavior
- Actual behavior
- Steps to reproduce
- Device/OS version
- Screenshots (if applicable)
