# flutter_smart_refresh

[![Pub Version](https://img.shields.io/pub/v/flutter_smart_refresh)](https://pub.dev/packages/flutter_smart_refresh)
[![Dart SDK](https://img.shields.io/badge/dart-%5E3.12.0-blue)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-iOS%7CAndroid-blue)](https://flutter.dev)
[![Null Safety](https://img.shields.io/badge/null-safety-ready-brightgreen)](https://dart.dev/null-safety)

## ⚠️ Fork Notice

> **This is a community maintenance fork of [peng8350/flutter_pulltorefresh](https://github.com/peng8350/flutter_pulltorefresh).**

The original library is **no longer maintained**. This fork addresses critical issues:

- ✅ Full null-safety compliance for Dart 3.12+
- ✅ Bug fixes (null check operators, dispose issues, etc.)
- ✅ API compatibility preserved

**Original Author:** [peng8350](https://github.com/peng8350)  
**Original Repo:** [peng8350/flutter_pulltorefresh](https://github.com/peng8350/flutter_pulltorefresh) (unmaintained)

---

## Features

- 🛡️ **Fully null-safe** with Dart 3.12+ support
- 📦 **8+ built-in indicator components** (Classic, Material, Bezier, WaterDrop, TwoLevel, etc.)
- 🎮 **Flexible status management** via RefreshController
- 🎨 **4 RefreshStyle modes**: Follow, UnFollow, Behind, Front
- 📋 **3 LoadStyle modes**: ShowAlways, HideAlways, ShowWhenLoading
- 🏠 **Two-level (二楼) refresh** support
- ⚙️ **Global configuration** via RefreshConfiguration
- 🌍 **Internationalization support** (15+ languages built-in)
- 🔧 **Custom physics tuning** (spring, drag speed, overscroll limits)
- 📳 **NestedScrollView support**

---

## Installation

Add `flutter_smart_refresh` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_smart_refresh: ^3.0.0
```

Then run:

```bash
flutter pub get
```

---

## Quick Start

```dart
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';

// 1. Create a RefreshController
final RefreshController _controller = RefreshController();

// 2. Use SmartRefresher
SmartRefresher(
  controller: _controller,
  enablePullDown: true,
  enablePullUp: true,
  onRefresh: () async {
    // Fetch data
    await fetchData();
    // End refresh
    _controller.refreshCompleted();
    // Or: _controller.refreshFailed();
  },
  onLoading: () async {
    // Load more data
    await loadMoreData();
    if (noMoreData) {
      _controller.loadNoData();
    } else {
      _controller.loadComplete();
      // Or: _controller.loadFailed();
    }
  },
  header: ClassicHeader(),
  footer: ClassicFooter(),
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => ListTile(title: Text(items[index])),
  ),
)

// 3. Don't forget to dispose
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

---

## Examples

### 1. Basic Pull-to-Refresh

```dart
SmartRefresher(
  controller: _controller,
  enablePullDown: true,
  header: ClassicHeader(),
  onRefresh: () async {
    await fetchData();
    _controller.refreshCompleted();
  },
  child: ListView.builder(
    itemBuilder: (c, i) => Text('Item $i'),
    itemCount: 20,
    itemExtent: 100,
  ),
)
```

### 2. Pull-to-Load-More

```dart
SmartRefresher(
  controller: _controller,
  enablePullUp: true,
  footer: ClassicFooter(
    loadStyle: LoadStyle.ShowAlways,
  ),
  onLoading: () async {
    await loadMoreData();
    _controller.loadComplete();
  },
  child: ListView.builder(
    itemBuilder: (c, i) => Text('Item $i'),
    itemCount: 20,
    itemExtent: 100,
  ),
)
```

### 3. Custom Header

```dart
SmartRefresher(
  controller: _controller,
  header: CustomHeader(
    builder: (context, mode) {
      switch (mode) {
        case RefreshStatus.refreshing:
          return SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(),
          );
        case RefreshStatus.completed:
          return Text('Refresh completed');
        case RefreshStatus.failed:
          return Text('Refresh failed');
        default:
          return Text('Pull down to refresh');
      }
    },
  ),
  onRefresh: () async {
    await fetchData();
    _controller.refreshCompleted();
  },
  child: ListView.builder(
    itemBuilder: (c, i) => Text('Item $i'),
    itemCount: 20,
    itemExtent: 100,
  ),
)
```

### 4. Two-Level Refresh (二楼)

```dart
SmartRefresher(
  controller: _controller,
  enableTwoLevel: true,
  onTwoLevel: (isOpen) {
    if (isOpen) {
      // User opened two-level, load content
      Future.delayed(Duration(seconds: 2), () {
        _controller.twoLevelComplete();
      });
    }
  },
  header: TwoLevelHeader(
    twoLevelWidget: Container(
      color: Colors.blue,
      child: Center(child: Text('Second Floor Content')),
    ),
  ),
  child: ListView.builder(
    itemBuilder: (c, i) => Text('Item $i'),
    itemCount: 20,
    itemExtent: 100,
  ),
)
```

### 5. RefreshStyle Demo

```dart
// Follow (default) - indicator floats behind content
Header: ClassicHeader(refreshStyle: RefreshStyle.Follow)

// UnFollow - indicator stays at top when visible
Header: ClassicHeader(refreshStyle: RefreshStyle.UnFollow)

// Behind - indicator revealed on overscroll
Header: ClassicHeader(refreshStyle: RefreshStyle.Behind)

// Front - indicator overlays content (Android style)
Header: ClassicHeader(refreshStyle: RefreshStyle.Front)
```

### 6. LoadStyle Demo

```dart
// ShowAlways - footer always occupies space
Footer: ClassicFooter(loadStyle: LoadStyle.ShowAlways)

// HideAlways - footer hidden until triggered
Footer: ClassicFooter(loadStyle: LoadStyle.HideAlways)

// ShowWhenLoading - only shows during loading
Footer: ClassicFooter(loadStyle: LoadStyle.ShowWhenLoading)
```

### 7. Global Configuration

Wrap your app with `RefreshConfiguration` for global defaults:

```dart
MaterialApp(
  title: 'My App',
  home: RefreshConfiguration(
    headerBuilder: () => WaterDropHeader(),
    footerBuilder: () => ClassicFooter(),
    headerTriggerDistance: 80.0,
    footerTriggerDistance: 80.0,
    hideFooterWhenNotFull: true,
    maxOverScrollExtent: 100.0,
    springDescription: SpringDescription(mass: 1.0, stiffness: 364.7, damping: 35.2),
    child: MyHomePage(),
  ),
)
```

### 8. NestedScrollView

```dart
NestedScrollView(
  headerSliverBuilder: (context, innerBoxIsScrolled) => [
    SliverAppBar(/* ... */),
  ],
  body: SmartRefresher.builder(
    controller: _controller,
    builder: (context, physics) => ListView.builder(
      physics: physics,
      itemBuilder: (c, i) => Text('Item $i'),
      itemCount: 20,
      itemExtent: 100,
    ),
  ),
)
```

---

## API Reference

### SmartRefresher

The main widget that attaches pull-to-refresh and load-more functionality.

#### Constructor Parameters

| Parameter            | Type                 | Default      | Description                              |
| -------------------- | -------------------- | ------------ | ---------------------------------------- |
| `controller`         | `RefreshController`  | **required** | Controls header and footer state         |
| `child`              | `Widget?`            | `null`       | Refresh content (ScrollView or widget)   |
| `header`             | `Widget?`            | `null`       | Header indicator                         |
| `footer`             | `Widget?`            | `null`       | Footer indicator                         |
| `enablePullDown`     | `bool`               | `true`       | Enable drop-down refresh                 |
| `enablePullUp`       | `bool`               | `false`      | Enable pull-up load                      |
| `enableTwoLevel`     | `bool`               | `false`      | Enable two-level refresh                 |
| `onRefresh`          | `VoidCallback?`      | `null`       | Callback when refresh triggered          |
| `onLoading`          | `VoidCallback?`      | `null`       | Callback when loading triggered          |
| `onTwoLevel`         | `OnTwoLevel?`        | `null`       | Callback when entering/exiting two-level |
| `dragStartBehavior`  | `DragStartBehavior?` | `null`       | ScrollView copy                          |
| `primary`            | `bool?`              | `null`       | ScrollView copy                          |
| `cacheExtent`        | `double?`            | `null`       | ScrollView copy                          |
| `semanticChildCount` | `int?`               | `null`       | ScrollView copy                          |
| `reverse`            | `bool?`              | `null`       | ScrollView copy                          |
| `physics`            | `ScrollPhysics?`     | `null`       | ScrollView copy                          |
| `scrollDirection`    | `Axis?`              | `null`       | ScrollView copy                          |
| `scrollController`   | `ScrollController?`  | `null`       | ScrollView copy                          |

#### SmartRefresher.builder (for NestedScrollView)

| Parameter        | Type                | Default      | Description                                |
| ---------------- | ------------------- | ------------ | ------------------------------------------ |
| `controller`     | `RefreshController` | **required** | Controls state                             |
| `builder`        | `RefresherBuilder`  | **required** | `(BuildContext, RefreshPhysics) => Widget` |
| `enablePullDown` | `bool`              | `true`       | Enable drop-down refresh                   |
| `enablePullUp`   | `bool`              | `false`      | Enable pull-up load                        |
| `enableTwoLevel` | `bool`              | `false`      | Enable two-level refresh                   |
| `onRefresh`      | `VoidCallback?`     | `null`       | Callback when refresh triggered            |
| `onLoading`      | `VoidCallback?`     | `null`       | Callback when loading triggered            |
| `onTwoLevel`     | `OnTwoLevel?`       | `null`       | Callback for two-level                     |

#### Static Methods

```dart
// Find ancestor SmartRefresher
SmartRefresher.of(BuildContext?) → SmartRefresher?

// Find ancestor SmartRefresherState
SmartRefresher.ofState(BuildContext?) → SmartRefresherState?
```

---

### RefreshController

Controls header and footer indicator states.

#### Constructor

```dart
RefreshController({
  bool initialRefresh = false,
  bool autoCleanup = true,
  RefreshStatus? initialRefreshStatus,
  LoadStatus? initialLoadStatus,
})
```

| Parameter              | Type             | Default | Description                  |
| ---------------------- | ---------------- | ------- | ---------------------------- |
| `initialRefresh`       | `bool`           | `false` | Auto-request refresh on init |
| `autoCleanup`          | `bool`           | `true`  | Auto-dispose when destroyed  |
| `initialRefreshStatus` | `RefreshStatus?` | `null`  | Initial header status        |
| `initialLoadStatus`    | `LoadStatus?`    | `null`  | Initial footer status        |

#### Public Properties

| Property             | Type                              | Description                 |
| -------------------- | --------------------------------- | --------------------------- |
| `headerMode`         | `RefreshNotifier<RefreshStatus>?` | Header mode controller      |
| `footerMode`         | `RefreshNotifier<LoadStatus>?`    | Footer mode controller      |
| `headerStatus`       | `RefreshStatus?`                  | Current header status       |
| `footerStatus`       | `LoadStatus?`                     | Current footer status       |
| `isRefresh`          | `bool`                            | `true` if refreshing        |
| `isLoading`          | `bool`                            | `true` if loading           |
| `isTwoLevel`         | `bool`                            | `true` if in two-level mode |
| `headerStatusStream` | `Stream<RefreshStatus?>`          | Header status stream        |
| `footerStatusStream` | `Stream<LoadStatus?>`             | Footer status stream        |

#### Public Methods

| Method                                                                               | Returns         | Description                      |
| ------------------------------------------------------------------------------------ | --------------- | -------------------------------- |
| `requestRefresh({bool needMove, bool needCallback, Duration duration, Curve curve})` | `Future<void>`  | Trigger header refresh           |
| `refreshCompleted({bool resetFooterState})`                                          | `void`          | End refresh with success         |
| `refreshFailed()`                                                                    | `void`          | End refresh with failure         |
| `refreshToIdle()`                                                                    | `void`          | Reset header to idle             |
| `requestTwoLevel({Duration duration, Curve curve})`                                  | `Future<void>`  | Enter two-level mode             |
| `twoLevelComplete({Duration duration, Curve curve})`                                 | `Future<void>?` | Exit two-level mode              |
| `requestLoading({bool needMove, bool needCallback, Duration duration, Curve curve})` | `Future<void>`  | Trigger footer loading           |
| `loadComplete()`                                                                     | `void`          | End loading with success         |
| `loadFailed()`                                                                       | `void`          | End loading with failure         |
| `loadNoData()`                                                                       | `void`          | Set footer to no more data       |
| `resetNoData()`                                                                      | `void`          | Reset footer from noMore to idle |
| `dispose()`                                                                          | `void`          | Dispose resources                |

> **Note:** Do not call `requestRefresh()` or `requestLoading()` before the UI is rendered.

---

### RefreshStatus Enum

Header state values:

| Value             | Description                   |
| ----------------- | ----------------------------- |
| `idle`            | Initial state                 |
| `canRefresh`      | Dragged far enough to refresh |
| `refreshing`      | Refreshing in progress        |
| `completed`       | Refresh completed             |
| `failed`          | Refresh failed                |
| `canTwoLevel`     | Ready to enter two-level      |
| `twoLevelOpening` | Opening two-level             |
| `twoLeveling`     | In two-level mode             |
| `twoLevelClosing` | Closing two-level             |

### LoadStatus Enum

Footer state values:

| Value        | Description                        |
| ------------ | ---------------------------------- |
| `idle`       | Initial state, can trigger loading |
| `canLoading` | Dragged far enough to load         |
| `loading`    | Loading in progress                |
| `noMore`     | No more data to load               |
| `failed`     | Loading failed                     |

---

### RefreshStyle Enum

| Value      | Description                                |
| ---------- | ------------------------------------------ |
| `Follow`   | Indicator floats behind content            |
| `UnFollow` | Indicator stays at top when visible        |
| `Behind`   | Indicator revealed on overscroll           |
| `Front`    | Indicator overlays content (Android style) |

### LoadStyle Enum

| Value             | Description                      |
| ----------------- | -------------------------------- |
| `ShowAlways`      | Footer always occupies space     |
| `HideAlways`      | Footer hidden until triggered    |
| `ShowWhenLoading` | Footer only shows during loading |

---

### Built-in Indicators

#### ClassicHeader

Classic refresh indicator with text and icon.

| Parameter          | Type            | Default               | Description                 |
| ------------------ | --------------- | --------------------- | --------------------------- |
| `refreshStyle`     | `RefreshStyle`  | `RefreshStyle.Follow` | Display style               |
| `height`           | `double`        | `60.0`                | Indicator height            |
| `completeDuration` | `Duration`      | `600ms`               | Complete display duration   |
| `outerBuilder`     | `OuterBuilder?` | `null`                | Custom wrapper              |
| `textStyle`        | `TextStyle`     | `grey`                | Text style                  |
| `releaseText`      | `String?`       | `null`                | "Release to refresh" text   |
| `refreshingText`   | `String?`       | `null`                | "Refreshing..." text        |
| `completeText`     | `String?`       | `null`                | "Refresh completed" text    |
| `failedText`       | `String?`       | `null`                | "Refresh failed" text       |
| `idleText`         | `String?`       | `null`                | "Pull down to refresh" text |
| `iconPos`          | `IconPosition`  | `left`                | Icon position               |
| `spacing`          | `double`        | `15.0`                | Icon-text spacing           |
| `releaseIcon`      | `Widget?`       | `refresh icon`        | Release icon                |
| `refreshingIcon`   | `Widget?`       | `null`                | Refreshing icon             |
| `completeIcon`     | `Widget?`       | `done icon`           | Complete icon               |
| `failedIcon`       | `Widget?`       | `error icon`          | Failed icon                 |
| `idleIcon`         | `Widget?`       | `arrow_down icon`     | Idle icon                   |

#### ClassicFooter

Classic load-more indicator with text and icon.

| Parameter          | Type            | Default                | Description            |
| ------------------ | --------------- | ---------------------- | ---------------------- |
| `loadStyle`        | `LoadStyle`     | `LoadStyle.ShowAlways` | Display style          |
| `height`           | `double`        | `60.0`                 | Indicator height       |
| `onClick`          | `VoidCallback?` | `null`                 | Click callback         |
| `outerBuilder`     | `OuterBuilder?` | `null`                 | Custom wrapper         |
| `textStyle`        | `TextStyle`     | `grey`                 | Text style             |
| `idleText`         | `String?`       | `null`                 | "Pull up to load" text |
| `loadingText`      | `String?`       | `null`                 | "Loading..." text      |
| `noDataText`       | `String?`       | `null`                 | "No more data" text    |
| `failedText`       | `String?`       | `null`                 | "Load failed" text     |
| `canLoadingText`   | `String?`       | `null`                 | "Release to load" text |
| `iconPos`          | `IconPosition`  | `left`                 | Icon position          |
| `spacing`          | `double`        | `15.0`                 | Icon-text spacing      |
| `completeDuration` | `Duration`      | `300ms`                | Complete duration      |
| `idleIcon`         | `Widget?`       | `arrow_up icon`        | Idle icon              |
| `loadingIcon`      | `Widget?`       | `null`                 | Loading icon           |
| `noMoreIcon`       | `Widget?`       | `null`                 | No more icon           |
| `failedIcon`       | `Widget?`       | `error icon`           | Failed icon            |
| `canLoadingIcon`   | `Widget?`       | `autorenew icon`       | Can loading icon       |

#### MaterialClassicHeader

Material-style classic header.

| Parameter         | Type      | Default | Description              |
| ----------------- | --------- | ------- | ------------------------ |
| `height`          | `double`  | `80.0`  | Indicator height         |
| `offset`          | `double`  | `0`     | Offset from top          |
| `distance`        | `double`  | `50.0`  | Distance when refreshing |
| `semanticsLabel`  | `String?` | `null`  | Accessibility label      |
| `semanticsValue`  | `String?` | `null`  | Accessibility value      |
| `color`           | `Color?`  | `null`  | Progress color           |
| `backgroundColor` | `Color?`  | `null`  | Background color         |

#### WaterDropMaterialHeader

Material-style water drop header (extends MaterialClassicHeader).

| Parameter  | Type     | Default | Description      |
| ---------- | -------- | ------- | ---------------- |
| `distance` | `double` | `60.0`  | Refresh distance |
| `color`    | `Color`  | `white` | Water drop color |

#### WaterDropHeader

Animated water drop header.

| Parameter          | Type       | Default          | Description       |
| ------------------ | ---------- | ---------------- | ----------------- |
| `completeDuration` | `Duration` | `600ms`          | Complete duration |
| `refresh`          | `Widget?`  | `null`           | Refreshing widget |
| `complete`         | `Widget?`  | `null`           | Complete widget   |
| `failed`           | `Widget?`  | `null`           | Failed widget     |
| `waterDropColor`   | `Color`    | `grey`           | Water drop color  |
| `idleIcon`         | `Widget`   | `autorenew icon` | Idle icon         |

#### BezierHeader

Bezier curve animated header.

| Parameter             | Type                | Default      | Description             |
| --------------------- | ------------------- | ------------ | ----------------------- |
| `child`               | `Widget`            | `Text("")`   | Content widget          |
| `enableChildOverflow` | `bool`              | `false`      | Allow child overflow    |
| `dismissType`         | `BezierDismissType` | `rectSpread` | Dismiss animation       |
| `rectHeight`          | `double`            | `70`         | Container height        |
| `bezierColor`         | `Color?`            | `null`       | Bezier background color |

#### BezierDismissType Enum

| Value           | Description             |
| --------------- | ----------------------- |
| `none`          | No dismiss animation    |
| `rectSpread`    | Rectangle spread effect |
| `scaleToCenter` | Scale to center effect  |

#### BezierCircleHeader

Circular progress bezier header.

| Parameter             | Type                | Default      | Description          |
| --------------------- | ------------------- | ------------ | -------------------- |
| `bezierColor`         | `Color?`            | `null`       | Background color     |
| `circleType`          | `BezierCircleType`  | `progress`   | Circle style         |
| `rectHeight`          | `double`            | `70`         | Container height     |
| `circleColor`         | `Color`             | `white`      | Circle color         |
| `circleRadius`        | `double`            | `12`         | Circle radius        |
| `enableChildOverflow` | `bool`              | `false`      | Allow child overflow |
| `dismissType`         | `BezierDismissType` | `rectSpread` | Dismiss animation    |

#### BezierCircleType Enum

| Value      | Description        |
| ---------- | ------------------ |
| `progress` | Progress indicator |
| `raidal`   | Radial indicator   |

#### TwoLevelHeader

Header for two-level refresh functionality.

| Parameter          | Type                       | Default           | Description              |
| ------------------ | -------------------------- | ----------------- | ------------------------ |
| `height`           | `double`                   | `80.0`            | Indicator height         |
| `decoration`       | `BoxDecoration?`           | `null`            | Background decoration    |
| `displayAlignment` | `TwoLevelDisplayAlignment` | `fromBottom`      | Alignment mode           |
| `completeDuration` | `Duration`                 | `600ms`           | Complete duration        |
| `textStyle`        | `TextStyle`                | `grey`            | Text style               |
| `spacing`          | `double`                   | `15.0`            | Icon-text spacing        |
| `iconPos`          | `IconPosition`             | `left`            | Icon position            |
| `releaseText`      | `String?`                  | `null`            | Release text             |
| `refreshingText`   | `String?`                  | `null`            | Refreshing text          |
| `completeText`     | `String?`                  | `null`            | Complete text            |
| `failedText`       | `String?`                  | `null`            | Failed text              |
| `idleText`         | `String?`                  | `null`            | Idle text                |
| `releaseIcon`      | `Widget?`                  | `refresh icon`    | Release icon             |
| `refreshingIcon`   | `Widget?`                  | `null`            | Refreshing icon          |
| `completeIcon`     | `Widget?`                  | `done icon`       | Complete icon            |
| `failedIcon`       | `Widget?`                  | `error icon`      | Failed icon              |
| `idleIcon`         | `Widget?`                  | `arrow_down icon` | Idle icon                |
| `twoLevelWidget`   | `Widget?`                  | `null`            | Custom two-level content |

#### TwoLevelDisplayAlignment Enum

| Value        | Description                  |
| ------------ | ---------------------------- |
| `fromTop`    | Use with RefreshStyle.Behind |
| `fromBottom` | Use with RefreshStyle.Follow |
| `fromCenter` | Use with RefreshStyle.Follow |

#### CustomHeader / CustomFooter

Build your own indicators with callbacks.

```dart
CustomHeader(
  builder: (context, mode) => /* your widget */,
  height: 60.0,
  refreshStyle: RefreshStyle.Follow,
)

// Callback parameters:
typedef HeaderBuilder = Widget Function(BuildContext context, RefreshStatus? mode);
typedef FooterBuilder = Widget Function(BuildContext context, LoadStatus? mode);
typedef OffsetCallBack = void Function(double offset);
typedef ModeChangeCallBack<T> = void Function(T? mode);
typedef VoidFutureCallBack = Future<void> Function();
```

#### LinkHeader / LinkFooter

Link to an external header/footer outside the viewport.

```dart
LinkHeader(
  linkKey: _globalKey,  // GlobalKey pointing to external widget
  height: 60.0,
  refreshStyle: RefreshStyle.Follow,
)
```

---

### RefreshConfiguration

Global configuration for all SmartRefresher widgets in a subtree.

```dart
RefreshConfiguration(
  child: MaterialApp(
    home: MyApp(),
  ),
  // Configuration parameters...
)
```

#### Configuration Parameters

| Parameter                          | Type                   | Default                                 | Description                  |
| ---------------------------------- | ---------------------- | --------------------------------------- | ---------------------------- |
| `child`                            | `Widget`               | **required**                            | Child widget                 |
| `headerBuilder`                    | `IndicatorBuilder?`    | `null`                                  | Default header builder       |
| `footerBuilder`                    | `IndicatorBuilder?`    | `null`                                  | Default footer builder       |
| `dragSpeedRatio`                   | `double`               | `1.0`                                   | Drag speed ratio             |
| `springDescription`                | `SpringDescription`    | `mass:1, stiffness:364.7, damping:35.2` | Spring animation             |
| `skipCanRefresh`                   | `bool`                 | `false`                                 | Skip canRefresh state        |
| `shouldFooterFollowWhenNotFull`    | `ShouldFollowContent?` | `null`                                  | Footer follow callback       |
| `hideFooterWhenNotFull`            | `bool`                 | `false`                                 | Hide footer when not full    |
| `enableScrollWhenTwoLevel`         | `bool`                 | `true`                                  | Allow scroll in two-level    |
| `enableScrollWhenRefreshCompleted` | `bool`                 | `false`                                 | Allow scroll on complete     |
| `enableBallisticRefresh`           | `bool`                 | `false`                                 | Trigger by ballistic scroll  |
| `enableBallisticLoad`              | `bool`                 | `true`                                  | Trigger loading by ballistic |
| `enableLoadingWhenFailed`          | `bool`                 | `true`                                  | Allow loading when failed    |
| `enableLoadingWhenNoData`          | `bool`                 | `false`                                 | Allow loading when noMore    |
| `headerTriggerDistance`            | `double`               | `80.0`                                  | Refresh trigger distance     |
| `twiceTriggerDistance`             | `double`               | `150.0`                                 | Two-level trigger distance   |
| `closeTwoLevelDistance`            | `double`               | `80.0`                                  | Close two-level distance     |
| `footerTriggerDistance`            | `double`               | `15.0`                                  | Loading trigger distance     |
| `maxOverScrollExtent`              | `double?`              | `null`                                  | Max overscroll distance      |
| `maxUnderScrollExtent`             | `double?`              | `null`                                  | Max underscroll distance     |
| `topHitBoundary`                   | `double?`              | `null`                                  | Top boundary                 |
| `bottomHitBoundary`                | `double?`              | `null`                                  | Bottom boundary              |
| `enableRefreshVibrate`             | `bool`                 | `false`                                 | Vibrate on refresh           |
| `enableLoadMoreVibrate`            | `bool`                 | `false`                                 | Vibrate on load more         |

---

### Internationalization

flutter_smart_refresh includes built-in localization for 15+ languages.

```dart
MaterialApp(
  localizationsDelegates: RefreshLocalizations.delegates,
  supportedLocales: [
    Locale('en'),
    Locale('zh'),
    // Add more locales
  ],
  home: MyApp(),
)
```

To add a custom language:

```dart
class XXRefreshString implements RefreshString {
  @override
  String? idleRefreshText = "...";
  // Implement all 10 string properties
}

// Add to RefreshLocalizations.values map
```

---

## License

MIT License

Copyright (c) 2024 flutter_smart_refresh contributors  
Based on [peng8350/flutter_pulltorefresh](https://github.com/peng8350/flutter_pulltorefresh) (unmaintained)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
