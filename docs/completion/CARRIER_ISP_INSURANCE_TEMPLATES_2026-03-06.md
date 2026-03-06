# Carrier / ISP / Insurance Templates — March 6, 2026

**Status:** Complete
**Templates added:** 23 new (290 → 313 total)
**Code changes:** `service_icons.dart` _iconMap only — no model changes, no build_runner needed

---

## Summary

Added the most-requested recurring bill types that fit the existing subscription model:
- Fixed monthly/annual amount
- Cancellable service
- Reminder value is high (charges happen automatically)

Excluded variable-amount bills (electric, gas, water) and loan payments (mortgage, car loan)
as they don't fit the fixed-amount template model cleanly.

---

## Files Changed

| File | Change |
|------|--------|
| `assets/data/subscription_templates.json` | +23 template objects appended at end of array |
| `lib/core/utils/service_icons.dart` | +4 entries in `_iconMap` |
| `CHANGELOG.md` | Added [Unreleased] entry |

---

## 23 New Templates

### Cell Phone Carriers (category: utilities)

| Service | Price | Cycle | iconName | Icon Source |
|---------|-------|-------|----------|-------------|
| T-Mobile | $70.00/mo | monthly | tmobile | Letter avatar (T) |
| Verizon | $80.00/mo | monthly | verizon | SimpleIcons.verizon |
| AT&T Wireless | $75.00/mo | monthly | att_wireless | SimpleIcons.atandt |
| Xfinity Mobile | $25.00/mo | monthly | xfinity_mobile | Letter avatar (X) |
| Google Fi Wireless | $20.00/mo | monthly | googlefi | Letter avatar (G) |
| Mint Mobile | $30.00/mo | monthly | mintmobile | Letter avatar (M) |
| Cricket Wireless | $55.00/mo | monthly | cricket | Letter avatar (C) |
| Visible | $25.00/mo | monthly | visible | Letter avatar (V) |
| Boost Mobile | $25.00/mo | monthly | boost | SimpleIcons.boost |

### Internet & Cable Providers (category: utilities)

| Service | Price | Cycle | iconName | Icon Source |
|---------|-------|-------|----------|-------------|
| Xfinity Internet | $60.00/mo | monthly | xfinity | Letter avatar (X) |
| Spectrum Internet | $50.00/mo | monthly | spectrum_isp | Letter avatar (S) |
| AT&T Internet | $55.00/mo | monthly | att_internet | SimpleIcons.atandt |
| Cox Internet | $50.00/mo | monthly | cox | Letter avatar (C) |
| Google Fiber | $70.00/mo | monthly | googlefiber | Letter avatar (G) |
| Frontier Internet | $50.00/mo | monthly | frontier | Letter avatar (F) |
| Optimum | $50.00/mo | monthly | optimum | Letter avatar (O) |

### Insurance & Roadside (category: finance)

| Service | Price | Cycle | iconName | Icon Source |
|---------|-------|-------|----------|-------------|
| GEICO | $120.00/mo | monthly | geico | Letter avatar (G) |
| Progressive | $110.00/mo | monthly | progressive | Letter avatar (P) |
| State Farm | $115.00/mo | monthly | statefarm | Letter avatar (S) |
| Allstate | $125.00/mo | monthly | allstate | Letter avatar (A) |
| USAA | $95.00/mo | monthly | usaa | Letter avatar (U) |
| Lemonade Insurance | $12.00/mo | monthly | lemonade | Letter avatar (L) |
| AAA Membership | $129.00/yr | yearly | aaa | Letter avatar (A) |

---

## Icon Map Additions (`service_icons.dart`)

```dart
'verizon':      SimpleIcons.verizon,
'att_wireless': SimpleIcons.atandt,
'att_internet': SimpleIcons.atandt,
'boost':        SimpleIcons.boost,   // orange #F7901E — confirmed Boost Mobile
```

**Important gotcha**: `SimpleIcons.spectrum` is the CSS dev framework (purple `#7B16FF`),
NOT Charter Spectrum ISP. Charter Spectrum uses blue `#0063A3`. The ISP template uses
iconName `spectrum_isp` and intentionally has no SimpleIcons mapping — falls back to letter avatar.

---

## Pricing Convention

Insurance amounts are US national averages (car insurance). Users are expected to edit
to their actual premium. These serve primarily as reminders, not precise trackers.

- Car insurance average: $115–125/mo (varies widely by state, age, vehicle)
- Renters insurance (Lemonade): $12/mo — entry-level / lowest tier
- AAA: $129/yr — Classic membership (most common tier); billed annually

---

## What Was Excluded (and Why)

| Bill Type | Reason Excluded |
|-----------|----------------|
| Mortgage payment | Amortized loan — amount is fixed but payoff date and principal/interest split not modeled |
| Car loan payment | Same as mortgage |
| Electric / Gas / Water | Variable amount each month — template would mislead users |
| Homeowners insurance | Often bundled into mortgage escrow — less likely to be tracked separately |
| Credit card minimums | Variable, complex interest logic |
| Rent | Variable, not a "cancellable" service |
