import 'package:flutter/material.dart';

class CalendarStyle {
  final BoxDecoration todayDecoration;
  final BoxDecoration selectedDecoration;

  // Text styles for different calendar elements
  final TextStyle? dayTextStyle;           // Normal day numbers
  final TextStyle? selectedDayTextStyle;   // Selected day number
  final TextStyle? todayTextStyle;         // Today's number
  final TextStyle? headerTextStyle;        // Month/Year header text
  final TextStyle? comboboxTextStyle;      // Month/Year dropdown text
  final TextStyle? formatTextStyle;        // Format dropdown text
  final TextStyle? weekdayTextStyle;       // Weekday headers (M, T, W, etc.)

  CalendarStyle({
    required this.todayDecoration,
    required this.selectedDecoration,
    this.dayTextStyle,
    this.selectedDayTextStyle,
    this.todayTextStyle,
    this.headerTextStyle,
    this.comboboxTextStyle,
    this.formatTextStyle,
    this.weekdayTextStyle,
  });
}