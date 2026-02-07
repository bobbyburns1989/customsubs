import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';

/// Static skeleton box for loading states
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppSizes.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton for subscription tile (matches _SubscriptionTile layout)
class SkeletonSubscriptionTile extends StatelessWidget {
  const SkeletonSubscriptionTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.base,
        vertical: AppSizes.xs,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.lg),
        child: Row(
          children: [
            // Icon placeholder (48x48 circle)
            SkeletonBox(
              width: 48,
              height: 48,
              borderRadius: AppSizes.radiusFull,
            ),
            SizedBox(width: AppSizes.base),

            // Name and amount placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 120, height: 16, borderRadius: AppSizes.radiusSm),
                  SizedBox(height: AppSizes.xs),
                  SkeletonBox(width: 80, height: 14, borderRadius: AppSizes.radiusSm),
                ],
              ),
            ),

            // Date placeholder
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SkeletonBox(width: 60, height: 14, borderRadius: AppSizes.radiusSm),
                SizedBox(height: 4),
                SkeletonBox(width: 50, height: 12, borderRadius: AppSizes.radiusSm),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for analytics category bar
class SkeletonCategoryBar extends StatelessWidget {
  const SkeletonCategoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: 10, height: 10, borderRadius: AppSizes.radiusFull),
              SizedBox(width: AppSizes.md),
              SkeletonBox(width: 100, height: 14, borderRadius: AppSizes.radiusSm),
              Spacer(),
              SkeletonBox(width: 60, height: 14, borderRadius: AppSizes.radiusSm),
            ],
          ),
          SizedBox(height: AppSizes.md),
          SkeletonBox(width: double.infinity, height: 32, borderRadius: AppSizes.radiusSm),
        ],
      ),
    );
  }
}

/// Skeleton for template grid item
class SkeletonTemplateItem extends StatelessWidget {
  const SkeletonTemplateItem({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.base),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SkeletonBox(width: 48, height: 48, borderRadius: AppSizes.radiusFull),
            SizedBox(height: AppSizes.md),
            SkeletonBox(width: 80, height: 14, borderRadius: AppSizes.radiusSm),
            SizedBox(height: AppSizes.xs),
            SkeletonBox(width: 60, height: 12, borderRadius: AppSizes.radiusSm),
          ],
        ),
      ),
    );
  }
}
