library flutter_calendar_essentials;
import 'package:flutter/material.dart';
import 'package:flutter_calendar_essentials/calendar_style.dart';
import 'package:flutter_calendar_essentials/enums.dart';
import 'package:flutter_calendar_essentials/event_calendar.dart';
import 'package:flutter_calendar_essentials/calendar_essential_state.dart';
typedef CustomValueChanged<T, U> = void Function(T value1, U value2);
class CalendarEssentials extends StatelessWidget {
  final List<EventCalendarEssential> events;
  final CalendarStyle? calendarStyle;
  final ValueChanged<DateTime>? onDaySelected;
  final CustomValueChanged<DateTime, DateTime>? onChanged;
  final DateTime? firstDay;
  final DateTime? lastDay;
  final double? heightCell;
  final CalendarFormat? defaultCalendarFormat;
  final ValueChanged<CalendarFormat>? onFormatChanged;
  final ValueChanged<DateTime>? onPageChanged;
  final AvailableGestures availableGestures;
  final DateTime? selectedDay;
  final bool showComboboxForMonthYear;
  final ValueChanged<int>? onYearChanged;
  final ValueChanged<int>? onMonthChanged;

  const CalendarEssentials({super.key,
    required this.events,
    this.calendarStyle,
    this.firstDay,
    this.onDaySelected,
    this.onChanged,
    this.lastDay,
    this.heightCell,
    this.defaultCalendarFormat,
    this.onFormatChanged,
    this.onPageChanged,
    this.selectedDay,
    this.availableGestures = AvailableGestures.all,
    this.showComboboxForMonthYear = false,
    this.onYearChanged,
    this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CalendarEssentialsStatefulWidget(
      events: events,
      calendarStyle: calendarStyle,
      onDaySelected: onDaySelected,
      firstDay: firstDay,
      lastDay: lastDay,
      defaultCalendarFormat: defaultCalendarFormat,
      onFormatChanged: onFormatChanged,
      onPageChanged: onPageChanged,
      onChanged: onChanged,
      availableGestures: availableGestures,
      selectedDay: selectedDay,
      heightCell: heightCell,
      showComboboxForMonthYear: showComboboxForMonthYear,
      onYearChanged: onYearChanged,
      onMonthChanged: onMonthChanged,
    );
  }
}

class CalendarEssentialsStatefulWidget extends StatefulWidget {
  final Weekday firstDayOfWeek = Weekday.monday;
  final List<EventCalendarEssential> events;
  final CalendarStyle? calendarStyle;
  final double? heightCell;
  final ValueChanged<DateTime>? onDaySelected;
  final CustomValueChanged<DateTime, DateTime>? onChanged;
  final DateTime? firstDay;
  final DateTime? lastDay;
  final CalendarFormat? defaultCalendarFormat;
  final ValueChanged<CalendarFormat>? onFormatChanged;
  final ValueChanged<DateTime>? onPageChanged;
  final AvailableGestures availableGestures;
  final DateTime? selectedDay;
  final bool showComboboxForMonthYear;
  final ValueChanged<int>? onYearChanged;
  final ValueChanged<int>? onMonthChanged;

  const CalendarEssentialsStatefulWidget({super.key,
    required this.events,
    this.calendarStyle,
    this.onDaySelected,
    this.heightCell,
    this.firstDay,
    this.lastDay,
    this.onChanged,
    this.defaultCalendarFormat,
    this.onFormatChanged,
    this.onPageChanged,
    required this.availableGestures,
    this.selectedDay,
    required this.showComboboxForMonthYear,
    this.onYearChanged,
    this.onMonthChanged,
  });

  @override
  CalendarEssentialsState createState() => CalendarEssentialsState();
}