# EventCalendar Widget for Flutter
This README provides detailed instructions on how to use the EventCalendar widget, a customizable calendar widget for Flutter that allows the display of events and provides customization options for event selection, event markers, and calendar style.

_Tested on Web and Android_

## What's New 🎉

### Latest Updates (Unreleased)
- **🎨 Full Text Styling Customization**: Control the appearance of all text elements including day numbers, headers, dropdowns, and weekday labels with dedicated TextStyle properties.
- **📅 Month/Year Dropdown Selectors**: Quick navigation with optional dropdown menus for selecting month and year.
- **📱 Responsive Weekday Labels**: Weekday headers automatically adapt based on available screen width (short/medium/long format).
- **🎯 Enhanced Callbacks**: New `onYearChanged` and `onMonthChanged` callbacks for better control.

## Features
- Display events on a calendar.
- Customize the appearance of selected dates and today's date.
- **Full text styling customization** for all calendar elements (day numbers, headers, dropdowns).
- Add markers to indicate events.
- **Month/Year dropdown selectors** for quick navigation.
- Handle day selection, format changes, and page changes with callbacks.
- Restrict the calendar's date range and control gestures.
- Responsive weekday header labels that adapt to screen width.

![Alt text](/example1.png?raw=true "Example view")

## Quick Start

For basic calendar usage with default events:

```dart
import 'package:flutter_calendar_essentials/calendar_essentials.dart';
import 'package:flutter_calendar_essentials/simple_event_calendar_essential.dart';
import 'package:flutter_calendar_essentials/calendar_style.dart';

CalendarEssentials(
  events: [],  // Start with empty or add your custom EventCalendarEssential objects
  showComboboxForMonthYear: true,  // Enable month/year dropdowns
  calendarStyle: CalendarStyle(
    todayDecoration: BoxDecoration(
      color: Colors.blue,
      shape: BoxShape.circle,
    ),
    selectedDecoration: BoxDecoration(
      color: Colors.red,
      shape: BoxShape.circle,
    ),
    // Customize text colors (all optional)
    dayTextStyle: TextStyle(color: Colors.black),
    headerTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
  onDaySelected: (day) {
    print('Selected: $day');
  },
)
```

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

### Calendar Widget Parameters
- **events**: The list of events to be displayed.
- **calendarStyle**: The style of the calendar (see CalendarStyle section below).
- **onDaySelected**: Callback when a day is selected.
- **defaultCalendarFormat**: The default format of the calendar (week, two weeks, or month).
- **onFormatChanged**: Callback when the format of the calendar is changed.
- **onChanged**: Callback when the calendar page is changed. Returns the first and last day displayed.
- **heightCell**: The height of the cell. The width is based on the container.
- **selectedDay**: The selected day.
- **firstDay** and **lastDay**: The date limits of the calendar.
- **availableGestures**: The gestures allowed (e.g., horizontal swipes, vertical swipes, or all).
- **onPageChanged**: Callback when the calendar page is changed.
- **showComboboxForMonthYear**: Enable dropdown selectors for month and year (default: false).
- **onYearChanged**: Callback when year is changed via dropdown.
- **onMonthChanged**: Callback when month is changed via dropdown.

### CalendarStyle Properties

The `CalendarStyle` class allows you to customize the visual appearance of the calendar:

#### Decoration Properties
- **todayDecoration**: BoxDecoration for today's date cell.
- **selectedDecoration**: BoxDecoration for the selected date cell.

#### Text Style Properties (New!)
All text style properties are optional and have sensible defaults:

- **dayTextStyle**: TextStyle for normal day numbers.
- **selectedDayTextStyle**: TextStyle for the selected day number.
- **todayTextStyle**: TextStyle for today's day number.
- **headerTextStyle**: TextStyle for the month/year header text.
- **comboboxTextStyle**: TextStyle for month/year dropdown text.
- **formatTextStyle**: TextStyle for the format dropdown (Week/Month/Two Weeks).
- **weekdayTextStyle**: TextStyle for weekday headers (M, T, W, etc.).

#### Example with Full Styling

```dart
CalendarEssentials(
  events: myEvents,
  showComboboxForMonthYear: true,  // Enable month/year dropdowns
  calendarStyle: CalendarStyle(
    // Decorations
    todayDecoration: BoxDecoration(
      color: Colors.blue.shade700,
      shape: BoxShape.circle,
    ),
    selectedDecoration: BoxDecoration(
      color: Colors.red.shade600,
      shape: BoxShape.circle,
    ),

    // Day number styling
    dayTextStyle: TextStyle(
      color: Colors.black87,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    selectedDayTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    todayTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),

    // Header and controls styling
    headerTextStyle: TextStyle(
      color: Colors.blue.shade700,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    comboboxTextStyle: TextStyle(
      color: Colors.purple.shade700,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    formatTextStyle: TextStyle(
      color: Colors.green.shade700,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    weekdayTextStyle: TextStyle(
      color: Colors.grey.shade600,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  ),
  onYearChanged: (year) {
    print('Year changed to: $year');
  },
  onMonthChanged: (month) {
    print('Month changed to: $month');
  },
  // ... other parameters
)
```







