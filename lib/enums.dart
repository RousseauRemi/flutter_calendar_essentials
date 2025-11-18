/// Defines the display format for the calendar.
enum CalendarFormat {
  /// Shows one week at a time
  week,

  /// Shows two weeks at a time
  twoWeeks,

  /// Shows a full month (4-6 weeks depending on the month)
  month
}

/// Defines which gesture directions are enabled for calendar navigation.
enum AvailableGestures {
  /// Only horizontal swipe gestures (left/right)
  horizontal,

  /// Only vertical swipe gestures (up/down)
  vertical,

  /// Both horizontal and vertical swipe gestures
  all
}

/// Represents days of the week.
///
/// Used to configure the first day of the week for the calendar display.
enum Weekday {
  /// Sunday
  sunday,

  /// Monday
  monday,

  /// Tuesday
  tuesday,

  /// Wednesday
  wednesday,

  /// Thursday
  thursday,

  /// Friday
  friday,

  /// Saturday
  saturday
}
