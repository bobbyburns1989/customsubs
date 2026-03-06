# Subscription Logo Assets

PNG logos for services not covered by the `simple_icons` package
(brands that were removed from Simple Icons due to trademark requests).

## Naming convention
Files must be named exactly: `{iconName}.png`
where `{iconName}` matches the `iconName` field in `subscription_templates.json`.

Examples:
- `disney.png`     → Disney+
- `hulu.png`       → Hulu
- `microsoft.png`  → Microsoft 365
- `adobe.png`      → Adobe Creative Cloud
- `linkedin.png`   → LinkedIn Premium
- `xbox.png`       → Xbox Game Pass
- `nintendo.png`   → Nintendo Switch Online
- `bumble.png`     → Bumble

## Spec
- Format: PNG with transparent background
- Size: 512×512 px (will be scaled down at runtime)
- Source: Official press kits or brandfetch.com

## Adding a new logo
1. Drop the PNG file here (e.g. `disney.png`)
2. Add the iconName to `_localLogoIconNames` in:
   `lib/core/utils/service_icons.dart`
3. Run `flutter pub get` to rebuild the asset bundle
