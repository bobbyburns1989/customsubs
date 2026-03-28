// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarControllerHash() =>
    r'da1f6b9ecc9646568632acf602adcbeb677f823f';

/// Controller for the Calendar screen.
///
/// Projects billing dates across a 6-month window (3 months back, 3 forward)
/// and groups them by calendar day for display in the calendar grid.
///
/// Only includes active subscriptions — paused subs are excluded,
/// consistent with the home screen's upcoming/later sections.
///
/// Copied from [CalendarController].
@ProviderFor(CalendarController)
final calendarControllerProvider =
    AutoDisposeAsyncNotifierProvider<CalendarController, CalendarData>.internal(
  CalendarController.new,
  name: r'calendarControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CalendarController = AutoDisposeAsyncNotifier<CalendarData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
