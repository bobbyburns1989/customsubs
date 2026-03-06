# New Templates + Sports Category — March 5, 2026

**Status:** Complete
**Templates added:** 30 new (260 → 290 total)
**Code changes:** `sports` SubscriptionCategory enum + analytics color mapping

---

## Code Changes

### 1. SubscriptionCategory enum — `lib/data/models/subscription_category.dart`
Added `sports` at HiveField index 12 (appended to end — safe for existing data).
Includes `displayName` ("Sports") and `icon` (trophy emoji).

### 2. Analytics donut chart — `lib/features/analytics/widgets/category_donut_chart.dart`
Added `sports` to both `_getCategoryDisplayName()` and `_getCategoryColor()`.
Sports color: `Color(0xFF0EA5E9)` — sky blue (distinct from gaming purple, fitness green, entertainment red).

### 3. Hive adapter regenerated
`dart run build_runner build --delete-conflicting-outputs` — 80 outputs, 0 errors.

### 4. ESPN Select category updated
`espn_select` moved from `entertainment` to `sports` category.

---

## 30 New Templates Added

### Music / Audio
| Service | Price | Category | iconName |
|---------|-------|----------|----------|
| Amazon Music Unlimited | $10.99/mo | entertainment | amazon_music |
| YouTube Music | $10.99/mo | entertainment | youtube_music |
| Deezer Premium | $10.99/mo | entertainment | deezer |

### Fitness / Wearables
| Service | Price | Category | iconName |
|---------|-------|----------|----------|
| Oura Ring | $5.99/mo | health | oura |
| Garmin Connect+ | $6.99/mo | fitness | garmin |

### VPN / Privacy
| Service | Price | Category | iconName |
|---------|-------|----------|----------|
| Surfshark | $3.99/mo | utilities | surfshark |
| ProtonVPN | $4.99/mo | utilities | protonvpn |
| Mullvad VPN | $5.50/mo | utilities | mullvad |

### Privacy Email
| Service | Price | Category | iconName |
|---------|-------|----------|----------|
| Proton Mail | $3.99/mo | productivity | protonmail |
| Fastmail | $5.00/mo | productivity | fastmail |

### Finance
| Service | Price | Category | iconName |
|---------|-------|----------|----------|
| Copilot Money | $14.99/mo | finance | copilot |
| Simplifi by Quicken | $5.99/mo | finance | simplifi |

### Streaming Gaps
| Service | Price | Category | iconName |
|---------|-------|----------|----------|
| MGM+ | $5.99/mo | entertainment | mgmplus |
| Philo | $25.00/mo | entertainment | philo |
| MUBI | $14.99/mo | entertainment | mubi |

### Sports (new category)
| Service | Price | Category | iconName |
|---------|-------|----------|----------|
| ESPN+ | $10.99/mo | sports | espnplus |
| NBA League Pass | $14.99/mo | sports | nba |
| MLB.TV | $24.99/mo | sports | mlb |
| MLS Season Pass | $12.99/mo | sports | mls |
| DAZN | $19.99/mo | sports | dazn |
| F1 TV Pro | $9.99/mo | sports | f1tv |

### Productivity / Notes
| Service | Price | Category | iconName |
|---------|-------|----------|----------|
| Todoist Pro | $5.00/mo | productivity | todoist |
| Fantastical | $4.99/mo | productivity | fantastical |
| Obsidian Sync | $8.00/mo | productivity | obsidian |
| Kagi Search | $10.00/mo | productivity | kagi |
| Raycast Pro | $8.00/mo | productivity | raycast |

### AI Tools
| Service | Price | Category | iconName |
|---------|-------|----------|----------|
| Poe | $19.99/mo | productivity | poe |
| Character.ai+ | $9.99/mo | productivity | characterai |
| NotebookLM Plus | $19.99/mo | productivity | notebooklm |

### Smart Home / Security
| Service | Price | Category | iconName |
|---------|-------|----------|----------|
| Arlo Secure | $12.99/mo | utilities | arlo |

---

## Icon Coverage Notes

Most new services fall back to letter avatars (no SimpleIcons glyph). The following may have SimpleIcons coverage — verify in-app:
- `deezer`, `surfshark`, `mullvad`, `todoist`, `obsidian`, `raycast`, `dazn` — likely in SimpleIcons 14.x

---

## Pricing Convention

All prices reflect the most popular paid tier at monthly billing rate (USD), as of March 2026.
Notable decisions:
- **Mullvad**: €5/mo — used $5.50 as USD equivalent (Mullvad charges in EUR, no USD price)
- **Surfshark**: Monthly rate $3.99 (annual plan ~$2.49/mo — we show monthly)
- **NBA League Pass**: Seasonal product; $14.99/mo is approximate in-season rate
- **MLB.TV**: Premium tier in-season rate
- **Kagi Search**: Professional plan ($10/mo); Starter is $5/mo

---

## Next Price Review

Recommended: Q3 2026. Sports streaming services (ESPN+, DAZN) and AI tools (Poe, Character.ai) are especially volatile.
