# CustomSubs Testing Checklist

**Status**: ✅ Complete
**Last Updated**: February 4, 2026
**Relevant to**: Testers

## Phase 5: Comprehensive Testing

This checklist covers all features, edge cases, and critical user flows in CustomSubs MVP.

---

## ✅ Pre-Testing Setup

- [ ] Run `flutter clean && flutter pub get`
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`
- [ ] Verify `flutter analyze` shows 0 issues
- [ ] Test on iOS Simulator (iPhone 14+ with iOS 16+)
- [ ] Test on Android emulator or LambdaTest (Android 13+)

---

## 1. Onboarding Flow

### First Launch
- [ ] App shows onboarding on first launch
- [ ] Logo displays correctly at top
- [ ] Welcome message shows: "Welcome to CustomSubs"
- [ ] All 3 feature cards display correctly:
  - [ ] "Track Everything" with dashboard icon
  - [ ] "Never Miss a Charge" with notification icon
  - [ ] "Cancel with Confidence" with exit icon
- [ ] Each feature card has icon, title, and description
- [ ] Staggered fade-in animations play smoothly (1200ms total)
- [ ] "Get Started" button displays prominently
- [ ] Privacy note displays: "🔒 100% offline • No account required"
- [ ] "Get Started" button triggers notification permission request
- [ ] Notification permission request appears (iOS/Android)
- [ ] Granting permission works
- [ ] Denying permission doesn't crash app
- [ ] Successfully navigates to home screen after onboarding
- [ ] Onboarding doesn't show again on subsequent launches
- [ ] `hasSeenOnboarding` flag persists in Hive

### Edge Cases
- [ ] Kill app during onboarding → restarts onboarding
- [ ] Screen scrolls properly on small devices (iPhone SE)
- [ ] Rotate device during onboarding → layout adjusts
- [ ] Animations don't lag or cause performance issues
- [ ] Works correctly on Android tablets and iPads

---

## 2. Home Screen (Empty State)

### Initial State
- [ ] Empty state displays when no subscriptions exist
- [ ] Illustration/icon shows
- [ ] Message: "No subscriptions yet" displays
- [ ] "Add Subscription" button is prominent and tappable
- [ ] Settings gear icon appears in app bar
- [ ] No crashes or errors

### Navigation
- [ ] "Add Subscription" button → Add Subscription screen
- [ ] Settings icon → Settings screen
- [ ] FAB (if visible) → Add Subscription screen

---

## 3. Add Subscription Screen

### Template Picker
- [ ] Template grid loads successfully
- [ ] 40+ templates display (Netflix, Spotify, etc.)
- [ ] Each template shows: name, icon/avatar, default price
- [ ] Search bar filters templates by name
- [ ] Search is case-insensitive
- [ ] Tapping template pre-fills form with template data
- [ ] "Create Custom" button shows empty form

### Form - Required Fields
- [ ] **Name** field is required (validation works)
- [ ] **Amount** field is required and numeric only
- [ ] **Amount** allows decimals (e.g., 15.99)
- [ ] **Currency** dropdown shows 30+ currencies
- [ ] **Currency** defaults to primary currency from settings
- [ ] **Billing Cycle** selector shows all 6 options (weekly → yearly)
- [ ] **Next Billing Date** date picker works
- [ ] **Category** picker shows all 11 categories

### Form - Optional Fields
- [ ] **Free Trial** toggle shows/hides trial fields
- [ ] **Trial End Date** picker appears when trial is ON
- [ ] **Post-Trial Amount** field appears when trial is ON
- [ ] **Color Picker** shows 12 color options
- [ ] **Cancellation URL** accepts text input
- [ ] **Cancellation Phone** accepts text input
- [ ] **Cancellation Notes** multiline text works
- [ ] **Cancellation Checklist** allows adding/removing steps
- [ ] **General Notes** multiline text works

### Reminders Section
- [ ] Expands/collapses smoothly
- [ ] First reminder dropdown: Off, 1, 2, 3, 5, 7, 10, 14 days
- [ ] Second reminder dropdown: same options
- [ ] "Remind on billing day" toggle works
- [ ] "Reminder time" time picker works (default 9:00 AM)

### Save Behavior
- [ ] "Save" button validates required fields
- [ ] Missing name → shows validation error
- [ ] Missing amount → shows validation error
- [ ] Amount = 0 or negative → shows validation error
- [ ] Valid form → saves subscription to Hive
- [ ] Navigates back to home screen after save
- [ ] New subscription appears in home list
- [ ] Notifications are scheduled after save

### Edge Cases
- [ ] Very long subscription name (50+ chars) → truncates properly
- [ ] Very large amount (e.g., $10,000) → displays correctly
- [ ] Amount with many decimals (e.g., 15.999999) → rounds properly
- [ ] Next billing date in past → accepts and auto-advances on next app open
- [ ] 10+ checklist items → scrolls properly
- [ ] Cancel (back button) → doesn't save subscription
- [ ] App killed during save → subscription may or may not exist (acceptable)

---

## 4. Home Screen (With Subscriptions)

### Spending Summary Card
- [ ] Large monthly total displays correctly
- [ ] Currency symbol is correct (based on primary currency)
- [ ] Active subscription count is accurate
- [ ] Multi-currency note appears if subs use different currencies
- [ ] Card has green gradient background

### Quick Actions
- [ ] "Add New" button → Add Subscription screen
- [ ] "Analytics" button → Analytics screen

### Upcoming Charges List
- [ ] Subscriptions sorted by next billing date (soonest first)
- [ ] Each tile shows:
  - [ ] Color dot + icon or first letter avatar
  - [ ] Subscription name
  - [ ] Amount + cycle (e.g., "$15.99/mo")
  - [ ] Days until billing: "in 3 days", "Tomorrow", "Today"
- [ ] "Paid" badge shows if marked paid
- [ ] Trial badge shows "Trial ends in X days" (yellow)
- [ ] Tapping tile → Subscription Detail screen

### Swipe Actions
- [ ] Swipe left reveals actions
- [ ] "Delete" action shows confirmation dialog
- [ ] Confirming delete removes subscription
- [ ] Canceling delete keeps subscription

### Attention Section (Conditional)
- [ ] Shows "Trials ending soon" if trials end within 7 days
- [ ] Shows trial subscriptions with warning
- [ ] Tapping trial → Subscription Detail screen

### Pull to Refresh
- [ ] Pull down gesture triggers refresh
- [ ] Recalculates totals
- [ ] Re-sorts subscriptions
- [ ] Animation is smooth

### Edge Cases
- [ ] 1 subscription → singular text "1 active subscription"
- [ ] 100+ subscriptions → list scrolls smoothly (60fps)
- [ ] All subscriptions marked paid → no unpaid items at top
- [ ] Today's date advances → overdue subscriptions show "Overdue"
- [ ] App opened after 30 days → past billing dates auto-advance

---

## 5. Subscription Detail Screen

### Header
- [ ] Subscription color as background accent
- [ ] Large icon or first-letter avatar
- [ ] Name displays prominently
- [ ] Amount + cycle below name
- [ ] Status badge: "Trial" (yellow), "Paid" (green) when applicable

### Quick Actions
- [ ] "Mark as Paid" button (full width) toggles paid status
- [ ] Marking paid → green checkmark appears on home
- [ ] "Edit" button (top bar) → Add/Edit screen with pre-filled data
- [ ] "Delete" button (top bar) shows confirmation dialog
- [ ] Confirming delete removes subscription and navigates back

### Billing Info Card
- [ ] Next billing date with countdown ("in 12 days")
- [ ] Billing cycle displayed
- [ ] Currency + amount shown
- [ ] Start date shown
- [ ] Trial info: "Trial ends [date] — then $X.XX/[cycle]" (if trial)

### Cancellation Manager Card
- [ ] Only shows if cancellation info exists
- [ ] "How to Cancel" header
- [ ] Cancellation URL → tappable, opens browser/webview
- [ ] Cancellation phone → tappable, opens phone dialer
- [ ] Cancellation notes displayed
- [ ] Interactive checklist with checkboxes
- [ ] Checking boxes persists state
- [ ] Progress indicator: "X of Y steps complete"

### Notes Card
- [ ] Shows general notes if they exist
- [ ] Long notes scroll properly

### Edge Cases
- [ ] Edit and save → changes reflected immediately
- [ ] Edit and cancel → no changes applied
- [ ] Delete → navigates back to home (doesn't crash)
- [ ] Mark paid repeatedly → toggles correctly
- [ ] Hero animation from home → detail is smooth

---

## 6. Analytics Screen

### Monthly Total Card
- [ ] Large monthly total in primary currency
- [ ] Active subscription count accurate
- [ ] Month-over-month change shows if previous snapshot exists
- [ ] Change indicator: Red arrow up for increase, Green arrow down for decrease
- [ ] First time opening → no MoM change (no previous month)
- [ ] Second month → MoM change calculates correctly

### Yearly Forecast Card
- [ ] Shows monthly total × 12
- [ ] Text: "At this rate, you'll spend $X,XXX this year"
- [ ] Updates when subscriptions change

### Category Breakdown Card
- [ ] Horizontal bar chart for each category
- [ ] Bars sorted by spend (highest first)
- [ ] Each bar shows:
  - [ ] Category icon/name
  - [ ] Amount in primary currency
  - [ ] Percentage (0-100%)
  - [ ] Subscription count
- [ ] Percentage labels: inside bar if wide enough, outside if narrow
- [ ] Gradient fill looks good
- [ ] Categories with $0 don't appear

### Top Subscriptions Card
- [ ] Shows top 5 most expensive (by monthly equivalent)
- [ ] Rank badges: Gold (#1), Silver (#2), Bronze (#3), Gray (#4-5)
- [ ] Each item shows: rank, name, monthly amount
- [ ] Tapping item → Subscription Detail screen
- [ ] Less than 5 subs → shows all available

### Currency Breakdown Card
- [ ] Only shows if user has multi-currency subscriptions
- [ ] Lists each currency with total (in that currency)
- [ ] No conversion applied here (raw totals)

### Monthly Snapshot
- [ ] First time opening analytics → creates snapshot for current month
- [ ] Opening again same month → doesn't create duplicate
- [ ] Opening next month → creates new snapshot
- [ ] Snapshots persist in Hive `monthly_snapshots` box

### Empty State
- [ ] Shows when no subscriptions exist
- [ ] Icon + message: "No subscription data yet"
- [ ] "Add your first subscription" button → Add Subscription screen

### Edge Cases
- [ ] All subscriptions in same category → 100% bar shows correctly
- [ ] 11 categories with data → all display, scrolls if needed
- [ ] Very large amounts (e.g., $50k/year) → formats properly
- [ ] Opening analytics rapidly → doesn't create duplicate snapshots
- [ ] Delete all subscriptions → analytics shows empty state

---

## 7. Settings Screen

### General Settings
- [ ] "Primary Currency" picker shows 30+ currencies
- [ ] Changing primary currency updates home totals immediately
- [ ] Currency persists after app restart

### Data Settings
- [ ] **Export Backup** button works
- [ ] Export generates JSON file with correct structure
- [ ] File named `customsubs_backup_YYYY-MM-DD.json`
- [ ] Share sheet appears (iOS: Activity, Android: Share)
- [ ] Can share to Files, AirDrop, email, etc.
- [ ] **Import Backup** button opens file picker
- [ ] Selecting valid JSON file imports subscriptions
- [ ] Confirmation dialog shows: "This will add X subscriptions"
- [ ] Duplicates are skipped (match by name + amount + cycle)
- [ ] After import, notifications are re-scheduled
- [ ] **Delete All Data** button shows double confirmation
- [ ] First confirm: "Are you sure?"
- [ ] Second confirm: "Type DELETE to confirm"
- [ ] Typing "DELETE" enables confirm button
- [ ] Confirming deletes all subscriptions and settings
- [ ] After delete, home shows empty state

### Notifications Settings
- [ ] **Test Notification** button fires immediate notification
- [ ] Test notification appears on device
- [ ] Test notification body: "Notifications are working! You'll be reminded before every charge."
- [ ] Informational text explains notifications

### About Section
- [ ] App version displays (e.g., "1.0.0+1")
- [ ] "Made with ♥ by Custom*" text shows
- [ ] Links are tappable (placeholders OK for now)

### Edge Cases
- [ ] Import backup with 100+ subscriptions → all imported correctly
- [ ] Import malformed JSON → shows error, doesn't crash
- [ ] Import empty JSON → shows "0 subscriptions found"
- [ ] Delete all data → confirm app works from empty state
- [ ] Change currency 10 times rapidly → no crashes

---

## 8. Notifications (CRITICAL)

**This is the #1 feature. Test thoroughly on real devices.**

### Setup
- [ ] Permissions requested on first launch
- [ ] Permissions can be granted/denied
- [ ] If denied, test notification still works in Settings

### Notification Scheduling
- [ ] Creating subscription schedules 3 notifications:
  - [ ] First reminder (default: 7 days before)
  - [ ] Second reminder (default: 1 day before)
  - [ ] Day-of reminder (default: morning of billing day)
- [ ] Editing subscription re-schedules all notifications
- [ ] Deleting subscription cancels all notifications
- [ ] Pausing subscription cancels notifications
- [ ] Resuming subscription re-schedules notifications

### Trial Notifications
- [ ] Trial subscription schedules 4 notifications:
  - [ ] 3 days before trial ends
  - [ ] 1 day before trial ends
  - [ ] Morning of trial end date
  - [ ] Regular billing notifications after trial
- [ ] Trial notifications fire correctly
- [ ] After trial ends, regular notifications continue

### Notification Content
- [ ] First reminder title: "📅 [Name] — Billing in [X] days"
- [ ] First reminder body: "$[amount]/[cycle] charges on [date]"
- [ ] Second reminder title: "⚠️ [Name] — Bills tomorrow"
- [ ] Day-of title: "💰 [Name] — Billing today"
- [ ] Trial ending title: "🔔 [Name] — Trial ending soon"
- [ ] Emoji icons appear correctly

### Notification Timing
- [ ] Notifications fire at correct time (default 9:00 AM)
- [ ] Changing reminder time updates future notifications
- [ ] Timezone changes handled correctly
- [ ] Device sleep doesn't prevent notifications

### Testing Methods
- [ ] **Test Notification** in Settings fires immediately
- [ ] Create subscription with billing date tomorrow → notification fires
- [ ] Create subscription with billing date in 2 minutes → notification fires
- [ ] Set phone date forward → notifications fire on schedule
- [ ] Reboot device → notifications still scheduled

### Edge Cases
- [ ] 20+ subscriptions → all notifications scheduled correctly
- [ ] Two subscriptions same day → both notifications fire
- [ ] Delete app data → notifications canceled (OS-level)
- [ ] Reinstall app → notifications reschedule on first data sync
- [ ] Notification dismissed → doesn't reschedule incorrectly

### iOS Specific
- [ ] Notifications appear in Notification Center
- [ ] Notifications appear on lock screen
- [ ] Notification sound plays (if not silenced)
- [ ] Tapping notification opens app (deep link optional)

### Android Specific
- [ ] Notification channel: "Subscription Reminders"
- [ ] Notifications appear in status bar
- [ ] Notifications grouped if multiple
- [ ] Tapping notification opens app

---

## 9. Multi-Currency Support

### Display
- [ ] Each subscription displays in its native currency
- [ ] Home total converts all to primary currency
- [ ] Analytics converts all to primary currency
- [ ] Currency symbols correct ($ £ € ¥ etc.)
- [ ] Exchange rates come from bundled JSON (not fetched)

### Calculations
- [ ] Monthly equivalents calculated correctly:
  - [ ] Weekly × 4.33
  - [ ] Biweekly × 2.167
  - [ ] Quarterly ÷ 3
  - [ ] Biannual ÷ 6
  - [ ] Yearly ÷ 12
- [ ] Conversions use bundled exchange rates
- [ ] Totals sum correctly across currencies

### Edge Cases
- [ ] All subs same currency → no conversion note
- [ ] Multi-currency → note shows on home
- [ ] Exotic currencies (e.g., VND, KRW) → large numbers format correctly
- [ ] Changing primary currency → all totals recalculate

---

## 10. Date Handling & Advancement

### Next Billing Date Auto-Advancement
- [ ] App opened day after billing date → auto-advances to next cycle
- [ ] Weekly sub advances 7 days
- [ ] Biweekly advances 14 days
- [ ] Monthly advances 1 month (e.g., Jan 15 → Feb 15)
- [ ] Quarterly advances 3 months
- [ ] Biannual advances 6 months
- [ ] Yearly advances 1 year
- [ ] Month-end dates handled correctly (e.g., Jan 31 → Feb 28)

### "Mark as Paid" Reset
- [ ] Marking paid sets `isPaid = true`
- [ ] When billing date advances, `isPaid` resets to `false`
- [ ] Paid status doesn't carry over to next cycle

### Edge Cases
- [ ] Subscription created with past date → advances immediately
- [ ] Billing date exactly today → shows "Today", doesn't advance until tomorrow
- [ ] App not opened for 3 months → all dates advance to current
- [ ] February 29 (leap year) → advances correctly to Feb 28 next year
- [ ] Daylight saving time changes → dates unaffected

---

## 11. Free Trial Mode

### UI
- [ ] Free Trial toggle shows trial fields
- [ ] Trial end date required when trial ON
- [ ] Post-trial amount required
- [ ] Trial badge shows on home: "Trial ends in X days" (yellow)

### Reminders
- [ ] Trial subscriptions get 4 notifications total
- [ ] 3 days before, 1 day before, day of trial end
- [ ] After trial ends, regular billing reminders start

### Detail Screen
- [ ] Trial info shows: "Trial ends [date] — then $X.XX/[cycle]"
- [ ] After trial ends, info updates to regular billing

### Edge Cases
- [ ] Trial ends today → shows "Trial ends today"
- [ ] Trial ended in past → switches to regular subscription
- [ ] Post-trial amount different from trial amount (e.g., $0 → $9.99)
- [ ] Editing trial → notifications re-schedule

---

## 12. Backup & Restore

### Export
- [ ] Export creates JSON file
- [ ] File structure correct:
  ```json
  {
    "app": "CustomSubs",
    "version": "1.0.0",
    "exportDate": "2026-02-04T12:00:00.000Z",
    "count": 5,
    "subscriptions": [...]
  }
  ```
- [ ] All subscription fields included
- [ ] Can view exported file (valid JSON)
- [ ] Date in filename: `customsubs_backup_2026-02-04.json`

### Import
- [ ] Import accepts `.json` files
- [ ] Valid backup imports successfully
- [ ] Confirmation shows subscription count
- [ ] Duplicates skipped (name + amount + cycle match)
- [ ] After import, home updates immediately
- [ ] Notifications re-scheduled for all imported subs

### Backup Reminder
- [ ] After adding 3rd subscription, one-time prompt appears
- [ ] Prompt: "Tip: You can back up your subscriptions..."
- [ ] Dismissing prompt → doesn't show again
- [ ] Prompt doesn't show if already backed up

### Settings Display
- [ ] Settings shows "Last backup: Never" if never backed up
- [ ] After first backup, shows "Last backup: [date]"
- [ ] Amber warning if never backed up

### Edge Cases
- [ ] Import same backup twice → second time skips all duplicates
- [ ] Import backup with 0 subscriptions → shows message
- [ ] Malformed JSON → error message, no crash
- [ ] Import backup from old version (future-proofing) → handles gracefully
- [ ] Export → uninstall → reinstall → import → all data restored

---

## 13. Cancellation Management

### Data Entry
- [ ] Cancellation URL saved correctly
- [ ] URL opens in browser when tapped
- [ ] Phone number opens dialer when tapped
- [ ] Notes display as plain text
- [ ] Checklist steps are reorderable (if implemented)

### Interactive Checklist
- [ ] Checkboxes toggle on/tap
- [ ] Progress persists (checked items stay checked)
- [ ] Progress indicator: "X of Y steps complete"
- [ ] All steps checked → 100% progress shows

### Edge Cases
- [ ] Very long URL → doesn't break layout
- [ ] Invalid URL → tapping shows error or opens anyway
- [ ] 20+ checklist steps → scrolls correctly
- [ ] No cancellation info → card doesn't appear
- [ ] Only URL (no notes/checklist) → card shows URL only

---

## 14. Performance & Polish

### Performance
- [ ] App launches in < 2 seconds
- [ ] Home screen renders immediately (< 1 second)
- [ ] List scrolling is 60fps (no jank)
- [ ] Page transitions are smooth
- [ ] No memory leaks (test with profiler)
- [ ] 100+ subscriptions → still performs well

### Animations
- [ ] Hero animation: home tile → detail screen
- [ ] Hero animation: detail screen → back to home
- [ ] Pull-to-refresh animation smooth
- [ ] Button press animations (subtle scale down)
- [ ] Onboarding fade-in animations smooth and staggered
- [ ] Analytics top subscription press animations work

### Responsiveness
- [ ] Works on small screens (iPhone SE)
- [ ] Works on large screens (iPad, though not optimized)
- [ ] Landscape orientation handled (if supported)
- [ ] Dynamic text size scaling works

### Edge Cases
- [ ] Rapid tapping → no duplicate actions
- [ ] Rapid navigation → no crashes
- [ ] Background → foreground → data persists
- [ ] Kill app during write → data may or may not save (acceptable)

---

## 15. Visual Design

### Typography
- [ ] DM Sans font loads correctly
- [ ] Headlines are bold
- [ ] Body text is regular/medium
- [ ] Currency amounts use proper formatting

### Colors
- [ ] Primary green (#16A34A) used consistently
- [ ] White cards on light background
- [ ] Borders are subtle (not heavy black lines)
- [ ] Category colors distinct and visible
- [ ] Subscription color picker shows 12 colors
- [ ] Status badges color-coded correctly

### Spacing
- [ ] Generous whitespace between elements
- [ ] Cards not crowded
- [ ] Touch targets are 48x48 minimum
- [ ] Padding consistent across screens

### Icons
- [ ] Material Icons load correctly
- [ ] Service icons from templates show correctly
- [ ] First-letter avatars show when no icon
- [ ] Status icons (emoji) appear in notifications

---

## 16. Accessibility

### Semantic Labels
- [ ] All buttons have labels
- [ ] All form fields have labels
- [ ] Screen reader can navigate all elements
- [ ] Color contrast ratios pass WCAG AA

### Touch Targets
- [ ] All interactive elements 48x48 minimum
- [ ] Buttons not too close together
- [ ] Swipe actions discoverable

### Text Scaling
- [ ] App works with large text sizes
- [ ] Layout doesn't break with 200% text scale

---

## 17. Platform-Specific Testing

### iOS
- [ ] Runs on iOS 16+
- [ ] Runs on iPhone SE, iPhone 14, iPhone 15 Pro Max
- [ ] Notifications work correctly
- [ ] File sharing via Activity sheet works
- [ ] Back swipe gesture works
- [ ] Status bar color correct
- [ ] Safe area insets respected

### Android
- [ ] Runs on Android 13+
- [ ] Runs on small, medium, large screens
- [ ] Notifications work correctly (channel setup)
- [ ] File sharing via Share sheet works
- [ ] Back button works correctly
- [ ] Material design guidelines followed
- [ ] Splash screen displays

---

## 18. Critical User Flows (End-to-End)

### Flow 1: New User
1. [ ] Launch app → sees onboarding
2. [ ] Complete onboarding → reaches home (empty)
3. [ ] Tap "Add Subscription" → sees template picker
4. [ ] Select "Netflix" → form pre-filled
5. [ ] Tap "Save" → returns to home
6. [ ] Netflix subscription visible on home
7. [ ] Notification scheduled (verify in Settings → Test Notification)

### Flow 2: Power User
1. [ ] Add 10+ subscriptions from templates
2. [ ] Add 2-3 custom subscriptions
3. [ ] Navigate to Analytics → sees breakdown
4. [ ] Verify MoM change (second month)
5. [ ] Export backup → file saved
6. [ ] Delete all data → home empty
7. [ ] Import backup → all subscriptions restored

### Flow 3: Trial Management
1. [ ] Add subscription with free trial
2. [ ] Set trial end date 3 days from now
3. [ ] Verify trial badge on home
4. [ ] Open detail → verify trial info
5. [ ] Wait for trial end (or advance device date)
6. [ ] Verify trial notifications fire
7. [ ] After trial ends, verify regular billing

### Flow 4: Cancellation
1. [ ] Add subscription (e.g., "Unused Gym")
2. [ ] Edit → add cancellation URL, phone, checklist
3. [ ] Open detail → see cancellation card
4. [ ] Tap URL → browser opens
5. [ ] Tap phone → dialer opens
6. [ ] Check off checklist items → progress updates
7. [ ] Delete subscription → removed from home

---

## 19. Stress Testing

### Data Volume
- [ ] 1 subscription → works
- [ ] 10 subscriptions → works
- [ ] 50 subscriptions → works
- [ ] 100 subscriptions → performance still good
- [ ] 200 subscriptions → (optional, stress test)

### Rapid Actions
- [ ] Add 10 subscriptions rapidly → all saved
- [ ] Delete 10 subscriptions rapidly → all deleted
- [ ] Toggle paid status 20 times → no issues
- [ ] Navigate rapidly between screens → no crashes

### Long Running
- [ ] Leave app open for 1 hour → no memory issues
- [ ] Background for 24 hours → data persists
- [ ] Reboot device → data persists
- [ ] Uninstall → reinstall → data gone (expected)

---

## 20. Final Checklist

### Pre-Release
- [ ] All critical features tested
- [ ] All edge cases covered
- [ ] Notifications verified on real devices
- [ ] Backup/restore verified
- [ ] Zero analysis warnings (`flutter analyze`)
- [ ] No console errors during testing
- [ ] Performance profiled (60fps)
- [ ] Memory profiled (no leaks)

### Documentation
- [ ] README updated with current status
- [ ] CLAUDE.md reflects completed phases
- [ ] Code comments are clear and helpful
- [ ] Future roadmap documented (if any)

### Ready for App Store?
- [ ] Privacy policy ready (placeholder OK)
- [ ] App Store screenshots prepared (Phase 6)
- [ ] App Store description written (Phase 6)
- [ ] Icons and assets finalized (Phase 6)
- [ ] Version 1.0.0 tagged in git

---

## Testing Notes

### Found Issues
- Document any bugs or issues found during testing here
- Track fixes and retest

### Performance Observations
- Document any performance bottlenecks
- Note frame rate drops or jank

### User Experience Notes
- Document any UX improvements needed
- Note confusing flows or unclear UI

---

**Testing Goal**: Zero crashes, smooth 60fps, reliable notifications, complete data safety.

**Priority**: Notifications > Data Safety > Core Features > Polish

---

## See Also

- [TEST_DATA_SCENARIOS.md](TEST_DATA_SCENARIOS.md) - Ready-to-use test data for all scenarios
- [READY_FOR_TESTING.md](READY_FOR_TESTING.md) - Testing quick start guide
- [guides/working-with-notifications.md](../guides/working-with-notifications.md) - Notification implementation details
- [architecture/overview.md](../architecture/overview.md) - System architecture reference
