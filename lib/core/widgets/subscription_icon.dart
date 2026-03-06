import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/utils/service_icons.dart';

/// Renders a subscription brand icon with a three-tier fallback:
///
/// 1. **Local SVG asset** (`assets/logos/{iconName}.svg`) — for brands whose
///    icons were removed from Simple Icons (Disney+, Microsoft, Adobe, etc.)
/// 2. **SimpleIcons** brand icon — font-based SVG, fully offline
/// 3. **Letter avatar** — first character of [name] in [color]
///
/// Used in five locations:
/// - Home upcoming tile (circle, 48px)
/// - Home paused tile (circle, 48px, 50% opacity wrapper)
/// - Home later tile (circle, 40px, 75% opacity wrapper)
/// - Template picker grid (circle, 56px)
/// - Subscription detail header (rounded rect, 80px)
/// - Add subscription live preview (circle, 48px)
///
/// ## Shape
/// - [isCircle] = true → circular container (all list tiles + template grid)
/// - [isCircle] = false → rounded-rect container (detail header)
///
/// ## Hero animation
/// Wrap in a [Hero] at the call site with tag `'subscription-icon-\$id'`.
class SubscriptionIcon extends StatelessWidget {
  /// Display name of the subscription (used for letter fallback).
  final String name;

  /// Template iconName from subscription_templates.json.
  /// Null for custom (user-created) subscriptions.
  final String? iconName;

  /// Brand / accent color for the icon tint and background gradient.
  final Color color;

  /// Total container size in logical pixels.
  final double size;

  /// Circle (true) or rounded-rect (false) container shape.
  final bool isCircle;

  const SubscriptionIcon({
    super.key,
    required this.name,
    required this.color,
    this.iconName,
    this.size = 48,
    this.isCircle = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.22),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildChild(theme),
    );
  }

  Widget _buildChild(ThemeData theme) {
    // ----- Tier 1: local SVG asset -----
    // Used for brands removed from Simple Icons (Disney+, Microsoft, etc.).
    // Activate a logo by adding it to ServiceIcons._localLogoIconNames and
    // dropping the SVG file in assets/logos/.
    if (ServiceIcons.hasLocalLogo(iconName)) {
      return _LocalLogoImage(
        path: ServiceIcons.getLocalLogoPath(iconName!),
        size: size,
        isCircle: isCircle,
        fallback: _buildSimpleIconOrLetter(theme),
      );
    }

    // ----- Tier 2 + 3: SimpleIcons or letter -----
    return _buildSimpleIconOrLetter(theme);
  }

  Widget _buildSimpleIconOrLetter(ThemeData theme) {
    final brandIcon = ServiceIcons.getIconForIconName(iconName)
        ?? ServiceIcons.getIconByName(name);

    final iconSize = size * 0.52;
    final letterSize = size * 0.42;

    if (brandIcon != null) {
      return Center(
        child: Icon(brandIcon, color: color, size: iconSize),
      );
    }

    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: theme.textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: letterSize,
          height: 1.0,
        ),
      ),
    );
  }
}

/// Internal widget that loads a local SVG or PNG logo asset.
///
/// Clips to circle or rounded rect to match the parent [SubscriptionIcon]
/// container shape. Falls back to [fallback] if the asset file is missing
/// (PNG only — SVG assets are bundled and always present).
class _LocalLogoImage extends StatelessWidget {
  final String path;
  final double size;
  final bool isCircle;
  final Widget fallback;

  const _LocalLogoImage({
    required this.path,
    required this.size,
    required this.isCircle,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    // Padding lets the gradient background show as a subtle border ring
    // around the logo, which matches the SimpleIcons style.
    final padding = size * 0.14;
    final innerSize = size - padding * 2;

    final Widget content;
    if (path.endsWith('.svg')) {
      content = SvgPicture.asset(
        path,
        width: innerSize,
        height: innerSize,
        fit: BoxFit.contain,
      );
    } else {
      content = Image.asset(
        path,
        width: innerSize,
        height: innerSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    // Clip the content to match the container shape.
    final clipped = isCircle
        ? ClipOval(child: content)
        : ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            child: content,
          );

    return Padding(
      padding: EdgeInsets.all(padding),
      child: clipped,
    );
  }
}
