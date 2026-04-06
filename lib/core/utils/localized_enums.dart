import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/l10n/generated/app_localizations.dart';

/// Locale-aware display names for [SubscriptionCategory].
///
/// Use `.localizedName(l10n)` in UI code instead of `.displayName` so that
/// category labels render in the user's selected language. The original
/// `.displayName` getter is kept for serialization (backup export, analytics).
extension LocalizedCategory on SubscriptionCategory {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case SubscriptionCategory.entertainment:
        return l10n.categoryEntertainment;
      case SubscriptionCategory.productivity:
        return l10n.categoryProductivity;
      case SubscriptionCategory.fitness:
        return l10n.categoryFitness;
      case SubscriptionCategory.news:
        return l10n.categoryNews;
      case SubscriptionCategory.cloud:
        return l10n.categoryCloud;
      case SubscriptionCategory.gaming:
        return l10n.categoryGaming;
      case SubscriptionCategory.education:
        return l10n.categoryEducation;
      case SubscriptionCategory.finance:
        return l10n.categoryFinance;
      case SubscriptionCategory.shopping:
        return l10n.categoryShopping;
      case SubscriptionCategory.utilities:
        return l10n.categoryUtilities;
      case SubscriptionCategory.health:
        return l10n.categoryHealth;
      case SubscriptionCategory.other:
        return l10n.categoryOther;
      case SubscriptionCategory.sports:
        return l10n.categorySports;
    }
  }
}

/// Locale-aware display names for [SubscriptionCycle].
///
/// Use `.localizedName(l10n)` and `.localizedShortName(l10n)` in UI code
/// instead of `.displayName` / `.shortName` so that cycle labels render
/// in the user's selected language.
extension LocalizedCycle on SubscriptionCycle {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case SubscriptionCycle.weekly:
        return l10n.cycleWeekly;
      case SubscriptionCycle.biweekly:
        return l10n.cycleBiweekly;
      case SubscriptionCycle.monthly:
        return l10n.cycleMonthly;
      case SubscriptionCycle.quarterly:
        return l10n.cycleQuarterly;
      case SubscriptionCycle.biannual:
        return l10n.cycleBiannual;
      case SubscriptionCycle.yearly:
        return l10n.cycleYearly;
    }
  }

  String localizedShortName(AppLocalizations l10n) {
    switch (this) {
      case SubscriptionCycle.weekly:
        return l10n.cycleShortWeekly;
      case SubscriptionCycle.biweekly:
        return l10n.cycleShortBiweekly;
      case SubscriptionCycle.monthly:
        return l10n.cycleShortMonthly;
      case SubscriptionCycle.quarterly:
        return l10n.cycleShortQuarterly;
      case SubscriptionCycle.biannual:
        return l10n.cycleShortBiannual;
      case SubscriptionCycle.yearly:
        return l10n.cycleShortYearly;
    }
  }
}
