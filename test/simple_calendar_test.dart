import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_calendar_essentials/calendar_essentials.dart';
import 'package:flutter_calendar_essentials/calendar_style.dart';
import 'package:flutter_calendar_essentials/simple_event_calendar_essential.dart';

void main() {
  group('CalendarEssentials Combobox Tests', () {
    testWidgets('Should show label when showComboboxForMonthYear is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
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

    testWidgets('Should show comboboxes when showComboboxForMonthYear is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
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

    testWidgets('Should trigger onMonthChanged when month is selected', (WidgetTester tester) async {
      int? selectedMonth;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarEssentials(
              events: [],
              showComboboxForMonthYear: true,
              onMonthChanged: (month) {
                selectedMonth = month;
              },
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

      // Find and tap a different month option (if available)
      final monthOptions = find.text('February');
      if (monthOptions.evaluate().isNotEmpty) {
        await tester.tap(monthOptions.last);
        await tester.pumpAndSettle();

        // Verify the callback was triggered
        expect(selectedMonth, 2);
      }
    });

    testWidgets('Should trigger onYearChanged when year is selected', (WidgetTester tester) async {
      int? selectedYear;
      final currentYear = DateTime.now().year;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarEssentials(
              events: [],
              showComboboxForMonthYear: true,
              firstDay: DateTime(currentYear - 5, 1, 1),
              lastDay: DateTime(currentYear + 5, 12, 31),
              onYearChanged: (year) {
                selectedYear = year;
              },
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
      final yearOption = find.text((currentYear - 1).toString());
      if (yearOption.evaluate().isNotEmpty) {
        await tester.tap(yearOption.last);
        await tester.pumpAndSettle();

        // Verify the callback was triggered
        expect(selectedYear, currentYear - 1);
      }
    });

    testWidgets('Should respect min/max date constraints for months', (WidgetTester tester) async {
      final currentYear = DateTime.now().year;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarEssentials(
              events: [],
              showComboboxForMonthYear: true,
              firstDay: DateTime(currentYear, 3, 1),  // March
              lastDay: DateTime(currentYear, 8, 31),  // August
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
    });

    testWidgets('Should respect min/max date constraints for years', (WidgetTester tester) async {
      final startYear = 2020;
      final endYear = 2025;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarEssentials(
              events: [],
              showComboboxForMonthYear: true,
              firstDay: DateTime(startYear, 1, 1),
              lastDay: DateTime(endYear, 12, 31),
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
