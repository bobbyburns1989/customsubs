# CustomSubs - Privacy-First Subscription Tracker

<div align="center">
  <img src="assets/images/CustomSubsLOGO.png" alt="CustomSubs Logo" width="300"/>

  A beautiful, privacy-first subscription tracker for iOS and Android.

  **No accounts • No cloud sync • No tracking • 100% offline**
</div>

## Overview

CustomSubs is a mobile application designed to help you track and manage your subscriptions with complete privacy. All your data stays on your device - no servers, no accounts, no tracking, no internet connection required.

**📊 Development Status:** 98% Complete - Ready for Device Testing! | **📋 See [ROADMAP.md](ROADMAP.md) for detailed progress tracking**

**🆕 Latest Update (v1.0.3):** Add Subscription screen modernized with 60% size reduction, collapsible sections, and sleek compact design!

### Key Features

✅ **Completed Features (Phases 0-2 + UI Modernization)**

**Core Functionality:**
- 📱 Clean Material 3 UI with custom theming
- ➕ Add/Edit subscriptions with 40+ pre-populated templates
- 🎨 Color customization with 12 vibrant colors
- 🎯 **Service icons** - 50+ popular services display recognizable icons (Netflix, Spotify, Disney+, etc.)
- 💰 Multi-currency support (30+ currencies with bundled exchange rates)
- 🔔 Smart notification system with timezone support (fixed critical bugs)
- 📅 Multiple billing cycles (weekly, biweekly, monthly, quarterly, biannual, yearly)
- 🎁 Free trial tracking with post-trial amount
- 📋 Cancellation management (URLs, phone numbers, interactive checklists)
- 🏠 Home screen with spending summary and subscription list
- 🔍 Template search and quick subscription creation
- 📝 Custom notes and detailed subscription info
- ✨ Real-time home screen refresh after adding subscriptions

**Subscription Management:**
- 📊 **Full subscription detail screen** with complete management
- ✅ Mark as Paid functionality with visual badges
- ⏸️ Pause/Resume subscriptions
- 🗑️ Delete with confirmation and notification cleanup
- 📱 Interactive cancellation checklists with progress tracking
- 🌐 Launch cancel URLs and phone numbers directly

**Settings & Data Safety:**
- 💱 Currency picker (30+ currencies with search)
- ⏰ Default reminder time configuration
- 💾 **Backup and restore** (export to JSON, share to Files/email/cloud)
- 🔄 Import with duplicate detection
- ⏰ Backup reminders (after 3rd subscription)
- 📅 Last backup date tracking
- 🧪 Test notification feature
- 🗑️ Delete all data with double confirmation (type-to-confirm security)
- 📄 Privacy Policy and Terms of Service links
- ℹ️ Version info and company attribution

**Analytics & Insights:**
- 📈 **Analytics screen** with comprehensive spending insights
- 📊 Category breakdown with horizontal bar charts
- 📉 Month-over-month spending comparison with automatic snapshots
- 🏆 Top 5 subscriptions ranking
- 💰 Monthly and yearly spending forecasts
- 💱 Multi-currency breakdown

**Critical Bug Fixes (Phase 0):**
- ✅ Fixed notification timezone (now uses device local time)
- ✅ Fixed same-day reminder skip bug
- ✅ Fixed month-end billing date drift (Jan 31 stays Jan 31)
- ✅ Fixed edit state preservation (no data loss on edit)
- ✅ Fixed multi-currency total conversion
- ✅ Fixed "Next 30 days" filter accuracy

**Code Quality (Phases 4-5):**
- ✅ Zero analysis warnings or errors
- ✅ All deprecations resolved
- ✅ Performance optimized (60fps)
- ✅ Error handling utilities
- ✅ Comprehensive testing checklist (300+ test cases)

**UI Modernization (v1.0.3):**
- ✨ **60% reduction in Add Subscription form height**
- 📝 Smart collapsible sections with smooth animations
- 🎯 Compact, modern design (12px padding, 36px icons)
- 🎨 Unified FormSectionCard styling across all sections
- 🔽 Animated chevron icons (300ms transitions)
- 👆 All touch targets maintained >32px for accessibility
- 📱 Collapsed preview widgets (e.g., color dot when Appearance collapsed)
- **See:** [`docs/completion/ADD_SUBSCRIPTION_MODERNIZATION.md`](docs/completion/ADD_SUBSCRIPTION_MODERNIZATION.md)

🔮 **Planned (Future Versions)**
- 🌙 Dark mode support
- 🏠 Home screen widgets (iOS/Android)
- 📊 Advanced analytics with charts (fl_chart)
- 🎯 Dedicated cancellation flow screen
- 🌍 Localization (i18n)
- ☁️ iCloud backup option (iOS)
- 📸 Receipt scanning (OCR)

## Screenshots

[Coming soon]

## Technology Stack

- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Riverpod with code generation
- **Local Database**: Hive (NoSQL, encrypted)
- **Navigation**: GoRouter
- **Notifications**: flutter_local_notifications with timezone support
- **Design**: Material 3 with custom theme

## Architecture

CustomSubs follows clean architecture principles with a feature-first folder structure:

```
lib/
├── app/              # App-level configuration (theme, router)
├── core/             # Shared utilities, constants, extensions
├── data/             # Data layer (models, repositories, services)
└── features/         # Feature modules (onboarding, home, add, detail, etc.)
```

For detailed architecture documentation, see [Architecture Overview](docs/architecture/overview.md).

## Getting Started

### Prerequisites

- Flutter SDK 3.24.0 or higher
- Dart SDK 3.5.0 or higher
- iOS development: Xcode 14+ (macOS)
- Android development: Android Studio with SDK 21+

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd customsubs
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   # List available devices
   flutter devices

   # Run on specific device
   flutter run -d <device-id>

   # Or run on default device
   flutter run
   ```

### Development Workflow

**Hot Reload** (while app is running):
```bash
# Press 'r' in terminal for hot reload
# Press 'R' for hot restart
```

**Clean build** (if you encounter issues):
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

**Code generation** (after modifying models or providers):
```bash
# Watch mode (auto-regenerate on file changes)
dart run build_runner watch

# One-time generation
dart run build_runner build --delete-conflicting-outputs
```

## Project Structure

```
customsubs/
├── assets/
│   ├── data/                          # JSON data files
│   │   ├── subscription_templates.json  # 40+ service templates
│   │   └── exchange_rates.json         # Currency conversion rates
│   └── images/                        # Images and logos
│       └── CustomSubsLOGO.png
├── lib/
│   ├── app/
│   │   ├── router.dart                # GoRouter configuration
│   │   └── theme.dart                 # Material 3 theme
│   ├── core/
│   │   ├── constants/                 # App-wide constants
│   │   ├── extensions/                # Dart extensions
│   │   └── utils/                     # Utility classes
│   ├── data/
│   │   ├── models/                    # Data models (Hive)
│   │   ├── repositories/              # Data access layer
│   │   └── services/                  # Business logic services
│   └── features/
│       ├── onboarding/                # First-time user flow
│       ├── home/                      # Main subscription list
│       ├── add_subscription/          # Add/edit subscription
│       ├── subscription_detail/       # Subscription details (TODO)
│       ├── settings/                  # App settings
│       └── analytics/                 # Analytics (TODO)
├── CLAUDE.md                          # Original specification
├── README.md                          # This file
└── ARCHITECTURE.md                    # Technical architecture docs
```

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `riverpod` | State management and dependency injection |
| `hive` | Local NoSQL database |
| `go_router` | Declarative navigation |
| `flutter_local_notifications` | Local push notifications |
| `timezone` | Timezone support for notifications |
| `google_fonts` | DM Sans font family |
| `uuid` | Unique ID generation |
| `intl` | Internationalization and formatting |
| `url_launcher` | Open URLs and phone numbers |
| `share_plus` | Share functionality (for backups) |
| `file_picker` | File selection (for restore) |

## Configuration

### Notifications

Notifications require platform-specific setup:

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

### Assets

The app uses bundled data files for offline operation:

- **Templates**: `assets/data/subscription_templates.json` - 40+ popular subscription services
- **Exchange Rates**: `assets/data/exchange_rates.json` - Currency conversion rates
- **Logo**: `assets/images/CustomSubsLOGO.png` - App branding

These are loaded once on app startup and cached in memory.

## Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

## Building for Release

### iOS

```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode and archive
```

### Android

```bash
flutter build apk --release        # For APK
flutter build appbundle --release  # For Play Store
```

## Privacy & Security

CustomSubs is designed with privacy as the top priority:

- ✅ **No Network Access**: The app never makes network calls
- ✅ **No Analytics**: Zero tracking or telemetry
- ✅ **Local-Only Storage**: All data stored in Hive on-device
- ✅ **No Third-Party Services**: No cloud sync, no servers
- ✅ **Export Control**: Users can export/import their own data (JSON format)
- ✅ **Open Source**: Full transparency in code

## Known Issues & Limitations

- Dark mode not yet implemented (light mode only)
- Notification reliability depends on OS background task limitations
- Currency exchange rates are bundled (updated with app releases, not real-time)
- No cloud backup (by design - privacy-first)

## Roadmap

**Overall Progress: ~75% Complete**

See [ROADMAP.md](ROADMAP.md) for the detailed implementation plan with task breakdowns and time estimates.

---

### ✅ Phase 0: Critical Bug Fixes (COMPLETE)
**Status:** ✅ Complete (100%)
**Time:** ~3 hours

- [x] Fixed notification timezone (device local time)
- [x] Fixed same-day reminder skip bug
- [x] Fixed month-end billing date drift
- [x] Fixed edit state preservation (isActive, isPaid, checklist)
- [x] Fixed multi-currency total conversion
- [x] Fixed getById null return handling
- [x] Fixed "Next 30 days" filter accuracy

**Impact:** Core functionality now reliable and production-ready.

---

### ✅ Phase 1: Critical Completions (COMPLETE)
**Status:** ✅ Complete (100%)
**Time:** ~5 hours

- [x] Full Subscription Detail Screen (734 lines, 7 sub-widgets)
- [x] Subscription Detail Controller (paid, active, checklist, delete actions)
- [x] Settings Provider with Hive persistence
- [x] Currency Picker Dialog (30+ currencies with search)
- [x] Dynamic currency switching throughout app

**Impact:** Core user flow complete (Home → Detail → Actions).

---

### ✅ Phase 2: Data Safety Features (COMPLETE)
**Status:** ✅ Complete (100%)
**Time:** ~4 hours

- [x] Backup Service (export to JSON)
- [x] Import Service (restore from file with duplicate detection)
- [x] Backup reminder after 3rd subscription
- [x] Last backup date tracking in Settings
- [x] Share sheet integration

**Impact:** Data loss prevention - key competitive advantage.

---

### ⏳ Phase 3: Analytics Screen (IN PROGRESS)
**Status:** 🚧 Ready to Start (0%)
**Estimated Time:** 2-3 hours

- [ ] Monthly Snapshot Hive model
- [ ] Analytics Controller with calculations
- [ ] Analytics Screen UI (simple bar charts)
- [ ] Category breakdown with percentages
- [ ] Top 5 subscriptions ranking
- [ ] Month-over-month comparison
- [ ] Router integration

**Next Up:** Task 3.1 - Create Monthly Snapshot model

---

### 🔜 Phase 4: Full Quality Pass (PENDING)
**Status:** 🔜 Not Started (0%)
**Estimated Time:** 4-5 hours

- [ ] Fix all 36 deprecation warnings
- [ ] Refactor add_subscription_screen.dart (656 → 300 lines)
- [ ] Refactor home_screen.dart (523 → 250 lines)
- [ ] Add comprehensive error handling
- [ ] Performance audit and optimization

---

### 🔜 Phase 5: Extended Testing (PENDING)
**Status:** 🔜 Not Started (0%)
**Estimated Time:** 2-3 hours

- [ ] Comprehensive feature testing (all screens)
- [ ] Notification testing on iPhone
- [ ] Notification testing on Android (LambdaTest)
- [ ] Edge case and stress testing
- [ ] Final code review and documentation

---

### 🎯 Target Completion
**Total Remaining:** 8-11 hours of focused development
**Target Date:** February 9-11, 2026
**Ready for:** Beta testing → TestFlight → App Store submission

---

### Future Versions
**v1.1** - Dark mode, advanced analytics, home screen widgets
**v1.2** - Receipt scanning, custom cycles, price change alerts
**v2.0** - Localization, premium features, social features (opt-in)

## 📚 Complete Documentation

**📋 [Documentation Index](docs/INDEX.md)** - Master navigation for all 35+ documentation files

### For Developers & AI Coding Sessions

**Quick Start:**
- **AI Specifications:** [CLAUDE.md](CLAUDE.md) - Complete project spec for AI assistants
- **Quick Reference:** [docs/QUICK-REFERENCE.md](docs/QUICK-REFERENCE.md) - Cheat sheet for common tasks
- **Documentation Index:** [docs/INDEX.md](docs/INDEX.md) - Find any documentation quickly

**Architecture & Design:**
- [Architecture Overview](docs/architecture/overview.md) - System design and principles
- [State Management (Riverpod)](docs/architecture/state-management.md) - Riverpod patterns and conventions
- [Data Layer (Hive)](docs/architecture/data-layer.md) - Models, repositories, persistence
- [Design System](docs/architecture/design-system.md) - Colors, typography, components

**Implementation Guides:**
- [Adding a Feature](docs/guides/adding-a-feature.md) - Step-by-step feature implementation
- [Working with Notifications](docs/guides/working-with-notifications.md) ⚠️ **Critical system**
- [Forms and Validation](docs/guides/forms-and-validation.md) - Form patterns and validation
- [Multi-Currency Support](docs/guides/multi-currency.md) - Currency conversion and display

**Templates & Examples:**
- [Feature Template](docs/templates/feature-template.md) - Implementation checklist
- [Screen with Controller](docs/templates/screen-with-controller.dart) - Annotated code example
- [Form Screen](docs/templates/form-screen.dart) - Form implementation example

**Architectural Decision Records:**
- [ADR 001: Riverpod Code Generation](docs/decisions/001-riverpod-code-generation.md) - Why code generation
- [ADR 002: Notification ID Strategy](docs/decisions/002-notification-id-strategy.md) - Deterministic IDs
- [ADR 003: Offline-First Architecture](docs/decisions/003-offline-first-architecture.md) - No cloud, no backend

---

## Contributing

This is a personal project, but feedback and suggestions are welcome! Please open an issue to discuss any changes.

## License

[To be determined]

## Contact

For questions or feedback about CustomSubs, please [open an issue](link-to-issues).

---

**Built with Flutter 💙 | Privacy-First 🔒 | Offline-Only 📵**
