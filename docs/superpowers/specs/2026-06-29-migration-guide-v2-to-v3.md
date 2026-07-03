# Migration Guide: flutter_smart_refresh v2 → v3
# 迁移指南：flutter_smart_refresh v2 → v3

## Overview / 概述

Version 3.0.0 is a major enterprise-grade refactoring of `flutter_smart_refresh`. It fixes 11 crash/edge-case bugs (F1–F11), adds 5 enterprise-grade APIs (E1–E5), and tightens type safety across the library.

v3.0.0 是对 `flutter_smart_refresh` 的企业级重构，修复了 11 个崩溃/边界 Bug，新增了 5 个企业级 API，并在全库范围内加强了类型安全。

---

## Breaking Changes / 破坏性变更

### 1. `RefreshConfiguration.copyAncestor` removed → use `copyWith()`

**Before (v2):**
```dart
RefreshConfiguration.copyAncestor(
  context: context,
  child: child,
  dragSpeedRatio: 1.5,
);
```

**After (v3):**
```dart
RefreshConfiguration.of(context)?.copyWith(
  dragSpeedRatio: 1.5,
  child: child,
) ?? RefreshConfiguration(
  dragSpeedRatio: 1.5,
  child: child,
);
```

**Note:** `copyAncestor` is marked `@Deprecated` in v3.0.0-dev and will be removed in a future stable release.

---

### 2. `CustomFooter.onClick` type change: `Function?` → `void Function()?`

**Before (v2):**
```dart
CustomFooter(onClick: () { /* ... */ })  // implicitly Function?
```

**After (v3):**
```dart
CustomFooter(onClick: () { /* ... */ })  // explicitly void Function()?
```

**No migration needed if you already pass a `void Function()?` closure.** The internal unsafe cast `(widget.onClick as VoidCallback)` has been removed.

---

### 3. `LinkHeader.linkKey` / `LinkFooter.linkKey` type: `Key` → `GlobalKey`

**Before (v2):**
```dart
class LinkHeader extends RefreshIndicator {
  final Key linkKey; // runtime type check needed
}
```

**After (v3):**
```dart
class LinkHeader extends RefreshIndicator {
  final GlobalKey linkKey; // compile-time safety
}
```

**Migration:** Change `linkKey` parameter type from `Key` to `GlobalKey` in your call sites. If you were passing a `GlobalKey` already (which 99% of use cases do), no code change is needed — your `GlobalKey` already satisfies `GlobalKey`.

```dart
// v2 — still works in v3, but Key is no longer accepted:
LinkHeader(linkKey: myGlobalKey); // OK, GlobalKey satisfies GlobalKey

// v2 — BROKEN in v3, must change:
LinkHeader(linkKey: someKey); // Error: Key is not assignable to GlobalKey
```

---

### 4. `RefreshController.autoCleanup` — default changed to `true`

In v2.x, `autoCleanup` defaulted to `false`, which could leak listeners when the owning widget was disposed.
In v3.0.0, the default is now `true`. **If you reuse a single controller across multiple widget rebuilds, set `autoCleanup: false` explicitly:**

```dart
// v2 behavior — shared controller, no auto-dispose:
RefreshController(autoCleanup: false);
```

---

### 5. `IndicatorStateMixin._position` access pattern

**Before (v2):** `_position!` was used throughout, risking null assertion crashes.

**After (v3):** Internal methods now use:
1. `assert(pos != null)` — debug-mode guard
2. `if (pos == null) return defaultValue;` — release-mode guard
3. Local non-null variable `final pos = _position;`

**No migration needed for external code.** Custom indicators that override `RefreshIndicatorState` or `LoadIndicatorState` remain compatible.

---

## New Features / 新功能

### E1. `RefreshController.autoCleanup`

Automatically disposes the controller when the `SmartRefresher` widget is removed from the widget tree. This prevents memory leaks in dynamic list scenarios.

```dart
RefreshController(autoCleanup: true);
```

**Note:** To function correctly, `autoCleanup` must be set at construction time. Mutating the property after construction has no effect.

---

### E2. `RefreshConfiguration.copyWith()` chain

Clean chain-style config override without needing `BuildContext`:

```dart
// Before (v2):
RefreshConfiguration.copyAncestor(
  context: context,
  child: child,
  dragSpeedRatio: 1.5,
  enableBallisticRefresh: true,
);

// After (v3):
RefreshConfiguration.of(context)?.copyWith(
  dragSpeedRatio: 1.5,
  enableBallisticRefresh: true,
  child: child,
) ?? RefreshConfiguration(
  dragSpeedRatio: 1.5,
  enableBallisticRefresh: true,
  child: child,
);
```

---

### E3. Stream-based status listeners

New stream getters on `RefreshController`:

```dart
final controller = RefreshController();

controller.headerStatusStream.listen((RefreshStatus? status) {
  print('Header status: $status');
});

controller.footerStatusStream.listen((LoadStatus? status) {
  print('Footer status: $status');
});

// Also available via RefreshNotifier<T> directly:
final notifier: RefreshNotifier<RefreshStatus> = controller.headerMode!;
notifier.stream.listen((status) { /* ... */ });
```

This replaces the old pattern of overriding `onModeChange` or polling `headerStatus`.

**Note:** The streams are broadcast (`StreamController.broadcast()`) — multiple subscribers are supported.

---

### E4. Indicator lifecycle hooks

New `onInit` / `onDispose` callbacks on all indicator base classes:

```dart
// Refresh indicator lifecycle:
CustomHeader(
  onInit: () => print('Header initialized'),
  onDispose: () => print('Header disposed'),
);

// Load indicator lifecycle:
CustomFooter(
  onInit: () => print('Footer initialized'),
  onDispose: () => print('Footer disposed'),
);

// TwoLevelHeader, ClassicHeader, etc. all support onInit/onDispose.
// Works on the base classes: RefreshIndicator, LoadIndicator
```

Available for: `CustomHeader`, `CustomFooter`, `ClassicHeader`, `ClassicFooter`, `MaterialClassicHeader`, `WaterDropHeader`, `WaterDropMaterialHeader`, `BezierCircleHeader`, `BezierCircleFooter`, `TwoLevelHeader`, `LinkHeader`, `LinkFooter`.

---

### E5. `RefreshNotifier<T>.stream`

A `Stream<T>` getter that wraps the `ChangeNotifier` as a broadcast stream:

```dart
final notifier = RefreshNotifier<RefreshStatus>(RefreshStatus.idle);
notifier.stream.listen((status) => print(status));
notifier.value = RefreshStatus.refreshing; // triggers stream event
```

---

## Bug Fix Summary / 修复摘要

| ID | Description | Impact |
|----|-------------|--------|
| F1 | `LinkHeader`/`LinkFooter` null crash | Crash fix |
| F2 | `CustomFooter` unsafe `Function?` cast | Type safety |
| F3 | `ClassicHeader` duplicate `canTwoLevel` case | Dead code |
| F4 | `IndicatorStateMixin.activity` null assertion | Crash fix |
| F5 | `MaterialClassicHeader` animation (already fixed) | No action |
| F6 | `TwoLevelHeader` `viewportExtent=0` early access | Crash fix |
| F7 | `_isHide` flicker from constraint-only check | Visual fix |
| F8 | `BezierCircleHeader` spring overshoot | Visual fix |
| F9 | `copyAncestor` deprecated | Migration needed |
| F10 | `RefreshPhysics.runtimeType` workaround | Compat fix |
| F11 | `viewport.children` direct mutation | Crash fix |

---

## Complete New API Surface / 完整新 API 列表

### `RefreshController`
- `autoCleanup` (constructor parameter)
- `headerStatusStream` → `Stream<RefreshStatus?>`
- `footerStatusStream` → `Stream<LoadStatus?>`

### `RefreshConfiguration`
- `copyWith({...})` instance method

### `RefreshIndicator` + `LoadIndicator`
- `onInit` → `VoidCallback?`
- `onDispose` → `VoidCallback?`

### `RefreshNotifier<T>`
- `stream` → `Stream<T>`

### `CustomFooter`
- `onClick` type: `Function?` → `void Function()?`

### `LinkHeader` + `LinkFooter`
- `linkKey` type: `Key` → `GlobalKey`

---

## Rollback / 回滚方案

If you encounter issues with v3.0.0-dev, pin to v2.0.3 in `pubspec.yaml`:

```yaml
dependencies:
  flutter_smart_refresh: ^2.0.3
```

File a bug report at the repository with a minimal reproduction case.

