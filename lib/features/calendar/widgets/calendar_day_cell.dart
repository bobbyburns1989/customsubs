import 'package:flutter/material.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/core/extensions/theme_extensions.dart';

/// Builds colored dot markers below a calendar day cell.
///
/// Shows up to 3 dots, each colored with the subscription's brand color.
/// Past dates render dots at 60% opacity to visually distinguish them
/// from upcoming billing dates.
///
/// Returns null when [events] is empty (no markers to show).
Widget? buildDayMarkers(
  BuildContext context,
  DateTime day,
  List<Subscription> events,
) {
  if (events.isEmpty) return null;

  final now = DateTime.now();
  final isPast = day.isBefore(DateTime(now.year, now.month, now.day));

  // Show up to 3 dots — full list visible in the detail panel on tap
  final dotsToShow = events.take(3).toList();

  return Positioned(
    bottom: 4,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: dotsToShow.map((sub) {
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: Color(sub.colorValue).withValues(alpha: isPast ? 0.5 : 1.0),
            shape: BoxShape.circle,
          ),
        );
      }).toList(),
    ),
  );
}

/// Builds a custom "today" cell with a sage green tinted circle background.
Widget buildTodayCell(
  BuildContext context,
  DateTime day,
  DateTime focusedDay,
) {
  return Center(
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: context.colors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ),
  );
}

/// Builds a custom "selected" cell with a solid sage green circle.
Widget buildSelectedCell(
  BuildContext context,
  DateTime day,
  DateTime focusedDay,
) {
  return Center(
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.colors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ),
  );
}
