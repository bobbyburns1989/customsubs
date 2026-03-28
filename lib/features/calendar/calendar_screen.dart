import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:custom_subs/app/router.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/extensions/theme_extensions.dart';
import 'package:custom_subs/core/utils/haptic_utils.dart';
import 'package:custom_subs/core/widgets/empty_state_widget.dart';
import 'package:custom_subs/core/widgets/standard_card.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/services/analytics_service.dart';
import 'package:custom_subs/features/calendar/calendar_controller.dart';
import 'package:custom_subs/features/calendar/widgets/calendar_day_cell.dart';
import 'package:custom_subs/features/calendar/widgets/day_detail_list.dart';

/// Calendar view showing billing dates as colored dots on a monthly grid.
///
/// Tap any date to see which subscriptions bill that day and the total cost.
/// Only shows active subscriptions — paused subs are excluded.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  /// Controls which month is currently visible in the calendar.
  DateTime _focusedDay = DateTime.now();

  /// The date the user has tapped. Null initially (no selection).
  DateTime? _selectedDay;

  /// Track whether we've fired the analytics event this session.
  bool _hasTrackedView = false;

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(calendarControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: calendarAsync.when(
        data: (calendarData) {
          // Fire analytics event once per screen visit
          if (!_hasTrackedView) {
            _hasTrackedView = true;
            ref.read(analyticsServiceProvider).capture(
              'calendar_viewed',
              {'active_sub_count': calendarData.activeSubscriptions.length},
            );
          }

          // Empty state when no active subscriptions exist
          if (calendarData.activeSubscriptions.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.calendar_month_outlined,
              title: 'No Billing Dates',
              subtitle:
                  'Add your first subscription to see billing dates on the calendar.',
              buttonText: 'Add Subscription',
              onButtonPressed: () => context.push(AppRouter.addSubscription),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(calendarControllerProvider.notifier).refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar grid inside a card
                  StandardCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: AppSizes.md,
                    ),
                    child: TableCalendar<Subscription>(
                      firstDay: DateTime(
                        DateTime.now().year - 1,
                        DateTime.now().month,
                        1,
                      ),
                      lastDay: DateTime(
                        DateTime.now().year + 1,
                        DateTime.now().month + 1,
                        0,
                      ),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),

                      // Lock to month view — no week/2-week toggle
                      calendarFormat: CalendarFormat.month,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                      },
                      startingDayOfWeek: StartingDayOfWeek.sunday,

                      // Provide subscriptions for each day (drives dot markers)
                      eventLoader: (day) =>
                          calendarData.subscriptionsForDay(day),

                      onDaySelected: (selectedDay, focusedDay) {
                        HapticUtils.selection();
                        final subs =
                            calendarData.subscriptionsForDay(selectedDay);
                        ref.read(analyticsServiceProvider).capture(
                          'calendar_day_tapped',
                          {
                            'has_subs': subs.isNotEmpty,
                            'sub_count': subs.length,
                          },
                        );
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },

                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                          _selectedDay = null; // Clear selection on month swipe
                        });
                      },

                      // Custom cell builders for branded styling
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, day, events) =>
                            buildDayMarkers(
                          context,
                          day,
                          events.cast<Subscription>(),
                        ),
                        todayBuilder: buildTodayCell,
                        selectedBuilder: buildSelectedCell,
                      ),

                      // Header: centered month/year, sage green nav arrows
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle:
                            Theme.of(context).textTheme.titleMedium!,
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: context.colors.textPrimary,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: context.colors.textPrimary,
                        ),
                      ),

                      // Day-of-week header style
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          color: context.colors.textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        weekendStyle: TextStyle(
                          color: context.colors.textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // General calendar styling
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        // Default text styles (used when custom builders don't apply)
                        defaultTextStyle: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 14,
                        ),
                        weekendTextStyle: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 14,
                        ),
                        // Markers (dots) — handled by markerBuilder, but set max
                        markersMaxCount: 3,
                        markerSize: 6,
                        // Cell sizing
                        cellMargin: const EdgeInsets.all(4),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.sectionSpacing),

                  // Day detail section (shows on tap) with animated crossfade
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _selectedDay != null
                        ? DayDetailList(
                            key: ValueKey(_selectedDay),
                            day: _selectedDay!,
                            subscriptions:
                                calendarData.subscriptionsForDay(_selectedDay!),
                            primaryCurrency: calendarData.primaryCurrency,
                            dayTotal:
                                calendarData.totalForDay(_selectedDay!),
                          )
                        : Padding(
                            key: const ValueKey('prompt'),
                            padding: const EdgeInsets.all(AppSizes.xl),
                            child: Center(
                              child: Text(
                                'Tap a date to see billing details',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: context.colors.textTertiary,
                                    ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },

        // Loading skeleton — matches card layout shape
        loading: () => Padding(
          padding: const EdgeInsets.all(AppSizes.base),
          child: Column(
            children: [
              Container(
                height: 360,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(
                    color: context.colors.border,
                    width: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
