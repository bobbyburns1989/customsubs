// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CustomSubs';

  @override
  String get sectionUpcoming => 'Upcoming';

  @override
  String get sectionLater => 'Later';

  @override
  String get sectionPaused => 'Paused';

  @override
  String get sectionSpendingSummary => 'Spending Summary';

  @override
  String get navAddNew => 'Add New';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryProductivity => 'Productivity';

  @override
  String get categoryFitness => 'Fitness';

  @override
  String get categoryNews => 'News';

  @override
  String get categoryCloud => 'Cloud Storage';

  @override
  String get categoryGaming => 'Gaming';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryFinance => 'Finance';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryUtilities => 'Utilities';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryOther => 'Other';

  @override
  String get categorySports => 'Sports';

  @override
  String get cycleWeekly => 'Weekly';

  @override
  String get cycleBiweekly => 'Biweekly';

  @override
  String get cycleMonthly => 'Monthly';

  @override
  String get cycleQuarterly => 'Quarterly';

  @override
  String get cycleBiannual => 'Biannual';

  @override
  String get cycleYearly => 'Yearly';

  @override
  String get cycleShortWeekly => 'wk';

  @override
  String get cycleShortBiweekly => '2wk';

  @override
  String get cycleShortMonthly => 'mo';

  @override
  String get cycleShortQuarterly => 'qtr';

  @override
  String get cycleShortBiannual => '6mo';

  @override
  String get cycleShortYearly => 'yr';

  @override
  String get onboardingWelcome => 'Welcome to CustomSubs';

  @override
  String get onboardingSubtitle => 'Your private subscription tracker';

  @override
  String get onboardingFeature1Title => 'Track Everything';

  @override
  String get onboardingFeature1Desc =>
      'All your subscriptions in one place. No bank linking. No login.';

  @override
  String get onboardingFeature2Title => 'Never Miss a Charge';

  @override
  String get onboardingFeature2Desc =>
      'Get notified 7 days before, 1 day before, and the morning of every billing date.';

  @override
  String get onboardingFeature3Title => 'Cancel with Confidence';

  @override
  String get onboardingFeature3Desc =>
      'Step-by-step guides to cancel any subscription quickly.';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingPrivacyNote => '100% offline • No account required';

  @override
  String get homeTitle => 'CustomSubs';

  @override
  String get homeEmptyTitle => 'No subscriptions yet';

  @override
  String get homeEmptySubtitle =>
      'Tap + to add your first one. We\'ll remind you before every charge.';

  @override
  String get homeAddSubscription => 'Add Subscription';

  @override
  String get homeDeleteTitle => 'Delete Subscription';

  @override
  String get homeDeleteCancel => 'Cancel';

  @override
  String get homeDeleteConfirm => 'Delete';

  @override
  String get homePaid => 'Paid';

  @override
  String get homeMarkAsPaid => 'Mark as Paid';

  @override
  String get homeMarkedAsPaid => 'Marked as paid ✓';

  @override
  String get homePerMonth => '/month';

  @override
  String get homePerYear => '/year';

  @override
  String get homePerDay => '/day';

  @override
  String homeError(String error) {
    return 'Error: $error';
  }

  @override
  String homePaidCount(int paid, int total) {
    return 'Paid · $paid of $total';
  }

  @override
  String get homeNext30Days => 'next 30 days';

  @override
  String get homeLaterDays => '31–90 days';

  @override
  String homePausedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paused',
      one: '1 paused',
    );
    return '$_temp0';
  }

  @override
  String get homeResumesToday => 'Resumes today';

  @override
  String get homeResumesTomorrow => 'Resumes tomorrow';

  @override
  String homeResumesInDays(int days) {
    return 'Resumes in $days days';
  }

  @override
  String homePausedDaysAgo(int days) {
    return 'Paused $days days ago';
  }

  @override
  String get homePausedManualResume => 'Resume manually';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsShare => 'Share';

  @override
  String get settingsRateApp => 'Rate App';

  @override
  String get settingsFeedback => 'Feedback';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsPrimaryCurrency => 'Primary Currency';

  @override
  String settingsCurrencyChanged(String currency) {
    return 'Currency changed to $currency';
  }

  @override
  String settingsCurrencyRestored(String currency) {
    return 'Currency restored to $currency';
  }

  @override
  String get settingsDefaultReminderTime => 'Default Reminder Time';

  @override
  String get settingsReminderTimeUpdated => 'Reminder time updated';

  @override
  String get settingsReminderTimeRestored => 'Reminder time restored';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System Default';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsTestNotification => 'Test Notification';

  @override
  String get settingsTestNotificationSubtitle => 'Verify reminders are working';

  @override
  String get settingsNotificationsDisabled => 'Notifications Disabled';

  @override
  String get settingsNotificationsDisabledBody =>
      'Notifications are currently disabled for CustomSubs. Enable them in device settings to receive billing reminders.';

  @override
  String get settingsNotNow => 'Not Now';

  @override
  String get settingsOpenSettings => 'Open Settings';

  @override
  String get settingsTestSent => 'Test Sent';

  @override
  String get settingsTestSentBody =>
      'A test notification was just sent.\n\nDon\'t see it? Notifications may be disabled in your device settings.';

  @override
  String get settingsGotIt => 'Got It';

  @override
  String get settingsNotificationsHelp =>
      'CustomSubs sends reminders at your chosen time before billing dates. Make sure notifications are enabled in your device settings.';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsShareAnalytics => 'Share Anonymous Usage Data';

  @override
  String get settingsShareAnalyticsSubtitle =>
      'Helps us improve the app. No personal data is collected.';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsLastBackup => 'Last Backup';

  @override
  String get settingsNeverBackedUp => 'Never backed up';

  @override
  String get settingsExportBackup => 'Export Backup';

  @override
  String get settingsExportBackupSubtitle =>
      'Save your subscriptions to a file';

  @override
  String get settingsPreparingBackup => 'Preparing backup...';

  @override
  String get settingsBackupSuccess => 'Backup exported successfully!';

  @override
  String settingsBackupError(String error) {
    return 'Failed to export backup: $error';
  }

  @override
  String get settingsImportBackup => 'Import Backup';

  @override
  String get settingsImportBackupSubtitle =>
      'Restore subscriptions from a file';

  @override
  String get settingsImportComplete => 'Import Complete';

  @override
  String settingsImportFound(int count) {
    return 'Found: $count subscriptions';
  }

  @override
  String settingsImportDuplicates(int count) {
    return 'Duplicates skipped: $count';
  }

  @override
  String settingsImportImported(int count) {
    return 'Imported: $count subscriptions';
  }

  @override
  String settingsImportSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subscriptions could not be imported due to invalid data.',
      one: '1 subscription could not be imported due to invalid data.',
    );
    return '$_temp0';
  }

  @override
  String get settingsImportNotifications =>
      'Notifications have been scheduled for all imported subscriptions.';

  @override
  String get settingsOk => 'OK';

  @override
  String get settingsDeleteAll => 'Delete All Data';

  @override
  String get settingsDeleteAllSubtitle =>
      'Permanently delete all subscriptions';

  @override
  String get settingsDeleteAllTitle => 'Delete All Data?';

  @override
  String get settingsDeleteAllBody =>
      'This will permanently delete all subscriptions and settings. This cannot be undone.\n\nAre you sure you want to continue?';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsContinue => 'Continue';

  @override
  String get settingsFinalConfirmation => 'Final Confirmation';

  @override
  String get settingsFinalConfirmationBody =>
      'This action is irreversible. All your subscription data will be lost forever.';

  @override
  String get settingsTypeDelete => 'Type DELETE to confirm:';

  @override
  String get settingsDeleteHint => 'DELETE';

  @override
  String get settingsDeleteButton => 'Delete All';

  @override
  String get settingsTypeDeleteWarning => 'Please type DELETE to confirm';

  @override
  String get settingsAllDataDeleted => 'All data deleted successfully';

  @override
  String settingsDeleteError(String error) {
    return 'Failed to delete data: $error';
  }

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsMadeWith => 'Made with love by CustomApps LLC';

  @override
  String get settingsDeveloperTools => 'Developer Tools';

  @override
  String get settingsLoadDemoData => 'Load Demo Data';

  @override
  String get settingsLoadDemoDataSubtitle => 'Add 18 sample subscriptions';

  @override
  String get settingsClearDemoData => 'Clear Demo Data';

  @override
  String get settingsClearDemoDataSubtitle => 'Remove only demo subscriptions';

  @override
  String get settingsDeveloperUnlocked => 'Developer tools unlocked';

  @override
  String get settingsLoadDemoTitle => 'Load Demo Data?';

  @override
  String get settingsLoadDemoBody =>
      'This will add 18 sample subscriptions to your app. Existing subscriptions will not be affected.\n\nDemo subscriptions are tagged and can be removed with \"Clear Demo Data\".';

  @override
  String get settingsLoad => 'Load';

  @override
  String settingsLoadedDemoCount(int count) {
    return 'Loaded $count demo subscriptions';
  }

  @override
  String settingsLoadDemoError(String error) {
    return 'Failed to load demo data: $error';
  }

  @override
  String get settingsClearDemoTitle => 'Clear Demo Data?';

  @override
  String settingsClearDemoBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'This will remove $count demo subscriptions. Your real subscriptions will not be affected.',
      one:
          'This will remove 1 demo subscription. Your real subscriptions will not be affected.',
    );
    return '$_temp0';
  }

  @override
  String get settingsClear => 'Clear';

  @override
  String settingsClearedDemoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cleared $count demo subscriptions',
      one: 'Cleared 1 demo subscription',
    );
    return '$_temp0';
  }

  @override
  String settingsClearDemoError(String error) {
    return 'Failed to clear demo data: $error';
  }

  @override
  String get settingsNoDemoFound => 'No demo subscriptions found';

  @override
  String get backupReminderTitle => 'Back Up Your Data';

  @override
  String get backupReminderBody =>
      'You\'ve added 3 subscriptions! Consider backing up your data to prevent loss.';

  @override
  String get backupReminderHint =>
      'You can export a backup anytime in Settings → Export Backup.';

  @override
  String get backupReminderDontShow => 'Don\'t show this again';

  @override
  String get backupReminderGotIt => 'Got it';

  @override
  String get promoTitle => 'More from CustomApps';

  @override
  String get promoSubtitle => 'Check out our other apps';

  @override
  String get promoCouldNotOpen => 'Could not open website';

  @override
  String get promoCustomBank => 'CustomBank';

  @override
  String get promoCustomBankDesc => 'Banking simulator, no real money';

  @override
  String get promoCustomCrypto => 'CustomCrypto';

  @override
  String get promoCustomCryptoDesc => 'Crypto paper trader';

  @override
  String get promoCustomDashboards => 'CustomDashboards';

  @override
  String get promoCustomDashboardsDesc => 'E-commerce dashboard simulator';

  @override
  String get promoCustomNotify => 'CustomNotify';

  @override
  String get promoCustomNotifyDesc => 'Smart reminders & alerts';

  @override
  String get promoCustomWorth => 'CustomWorth';

  @override
  String get promoCustomWorthDesc => 'Track your net worth';

  @override
  String get addSubscriptionTitle => 'Add Subscription';

  @override
  String get editSubscriptionTitle => 'Edit Subscription';

  @override
  String get addSubscriptionSave => 'Save';

  @override
  String get addSubscriptionChooseTemplate => 'Choose from templates';

  @override
  String get addSubscriptionSearchHint => 'Search services...';

  @override
  String get addSubscriptionNoTemplates => 'No templates found';

  @override
  String get addSubscriptionNoTemplatesHint =>
      'Try a different search term or create a custom subscription below';

  @override
  String get addSubscriptionCreateCustom => 'Create Custom';

  @override
  String get addSubscriptionInvalidData => 'Please enter valid data';

  @override
  String get addSubscriptionAdded => 'Subscription added!';

  @override
  String get addSubscriptionUpdated => 'Subscription updated!';

  @override
  String addSubscriptionError(String error) {
    return 'Error: $error';
  }

  @override
  String get addSubscriptionButton => 'Add Subscription';

  @override
  String get updateSubscriptionButton => 'Update Subscription';

  @override
  String get addSubscriptionTemplateError => 'Error loading templates';

  @override
  String get detailsSection => 'Subscription Details';

  @override
  String get detailsNameLabel => 'Name *';

  @override
  String get detailsNameHint => 'Netflix, Spotify, etc.';

  @override
  String get detailsNameValidation => 'Please enter a name';

  @override
  String get detailsAmountLabel => 'Amount *';

  @override
  String get detailsAmountHint => '0.00';

  @override
  String get detailsAmountRequired => 'Required';

  @override
  String get detailsAmountInvalid => 'Invalid amount';

  @override
  String get detailsCurrencyLabel => 'Currency';

  @override
  String get detailsBillingCycleLabel => 'Billing Cycle *';

  @override
  String get detailsNextBillingDateLabel => 'Next Billing Date *';

  @override
  String get detailsCategoryLabel => 'Category *';

  @override
  String get trialSectionTitle => 'Free Trial';

  @override
  String get trialSectionSubtitle => 'Track trial period and conversion date';

  @override
  String get trialToggleLabel => 'This is a free trial';

  @override
  String get trialToggleSubtitle =>
      'Enable if subscription is currently in trial period';

  @override
  String get trialEndDateLabel => 'Trial End Date';

  @override
  String get trialSetEndDate => 'Set Trial End Date';

  @override
  String get trialAmountAfter => 'Amount after trial';

  @override
  String get cancelSectionTitle => 'Cancellation Info';

  @override
  String get cancelSectionSubtitle => 'How to cancel this subscription';

  @override
  String get cancelUrlLabel => 'Cancellation URL';

  @override
  String get cancelUrlHint => 'https://...';

  @override
  String get cancelPhoneLabel => 'Cancellation Phone';

  @override
  String get cancelPhoneHint => '+1 (555) 123-4567';

  @override
  String get cancelNotesLabel => 'Cancellation Notes';

  @override
  String get cancelNotesHint => 'How to cancel...';

  @override
  String get cancelStepsTitle => 'Cancellation Steps';

  @override
  String get cancelAddStep => 'Add Step';

  @override
  String cancelStepLabel(int number) {
    return 'Step $number';
  }

  @override
  String get cancelStepHint => 'Enter step...';

  @override
  String get notesSectionTitle => 'Notes';

  @override
  String get notesSectionSubtitle => 'Add any additional notes';

  @override
  String get notesGeneralLabel => 'General Notes';

  @override
  String get notesGeneralHint => 'Add any additional notes...';

  @override
  String get reminderFirstLabel => 'First reminder';

  @override
  String get reminderSecondLabel => 'Second reminder';

  @override
  String get reminderOff => 'Off';

  @override
  String reminderDaysBefore(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days before',
      one: '1 day before',
    );
    return '$_temp0';
  }

  @override
  String get reminderOnBillingDay => 'Remind on billing day';

  @override
  String get reminderTimeLabel => 'Reminder time';

  @override
  String get detailScreenTitle => 'Details';

  @override
  String get detailNotFound => 'Subscription not found';

  @override
  String get detailDeleteTitle => 'Delete Subscription?';

  @override
  String get detailDeleteBody =>
      'This will permanently delete this subscription and cancel all reminders. This cannot be undone.';

  @override
  String get detailDeleteButton => 'Delete';

  @override
  String get detailMarkedAsPaid => 'Marked as paid ✓';

  @override
  String get detailPauseTitle => 'Pause Subscription';

  @override
  String get detailPauseWhilePaused => 'While paused:';

  @override
  String get detailPauseNoReminders => 'No reminders will be sent';

  @override
  String get detailPauseNoBilling => 'Billing dates won\'t advance';

  @override
  String get detailPauseNoSpending => 'Excluded from spending totals';

  @override
  String get detailPauseAutoResume => 'Auto-resume date (optional):';

  @override
  String get detailPauseManual => 'Resume manually';

  @override
  String get detailPauseClearDate => 'Clear date';

  @override
  String get detailPauseButton => 'Pause';

  @override
  String get detailPaused => 'Subscription Paused';

  @override
  String detailAutoResumes(String date) {
    return 'Auto-resumes on $date';
  }

  @override
  String detailPausedDaysAgo(int days) {
    return 'Paused $days days ago';
  }

  @override
  String get detailResumeButton => 'Resume Subscription';

  @override
  String detailLoadError(String error) {
    return 'Error loading subscription: $error';
  }

  @override
  String get detailGoBack => 'Go Back';

  @override
  String get detailPaid => 'Paid';

  @override
  String get detailMarkAsPaid => 'Mark as Paid';

  @override
  String get billingInfoTitle => 'Billing Information';

  @override
  String get billingNextBilling => 'Next Billing';

  @override
  String get billingCycle => 'Billing Cycle';

  @override
  String get billingAmount => 'Amount';

  @override
  String get billingStarted => 'Started';

  @override
  String get billingTrialEnds => 'Trial Ends';

  @override
  String billingThenAmount(String amount, String cycle) {
    return 'Then $amount/$cycle';
  }

  @override
  String get headerTrialBadge => 'Trial';

  @override
  String get headerPaidBadge => 'Paid';

  @override
  String get cancelCardTitle => 'How to Cancel';

  @override
  String get cancelCardOpenPage => 'Open Cancellation Page';

  @override
  String cancelCardCall(String phone) {
    return 'Call $phone';
  }

  @override
  String get cancelCardStepsTitle => 'Cancellation Steps';

  @override
  String cancelCardProgress(int completed, int total) {
    return '$completed of $total complete';
  }

  @override
  String get reminderCardTitle => 'Reminder Settings';

  @override
  String get reminderCardFirst => 'First Reminder';

  @override
  String reminderCardFirstValue(int days) {
    return '$days days before';
  }

  @override
  String get reminderCardSecond => 'Second Reminder';

  @override
  String reminderCardSecondValue(int days) {
    return '$days days before';
  }

  @override
  String get reminderCardDayOf => 'Day-of Reminder';

  @override
  String get reminderCardEnabled => 'Enabled';

  @override
  String get reminderCardTime => 'Reminder Time';

  @override
  String get notesCardTitle => 'Notes';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarEmptyTitle => 'No Billing Dates';

  @override
  String get calendarEmptySubtitle =>
      'Add your first subscription to see billing dates on the calendar.';

  @override
  String get calendarAddSubscription => 'Add Subscription';

  @override
  String get calendarMonth => 'Month';

  @override
  String get calendarTapHint => 'Tap a date to see billing details';

  @override
  String calendarError(String error) {
    return 'Error: $error';
  }

  @override
  String get calendarNoBills => 'No bills on this date';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsEmptyTitle => 'No Analytics Yet';

  @override
  String get analyticsEmptySubtitle =>
      'Add your first subscription to see spending insights';

  @override
  String get analyticsAddSubscription => 'Add Subscription';

  @override
  String get analyticsLoadError => 'Error loading analytics';

  @override
  String get analyticsYearlyForecast => 'Yearly Forecast';

  @override
  String analyticsMonthlyTotal(String amount) {
    return '$amount/mo';
  }

  @override
  String analyticsSubsAndDaily(int count, String daily) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subscriptions',
      one: '1 subscription',
    );
    return '$_temp0 · $daily/day';
  }

  @override
  String get analyticsSpendingByCategory => 'Spending by Category';

  @override
  String get analyticsTopSubscriptions => 'Top Subscriptions';

  @override
  String get analyticsByCurrency => 'By Currency';

  @override
  String analyticsCurrencyEntry(String code, String symbol) {
    return '$code ($symbol)';
  }

  @override
  String analyticsTotalLabel(String currency) {
    return 'Total ($currency)';
  }

  @override
  String analyticsTotalApprox(String amount) {
    return '≈ $amount';
  }

  @override
  String get analyticsExchangeNote => 'At bundled exchange rates';

  @override
  String get analyticsActiveVsPaused => 'Active vs Paused';

  @override
  String analyticsActiveCount(int count) {
    return 'Active ($count)';
  }

  @override
  String analyticsPausedCount(int count) {
    return 'Paused ($count)';
  }

  @override
  String get analyticsIfResumed => 'If all resumed';

  @override
  String get analyticsMonthlyLabel => 'Monthly';

  @override
  String get insightsTitle => 'Smart Insights';

  @override
  String insightsOverlapSummary(int count, String group) {
    return '$count $group services';
  }

  @override
  String insightsOverlapCombined(String names, String amount) {
    return '$names = $amount/mo combined';
  }

  @override
  String insightsOverlapTitle(String group) {
    return 'Overlapping $group';
  }

  @override
  String insightsOverlapBody(int count, String group) {
    return 'You have $count $group subscriptions. These services offer similar content — you may only need one.';
  }

  @override
  String insightsOverlapCombinedDetail(String monthly, String yearly) {
    return 'Combined: $monthly/mo · $yearly/year';
  }

  @override
  String get insightsAnnualTitle => 'Switch to annual billing';

  @override
  String insightsAnnualSummary(String min, String max) {
    return 'Est. save $min–$max/year';
  }

  @override
  String get insightsAnnualHeading => 'Annual Billing Savings';

  @override
  String get insightsAnnualBody =>
      'Most services offer a 15–20% discount when you pay annually instead of monthly.';

  @override
  String insightsAnnualRange(String min, String max) {
    return '$min–$max';
  }

  @override
  String get insightsAnnualEstimated => 'estimated annual savings';

  @override
  String insightsAnnualAppliesTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Applies to $count monthly-billed subscriptions.',
      one: 'Applies to 1 monthly-billed subscription.',
    );
    return '$_temp0';
  }

  @override
  String get insightsAnnualDisclaimer =>
      '* Estimated based on a 15–20% typical discount. Check each provider\'s current annual pricing for exact savings.';

  @override
  String insightsBundleTitle(String name) {
    return '$name available';
  }

  @override
  String insightsBundleSummary(String amount) {
    return 'Save ~$amount/mo vs separate plans';
  }

  @override
  String get insightsBundleYouPayNow => 'You pay now';

  @override
  String get insightsBundleMonthlySavings => 'Monthly savings';

  @override
  String insightsBundleSavingsDetail(String amount) {
    return '~$amount/mo from last month';
  }

  @override
  String get insightsBundleDisclaimer =>
      '* Bundle price shown in USD. Check current pricing — promotions and regional pricing vary.';

  @override
  String get insightsBundleCheckPricing => 'Check current pricing';

  @override
  String insightsHighSpendSummary(String category, String percent) {
    return '$category = $percent% of spend';
  }

  @override
  String get insightsHighSpendSubtitle =>
      'One category dominates your subscription budget';

  @override
  String insightsHighSpendTitle(String category) {
    return '$category Spending';
  }

  @override
  String insightsHighSpendBody(
      String category, String percent, String monthly, String yearly) {
    return '$category accounts for $percent% of your active subscription spend — $monthly/mo ($yearly/year).';
  }

  @override
  String get insightsHighSpendListTitle => 'Subscriptions in this category:';

  @override
  String get dateToday => 'Today';

  @override
  String get dateTomorrow => 'Tomorrow';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String get dateOverdue => 'Overdue';

  @override
  String dateDaysAgo(int days) {
    return '$days days ago';
  }

  @override
  String dateWeeksAgo(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String dateInDays(int days) {
    return 'in $days days';
  }

  @override
  String dateInWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'in $weeks weeks',
      one: 'in 1 week',
    );
    return '$_temp0';
  }

  @override
  String dateInMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'in $months months',
      one: 'in 1 month',
    );
    return '$_temp0';
  }

  @override
  String notifFirstReminderTitle(String name, int days) {
    return '📅 $name — Billing in $days days';
  }

  @override
  String notifFirstReminderBody(String amount, String date) {
    return '$amount charges on $date';
  }

  @override
  String notifFirstReminderSubtitle(int days) {
    return 'Billing in $days days';
  }

  @override
  String notifFirstReminderExpanded(String amount, String date) {
    return '$amount charges on $date\n\nTap to view details or mark as paid.';
  }

  @override
  String notifSecondReminderTitleTomorrow(String name) {
    return '⚠️ $name — Bills tomorrow';
  }

  @override
  String notifSecondReminderTitle(String name, int days) {
    return '⚠️ $name — Bills in $days days';
  }

  @override
  String notifSecondReminderBody(String amount, String date) {
    return '$amount will be charged on $date';
  }

  @override
  String get notifSecondReminderSubtitleTomorrow => 'Bills tomorrow';

  @override
  String notifSecondReminderSubtitle(int days) {
    return 'Bills in $days days';
  }

  @override
  String notifSecondReminderExpanded(String amount, String date) {
    return '$amount will be charged on $date\n\nTap to view details or mark as paid.';
  }

  @override
  String notifDayOfTitle(String name) {
    return '💰 $name — Billing today';
  }

  @override
  String notifDayOfBody(String amount) {
    return '$amount charge expected today';
  }

  @override
  String get notifDayOfSubtitle => 'Billing today';

  @override
  String notifDayOfExpanded(String amount) {
    return '$amount charge expected today\n\nTap to view details or mark as paid.';
  }

  @override
  String notifTrialEnding3Days(String name) {
    return '🔔 $name — Trial ending in 3 days';
  }

  @override
  String notifTrialEndingTomorrow(String name) {
    return '🔔 $name — Trial ending tomorrow';
  }

  @override
  String notifTrialEndsToday(String name) {
    return '🔔 $name — Trial ends today';
  }

  @override
  String get notifTrialSubtitle => 'Trial ending';

  @override
  String notifTrialBody(String date, String amount, String cycle) {
    return 'Free trial ends $date. You\'ll be charged $amount/$cycle after.\n\nTap to view details or mark as paid.';
  }

  @override
  String get notifTestTitle => '✅ Notifications are working!';

  @override
  String get notifTestBody => 'You\'ll be reminded before every charge.';

  @override
  String get notifActionMarkPaid => 'Mark as Paid';

  @override
  String get notifActionViewDetails => 'View Details';

  @override
  String get notifChannelName => 'Subscription Reminders';

  @override
  String get notifChannelDesc =>
      'Notifications for upcoming subscription charges';
}
