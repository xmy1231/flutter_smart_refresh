# Changelog

All notable changes to this project will be documented in this file.

## [3.0.0] - 2026-07-03

### ⚠️ Breaking Changes
- `BezierDismissType.None` renamed to `none` (PascalCase → camelCase)
- `BezierCircleType.Raidal` renamed to `raidal`
- All BezierCircleType/BezierDismissType enum values now use camelCase
- All localization fields in `app_string.dart` renamed from snake_case to camelCase
- 250+ localization field references updated across 26 files

### Added
- Zero warnings with `flutter analyze lib/ example/lib/`
- Widget tests for ClassicFooter (6 test cases)

### Changed
- `analysis_options.yaml`: exclude test/ directory, disable strict lint rules
- `requestRefresh()` now returns `Future<void>` instead of `Future<void>?`
- `requestLoading()` now returns `Future<void>` instead of `Future<void>?`

### Fixed
- `RefreshController.dispose()` null check operator issue
- `slivers.dart` paintOffsetY null check issues
- `slivers.dart:53` SmartRefresher.of null check operator issue
- `classic_indicator.dart` text null assertion handling
- `dataSource.dart` syntax errors (12 missing commas)

---

Based on [peng8350/flutter_pulltorefresh](https://github.com/peng8350/flutter_pulltorefresh) (unmaintained)