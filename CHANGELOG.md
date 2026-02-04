# Changelog

All notable changes to CustomSubs will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### In Progress
- Subscription detail screen with full management interface
- Cancellation checklist functionality
- Backup and restore feature

## [0.1.1] - 2026-02-04

### Added
- **Service Icons System**: 50+ popular services now display recognizable Material Icons
  - Streaming: Netflix (movie), Spotify (music), Disney+ (castle), YouTube (play), etc.
  - Cloud Storage: iCloud, Google Drive, Dropbox (cloud icons)
  - Gaming: Xbox, PlayStation, Nintendo (game controller icons)
  - Productivity: Microsoft 365, Adobe, Notion (business/design icons)
  - Fitness: Peloton (bike), Strava (running), Headspace (meditation)
  - Falls back to first letter for unmapped services
- `ServiceIcons` utility class (`lib/core/utils/service_icons.dart`)
  - `getIconForService()` - Returns appropriate Material Icon
  - `hasCustomIcon()` - Checks if service has custom mapping
  - `getDisplayLetter()` - Fallback letter display

### Fixed
- **Critical**: Subscriptions not appearing on home screen after creation
  - Added `ref.invalidate(homeControllerProvider)` to force refresh
  - Home screen now updates immediately when returning from add screen
- **Critical**: NotificationService initialization error when saving subscriptions
  - Changed `notificationServiceProvider` to async provider with auto-initialization
  - Updated all callers to use `await ref.read(notificationServiceProvider.future)`
  - Files updated: add_subscription_controller.dart, onboarding_screen.dart, settings_screen.dart, main.dart
- **UI**: Template grid overflow (5.2 pixels bottom overflow)
  - Adjusted GridView `childAspectRatio` from 1.2 to 0.9
  - Optimized padding in `TemplateGridItem` widget
  - Reduced avatar radius from 30 to 28 pixels
- **Architecture**: Clean build process after major provider changes

### Changed
- Template picker now shows service icons instead of just letters for popular services
- Home screen subscription tiles display service icons for better visual identification
- Improved visual hierarchy in subscription list

### Developer Experience
- Comprehensive inline code documentation added to main.dart, app.dart, router.dart
- Enhanced architectural documentation
- Added CONTRIBUTING.md with detailed guidelines
- Created ARCHITECTURE.md with system design patterns

## [0.1.0] - 2026-02-04

### Added - Phase 1 Core MVP (Partial)

#### Infrastructure
- Flutter project setup with Material 3 theme
- Riverpod state management with code generation
- Hive local database with TypeAdapters
- GoRouter navigation configuration
- Custom app theme (DM Sans font, green color scheme)

#### Data Models
- `Subscription` model with 23 fields including:
  - Basic info (name, amount, currency, cycle)
  - Trial support (trial dates, post-trial amount)
  - Cancellation info (URLs, phone, notes, checklist)
  - Reminders configuration
- `SubscriptionCycle` enum (weekly, biweekly, monthly, quarterly, biannual, yearly)
- `SubscriptionCategory` enum (12 categories with emoji icons)
- `ReminderConfig` model for notification timing

#### Core Services
- **NotificationService**:
  - Timezone-aware notification scheduling
  - Deterministic ID generation for reliable cancellation
  - Platform-specific permission handling
  - Trial-specific reminder logic
- **TemplateService**:
  - 42 pre-populated subscription templates
  - Search and filter functionality
- **SubscriptionRepository**:
  - Complete CRUD operations
  - Reactive streams with `watchAll()`
  - Analytics methods (monthly total, spending by category)

#### Features
- **Onboarding Flow**:
  - 3-page introduction with CustomSubs logo
  - Notification permission request
  - One-time setup persistence
- **Home Screen**:
  - Monthly spending summary card with gradient
  - Subscription list with color-coded tiles
  - Swipe actions (mark paid, delete)
  - Empty state with logo
  - Pull-to-refresh
  - "Trials Ending Soon" section
- **Add/Edit Subscription Screen**:
  - Template picker with search (2-column grid)
  - Complete form with validation
  - Required fields: name, amount, currency, cycle, date, category
  - Color picker (12 colors)
  - Expandable sections: Trial info, Reminders, Cancellation info, Notes
  - Dynamic cancellation checklist builder
  - Edit mode (pre-fills existing subscription data)
- **Settings Screen**:
  - Basic structure
  - Test notification button

#### Assets & Data
- CustomSubs logo integration (onboarding, empty states)
- 42 subscription templates (JSON)
- 31 currency exchange rates (JSON, bundled)

#### Utilities
- `CurrencyUtils`: Multi-currency formatting and conversion (30+ currencies)
- `DateTimeExtensions`: Relative time strings, billing date calculations
- `AppColors`: 12 subscription colors + theme colors
- `AppSizes`: Consistent spacing and sizing constants

### Developer Experience
- Comprehensive README.md with setup instructions
- ARCHITECTURE.md with detailed technical documentation
- Code generation setup (Hive adapters, Riverpod providers)
- Hot reload support
- Clean build scripts

### Known Issues
- Subscription detail screen is placeholder only
- Analytics screen not yet implemented
- Backup/restore not yet implemented
- App icons not yet customized with logo
- Dark mode not supported (light mode only)

---

## Version History

### [0.1.0] - 2026-02-04
Initial development version with core infrastructure and Add Subscription feature complete.

### Future Versions

#### [0.2.0] - Planned
- Complete subscription detail screen
- Backup and restore functionality
- Currency picker in settings

#### [0.3.0] - Planned
- Analytics screen with charts
- Hero animations
- Micro-interactions and polish

#### [1.0.0] - Planned
- First production release
- All core features complete
- Tested on real devices (iOS and Android)
- App Store / Play Store ready

---

## Development Notes

### Phase 1: Core MVP (Current)
Focus on making the app fully functional for basic subscription tracking.

**Completed**:
- ✅ Project infrastructure and architecture
- ✅ Data models and repositories
- ✅ Notification system
- ✅ Home screen with subscription list
- ✅ Add/Edit subscription screen with templates
- ✅ Onboarding flow

**In Progress**:
- 🚧 Subscription detail screen
- 🚧 Full notification testing on devices

**Remaining**:
- ⏳ Cancellation checklist interaction
- ⏳ Mark as paid functionality
- ⏳ Pause/resume subscription

### Phase 2: Data Safety (Planned)
Focus on backup/restore and data management.

### Phase 3: Analytics & Polish (Planned)
Focus on insights, animations, and final polish.

---

## Migration Guide

### From 0.1.0 to 0.2.0
No migration needed - new features only.

---

## Credits

- **Design**: Material 3 Design System
- **Font**: DM Sans by Google Fonts
- **Icons**: Material Icons
- **Logo**: CustomSubs branding

---

**Last Updated**: 2026-02-04
