import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/data/services/notification_service.dart';
import 'package:custom_subs/app/router.dart';
import 'package:custom_subs/core/utils/haptic_utils.dart';

/// Single-screen onboarding that introduces key features.
///
/// Shows:
/// - Welcome message
/// - 3 key features (tracking, reminders, cancellation)
/// - Get Started CTA with privacy note
///
/// On completion:
/// - Requests notification permissions
/// - Marks onboarding as seen
/// - Navigates to home screen
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();

    // Initialize staggered fade-in animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Create staggered animations for each section
    _fadeAnimations = List.generate(5, (index) {
      final start = index * 0.15;
      final end = start + 0.4;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    // Start animations
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await HapticUtils.medium(); // Primary action feedback

    // Request notification permissions
    final notificationService = await ref.read(notificationServiceProvider.future);
    await notificationService.requestPermissions();

    // Mark onboarding as complete
    final settingsBox = await Hive.openBox('settings');
    await settingsBox.put('hasSeenOnboarding', true);

    if (mounted) {
      context.go(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.lg,
                  vertical: AppSizes.base,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                // Header Section: Welcome Message
                FadeTransition(
                  opacity: _fadeAnimations[0],
                  child: Column(
                    children: [
                      // Logo with enhanced presentation
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                          child: Image.asset(
                            'assets/images/new_app_icon.png',
                            width: 110,
                            height: 110,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Welcome message
                      Text(
                        'Welcome to CustomSubs',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.sm),

                      Text(
                        'Your private subscription tracker',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                // Feature 1: Track Everything
                FadeTransition(
                  opacity: _fadeAnimations[1],
                  child: const _FeatureCard(
                    icon: Icons.dashboard_rounded,
                    title: 'Track Everything',
                    description:
                        'All your subscriptions in one place. No bank linking. No login.',
                  ),
                ),

                const SizedBox(height: AppSizes.sm),

                // Feature 2: Smart Reminders
                FadeTransition(
                  opacity: _fadeAnimations[2],
                  child: const _FeatureCard(
                    icon: Icons.notifications_active_rounded,
                    title: 'Never Miss a Charge',
                    description:
                        'Get notified 7 days before, 1 day before, and the morning of every billing date.',
                  ),
                ),

                const SizedBox(height: AppSizes.sm),

                // Feature 3: Easy Cancellation
                FadeTransition(
                  opacity: _fadeAnimations[3],
                  child: const _FeatureCard(
                    icon: Icons.exit_to_app_rounded,
                    title: 'Cancel with Confidence',
                    description:
                        'Step-by-step guides to cancel any subscription quickly.',
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                // CTA Section: Button + Privacy Note
                FadeTransition(
                  opacity: _fadeAnimations[4],
                  child: Column(
                    children: [
                      // Get Started Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _completeOnboarding,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.base,
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Privacy Note
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Text(
                            '100% offline • No account required',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
          ),
        ),
      ),
    );
  }
}

/// Feature card component showing an icon, title, and description.
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
