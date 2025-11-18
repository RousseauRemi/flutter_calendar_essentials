import 'package:flutter/material.dart';

/// Defines the visual styling for the calendar widget.
///
/// All parameters are optional with sensible defaults. Customize only the
/// aspects you want to change from the default appearance.
///
/// Example:
/// ```dart
/// CalendarStyle(
///   todayDecoration: BoxDecoration(
///     color: Colors.green,
///     shape: BoxShape.circle,
///   ),
///   selectedDayTextStyle: TextStyle(
///     color: Colors.white,
///     fontWeight: FontWeight.bold,
///   ),
/// )
/// ```
class CalendarStyle {
  /// Decoration for today's date cell
  final BoxDecoration todayDecoration;

  /// Decoration for the selected date cell
  final BoxDecoration selectedDecoration;

  /// Text style for normal day numbers
  final TextStyle? dayTextStyle;

  /// Text style for the selected day number
  final TextStyle? selectedDayTextStyle;

  /// Text style for today's day number
  final TextStyle? todayTextStyle;

  /// Text style for the month/year header text
  final TextStyle? headerTextStyle;

  /// Text style for month/year dropdown text
  final TextStyle? comboboxTextStyle;

  /// Text style for format dropdown text
  final TextStyle? formatTextStyle;

  /// Text style for weekday headers (M, T, W, etc.)
  final TextStyle? weekdayTextStyle;

  /// Creates a calendar style with optional custom styling.
  ///
  /// If [todayDecoration] is not provided, defaults to a blue circle.
  /// If [selectedDecoration] is not provided, defaults to a red circle.
  /// Text styles default to appropriate values if not specified.
  CalendarStyle({
    BoxDecoration? todayDecoration,
    BoxDecoration? selectedDecoration,
    this.dayTextStyle,
    this.selectedDayTextStyle,
    this.todayTextStyle,
    this.headerTextStyle,
    this.comboboxTextStyle,
    this.formatTextStyle,
    this.weekdayTextStyle,
  })  : todayDecoration = todayDecoration ??
            const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
        selectedDecoration = selectedDecoration ??
            const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            );
}
