# Batch 8 Templates — March 6, 2026

**Status:** Complete
**Templates added:** 16 new (313 → 329 total)
**Code changes:** `service_icons.dart` _iconMap only (+3 entries) — no model changes, no build_runner needed

---

## Summary

Filled remaining high-value gaps: new standalone services, family/business tier variants of
existing templates, and missing storage tiers for iCloud+ and Google One.

---

## Files Changed

| File | Change |
|------|--------|
| `assets/data/subscription_templates.json` | +16 template objects appended at end of array |
| `lib/core/utils/service_icons.dart` | +3 entries in `_iconMap`: wyze, lastpass, keeper |
| `CHANGELOG.md` | Updated [Unreleased] entry |

---

## New Services (not previously in app)

| Template | Price | Cycle | Category | iconName | Icon |
|----------|-------|-------|----------|----------|------|
| Wyze Cam Plus | $3.99/mo | monthly | utilities | wyze | SimpleIcons.wyze |
| AppleCare+ | $9.99/mo | monthly | utilities | applecare | Letter avatar (A) |
| Adobe Acrobat | $19.99/mo | monthly | productivity | adobe | Local SVG (reuse) |
| LinkedIn Learning | $32.99/mo | monthly | education | linkedin | Local SVG (reuse) |
| Coursera Certificate | $49.00/mo | monthly | education | coursera | SimpleIcons (existing) |
| LastPass | $3.00/mo | monthly | productivity | lastpass | SimpleIcons.lastpass |
| Keeper Security | $2.92/mo | monthly | productivity | keeper | SimpleIcons.keeper |

## Family / Business Tier Variants

| Template | Price | Cycle | Category | iconName | Base template |
|----------|-------|-------|----------|----------|---------------|
| YouTube Premium Family | $22.99/mo | monthly | entertainment | youtube | YouTube Premium ($13.99) |
| Microsoft 365 Family | $12.99/mo | monthly | productivity | microsoft | Microsoft 365 ($9.99) |
| Duolingo Family | $9.99/mo | monthly | education | duolingo | Duolingo Plus ($12.99) |
| Dropbox Business | $20.00/mo | monthly | productivity | dropbox | Dropbox Plus ($11.99) |
| Dashlane Friends & Family | $7.49/mo | monthly | productivity | dashlane | Dashlane ($4.99) |

## Missing Storage Tiers

| Template | Price | Existing tier |
|----------|-------|---------------|
| iCloud+ 50GB | $0.99/mo | iCloud+ = 200GB ($2.99) — already existed |
| iCloud+ 2TB | $9.99/mo | — |
| Google One 100GB | $1.99/mo | Google One = 2TB ($9.99) — already existed |
| Google One 200GB | $2.99/mo | — |

All storage tier variants share the same `iconName` as their base template. This is intentional —
the icon renders identically; only the name and price differ in the template picker.

---

## _iconMap Additions

```dart
// --- Smart Home ---
'wyze': SimpleIcons.wyze,             // turquoise #1DF0BB

// --- Password Managers ---
'lastpass': SimpleIcons.lastpass,     // red #D32D27
'keeper': SimpleIcons.keeper,         // yellow #FFC700
```

All three confirmed present in simple_icons v14.6.1.

---

## Pricing Notes

- **AppleCare+**: $9.99/mo is representative (iPhone tier); actual varies by device (iPad $7.49, MacBook $14.99+)
- **Keeper**: Billed annually ($34.99/yr ÷ 12 = $2.92/mo) — shown as monthly for consistency
- **LastPass**: Premium tier billed annually ($36/yr = $3.00/mo)
- **LinkedIn Learning**: $32.99/mo standalone; free with LinkedIn Premium Career ($39.99)
- **Adobe Acrobat**: Standard plan ($19.99/mo); Pro is $29.99/mo
- **Dropbox Business**: "Essentials" entry business tier ($20/mo per user)
- **Duolingo Family**: $9.99/mo for up to 7 users — notably cheaper than individual Plus ($12.99)
