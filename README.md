# CustomSubs - Privacy-First Subscription Tracker

<div align="center">
  <img src="assets/images/CustomSubsLOGO.png" alt="CustomSubs Logo" width="300"/>

  A beautiful, privacy-first subscription tracker for iOS and Android.

  **No accounts • No cloud sync • No tracking • 100% offline**
</div>

## Overview

CustomSubs is a mobile application designed to help you track and manage your subscriptions with complete privacy. All your data stays on your device - no servers, no accounts, no tracking, no internet connection required.

### Key Features

✅ **Currently Implemented (Phase 1 - In Progress)**
- 📱 Clean Material 3 UI with custom theming
- ➕ Add/Edit subscriptions with 40+ pre-populated templates
- 🎨 Color customization with 12 vibrant colors
- 🎯 **Service icons** - 50+ popular services display recognizable icons (Netflix, Spotify, Disney+, etc.)
- 💰 Multi-currency support (30+ currencies with bundled exchange rates)
- 🔔 Smart notification system with timezone support
- 📅 Multiple billing cycles (weekly, biweekly, monthly, quarterly, biannual, yearly)
- 🎁 Free trial tracking with post-trial amount
- 📋 Cancellation management (URLs, phone numbers, checklists)
- 🏠 Home screen with spending summary and subscription list
- 🔍 Template search and quick subscription creation
- 📝 Custom notes and detailed subscription info
- ✨ Real-time home screen refresh after adding subscriptions

🚧 **In Development**
- 📊 Subscription detail screen with full management
- 💾 Backup and restore functionality
- 📈 Analytics and spending insights
- 📱 iOS and Android app icons

🔮 **Planned (Phase 2-3)**
- 📊 Category-based spending breakdown
- 📉 Monthly/yearly spending trends
- 🎯 Smart reminders (customizable timing)
- 🌙 Dark mode support

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

For detailed architecture documentation, see [ARCHITECTURE.md](ARCHITECTURE.md).

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

See [CLAUDE.md](CLAUDE.md) for the complete specification and implementation plan.

**Phase 1 - Core MVP** (In Progress)
- [x] Project setup and architecture
- [x] Data models and repositories
- [x] Home screen with spending summary
- [x] Add/Edit subscription screen with templates
- [x] Service icons for 50+ popular services
- [x] Real-time home screen refresh
- [x] Template grid overflow fixes
- [x] NotificationService initialization fixes
- [ ] Subscription detail screen
- [ ] Complete notification system testing on devices

**Phase 2 - Data Safety**
- [ ] Backup and restore
- [ ] Currency picker
- [ ] Trial mode polish

**Phase 3 - Analytics & Polish**
- [ ] Analytics screen with charts
- [ ] Hero animations
- [ ] Micro-interactions
- [ ] Beta testing

## 📚 Complete Documentation

### For Developers & AI Coding Sessions

**Quick Start:**
- **AI Specifications:** [CLAUDE.md](CLAUDE.md) - Complete project spec for AI assistants
- **Quick Reference:** [docs/QUICK-REFERENCE.md](docs/QUICK-REFERENCE.md) - Cheat sheet for common tasks

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
