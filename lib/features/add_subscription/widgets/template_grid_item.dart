import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/utils/service_icons.dart';
import 'package:custom_subs/core/widgets/subtle_pressable.dart';
import 'package:custom_subs/data/services/template_service.dart';

class TemplateGridItem extends StatelessWidget {
  final SubscriptionTemplate template;
  final VoidCallback onTap;

  const TemplateGridItem({
    super.key,
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(template.color);
    final hasCustomIcon = ServiceIcons.hasCustomIcon(template.name);

    return SubtlePressable(
      onPressed: onTap,
      scale: 0.985, // 1.5% scale down for template items
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sm,
            vertical: AppSizes.base,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Colored avatar with icon or first letter
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withValues(alpha: 0.2),
                child: hasCustomIcon
                    ? Icon(
                        ServiceIcons.getIconForService(template.name),
                        color: color,
                        size: 30,
                      )
                    : Text(
                        template.name[0].toUpperCase(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: AppSizes.sm),

              // Service name
              Text(
                template.name,
                style: theme.textTheme.titleSmall,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.xs),

              // Price and cycle
              Text(
                '\$${template.defaultAmount.toStringAsFixed(2)}/${template.defaultCycle.shortName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
