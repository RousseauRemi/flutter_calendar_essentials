import 'package:flutter/material.dart';

abstract class EventCalendarEssential {
  DateTime date;
  bool isSelected;

  EventCalendarEssential(this.date, this.isSelected);

  Widget buildEvent(bool isSelected, bool isToday);
  Widget buildMarkerEvent();
  bool isEventSelected(DateTime selectedDay);
}