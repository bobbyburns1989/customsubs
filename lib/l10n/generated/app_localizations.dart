import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// App title
  ///
  /// In en, this message translates to:
  /// **'CustomSubs'**
  String get appTitle;

  /// No description provided for @sectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get sectionUpcoming;

  /// No description provided for @sectionLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get sectionLater;

  /// No description provided for @sectionPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get sectionPaused;

  /// No description provided for @sectionSpendingSummary.
  ///
  /// In en, this message translates to:
  /// **'Spending Summary'**
  String get sectionSpendingSummary;

  /// No description provided for @navAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get navAddNew;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryProductivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get categoryProductivity;

  /// No description provided for @categoryFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get categoryFitness;

  /// No description provided for @categoryNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get categoryNews;

  /// No description provided for @categoryCloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud Storage'**
  String get categoryCloud;

  /// No description provided for @categoryGaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get categoryGaming;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get categoryFinance;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get categoryUtilities;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @categorySports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get categorySports;

  /// No description provided for @cycleWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get cycleWeekly;

  /// No description provided for @cycleBiweekly.
  ///
  /// In en, this message translates to:
  /// **'Biweekly'**
  String get cycleBiweekly;

  /// No description provided for @cycleMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get cycleMonthly;

  /// No description provided for @cycleQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get cycleQuarterly;

  /// No description provided for @cycleBiannual.
  ///
  /// In en, this message translates to:
  /// **'Biannual'**
  String get cycleBiannual;

  /// No description provided for @cycleYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get cycleYearly;

  /// No description provided for @cycleShortWeekly.
  ///
  /// In en, this message translates to:
  /// **'wk'**
  String get cycleShortWeekly;

  /// No description provided for @cycleShortBiweekly.
  ///
  /// In en, this message translates to:
  /// **'2wk'**
  String get cycleShortBiweekly;

  /// No description provided for @cycleShortMonthly.
  ///
  /// In en, this message translates to:
  /// **'mo'**
  String get cycleShortMonthly;

  /// No description provided for @cycleShortQuarterly.
  ///
  /// In en, this message translates to:
  /// **'qtr'**
  String get cycleShortQuarterly;

  /// No description provided for @cycleShortBiannual.
  ///
  /// In en, this message translates to:
  /// **'6mo'**
  String get cycleShortBiannual;

  /// No description provided for @cycleShortYearly.
  ///
  /// In en, this message translates to:
  /// **'yr'**
  String get cycleShortYearly;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to CustomSubs'**
  String get onboardingWelcome;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your private subscription tracker'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingFeature1Title.
  ///
  /// In en, this message translates to:
  /// **'Track Everything'**
  String get onboardingFeature1Title;

  /// No description provided for @onboardingFeature1Desc.
  ///
  /// In en, this message translates to:
  /// **'All your subscriptions in one place. No bank linking. No login.'**
  String get onboardingFeature1Desc;

  /// No description provided for @onboardingFeature2Title.
  ///
  /// In en, this message translates to:
  /// **'Never Miss a Charge'**
  String get onboardingFeature2Title;

  /// No description provided for @onboardingFeature2Desc.
  ///
  /// In en, this message translates to:
  /// **'Get notified 7 days before, 1 day before, and the morning of every billing date.'**
  String get onboardingFeature2Desc;

  /// No description provided for @onboardingFeature3Title.
  ///
  /// In en, this message translates to:
  /// **'Cancel with Confidence'**
  String get onboardingFeature3Title;

  /// No description provided for @onboardingFeature3Desc.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step guides to cancel any subscription quickly.'**
  String get onboardingFeature3Desc;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'100% offline • No account required'**
  String get onboardingPrivacyNote;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'CustomSubs'**
  String get homeTitle;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions yet'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first one. We\'ll remind you before every charge.'**
  String get homeEmptySubtitle;

  /// No description provided for @homeAddSubscription.
  ///
  /// In en, this message translates to:
  /// **'Add Subscription'**
  String get homeAddSubscription;

  /// No description provided for @homeDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Subscription'**
  String get homeDeleteTitle;

  /// No description provided for @homeDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get homeDeleteCancel;

  /// No description provided for @homeDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get homeDeleteConfirm;

  /// No description provided for @homePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get homePaid;

  /// No description provided for @homeMarkAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get homeMarkAsPaid;

  /// No description provided for @homeMarkedAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Marked as paid ✓'**
  String get homeMarkedAsPaid;

  /// No description provided for @homePerMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get homePerMonth;

  /// No description provided for @homePerYear.
  ///
  /// In en, this message translates to:
  /// **'/year'**
  String get homePerYear;

  /// No description provided for @homePerDay.
  ///
  /// In en, this message translates to:
  /// **'/day'**
  String get homePerDay;

  /// No description provided for @homeError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String homeError(String error);

  /// No description provided for @homePaidCount.
  ///
  /// In en, this message translates to:
  /// **'Paid · {paid} of {total}'**
  String homePaidCount(int paid, int total);

  /// No description provided for @homeNext30Days.
  ///
  /// In en, this message translates to:
  /// **'next 30 days'**
  String get homeNext30Days;

  /// No description provided for @homeLaterDays.
  ///
  /// In en, this message translates to:
  /// **'31–90 days'**
  String get homeLaterDays;

  /// No description provided for @homePausedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 paused} other{{count} paused}}'**
  String homePausedCount(int count);

  /// No description provided for @homeResumesToday.
  ///
  /// In en, this message translates to:
  /// **'Resumes today'**
  String get homeResumesToday;

  /// No description provided for @homeResumesTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Resumes tomorrow'**
  String get homeResumesTomorrow;

  /// No description provided for @homeResumesInDays.
  ///
  /// In en, this message translates to:
  /// **'Resumes in {days} days'**
  String homeResumesInDays(int days);

  /// No description provided for @homePausedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Paused {days} days ago'**
  String homePausedDaysAgo(int days);

  /// No description provided for @homePausedManualResume.
  ///
  /// In en, this message translates to:
  /// **'Resume manually'**
  String get homePausedManualResume;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsPrimaryCurrency.
  ///
  /// In en, this message translates to:
  /// **'Primary Currency'**
  String get settingsPrimaryCurrency;

  /// No description provided for @settingsCurrencyChanged.
  ///
  /// In en, this message translates to:
  /// **'Currency changed to {currency}'**
  String settingsCurrencyChanged(String currency);

  /// No description provided for @settingsCurrencyRestored.
  ///
  /// In en, this message translates to:
  /// **'Currency restored to {currency}'**
  String settingsCurrencyRestored(String currency);

  /// No description provided for @settingsDefaultReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Default Reminder Time'**
  String get settingsDefaultReminderTime;

  /// No description provided for @settingsReminderTimeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Reminder time updated'**
  String get settingsReminderTimeUpdated;

  /// No description provided for @settingsReminderTimeRestored.
  ///
  /// In en, this message translates to:
  /// **'Reminder time restored'**
  String get settingsReminderTimeRestored;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get settingsLanguageFrench;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsTestNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get settingsTestNotification;

  /// No description provided for @settingsTestNotificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify reminders are working'**
  String get settingsTestNotificationSubtitle;

  /// No description provided for @settingsNotificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications Disabled'**
  String get settingsNotificationsDisabled;

  /// No description provided for @settingsNotificationsDisabledBody.
  ///
  /// In en, this message translates to:
  /// **'Notifications are currently disabled for CustomSubs. Enable them in device settings to receive billing reminders.'**
  String get settingsNotificationsDisabledBody;

  /// No description provided for @settingsNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get settingsNotNow;

  /// No description provided for @settingsOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get settingsOpenSettings;

  /// No description provided for @settingsTestSent.
  ///
  /// In en, this message translates to:
  /// **'Test Sent'**
  String get settingsTestSent;

  /// No description provided for @settingsTestSentBody.
  ///
  /// In en, this message translates to:
  /// **'A test notification was just sent.\n\nDon\'t see it? Notifications may be disabled in your device settings.'**
  String get settingsTestSentBody;

  /// No description provided for @settingsGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got It'**
  String get settingsGotIt;

  /// No description provided for @settingsNotificationsHelp.
  ///
  /// In en, this message translates to:
  /// **'CustomSubs sends reminders at your chosen time before billing dates. Make sure notifications are enabled in your device settings.'**
  String get settingsNotificationsHelp;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsShareAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Share Anonymous Usage Data'**
  String get settingsShareAnalytics;

  /// No description provided for @settingsShareAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Helps us improve the app. No personal data is collected.'**
  String get settingsShareAnalyticsSubtitle;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsLastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last Backup'**
  String get settingsLastBackup;

  /// No description provided for @settingsNeverBackedUp.
  ///
  /// In en, this message translates to:
  /// **'Never backed up'**
  String get settingsNeverBackedUp;

  /// No description provided for @settingsExportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get settingsExportBackup;

  /// No description provided for @settingsExportBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your subscriptions to a file'**
  String get settingsExportBackupSubtitle;

  /// No description provided for @settingsPreparingBackup.
  ///
  /// In en, this message translates to:
  /// **'Preparing backup...'**
  String get settingsPreparingBackup;

  /// No description provided for @settingsBackupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup exported successfully!'**
  String get settingsBackupSuccess;

  /// No description provided for @settingsBackupError.
  ///
  /// In en, this message translates to:
  /// **'Failed to export backup: {error}'**
  String settingsBackupError(String error);

  /// No description provided for @settingsImportBackup.
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get settingsImportBackup;

  /// No description provided for @settingsImportBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore subscriptions from a file'**
  String get settingsImportBackupSubtitle;

  /// No description provided for @settingsImportComplete.
  ///
  /// In en, this message translates to:
  /// **'Import Complete'**
  String get settingsImportComplete;

  /// No description provided for @settingsImportFound.
  ///
  /// In en, this message translates to:
  /// **'Found: {count} subscriptions'**
  String settingsImportFound(int count);

  /// No description provided for @settingsImportDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Duplicates skipped: {count}'**
  String settingsImportDuplicates(int count);

  /// No description provided for @settingsImportImported.
  ///
  /// In en, this message translates to:
  /// **'Imported: {count} subscriptions'**
  String settingsImportImported(int count);

  /// No description provided for @settingsImportSkipped.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 subscription could not be imported due to invalid data.} other{{count} subscriptions could not be imported due to invalid data.}}'**
  String settingsImportSkipped(int count);

  /// No description provided for @settingsImportNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications have been scheduled for all imported subscriptions.'**
  String get settingsImportNotifications;

  /// No description provided for @settingsOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get settingsOk;

  /// No description provided for @settingsDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get settingsDeleteAll;

  /// No description provided for @settingsDeleteAllSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all subscriptions'**
  String get settingsDeleteAllSubtitle;

  /// No description provided for @settingsDeleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data?'**
  String get settingsDeleteAllTitle;

  /// No description provided for @settingsDeleteAllBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all subscriptions and settings. This cannot be undone.\n\nAre you sure you want to continue?'**
  String get settingsDeleteAllBody;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @settingsContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get settingsContinue;

  /// No description provided for @settingsFinalConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Final Confirmation'**
  String get settingsFinalConfirmation;

  /// No description provided for @settingsFinalConfirmationBody.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. All your subscription data will be lost forever.'**
  String get settingsFinalConfirmationBody;

  /// No description provided for @settingsTypeDelete.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm:'**
  String get settingsTypeDelete;

  /// No description provided for @settingsDeleteHint.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get settingsDeleteHint;

  /// No description provided for @settingsDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get settingsDeleteButton;

  /// No description provided for @settingsTypeDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'Please type DELETE to confirm'**
  String get settingsTypeDeleteWarning;

  /// No description provided for @settingsAllDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'All data deleted successfully'**
  String get settingsAllDataDeleted;

  /// No description provided for @settingsDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete data: {error}'**
  String settingsDeleteError(String error);

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsMadeWith.
  ///
  /// In en, this message translates to:
  /// **'Made with love by CustomApps LLC'**
  String get settingsMadeWith;

  /// No description provided for @settingsDeveloperTools.
  ///
  /// In en, this message translates to:
  /// **'Developer Tools'**
  String get settingsDeveloperTools;

  /// No description provided for @settingsLoadDemoData.
  ///
  /// In en, this message translates to:
  /// **'Load Demo Data'**
  String get settingsLoadDemoData;

  /// No description provided for @settingsLoadDemoDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add 18 sample subscriptions'**
  String get settingsLoadDemoDataSubtitle;

  /// No description provided for @settingsClearDemoData.
  ///
  /// In en, this message translates to:
  /// **'Clear Demo Data'**
  String get settingsClearDemoData;

  /// No description provided for @settingsClearDemoDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove only demo subscriptions'**
  String get settingsClearDemoDataSubtitle;

  /// No description provided for @settingsDeveloperUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Developer tools unlocked'**
  String get settingsDeveloperUnlocked;

  /// No description provided for @settingsLoadDemoTitle.
  ///
  /// In en, this message translates to:
  /// **'Load Demo Data?'**
  String get settingsLoadDemoTitle;

  /// No description provided for @settingsLoadDemoBody.
  ///
  /// In en, this message translates to:
  /// **'This will add 18 sample subscriptions to your app. Existing subscriptions will not be affected.\n\nDemo subscriptions are tagged and can be removed with \"Clear Demo Data\".'**
  String get settingsLoadDemoBody;

  /// No description provided for @settingsLoad.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get settingsLoad;

  /// No description provided for @settingsLoadedDemoCount.
  ///
  /// In en, this message translates to:
  /// **'Loaded {count} demo subscriptions'**
  String settingsLoadedDemoCount(int count);

  /// No description provided for @settingsLoadDemoError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load demo data: {error}'**
  String settingsLoadDemoError(String error);

  /// No description provided for @settingsClearDemoTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Demo Data?'**
  String get settingsClearDemoTitle;

  /// No description provided for @settingsClearDemoBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This will remove 1 demo subscription. Your real subscriptions will not be affected.} other{This will remove {count} demo subscriptions. Your real subscriptions will not be affected.}}'**
  String settingsClearDemoBody(int count);

  /// No description provided for @settingsClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get settingsClear;

  /// No description provided for @settingsClearedDemoCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Cleared 1 demo subscription} other{Cleared {count} demo subscriptions}}'**
  String settingsClearedDemoCount(int count);

  /// No description provided for @settingsClearDemoError.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear demo data: {error}'**
  String settingsClearDemoError(String error);

  /// No description provided for @settingsNoDemoFound.
  ///
  /// In en, this message translates to:
  /// **'No demo subscriptions found'**
  String get settingsNoDemoFound;

  /// No description provided for @backupReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Back Up Your Data'**
  String get backupReminderTitle;

  /// No description provided for @backupReminderBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve added 3 subscriptions! Consider backing up your data to prevent loss.'**
  String get backupReminderBody;

  /// No description provided for @backupReminderHint.
  ///
  /// In en, this message translates to:
  /// **'You can export a backup anytime in Settings → Export Backup.'**
  String get backupReminderHint;

  /// No description provided for @backupReminderDontShow.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show this again'**
  String get backupReminderDontShow;

  /// No description provided for @backupReminderGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get backupReminderGotIt;

  /// No description provided for @promoTitle.
  ///
  /// In en, this message translates to:
  /// **'More from CustomApps'**
  String get promoTitle;

  /// No description provided for @promoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check out our other apps'**
  String get promoSubtitle;

  /// No description provided for @promoCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open website'**
  String get promoCouldNotOpen;

  /// No description provided for @promoCustomBank.
  ///
  /// In en, this message translates to:
  /// **'CustomBank'**
  String get promoCustomBank;

  /// No description provided for @promoCustomBankDesc.
  ///
  /// In en, this message translates to:
  /// **'Banking simulator — no real money'**
  String get promoCustomBankDesc;

  /// No description provided for @promoCustomCrypto.
  ///
  /// In en, this message translates to:
  /// **'CustomCrypto'**
  String get promoCustomCrypto;

  /// No description provided for @promoCustomCryptoDesc.
  ///
  /// In en, this message translates to:
  /// **'Practice Crypto Trading'**
  String get promoCustomCryptoDesc;

  /// No description provided for @promoCustomNotify.
  ///
  /// In en, this message translates to:
  /// **'CustomNotify'**
  String get promoCustomNotify;

  /// No description provided for @promoCustomNotifyDesc.
  ///
  /// In en, this message translates to:
  /// **'Smart reminders & alerts'**
  String get promoCustomNotifyDesc;

  /// No description provided for @promoCustomWorth.
  ///
  /// In en, this message translates to:
  /// **'CustomWorth'**
  String get promoCustomWorth;

  /// No description provided for @promoCustomWorthDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your net worth'**
  String get promoCustomWorthDesc;

  /// No description provided for @addSubscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Subscription'**
  String get addSubscriptionTitle;

  /// No description provided for @editSubscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Subscription'**
  String get editSubscriptionTitle;

  /// No description provided for @addSubscriptionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get addSubscriptionSave;

  /// No description provided for @addSubscriptionChooseTemplate.
  ///
  /// In en, this message translates to:
  /// **'Choose from templates'**
  String get addSubscriptionChooseTemplate;

  /// No description provided for @addSubscriptionSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search services...'**
  String get addSubscriptionSearchHint;

  /// No description provided for @addSubscriptionNoTemplates.
  ///
  /// In en, this message translates to:
  /// **'No templates found'**
  String get addSubscriptionNoTemplates;

  /// No description provided for @addSubscriptionNoTemplatesHint.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term or create a custom subscription below'**
  String get addSubscriptionNoTemplatesHint;

  /// No description provided for @addSubscriptionCreateCustom.
  ///
  /// In en, this message translates to:
  /// **'Create Custom'**
  String get addSubscriptionCreateCustom;

  /// No description provided for @addSubscriptionInvalidData.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid data'**
  String get addSubscriptionInvalidData;

  /// No description provided for @addSubscriptionAdded.
  ///
  /// In en, this message translates to:
  /// **'Subscription added!'**
  String get addSubscriptionAdded;

  /// No description provided for @addSubscriptionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Subscription updated!'**
  String get addSubscriptionUpdated;

  /// No description provided for @addSubscriptionError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String addSubscriptionError(String error);

  /// No description provided for @addSubscriptionButton.
  ///
  /// In en, this message translates to:
  /// **'Add Subscription'**
  String get addSubscriptionButton;

  /// No description provided for @updateSubscriptionButton.
  ///
  /// In en, this message translates to:
  /// **'Update Subscription'**
  String get updateSubscriptionButton;

  /// No description provided for @addSubscriptionTemplateError.
  ///
  /// In en, this message translates to:
  /// **'Error loading templates'**
  String get addSubscriptionTemplateError;

  /// No description provided for @detailsSection.
  ///
  /// In en, this message translates to:
  /// **'Subscription Details'**
  String get detailsSection;

  /// No description provided for @detailsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get detailsNameLabel;

  /// No description provided for @detailsNameHint.
  ///
  /// In en, this message translates to:
  /// **'Netflix, Spotify, etc.'**
  String get detailsNameHint;

  /// No description provided for @detailsNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get detailsNameValidation;

  /// No description provided for @detailsAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount *'**
  String get detailsAmountLabel;

  /// No description provided for @detailsAmountHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get detailsAmountHint;

  /// No description provided for @detailsAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get detailsAmountRequired;

  /// No description provided for @detailsAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get detailsAmountInvalid;

  /// No description provided for @detailsCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get detailsCurrencyLabel;

  /// No description provided for @detailsBillingCycleLabel.
  ///
  /// In en, this message translates to:
  /// **'Billing Cycle *'**
  String get detailsBillingCycleLabel;

  /// No description provided for @detailsNextBillingDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Next Billing Date *'**
  String get detailsNextBillingDateLabel;

  /// No description provided for @detailsCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category *'**
  String get detailsCategoryLabel;

  /// No description provided for @trialSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Free Trial'**
  String get trialSectionTitle;

  /// No description provided for @trialSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track trial period and conversion date'**
  String get trialSectionSubtitle;

  /// No description provided for @trialToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'This is a free trial'**
  String get trialToggleLabel;

  /// No description provided for @trialToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable if subscription is currently in trial period'**
  String get trialToggleSubtitle;

  /// No description provided for @trialEndDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Trial End Date'**
  String get trialEndDateLabel;

  /// No description provided for @trialSetEndDate.
  ///
  /// In en, this message translates to:
  /// **'Set Trial End Date'**
  String get trialSetEndDate;

  /// No description provided for @trialAmountAfter.
  ///
  /// In en, this message translates to:
  /// **'Amount after trial'**
  String get trialAmountAfter;

  /// No description provided for @cancelSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Info'**
  String get cancelSectionTitle;

  /// No description provided for @cancelSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How to cancel this subscription'**
  String get cancelSectionSubtitle;

  /// No description provided for @cancelUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancellation URL'**
  String get cancelUrlLabel;

  /// No description provided for @cancelUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://...'**
  String get cancelUrlHint;

  /// No description provided for @cancelPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Phone'**
  String get cancelPhoneLabel;

  /// No description provided for @cancelPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+1 (555) 123-4567'**
  String get cancelPhoneHint;

  /// No description provided for @cancelNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Notes'**
  String get cancelNotesLabel;

  /// No description provided for @cancelNotesHint.
  ///
  /// In en, this message translates to:
  /// **'How to cancel...'**
  String get cancelNotesHint;

  /// No description provided for @cancelStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Steps'**
  String get cancelStepsTitle;

  /// No description provided for @cancelAddStep.
  ///
  /// In en, this message translates to:
  /// **'Add Step'**
  String get cancelAddStep;

  /// No description provided for @cancelStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String cancelStepLabel(int number);

  /// No description provided for @cancelStepHint.
  ///
  /// In en, this message translates to:
  /// **'Enter step...'**
  String get cancelStepHint;

  /// No description provided for @notesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesSectionTitle;

  /// No description provided for @notesSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add any additional notes'**
  String get notesSectionSubtitle;

  /// No description provided for @notesGeneralLabel.
  ///
  /// In en, this message translates to:
  /// **'General Notes'**
  String get notesGeneralLabel;

  /// No description provided for @notesGeneralHint.
  ///
  /// In en, this message translates to:
  /// **'Add any additional notes...'**
  String get notesGeneralHint;

  /// No description provided for @reminderFirstLabel.
  ///
  /// In en, this message translates to:
  /// **'First reminder'**
  String get reminderFirstLabel;

  /// No description provided for @reminderSecondLabel.
  ///
  /// In en, this message translates to:
  /// **'Second reminder'**
  String get reminderSecondLabel;

  /// No description provided for @reminderOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get reminderOff;

  /// No description provided for @reminderDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day before} other{{days} days before}}'**
  String reminderDaysBefore(int days);

  /// No description provided for @reminderOnBillingDay.
  ///
  /// In en, this message translates to:
  /// **'Remind on billing day'**
  String get reminderOnBillingDay;

  /// No description provided for @reminderTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTimeLabel;

  /// No description provided for @detailScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailScreenTitle;

  /// No description provided for @detailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Subscription not found'**
  String get detailNotFound;

  /// No description provided for @detailDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Subscription?'**
  String get detailDeleteTitle;

  /// No description provided for @detailDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this subscription and cancel all reminders. This cannot be undone.'**
  String get detailDeleteBody;

  /// No description provided for @detailDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get detailDeleteButton;

  /// No description provided for @detailMarkedAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Marked as paid ✓'**
  String get detailMarkedAsPaid;

  /// No description provided for @detailPauseTitle.
  ///
  /// In en, this message translates to:
  /// **'Pause Subscription'**
  String get detailPauseTitle;

  /// No description provided for @detailPauseWhilePaused.
  ///
  /// In en, this message translates to:
  /// **'While paused:'**
  String get detailPauseWhilePaused;

  /// No description provided for @detailPauseNoReminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders will be sent'**
  String get detailPauseNoReminders;

  /// No description provided for @detailPauseNoBilling.
  ///
  /// In en, this message translates to:
  /// **'Billing dates won\'t advance'**
  String get detailPauseNoBilling;

  /// No description provided for @detailPauseNoSpending.
  ///
  /// In en, this message translates to:
  /// **'Excluded from spending totals'**
  String get detailPauseNoSpending;

  /// No description provided for @detailPauseAutoResume.
  ///
  /// In en, this message translates to:
  /// **'Auto-resume date (optional):'**
  String get detailPauseAutoResume;

  /// No description provided for @detailPauseManual.
  ///
  /// In en, this message translates to:
  /// **'Resume manually'**
  String get detailPauseManual;

  /// No description provided for @detailPauseClearDate.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get detailPauseClearDate;

  /// No description provided for @detailPauseButton.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get detailPauseButton;

  /// No description provided for @detailPaused.
  ///
  /// In en, this message translates to:
  /// **'Subscription Paused'**
  String get detailPaused;

  /// No description provided for @detailAutoResumes.
  ///
  /// In en, this message translates to:
  /// **'Auto-resumes on {date}'**
  String detailAutoResumes(String date);

  /// No description provided for @detailPausedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Paused {days} days ago'**
  String detailPausedDaysAgo(int days);

  /// No description provided for @detailResumeButton.
  ///
  /// In en, this message translates to:
  /// **'Resume Subscription'**
  String get detailResumeButton;

  /// No description provided for @detailLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading subscription: {error}'**
  String detailLoadError(String error);

  /// No description provided for @detailGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get detailGoBack;

  /// No description provided for @detailPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get detailPaid;

  /// No description provided for @detailMarkAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get detailMarkAsPaid;

  /// No description provided for @billingInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Billing Information'**
  String get billingInfoTitle;

  /// No description provided for @billingNextBilling.
  ///
  /// In en, this message translates to:
  /// **'Next Billing'**
  String get billingNextBilling;

  /// No description provided for @billingCycle.
  ///
  /// In en, this message translates to:
  /// **'Billing Cycle'**
  String get billingCycle;

  /// No description provided for @billingAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get billingAmount;

  /// No description provided for @billingStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get billingStarted;

  /// No description provided for @billingTrialEnds.
  ///
  /// In en, this message translates to:
  /// **'Trial Ends'**
  String get billingTrialEnds;

  /// No description provided for @billingThenAmount.
  ///
  /// In en, this message translates to:
  /// **'Then {amount}/{cycle}'**
  String billingThenAmount(String amount, String cycle);

  /// No description provided for @headerTrialBadge.
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get headerTrialBadge;

  /// No description provided for @headerPaidBadge.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get headerPaidBadge;

  /// No description provided for @cancelCardTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Cancel'**
  String get cancelCardTitle;

  /// No description provided for @cancelCardOpenPage.
  ///
  /// In en, this message translates to:
  /// **'Open Cancellation Page'**
  String get cancelCardOpenPage;

  /// No description provided for @cancelCardCall.
  ///
  /// In en, this message translates to:
  /// **'Call {phone}'**
  String cancelCardCall(String phone);

  /// No description provided for @cancelCardStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Steps'**
  String get cancelCardStepsTitle;

  /// No description provided for @cancelCardProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} complete'**
  String cancelCardProgress(int completed, int total);

  /// No description provided for @reminderCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder Settings'**
  String get reminderCardTitle;

  /// No description provided for @reminderCardFirst.
  ///
  /// In en, this message translates to:
  /// **'First Reminder'**
  String get reminderCardFirst;

  /// No description provided for @reminderCardFirstValue.
  ///
  /// In en, this message translates to:
  /// **'{days} days before'**
  String reminderCardFirstValue(int days);

  /// No description provided for @reminderCardSecond.
  ///
  /// In en, this message translates to:
  /// **'Second Reminder'**
  String get reminderCardSecond;

  /// No description provided for @reminderCardSecondValue.
  ///
  /// In en, this message translates to:
  /// **'{days} days before'**
  String reminderCardSecondValue(int days);

  /// No description provided for @reminderCardDayOf.
  ///
  /// In en, this message translates to:
  /// **'Day-of Reminder'**
  String get reminderCardDayOf;

  /// No description provided for @reminderCardEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get reminderCardEnabled;

  /// No description provided for @reminderCardTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderCardTime;

  /// No description provided for @notesCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesCardTitle;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Billing Dates'**
  String get calendarEmptyTitle;

  /// No description provided for @calendarEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first subscription to see billing dates on the calendar.'**
  String get calendarEmptySubtitle;

  /// No description provided for @calendarAddSubscription.
  ///
  /// In en, this message translates to:
  /// **'Add Subscription'**
  String get calendarAddSubscription;

  /// No description provided for @calendarMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendarMonth;

  /// No description provided for @calendarTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a date to see billing details'**
  String get calendarTapHint;

  /// No description provided for @calendarError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String calendarError(String error);

  /// No description provided for @calendarNoBills.
  ///
  /// In en, this message translates to:
  /// **'No bills on this date'**
  String get calendarNoBills;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Analytics Yet'**
  String get analyticsEmptyTitle;

  /// No description provided for @analyticsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first subscription to see spending insights'**
  String get analyticsEmptySubtitle;

  /// No description provided for @analyticsAddSubscription.
  ///
  /// In en, this message translates to:
  /// **'Add Subscription'**
  String get analyticsAddSubscription;

  /// No description provided for @analyticsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading analytics'**
  String get analyticsLoadError;

  /// No description provided for @analyticsYearlyForecast.
  ///
  /// In en, this message translates to:
  /// **'Yearly Forecast'**
  String get analyticsYearlyForecast;

  /// No description provided for @analyticsMonthlyTotal.
  ///
  /// In en, this message translates to:
  /// **'{amount}/mo'**
  String analyticsMonthlyTotal(String amount);

  /// No description provided for @analyticsSubsAndDaily.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 subscription} other{{count} subscriptions}} · {daily}/day'**
  String analyticsSubsAndDaily(int count, String daily);

  /// No description provided for @analyticsSpendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by Category'**
  String get analyticsSpendingByCategory;

  /// No description provided for @analyticsTopSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Top Subscriptions'**
  String get analyticsTopSubscriptions;

  /// No description provided for @analyticsByCurrency.
  ///
  /// In en, this message translates to:
  /// **'By Currency'**
  String get analyticsByCurrency;

  /// No description provided for @analyticsCurrencyEntry.
  ///
  /// In en, this message translates to:
  /// **'{code} ({symbol})'**
  String analyticsCurrencyEntry(String code, String symbol);

  /// No description provided for @analyticsTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total ({currency})'**
  String analyticsTotalLabel(String currency);

  /// No description provided for @analyticsTotalApprox.
  ///
  /// In en, this message translates to:
  /// **'≈ {amount}'**
  String analyticsTotalApprox(String amount);

  /// No description provided for @analyticsExchangeNote.
  ///
  /// In en, this message translates to:
  /// **'At bundled exchange rates'**
  String get analyticsExchangeNote;

  /// No description provided for @analyticsActiveVsPaused.
  ///
  /// In en, this message translates to:
  /// **'Active vs Paused'**
  String get analyticsActiveVsPaused;

  /// No description provided for @analyticsActiveCount.
  ///
  /// In en, this message translates to:
  /// **'Active ({count})'**
  String analyticsActiveCount(int count);

  /// No description provided for @analyticsPausedCount.
  ///
  /// In en, this message translates to:
  /// **'Paused ({count})'**
  String analyticsPausedCount(int count);

  /// No description provided for @analyticsIfResumed.
  ///
  /// In en, this message translates to:
  /// **'If all resumed'**
  String get analyticsIfResumed;

  /// No description provided for @analyticsMonthlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get analyticsMonthlyLabel;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Insights'**
  String get insightsTitle;

  /// No description provided for @insightsOverlapSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} {group} services'**
  String insightsOverlapSummary(int count, String group);

  /// No description provided for @insightsOverlapCombined.
  ///
  /// In en, this message translates to:
  /// **'{names} = {amount}/mo combined'**
  String insightsOverlapCombined(String names, String amount);

  /// No description provided for @insightsOverlapTitle.
  ///
  /// In en, this message translates to:
  /// **'Overlapping {group}'**
  String insightsOverlapTitle(String group);

  /// No description provided for @insightsOverlapBody.
  ///
  /// In en, this message translates to:
  /// **'You have {count} {group} subscriptions. These services offer similar content — you may only need one.'**
  String insightsOverlapBody(int count, String group);

  /// No description provided for @insightsOverlapCombinedDetail.
  ///
  /// In en, this message translates to:
  /// **'Combined: {monthly}/mo · {yearly}/year'**
  String insightsOverlapCombinedDetail(String monthly, String yearly);

  /// No description provided for @insightsAnnualTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch to annual billing'**
  String get insightsAnnualTitle;

  /// No description provided for @insightsAnnualSummary.
  ///
  /// In en, this message translates to:
  /// **'Est. save {min}–{max}/year'**
  String insightsAnnualSummary(String min, String max);

  /// No description provided for @insightsAnnualHeading.
  ///
  /// In en, this message translates to:
  /// **'Annual Billing Savings'**
  String get insightsAnnualHeading;

  /// No description provided for @insightsAnnualBody.
  ///
  /// In en, this message translates to:
  /// **'Most services offer a 15–20% discount when you pay annually instead of monthly.'**
  String get insightsAnnualBody;

  /// No description provided for @insightsAnnualRange.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max}'**
  String insightsAnnualRange(String min, String max);

  /// No description provided for @insightsAnnualEstimated.
  ///
  /// In en, this message translates to:
  /// **'estimated annual savings'**
  String get insightsAnnualEstimated;

  /// No description provided for @insightsAnnualAppliesTo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Applies to 1 monthly-billed subscription.} other{Applies to {count} monthly-billed subscriptions.}}'**
  String insightsAnnualAppliesTo(int count);

  /// No description provided for @insightsAnnualDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'* Estimated based on a 15–20% typical discount. Check each provider\'s current annual pricing for exact savings.'**
  String get insightsAnnualDisclaimer;

  /// No description provided for @insightsBundleTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} available'**
  String insightsBundleTitle(String name);

  /// No description provided for @insightsBundleSummary.
  ///
  /// In en, this message translates to:
  /// **'Save ~{amount}/mo vs separate plans'**
  String insightsBundleSummary(String amount);

  /// No description provided for @insightsBundleYouPayNow.
  ///
  /// In en, this message translates to:
  /// **'You pay now'**
  String get insightsBundleYouPayNow;

  /// No description provided for @insightsBundleMonthlySavings.
  ///
  /// In en, this message translates to:
  /// **'Monthly savings'**
  String get insightsBundleMonthlySavings;

  /// No description provided for @insightsBundleSavingsDetail.
  ///
  /// In en, this message translates to:
  /// **'~{amount}/mo from last month'**
  String insightsBundleSavingsDetail(String amount);

  /// No description provided for @insightsBundleDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'* Bundle price shown in USD. Check current pricing — promotions and regional pricing vary.'**
  String get insightsBundleDisclaimer;

  /// No description provided for @insightsBundleCheckPricing.
  ///
  /// In en, this message translates to:
  /// **'Check current pricing'**
  String get insightsBundleCheckPricing;

  /// No description provided for @insightsHighSpendSummary.
  ///
  /// In en, this message translates to:
  /// **'{category} = {percent}% of spend'**
  String insightsHighSpendSummary(String category, String percent);

  /// No description provided for @insightsHighSpendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One category dominates your subscription budget'**
  String get insightsHighSpendSubtitle;

  /// No description provided for @insightsHighSpendTitle.
  ///
  /// In en, this message translates to:
  /// **'{category} Spending'**
  String insightsHighSpendTitle(String category);

  /// No description provided for @insightsHighSpendBody.
  ///
  /// In en, this message translates to:
  /// **'{category} accounts for {percent}% of your active subscription spend — {monthly}/mo ({yearly}/year).'**
  String insightsHighSpendBody(
      String category, String percent, String monthly, String yearly);

  /// No description provided for @insightsHighSpendListTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions in this category:'**
  String get insightsHighSpendListTitle;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @dateTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dateTomorrow;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// No description provided for @dateOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get dateOverdue;

  /// No description provided for @dateDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String dateDaysAgo(int days);

  /// No description provided for @dateWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, =1{1 week ago} other{{weeks} weeks ago}}'**
  String dateWeeksAgo(int weeks);

  /// No description provided for @dateInDays.
  ///
  /// In en, this message translates to:
  /// **'in {days} days'**
  String dateInDays(int days);

  /// No description provided for @dateInWeeks.
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, =1{in 1 week} other{in {weeks} weeks}}'**
  String dateInWeeks(int weeks);

  /// No description provided for @dateInMonths.
  ///
  /// In en, this message translates to:
  /// **'{months, plural, =1{in 1 month} other{in {months} months}}'**
  String dateInMonths(int months);

  /// No description provided for @notifFirstReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'📅 {name} — Billing in {days} days'**
  String notifFirstReminderTitle(String name, int days);

  /// No description provided for @notifFirstReminderBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} charges on {date}'**
  String notifFirstReminderBody(String amount, String date);

  /// No description provided for @notifFirstReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Billing in {days} days'**
  String notifFirstReminderSubtitle(int days);

  /// No description provided for @notifFirstReminderExpanded.
  ///
  /// In en, this message translates to:
  /// **'{amount} charges on {date}\n\nTap to view details or mark as paid.'**
  String notifFirstReminderExpanded(String amount, String date);

  /// No description provided for @notifSecondReminderTitleTomorrow.
  ///
  /// In en, this message translates to:
  /// **'⚠️ {name} — Bills tomorrow'**
  String notifSecondReminderTitleTomorrow(String name);

  /// No description provided for @notifSecondReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️ {name} — Bills in {days} days'**
  String notifSecondReminderTitle(String name, int days);

  /// No description provided for @notifSecondReminderBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} will be charged on {date}'**
  String notifSecondReminderBody(String amount, String date);

  /// No description provided for @notifSecondReminderSubtitleTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Bills tomorrow'**
  String get notifSecondReminderSubtitleTomorrow;

  /// No description provided for @notifSecondReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bills in {days} days'**
  String notifSecondReminderSubtitle(int days);

  /// No description provided for @notifSecondReminderExpanded.
  ///
  /// In en, this message translates to:
  /// **'{amount} will be charged on {date}\n\nTap to view details or mark as paid.'**
  String notifSecondReminderExpanded(String amount, String date);

  /// No description provided for @notifDayOfTitle.
  ///
  /// In en, this message translates to:
  /// **'💰 {name} — Billing today'**
  String notifDayOfTitle(String name);

  /// No description provided for @notifDayOfBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} charge expected today'**
  String notifDayOfBody(String amount);

  /// No description provided for @notifDayOfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Billing today'**
  String get notifDayOfSubtitle;

  /// No description provided for @notifDayOfExpanded.
  ///
  /// In en, this message translates to:
  /// **'{amount} charge expected today\n\nTap to view details or mark as paid.'**
  String notifDayOfExpanded(String amount);

  /// No description provided for @notifTrialEnding3Days.
  ///
  /// In en, this message translates to:
  /// **'🔔 {name} — Trial ending in 3 days'**
  String notifTrialEnding3Days(String name);

  /// No description provided for @notifTrialEndingTomorrow.
  ///
  /// In en, this message translates to:
  /// **'🔔 {name} — Trial ending tomorrow'**
  String notifTrialEndingTomorrow(String name);

  /// No description provided for @notifTrialEndsToday.
  ///
  /// In en, this message translates to:
  /// **'🔔 {name} — Trial ends today'**
  String notifTrialEndsToday(String name);

  /// No description provided for @notifTrialSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trial ending'**
  String get notifTrialSubtitle;

  /// No description provided for @notifTrialBody.
  ///
  /// In en, this message translates to:
  /// **'Free trial ends {date}. You\'ll be charged {amount}/{cycle} after.\n\nTap to view details or mark as paid.'**
  String notifTrialBody(String date, String amount, String cycle);

  /// No description provided for @notifTestTitle.
  ///
  /// In en, this message translates to:
  /// **'✅ Notifications are working!'**
  String get notifTestTitle;

  /// No description provided for @notifTestBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be reminded before every charge.'**
  String get notifTestBody;

  /// No description provided for @notifActionMarkPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get notifActionMarkPaid;

  /// No description provided for @notifActionViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get notifActionViewDetails;

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Subscription Reminders'**
  String get notifChannelName;

  /// No description provided for @notifChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications for upcoming subscription charges'**
  String get notifChannelDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
