import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_calendar_essentials/calendar_essentials.dart';

void main() {
  group('CalendarEssentials Combobox Tests', () {
    testWidgets('Should show label when showComboboxForMonthYear is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalendarEssentials(
              events: [],
              showComboboxForMonthYear: false,
            ),
          ),
        ),
      );

      // Should find the Text widget for month/year label
      expect(find.byType(Text), findsWidgets);
      // Should not find multiple DropdownButtons (only the format dropdown)
      expect(find.byType(DropdownButton<int>), findsNothing);
    });

    testWidgets('Should show comboboxes when showComboboxForMonthYear is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalendarEssentials(
              events: [],
              showComboboxForMonthYear: true,
            ),
          ),
        ),
      );

      // Should find the DropdownButton widgets for month and year
      expect(find.byType(DropdownButton<int>), findsNWidgets(2));
    });

    testWidgets('Should trigger onMonthChanged when month is selected',
        (WidgetTester tester) async {
      int? selectedMonth;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: CalendarEssentials(
                events: const [],
                showComboboxForMonthYear: true,
                selectedDay: DateTime(2024, 1, 15),
                onMonthChanged: (month) {
                  selectedMonth = month;
                },
              ),
            ),
          ),
        ),
      );

      // Find the month dropdown and tap it
      final monthDropdowns = find.byType(DropdownButton<int>);
      expect(monthDropdowns, findsNWidgets(2));

      // Tap the first dropdown (month)
      await tester.tap(monthDropdowns.first);
      await tester.pumpAndSettle();

      // Find and tap February option
      final februaryOption = find.text('February').last;
      await tester.tap(februaryOption, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify the callback was triggered
      expect(selectedMonth, 2);
    });

    testWidgets('Should trigger onYearChanged when year is selected',
        (WidgetTester tester) async {
      int? selectedYear;
      const testYear = 2024;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: CalendarEssentials(
                events: const [],
                showComboboxForMonthYear: true,
                selectedDay: DateTime(testYear, 1, 15),
                firstDay: DateTime(testYear - 5, 1, 1),
                lastDay: DateTime(testYear + 5, 12, 31),
                onYearChanged: (year) {
                  selectedYear = year;
                },
              ),
            ),
          ),
        ),
      );

      // Find the year dropdown (second one)
      final dropdowns = find.byType(DropdownButton<int>);
      expect(dropdowns, findsNWidgets(2));

      // Tap the year dropdown
      await tester.tap(dropdowns.at(1));
      await tester.pumpAndSettle();

      // Find and tap a different year option
      final yearOption = find.text((testYear - 1).toString()).last;
      await tester.tap(yearOption, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify the callback was triggered
      expect(selectedYear, testYear - 1);
    });

    testWidgets('Should respect min/max date constraints for months',
        (WidgetTester tester) async {
      const testYear = 2024;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 800,
                height: 800,
                child: CalendarEssentials(
                  events: const [],
                  showComboboxForMonthYear: true,
                  selectedDay:
                      DateTime(testYear, 5, 15), // Start in May (within range)
                  firstDay: DateTime(testYear, 3, 1), // March
                  lastDay: DateTime(testYear, 8, 31), // August
                ),
              ),
            ),
          ),
        ),
      );

      // Tap the month dropdown
      final monthDropdown = find.byType(DropdownButton<int>).first;
      await tester.tap(monthDropdown);
      await tester.pumpAndSettle();

      // Should not find January (before firstDay)
      expect(find.text('January'), findsNothing);

      // Should find March (within range)
      expect(find.text('March'), findsWidgets);

      // Should find August (within range)
      expect(find.text('August'), findsWidgets);

      // Should not find September (after lastDay)
      expect(find.text('September'), findsNothing);

      // Close dropdown
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
    });

    testWidgets('Should respect min/max date constraints for years',
        (WidgetTester tester) async {
      const startYear = 2020;
      const endYear = 2025;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: CalendarEssentials(
                events: const [],
                showComboboxForMonthYear: true,
                selectedDay: DateTime(2022, 6, 15), // Start in middle of range
                firstDay: DateTime(startYear, 1, 1),
                lastDay: DateTime(endYear, 12, 31),
              ),
            ),
          ),
        ),
      );

      // Tap the year dropdown
      final yearDropdown = find.byType(DropdownButton<int>).at(1);
      await tester.tap(yearDropdown);
      await tester.pumpAndSettle();

      // Should not find years before startYear
      expect(find.text('2019'), findsNothing);

      // Should find startYear
      expect(find.text('2020'), findsWidgets);

      // Should find endYear
      expect(find.text('2025'), findsWidgets);

      // Should not find years after endYear
      expect(find.text('2026'), findsNothing);
    });
  });
}
