import 'package:flutter/material.dart';

/// Abstract base class for calendar events.
///
/// Implement this class to create custom event types for the calendar.
/// Each event must provide methods to build its visual representation
/// and determine its selection state.
abstract class EventCalendarEssential {
  /// The date of this event
  final DateTime date;

  /// Creates an event for the specified date
  EventCalendarEssential(this.date);

  /// Builds the visual representation of the event for a given day cell.
  ///
  /// [isSelected] - Whether this event's date matches the currently selected day
  /// [isToday] - Whether this event's date is today
  Widget buildEvent(bool isSelected, bool isToday);

  /// Builds a marker widget displayed below the day number.
  ///
  /// Used to indicate the presence of an event (e.g., a dot or icon)
  Widget buildMarkerEvent();

  /// Determines if this event should be shown as selected.
  ///
  /// [selectedDay] - The currently selected day in the calendar
  /// Returns true if this event's date matches the selected day
  bool isEventSelected(DateTime selectedDay);
}
