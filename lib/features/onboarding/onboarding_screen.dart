import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/data/services/notification_service.dart';
import 'package:custom_subs/app/router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Page indicator
            Padding(
              padding: const EdgeInsets.all(AppSizes.base),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _OnboardingPage(
                    showLogo: true,
                    title: 'Welcome to CustomSubs',
                    subtitle:
                        'Track all your subscriptions in one place. No bank linking. No login. Just you and your bills.',
                  ),
                  _OnboardingPage(
                    icon: Icons.notifications_active_rounded,
                    title: 'Reminders that\nactually work',
                    subtitle:
                        'Get notified 7 days, 1 day, and the morning of every charge.',
                  ),
                  _OnboardingPage(
                    icon: Icons.cancel_rounded,
                    title: 'Take back control',
                    subtitle:
                        'Step-by-step cancellation guides for every subscription.',
                  ),
                ],
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Column(
                children: [
                  if (_currentPage < 2)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _completeOnboarding,
                            child: const Text('Skip'),
                          ),
                        ),
                        const SizedBox(width: AppSizes.base),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Text('Next'),
                          ),
                        ),
                      ],
                    ),
                  if (_currentPage == 2)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _completeOnboarding,
                        child: const Text('Get Started'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData? icon;
  final bool showLogo;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    this.icon,
    this.showLogo = false,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo or Icon
          if (showLogo)
            Image.asset(
              'assets/images/CustomSubsLOGO.png',
              width: 200,
              height: 80,
              fit: BoxFit.contain,
            )
          else if (icon != null)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: AppColors.primary,
              ),
            ),
          const SizedBox(height: AppSizes.xxxl),

          // Title
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.base),

          // Subtitle
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
