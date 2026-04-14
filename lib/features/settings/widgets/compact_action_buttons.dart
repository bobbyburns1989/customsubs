import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:custom_subs/core/extensions/theme_extensions.dart';
import 'package:custom_subs/core/utils/haptic_utils.dart';
import 'package:custom_subs/data/services/analytics_service.dart';
import 'package:custom_subs/l10n/generated/app_localizations.dart';

/// Three circular action buttons displayed at the top of the settings screen:
/// Share, Rate App, and Feedback.
///
/// Adapted from CustomBank's CompactActionButtons for CustomSubs conventions
/// (Riverpod, context.colors, HapticUtils, url_launcher mailto).
class CompactActionButtons extends ConsumerStatefulWidget {
  const CompactActionButtons({super.key});

  @override
  ConsumerState<CompactActionButtons> createState() =>
      _CompactActionButtonsState();
}

class _CompactActionButtonsState extends ConsumerState<CompactActionButtons> {
  // GlobalKey for iOS share sheet anchor positioning
  final GlobalKey _shareButtonKey = GlobalKey();

  // Store links
  static const _appStoreId = '6758743032';
  static const _iosLink =
      'https://apps.apple.com/us/app/customsubs-bill-sub-tracker/id$_appStoreId';
  static const _androidLink =
      'https://play.google.com/store/apps/details?id=com.customsubs.app';

  // Feedback email
  static const _feedbackEmail = 'info@customapps.us';

  /// Opens the native share sheet with the appropriate store link.
  Future<void> _shareApp() async {
    await HapticUtils.medium();

    ref.read(analyticsServiceProvider).capture('share_app', {
      'source': 'settings',
    });

    final appLink = Platform.isIOS ? _iosLink : _androidLink;
    final shareMessage =
        'I use CustomSubs to track all my subscriptions — free & offline! $appLink';

    // Anchor share sheet to button position on iOS to avoid iPad crash
    Rect? sharePositionOrigin;
    if (Platform.isIOS) {
      final RenderBox? renderBox =
          _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        sharePositionOrigin = Rect.fromLTWH(
          position.dx,
          position.dy,
          renderBox.size.width,
          renderBox.size.height,
        );
      }
    }

    await SharePlus.instance.share(
      ShareParams(
        text: shareMessage,
        subject: 'CustomSubs — Subscription Tracker',
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  /// Opens the App Store / Play Store listing for rating.
  /// Uses openStoreListing (not requestReview) since this is an explicit user action.
  Future<void> _rateApp() async {
    await HapticUtils.medium();

    ref.read(analyticsServiceProvider).capture('rate_app_tapped', {
      'source': 'settings',
    });

    try {
      final inAppReview = InAppReview.instance;
      await inAppReview.openStoreListing(appStoreId: _appStoreId);
    } catch (_) {
      // Silently fail — store listing unavailable on this device.
    }
  }

  /// Opens the user's email client with a pre-filled feedback template.
  Future<void> _openFeedback() async {
    await HapticUtils.medium();

    ref.read(analyticsServiceProvider).capture('feedback_tapped', {
      'source': 'settings',
    });

    final subject = Uri.encodeComponent('CustomSubs Feedback');
    final body = Uri.encodeComponent(
      '\n\n---\nPlatform: ${Platform.operatingSystem}\n'
      'OS Version: ${Platform.operatingSystemVersion}\n',
    );

    final mailtoUri = Uri.parse('mailto:$_feedbackEmail?subject=$subject&body=$body');
    try {
      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri);
      }
    } catch (_) {
      // Silently fail — email client unavailable on this device.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    // Blue for Rate — distinct from sage green primary
    const rateBlue = Color(0xFF3B82F6);
    const rateBlueDark = Color(0xFF2563EB);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.share,
            label: l10n.settingsShare,
            gradientColors: [colors.primary, colors.primaryDark],
            onTap: _shareApp,
            buttonKey: _shareButtonKey,
          ),
          _buildActionButton(
            icon: Icons.star,
            label: l10n.settingsRateApp,
            gradientColors: const [rateBlue, rateBlueDark],
            onTap: _rateApp,
          ),
          _buildActionButton(
            icon: Icons.mail_outline,
            label: l10n.settingsFeedback,
            gradientColors: [
              colors.warning,
              Color.lerp(colors.warning, Colors.black, 0.15)!,
            ],
            onTap: _openFeedback,
          ),
        ],
      ),
    );
  }

  /// Builds a single circular gradient button with an icon and label below.
  /// 56px circle, gradient fill, colored shadow, 48px+ tap target.
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    Key? buttonKey,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              button: true,
              label: label,
              child: GestureDetector(
                key: buttonKey,
                onTap: onTap,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
