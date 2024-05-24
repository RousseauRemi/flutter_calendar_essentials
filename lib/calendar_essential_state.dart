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
    _selectedDay = widget.selectedDay ??
        _computeFirstDateOfCalendarFormat(_firstDayDisplayed, _calendarFormat);

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
      default:
        firstDateOfThePreviousPage = DateTime(_firstDayDisplayed.year,
            _firstDayDisplayed.month, _firstDayDisplayed.day - 7);
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

  String _getWeekdayName(Weekday weekday) {
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
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: previousPageEnabled ? _previousPage : null,
        ),
        Text(
          DateFormat.yMMMM().format(_firstDayDisplayed),
          // Display the month and year
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        DropdownButton<CalendarFormat>(
          value: _calendarFormat,
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
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: nextPageEnabled ? _nextPage : null,
        ),
      ],
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
      double dayHeight = widget.heightCell ?? 50.0; // Set the desired height for each day
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
                border: Border.all(color: Colors.grey, width: 0.5),
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.rectangle,
              ),
            );
        event ??= SimpleEventCalendarEssential(style, day, true);

        week.add(Padding(
            padding: const EdgeInsets.all(8.0),
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
        SizedBox(
          width: computeWidthCase(),
          height: 30,
          child: Text(
            _getWeekdayName(weekday),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
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
    switch (_calendarFormat) {
      case CalendarFormat.week:
        return Column(children: [
          Row(
            children: weekdays,
          ),
          Wrap(
            alignment: WrapAlignment.spaceAround,
            children: buildByWeeks(1),
          )
        ]);
      case CalendarFormat.twoWeeks:
        return Column(children: [
          Row(
            children: weekdays,
          ),
          Wrap(
            alignment: WrapAlignment.center,
            children: buildByWeeks(2),
          )
        ]);
      case CalendarFormat.month:
      default:
        return Column(children: [
          Row(
            children: weekdays,
          ),
          Wrap(
            alignment: WrapAlignment.center,
            children: buildByWeeks(4),
          )
        ]);
    }
  }

  double computeWidthCase() => (MediaQuery.of(context).size.width - 16.0) / 7;

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
