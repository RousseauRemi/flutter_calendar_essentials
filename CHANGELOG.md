## 1.0.14 - 2025-01-18

### 🎯 Major Refactoring & Professional Polish

This release represents a complete overhaul of the codebase to achieve production-grade quality, with significant improvements to architecture, documentation, performance, and code quality.

### 🏗️ Architecture Improvements
* **Removed unnecessary widget wrapper** - Eliminated the redundant `StatelessWidget` wrapper class for cleaner, more maintainable architecture
* **Consolidated file structure** - Merged state file into main widget file for better organization
* **Extracted large methods** - Broke down 161-line `_buildCalendar()` method into focused, single-responsibility methods:
  - `_buildWeek()` - Builds a week of day cells
  - `_buildDayCell()` - Builds individual day cells
  - `_findEventForDay()` - Optimized event lookup
  - `_buildWeeks()` - Builds multiple weeks for calendar
  - `_buildWeekdayHeader()` - Builds weekday header row
  - `_notifyPageChange()` - Consolidated callback notifications

### 📚 Documentation
* **Comprehensive dartdoc comments** added to all public APIs (100% coverage):
  - All public classes (CalendarEssentials, CalendarStyle, EventCalendarEssential, etc.)
  - All public methods with parameter descriptions and examples
  - All enums with detailed descriptions
* **Fixed broken README examples** - Updated examples to use correct, working class names
* **Updated README to v1.0.14** with improved code samples and usage instructions

### ⚡ Performance Optimizations
* **O(1) event lookup** - Replaced O(n) linear search with Map-based O(1) lookup (major performance improvement for calendars with many events)
* **Event map caching** - Built event map once and reused, with automatic rebuilding on event list changes via `didUpdateWidget`
* **Date normalization** - Unified date comparison logic with `_normalizeDate()` utility method

### 🐛 Bug Fixes & Code Quality
* **Removed dead code** - Deleted unused `isSelected` property from `EventCalendarEssential`
* **Fixed typos** - Corrected method names (`Moth`→`Month`, `temporyDate`→`temporaryDate`)
* **Named constants** - Replaced all magic numbers with descriptive constants:
  - `_defaultCellHeight = 38.0`
  - `_cellHorizontalPadding = 6.0`
  - `_totalHorizontalMargin = 16.0`
  - `_headerWrapThreshold = 400.0`
  - `_shortNameWidthThreshold = 40.0`
  - `_mediumNameWidthThreshold = 70.0`
* **Eliminated code duplication** - Consolidated repeated callback notification code
* **Date validation** - Added `_validateSelectedDay()` to ensure selected day is within allowed date range
* **State initialization fix** - Account for `firstDay` limit when initializing state

### 🎨 API Improvements
* **Optional CalendarStyle parameters** - All CalendarStyle parameters now optional with sensible defaults:
  - `todayDecoration` defaults to blue circle
  - `selectedDecoration` defaults to red circle
  - All text styles optional with fallbacks
* **Breaking change**: Removed second parameter from `EventCalendarEssential` constructor (unused `isSelected` property)

### ✅ Code Quality
* **Zero analyzer warnings** - All 20 Dart analyzer issues resolved:
  - Added `const` constructors where applicable
  - Removed unused imports
  - Fixed async misuse
* **100% formatted** - All code formatted with `dart format`
* **Improved null safety** - Better use of nullable types and null checks

### 📦 Other Improvements
* **Enhanced package description** in pubspec.yaml
* **Updated dependencies** - Clarified intl package usage comment
* **Test improvements** - Fixed all test file warnings

### Full Text Styling Customization (from 1.0.13, now documented)
* **7 TextStyle properties** for complete visual control:
  - `dayTextStyle` - Normal day numbers
  - `selectedDayTextStyle` - Selected day number
  - `todayTextStyle` - Today's day number
  - `headerTextStyle` - Month/year header text
  - `comboboxTextStyle` - Month/year dropdown text
  - `formatTextStyle` - Format dropdown text
  - `weekdayTextStyle` - Weekday headers

### Responsive Features (from 1.0.13, now documented)
* **Month/Year dropdown selectors** - `showComboboxForMonthYear` parameter
* **New callbacks** - `onYearChanged` and `onMonthChanged`
* **Responsive weekday labels** - Auto-adapt based on screen width
* **Responsive calendar header** - Layout adapts to available width

## 1.0.13 - Previous Release

* Fixed event content alignment by adding proper mainAxisAlignment and crossAxisAlignment
* Fixed calendar display for months spanning more than 4 weeks (increased to 6 weeks maximum)
* Fixed cell width calculation to properly account for padding (8px on all sides)
* Code quality improvements: removed unreachable switch defaults and added const constructors

## 1.0.10

* initialization of the project with a basic implementation
* add days name for month format
*  add selectedday property and set it when changing pages

