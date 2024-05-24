import 'package:flutter/material.dart';
import 'package:flutter_calendar_essentials/calendar_style.dart';
import 'package:flutter_calendar_essentials/event_calendar.dart';

class SimpleEventCalendarEssential extends EventCalendarEssential {
  bool defaultEvent = true;

  final CalendarStyle _calendarStyle;
  @override
  bool isEventSelected(DateTime selectedDay) {
    return date.year == selectedDay.year &&
        date.month == selectedDay.month &&
        date.day == selectedDay.day;
  }
  SimpleEventCalendarEssential(this._calendarStyle, DateTime date, this.defaultEvent) : super(date, false);

  @override
  Widget buildEvent(bool isSelected, bool isToday ) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? _calendarStyle.selectedDecoration.color : isToday ? _calendarStyle.todayDecoration.color : Colors.transparent,
        border: isSelected ? _calendarStyle.selectedDecoration.border: Border.all(color: Colors.transparent),

      ),
      child: Center(
        child: Text(
          date.day.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
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
