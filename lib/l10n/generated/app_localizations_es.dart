// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'CustomSubs';

  @override
  String get sectionUpcoming => 'Próximos';

  @override
  String get sectionLater => 'Más tarde';

  @override
  String get sectionPaused => 'En pausa';

  @override
  String get sectionSpendingSummary => 'Resumen de gastos';

  @override
  String get navAddNew => 'Agregar';

  @override
  String get navCalendar => 'Calendario';

  @override
  String get navAnalytics => 'Análisis';

  @override
  String get categoryEntertainment => 'Entretenimiento';

  @override
  String get categoryProductivity => 'Productividad';

  @override
  String get categoryFitness => 'Fitness';

  @override
  String get categoryNews => 'Noticias';

  @override
  String get categoryCloud => 'Almacenamiento en la nube';

  @override
  String get categoryGaming => 'Videojuegos';

  @override
  String get categoryEducation => 'Educación';

  @override
  String get categoryFinance => 'Finanzas';

  @override
  String get categoryShopping => 'Compras';

  @override
  String get categoryUtilities => 'Servicios';

  @override
  String get categoryHealth => 'Salud';

  @override
  String get categoryOther => 'Otro';

  @override
  String get categorySports => 'Deportes';

  @override
  String get cycleWeekly => 'Semanal';

  @override
  String get cycleBiweekly => 'Quincenal';

  @override
  String get cycleMonthly => 'Mensual';

  @override
  String get cycleQuarterly => 'Trimestral';

  @override
  String get cycleBiannual => 'Semestral';

  @override
  String get cycleYearly => 'Anual';

  @override
  String get cycleShortWeekly => 'sem';

  @override
  String get cycleShortBiweekly => '2sem';

  @override
  String get cycleShortMonthly => 'mes';

  @override
  String get cycleShortQuarterly => 'trim';

  @override
  String get cycleShortBiannual => '6m';

  @override
  String get cycleShortYearly => 'año';

  @override
  String get onboardingWelcome => 'Bienvenido a CustomSubs';

  @override
  String get onboardingSubtitle => 'Tu rastreador de suscripciones privado';

  @override
  String get onboardingFeature1Title => 'Rastrea todo';

  @override
  String get onboardingFeature1Desc =>
      'Todas tus suscripciones en un solo lugar. Sin vincular bancos. Sin inicio de sesión.';

  @override
  String get onboardingFeature2Title => 'No te pierdas un cobro';

  @override
  String get onboardingFeature2Desc =>
      'Recibe notificaciones 7 días antes, 1 día antes y la mañana de cada fecha de facturación.';

  @override
  String get onboardingFeature3Title => 'Cancela con confianza';

  @override
  String get onboardingFeature3Desc =>
      'Guías paso a paso para cancelar cualquier suscripción rápidamente.';

  @override
  String get onboardingGetStarted => 'Empezar';

  @override
  String get onboardingPrivacyNote =>
      '100% sin conexión • No se requiere cuenta';

  @override
  String get homeTitle => 'CustomSubs';

  @override
  String get homeEmptyTitle => 'Sin suscripciones';

  @override
  String get homeEmptySubtitle =>
      'Toca + para agregar la primera. Te recordaremos antes de cada cobro.';

  @override
  String get homeAddSubscription => 'Agregar suscripción';

  @override
  String get homeDeleteTitle => 'Eliminar suscripción';

  @override
  String get homeDeleteCancel => 'Cancelar';

  @override
  String get homeDeleteConfirm => 'Eliminar';

  @override
  String get homePaid => 'Pagado';

  @override
  String get homeMarkAsPaid => 'Marcar como pagado';

  @override
  String get homeMarkedAsPaid => 'Marcado como pagado ✓';

  @override
  String get homePerMonth => '/mes';

  @override
  String get homePerYear => '/año';

  @override
  String get homePerDay => '/día';

  @override
  String homeError(String error) {
    return 'Error: $error';
  }

  @override
  String homePaidCount(int paid, int total) {
    return 'Pagado · $paid de $total';
  }

  @override
  String get homeNext30Days => 'próximos 30 días';

  @override
  String get homeLaterDays => '31–90 días';

  @override
  String homePausedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en pausa',
      one: '1 en pausa',
    );
    return '$_temp0';
  }

  @override
  String get homeResumesToday => 'Se reanuda hoy';

  @override
  String get homeResumesTomorrow => 'Se reanuda mañana';

  @override
  String homeResumesInDays(int days) {
    return 'Se reanuda en $days días';
  }

  @override
  String homePausedDaysAgo(int days) {
    return 'En pausa hace $days días';
  }

  @override
  String get homePausedManualResume => 'Reanudar manualmente';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsShare => 'Compartir';

  @override
  String get settingsRateApp => 'Calificar';

  @override
  String get settingsFeedback => 'Comentarios';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsPrimaryCurrency => 'Moneda principal';

  @override
  String settingsCurrencyChanged(String currency) {
    return 'Moneda cambiada a $currency';
  }

  @override
  String settingsCurrencyRestored(String currency) {
    return 'Moneda restaurada a $currency';
  }

  @override
  String get settingsDefaultReminderTime =>
      'Hora de recordatorio predeterminada';

  @override
  String get settingsReminderTimeUpdated => 'Hora de recordatorio actualizada';

  @override
  String get settingsReminderTimeRestored => 'Hora de recordatorio restaurada';

  @override
  String get settingsDarkMode => 'Modo oscuro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Predeterminado del sistema';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsTestNotification => 'Notificación de prueba';

  @override
  String get settingsTestNotificationSubtitle =>
      'Verificar que los recordatorios funcionan';

  @override
  String get settingsNotificationsDisabled => 'Notificaciones desactivadas';

  @override
  String get settingsNotificationsDisabledBody =>
      'Las notificaciones están actualmente desactivadas para CustomSubs. Actívalas en los ajustes del dispositivo para recibir recordatorios de facturación.';

  @override
  String get settingsNotNow => 'Ahora no';

  @override
  String get settingsOpenSettings => 'Abrir ajustes';

  @override
  String get settingsTestSent => 'Prueba enviada';

  @override
  String get settingsTestSentBody =>
      'Se acaba de enviar una notificación de prueba.\n\n¿No la ves? Las notificaciones pueden estar desactivadas en los ajustes de tu dispositivo.';

  @override
  String get settingsGotIt => 'Entendido';

  @override
  String get settingsNotificationsHelp =>
      'CustomSubs envía recordatorios a la hora elegida antes de las fechas de facturación. Asegúrate de que las notificaciones estén activadas en los ajustes de tu dispositivo.';

  @override
  String get settingsPrivacy => 'Privacidad';

  @override
  String get settingsShareAnalytics => 'Compartir datos de uso anónimos';

  @override
  String get settingsShareAnalyticsSubtitle =>
      'Nos ayuda a mejorar la app. No se recopilan datos personales.';

  @override
  String get settingsData => 'Datos';

  @override
  String get settingsLastBackup => 'Última copia de seguridad';

  @override
  String get settingsNeverBackedUp => 'Nunca respaldado';

  @override
  String get settingsExportBackup => 'Exportar copia de seguridad';

  @override
  String get settingsExportBackupSubtitle =>
      'Guardar tus suscripciones en un archivo';

  @override
  String get settingsPreparingBackup => 'Preparando copia de seguridad...';

  @override
  String get settingsBackupSuccess =>
      '¡Copia de seguridad exportada con éxito!';

  @override
  String settingsBackupError(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get settingsImportBackup => 'Importar copia de seguridad';

  @override
  String get settingsImportBackupSubtitle =>
      'Restaurar suscripciones desde un archivo';

  @override
  String get settingsImportComplete => 'Importación completada';

  @override
  String settingsImportFound(int count) {
    return 'Encontradas: $count suscripciones';
  }

  @override
  String settingsImportDuplicates(int count) {
    return 'Duplicados omitidos: $count';
  }

  @override
  String settingsImportImported(int count) {
    return 'Importadas: $count suscripciones';
  }

  @override
  String settingsImportSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suscripciones no pudieron importarse por datos inválidos.',
      one: '1 suscripción no pudo importarse por datos inválidos.',
    );
    return '$_temp0';
  }

  @override
  String get settingsImportNotifications =>
      'Se han programado notificaciones para todas las suscripciones importadas.';

  @override
  String get settingsOk => 'OK';

  @override
  String get settingsDeleteAll => 'Eliminar todos los datos';

  @override
  String get settingsDeleteAllSubtitle =>
      'Eliminar permanentemente todas las suscripciones';

  @override
  String get settingsDeleteAllTitle => '¿Eliminar todos los datos?';

  @override
  String get settingsDeleteAllBody =>
      'Esto eliminará permanentemente todas las suscripciones y ajustes. Esta acción no se puede deshacer.\n\n¿Estás seguro de que quieres continuar?';

  @override
  String get settingsCancel => 'Cancelar';

  @override
  String get settingsContinue => 'Continuar';

  @override
  String get settingsFinalConfirmation => 'Confirmación final';

  @override
  String get settingsFinalConfirmationBody =>
      'Esta acción es irreversible. Todos tus datos de suscripción se perderán para siempre.';

  @override
  String get settingsTypeDelete => 'Escribe DELETE para confirmar:';

  @override
  String get settingsDeleteHint => 'DELETE';

  @override
  String get settingsDeleteButton => 'Eliminar todo';

  @override
  String get settingsTypeDeleteWarning => 'Escribe DELETE para confirmar';

  @override
  String get settingsAllDataDeleted => 'Todos los datos eliminados con éxito';

  @override
  String settingsDeleteError(String error) {
    return 'Error al eliminar: $error';
  }

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsTermsOfService => 'Términos de servicio';

  @override
  String get settingsMadeWith => 'Hecho con amor por CustomApps LLC';

  @override
  String get settingsDeveloperTools => 'Herramientas de desarrollador';

  @override
  String get settingsLoadDemoData => 'Cargar datos demo';

  @override
  String get settingsLoadDemoDataSubtitle =>
      'Agregar 18 suscripciones de ejemplo';

  @override
  String get settingsClearDemoData => 'Limpiar datos demo';

  @override
  String get settingsClearDemoDataSubtitle =>
      'Eliminar solo las suscripciones demo';

  @override
  String get settingsDeveloperUnlocked =>
      'Herramientas de desarrollador desbloqueadas';

  @override
  String get settingsLoadDemoTitle => '¿Cargar datos demo?';

  @override
  String get settingsLoadDemoBody =>
      'Esto agregará 18 suscripciones de ejemplo a tu app. Tus suscripciones existentes no se verán afectadas.\n\nLas suscripciones demo están etiquetadas y pueden eliminarse con \"Limpiar datos demo\".';

  @override
  String get settingsLoad => 'Cargar';

  @override
  String settingsLoadedDemoCount(int count) {
    return '$count suscripciones demo cargadas';
  }

  @override
  String settingsLoadDemoError(String error) {
    return 'Error al cargar datos demo: $error';
  }

  @override
  String get settingsClearDemoTitle => '¿Limpiar datos demo?';

  @override
  String settingsClearDemoBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Esto eliminará $count suscripciones demo. Tus suscripciones reales no se verán afectadas.',
      one:
          'Esto eliminará 1 suscripción demo. Tus suscripciones reales no se verán afectadas.',
    );
    return '$_temp0';
  }

  @override
  String get settingsClear => 'Limpiar';

  @override
  String settingsClearedDemoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suscripciones demo eliminadas',
      one: '1 suscripción demo eliminada',
    );
    return '$_temp0';
  }

  @override
  String settingsClearDemoError(String error) {
    return 'Error al limpiar datos demo: $error';
  }

  @override
  String get settingsNoDemoFound => 'No se encontraron suscripciones demo';

  @override
  String get backupReminderTitle => 'Respalda tus datos';

  @override
  String get backupReminderBody =>
      '¡Has agregado 3 suscripciones! Considera respaldar tus datos para prevenir pérdidas.';

  @override
  String get backupReminderHint =>
      'Puedes exportar una copia de seguridad en cualquier momento en Ajustes → Exportar copia de seguridad.';

  @override
  String get backupReminderDontShow => 'No mostrar de nuevo';

  @override
  String get backupReminderGotIt => 'Entendido';

  @override
  String get promoTitle => 'Más de CustomApps';

  @override
  String get promoSubtitle => 'Conoce nuestras otras apps';

  @override
  String get promoCouldNotOpen => 'No se pudo abrir el sitio web';

  @override
  String get promoCustomBank => 'CustomBank';

  @override
  String get promoCustomBankDesc => 'Simulador bancario, sin dinero real';

  @override
  String get promoCustomCrypto => 'CustomCrypto';

  @override
  String get promoCustomCryptoDesc => 'Trading crypto de prueba';

  @override
  String get promoCustomDashboards => 'CustomDashboards';

  @override
  String get promoCustomDashboardsDesc => 'Simulador de panel de e-commerce';

  @override
  String get promoCustomNotify => 'CustomNotify';

  @override
  String get promoCustomNotifyDesc => 'Recordatorios y alertas inteligentes';

  @override
  String get promoCustomWorth => 'CustomWorth';

  @override
  String get promoCustomWorthDesc => 'Rastrea tu patrimonio neto';

  @override
  String get addSubscriptionTitle => 'Agregar suscripción';

  @override
  String get editSubscriptionTitle => 'Editar suscripción';

  @override
  String get addSubscriptionSave => 'Guardar';

  @override
  String get addSubscriptionChooseTemplate => 'Elegir una plantilla';

  @override
  String get addSubscriptionSearchHint => 'Buscar servicios...';

  @override
  String get addSubscriptionNoTemplates => 'No se encontraron plantillas';

  @override
  String get addSubscriptionNoTemplatesHint =>
      'Prueba con otro término de búsqueda o crea una suscripción personalizada abajo';

  @override
  String get addSubscriptionCreateCustom => 'Crear personalizada';

  @override
  String get addSubscriptionInvalidData => 'Por favor ingresa datos válidos';

  @override
  String get addSubscriptionAdded => '¡Suscripción agregada!';

  @override
  String get addSubscriptionUpdated => '¡Suscripción actualizada!';

  @override
  String addSubscriptionError(String error) {
    return 'Error: $error';
  }

  @override
  String get addSubscriptionButton => 'Agregar suscripción';

  @override
  String get updateSubscriptionButton => 'Actualizar suscripción';

  @override
  String get addSubscriptionTemplateError => 'Error al cargar plantillas';

  @override
  String get detailsSection => 'Detalles de la suscripción';

  @override
  String get detailsNameLabel => 'Nombre *';

  @override
  String get detailsNameHint => 'Netflix, Spotify, etc.';

  @override
  String get detailsNameValidation => 'Por favor ingresa un nombre';

  @override
  String get detailsAmountLabel => 'Monto *';

  @override
  String get detailsAmountHint => '0.00';

  @override
  String get detailsAmountRequired => 'Requerido';

  @override
  String get detailsAmountInvalid => 'Monto inválido';

  @override
  String get detailsCurrencyLabel => 'Moneda';

  @override
  String get detailsBillingCycleLabel => 'Ciclo de facturación *';

  @override
  String get detailsNextBillingDateLabel => 'Próxima fecha de facturación *';

  @override
  String get detailsCategoryLabel => 'Categoría *';

  @override
  String get trialSectionTitle => 'Prueba gratuita';

  @override
  String get trialSectionSubtitle =>
      'Rastrear período de prueba y fecha de conversión';

  @override
  String get trialToggleLabel => 'Es una prueba gratuita';

  @override
  String get trialToggleSubtitle =>
      'Activar si la suscripción está en período de prueba';

  @override
  String get trialEndDateLabel => 'Fecha de fin de prueba';

  @override
  String get trialSetEndDate => 'Establecer fecha de fin';

  @override
  String get trialAmountAfter => 'Monto después de la prueba';

  @override
  String get cancelSectionTitle => 'Info de cancelación';

  @override
  String get cancelSectionSubtitle => 'Cómo cancelar esta suscripción';

  @override
  String get cancelUrlLabel => 'URL de cancelación';

  @override
  String get cancelUrlHint => 'https://...';

  @override
  String get cancelPhoneLabel => 'Teléfono de cancelación';

  @override
  String get cancelPhoneHint => '+1 (555) 123-4567';

  @override
  String get cancelNotesLabel => 'Notas de cancelación';

  @override
  String get cancelNotesHint => 'Cómo cancelar...';

  @override
  String get cancelStepsTitle => 'Pasos de cancelación';

  @override
  String get cancelAddStep => 'Agregar paso';

  @override
  String cancelStepLabel(int number) {
    return 'Paso $number';
  }

  @override
  String get cancelStepHint => 'Ingresar paso...';

  @override
  String get notesSectionTitle => 'Notas';

  @override
  String get notesSectionSubtitle => 'Agregar notas adicionales';

  @override
  String get notesGeneralLabel => 'Notas generales';

  @override
  String get notesGeneralHint => 'Agregar notas...';

  @override
  String get reminderFirstLabel => 'Primer recordatorio';

  @override
  String get reminderSecondLabel => 'Segundo recordatorio';

  @override
  String get reminderOff => 'Desactivado';

  @override
  String reminderDaysBefore(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días antes',
      one: '1 día antes',
    );
    return '$_temp0';
  }

  @override
  String get reminderOnBillingDay => 'Recordar el día de facturación';

  @override
  String get reminderTimeLabel => 'Hora del recordatorio';

  @override
  String get detailScreenTitle => 'Detalles';

  @override
  String get detailNotFound => 'Suscripción no encontrada';

  @override
  String get detailDeleteTitle => '¿Eliminar suscripción?';

  @override
  String get detailDeleteBody =>
      'Esto eliminará permanentemente esta suscripción y cancelará todos los recordatorios. Esta acción no se puede deshacer.';

  @override
  String get detailDeleteButton => 'Eliminar';

  @override
  String get detailMarkedAsPaid => 'Marcado como pagado ✓';

  @override
  String get detailPauseTitle => 'Pausar suscripción';

  @override
  String get detailPauseWhilePaused => 'Durante la pausa:';

  @override
  String get detailPauseNoReminders => 'No se enviarán recordatorios';

  @override
  String get detailPauseNoBilling => 'Las fechas de facturación no avanzarán';

  @override
  String get detailPauseNoSpending => 'Excluido de los totales de gastos';

  @override
  String get detailPauseAutoResume =>
      'Fecha de reanudación automática (opcional):';

  @override
  String get detailPauseManual => 'Reanudar manualmente';

  @override
  String get detailPauseClearDate => 'Borrar fecha';

  @override
  String get detailPauseButton => 'Pausar';

  @override
  String get detailPaused => 'Suscripción en pausa';

  @override
  String detailAutoResumes(String date) {
    return 'Se reanuda automáticamente el $date';
  }

  @override
  String detailPausedDaysAgo(int days) {
    return 'En pausa hace $days días';
  }

  @override
  String get detailResumeButton => 'Reanudar suscripción';

  @override
  String detailLoadError(String error) {
    return 'Error al cargar suscripción: $error';
  }

  @override
  String get detailGoBack => 'Volver';

  @override
  String get detailPaid => 'Pagado';

  @override
  String get detailMarkAsPaid => 'Marcar como pagado';

  @override
  String get billingInfoTitle => 'Información de facturación';

  @override
  String get billingNextBilling => 'Próxima facturación';

  @override
  String get billingCycle => 'Ciclo de facturación';

  @override
  String get billingAmount => 'Monto';

  @override
  String get billingStarted => 'Inicio';

  @override
  String get billingTrialEnds => 'Fin de prueba';

  @override
  String billingThenAmount(String amount, String cycle) {
    return 'Luego $amount/$cycle';
  }

  @override
  String get headerTrialBadge => 'Prueba';

  @override
  String get headerPaidBadge => 'Pagado';

  @override
  String get cancelCardTitle => 'Cómo cancelar';

  @override
  String get cancelCardOpenPage => 'Abrir página de cancelación';

  @override
  String cancelCardCall(String phone) {
    return 'Llamar a $phone';
  }

  @override
  String get cancelCardStepsTitle => 'Pasos de cancelación';

  @override
  String cancelCardProgress(int completed, int total) {
    return '$completed de $total completados';
  }

  @override
  String get reminderCardTitle => 'Ajustes de recordatorio';

  @override
  String get reminderCardFirst => 'Primer recordatorio';

  @override
  String reminderCardFirstValue(int days) {
    return '$days días antes';
  }

  @override
  String get reminderCardSecond => 'Segundo recordatorio';

  @override
  String reminderCardSecondValue(int days) {
    return '$days días antes';
  }

  @override
  String get reminderCardDayOf => 'Recordatorio del día';

  @override
  String get reminderCardEnabled => 'Activado';

  @override
  String get reminderCardTime => 'Hora del recordatorio';

  @override
  String get notesCardTitle => 'Notas';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get calendarEmptyTitle => 'Sin fechas de facturación';

  @override
  String get calendarEmptySubtitle =>
      'Agrega tu primera suscripción para ver las fechas de facturación en el calendario.';

  @override
  String get calendarAddSubscription => 'Agregar suscripción';

  @override
  String get calendarMonth => 'Mes';

  @override
  String get calendarTapHint =>
      'Toca una fecha para ver los detalles de facturación';

  @override
  String calendarError(String error) {
    return 'Error: $error';
  }

  @override
  String get calendarNoBills => 'Sin facturas en esta fecha';

  @override
  String get analyticsTitle => 'Análisis';

  @override
  String get analyticsEmptyTitle => 'Sin análisis aún';

  @override
  String get analyticsEmptySubtitle =>
      'Agrega tu primera suscripción para ver información de gastos';

  @override
  String get analyticsAddSubscription => 'Agregar suscripción';

  @override
  String get analyticsLoadError => 'Error al cargar análisis';

  @override
  String get analyticsYearlyForecast => 'Pronóstico anual';

  @override
  String analyticsMonthlyTotal(String amount) {
    return '$amount/mes';
  }

  @override
  String analyticsSubsAndDaily(int count, String daily) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suscripciones',
      one: '1 suscripción',
    );
    return '$_temp0 · $daily/día';
  }

  @override
  String get analyticsSpendingByCategory => 'Gastos por categoría';

  @override
  String get analyticsTopSubscriptions => 'Top suscripciones';

  @override
  String get analyticsByCurrency => 'Por moneda';

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
  String get analyticsExchangeNote => 'A tasas de cambio incluidas';

  @override
  String get analyticsActiveVsPaused => 'Activas vs En pausa';

  @override
  String analyticsActiveCount(int count) {
    return 'Activas ($count)';
  }

  @override
  String analyticsPausedCount(int count) {
    return 'En pausa ($count)';
  }

  @override
  String get analyticsIfResumed => 'Si se reanudan todas';

  @override
  String get analyticsMonthlyLabel => 'Mensual';

  @override
  String get insightsTitle => 'Análisis inteligente';

  @override
  String insightsOverlapSummary(int count, String group) {
    return '$count servicios de $group';
  }

  @override
  String insightsOverlapCombined(String names, String amount) {
    return '$names = $amount/mes combinado';
  }

  @override
  String insightsOverlapTitle(String group) {
    return '$group duplicados';
  }

  @override
  String insightsOverlapBody(int count, String group) {
    return 'Tienes $count suscripciones de $group. Estos servicios ofrecen contenido similar — puede que solo necesites uno.';
  }

  @override
  String insightsOverlapCombinedDetail(String monthly, String yearly) {
    return 'Combinado: $monthly/mes · $yearly/año';
  }

  @override
  String get insightsAnnualTitle => 'Cambiar a facturación anual';

  @override
  String insightsAnnualSummary(String min, String max) {
    return 'Ahorro est. $min–$max/año';
  }

  @override
  String get insightsAnnualHeading => 'Ahorros facturación anual';

  @override
  String get insightsAnnualBody =>
      'La mayoría de servicios ofrecen un descuento del 15–20% cuando pagas anualmente en vez de mensualmente.';

  @override
  String insightsAnnualRange(String min, String max) {
    return '$min–$max';
  }

  @override
  String get insightsAnnualEstimated => 'ahorro anual estimado';

  @override
  String insightsAnnualAppliesTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aplica a $count suscripciones mensuales.',
      one: 'Aplica a 1 suscripción mensual.',
    );
    return '$_temp0';
  }

  @override
  String get insightsAnnualDisclaimer =>
      '* Estimado basado en un descuento típico del 15–20%. Verifica el precio anual actual de cada proveedor.';

  @override
  String insightsBundleTitle(String name) {
    return '$name disponible';
  }

  @override
  String insightsBundleSummary(String amount) {
    return 'Ahorra ~$amount/mes vs planes separados';
  }

  @override
  String get insightsBundleYouPayNow => 'Pagas ahora';

  @override
  String get insightsBundleMonthlySavings => 'Ahorro mensual';

  @override
  String insightsBundleSavingsDetail(String amount) {
    return '~$amount/mes respecto al mes pasado';
  }

  @override
  String get insightsBundleDisclaimer =>
      '* Precio del paquete mostrado en USD. Verifica precios actuales — promociones y precios regionales varían.';

  @override
  String get insightsBundleCheckPricing => 'Ver precios actuales';

  @override
  String insightsHighSpendSummary(String category, String percent) {
    return '$category = $percent% del gasto';
  }

  @override
  String get insightsHighSpendSubtitle =>
      'Una categoría domina tu presupuesto de suscripciones';

  @override
  String insightsHighSpendTitle(String category) {
    return 'Gastos en $category';
  }

  @override
  String insightsHighSpendBody(
      String category, String percent, String monthly, String yearly) {
    return '$category representa el $percent% de tu gasto en suscripciones activas — $monthly/mes ($yearly/año).';
  }

  @override
  String get insightsHighSpendListTitle => 'Suscripciones en esta categoría:';

  @override
  String get dateToday => 'Hoy';

  @override
  String get dateTomorrow => 'Mañana';

  @override
  String get dateYesterday => 'Ayer';

  @override
  String get dateOverdue => 'Vencido';

  @override
  String dateDaysAgo(int days) {
    return 'hace $days días';
  }

  @override
  String dateWeeksAgo(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'hace $weeks semanas',
      one: 'hace 1 semana',
    );
    return '$_temp0';
  }

  @override
  String dateInDays(int days) {
    return 'en $days días';
  }

  @override
  String dateInWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'en $weeks semanas',
      one: 'en 1 semana',
    );
    return '$_temp0';
  }

  @override
  String dateInMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'en $months meses',
      one: 'en 1 mes',
    );
    return '$_temp0';
  }

  @override
  String notifFirstReminderTitle(String name, int days) {
    return '📅 $name — Cobro en $days días';
  }

  @override
  String notifFirstReminderBody(String amount, String date) {
    return 'Cargo de $amount el $date';
  }

  @override
  String notifFirstReminderSubtitle(int days) {
    return 'Cobro en $days días';
  }

  @override
  String notifFirstReminderExpanded(String amount, String date) {
    return 'Cargo de $amount el $date\n\nToca para ver detalles o marcar como pagado.';
  }

  @override
  String notifSecondReminderTitleTomorrow(String name) {
    return '⚠️ $name — Se cobra mañana';
  }

  @override
  String notifSecondReminderTitle(String name, int days) {
    return '⚠️ $name — Se cobra en $days días';
  }

  @override
  String notifSecondReminderBody(String amount, String date) {
    return 'Se cobrará $amount el $date';
  }

  @override
  String get notifSecondReminderSubtitleTomorrow => 'Se cobra mañana';

  @override
  String notifSecondReminderSubtitle(int days) {
    return 'Se cobra en $days días';
  }

  @override
  String notifSecondReminderExpanded(String amount, String date) {
    return 'Se cobrará $amount el $date\n\nToca para ver detalles o marcar como pagado.';
  }

  @override
  String notifDayOfTitle(String name) {
    return '💰 $name — Cobro hoy';
  }

  @override
  String notifDayOfBody(String amount) {
    return 'Cargo de $amount esperado hoy';
  }

  @override
  String get notifDayOfSubtitle => 'Cobro hoy';

  @override
  String notifDayOfExpanded(String amount) {
    return 'Cargo de $amount esperado hoy\n\nToca para ver detalles o marcar como pagado.';
  }

  @override
  String notifTrialEnding3Days(String name) {
    return '🔔 $name — Prueba termina en 3 días';
  }

  @override
  String notifTrialEndingTomorrow(String name) {
    return '🔔 $name — Prueba termina mañana';
  }

  @override
  String notifTrialEndsToday(String name) {
    return '🔔 $name — Prueba termina hoy';
  }

  @override
  String get notifTrialSubtitle => 'Fin de prueba';

  @override
  String notifTrialBody(String date, String amount, String cycle) {
    return 'La prueba gratuita termina el $date. Se te cobrará $amount/$cycle después.\n\nToca para ver detalles o marcar como pagado.';
  }

  @override
  String get notifTestTitle => '✅ ¡Las notificaciones funcionan!';

  @override
  String get notifTestBody => 'Te recordaremos antes de cada cobro.';

  @override
  String get notifActionMarkPaid => 'Marcar pagado';

  @override
  String get notifActionViewDetails => 'Ver detalles';

  @override
  String get notifChannelName => 'Recordatorios de suscripciones';

  @override
  String get notifChannelDesc =>
      'Notificaciones para próximos cobros de suscripciones';
}
