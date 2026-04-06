import 'package:flutter/material.dart';
import 'package:custom_subs/l10n/generated/app_localizations.dart';

/// Wraps a widget in a [MaterialApp] with localization delegates configured.
///
/// Use this instead of bare `MaterialApp(home: ...)` in widget tests
/// so that widgets using `AppLocalizations.of(context)` can resolve strings.
Widget buildLocalizedWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}
