import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_calendar_essentials/calendar_essentials.dart';
import 'package:flutter_calendar_essentials/calendar_style.dart';
import 'package:flutter_calendar_essentials/enums.dart';
import 'package:flutter_calendar_essentials/event_calendar.dart';

class _LabelEvent extends EventCalendarEssential {
  final String label;
  _LabelEvent(super.date, this.label);

  @override
  Widget buildEvent(bool isSelected, bool isToday) => Text('E:$label');

  @override
  Widget buildMarkerEvent() => const SizedBox.shrink();

  @override
  bool isEventSelected(DateTime selectedDay) => false;
}

Widget _app(Widget calendar) => MaterialApp(home: Scaffold(body: calendar));

List<String> _texts(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data ?? '')
    .toList();

List<String> _dayNumbers(WidgetTester tester) =>
    _texts(tester).where((s) => RegExp(r'^\d{1,2}$').hasMatch(s)).toList();

List<String> _weekdayLabels(WidgetTester tester, String first) {
  final texts = _texts(tester);
  final start = texts.indexOf(first);
  expect(start, isNonNegative, reason: 'no "$first" label found');
  return texts.sublist(start, start + 7);
}

Future<void> _pumpAtWidth(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(CalendarEssentials(
    events: const [],
    selectedDay: DateTime(2024, 1, 15),
  )));
}

Finder _containerWith(BoxDecoration decoration) => find.byWidgetPredicate(
    (w) => w is Container && w.decoration == decoration);

void main() {
  group('Characterization: day grid', () {
    testWidgets('month view of Feb 2024 lists Jan 29 .. Mar 3',
        (tester) async {
      await tester.pumpWidget(_app(CalendarEssentials(
        events: const [],
        selectedDay: DateTime(2024, 2, 14),
      )));
      expect(_dayNumbers(tester), [
        '29', '30', '31',
        for (var d = 1; d <= 29; d++) '$d',
        '1', '2', '3',
      ]);
    });

    testWidgets('week view of 2024-02-14 lists Feb 12 .. 18', (tester) async {
      await tester.pumpWidget(_app(CalendarEssentials(
        events: const [],
        selectedDay: DateTime(2024, 2, 14),
        defaultCalendarFormat: CalendarFormat.week,
      )));
      expect(_dayNumbers(tester), ['12', '13', '14', '15', '16', '17', '18']);
    });

    testWidgets('two-weeks view of 2024-02-14 lists Feb 12 .. 25',
        (tester) async {
      await tester.pumpWidget(_app(CalendarEssentials(
        events: const [],
        selectedDay: DateTime(2024, 2, 14),
        defaultCalendarFormat: CalendarFormat.twoWeeks,
      )));
      expect(_dayNumbers(tester), [for (var d = 12; d <= 25; d++) '$d']);
    });
  });

  group('Characterization: default and custom cell style', () {
    const red = BoxDecoration(color: Colors.red, shape: BoxShape.circle);
    const blue = BoxDecoration(color: Colors.blue, shape: BoxShape.circle);

    testWidgets('selected day uses red circle and white bold 14 text',
        (tester) async {
      await tester.pumpWidget(_app(CalendarEssentials(
        events: const [],
        selectedDay: DateTime(2024, 1, 15),
      )));
      final cell = _containerWith(red);
      expect(cell, findsOneWidget);
      expect(find.descendant(of: cell, matching: find.text('15')),
          findsOneWidget);
      final text = tester.widget<Text>(
          find.descendant(of: cell, matching: find.byType(Text)));
      expect(
          text.style,
          const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white));
      expect(_containerWith(blue), findsNothing);
    });

    testWidgets('today uses blue circle when not selected', (tester) async {
      final now = DateTime.now();
      final other = DateTime(now.year, now.month, now.day == 1 ? 2 : 1);
      await tester.pumpWidget(_app(CalendarEssentials(
        events: const [],
        selectedDay: other,
      )));
      final cell = _containerWith(blue);
      expect(cell, findsOneWidget);
      expect(find.descendant(of: cell, matching: find.text('${now.day}')),
          findsOneWidget);
      final text = tester.widget<Text>(
          find.descendant(of: cell, matching: find.byType(Text)));
      expect(
          text.style,
          const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white));
    });

    testWidgets('custom calendarStyle decorations are used', (tester) async {
      const green = BoxDecoration(color: Colors.green, shape: BoxShape.circle);
      await tester.pumpWidget(_app(CalendarEssentials(
        events: const [],
        selectedDay: DateTime(2024, 1, 15),
        calendarStyle: CalendarStyle(selectedDecoration: green),
      )));
      expect(_containerWith(green), findsOneWidget);
      expect(_containerWith(red), findsNothing);
    });
  });

  group('Characterization: weekday labels by screen width', () {
    const long = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
      'Sunday'
    ];
    const medium = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const short = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    for (final c in <(double, List<String>)>[
      (337, short),
      (338, medium),
      (500, medium),
      (547, medium),
      (548, long),
      (800, long),
    ]) {
      testWidgets('width ${c.$1} -> ${c.$2.first}', (tester) async {
        await _pumpAtWidth(tester, c.$1);
        expect(_weekdayLabels(tester, c.$2.first), c.$2);
      });
    }
  });

  group('Characterization: event map', () {
    testWidgets('last event wins for the same date, time is ignored',
        (tester) async {
      await tester.pumpWidget(_app(CalendarEssentials(
        events: [
          _LabelEvent(DateTime(2024, 1, 10, 9), 'a'),
          _LabelEvent(DateTime(2024, 1, 10, 18), 'b'),
          _LabelEvent(DateTime(2024, 1, 20), 'c'),
        ],
        selectedDay: DateTime(2024, 1, 15),
      )));
      expect(find.text('E:a'), findsNothing);
      expect(find.text('E:b'), findsOneWidget);
      expect(find.text('E:c'), findsOneWidget);
    });

    testWidgets('a new events list rebuilds the lookup', (tester) async {
      await tester.pumpWidget(_app(CalendarEssentials(
        events: [_LabelEvent(DateTime(2024, 1, 10), 'old')],
        selectedDay: DateTime(2024, 1, 15),
      )));
      expect(find.text('E:old'), findsOneWidget);
      await tester.pumpWidget(_app(CalendarEssentials(
        events: [_LabelEvent(DateTime(2024, 1, 11), 'new')],
        selectedDay: DateTime(2024, 1, 15),
      )));
      expect(find.text('E:old'), findsNothing);
      expect(find.text('E:new'), findsOneWidget);
    });
  });

  group('Characterization: month/year dropdown style', () {
    testWidgets('default combobox style is 18 bold black', (tester) async {
      await tester.pumpWidget(_app(CalendarEssentials(
        events: const [],
        showComboboxForMonthYear: true,
        selectedDay: DateTime(2024, 1, 15),
      )));
      final dropdowns =
          tester.widgetList<DropdownButton<int>>(find.byType(DropdownButton<int>));
      expect(dropdowns.length, 2);
      for (final d in dropdowns) {
        expect(
            d.style,
            const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black));
      }
      expect(dropdowns.first.value, 1);
      expect(dropdowns.last.value, 2024);
    });

    testWidgets('custom comboboxTextStyle is used by both', (tester) async {
      const custom = TextStyle(fontSize: 11, color: Colors.purple);
      await tester.pumpWidget(_app(CalendarEssentials(
        events: const [],
        showComboboxForMonthYear: true,
        selectedDay: DateTime(2024, 1, 15),
        calendarStyle: CalendarStyle(comboboxTextStyle: custom),
      )));
      for (final d in tester
          .widgetList<DropdownButton<int>>(find.byType(DropdownButton<int>))) {
        expect(d.style, custom);
      }
    });
  });
}
