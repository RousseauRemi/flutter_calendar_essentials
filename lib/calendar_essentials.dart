library flutter_calendar_essentials;

import 'package:flutter/material.dart';
import 'package:flutter_calendar_essentials/calendar_style.dart';
import 'package:flutter_calendar_essentials/enums.dart';
import 'package:flutter_calendar_essentials/event_calendar.dart';
import 'package:flutter_calendar_essentials/simple_event_calendar_essential.dart';
import 'package:intl/intl.dart';

typedef CustomValueChanged<T, U> = void Function(T value1, U value2);

/// A customizable calendar widget for Flutter applications.
///
/// [CalendarEssentials] provides a flexible calendar view with support for:
/// - Multiple calendar formats (month, week, two weeks)
/// - Event display and selection
/// - Gesture navigation
/// - Date range constraints
/// - Custom styling
/// - Month/Year dropdowns for quick navigation
///
/// Example usage:
/// ```dart
/// CalendarEssentials(
///   events: myEventsList,
///   selectedDay: DateTime.now(),
///   onDaySelected: (day) => print('Selected: $day'),
///   firstDay: DateTime(2020, 1, 1),
///   lastDay: DateTime(2030, 12, 31),
/// )
/// ```
class CalendarEssentials extends StatefulWidget {
  /// The first day of the week (defaults to Monday)
  final Weekday firstDayOfWeek = Weekday.monday;

  /// List of events to display on the calendar
  final List<EventCalendarEssential> events;

  /// Custom styling for the calendar
  final CalendarStyle? calendarStyle;

  /// Height of each day cell
  final double? heightCell;

  /// Callback when a day is selected
  final ValueChanged<DateTime>? onDaySelected;

  /// Callback when the calendar range changes (provides first and last visible dates)
  final CustomValueChanged<DateTime, DateTime>? onChanged;

  /// The earliest date the calendar can show
  final DateTime? firstDay;

  /// The latest date the calendar can show
  final DateTime? lastDay;

  /// Default calendar format (month, week, or two weeks)
  final CalendarFormat? defaultCalendarFormat;

  /// Callback when calendar format changes
  final ValueChanged<CalendarFormat>? onFormatChanged;

  /// Callback when page (month/week) changes
  final ValueChanged<DateTime>? onPageChanged;

  /// Available gesture directions for navigation
  final AvailableGestures availableGestures;

  /// Currently selected day
  final DateTime? selectedDay;

  /// Whether to show dropdowns for month/year selection
  final bool showComboboxForMonthYear;

  /// Callback when year is changed via dropdown
  final ValueChanged<int>? onYearChanged;

  /// Callback when month is changed via dropdown
  final ValueChanged<int>? onMonthChanged;

  const CalendarEssentials({
    super.key,
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
    this.availableGestures = AvailableGestures.all,
    this.selectedDay,
    this.showComboboxForMonthYear = false,
    this.onYearChanged,
    this.onMonthChanged,
  });

  @override
  State<CalendarEssentials> createState() => _CalendarEssentialsState();
}

class _CalendarEssentialsState extends State<CalendarEssentials> {
  // Magic numbers as named constants
  static const double _defaultCellHeight = 38.0;
  static const double _cellHorizontalPadding = 6.0;
  static const double _totalHorizontalMargin = 16.0;
  static const double _headerWrapThreshold = 400.0;
  static const double _shortNameWidthThreshold = 40.0;
  static const double _mediumNameWidthThreshold = 70.0;

  Weekday _firstDayOfWeek = Weekday.monday;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _firstDayDisplayed = DateTime.now();
  bool _previousPageEnabled = false;
  bool _nextPageEnabled = true;
  DateTime _selectedDay = DateTime.now();

  // Cache for event lookup optimization
  Map<DateTime, EventCalendarEssential>? _eventMap;

  @override
  void initState() {
    super.initState();
    _firstDayOfWeek = widget.firstDayOfWeek;
    _calendarFormat = widget.defaultCalendarFormat ?? CalendarFormat.month;

    // Initialize _firstDayDisplayed based on the calendar format
    final initialDate = widget.selectedDay ?? DateTime.now();
    _firstDayDisplayed =
        _computeFirstDateOfCalendarFormat(initialDate, _calendarFormat);

    // Validate selectedDay against date range
    _selectedDay = _validateSelectedDay(widget.selectedDay ?? initialDate);

    _computeEnabledPages(_firstDayDisplayed);
    _buildEventMap();
  }

  @override
  void didUpdateWidget(CalendarEssentials oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.events != widget.events) {
      _buildEventMap();
    }
  }

  /// Builds a map for O(1) event lookup by date
  void _buildEventMap() {
    _eventMap = {};
    for (var event in widget.events) {
      final normalizedDate = _normalizeDate(event.date);
      _eventMap![normalizedDate] = event;
    }
  }

  /// Normalizes a DateTime to midnight (strips time component)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Validates that selectedDay is within the allowed date range
  DateTime _validateSelectedDay(DateTime day) {
    final normalizedDay = _normalizeDate(day);

    if (widget.firstDay != null && normalizedDay.isBefore(widget.firstDay!)) {
      return _normalizeDate(widget.firstDay!);
    }

    if (widget.lastDay != null && normalizedDay.isAfter(widget.lastDay!)) {
      return _normalizeDate(widget.lastDay!);
    }

    return normalizedDay;
  }

  /// Computes whether previous/next page navigation is enabled
  void _computeEnabledPages(DateTime date) {
    // Note: In the case of a click on the next or previous page, the date will be identical
    DateTime newDate = _computeFirstDateOfCalendarFormat(date, _calendarFormat);
    _previousPageEnabled = widget.firstDay == null ||
        !(newDate.isBefore(widget.firstDay!) ||
            newDate.isAtSameMomentAs(widget.firstDay!));

    DateTime nextFutureDate =
        _computeLastDateOfCalendarFormat(newDate, _calendarFormat);
    _nextPageEnabled = widget.lastDay == null ||
        !(nextFutureDate.isAfter(widget.lastDay!) ||
            nextFutureDate.isAtSameMomentAs(widget.lastDay!));
  }

  /// Handles gesture-based navigation
  void _handleGesture(DragUpdateDetails details) {
    if (widget.availableGestures == AvailableGestures.all ||
        widget.availableGestures == AvailableGestures.horizontal) {
      if (details.delta.dx > 5) {
        _previousPage();
      } else if (details.delta.dx < -5) {
        _nextPage();
      }
    }

    if (widget.availableGestures == AvailableGestures.all ||
        widget.availableGestures == AvailableGestures.vertical) {
      if (details.delta.dy > 5) {
        _previousPage();
      } else if (details.delta.dy < -5) {
        _nextPage();
      }
    }
  }

  /// Navigates to the previous page
  void _previousPage() {
    DateTime firstDateOfThePreviousPage;
    switch (_calendarFormat) {
      case CalendarFormat.week:
        firstDateOfThePreviousPage = DateTime(_firstDayDisplayed.year,
            _firstDayDisplayed.month, _firstDayDisplayed.day - 7);
        break;
      case CalendarFormat.twoWeeks:
        firstDateOfThePreviousPage = DateTime(_firstDayDisplayed.year,
            _firstDayDisplayed.month, _firstDayDisplayed.day - 14);
        break;
      case CalendarFormat.month:
        firstDateOfThePreviousPage = DateTime(_firstDayDisplayed.year,
            _firstDayDisplayed.month - 1, _firstDayDisplayed.day);
        break;
    }

    _computeEnabledPages(firstDateOfThePreviousPage);

    setState(() {
      _firstDayDisplayed = firstDateOfThePreviousPage;
      _selectedDay = _computeSelectedDay(firstDateOfThePreviousPage);
    });

    _notifyPageChange();
  }

  /// Navigates to the next page
  void _nextPage() {
    DateTime lastDateOfTheCurrentMonth =
        _computeLastDateOfCalendarFormat(_firstDayDisplayed, _calendarFormat);
    DateTime firstDateOfTheNextPage = DateTime(lastDateOfTheCurrentMonth.year,
        lastDateOfTheCurrentMonth.month, lastDateOfTheCurrentMonth.day + 1);
    _computeEnabledPages(firstDateOfTheNextPage);

    setState(() {
      _firstDayDisplayed = firstDateOfTheNextPage;
      _selectedDay = _computeSelectedDay(firstDateOfTheNextPage);
    });

    _notifyPageChange();
  }

  /// Notifies listeners about page changes
  void _notifyPageChange() {
    if (widget.onChanged != null) {
      widget.onChanged!(
          _firstDayDisplayed,
          _computeLastDateOfCalendarFormat(
              _firstDayDisplayed, _calendarFormat));
    }
    if (widget.onPageChanged != null) {
      widget.onPageChanged!(_firstDayDisplayed);
    }
  }

  /// Computes the selected day within the current view
  DateTime _computeSelectedDay(DateTime date) {
    final firstDate = _computeFirstDateOfCalendarFormat(date, _calendarFormat);
    final lastDate = _computeLastDateOfCalendarFormat(date, _calendarFormat);
    final today = _normalizeDate(DateTime.now());

    if ((today.isBefore(lastDate) || today.isAtSameMomentAs(lastDate)) &&
        (today.isAfter(firstDate) || today.isAtSameMomentAs(firstDate))) {
      return today;
    } else {
      return firstDate;
    }
  }

  /// Returns the display name for a calendar format
  String _getFormatName(CalendarFormat format) {
    switch (format) {
      case CalendarFormat.month:
        return 'Month';
      case CalendarFormat.week:
        return 'Week';
      case CalendarFormat.twoWeeks:
        return 'Two weeks';
    }
  }

  /// Returns the display name for a weekday with responsive formatting
  String _getWeekdayName(Weekday weekday, {String format = 'auto'}) {
    // Determine format based on cell width if auto
    String actualFormat = format;
    if (format == 'auto') {
      final width = _computeWidthCase();
      if (width < _shortNameWidthThreshold) {
        actualFormat = 'short';
      } else if (width < _mediumNameWidthThreshold) {
        actualFormat = 'medium';
      } else {
        actualFormat = 'long';
      }
    }

    switch (actualFormat) {
      case 'short':
        switch (weekday) {
          case Weekday.monday:
            return 'M';
          case Weekday.tuesday:
            return 'T';
          case Weekday.wednesday:
            return 'W';
          case Weekday.thursday:
            return 'T';
          case Weekday.friday:
            return 'F';
          case Weekday.saturday:
            return 'S';
          case Weekday.sunday:
            return 'S';
        }
      case 'medium':
        switch (weekday) {
          case Weekday.monday:
            return 'Mon';
          case Weekday.tuesday:
            return 'Tue';
          case Weekday.wednesday:
            return 'Wed';
          case Weekday.thursday:
            return 'Thu';
          case Weekday.friday:
            return 'Fri';
          case Weekday.saturday:
            return 'Sat';
          case Weekday.sunday:
            return 'Sun';
        }
      case 'long':
      default:
        switch (weekday) {
          case Weekday.monday:
            return 'Monday';
          case Weekday.tuesday:
            return 'Tuesday';
          case Weekday.wednesday:
            return 'Wednesday';
          case Weekday.thursday:
            return 'Thursday';
          case Weekday.friday:
            return 'Friday';
          case Weekday.saturday:
            return 'Saturday';
          case Weekday.sunday:
            return 'Sunday';
        }
    }
  }

  /// Returns list of available years based on date constraints
  List<int> _getAvailableYears() {
    final startYear = widget.firstDay?.year ?? DateTime.now().year - 100;
    final endYear = widget.lastDay?.year ?? DateTime.now().year + 100;
    return List.generate(endYear - startYear + 1, (index) => startYear + index);
  }

  /// Returns list of available months for a given year
  List<int> _getAvailableMonths(int year) {
    int startMonth = 1;
    int endMonth = 12;

    if (widget.firstDay != null && year == widget.firstDay!.year) {
      startMonth = widget.firstDay!.month;
    }

    if (widget.lastDay != null && year == widget.lastDay!.year) {
      endMonth = widget.lastDay!.month;
    }

    return List.generate(
        endMonth - startMonth + 1, (index) => startMonth + index);
  }

  /// Handles year selection from dropdown
  void _onYearSelected(int? year) {
    if (year == null) return;

    final availableMonths = _getAvailableMonths(year);
    int newMonth = _firstDayDisplayed.month;

    // Adjust month if current month is not available in the new year
    if (!availableMonths.contains(newMonth)) {
      newMonth = availableMonths.first;
    }

    setState(() {
      _firstDayDisplayed = DateTime(year, newMonth, 1);
      _selectedDay = _computeSelectedDay(_firstDayDisplayed);
    });

    _computeEnabledPages(_firstDayDisplayed);

    if (widget.onYearChanged != null) {
      widget.onYearChanged!(year);
    }

    _notifyPageChange();
  }

  /// Handles month selection from dropdown
  void _onMonthSelected(int? month) {
    if (month == null) return;

    setState(() {
      _firstDayDisplayed = DateTime(_firstDayDisplayed.year, month, 1);
      _selectedDay = _computeSelectedDay(_firstDayDisplayed);
    });

    _computeEnabledPages(_firstDayDisplayed);

    if (widget.onMonthChanged != null) {
      widget.onMonthChanged!(month);
    }

    _notifyPageChange();
  }

  /// Returns the localized month name
  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }

  /// Builds the month selection dropdown
  Widget _buildMonthCombobox() {
    final availableMonths = _getAvailableMonths(_firstDayDisplayed.year);
    const defaultStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return DropdownButton<int>(
      value: _firstDayDisplayed.month,
      underline: Container(),
      style: widget.calendarStyle?.comboboxTextStyle ?? defaultStyle,
      onChanged: _onMonthSelected,
      items: availableMonths.map<DropdownMenuItem<int>>((int month) {
        return DropdownMenuItem<int>(
          value: month,
          child: Text(_getMonthName(month)),
        );
      }).toList(),
    );
  }

  /// Builds the year selection dropdown
  Widget _buildYearCombobox() {
    final availableYears = _getAvailableYears();
    const defaultStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return DropdownButton<int>(
      value: _firstDayDisplayed.year,
      underline: Container(),
      style: widget.calendarStyle?.comboboxTextStyle ?? defaultStyle,
      onChanged: _onYearSelected,
      items: availableYears.map<DropdownMenuItem<int>>((int year) {
        return DropdownMenuItem<int>(
          value: year,
          child: Text(year.toString()),
        );
      }).toList(),
    );
  }

  /// Builds the calendar header with navigation controls
  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate if we need to wrap based on available width
        // Arrows take ~48px each, month/year ~200px, view mode ~100px
        // Total needed: ~396px. If less than threshold, wrap to two rows
        final shouldWrap = constraints.maxWidth < _headerWrapThreshold;

        final backButton = IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousPageEnabled ? _previousPage : null,
        );

        final forwardButton = IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: _nextPageEnabled ? _nextPage : null,
        );

        final monthYearWidget = widget.showComboboxForMonthYear
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMonthCombobox(),
                  const SizedBox(width: 8),
                  _buildYearCombobox(),
                ],
              )
            : Text(
                DateFormat.yMMMM().format(_firstDayDisplayed),
                style: widget.calendarStyle?.headerTextStyle ??
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              );

        final viewModeSelector = DropdownButton<CalendarFormat>(
          value: _calendarFormat,
          style: widget.calendarStyle?.formatTextStyle,
          onChanged: (newFormat) {
            if (newFormat == null) return;
            setState(() {
              if (newFormat == CalendarFormat.month) {
                _firstDayDisplayed =
                    DateTime(_selectedDay.year, _selectedDay.month, 1);
              }
              _calendarFormat = newFormat;
              if (widget.onChanged != null) {
                widget.onChanged!(
                    _firstDayDisplayed,
                    _computeLastDateOfCalendarFormat(
                        _firstDayDisplayed, _calendarFormat));
              }
              if (widget.onFormatChanged != null) {
                widget.onFormatChanged!(newFormat);
              }
            });
          },
          items: CalendarFormat.values
              .map<DropdownMenuItem<CalendarFormat>>((CalendarFormat value) {
            return DropdownMenuItem<CalendarFormat>(
              value: value,
              child: Text(_getFormatName(value)),
            );
          }).toList(),
        );

        if (shouldWrap) {
          // Two-row layout: Row 1 has arrows and month/year, Row 2 has view mode
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backButton,
                  monthYearWidget,
                  forwardButton,
                ],
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: viewModeSelector,
                ),
              ),
            ],
          );
        } else {
          // Single-row layout: all controls in one row
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              backButton,
              monthYearWidget,
              viewModeSelector,
              forwardButton,
            ],
          );
        }
      },
    );
  }

  /// Computes the first date to display for a given format
  DateTime _computeFirstDateOfCalendarFormat(
      DateTime date, CalendarFormat format) {
    DateTime startDate = _normalizeDate(date);

    switch (format) {
      case CalendarFormat.week:
      case CalendarFormat.twoWeeks:
        startDate = startDate.subtract(
            Duration(days: startDate.weekday - _firstDayOfWeek.index));
        break;
      case CalendarFormat.month:
        startDate = DateTime(startDate.year, startDate.month, 1);
        break;
    }

    return startDate;
  }

  /// Computes the last date to display for a given format
  DateTime _computeLastDateOfCalendarFormat(
      DateTime date, CalendarFormat format) {
    DateTime endDate = _normalizeDate(date);
    switch (format) {
      case CalendarFormat.week:
      case CalendarFormat.twoWeeks:
        int daysToAdd = (format == CalendarFormat.week) ? 6 : 13;
        endDate = endDate.add(Duration(
            days: daysToAdd - 1 - (_firstDayOfWeek.index - endDate.weekday)));
        break;
      case CalendarFormat.month:
        endDate = DateTime(endDate.year, endDate.month + 1, 0);
        break;
    }

    return endDate;
  }

  /// Checks if a date is today
  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return _normalizeDate(today) == _normalizeDate(date);
  }

  /// Finds an event for a specific day using optimized Map lookup
  EventCalendarEssential? _findEventForDay(DateTime day) {
    return _eventMap?[_normalizeDate(day)];
  }

  /// Builds a single day cell
  Widget _buildDayCell(DateTime day, double dayWidth, double dayHeight) {
    EventCalendarEssential? event = _findEventForDay(day);

    final style = widget.calendarStyle ??
        CalendarStyle(
          todayDecoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        );
    event ??= SimpleEventCalendarEssential(style, day, true);

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: SizedBox(
        width: dayWidth,
        height: dayHeight,
        child: GestureDetector(
          onTap: () {
            final validatedDay = _validateSelectedDay(day);
            setState(() {
              _selectedDay = validatedDay;
              if (widget.onDaySelected != null) {
                widget.onDaySelected!(validatedDay);
              }
            });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: event.buildEvent(
                  event.isEventSelected(_selectedDay),
                  _isToday(event.date),
                ),
              ),
              event.buildMarkerEvent()
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a week of day cells
  List<Widget> _buildWeek(DateTime date, double dayWidth, double dayHeight) {
    List<Widget> week = [];
    final firstDayOfWeekIndex = _firstDayOfWeek.index;

    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      final int adjustedDayIndex = dayIndex + firstDayOfWeekIndex;
      final DateTime day = DateTime(date.year, date.month,
          date.day + adjustedDayIndex - firstDayOfWeekIndex);

      week.add(_buildDayCell(day, dayWidth, dayHeight));
    }

    return week;
  }

  /// Calculates the number of weeks needed to display the whole month
  int _calculateNumberOfWeeksToDisplayTheWholeMonth(
      DateTime date, int defaultWeeks) {
    if (_calendarFormat != CalendarFormat.month) {
      return defaultWeeks;
    }

    var temporaryDate = date;
    int requiredWeeks = 0;
    final lastDate =
        _computeLastDateOfCalendarFormat(_firstDayDisplayed, _calendarFormat);

    while (temporaryDate.isBefore(lastDate) ||
        temporaryDate.isAtSameMomentAs(lastDate)) {
      requiredWeeks++;
      temporaryDate = DateTime(
          temporaryDate.year, temporaryDate.month, temporaryDate.day + 7);
    }

    return requiredWeeks;
  }

  /// Builds multiple weeks for the calendar
  List<Widget> _buildWeeks(int numberOfWeeks) {
    var date = _computeFirstDateOfCalendarFormat(
        _firstDayDisplayed, CalendarFormat.week);

    numberOfWeeks =
        _calculateNumberOfWeeksToDisplayTheWholeMonth(date, numberOfWeeks);

    final weeks = <Widget>[];
    final dayWidth = _computeWidthCase();
    final dayHeight = widget.heightCell ?? _defaultCellHeight;

    for (int weekIndex = 0; weekIndex < numberOfWeeks; weekIndex++) {
      final week = _buildWeek(date, dayWidth, dayHeight);
      for (int i = 0; i < week.length; i++) {
        weeks.add(SizedBox(
          width: dayWidth,
          child: week[i],
        ));
      }
      date = DateTime(date.year, date.month, date.day + 7);
    }

    return weeks;
  }

  /// Builds the weekday header row
  Widget _buildWeekdayHeader() {
    final weekdays = <Widget>[];
    final firstDayOfWeekIndex = _firstDayOfWeek.index;

    for (int i = firstDayOfWeekIndex; i < firstDayOfWeekIndex + 7; i++) {
      final weekdayIndex = i % Weekday.values.length;
      final weekday = Weekday.values[weekdayIndex];
      weekdays.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Center(
              child: Text(
                _getWeekdayName(weekday),
                textAlign: TextAlign.center,
                style: widget.calendarStyle?.weekdayTextStyle ??
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: weekdays,
    );
  }

  /// Builds the calendar grid
  Widget _buildCalendar() {
    final weekdayHeader = _buildWeekdayHeader();

    switch (_calendarFormat) {
      case CalendarFormat.week:
        return Column(
          children: [
            weekdayHeader,
            Wrap(
              alignment: WrapAlignment.spaceAround,
              children: _buildWeeks(1),
            )
          ],
        );
      case CalendarFormat.twoWeeks:
        return Column(
          children: [
            weekdayHeader,
            Wrap(
              alignment: WrapAlignment.center,
              children: _buildWeeks(2),
            )
          ],
        );
      case CalendarFormat.month:
        return Column(
          children: [
            weekdayHeader,
            Wrap(
              alignment: WrapAlignment.center,
              // Max weeks any month can need; will be recalculated dynamically
              children: _buildWeeks(6),
            )
          ],
        );
    }
  }

  /// Computes the width of each day cell
  double _computeWidthCase() {
    // Account for padding: each cell has 3px padding on all sides (6px horizontal)
    // Total horizontal padding for 7 cells = 7 * 6 = 42px
    // Total margin = 16px
    // Available width = screen width - 16 (margins) - 42 (padding)
    return (MediaQuery.of(context).size.width -
            _totalHorizontalMargin -
            (7 * _cellHorizontalPadding)) /
        7;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        GestureDetector(
          onHorizontalDragUpdate: _handleGesture,
          onVerticalDragUpdate: _handleGesture,
          child: _buildCalendar(),
        ),
      ],
    );
  }
}
