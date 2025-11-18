## [Unreleased]

### Added
* **Full text styling customization** - Added 7 new TextStyle properties to CalendarStyle:
  - `dayTextStyle` - Style for normal day numbers
  - `selectedDayTextStyle` - Style for selected day number
  - `todayTextStyle` - Style for today's day number
  - `headerTextStyle` - Style for month/year header text
  - `comboboxTextStyle` - Style for month/year dropdown text
  - `formatTextStyle` - Style for format dropdown text
  - `weekdayTextStyle` - Style for weekday headers (M, T, W, etc.)
* **Month/Year dropdown selectors** - Added `showComboboxForMonthYear` parameter for quick date navigation
* **New callbacks** - Added `onYearChanged` and `onMonthChanged` callbacks for dropdown selection events
* **Responsive weekday labels** - Weekday headers now automatically adapt based on screen width:
  - Short format (M, T, W) for narrow screens (< 40px per cell)
  - Medium format (Mon, Tue, Wed) for medium screens (40-70px per cell)
  - Long format (Monday, Tuesday, Wednesday) for wide screens (> 70px)
* **Responsive calendar header** - Header layout now adapts to screen width:
  - Wide screens (>= 400px): All controls in single row (arrows, month/year, view mode)
  - Narrow screens (< 400px): Two-row layout with view mode selector wrapping to second row

### Changed
* Refactored text styling throughout the calendar to use the new style properties
* Improved CalendarStyle constructor to accept optional text style parameters
* Enhanced documentation with comprehensive examples and styling guidelines

## 1.0.13

* Fixed event content alignment by adding proper mainAxisAlignment and crossAxisAlignment
* Fixed calendar display for months spanning more than 4 weeks (increased to 6 weeks maximum)
* Fixed cell width calculation to properly account for padding (8px on all sides)
* Code quality improvements: removed unreachable switch defaults and added const constructors

## 1.0.10

* initialization of the project with a basic implementation
* add days name for month format
*  add selectedday property and set it when changing pages

