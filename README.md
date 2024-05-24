# EventCalendar Widget for Flutter
This README provides detailed instructions on how to use the EventCalendar widget, a customizable calendar widget for Flutter that allows the display of events and provides customization options for event selection, event markers, and calendar style.

_Tested on Web and Android_

## Features
- Display events on a calendar.
- Customize the appearance of selected dates and today's date.
- Add markers to indicate events.
- Handle day selection, format changes, and page changes with callbacks.
- Restrict the calendar's date range and control gestures.

![Alt text](/example1.png?raw=true "Example view")

## Installation
Add the following dependency to your pubspec.yaml file:
```
dependencies:
  flutter:
    sdk: flutter
  flutter_calendar_essentials: ^1.0.10
```
## Usage
Creating an Event Class
To use the EventCalendar, you need to create a class that extends EventCalendarEssential and overrides the required methods.

```
import 'package:flutter/material.dart';
import 'package:flutter_calendar_essentials/event_calendar.dart';
class MyCustomEventCalendar extends EventCalendarEssential {
  bool defaultEvent = true;
  var events = <CalendarEventEntity>[];
  ArrEventCalendar(DateTime date, this.defaultEvent, this.events) : super(date, false);
  
  @override
  bool isEventSelected(DateTime selectedDay) {
    return date.year == selectedDay.year &&
        date.month == selectedDay.month &&
        date.day == selectedDay.day;
  }
  
  @override
  Widget buildEvent(bool isSelected, bool isToday) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Colors.blue : isToday ? Colors.blueGrey : Colors.transparent,
        border: isSelected ? Border.all(color: Colors.grey, width: 0.5): Border.all(color: Colors.transparent),
      ),
      child: Center(
        child: Text(
          date.day.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Padding(padding: const EdgeInsets.fromLTRB(1, 0, 1, 0), child: Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    ));
  }

  @override
  Widget buildMarkerEvent() {
    List<Widget> dotWidgets = [];

    for (var event in events) {
      dotWidgets.add(_buildDot(event.api.color));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dotWidgets,
    );
  }
}


```
## Using the Calendar Widget
Create a list of MyEvent objects and pass them to the CalendarEssentials widget.

```
import 'package:flutter/material.dart';
import 'package:event_calendar/event_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late List<MyEvent> events;
  late DateTime selectedDay;
  late DateTime firstDayLimit;
  late DateTime lastDayLimit;
  late CalendarFormat calendarFormat;

  @override
  void initState() {
    super.initState();
    // Initialize your events, selected day, limits, and format
    selectedDay = DateTime.now();
    firstDayLimit = DateTime.now().subtract(Duration(days: 365));
    lastDayLimit = DateTime.now().add(Duration(days: 365));
    calendarFormat = CalendarFormat.twoWeeks;
    events = [
      MyEvent(
        date: DateTime.now(),
        events: [EventDetail(color: Colors.red)],
      ),
      // Add more events
    ];
  }

  void onDaySelected(DateTime day) {
    setState(() {
      selectedDay = day;
    });
  }

  void refreshEvents() {
    setState(() {
      // Update your events list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Calendar'),
      ),
      body: CalendarEssentials(
        events: events,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            shape: BoxShape.rectangle,
          ),
        ),
        onDaySelected: (selectedDay) {
          onDaySelected(selectedDay);
        },
        defaultCalendarFormat: CalendarFormat.twoWeeks,
        onFormatChanged: (format) {
          setState(() {
            calendarFormat = format;
          });
          refreshEvents();
        },
        onChanged: (firstDay, lastDay) {
          setState(() {
            firstDayLimit = firstDay;
            lastDayLimit = lastDay;
          });
        },
        heightCell: 30,
        selectedDay: selectedDay,
        firstDay: firstDayLimit,
        lastDay: lastDayLimit,
        availableGestures: AvailableGestures.horizontal,
        onPageChanged: (focusedDay) {
          onDaySelected(focusedDay);
          refreshEvents();
        },
      ),
    );
  }
}

```
## Parameters
- events: The list of events to be displayed.
- calendarStyle: The style of the calendar.
- onDaySelected: Callback when a day is selected.
- defaultCalendarFormat: The default format of the calendar (week, two weeks, or month).
- onFormatChanged: Callback when the format of the calendar is changed.
- onChanged: Callback when the calendar page is changed. Returns the first and last day displayed.
- heightCell: The height of the cell. The width is based on the container.
- selectedDay: The selected day.
- firstDay and lastDay: The date limits of the calendar.
- availableGestures: The gestures allowed (e.g., horizontal swipes).
- onPageChanged: Callback when the calendar page is changed.







