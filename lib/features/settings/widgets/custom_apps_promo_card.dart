import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/extensions/theme_extensions.dart';
import 'package:custom_subs/core/widgets/standard_card.dart';
import 'package:custom_subs/core/utils/haptic_utils.dart';
import 'package:custom_subs/core/utils/snackbar_utils.dart';

/// Data class for sibling apps displayed in the cross-promotion card.
class _AppInfo {
  final String name;
  final String subtitle;
  final String websiteUrl;
  final String logoAsset;
  final Color brandColor; // fallback background when logo PNG is missing

  const _AppInfo({
    required this.name,
    required this.subtitle,
    required this.websiteUrl,
    required this.logoAsset,
    required this.brandColor,
  });
}

/// Static list of sibling apps to promote (excludes CustomSubs — the current app).
const _apps = [
  _AppInfo(
    name: 'CustomBank',
    subtitle: 'Banking simulator — no real money',
    websiteUrl: 'https://custombank.us',
    logoAsset: 'assets/images/custombank_logo.png',
    brandColor: Color(0xFF3B82F6), // blue
  ),
  _AppInfo(
    name: 'CustomCrypto',
    subtitle: 'Practice Crypto Trading',
    websiteUrl: 'https://customcrypto.us',
    logoAsset: 'assets/images/customcrypto_logo.png',
    brandColor: Color(0xFFF59E0B), // amber
  ),
  _AppInfo(
    name: 'CustomNotify',
    subtitle: 'Smart reminders & alerts',
    websiteUrl: 'https://customnotify.us',
    logoAsset: 'assets/images/customnotify_logo.png',
    brandColor: Color(0xFFCDA434), // gold
  ),
  _AppInfo(
    name: 'CustomWorth',
    subtitle: 'Track your net worth',
    websiteUrl: 'https://customworth.com',
    logoAsset: 'assets/images/customworth_logo.png',
    brandColor: Color(0xFF8B5CF6), // violet
  ),
];

/// Collapsible cross-promotion card showcasing other CustomApps LLC products.
///
/// Collapsed by default — shows a single tappable header row. Expanding reveals
/// 3 sibling app rows with logos, descriptions, and external website links.
/// Placed in the Settings screen above the "Made with love" footer.
class CustomAppsPromoCard extends StatefulWidget {
  const CustomAppsPromoCard({super.key});

  @override
  State<CustomAppsPromoCard> createState() => _CustomAppsPromoCardState();
}

class _CustomAppsPromoCardState extends State<CustomAppsPromoCard> {
  bool _isExpanded = false;

  void _toggleExpansion() {
    HapticUtils.light();
    setState(() => _isExpanded = !_isExpanded);
  }

  /// Opens the app's website in an external browser.
  /// Shows an error snackbar if the URL cannot be launched.
  Future<void> _openWebsite(String url) async {
    await HapticUtils.light();
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        SnackBarUtils.show(
          context,
          SnackBarUtils.error('Could not open website'),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.show(
          context,
          SnackBarUtils.error('Could not open website'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.base),
      child: StandardCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tappable header — always visible
            GestureDetector(
              onTap: _toggleExpansion,
              behavior: HitTestBehavior.opaque,
              child: _buildHeader(theme),
            ),

            // Expandable app list
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Column(
                      children: [
                        Divider(height: 1, color: context.colors.border),
                        for (int i = 0; i < _apps.length; i++) ...[
                          if (i > 0)
                            Divider(height: 1, color: context.colors.border),
                          _buildAppRow(_apps[i]),
                        ],
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  /// Header row with icon, title/subtitle, and animated chevron.
  /// Matches the FormSectionCard header pattern for visual consistency.
  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Row(
        children: [
          // Icon in circular container — matches FormSectionCard pattern
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.colors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.apps_rounded,
              size: 20,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(width: AppSizes.base),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'More from CustomApps',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Check out our other apps',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Animated chevron — rotates 180° when expanded
          AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Icon(
              Icons.expand_more,
              color: context.colors.textSecondary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  /// Individual app row with logo, name, subtitle, and trailing chevron.
  Widget _buildAppRow(_AppInfo app) {
    return InkWell(
      onTap: () => _openWebsite(app.websiteUrl),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.md,
        ),
        child: Row(
          children: [
            // App logo with fallback for missing assets
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                app.logoAsset,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: app.brandColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      app.name[0],
                      style: TextStyle(
                        color: app.brandColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.base),

            // Name + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    app.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing arrow
            Icon(
              Icons.chevron_right,
              color: context.colors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
