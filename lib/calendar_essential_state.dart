import 'package:flutter/material.dart';
import 'package:flutter_calendar_essentials/calendar_essentials.dart';
import 'package:flutter_calendar_essentials/calendar_style.dart';
import 'package:intl/intl.dart';
import 'package:flutter_calendar_essentials/enums.dart';
import 'package:flutter_calendar_essentials/event_calendar.dart';
import 'package:flutter_calendar_essentials/simple_event_calendar_essential.dart';

class CalendarEssentialsState extends State<CalendarEssentialsStatefulWidget> {
  Weekday _firstDayOfWeek = Weekday.monday;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _firstDayDisplayed = DateTime.now();
  bool previousPageEnabled = false;
  bool nextPageEnabled = true;
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _firstDayOfWeek = widget.firstDayOfWeek;
    _calendarFormat = widget.defaultCalendarFormat ?? CalendarFormat.month;

    // Initialize _firstDayDisplayed based on the calendar format
    final initialDate = widget.selectedDay ?? DateTime.now();
    _firstDayDisplayed = _computeFirstDateOfCalendarFormat(initialDate, _calendarFormat);

    _selectedDay = widget.selectedDay ?? initialDate;

    computeEnabledPages(_firstDayDisplayed);
  }

  Future<void> computeEnabledPages(DateTime date) async {
    // in the case of a click on the next or previous page, the dat will be identical
    DateTime newDate = _computeFirstDateOfCalendarFormat(date, _calendarFormat);
    previousPageEnabled = widget.firstDay == null ||
        !(newDate.isBefore(widget.firstDay!) ||
            newDate.isAtSameMomentAs(widget.firstDay!));

    DateTime nextFuturDate =
        _computeLastDateOfCalendarFormat(newDate, _calendarFormat);
    nextPageEnabled = widget.lastDay == null ||
        !(nextFuturDate.isAfter(widget.lastDay!) ||
            nextFuturDate.isAtSameMomentAs(widget.lastDay!));
  }

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

    computeEnabledPages(firstDateOfThePreviousPage);

    setState(() {
      _firstDayDisplayed = firstDateOfThePreviousPage;
      _selectedDay = _computeSelectedDay(firstDateOfThePreviousPage);
    });

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

  DateTime _computeSelectedDay(DateTime date) {
    final firstDate = _computeFirstDateOfCalendarFormat(date, _calendarFormat);
    final lastDate = _computeLastDateOfCalendarFormat(date, _calendarFormat);
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if ((today.isBefore(lastDate) || today.isAtSameMomentAs(lastDate)) &&
        (today.isAfter(firstDate) || today.isAtSameMomentAs(firstDate))) {
      return today;
    } else {
      return firstDate;
    }
  }

  void _nextPage() {
    DateTime lastDateOfTheCurrentMonth =
        _computeLastDateOfCalendarFormat(_firstDayDisplayed, _calendarFormat);
    DateTime firstDateOfTheNextPage = DateTime(lastDateOfTheCurrentMonth.year,
        lastDateOfTheCurrentMonth.month, lastDateOfTheCurrentMonth.day + 1);
    computeEnabledPages(firstDateOfTheNextPage);

    setState(() {
      _firstDayDisplayed = firstDateOfTheNextPage;
      _selectedDay = _computeSelectedDay(firstDateOfTheNextPage);
    });
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

  String _getWeekdayName(Weekday weekday, {String format = 'auto'}) {
    // Determine format based on cell width if auto
    String actualFormat = format;
    if (format == 'auto') {
      final width = computeWidthCase();
      if (width < 40) {
        actualFormat = 'short';
      } else if (width < 70) {
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

  List<int> _getAvailableYears() {
    final startYear = widget.firstDay?.year ?? DateTime.now().year - 100;
    final endYear = widget.lastDay?.year ?? DateTime.now().year + 100;
    return List.generate(endYear - startYear + 1, (index) => startYear + index);
  }

  List<int> _getAvailableMonths(int year) {
    int startMonth = 1;
    int endMonth = 12;

    if (widget.firstDay != null && year == widget.firstDay!.year) {
      startMonth = widget.firstDay!.month;
    }

    if (widget.lastDay != null && year == widget.lastDay!.year) {
      endMonth = widget.lastDay!.month;
    }

    return List.generate(endMonth - startMonth + 1, (index) => startMonth + index);
  }

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

    computeEnabledPages(_firstDayDisplayed);

    if (widget.onYearChanged != null) {
      widget.onYearChanged!(year);
    }

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

  void _onMonthSelected(int? month) {
    if (month == null) return;

    setState(() {
      _firstDayDisplayed = DateTime(_firstDayDisplayed.year, month, 1);
      _selectedDay = _computeSelectedDay(_firstDayDisplayed);
    });

    computeEnabledPages(_firstDayDisplayed);

    if (widget.onMonthChanged != null) {
      widget.onMonthChanged!(month);
    }

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

  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }

  Widget _buildMonthCombobox() {
    final availableMonths = _getAvailableMonths(_firstDayDisplayed.year);
    final defaultStyle = const TextStyle(
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

  Widget _buildYearCombobox() {
    final availableYears = _getAvailableYears();
    final defaultStyle = const TextStyle(
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

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate if we need to wrap based on available width
        // Arrows take ~48px each, month/year ~200px, view mode ~100px
        // Total needed: ~396px. If less than 400px, wrap to two rows
        final shouldWrap = constraints.maxWidth < 400;

        final backButton = IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: previousPageEnabled ? _previousPage : null,
        );

        final forwardButton = IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: nextPageEnabled ? _nextPage : null,
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

  DateTime _computeFirstDateOfCalendarFormat(
      DateTime date, CalendarFormat format) {
    DateTime startDate = DateTime(date.year, date.month, date.day);

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

  DateTime _computeLastDateOfCalendarFormat(
      DateTime date, CalendarFormat format) {
    DateTime endDate = DateTime(date.year, date.month, date.day);
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

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return DateTime(today.year, today.month, today.day) ==
        DateTime(date.year, date.month, date.day);
  }

  Widget _buildCalendar() {
    List<Widget> buildWeek(DateTime date) {
      List<Widget> week = [];
      final double dayWidth = computeWidthCase();
      double dayHeight = widget.heightCell ?? 38.0; // Set the desired height for each day
      final firstDayOfWeekIndex = _firstDayOfWeek.index;
      for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
        final int adjustedDayIndex = dayIndex + firstDayOfWeekIndex;
        final DateTime day = DateTime(date.year, date.month,
            date.day + adjustedDayIndex - firstDayOfWeekIndex);

        EventCalendarEssential? event;
        for (var element in widget.events) {
          if (element.date.year == day.year &&
              element.date.month == day.month &&
              element.date.day == day.day) {
            event = element;
          }
        }
        final style = widget.calendarStyle ??
            CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            );
        event ??= SimpleEventCalendarEssential(style, day, true);

        week.add(Padding(
            padding: const EdgeInsets.all(3.0),
            child: SizedBox(
                width: dayWidth,
                height: dayHeight,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = day;
                      if (widget.onDaySelected != null) {
                        widget.onDaySelected!(day);
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
                              _isToday(event.date))),
                      event.buildMarkerEvent()
                    ],
                  ),
                ))));
      }

      return week;
    }

    int calculateNumberOfWeekToDisplayTheWholeMoth(DateTime date, int nbWeek) {
      var temporyDate = date;
      if (_calendarFormat == CalendarFormat.month) {
        int requiredWeeks = 0;
        while (temporyDate.isBefore(_computeLastDateOfCalendarFormat(
                _firstDayDisplayed, _calendarFormat)) ||
            temporyDate.isAtSameMomentAs(_computeLastDateOfCalendarFormat(
                _firstDayDisplayed, _calendarFormat))) {
          requiredWeeks++;
          temporyDate = DateTime(
              temporyDate.year, temporyDate.month, temporyDate.day + 7);
        }
        return requiredWeeks;
      }
      return nbWeek;
    }

    List<Widget> buildByWeeks(int nbWeek) {
      var date = _computeFirstDateOfCalendarFormat(
          _firstDayDisplayed, CalendarFormat.week);

      nbWeek = calculateNumberOfWeekToDisplayTheWholeMoth(date, nbWeek);

      final weeks = <Widget>[];
      for (int nb = 0; nb < nbWeek; nb++) {
        final week = buildWeek(date);
        for (int i = 0; i < week.length; i++) {
          weeks.add(SizedBox(
            width: computeWidthCase(), // Adjust the width of the items
            child: week[i],
          ));
        }
        date = DateTime(date.year, date.month, date.day + 7);
      }

      return weeks;
    }

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

    if (widget.onChanged != null) {
      widget.onChanged!(
          _firstDayDisplayed,
          _computeLastDateOfCalendarFormat(
              _firstDayDisplayed, _calendarFormat));
    }
    // Build header row with same width as calendar
    final weekdayHeader = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: weekdays,
    );

    switch (_calendarFormat) {
      case CalendarFormat.week:
        return Column(children: [
          weekdayHeader,
          Wrap(
            alignment: WrapAlignment.spaceAround,
            children: buildByWeeks(1),
          )
        ]);
      case CalendarFormat.twoWeeks:
        return Column(children: [
          weekdayHeader,
          Wrap(
            alignment: WrapAlignment.center,
            children: buildByWeeks(2),
          )
        ]);
      case CalendarFormat.month:
        return Column(children: [
          weekdayHeader,
          Wrap(
            alignment: WrapAlignment.center,
            children: buildByWeeks(6), // Max weeks any month can need; will be recalculated dynamically
          )
        ]);
    }
  }

  double computeWidthCase() {
    // Account for padding: each cell has 3px padding on all sides (6px horizontal)
    // Total horizontal padding for 7 cells = 7 * 6 = 42px
    // Available width = screen width - 16 (margins) - 42 (padding) = screen width - 58
    return (MediaQuery.of(context).size.width - 58.0) / 7;
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
