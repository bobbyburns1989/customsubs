# ADR 003: Offline-First Architecture

**Status**: Accepted
**Date**: 2024-01-15
**Deciders**: Development Team, Product
**Context**: Data persistence and architecture philosophy for CustomSubs

---

## Context and Problem Statement

CustomSubs is a subscription tracker that needs to store and manage user data. We must decide:

1. **Where to store data?** (Local device, cloud, hybrid)
2. **Do we need a backend?** (API, database, authentication)
3. **Do we sync across devices?** (Cloud sync, iCloud, Google Drive)
4. **How do we handle currency rates?** (Live API, bundled data)

This decision affects:
- User privacy and trust
- App complexity and maintenance burden
- Feature set and capabilities
- Development timeline and cost

---

## Decision Drivers

### Primary Drivers

1. **Privacy First** - User data should never leave their device without explicit consent
2. **Trust** - Users must feel confident their financial data is safe
3. **Simplicity** - Minimize complexity, dependencies, and failure points
4. **Reliability** - App should work 100% of the time, not 99.9%
5. **Speed** - Fast startup, no loading spinners waiting for network

### Secondary Drivers

6. Cost - No backend infrastructure or API costs
7. Development speed - No backend development or maintenance
8. Regulatory compliance - No GDPR, CCPA, or data retention concerns
9. Offline capability - Must work on planes, subways, poor connectivity

---

## Considered Options

### Option 1: Cloud-First with Backend (Traditional SaaS)

**Architecture:**
```
Mobile App ←→ REST API ←→ PostgreSQL
                ↓
          Authentication Service
          Cloud Storage
          Currency API
```

**Example apps:** Mint, YNAB, Truebill, Rocket Money

**Features:**
- Multi-device sync
- Web dashboard
- Shared subscriptions (family plans)
- Live currency rates
- Cloud backups
- Push notifications (marketing)

**Pros:**
- Feature-rich (sync, sharing, analytics)
- Users expect cloud sync
- Easier to add features server-side
- Can monetize via subscriptions

**Cons:**
- ❌ **Privacy concerns** - User data leaves device
- ❌ **Backend development** - API, auth, database, infrastructure
- ❌ **Ongoing costs** - Servers, database, API keys
- ❌ **Requires login** - Email, password, onboarding friction
- ❌ **Network dependency** - App breaks without internet
- ❌ **Regulatory compliance** - GDPR, CCPA, data retention
- ❌ **Attack surface** - API vulnerabilities, data breaches
- ❌ **Maintenance burden** - Backend updates, security patches

### Option 2: Hybrid (Local with Optional Cloud Sync)

**Architecture:**
```
Mobile App → Local DB (Hive)
     ↓
Optional: Firebase/Supabase for sync
```

**Examples:** 1Password, Bear, Things 3

**Features:**
- Works offline by default
- Optional iCloud/Google Drive sync
- No auth required (unless syncing)
- Fast local operations

**Pros:**
- Best of both worlds (offline + sync)
- Users choose if they want sync
- Respects privacy (opt-in)

**Cons:**
- ❌ **Sync complexity** - Conflict resolution, offline edits
- ❌ **Platform-specific** - Different sync per platform (iCloud vs Google Drive)
- ❌ **Still requires backend** - For web/cross-platform sync
- ❌ **Partial privacy** - Data still leaves device (if opted in)
- ❌ **Testing complexity** - Many code paths (sync on, sync off, conflicts)

### Option 3: 100% Offline-First, No Cloud (CHOSEN)

**Architecture:**
```
Mobile App → Hive (Local NoSQL DB)
     ↓
Bundled Assets (currency rates, templates)
```

**Examples:** Bear (originally), Notability (before iCloud), Simple budget apps

**Features:**
- Works completely offline
- No login or account creation
- Fast startup (no network calls)
- Export/import for backup (JSON file)
- Complete user control of data

**Pros:**
- ✅ **Maximum privacy** - Data never leaves device
- ✅ **No backend** - Zero infrastructure costs
- ✅ **Simple architecture** - Just app + local storage
- ✅ **Always available** - Works on planes, subway, poor network
- ✅ **Fast** - No loading spinners, instant operations
- ✅ **Trustworthy** - Users control their data
- ✅ **No compliance** - No user data = no regulations
- ✅ **Lower development cost** - No backend to build/maintain

**Cons:**
- ❌ **No multi-device sync** - Each device is independent
- ❌ **Manual backup** - User must export/import
- ❌ **No web version** - Mobile only
- ❌ **Stale currency rates** - Bundled rates updated via app releases
- ❌ **Data loss risk** - If device is lost/broken without backup

---

## Decision Outcome

**Chosen option: 100% Offline-First, No Cloud (Option 3)**

### Rationale

#### 1. Privacy is Our Core Value Proposition

**Competitive advantage:**
- Competitors (Mint, Truebill, Rocket Money) require bank linking
- Bobby (our target) is also offline, but has data loss issues
- We differentiate on **privacy + reliability**

**User trust:**
- Financial data is sensitive
- Users increasingly concerned about data privacy
- "No account, no cloud, no tracking" is a selling point

#### 2. Simplicity Enables Reliability

**The fewer moving parts, the fewer things can break:**
- No API downtime
- No authentication bugs
- No sync conflicts
- No network errors
- No rate limiting
- No backend maintenance

**Reliability is feature #1:**
- Notifications must fire 100% of the time
- Offline-first ensures no network dependency
- Local storage is fast and predictable

#### 3. Aligned with Product Philosophy

**CustomSubs core philosophy:**
> Do one thing perfectly — track subscriptions and remind users before they get charged.

**What users need:**
- Know what subscriptions they have
- Get reminded before charges
- Cancel subscriptions easily

**What users don't need:**
- Multi-device sync (most people have one phone)
- Web dashboard (mobile is where you manage subscriptions)
- Shared subscriptions (subscriptions are personal)

#### 4. Market Position

**We're not competing with YNAB or Mint** (full financial management)
**We're competing with Bobby** (simple subscription tracker)

Bobby's weaknesses:
- Broken notifications
- Data loss on reinstall
- iOS-only

Our advantages:
- Reliable notifications (local scheduling)
- Export/import backup (manual but reliable)
- Cross-platform (iOS + Android)

### Multi-Device Sync: Why We Don't Need It

**User research insights:**
1. Most people have one phone (primary device)
2. Subscription management happens on phone (where apps are installed)
3. Desktop tracking is "nice to have" not essential
4. Manual export/import acceptable for rare device switches

**Alternatives for users who want sync:**
- Export backup to cloud storage (Dropbox, Google Drive)
- Email JSON file to self
- Save in password manager (1Password, Bitwarden)

---

## Implementation Strategy

### Local Storage: Hive

**Why Hive?**
- Fast (synchronous reads, lazy loading)
- No SQL boilerplate
- Type-safe (code generation)
- Stable, mature package
- Works offline (obviously)

**Structure:**
```dart
// Single box for subscriptions
Box<Subscription> subscriptions;

// Settings box for app configuration
Box<dynamic> settings;
```

### Currency Rates: Bundled JSON

**Strategy:**
```
assets/data/exchange_rates.json
{
  "base": "USD",
  "rates": {
    "EUR": 0.85,
    "GBP": 0.73,
    ...
  },
  "lastUpdated": "2024-01-15"
}
```

**Why bundled?**
- No API dependency
- No API costs
- Works offline
- Acceptable staleness (updated monthly via app releases)

**Update strategy:**
- Bundle new rates with each app release
- Show "Rates updated: Jan 2024" in settings
- Users understand rates are approximate

**Alternatives considered:**
- Live API (exchangerate-api.com, fixer.io)
  - ❌ Network dependency
  - ❌ API costs ($10-50/month)
  - ❌ Rate limits
- No conversion (show native currency only)
  - ❌ Poor UX for multi-currency users

### Backup Strategy: Export/Import

**Export format:**
```json
{
  "app": "CustomSubs",
  "version": "1.0.0",
  "exportDate": "2024-01-15T10:30:00Z",
  "subscriptions": [
    {
      "id": "...",
      "name": "Netflix",
      ...
    }
  ]
}
```

**Export flow:**
1. User taps "Export Backup" in Settings
2. Generate JSON file: `customsubs_backup_2024-01-15.json`
3. Open system share sheet (email, cloud storage, AirDrop)
4. User saves wherever they want

**Import flow:**
1. User taps "Import Backup"
2. File picker (document picker)
3. Parse and validate JSON
4. Show preview: "Found 15 subscriptions. Import?"
5. Import (skip duplicates by name+amount+cycle)
6. Reschedule all notifications

**Backup prompts:**
- After 3rd subscription added: "Tip: Back up your subscriptions!"
- Settings shows "Last backup: Never" in warning color

---

## Consequences

### Positive Consequences

1. **Maximum Privacy**
   - No data collection or transmission
   - No third-party analytics or tracking
   - User owns their data completely

2. **Unmatched Reliability**
   - No network errors
   - No API downtime
   - Works everywhere (planes, tunnels, poor signal)

3. **Fast Performance**
   - Instant startup
   - No loading spinners
   - Synchronous data access

4. **Lower Costs**
   - No server infrastructure
   - No API subscriptions
   - No database hosting
   - No backend maintenance

5. **Faster Development**
   - No backend development
   - No API design
   - No authentication system
   - Focus on app quality

6. **Regulatory Simplicity**
   - No GDPR compliance needed
   - No CCPA compliance needed
   - No data retention policies
   - No privacy policy complexity

7. **Security by Design**
   - No attack surface (no API)
   - No user data to breach
   - No credentials to steal

### Negative Consequences

1. **No Multi-Device Sync**
   - **Mitigation**: Export/import backup
   - **Reality**: Most users have one phone

2. **Manual Backup Required**
   - **Mitigation**: In-app prompts and reminders
   - **Reality**: Similar to password managers (user control)

3. **Stale Currency Rates**
   - **Mitigation**: Update with app releases (monthly)
   - **Reality**: Users understand rates are approximate

4. **No Web Version**
   - **Mitigation**: Not needed for subscription tracking
   - **Reality**: Mobile is where subscriptions are managed

5. **Limited Analytics**
   - **Mitigation**: App Store stats, manual user surveys
   - **Reality**: Privacy > analytics

---

## User Education

### Communicate the Benefits

**Onboarding message:**
> "CustomSubs never accesses your bank account, scans your emails, or stores your data in the cloud. Everything stays on your device. You're in control."

**Marketing angle:**
- "Privacy-first subscription tracker"
- "No account, no cloud, no tracking"
- "Your data stays on your device, period"

### Set Expectations

**Settings screen:**
- "CustomSubs works 100% offline"
- "Export your data anytime in JSON format"
- "Currency rates updated monthly (approximate)"

**FAQ:**
- Q: "Can I sync across devices?"
  A: "Export from one device, import on another. Takes 30 seconds."

- Q: "What if I lose my phone?"
  A: "Export regular backups to your cloud storage of choice."

- Q: "Are currency rates real-time?"
  A: "Rates are approximate, updated monthly. Perfect for tracking spending, not forex trading."

---

## Future Considerations

### If We Need Sync Later

**Possible approaches (if user demand is high):**

1. **Platform-native sync** (Phase 2+)
   - iOS: iCloud Key-Value storage or iCloud Documents
   - Android: Google Drive App Data
   - No backend, no authentication
   - Platform handles sync
   - Users opt-in

2. **Self-hosted sync** (Advanced users)
   - Users can run their own sync server
   - Open-source sync backend
   - For power users only

3. **Encrypted cloud backup** (Premium feature)
   - End-to-end encrypted backup to our storage
   - Zero-knowledge architecture
   - Still no login (key stored locally)
   - Optional paid feature

**Important:** These are possible future additions, not current requirements. Offline-first is our foundation.

---

## Comparison with Competitors

| Feature | CustomSubs | Bobby | Mint | YNAB |
|---------|-----------|-------|------|------|
| **Privacy** | ✅ 100% offline | ✅ Offline | ❌ Cloud | ❌ Cloud |
| **Multi-device sync** | ❌ Manual backup | ❌ No sync | ✅ Auto | ✅ Auto |
| **Backend required** | ❌ No | ❌ No | ✅ Yes | ✅ Yes |
| **Internet required** | ❌ No | ❌ No | ✅ Yes | ✅ Yes |
| **Login required** | ❌ No | ❌ No | ✅ Yes | ✅ Yes |
| **Data portability** | ✅ JSON export | ❌ Weak | ❌ Locked in | ✅ CSV |
| **Notification reliability** | ✅ Local | ❌ Broken | ⚠️ Push | ⚠️ Email |

**Our niche:** Privacy-conscious users who want a simple, reliable subscription tracker.

---

## Related Decisions

- See `docs/architecture/overview.md` for full architecture
- See `docs/guides/working-with-notifications.md` for local notification strategy
- See ADR 002 for notification ID strategy (deterministic, offline-friendly)

---

## References

- [Local-First Software](https://www.inkandswitch.com/local-first/)
- [Privacy by Design](https://www.ipc.on.ca/wp-content/uploads/Resources/7foundationalprinciples.pdf)
- [Hive Documentation](https://docs.hivedb.dev/)

---

## Revision History

| Date | Change | Author |
|------|--------|--------|
| 2024-01-15 | Initial decision | Development Team, Product |
