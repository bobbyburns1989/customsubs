// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'CustomSubs';

  @override
  String get sectionUpcoming => 'À venir';

  @override
  String get sectionLater => 'Plus tard';

  @override
  String get sectionPaused => 'En pause';

  @override
  String get sectionSpendingSummary => 'Résumé des dépenses';

  @override
  String get navAddNew => 'Ajouter';

  @override
  String get navCalendar => 'Calendrier';

  @override
  String get navAnalytics => 'Analyses';

  @override
  String get categoryEntertainment => 'Divertissement';

  @override
  String get categoryProductivity => 'Productivité';

  @override
  String get categoryFitness => 'Sport';

  @override
  String get categoryNews => 'Actualités';

  @override
  String get categoryCloud => 'Stockage cloud';

  @override
  String get categoryGaming => 'Jeux vidéo';

  @override
  String get categoryEducation => 'Éducation';

  @override
  String get categoryFinance => 'Finance';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryUtilities => 'Services';

  @override
  String get categoryHealth => 'Santé';

  @override
  String get categoryOther => 'Autre';

  @override
  String get categorySports => 'Sports';

  @override
  String get cycleWeekly => 'Hebdomadaire';

  @override
  String get cycleBiweekly => 'Bimensuel';

  @override
  String get cycleMonthly => 'Mensuel';

  @override
  String get cycleQuarterly => 'Trimestriel';

  @override
  String get cycleBiannual => 'Semestriel';

  @override
  String get cycleYearly => 'Annuel';

  @override
  String get cycleShortWeekly => 'sem';

  @override
  String get cycleShortBiweekly => '2sem';

  @override
  String get cycleShortMonthly => 'mo';

  @override
  String get cycleShortQuarterly => 'trim';

  @override
  String get cycleShortBiannual => '6mo';

  @override
  String get cycleShortYearly => 'an';

  @override
  String get onboardingWelcome => 'Bienvenue sur CustomSubs';

  @override
  String get onboardingSubtitle => 'Ton suivi d\'abonnements privé';

  @override
  String get onboardingFeature1Title => 'Tout suivre';

  @override
  String get onboardingFeature1Desc =>
      'Tous tes abonnements au même endroit. Pas de lien bancaire. Pas de connexion.';

  @override
  String get onboardingFeature2Title => 'Ne rate aucun paiement';

  @override
  String get onboardingFeature2Desc =>
      'Reçois une notification 7 jours avant, 1 jour avant et le matin de chaque date de facturation.';

  @override
  String get onboardingFeature3Title => 'Résilie en confiance';

  @override
  String get onboardingFeature3Desc =>
      'Des guides étape par étape pour résilier rapidement n\'importe quel abonnement.';

  @override
  String get onboardingGetStarted => 'Commencer';

  @override
  String get onboardingPrivacyNote => '100% hors ligne • Aucun compte requis';

  @override
  String get homeTitle => 'CustomSubs';

  @override
  String get homeEmptyTitle => 'Aucun abonnement';

  @override
  String get homeEmptySubtitle =>
      'Appuie sur + pour ajouter le premier. On te rappellera avant chaque prélèvement.';

  @override
  String get homeAddSubscription => 'Ajouter un abonnement';

  @override
  String get homeDeleteTitle => 'Supprimer l\'abonnement';

  @override
  String get homeDeleteCancel => 'Annuler';

  @override
  String get homeDeleteConfirm => 'Supprimer';

  @override
  String get homePaid => 'Payé';

  @override
  String get homeMarkAsPaid => 'Marquer comme payé';

  @override
  String get homeMarkedAsPaid => 'Marqué comme payé ✓';

  @override
  String get homePerMonth => '/mois';

  @override
  String get homePerYear => '/an';

  @override
  String get homePerDay => '/jour';

  @override
  String homeError(String error) {
    return 'Erreur : $error';
  }

  @override
  String homePaidCount(int paid, int total) {
    return 'Payé · $paid sur $total';
  }

  @override
  String get homeNext30Days => '30 prochains jours';

  @override
  String get homeLaterDays => '31–90 jours';

  @override
  String homePausedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en pause',
      one: '1 en pause',
    );
    return '$_temp0';
  }

  @override
  String get homeResumesToday => 'Reprend aujourd\'hui';

  @override
  String get homeResumesTomorrow => 'Reprend demain';

  @override
  String homeResumesInDays(int days) {
    return 'Reprend dans $days jours';
  }

  @override
  String homePausedDaysAgo(int days) {
    return 'En pause depuis $days jours';
  }

  @override
  String get homePausedManualResume => 'Reprendre manuellement';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsGeneral => 'Général';

  @override
  String get settingsPrimaryCurrency => 'Devise principale';

  @override
  String settingsCurrencyChanged(String currency) {
    return 'Devise changée pour $currency';
  }

  @override
  String settingsCurrencyRestored(String currency) {
    return 'Devise restaurée à $currency';
  }

  @override
  String get settingsDefaultReminderTime => 'Heure de rappel par défaut';

  @override
  String get settingsReminderTimeUpdated => 'Heure de rappel mise à jour';

  @override
  String get settingsReminderTimeRestored => 'Heure de rappel restaurée';

  @override
  String get settingsDarkMode => 'Mode sombre';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Par défaut du système';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsTestNotification => 'Notification test';

  @override
  String get settingsTestNotificationSubtitle =>
      'Vérifier que les rappels fonctionnent';

  @override
  String get settingsNotificationsDisabled => 'Notifications désactivées';

  @override
  String get settingsNotificationsDisabledBody =>
      'Les notifications sont actuellement désactivées pour CustomSubs. Active-les dans les réglages de ton appareil pour recevoir les rappels de facturation.';

  @override
  String get settingsNotNow => 'Pas maintenant';

  @override
  String get settingsOpenSettings => 'Ouvrir les réglages';

  @override
  String get settingsTestSent => 'Test envoyé';

  @override
  String get settingsTestSentBody =>
      'Une notification test vient d\'être envoyée.\n\nTu ne la vois pas ? Les notifications sont peut-être désactivées dans les réglages de ton appareil.';

  @override
  String get settingsGotIt => 'Compris';

  @override
  String get settingsNotificationsHelp =>
      'CustomSubs envoie des rappels à l\'heure choisie avant les dates de facturation. Assure-toi que les notifications sont activées dans les réglages de ton appareil.';

  @override
  String get settingsPrivacy => 'Confidentialité';

  @override
  String get settingsShareAnalytics =>
      'Partager les données d\'utilisation anonymes';

  @override
  String get settingsShareAnalyticsSubtitle =>
      'Nous aide à améliorer l\'app. Aucune donnée personnelle n\'est collectée.';

  @override
  String get settingsData => 'Données';

  @override
  String get settingsLastBackup => 'Dernière sauvegarde';

  @override
  String get settingsNeverBackedUp => 'Jamais sauvegardé';

  @override
  String get settingsExportBackup => 'Exporter la sauvegarde';

  @override
  String get settingsExportBackupSubtitle =>
      'Enregistrer tes abonnements dans un fichier';

  @override
  String get settingsPreparingBackup => 'Préparation de la sauvegarde...';

  @override
  String get settingsBackupSuccess => 'Sauvegarde exportée avec succès !';

  @override
  String settingsBackupError(String error) {
    return 'Échec de l\'export : $error';
  }

  @override
  String get settingsImportBackup => 'Importer une sauvegarde';

  @override
  String get settingsImportBackupSubtitle =>
      'Restaurer les abonnements depuis un fichier';

  @override
  String get settingsImportComplete => 'Import terminé';

  @override
  String settingsImportFound(int count) {
    return 'Trouvés : $count abonnements';
  }

  @override
  String settingsImportDuplicates(int count) {
    return 'Doublons ignorés : $count';
  }

  @override
  String settingsImportImported(int count) {
    return 'Importés : $count abonnements';
  }

  @override
  String settingsImportSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count abonnements n\'ont pas pu être importés en raison de données invalides.',
      one:
          '1 abonnement n\'a pas pu être importé en raison de données invalides.',
    );
    return '$_temp0';
  }

  @override
  String get settingsImportNotifications =>
      'Les notifications ont été programmées pour tous les abonnements importés.';

  @override
  String get settingsOk => 'OK';

  @override
  String get settingsDeleteAll => 'Supprimer toutes les données';

  @override
  String get settingsDeleteAllSubtitle =>
      'Supprimer définitivement tous les abonnements';

  @override
  String get settingsDeleteAllTitle => 'Supprimer toutes les données ?';

  @override
  String get settingsDeleteAllBody =>
      'Cela supprimera définitivement tous les abonnements et paramètres. Cette action est irréversible.\n\nEs-tu sûr de vouloir continuer ?';

  @override
  String get settingsCancel => 'Annuler';

  @override
  String get settingsContinue => 'Continuer';

  @override
  String get settingsFinalConfirmation => 'Confirmation finale';

  @override
  String get settingsFinalConfirmationBody =>
      'Cette action est irréversible. Toutes tes données d\'abonnement seront perdues à jamais.';

  @override
  String get settingsTypeDelete => 'Tape DELETE pour confirmer :';

  @override
  String get settingsDeleteHint => 'DELETE';

  @override
  String get settingsDeleteButton => 'Tout supprimer';

  @override
  String get settingsTypeDeleteWarning => 'Tape DELETE pour confirmer';

  @override
  String get settingsAllDataDeleted =>
      'Toutes les données supprimées avec succès';

  @override
  String settingsDeleteError(String error) {
    return 'Échec de la suppression : $error';
  }

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsTermsOfService => 'Conditions d\'utilisation';

  @override
  String get settingsMadeWith => 'Fait avec amour par CustomApps LLC';

  @override
  String get settingsDeveloperTools => 'Outils développeur';

  @override
  String get settingsLoadDemoData => 'Charger les données démo';

  @override
  String get settingsLoadDemoDataSubtitle => 'Ajouter 18 abonnements exemples';

  @override
  String get settingsClearDemoData => 'Effacer les données démo';

  @override
  String get settingsClearDemoDataSubtitle =>
      'Supprimer uniquement les abonnements démo';

  @override
  String get settingsDeveloperUnlocked => 'Outils développeur déverrouillés';

  @override
  String get settingsLoadDemoTitle => 'Charger les données démo ?';

  @override
  String get settingsLoadDemoBody =>
      'Cela ajoutera 18 abonnements exemples à ton app. Tes abonnements existants ne seront pas affectés.\n\nLes abonnements démo sont marqués et peuvent être supprimés avec « Effacer les données démo ».';

  @override
  String get settingsLoad => 'Charger';

  @override
  String settingsLoadedDemoCount(int count) {
    return '$count abonnements démo chargés';
  }

  @override
  String settingsLoadDemoError(String error) {
    return 'Échec du chargement des données démo : $error';
  }

  @override
  String get settingsClearDemoTitle => 'Effacer les données démo ?';

  @override
  String settingsClearDemoBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Cela supprimera $count abonnements démo. Tes vrais abonnements ne seront pas affectés.',
      one:
          'Cela supprimera 1 abonnement démo. Tes vrais abonnements ne seront pas affectés.',
    );
    return '$_temp0';
  }

  @override
  String get settingsClear => 'Effacer';

  @override
  String settingsClearedDemoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnements démo effacés',
      one: '1 abonnement démo effacé',
    );
    return '$_temp0';
  }

  @override
  String settingsClearDemoError(String error) {
    return 'Échec de l\'effacement des données démo : $error';
  }

  @override
  String get settingsNoDemoFound => 'Aucun abonnement démo trouvé';

  @override
  String get backupReminderTitle => 'Sauvegarde tes données';

  @override
  String get backupReminderBody =>
      'Tu as ajouté 3 abonnements ! Pense à sauvegarder tes données pour éviter toute perte.';

  @override
  String get backupReminderHint =>
      'Tu peux exporter une sauvegarde à tout moment dans Paramètres → Exporter la sauvegarde.';

  @override
  String get backupReminderDontShow => 'Ne plus afficher';

  @override
  String get backupReminderGotIt => 'Compris';

  @override
  String get promoTitle => 'Plus de CustomApps';

  @override
  String get promoSubtitle => 'Découvre nos autres apps';

  @override
  String get promoCouldNotOpen => 'Impossible d\'ouvrir le site';

  @override
  String get promoCustomBank => 'CustomBank';

  @override
  String get promoCustomBankDesc => 'Simulateur bancaire — pas de vrai argent';

  @override
  String get promoCustomCrypto => 'CustomCrypto';

  @override
  String get promoCustomCryptoDesc => 'S\'entraîner au trading crypto';

  @override
  String get promoCustomNotify => 'CustomNotify';

  @override
  String get promoCustomNotifyDesc => 'Rappels et alertes intelligents';

  @override
  String get promoCustomWorth => 'CustomWorth';

  @override
  String get promoCustomWorthDesc => 'Suivre ta valeur nette';

  @override
  String get addSubscriptionTitle => 'Ajouter un abonnement';

  @override
  String get editSubscriptionTitle => 'Modifier l\'abonnement';

  @override
  String get addSubscriptionSave => 'Enregistrer';

  @override
  String get addSubscriptionChooseTemplate => 'Choisir un modèle';

  @override
  String get addSubscriptionSearchHint => 'Rechercher des services...';

  @override
  String get addSubscriptionNoTemplates => 'Aucun modèle trouvé';

  @override
  String get addSubscriptionNoTemplatesHint =>
      'Essaie un autre terme de recherche ou crée un abonnement personnalisé ci-dessous';

  @override
  String get addSubscriptionCreateCustom => 'Créer personnalisé';

  @override
  String get addSubscriptionInvalidData =>
      'Veuillez saisir des données valides';

  @override
  String get addSubscriptionAdded => 'Abonnement ajouté !';

  @override
  String get addSubscriptionUpdated => 'Abonnement mis à jour !';

  @override
  String addSubscriptionError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get addSubscriptionButton => 'Ajouter l\'abonnement';

  @override
  String get updateSubscriptionButton => 'Mettre à jour';

  @override
  String get addSubscriptionTemplateError => 'Erreur de chargement des modèles';

  @override
  String get detailsSection => 'Détails de l\'abonnement';

  @override
  String get detailsNameLabel => 'Nom *';

  @override
  String get detailsNameHint => 'Netflix, Spotify, etc.';

  @override
  String get detailsNameValidation => 'Veuillez saisir un nom';

  @override
  String get detailsAmountLabel => 'Montant *';

  @override
  String get detailsAmountHint => '0,00';

  @override
  String get detailsAmountRequired => 'Requis';

  @override
  String get detailsAmountInvalid => 'Montant invalide';

  @override
  String get detailsCurrencyLabel => 'Devise';

  @override
  String get detailsBillingCycleLabel => 'Cycle de facturation *';

  @override
  String get detailsNextBillingDateLabel => 'Prochaine date de facturation *';

  @override
  String get detailsCategoryLabel => 'Catégorie *';

  @override
  String get trialSectionTitle => 'Essai gratuit';

  @override
  String get trialSectionSubtitle =>
      'Suivre la période d\'essai et la date de conversion';

  @override
  String get trialToggleLabel => 'C\'est un essai gratuit';

  @override
  String get trialToggleSubtitle =>
      'Activer si l\'abonnement est en période d\'essai';

  @override
  String get trialEndDateLabel => 'Date de fin d\'essai';

  @override
  String get trialSetEndDate => 'Définir la date de fin';

  @override
  String get trialAmountAfter => 'Montant après l\'essai';

  @override
  String get cancelSectionTitle => 'Infos de résiliation';

  @override
  String get cancelSectionSubtitle => 'Comment résilier cet abonnement';

  @override
  String get cancelUrlLabel => 'URL de résiliation';

  @override
  String get cancelUrlHint => 'https://...';

  @override
  String get cancelPhoneLabel => 'Téléphone de résiliation';

  @override
  String get cancelPhoneHint => '+33 1 23 45 67 89';

  @override
  String get cancelNotesLabel => 'Notes de résiliation';

  @override
  String get cancelNotesHint => 'Comment résilier...';

  @override
  String get cancelStepsTitle => 'Étapes de résiliation';

  @override
  String get cancelAddStep => 'Ajouter une étape';

  @override
  String cancelStepLabel(int number) {
    return 'Étape $number';
  }

  @override
  String get cancelStepHint => 'Saisir l\'étape...';

  @override
  String get notesSectionTitle => 'Notes';

  @override
  String get notesSectionSubtitle => 'Ajouter des notes supplémentaires';

  @override
  String get notesGeneralLabel => 'Notes générales';

  @override
  String get notesGeneralHint => 'Ajouter des notes...';

  @override
  String get reminderFirstLabel => 'Premier rappel';

  @override
  String get reminderSecondLabel => 'Deuxième rappel';

  @override
  String get reminderOff => 'Désactivé';

  @override
  String reminderDaysBefore(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours avant',
      one: '1 jour avant',
    );
    return '$_temp0';
  }

  @override
  String get reminderOnBillingDay => 'Rappel le jour de facturation';

  @override
  String get reminderTimeLabel => 'Heure du rappel';

  @override
  String get detailScreenTitle => 'Détails';

  @override
  String get detailNotFound => 'Abonnement introuvable';

  @override
  String get detailDeleteTitle => 'Supprimer l\'abonnement ?';

  @override
  String get detailDeleteBody =>
      'Cela supprimera définitivement cet abonnement et annulera tous les rappels. Cette action est irréversible.';

  @override
  String get detailDeleteButton => 'Supprimer';

  @override
  String get detailMarkedAsPaid => 'Marqué comme payé ✓';

  @override
  String get detailPauseTitle => 'Mettre en pause';

  @override
  String get detailPauseWhilePaused => 'Pendant la pause :';

  @override
  String get detailPauseNoReminders => 'Aucun rappel ne sera envoyé';

  @override
  String get detailPauseNoBilling =>
      'Les dates de facturation n\'avanceront pas';

  @override
  String get detailPauseNoSpending => 'Exclu des totaux de dépenses';

  @override
  String get detailPauseAutoResume =>
      'Date de reprise automatique (optionnel) :';

  @override
  String get detailPauseManual => 'Reprendre manuellement';

  @override
  String get detailPauseClearDate => 'Effacer la date';

  @override
  String get detailPauseButton => 'Mettre en pause';

  @override
  String get detailPaused => 'Abonnement en pause';

  @override
  String detailAutoResumes(String date) {
    return 'Reprise auto le $date';
  }

  @override
  String detailPausedDaysAgo(int days) {
    return 'En pause depuis $days jours';
  }

  @override
  String get detailResumeButton => 'Reprendre l\'abonnement';

  @override
  String detailLoadError(String error) {
    return 'Erreur de chargement : $error';
  }

  @override
  String get detailGoBack => 'Retour';

  @override
  String get detailPaid => 'Payé';

  @override
  String get detailMarkAsPaid => 'Marquer comme payé';

  @override
  String get billingInfoTitle => 'Informations de facturation';

  @override
  String get billingNextBilling => 'Prochaine facturation';

  @override
  String get billingCycle => 'Cycle de facturation';

  @override
  String get billingAmount => 'Montant';

  @override
  String get billingStarted => 'Début';

  @override
  String get billingTrialEnds => 'Fin de l\'essai';

  @override
  String billingThenAmount(String amount, String cycle) {
    return 'Puis $amount/$cycle';
  }

  @override
  String get headerTrialBadge => 'Essai';

  @override
  String get headerPaidBadge => 'Payé';

  @override
  String get cancelCardTitle => 'Comment résilier';

  @override
  String get cancelCardOpenPage => 'Ouvrir la page de résiliation';

  @override
  String cancelCardCall(String phone) {
    return 'Appeler $phone';
  }

  @override
  String get cancelCardStepsTitle => 'Étapes de résiliation';

  @override
  String cancelCardProgress(int completed, int total) {
    return '$completed sur $total terminées';
  }

  @override
  String get reminderCardTitle => 'Paramètres de rappel';

  @override
  String get reminderCardFirst => 'Premier rappel';

  @override
  String reminderCardFirstValue(int days) {
    return '$days jours avant';
  }

  @override
  String get reminderCardSecond => 'Deuxième rappel';

  @override
  String reminderCardSecondValue(int days) {
    return '$days jours avant';
  }

  @override
  String get reminderCardDayOf => 'Rappel du jour';

  @override
  String get reminderCardEnabled => 'Activé';

  @override
  String get reminderCardTime => 'Heure du rappel';

  @override
  String get notesCardTitle => 'Notes';

  @override
  String get calendarTitle => 'Calendrier';

  @override
  String get calendarEmptyTitle => 'Aucune date de facturation';

  @override
  String get calendarEmptySubtitle =>
      'Ajoute ton premier abonnement pour voir les dates de facturation sur le calendrier.';

  @override
  String get calendarAddSubscription => 'Ajouter un abonnement';

  @override
  String get calendarMonth => 'Mois';

  @override
  String get calendarTapHint => 'Appuie sur une date pour voir les détails';

  @override
  String calendarError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get calendarNoBills => 'Aucune facturation ce jour';

  @override
  String get analyticsTitle => 'Analyses';

  @override
  String get analyticsEmptyTitle => 'Pas encore d\'analyses';

  @override
  String get analyticsEmptySubtitle =>
      'Ajoute ton premier abonnement pour voir les analyses de dépenses';

  @override
  String get analyticsAddSubscription => 'Ajouter un abonnement';

  @override
  String get analyticsLoadError => 'Erreur de chargement des analyses';

  @override
  String get analyticsYearlyForecast => 'Prévision annuelle';

  @override
  String analyticsMonthlyTotal(String amount) {
    return '$amount/mo';
  }

  @override
  String analyticsSubsAndDaily(int count, String daily) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnements',
      one: '1 abonnement',
    );
    return '$_temp0 · $daily/jour';
  }

  @override
  String get analyticsSpendingByCategory => 'Dépenses par catégorie';

  @override
  String get analyticsTopSubscriptions => 'Top abonnements';

  @override
  String get analyticsByCurrency => 'Par devise';

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
  String get analyticsExchangeNote => 'Aux taux de change intégrés';

  @override
  String get analyticsActiveVsPaused => 'Actifs vs En pause';

  @override
  String analyticsActiveCount(int count) {
    return 'Actifs ($count)';
  }

  @override
  String analyticsPausedCount(int count) {
    return 'En pause ($count)';
  }

  @override
  String get analyticsIfResumed => 'Si tous repris';

  @override
  String get analyticsMonthlyLabel => 'Mensuel';

  @override
  String get insightsTitle => 'Analyses intelligentes';

  @override
  String insightsOverlapSummary(int count, String group) {
    return '$count services $group';
  }

  @override
  String insightsOverlapCombined(String names, String amount) {
    return '$names = $amount/mo combinés';
  }

  @override
  String insightsOverlapTitle(String group) {
    return '$group en double';
  }

  @override
  String insightsOverlapBody(int count, String group) {
    return 'Tu as $count abonnements $group. Ces services offrent un contenu similaire — tu n\'en as peut-être besoin que d\'un seul.';
  }

  @override
  String insightsOverlapCombinedDetail(String monthly, String yearly) {
    return 'Combiné : $monthly/mo · $yearly/an';
  }

  @override
  String get insightsAnnualTitle => 'Passer à la facturation annuelle';

  @override
  String insightsAnnualSummary(String min, String max) {
    return 'Éco. estimée $min–$max/an';
  }

  @override
  String get insightsAnnualHeading => 'Économies facturation annuelle';

  @override
  String get insightsAnnualBody =>
      'La plupart des services offrent une réduction de 15–20 % quand tu paies annuellement au lieu de mensuellement.';

  @override
  String insightsAnnualRange(String min, String max) {
    return '$min–$max';
  }

  @override
  String get insightsAnnualEstimated => 'économies annuelles estimées';

  @override
  String insightsAnnualAppliesTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'S\'applique à $count abonnements mensuels.',
      one: 'S\'applique à 1 abonnement mensuel.',
    );
    return '$_temp0';
  }

  @override
  String get insightsAnnualDisclaimer =>
      '* Estimation basée sur une réduction typique de 15–20 %. Vérifie le tarif annuel actuel de chaque fournisseur.';

  @override
  String insightsBundleTitle(String name) {
    return '$name disponible';
  }

  @override
  String insightsBundleSummary(String amount) {
    return 'Économise ~$amount/mo vs abonnements séparés';
  }

  @override
  String get insightsBundleYouPayNow => 'Tu paies maintenant';

  @override
  String get insightsBundleMonthlySavings => 'Économie mensuelle';

  @override
  String insightsBundleSavingsDetail(String amount) {
    return '~$amount/mo par rapport au mois dernier';
  }

  @override
  String get insightsBundleDisclaimer =>
      '* Prix du bundle affiché en USD. Vérifie les tarifs actuels — les promotions et prix régionaux varient.';

  @override
  String get insightsBundleCheckPricing => 'Voir les tarifs actuels';

  @override
  String insightsHighSpendSummary(String category, String percent) {
    return '$category = $percent % des dépenses';
  }

  @override
  String get insightsHighSpendSubtitle =>
      'Une catégorie domine ton budget d\'abonnements';

  @override
  String insightsHighSpendTitle(String category) {
    return 'Dépenses $category';
  }

  @override
  String insightsHighSpendBody(
      String category, String percent, String monthly, String yearly) {
    return '$category représente $percent % de tes dépenses d\'abonnements actifs — $monthly/mo ($yearly/an).';
  }

  @override
  String get insightsHighSpendListTitle => 'Abonnements dans cette catégorie :';

  @override
  String get dateToday => 'Aujourd\'hui';

  @override
  String get dateTomorrow => 'Demain';

  @override
  String get dateYesterday => 'Hier';

  @override
  String get dateOverdue => 'En retard';

  @override
  String dateDaysAgo(int days) {
    return 'il y a $days jours';
  }

  @override
  String dateWeeksAgo(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'il y a $weeks semaines',
      one: 'il y a 1 semaine',
    );
    return '$_temp0';
  }

  @override
  String dateInDays(int days) {
    return 'dans $days jours';
  }

  @override
  String dateInWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'dans $weeks semaines',
      one: 'dans 1 semaine',
    );
    return '$_temp0';
  }

  @override
  String dateInMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'dans $months mois',
      one: 'dans 1 mois',
    );
    return '$_temp0';
  }

  @override
  String notifFirstReminderTitle(String name, int days) {
    return '📅 $name — Facturation dans $days jours';
  }

  @override
  String notifFirstReminderBody(String amount, String date) {
    return '$amount prélevé le $date';
  }

  @override
  String notifFirstReminderSubtitle(int days) {
    return 'Facturation dans $days jours';
  }

  @override
  String notifFirstReminderExpanded(String amount, String date) {
    return '$amount prélevé le $date\n\nAppuie pour voir les détails ou marquer comme payé.';
  }

  @override
  String notifSecondReminderTitleTomorrow(String name) {
    return '⚠️ $name — Facturation demain';
  }

  @override
  String notifSecondReminderTitle(String name, int days) {
    return '⚠️ $name — Facturation dans $days jours';
  }

  @override
  String notifSecondReminderBody(String amount, String date) {
    return '$amount sera prélevé le $date';
  }

  @override
  String get notifSecondReminderSubtitleTomorrow => 'Facturation demain';

  @override
  String notifSecondReminderSubtitle(int days) {
    return 'Facturation dans $days jours';
  }

  @override
  String notifSecondReminderExpanded(String amount, String date) {
    return '$amount sera prélevé le $date\n\nAppuie pour voir les détails ou marquer comme payé.';
  }

  @override
  String notifDayOfTitle(String name) {
    return '💰 $name — Facturation aujourd\'hui';
  }

  @override
  String notifDayOfBody(String amount) {
    return 'Prélèvement de $amount attendu aujourd\'hui';
  }

  @override
  String get notifDayOfSubtitle => 'Facturation aujourd\'hui';

  @override
  String notifDayOfExpanded(String amount) {
    return 'Prélèvement de $amount attendu aujourd\'hui\n\nAppuie pour voir les détails ou marquer comme payé.';
  }

  @override
  String notifTrialEnding3Days(String name) {
    return '🔔 $name — Essai se termine dans 3 jours';
  }

  @override
  String notifTrialEndingTomorrow(String name) {
    return '🔔 $name — Essai se termine demain';
  }

  @override
  String notifTrialEndsToday(String name) {
    return '🔔 $name — Essai se termine aujourd\'hui';
  }

  @override
  String get notifTrialSubtitle => 'Fin de l\'essai';

  @override
  String notifTrialBody(String date, String amount, String cycle) {
    return 'L\'essai gratuit se termine le $date. Tu seras facturé $amount/$cycle après.\n\nAppuie pour voir les détails ou marquer comme payé.';
  }

  @override
  String get notifTestTitle => '✅ Les notifications fonctionnent !';

  @override
  String get notifTestBody => 'Tu seras rappelé avant chaque prélèvement.';

  @override
  String get notifActionMarkPaid => 'Marquer payé';

  @override
  String get notifActionViewDetails => 'Voir détails';

  @override
  String get notifChannelName => 'Rappels d\'abonnements';

  @override
  String get notifChannelDesc =>
      'Notifications pour les prochains prélèvements';
}
