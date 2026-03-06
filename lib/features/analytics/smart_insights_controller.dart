import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';
import 'package:custom_subs/core/providers/settings_provider.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Computes offline subscription optimization insights.
///
/// Functional FutureProvider (no @riverpod codegen) so build_runner is not needed.
/// Automatically re-computes when the subscription repository or primary currency changes.
final smartInsightsProvider = FutureProvider.autoDispose<SmartInsightsData>((ref) async {
  final repository = await ref.watch(subscriptionRepositoryProvider.future);
  final subs = repository.getAllActive();
  final primaryCurrency = ref.watch(primaryCurrencyProvider);
  final bundles = await _loadBundles();

  return SmartInsightsData(
    overlaps: _detectOverlaps(subs, primaryCurrency),
    annualSavings: _calculateAnnualSavings(subs, primaryCurrency),
    bundleOpportunities: _detectBundles(subs, bundles, primaryCurrency),
    highSpendCategory: _detectHighSpendCategory(subs, primaryCurrency),
  );
});

// ---------------------------------------------------------------------------
// Public Data Models
// ---------------------------------------------------------------------------

/// Container for all computed insights. Returned by [smartInsightsProvider].
class SmartInsightsData {
  final List<OverlapInsight> overlaps;

  /// Null when the user has no monthly-cycle subscriptions.
  final AnnualSavingsInsight? annualSavings;

  final List<BundleInsight> bundleOpportunities;

  /// Null when no category exceeds [_highSpendThreshold] of total spend.
  final HighSpendInsight? highSpendCategory;

  const SmartInsightsData({
    required this.overlaps,
    required this.annualSavings,
    required this.bundleOpportunities,
    required this.highSpendCategory,
  });

  /// True when at least one insight is available to display.
  bool get hasAnyInsight =>
      overlaps.isNotEmpty ||
      annualSavings != null ||
      bundleOpportunities.isNotEmpty ||
      highSpendCategory != null;
}

/// Represents multiple subscriptions in the same service category (e.g., 2 music streamers).
class OverlapInsight {
  /// Human-readable label, e.g. "music streaming", "video streaming".
  final String groupLabel;

  /// Display names of the overlapping subscriptions.
  final List<String> names;

  /// Combined monthly cost in the user's primary currency.
  final double combinedMonthly;

  const OverlapInsight({
    required this.groupLabel,
    required this.names,
    required this.combinedMonthly,
  });
}

/// Estimated annual savings if monthly-billed subscriptions switch to annual plans.
class AnnualSavingsInsight {
  /// Low-end savings estimate (15% discount).
  final double minSavings;

  /// High-end savings estimate (20% discount).
  final double maxSavings;

  /// How many monthly-cycle subscriptions this applies to.
  final int subscriptionCount;

  const AnnualSavingsInsight({
    required this.minSavings,
    required this.maxSavings,
    required this.subscriptionCount,
  });
}

/// A known bundle that covers services the user already pays for separately.
class BundleInsight {
  final String bundleName;

  /// Official bundle price per month (USD).
  final double bundleAmount;

  /// What the user currently pays for the matched components (primary currency).
  final double currentCost;

  /// currentCost - bundleAmount. Always positive (negative bundles are filtered out).
  final double potentialSavings;

  final String description;

  /// Informational URL for the bundle's official page.
  final String? url;

  const BundleInsight({
    required this.bundleName,
    required this.bundleAmount,
    required this.currentCost,
    required this.potentialSavings,
    required this.description,
    required this.url,
  });
}

/// A single category that dominates the user's subscription spending.
class HighSpendInsight {
  /// e.g. "Entertainment"
  final String categoryName;

  /// 0–100 percentage of total active monthly spend.
  final double percentage;

  /// Monthly amount for this category in primary currency.
  final double monthlyAmount;

  /// Display names of subscriptions in this category.
  final List<String> subscriptionNames;

  const HighSpendInsight({
    required this.categoryName,
    required this.percentage,
    required this.monthlyAmount,
    required this.subscriptionNames,
  });
}

// ---------------------------------------------------------------------------
// Internal: Bundle Definition (parsed from bundles.json)
// ---------------------------------------------------------------------------

class _BundleDefinition {
  final String id;
  final String name;
  final double amount;
  final String currency;
  final List<String> components;
  final int minComponentsRequired;
  final String description;
  final String? url;

  const _BundleDefinition({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.components,
    required this.minComponentsRequired,
    required this.description,
    required this.url,
  });

  factory _BundleDefinition.fromJson(Map<String, dynamic> json) {
    return _BundleDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      components: (json['components'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      minComponentsRequired: json['minComponentsRequired'] as int,
      description: json['description'] as String,
      url: json['url'] as String?,
    );
  }
}

// ---------------------------------------------------------------------------
// Internal: Bundle loading (module-level cache — loaded once per app session)
// ---------------------------------------------------------------------------

List<_BundleDefinition>? _cachedBundles;

Future<List<_BundleDefinition>> _loadBundles() async {
  if (_cachedBundles != null) return _cachedBundles!;
  final jsonString = await rootBundle.loadString('assets/data/bundles.json');
  final data = json.decode(jsonString) as Map<String, dynamic>;
  _cachedBundles = (data['bundles'] as List<dynamic>)
      .map((e) => _BundleDefinition.fromJson(e as Map<String, dynamic>))
      .toList();
  return _cachedBundles!;
}

// ---------------------------------------------------------------------------
// Internal: Service overlap groups
// ---------------------------------------------------------------------------

/// Minimum number of subscriptions in a group before flagging as overlap.
const _videoOverlapThreshold = 3; // 2 video services is common; 3+ is worth surfacing
const _musicOverlapThreshold = 2; // 2 music services is always redundant
const _cloudOverlapThreshold = 3; // 2 cloud services is fine; 3+ is excess

/// iconName sets for each service category.
/// Use lowercased iconNames matching [Subscription.iconName].
const _videoServices = {
  'netflix', 'hulu', 'disney', 'hbo', 'peacock', 'paramount',
  'apple_tv', 'tubi', 'sling', 'funimation', 'crunchyroll', 'mubi',
  'youtube', 'britbox', 'acorn', 'shudder',
};

const _musicServices = {
  'spotify', 'apple_music', 'youtube_music', 'amazon_music',
  'tidal', 'pandora', 'deezer', 'soundcloud',
};

const _cloudServices = {
  'icloud', 'google_one', 'google_drive', 'dropbox', 'onedrive', 'box',
};

// ---------------------------------------------------------------------------
// Insight 1: Overlap Detection
// ---------------------------------------------------------------------------

List<OverlapInsight> _detectOverlaps(
  List<Subscription> subs,
  String primaryCurrency,
) {
  final insights = <OverlapInsight>[];

  void checkGroup(
    String label,
    Set<String> group,
    int threshold,
  ) {
    // Only match subs that have an iconName (template-based; custom subs are skipped)
    final matched = subs.where((s) {
      final icon = s.iconName?.toLowerCase();
      return icon != null && group.contains(icon);
    }).toList();

    if (matched.length < threshold) return;

    final combinedMonthly = matched.fold<double>(0.0, (sum, s) {
      return sum +
          CurrencyUtils.convert(
            s.effectiveMonthlyAmount,
            s.currencyCode,
            primaryCurrency,
          );
    });

    insights.add(OverlapInsight(
      groupLabel: label,
      names: matched.map((s) => s.name).toList(),
      combinedMonthly: combinedMonthly,
    ));
  }

  checkGroup('music streaming', _musicServices, _musicOverlapThreshold);
  checkGroup('video streaming', _videoServices, _videoOverlapThreshold);
  checkGroup('cloud storage', _cloudServices, _cloudOverlapThreshold);

  return insights;
}

// ---------------------------------------------------------------------------
// Insight 2: Annual Billing Savings Calculator
// ---------------------------------------------------------------------------

AnnualSavingsInsight? _calculateAnnualSavings(
  List<Subscription> subs,
  String primaryCurrency,
) {
  // Only monthly-cycle subscriptions benefit from switching to annual billing.
  // Weekly/biweekly/quarterly etc. don't typically have a simple annual upgrade.
  final monthlySubs = subs
      .where((s) => s.cycle == SubscriptionCycle.monthly)
      .toList();

  if (monthlySubs.isEmpty) return null;

  final totalMonthly = monthlySubs.fold<double>(0.0, (sum, s) {
    return sum +
        CurrencyUtils.convert(
          s.effectiveMonthlyAmount,
          s.currencyCode,
          primaryCurrency,
        );
  });

  // Industry standard annual discount ranges 15–20%
  return AnnualSavingsInsight(
    minSavings: totalMonthly * 12 * 0.15,
    maxSavings: totalMonthly * 12 * 0.20,
    subscriptionCount: monthlySubs.length,
  );
}

// ---------------------------------------------------------------------------
// Insight 3: Bundle Detection
// ---------------------------------------------------------------------------

List<BundleInsight> _detectBundles(
  List<Subscription> subs,
  List<_BundleDefinition> bundles,
  String primaryCurrency,
) {
  // Build a set of the user's iconNames for fast lookup
  final userIconNames = subs
      .map((s) => s.iconName?.toLowerCase())
      .whereType<String>()
      .toSet();

  final insights = <BundleInsight>[];

  for (final bundle in bundles) {
    // Determine which of the bundle's components the user has
    final matchedComponents = bundle.components
        .where(userIconNames.contains)
        .toList();

    if (matchedComponents.length < bundle.minComponentsRequired) continue;

    // Sum what the user currently pays for those matched components
    final currentCost = subs
        .where((s) => matchedComponents.contains(s.iconName?.toLowerCase()))
        .fold<double>(0.0, (sum, s) {
      return sum +
          CurrencyUtils.convert(
            s.effectiveMonthlyAmount,
            s.currencyCode,
            primaryCurrency,
          );
    });

    // Convert bundle price to primary currency for fair comparison
    // Bundle prices are in USD; convert to the user's primary currency
    final bundleAmountConverted = CurrencyUtils.convert(
      bundle.amount,
      bundle.currency,
      primaryCurrency,
    );

    final savings = currentCost - bundleAmountConverted;

    // Only surface a bundle if the user would actually save money
    if (savings <= 0) continue;

    insights.add(BundleInsight(
      bundleName: bundle.name,
      bundleAmount: bundleAmountConverted,
      currentCost: currentCost,
      potentialSavings: savings,
      description: bundle.description,
      url: bundle.url,
    ));
  }

  // Sort by largest savings first
  insights.sort((a, b) => b.potentialSavings.compareTo(a.potentialSavings));
  return insights;
}

// ---------------------------------------------------------------------------
// Insight 4: High-Spend Category Flag
// ---------------------------------------------------------------------------

/// A category is flagged when it accounts for at least this fraction of total spend.
const _highSpendThreshold = 0.40; // 40%

HighSpendInsight? _detectHighSpendCategory(
  List<Subscription> subs,
  String primaryCurrency,
) {
  if (subs.isEmpty) return null;

  final total = subs.fold<double>(0.0, (sum, s) {
    return sum +
        CurrencyUtils.convert(
          s.effectiveMonthlyAmount,
          s.currencyCode,
          primaryCurrency,
        );
  });
  if (total == 0) return null;

  // Group subscriptions by category
  final byCategory = <SubscriptionCategory, List<Subscription>>{};
  for (final sub in subs) {
    byCategory.putIfAbsent(sub.category, () => []).add(sub);
  }

  // Find the category with the highest spend that exceeds the threshold
  HighSpendInsight? topInsight;
  double topPercentage = 0;

  for (final entry in byCategory.entries) {
    // Skip "other" — it's a catch-all and not actionable
    if (entry.key == SubscriptionCategory.other) continue;

    final catTotal = entry.value.fold<double>(0.0, (sum, s) {
      return sum +
          CurrencyUtils.convert(
            s.effectiveMonthlyAmount,
            s.currencyCode,
            primaryCurrency,
          );
    });

    final pct = catTotal / total * 100;

    if (pct >= _highSpendThreshold * 100 && pct > topPercentage) {
      topPercentage = pct;
      topInsight = HighSpendInsight(
        categoryName: entry.key.displayName,
        percentage: pct,
        monthlyAmount: catTotal,
        subscriptionNames: entry.value.map((s) => s.name).toList(),
      );
    }
  }

  return topInsight;
}
