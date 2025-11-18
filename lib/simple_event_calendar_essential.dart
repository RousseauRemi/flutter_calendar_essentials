import 'package:flutter/material.dart';
import 'package:flutter_calendar_essentials/calendar_style.dart';
import 'package:flutter_calendar_essentials/event_calendar.dart';

/// A simple implementation of [EventCalendarEssential] with default styling behavior.
///
/// This class provides a basic calendar event that displays the day number
/// with appropriate styling for selected, today, and regular states.
class SimpleEventCalendarEssential extends EventCalendarEssential {
  /// Whether this is a default event (no marker) or a custom event (with marker)
  bool defaultEvent = true;

  final CalendarStyle _calendarStyle;

  /// Creates a simple event with the given calendar style.
  ///
  /// [_calendarStyle] - The style to use for rendering this event
  /// [date] - The date of this event
  /// [defaultEvent] - If true, no marker is shown; if false, a red dot marker is displayed
  SimpleEventCalendarEssential(
      this._calendarStyle, DateTime date, this.defaultEvent)
      : super(date);

  @override
  bool isEventSelected(DateTime selectedDay) {
    return date.year == selectedDay.year &&
        date.month == selectedDay.month &&
        date.day == selectedDay.day;
  }

  @override
  Widget buildEvent(bool isSelected, bool isToday) {
    BoxDecoration decoration;
    TextStyle textStyle;

    if (isSelected) {
      decoration = _calendarStyle.selectedDecoration;
      // Use custom style or default
      textStyle = _calendarStyle.selectedDayTextStyle ??
          TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: (_calendarStyle.selectedDecoration.color ==
                        Colors.transparent ||
                    _calendarStyle.selectedDecoration.color == null)
                ? Colors.black
                : Colors.white,
          );
    } else if (isToday) {
      decoration = _calendarStyle.todayDecoration;
      // Use custom style or default
      textStyle = _calendarStyle.todayTextStyle ??
          const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          );
    } else {
      decoration = const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      );
      // Use custom style or default
      textStyle = _calendarStyle.dayTextStyle ??
          const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: decoration,
          child: Center(
            child: Text(
              date.day.toString(),
              style: textStyle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildMarkerEvent() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: defaultEvent ? Colors.transparent : Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}
