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

final _built = <String>[];

class _RecordingEvent extends EventCalendarEssential {
  _RecordingEvent(super.date);

  @override
  Widget buildEvent(bool isSelected, bool isToday) {
    _built.add('${date.month}/${date.day}');
    return Text('R${date.day}');
  }

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

Finder _containerWith(BoxDecoration decoration) =>
    find.byWidgetPredicate((w) => w is Container && w.decoration == decoration);

String _d(DateTime d) => '${d.year}-${d.month}-${d.day} ${d.hour}:${d.minute}';

Widget _navCalendar(
  List<String> log, {
  required DateTime selectedDay,
  CalendarFormat? format,
  DateTime? firstDay,
  DateTime? lastDay,
  bool showComboboxForMonthYear = false,
}) =>
    _app(CalendarEssentials(
      events: const [],
      selectedDay: selectedDay,
      defaultCalendarFormat: format,
      firstDay: firstDay,
      lastDay: lastDay,
      showComboboxForMonthYear: showComboboxForMonthYear,
      onChanged: (a, b) => log.add('changed ${_d(a)} .. ${_d(b)}'),
      onPageChanged: (a) => log.add('page ${_d(a)}'),
      onYearChanged: (y) => log.add('year $y'),
      onMonthChanged: (m) => log.add('month $m'),
      onFormatChanged: (f) => log.add('format $f'),
    ));

bool _arrowEnabled(WidgetTester tester, IconData icon) =>
    tester
        .widget<IconButton>(find.ancestor(
            of: find.byIcon(icon), matching: find.byType(IconButton)))
        .onPressed !=
    null;

/// Arrow state and displayed grid: "prev/next first..last(count)".
String _page(WidgetTester tester) {
  final days = _dayNumbers(tester);
  return '${_arrowEnabled(tester, Icons.arrow_back)}/'
      '${_arrowEnabled(tester, Icons.arrow_forward)} '
      '${days.first}..${days.last}(${days.length})';
}

Future<void> _setNavView(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Taps [icon], returns the callbacks fired followed by the resulting page.
Future<List<String>> _tapArrow(
    WidgetTester tester, List<String> log, IconData icon) async {
  log.clear();
  await tester.tap(find.byIcon(icon));
  await tester.pumpAndSettle();
  return [...log, _page(tester)];
}

Future<List<String>> _pickDropdown(
    WidgetTester tester, List<String> log, int index, String text) async {
  log.clear();
  await tester.tap(find.byType(DropdownButton<int>).at(index));
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).last, warnIfMissed: false);
  await tester.pumpAndSettle();
  return [...log, _page(tester)];
}

Future<List<String>> _pickFormat(
    WidgetTester tester, List<String> log, String text) async {
  log.clear();
  await tester.tap(find.byType(DropdownButton<CalendarFormat>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).last, warnIfMissed: false);
  await tester.pumpAndSettle();
  return [...log, _page(tester)];
}

void main() {
  group('Characterization: day grid', () {
    testWidgets('month view of Feb 2024 lists Jan 29 .. Mar 3', (tester) async {
      await tester.pumpWidget(_app(CalendarEssentials(
        events: const [],
        selectedDay: DateTime(2024, 2, 14),
      )));
      expect(_dayNumbers(tester), [
        '29',
        '30',
        '31',
        for (var d = 1; d <= 29; d++) '$d',
        '1',
        '2',
        '3',
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
      expect(
          find.descendant(of: cell, matching: find.text('15')), findsOneWidget);
      final text = tester
          .widget<Text>(find.descendant(of: cell, matching: find.byType(Text)));
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
      final text = tester
          .widget<Text>(find.descendant(of: cell, matching: find.byType(Text)));
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
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
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
      final dropdowns = tester
          .widgetList<DropdownButton<int>>(find.byType(DropdownButton<int>));
      expect(dropdowns.length, 2);
      for (final d in dropdowns) {
        expect(
            d.style,
            const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black));
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

  group('Characterization: grid structure', () {
    for (final c in [
      (
        CalendarFormat.week,
        WrapAlignment.spaceAround,
        DateTime(2024, 2, 12),
        7
      ),
      (
        CalendarFormat.twoWeeks,
        WrapAlignment.center,
        DateTime(2024, 2, 12),
        14
      ),
      (CalendarFormat.month, WrapAlignment.center, DateTime(2024, 1, 29), 35),
    ]) {
      testWidgets('${c.$1.name}: Wrap, cells and build order', (tester) async {
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        _built.clear();
        await tester.pumpWidget(_app(CalendarEssentials(
          events: [
            for (var d = 0; d < 42; d++)
              _RecordingEvent(DateTime(2024, 1, 29 + d))
          ],
          selectedDay: DateTime(2024, 2, 14),
          defaultCalendarFormat: c.$1,
        )));

        expect(find.byType(Wrap), findsOneWidget);
        final wrap = tester.widget<Wrap>(find.byType(Wrap));
        expect(wrap.alignment, c.$2);
        expect(wrap.children, hasLength(c.$4));
        for (final child in wrap.children) {
          final outer = child as SizedBox;
          expect(outer.width, 106.0);
          expect(outer.height, isNull);
          final pad = outer.child as Padding;
          expect(pad.padding, const EdgeInsets.all(3.0));
          final inner = pad.child as SizedBox;
          expect(inner.width, 106.0);
          expect(inner.height, 38.0);
        }

        expect(tester.getSize(find.byType(Wrap)), Size(742.0, 44.0 * c.$4 / 7));
        final first = find.byWidget(wrap.children.first);
        expect(tester.getSize(first), const Size(106.0, 44.0));
        expect(tester.getTopLeft(first), const Offset(29.0, 88.0));
        final innerFirst = ((wrap.children.first as SizedBox).child as Padding)
            .child as SizedBox;
        expect(
            tester.getSize(find.byWidget(innerFirst)), const Size(100.0, 38.0));
        final last = find.byWidget(wrap.children.last);
        expect(tester.getTopLeft(last),
            Offset(665.0, 88.0 + 44.0 * (c.$4 / 7 - 1)));

        expect(_built, [
          for (var i = 0; i < c.$4; i++)
            '${DateTime(c.$3.year, c.$3.month, c.$3.day + i).month}/'
                '${DateTime(c.$3.year, c.$3.month, c.$3.day + i).day}'
        ]);
      });
    }
  });

  group('Characterization: navigation', () {
    const back = Icons.arrow_back, next = Icons.arrow_forward;

    testWidgets('A month, no bounds', (tester) async {
      await _setNavView(tester);
      final log = <String>[];
      await tester
          .pumpWidget(_navCalendar(log, selectedDay: DateTime(2024, 2, 14)));
      expect(_page(tester), 'true/true 29..3(35)');
      expect(await _tapArrow(tester, log, next), [
        'changed 2024-3-1 0:0 .. 2024-3-31 0:0',
        'page 2024-3-1 0:0',
        'true/true 26..31(35)',
      ]);
      expect(await _tapArrow(tester, log, back), [
        'changed 2024-2-1 0:0 .. 2024-2-29 0:0',
        'page 2024-2-1 0:0',
        'true/true 29..3(35)',
      ]);
      expect(await _tapArrow(tester, log, back), [
        'changed 2024-1-1 0:0 .. 2024-1-31 0:0',
        'page 2024-1-1 0:0',
        'true/true 1..4(35)',
      ]);
    });

    testWidgets('B week, bounded', (tester) async {
      await _setNavView(tester);
      final log = <String>[];
      await tester.pumpWidget(_navCalendar(log,
          selectedDay: DateTime(2024, 2, 14),
          format: CalendarFormat.week,
          firstDay: DateTime(2024, 2, 5),
          lastDay: DateTime(2024, 3, 3)));
      expect(_page(tester), 'true/true 12..18(7)');
      expect(await _tapArrow(tester, log, next), [
        'changed 2024-2-18 0:0 .. 2024-2-29 0:0',
        'page 2024-2-18 0:0',
        'true/true 12..18(7)',
      ]);
      expect(await _tapArrow(tester, log, next), [
        'changed 2024-3-1 0:0 .. 2024-3-10 0:0',
        'page 2024-3-1 0:0',
        'true/true 26..3(7)',
      ]);
      expect(await _tapArrow(tester, log, next), [
        'changed 2024-3-11 0:0 .. 2024-3-16 0:0',
        'page 2024-3-11 0:0',
        'true/false 11..17(7)',
      ]);
      expect(await _tapArrow(tester, log, back), [
        'changed 2024-3-4 0:0 .. 2024-3-9 0:0',
        'page 2024-3-4 0:0',
        'true/false 4..10(7)',
      ]);
      expect(await _tapArrow(tester, log, back), [
        'changed 2024-2-26 0:0 .. 2024-3-2 0:0',
        'page 2024-2-26 0:0',
        'true/true 26..3(7)',
      ]);
      expect(await _tapArrow(tester, log, back), [
        'changed 2024-2-19 0:0 .. 2024-2-24 0:0',
        'page 2024-2-19 0:0',
        'true/true 19..25(7)',
      ]);
    });

    testWidgets('C two weeks', (tester) async {
      await _setNavView(tester);
      final log = <String>[];
      await tester.pumpWidget(_navCalendar(log,
          selectedDay: DateTime(2024, 1, 17), format: CalendarFormat.twoWeeks));
      expect(_page(tester), 'true/true 15..28(14)');
      expect(await _tapArrow(tester, log, next), [
        'changed 2024-1-28 0:0 .. 2024-2-15 0:0',
        'page 2024-1-28 0:0',
        'true/true 22..4(14)',
      ]);
      expect(await _tapArrow(tester, log, back), [
        'changed 2024-1-14 0:0 .. 2024-2-1 0:0',
        'page 2024-1-14 0:0',
        'true/true 8..21(14)',
      ]);
      expect(await _tapArrow(tester, log, back), [
        'changed 2023-12-31 0:0 .. 2024-1-18 0:0',
        'page 2023-12-31 0:0',
        'true/true 25..7(14)',
      ]);
    });

    testWidgets('D month, bounded', (tester) async {
      await _setNavView(tester);
      final log = <String>[];
      await tester.pumpWidget(_navCalendar(log,
          selectedDay: DateTime(2024, 2, 14),
          firstDay: DateTime(2024, 1, 1),
          lastDay: DateTime(2024, 3, 31)));
      expect(_page(tester), 'true/true 29..3(35)');
      expect(await _tapArrow(tester, log, back), [
        'changed 2024-1-1 0:0 .. 2024-1-31 0:0',
        'page 2024-1-1 0:0',
        'false/true 1..4(35)',
      ]);
      expect(await _tapArrow(tester, log, next), [
        'changed 2024-2-1 0:0 .. 2024-2-29 0:0',
        'page 2024-2-1 0:0',
        'true/true 29..3(35)',
      ]);
      expect(await _tapArrow(tester, log, next), [
        'changed 2024-3-1 0:0 .. 2024-3-31 0:0',
        'page 2024-3-1 0:0',
        'true/false 26..31(35)',
      ]);
    });

    testWidgets('E month/year dropdowns', (tester) async {
      await _setNavView(tester);
      final log = <String>[];
      await tester.pumpWidget(_navCalendar(log,
          selectedDay: DateTime(2024, 2, 14),
          firstDay: DateTime(2023, 3, 10),
          lastDay: DateTime(2025, 10, 20),
          showComboboxForMonthYear: true));
      expect(_page(tester), 'true/true 29..3(35)');
      expect(await _pickDropdown(tester, log, 1, '2025'), [
        'year 2025',
        'changed 2025-2-1 0:0 .. 2025-2-28 0:0',
        'page 2025-2-1 0:0',
        'true/true 27..2(35)',
      ]);
      expect(await _pickDropdown(tester, log, 1, '2023'), [
        'year 2023',
        'changed 2023-3-1 0:0 .. 2023-3-31 0:0',
        'page 2023-3-1 0:0',
        'false/true 27..2(35)',
      ]);
      expect(await _pickDropdown(tester, log, 0, 'October'), [
        'month 10',
        'changed 2023-10-1 0:0 .. 2023-10-31 0:0',
        'page 2023-10-1 0:0',
        'true/true 25..5(42)',
      ]);
      expect(await _pickDropdown(tester, log, 1, '2025'), [
        'year 2025',
        'changed 2025-10-1 0:0 .. 2025-10-31 0:0',
        'page 2025-10-1 0:0',
        'true/false 29..2(35)',
      ]);
    });
  });

  group('Characterization: weekday header structure', () {
    for (final (name, style, expected) in [
      (
        'default style',
        null,
        const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
      (
        'custom weekdayTextStyle',
        CalendarStyle(
            weekdayTextStyle:
                const TextStyle(fontSize: 9, color: Colors.green)),
        const TextStyle(fontSize: 9, color: Colors.green),
      ),
    ]) {
      testWidgets(name, (tester) async {
        await _setNavView(tester);
        await tester.pumpWidget(_app(CalendarEssentials(
          events: const [],
          selectedDay: DateTime(2024, 2, 14),
          calendarStyle: style,
        )));
        final row = tester.widget<Row>(find
            .ancestor(of: find.text('Monday'), matching: find.byType(Row))
            .first);
        expect(row.mainAxisAlignment, MainAxisAlignment.start);
        expect(row.children, hasLength(7));
        final labels = <String>[];
        for (final child in row.children) {
          final expanded = child as Expanded;
          expect(expanded.flex, 1);
          expect(expanded.fit, FlexFit.tight);
          final pad = expanded.child as Padding;
          expect(pad.padding, const EdgeInsets.all(3.0));
          final center = pad.child as Center;
          expect(center.alignment, Alignment.center);
          expect(center.widthFactor, isNull);
          expect(center.heightFactor, isNull);
          final text = center.child as Text;
          expect(text.textAlign, TextAlign.center);
          expect(text.style, expected);
          labels.add(text.data!);
        }
        expect(labels, [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ]);
      });
    }
  });

  group('Characterization: format dropdown', () {
    testWidgets('T1 callbacks and grid per format', (tester) async {
      await _setNavView(tester);
      final log = <String>[];
      await tester
          .pumpWidget(_navCalendar(log, selectedDay: DateTime(2024, 2, 14)));
      final dropdown = tester.widget<DropdownButton<CalendarFormat>>(
          find.byType(DropdownButton<CalendarFormat>));
      expect(dropdown.value, CalendarFormat.month);
      expect(dropdown.items!.map((i) => i.value), CalendarFormat.values);
      expect(dropdown.items!.map((i) => (i.child as Text).data),
          ['Week', 'Two weeks', 'Month']);
      expect(await _pickFormat(tester, log, 'Week'), [
        'changed 2024-2-1 0:0 .. 2024-2-9 0:0',
        'format CalendarFormat.week',
        'true/true 29..4(7)',
      ]);
      expect(await _pickFormat(tester, log, 'Two weeks'), [
        'changed 2024-2-1 0:0 .. 2024-2-16 0:0',
        'format CalendarFormat.twoWeeks',
        'true/true 29..11(14)',
      ]);
      expect(await _pickFormat(tester, log, 'Month'), [
        'changed 2024-2-1 0:0 .. 2024-2-29 0:0',
        'format CalendarFormat.month',
        'true/true 29..3(35)',
      ]);
    });

    testWidgets('T1b no callbacks', (tester) async {
      await _setNavView(tester);
      await tester.pumpWidget(_app(CalendarEssentials(
        events: const [],
        selectedDay: DateTime(2024, 2, 14),
      )));
      expect(await _pickFormat(tester, <String>[], 'Week'),
          ['true/true 29..4(7)']);
      expect(tester.takeException(), isNull);
    });
  });

  group('Characterization: day tap', () {
    const red = BoxDecoration(color: Colors.red, shape: BoxShape.circle);

    testWidgets('T2 callback gets the validated day', (tester) async {
      await _setNavView(tester);
      final log = <String>[];
      await tester.pumpWidget(_app(CalendarEssentials(
        events: const [],
        selectedDay: DateTime(2024, 2, 14),
        firstDay: DateTime(2024, 2, 5),
        lastDay: DateTime(2024, 3, 3),
        onDaySelected: (d) => log.add('day ${_d(d)}'),
      )));
      await tester.tap(find.text('20'));
      await tester.pump();
      expect(log, ['day 2024-2-20 0:0']);
      expect(
          find.descendant(of: _containerWith(red), matching: find.text('20')),
          findsOneWidget);
      log.clear();
      await tester.tap(find.text('30'));
      await tester.pump();
      expect(log, ['day 2024-2-5 0:0']);
      expect(find.descendant(of: _containerWith(red), matching: find.text('5')),
          findsOneWidget);
    });

    testWidgets('T2b no callback', (tester) async {
      await _setNavView(tester);
      await tester.pumpWidget(_app(CalendarEssentials(
        events: const [],
        selectedDay: DateTime(2024, 2, 14),
      )));
      await tester.tap(find.text('20'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(
          find.descendant(of: _containerWith(red), matching: find.text('20')),
          findsOneWidget);
    });
  });

  group('Characterization: combobox items', () {
    testWidgets('T3 month and year items, labels, underline', (tester) async {
      await _setNavView(tester);
      await tester.pumpWidget(_app(CalendarEssentials(
        events: const [],
        showComboboxForMonthYear: true,
        selectedDay: DateTime(2024, 5, 1),
        firstDay: DateTime(2024, 3, 10),
        lastDay: DateTime(2025, 10, 20),
      )));
      final dropdowns = tester
          .widgetList<DropdownButton<int>>(find.byType(DropdownButton<int>))
          .toList();
      expect(dropdowns.length, 2);
      final month = dropdowns.first;
      expect(month.value, 5);
      expect(
          month.items!.map((i) => i.value), [for (var m = 3; m <= 12; m++) m]);
      expect(month.items!.map((i) => (i.child as Text).data), [
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ]);
      final year = dropdowns.last;
      expect(year.value, 2024);
      expect(year.items!.map((i) => i.value), [2024, 2025]);
      expect(year.items!.map((i) => (i.child as Text).data), ['2024', '2025']);
      for (final d in dropdowns) {
        final underline = d.underline;
        expect(underline, isA<Container>());
        expect((underline as Container).child, isNull);
        expect(underline.decoration, isNull);
        expect(d.onChanged, isNotNull);
      }
    });
  });
}
