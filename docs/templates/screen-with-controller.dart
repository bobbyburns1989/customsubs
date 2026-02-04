// TEMPLATE: Screen with Riverpod AsyncNotifier Controller
//
// This is a fully annotated example of a screen with controller pattern.
// Copy and modify for your feature implementation.
//
// This example shows an Analytics screen that displays subscription spending data.

// ============================================================================
// CONTROLLER FILE: analytics_controller.dart
// ============================================================================

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/models/subscription.dart';

// REQUIRED: Part directive for code generation
// Format: '[filename].g.dart' (without the original .dart extension)
part 'analytics_controller.g.dart';

/// Data model for analytics screen state.
///
/// **Pattern**: Create a dedicated data class when your state has multiple fields.
/// This is cleaner than returning a Map or List<dynamic>.
///
/// **Alternative**: If your state is simple (single List or primitive), you can
/// return it directly from build() without wrapping in a model.
class AnalyticsData {
  final double monthlyTotal;
  final double yearlyTotal;
  final Map<SubscriptionCategory, double> byCategory;
  final List<Subscription> topSubscriptions;

  const AnalyticsData({
    required this.monthlyTotal,
    required this.yearlyTotal,
    required this.byCategory,
    required this.topSubscriptions,
  });
}

/// Controller for Analytics screen using Riverpod code generation.
///
/// **Pattern**: AsyncNotifier for screens that need:
/// - Async data initialization
/// - User interaction methods
/// - Computed properties
///
/// **When NOT to use**: Simple forms with local state only (use StatefulWidget).
@riverpod
class AnalyticsController extends _$AnalyticsController {
  // ========================================================================
  // BUILD METHOD - Runs once on initialization
  // ========================================================================

  /// Initializes the controller state.
  ///
  /// **Called automatically** when the controller is first accessed.
  /// Returns FutureOr<T> - can be sync or async.
  ///
  /// **ref.watch() here**: Creates a reactive dependency. When the watched
  /// provider changes, build() will re-run automatically.
  ///
  /// **ref.read() in methods**: One-time access, doesn't create dependency.
  @override
  Future<AnalyticsData> build() async {
    // Watch repository - rebuilds when repository changes
    // Use .future to await the FutureProvider
    final repository = await ref.watch(subscriptionRepositoryProvider.future);

    // Calculate initial data
    return _calculateAnalytics(repository);
  }

  // ========================================================================
  // MUTATION METHODS - Update state based on user actions
  // ========================================================================

  /// Refreshes analytics data from repository.
  ///
  /// **Pattern**: Mutation methods should:
  /// 1. Set loading state (optional but good UX)
  /// 2. Perform async operation
  /// 3. Update state with new data or error
  ///
  /// **AsyncValue.guard()**: Automatically wraps result in AsyncValue.data()
  /// or AsyncValue.error() if exception is thrown.
  Future<void> refresh() async {
    // Set loading state while refreshing
    state = const AsyncValue.loading();

    // Use AsyncValue.guard for automatic error handling
    state = await AsyncValue.guard(() async {
      // Use ref.read() for one-time access in methods (not reactive)
      final repository = await ref.read(subscriptionRepositoryProvider.future);
      return _calculateAnalytics(repository);
    });
  }

  // ========================================================================
  // COMPUTED PROPERTIES - Derive data from current state
  // ========================================================================

  /// Gets the total monthly spending.
  ///
  /// **Pattern**: Computed properties are pure functions that read from state.
  /// They're NOT cached - called each time. Don't perform expensive operations here.
  ///
  /// **state.value**: Nullable. Returns null if loading or error.
  /// Always provide a default value with ?? operator.
  double getTotalMonthlySpending() {
    final data = state.value;
    return data?.monthlyTotal ?? 0.0;
  }

  /// Gets the category with highest spending.
  ///
  /// **Pattern**: Return nullable types when value might not exist.
  SubscriptionCategory? getTopCategory() {
    final data = state.value;
    if (data == null || data.byCategory.isEmpty) return null;

    return data.byCategory.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // ========================================================================
  // PRIVATE HELPER METHODS
  // ========================================================================

  /// Calculates analytics data from repository.
  ///
  /// **Pattern**: Extract complex logic into private methods for testability
  /// and readability. Keep build() and mutation methods clean.
  AnalyticsData _calculateAnalytics(SubscriptionRepository repository) {
    final monthlyTotal = repository.calculateMonthlyTotal();
    final yearlyTotal = monthlyTotal * 12;
    final byCategory = repository.getSpendingByCategory();

    // Get top 5 subscriptions by monthly equivalent
    final allSubs = repository.getAllActive();
    final sorted = List<Subscription>.from(allSubs)
      ..sort((a, b) => b.effectiveMonthlyAmount.compareTo(a.effectiveMonthlyAmount));
    final topSubscriptions = sorted.take(5).toList();

    return AnalyticsData(
      monthlyTotal: monthlyTotal,
      yearlyTotal: yearlyTotal,
      byCategory: byCategory,
      topSubscriptions: topSubscriptions,
    );
  }
}

// ============================================================================
// SCREEN FILE: analytics_screen.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_subs/features/analytics/analytics_controller.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:intl/intl.dart';

/// Analytics screen showing subscription spending breakdown.
///
/// **Pattern**: Use ConsumerWidget for screens that read providers.
/// Gives access to WidgetRef via build() parameter.
///
/// **Alternative**: ConsumerStatefulWidget if you also need local state
/// (e.g., TextEditingControllers, scroll controllers).
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ======================================================================
    // WATCHING STATE - Makes widget rebuild when state changes
    // ======================================================================

    /// **ref.watch()**: Widget rebuilds when provider value changes.
    /// Returns AsyncValue<T> with three states: loading, data, error.
    final analyticsState = ref.watch(analyticsControllerProvider);

    return Scaffold(
      // ====================================================================
      // APP BAR
      // ====================================================================
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          // Refresh button - calls controller method
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // **ref.read()**: Access controller without rebuilding.
              // Use .notifier to access the controller instance.
              ref.read(analyticsControllerProvider.notifier).refresh();
            },
          ),
        ],
      ),

      // ====================================================================
      // BODY - Handle all AsyncValue states
      // ====================================================================

      /// **AsyncValue.when()**: Pattern match on loading/data/error states.
      /// Must handle all three cases.
      body: analyticsState.when(
        // DATA STATE - Success, display content
        data: (analyticsData) => _buildContent(context, ref, analyticsData),

        // LOADING STATE - Show spinner
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        // ERROR STATE - Show error message
        error: (error, stackTrace) => _buildError(context, error),
      ),
    );
  }

  // ========================================================================
  // CONTENT BUILDERS - Keep build() clean by extracting large widgets
  // ========================================================================

  /// Builds the main content when data is available.
  ///
  /// **Pattern**: Extract complex layouts into separate methods.
  /// Makes code more readable and testable.
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AnalyticsData data,
  ) {
    // Check for empty state
    if (data.topSubscriptions.isEmpty) {
      return _buildEmptyState(context);
    }

    // Use RefreshIndicator for pull-to-refresh
    return RefreshIndicator(
      onRefresh: () async {
        // Call refresh and wait for completion
        await ref.read(analyticsControllerProvider.notifier).refresh();
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.base),
        children: [
          // Monthly total card
          _buildTotalCard(context, ref, data),
          const SizedBox(height: AppSizes.base),

          // Category breakdown
          _buildCategorySection(context, data),
          const SizedBox(height: AppSizes.base),

          // Top subscriptions
          _buildTopSubscriptionsSection(context, data),
        ],
      ),
    );
  }

  /// Builds the monthly total summary card.
  Widget _buildTotalCard(
    BuildContext context,
    WidgetRef ref,
    AnalyticsData data,
  ) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      // Use theme colors and sizes from constants
      elevation: AppSizes.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          children: [
            // Label
            Text(
              'Monthly Total',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.sm),

            // Amount - use large display style
            Text(
              currencyFormat.format(data.monthlyTotal),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.xs),

            // Subscription count
            Text(
              '${data.topSubscriptions.length} active subscriptions',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),

            // Divider
            const Divider(height: AppSizes.xxl),

            // Yearly forecast
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Yearly forecast: ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  currencyFormat.format(data.yearlyTotal),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the category breakdown section.
  Widget _buildCategorySection(BuildContext context, AnalyticsData data) {
    // Sort categories by spending (highest first)
    final sortedCategories = data.byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.base),

            // Category list
            ...sortedCategories.map((entry) {
              final percentage = (entry.value / data.monthlyTotal) * 100;
              return _buildCategoryTile(
                context,
                entry.key,
                entry.value,
                percentage,
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Builds a single category tile.
  Widget _buildCategoryTile(
    BuildContext context,
    SubscriptionCategory category,
    double amount,
    double percentage,
  ) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: [
          // Category name
          Expanded(
            child: Text(
              category.displayName,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),

          // Amount
          Text(
            currencyFormat.format(amount),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: AppSizes.sm),

          // Percentage
          Text(
            '(${percentage.toStringAsFixed(0)}%)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  /// Builds the top subscriptions section.
  Widget _buildTopSubscriptionsSection(BuildContext context, AnalyticsData data) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Expensive',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.base),

            // Top subscriptions list
            ...data.topSubscriptions.asMap().entries.map((entry) {
              final index = entry.key;
              final sub = entry.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Color(sub.colorValue),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(sub.name),
                subtitle: Text('${sub.cycle.displayName}'),
                trailing: Text(
                  currencyFormat.format(sub.effectiveMonthlyAmount),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Builds the empty state when no subscriptions exist.
  ///
  /// **Pattern**: Always provide helpful empty states.
  /// Tell users what to do next.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSizes.base),
            Text(
              'No spending data yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Add subscriptions to see your analytics',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the error state.
  ///
  /// **Pattern**: Clear error messages with recovery options.
  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSizes.base),
            Text(
              'Error loading analytics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.base),

            // Retry button
            ElevatedButton.icon(
              onPressed: () {
                // Trigger refresh - this is a ConsumerWidget, need to get ref somehow
                // In practice, you'd wrap this in a Consumer or use ConsumerStatefulWidget
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// KEY PATTERNS DEMONSTRATED
// ============================================================================
//
// 1. **AsyncNotifier Controller**
//    - build() for initialization
//    - Mutation methods for user actions
//    - Computed properties for derived data
//
// 2. **State Access**
//    - ref.watch() in build() for reactive updates
//    - ref.read() in methods for one-time access
//    - state.value with null checks for safe access
//
// 3. **AsyncValue Handling**
//    - .when() for complete pattern matching
//    - Loading/data/error states all handled
//
// 4. **UI Organization**
//    - Extract complex widgets to methods
//    - Use constants for spacing and colors
//    - Provide empty and error states
//
// 5. **Code Generation**
//    - @riverpod annotation
//    - part directive
//    - Run: dart run build_runner build
//
// ============================================================================
// CUSTOMIZATION CHECKLIST
// ============================================================================
//
// To adapt this template for your feature:
//
// [ ] Replace "Analytics" with your feature name
// [ ] Replace AnalyticsData with your data model
// [ ] Update _calculateAnalytics() with your data logic
// [ ] Modify computed properties for your needs
// [ ] Customize UI widgets for your layout
// [ ] Update empty/error states for your context
// [ ] Add any additional mutation methods
// [ ] Run code generation: dart run build_runner build
// [ ] Add route to router.dart
// [ ] Test all states: loading, data, error, empty
//
// ============================================================================
