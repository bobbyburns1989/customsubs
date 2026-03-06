# Feature Specifications — v1.0 (All Complete)

**Status**: ✅ All implemented as of v1.4.0
**Archived from**: CLAUDE.md (March 2026)

These are the original design specs. The source of truth for current behavior is the source code.

---

## 1. Onboarding (first launch only)

Single-screen onboarding with all content visible at once.

**Layout:**
- Header: CustomSubs logo (centered), "Welcome to CustomSubs", "Your private subscription tracker"
- 3 feature cards:
  - "Track Everything" — "All your subscriptions in one place. No bank linking. No login."
  - "Never Miss a Charge" — "Get notified 7 days before, 1 day before, and the morning of every billing date."
  - "Cancel with Confidence" — "Step-by-step guides to cancel any subscription quickly."
- CTA: "Get Started" button (primary green) + "🔒 100% offline • No account required"

**Animations:** Staggered fade-in, 1200ms total, 150ms offset per element.

**Behavior:**
- Store `hasSeenOnboarding` bool in Hive settings box — skip on subsequent launches
- On "Get Started": request notification permissions (iOS + Android 13+) → navigate to Home

---

## 2. Home Screen

Three sections always shown:

**Spending Summary Card:**
- Large monthly total in primary currency: "$274.50 /month"
- "X active subscriptions"
- Multi-currency note if applicable: "≈ $274.50 at bundled rates"
- Subtle green gradient background

**Quick Actions:** "Add New" (primary) + "Analytics" (outlined)

**Upcoming (0–30 days):** Active subs sorted by billing date. Each tile:
- Color dot + brand icon (or letter avatar)
- Name, amount/cycle
- Days until billing: "in 3 days", "Tomorrow", "Today", "Overdue"
- "Paid" badge (green) if marked paid
- "Trial ends in X days" badge (amber) if trial
- Tap → Detail screen; swipe left → Delete

**Later (31–90 days):** Muted tile style, absolute date format, no swipe actions.

**Paused:** Tiles showing pause date + resume date. Swipe → Resume.

**Attention (conditional):** Trials ending ≤7 days; possibly unused (no paid mark in 60+ days).

**Empty state:** "No subscriptions yet. Tap + to add your first one."

---

## 3. Add Subscription Screen

Two paths: template picker or custom form.

**Template Picker:** Search bar + 2-column grid. Each card: icon, name, price, cycle. Tap → pre-fills form.

**Form — Required fields:**
- Name, Amount, Currency (30+ supported), Billing Cycle, Next Billing Date, Category

**Form — Optional fields:**
- Free Trial toggle (reveals: trial end date, post-trial amount)
- Color picker (12–16 preset colors)
- Cancel URL, Cancel phone, Cancel notes
- Cancellation checklist (dynamic, reorderable steps)
- General notes

**Reminders section (expandable):**
- First reminder: Off/1/2/3/5/7/10/14 days before (default: 7)
- Second reminder: same options (default: 1)
- Remind on billing day toggle (default: ON)
- Reminder time picker (default: 9:00 AM)

**Save:** Validates → saves to Hive → schedules notifications → navigates back.

---

## 4. Subscription Detail Screen

**Header:** Subscription color accent + large icon + name/amount/cycle + status badges (Trial amber, Paid green).

**Quick Actions:**
- "Mark as Paid" — toggles paid status for current cycle
- "Edit" → form in edit mode
- "Delete" → confirmation dialog

**Billing Info Card:** Next billing date (countdown), cycle, currency, start date, trial info.

**Cancellation Manager Card** (only if any cancel info exists):
- "Open Cancellation Page" button (url_launcher)
- Tappable phone number (phone dialer)
- Cancel notes text
- Interactive checklist with "X of Y steps complete" progress

**Notes Card:** Shows general notes if set.

**Danger Zone:** "Delete Subscription" — red, confirmation: "This will remove [Name] and cancel all reminders. This cannot be undone."

---

## 5. Analytics Screen

**Yearly Forecast (hero):** "At this rate, you'll spend $X,XXX this year" + "That's $X.XX per day" — green gradient card at top.

**Category Breakdown:** Horizontal bars, sorted highest→lowest, with %, total per category.

**Top Subscriptions:** Ranked top 5 by monthly equivalent; tappable.

**Currency Breakdown:** Total per currency before conversion (if multi-currency).

---

## 6. Settings Screen

**General:** Primary Currency picker, Default Reminder Time picker.

**Data:**
- Export Backup → JSON via share sheet, filename `customsubs_backup_YYYY-MM-DD.json`
- Import Backup → file picker, confirmation with count, skip duplicates, reschedule notifications
- Delete All Data → red, double-confirmation ("Type DELETE to confirm")

**Notifications:** "Test Notification" → fires immediately. Shows last reminder time.

**About:** App version, "Made with ♥ by Custom*", App Store / Play Store links, privacy policy link.

---

## Backup Format

```json
{
  "app": "CustomSubs",
  "version": "1.0.0",
  "exportDate": "2026-03-03T09:00:00Z",
  "count": 12,
  "subscriptions": [ ... ]
}
```

Duplicate detection: match by name + amount + cycle.

After import: reschedule all notifications.

Backup prompt: after user adds 3rd subscription, show one-time tip.
Settings shows last backup date (or "Never backed up" in amber).

---

## Multi-Currency Rules

- Store `primary_currency` in Hive settings (default: "USD")
- Each sub stores its own `currencyCode`
- Bundled `assets/data/exchange_rates.json` — rates relative to USD, never fetched
- Tiles: always show native currency ("€12.99")
- Summary cards + analytics: show converted total in primary currency + note "at approximate bundled rates"
- Use `NumberFormat.currency(locale: ..., symbol: ...)` from `intl`
