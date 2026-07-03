# flutter_smart_refresh

[![Pub Version](https://img.shields.io/pub/v/flutter_smart_refresh)](https://pub.dev/packages/flutter_smart_refresh)
[![Dart SDK](https://img.shields.io/badge/dart-%5E3.12.0-blue)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## ⚠️ Fork 说明

> **本项目是基于 [peng8350/flutter_pulltorefresh](https://github.com/peng8350/flutter_pulltorefresh) 的社区维护分支。**

原始库**已停止维护**。本分支修复了以下关键问题：

- ✅ 完全符合 Dart 3.12+ 空安全规范
- ✅ Bug 修复（空检查操作符、dispose 问题等）
- ✅ 保持 API 兼容性

**原始作者：** [peng8350](https://github.com/peng8350)  
**原始仓库：** [peng8350/flutter_pulltorefresh](https://github.com/peng8350/flutter_pulltorefresh)（已停止维护）

---

## 特性

- 🛡️ **完全空安全** 支持 Dart 3.12+
- 📦 **8+ 内置指示器组件**（Classic、Material、Bezier、WaterDrop、TwoLevel 等）
- 🎮 **灵活的 RefreshController 状态管理**
- 🎨 **4 种 RefreshStyle 模式**：Follow、UnFollow、Behind、Front
- 📋 **3 种 LoadStyle 模式**：ShowAlways、HideAlways、ShowWhenLoading
- 🏠 **二级刷新（二楼）** 支持
- ⚙️ **全局配置** via RefreshConfiguration
- 🌍 **国际化支持**（内置 15+ 语言）
- 🔧 **物理特性自定义**（弹簧、拖拽速度、越界限制）
- 📳 **NestedScrollView 支持**

---

## 安装

将 `flutter_smart_refresh` 添加到 `pubspec.yaml`：

```yaml
dependencies:
  flutter_smart_refresh: ^3.0.0
```

然后运行：

```bash
flutter pub get
```

---

## 快速开始

```dart
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';

// 1. 创建 RefreshController
final RefreshController _controller = RefreshController();

// 2. 使用 SmartRefresher
SmartRefresher(
  controller: _controller,
  enablePullDown: true,
  enablePullUp: true,
  onRefresh: () async {
    // 获取数据
    await fetchData();
    // 结束刷新
    _controller.refreshCompleted();
    // 或: _controller.refreshFailed();
  },
  onLoading: () async {
    // 加载更多数据
    await loadMoreData();
    if (noMoreData) {
      _controller.loadNoData();
    } else {
      _controller.loadComplete();
      // 或: _controller.loadFailed();
    }
  },
  header: ClassicHeader(),
  footer: ClassicFooter(),
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => ListTile(title: Text(items[index])),
  ),
)

// 3. 别忘了 dispose
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

---

## 示例

### 1. 基础下拉刷新

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

### 2. 上拉加载更多

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

### 3. 自定义 Header

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
          return Text('刷新完成');
        case RefreshStatus.failed:
          return Text('刷新失败');
        default:
          return Text('下拉刷新');
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

### 4. 二级刷新（二楼）

```dart
SmartRefresher(
  controller: _controller,
  enableTwoLevel: true,
  onTwoLevel: (isOpen) {
    if (isOpen) {
      // 用户打开二级，刷新技术内容
      Future.delayed(Duration(seconds: 2), () {
        _controller.twoLevelComplete();
      });
    }
  },
  header: TwoLevelHeader(
    twoLevelWidget: Container(
      color: Colors.blue,
      child: Center(child: Text('第二层内容')),
    ),
  ),
  child: ListView.builder(
    itemBuilder: (c, i) => Text('Item $i'),
    itemCount: 20,
    itemExtent: 100,
  ),
)
```

### 5. RefreshStyle 示例

```dart
// Follow (默认) - 指示器浮动在内容后方
Header: ClassicHeader(refreshStyle: RefreshStyle.Follow)

// UnFollow - 指示器可见时停在顶部
Header: ClassicHeader(refreshStyle: RefreshStyle.UnFollow)

// Behind - 越界时显示指示器
Header: ClassicHeader(refreshStyle: RefreshStyle.Behind)

// Front - 指示器覆盖在内容上方 (Android 风格)
Header: ClassicHeader(refreshStyle: RefreshStyle.Front)
```

### 6. LoadStyle 示例

```dart
// ShowAlways - Footer 始终占据空间
Footer: ClassicFooter(loadStyle: LoadStyle.ShowAlways)

// HideAlways - Footer 在触发前隐藏
Footer: ClassicFooter(loadStyle: LoadStyle.HideAlways)

// ShowWhenLoading - 仅在加载时显示
Footer: ClassicFooter(loadStyle: LoadStyle.ShowWhenLoading)
```

### 7. 全局配置

使用 `RefreshConfiguration` 包装应用以设置全局默认值：

```dart
MaterialApp(
  title: '我的应用',
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

## API 参考

### SmartRefresher

提供下拉刷新和上拉加载功能的主要组件。

#### 构造函数参数

| 参数                 | 类型                 | 默认值   | 说明                            |
| -------------------- | -------------------- | -------- | ------------------------------- |
| `controller`         | `RefreshController`  | **必填** | 控制 header 和 footer 状态      |
| `child`              | `Widget?`            | `null`   | 刷新内容 (ScrollView 或 widget) |
| `header`             | `Widget?`            | `null`   | Header 指示器                   |
| `footer`             | `Widget?`            | `null`   | Footer 指示器                   |
| `enablePullDown`     | `bool`               | `true`   | 启用下拉刷新                    |
| `enablePullUp`       | `bool`               | `false`  | 启用上拉加载                    |
| `enableTwoLevel`     | `bool`               | `false`  | 启用二级刷新                    |
| `onRefresh`          | `VoidCallback?`      | `null`   | 刷新触发回调                    |
| `onLoading`          | `VoidCallback?`      | `null`   | 加载触发回调                    |
| `onTwoLevel`         | `OnTwoLevel?`        | `null`   | 进入/退出二级回调               |
| `dragStartBehavior`  | `DragStartBehavior?` | `null`   | ScrollView 属性复制             |
| `primary`            | `bool?`              | `null`   | ScrollView 属性复制             |
| `cacheExtent`        | `double?`            | `null`   | ScrollView 属性复制             |
| `semanticChildCount` | `int?`               | `null`   | ScrollView 属性复制             |
| `reverse`            | `bool?`              | `null`   | ScrollView 属性复制             |
| `physics`            | `ScrollPhysics?`     | `null`   | ScrollView 属性复制             |
| `scrollDirection`    | `Axis?`              | `null`   | ScrollView 属性复制             |
| `scrollController`   | `ScrollController?`  | `null`   | ScrollView 属性复制             |

#### SmartRefresher.builder (用于 NestedScrollView)

| 参数             | 类型                | 默认值   | 说明                                       |
| ---------------- | ------------------- | -------- | ------------------------------------------ |
| `controller`     | `RefreshController` | **必填** | 控制状态                                   |
| `builder`        | `RefresherBuilder`  | **必填** | `(BuildContext, RefreshPhysics) => Widget` |
| `enablePullDown` | `bool`              | `true`   | 启用下拉刷新                               |
| `enablePullUp`   | `bool`              | `false`  | 启用上拉加载                               |
| `enableTwoLevel` | `bool`              | `false`  | 启用二级刷新                               |
| `onRefresh`      | `VoidCallback?`     | `null`   | 刷新触发回调                               |
| `onLoading`      | `VoidCallback?`     | `null`   | 加载触发回调                               |
| `onTwoLevel`     | `OnTwoLevel?`       | `null`   | 二级回调                                   |

#### 静态方法

```dart
// 查找祖先 SmartRefresher
SmartRefresher.of(BuildContext?) → SmartRefresher?

// 查找祖先 SmartRefresherState
SmartRefresher.ofState(BuildContext?) → SmartRefresherState?
```

---

### RefreshController

控制 header 和 footer 指示器状态。

#### 构造函数

```dart
RefreshController({
  bool initialRefresh = false,
  bool autoCleanup = true,
  RefreshStatus? initialRefreshStatus,
  LoadStatus? initialLoadStatus,
})
```

| 参数                   | 类型             | 默认值  | 说明             |
| ---------------------- | ---------------- | ------- | ---------------- |
| `initialRefresh`       | `bool`           | `false` | 初始化时自动刷新 |
| `autoCleanup`          | `bool`           | `true`  | 销毁时自动释放   |
| `initialRefreshStatus` | `RefreshStatus?` | `null`  | 初始 header 状态 |
| `initialLoadStatus`    | `LoadStatus?`    | `null`  | 初始 footer 状态 |

#### 公共属性

| 属性                 | 类型                              | 说明              |
| -------------------- | --------------------------------- | ----------------- |
| `headerMode`         | `RefreshNotifier<RefreshStatus>?` | Header 模式控制器 |
| `footerMode`         | `RefreshNotifier<LoadStatus>?`    | Footer 模式控制器 |
| `headerStatus`       | `RefreshStatus?`                  | 当前 header 状态  |
| `footerStatus`       | `LoadStatus?`                     | 当前 footer 状态  |
| `isRefresh`          | `bool`                            | 是否正在刷新      |
| `isLoading`          | `bool`                            | 是否正在加载      |
| `isTwoLevel`         | `bool`                            | 是否在二级模式    |
| `headerStatusStream` | `Stream<RefreshStatus?>`          | Header 状态流     |
| `footerStatusStream` | `Stream<LoadStatus?>`             | Footer 状态流     |

#### 公共方法

| 方法                                                                                 | 返回值          | 说明                          |
| ------------------------------------------------------------------------------------ | --------------- | ----------------------------- |
| `requestRefresh({bool needMove, bool needCallback, Duration duration, Curve curve})` | `Future<void>`  | 触发 header 刷新              |
| `refreshCompleted({bool resetFooterState})`                                          | `void`          | 结束刷新（成功）              |
| `refreshFailed()`                                                                    | `void`          | 结束刷新（失败）              |
| `refreshToIdle()`                                                                    | `void`          | 重置 header 为 idle           |
| `requestTwoLevel({Duration duration, Curve curve})`                                  | `Future<void>`  | 进入二级模式                  |
| `twoLevelComplete({Duration duration, Curve curve})`                                 | `Future<void>?` | 退出二级模式                  |
| `requestLoading({bool needMove, bool needCallback, Duration duration, Curve curve})` | `Future<void>`  | 触发 footer 加载              |
| `loadComplete()`                                                                     | `void`          | 结束加载（成功）              |
| `loadFailed()`                                                                       | `void`          | 结束加载（失败）              |
| `loadNoData()`                                                                       | `void`          | 设置 footer 为无更多数据      |
| `resetNoData()`                                                                      | `void`          | 重置 footer 从 noMore 到 idle |
| `dispose()`                                                                          | `void`          | 释放资源                      |

> **注意：** 请勿在 UI 渲染完成前调用 `requestRefresh()` 或 `requestLoading()`。

---

### RefreshStatus 枚举

Header 状态值：

| 值                | 说明                 |
| ----------------- | -------------------- |
| `idle`            | 初始状态             |
| `canRefresh`      | 拖动足够远，可以刷新 |
| `refreshing`      | 正在刷新             |
| `completed`       | 刷新完成             |
| `failed`          | 刷新失败             |
| `canTwoLevel`     | 可以进入二级         |
| `twoLevelOpening` | 正在打开二级         |
| `twoLeveling`     | 在二级模式中         |
| `twoLevelClosing` | 正在关闭二级         |

### LoadStatus 枚举

Footer 状态值：

| 值           | 说明                   |
| ------------ | ---------------------- |
| `idle`       | 初始状态，可以触发加载 |
| `canLoading` | 拖动足够远，可以加载   |
| `loading`    | 正在加载               |
| `noMore`     | 没有更多数据           |
| `failed`     | 加载失败               |

---

### RefreshStyle 枚举

| 值         | 说明                                |
| ---------- | ----------------------------------- |
| `Follow`   | 指示器浮动在内容后方                |
| `UnFollow` | 指示器可见时停在顶部                |
| `Behind`   | 越界时显示指示器                    |
| `Front`    | 指示器覆盖在内容上方 (Android 风格) |

### LoadStyle 枚举

| 值                | 说明                  |
| ----------------- | --------------------- |
| `ShowAlways`      | Footer 始终占据空间   |
| `HideAlways`      | Footer 在触发前隐藏   |
| `ShowWhenLoading` | Footer 仅在加载时显示 |

---

### 内置指示器

#### ClassicHeader

带文字和图标的标准刷新指示器。

| 参数               | 类型            | 默认值                | 说明                |
| ------------------ | --------------- | --------------------- | ------------------- |
| `refreshStyle`     | `RefreshStyle`  | `RefreshStyle.Follow` | 显示样式            |
| `height`           | `double`        | `60.0`                | 指示器高度          |
| `completeDuration` | `Duration`      | `600ms`               | 完成显示时长        |
| `outerBuilder`     | `OuterBuilder?` | `null`                | 自定义包装器        |
| `textStyle`        | `TextStyle`     | `灰色`                | 文字样式            |
| `releaseText`      | `String?`       | `null`                | "释放开始刷新" 文字 |
| `refreshingText`   | `String?`       | `null`                | "刷新中..." 文字    |
| `completeText`     | `String?`       | `null`                | "刷新完成" 文字     |
| `failedText`       | `String?`       | `null`                | "刷新失败" 文字     |
| `idleText`         | `String?`       | `null`                | "下拉刷新" 文字     |
| `iconPos`          | `IconPosition`  | `left`                | 图标位置            |
| `spacing`          | `double`        | `15.0`                | 图标文字间距        |
| `releaseIcon`      | `Widget?`       | `refresh 图标`        | 释放状态图标        |
| `refreshingIcon`   | `Widget?`       | `null`                | 刷新状态图标        |
| `completeIcon`     | `Widget?`       | `done 图标`           | 完成状态图标        |
| `failedIcon`       | `Widget?`       | `error 图标`          | 失败状态图标        |
| `idleIcon`         | `Widget?`       | `arrow_down 图标`     | 空闲状态图标        |

#### ClassicFooter

带文字和图标的标准加载更多指示器。

| 参数               | 类型            | 默认值                 | 说明                |
| ------------------ | --------------- | ---------------------- | ------------------- |
| `loadStyle`        | `LoadStyle`     | `LoadStyle.ShowAlways` | 显示样式            |
| `height`           | `double`        | `60.0`                 | 指示器高度          |
| `onClick`          | `VoidCallback?` | `null`                 | 点击回调            |
| `outerBuilder`     | `OuterBuilder?` | `null`                 | 自定义包装器        |
| `textStyle`        | `TextStyle`     | `灰色`                 | 文字样式            |
| `idleText`         | `String?`       | `null`                 | "上拉加载" 文字     |
| `loadingText`      | `String?`       | `null`                 | "加载中..." 文字    |
| `noDataText`       | `String?`       | `null`                 | "没有更多数据" 文字 |
| `failedText`       | `String?`       | `null`                 | "加载失败" 文字     |
| `canLoadingText`   | `String?`       | `null`                 | "释放加载" 文字     |
| `iconPos`          | `IconPosition`  | `left`                 | 图标位置            |
| `spacing`          | `double`        | `15.0`                 | 图标文字间距        |
| `completeDuration` | `Duration`      | `300ms`                | 完成显示时长        |
| `idleIcon`         | `Widget?`       | `arrow_up 图标`        | 空闲状态图标        |
| `loadingIcon`      | `Widget?`       | `null`                 | 加载状态图标        |
| `noMoreIcon`       | `Widget?`       | `null`                 | 无更多数据图标      |
| `failedIcon`       | `Widget?`       | `error 图标`           | 失败状态图标        |
| `canLoadingIcon`   | `Widget?`       | `autorenew 图标`       | 可加载状态图标      |

#### MaterialClassicHeader

Material 风格经典 Header。

| 参数              | 类型      | 默认值 | 说明       |
| ----------------- | --------- | ------ | ---------- |
| `height`          | `double`  | `80.0` | 指示器高度 |
| `offset`          | `double`  | `0`    | 距顶部偏移 |
| `distance`        | `double`  | `50.0` | 刷新时距离 |
| `semanticsLabel`  | `String?` | `null` | 无障碍标签 |
| `semanticsValue`  | `String?` | `null` | 无障碍值   |
| `color`           | `Color?`  | `null` | 进度条颜色 |
| `backgroundColor` | `Color?`  | `null` | 背景颜色   |

#### WaterDropMaterialHeader

Material 风格水滴 Header（继承自 MaterialClassicHeader）。

| 参数       | 类型     | 默认值 | 说明     |
| ---------- | -------- | ------ | -------- |
| `distance` | `double` | `60.0` | 刷新距离 |
| `color`    | `Color`  | `白色` | 水滴颜色 |

#### WaterDropHeader

动画水滴 Header。

| 参数               | 类型       | 默认值           | 说明         |
| ------------------ | ---------- | ---------------- | ------------ |
| `completeDuration` | `Duration` | `600ms`          | 完成显示时长 |
| `refresh`          | `Widget?`  | `null`           | 刷新中组件   |
| `complete`         | `Widget?`  | `null`           | 完成组件     |
| `failed`           | `Widget?`  | `null`           | 失败组件     |
| `waterDropColor`   | `Color`    | `灰色`           | 水滴颜色     |
| `idleIcon`         | `Widget`   | `autorenew 图标` | 空闲状态图标 |

#### BezierHeader

贝塞尔曲线动画 Header。

| 参数                  | 类型                | 默认值       | 说明           |
| --------------------- | ------------------- | ------------ | -------------- |
| `child`               | `Widget`            | `Text("")`   | 内容组件       |
| `enableChildOverflow` | `bool`              | `false`      | 允许子组件溢出 |
| `dismissType`         | `BezierDismissType` | `rectSpread` | 消失动画类型   |
| `rectHeight`          | `double`            | `70`         | 容器高度       |
| `bezierColor`         | `Color?`            | `null`       | 贝塞尔背景色   |

#### BezierDismissType 枚举

| 值              | 说明           |
| --------------- | -------------- |
| `none`          | 无消失动画     |
| `rectSpread`    | 矩形扩散效果   |
| `scaleToCenter` | 缩放到中心效果 |

#### BezierCircleHeader

圆形进度贝塞尔 Header。

| 参数                  | 类型                | 默认值       | 说明           |
| --------------------- | ------------------- | ------------ | -------------- |
| `bezierColor`         | `Color?`            | `null`       | 背景颜色       |
| `circleType`          | `BezierCircleType`  | `progress`   | 圆形样式       |
| `rectHeight`          | `double`            | `70`         | 容器高度       |
| `circleColor`         | `Color`             | `白色`       | 圆形颜色       |
| `circleRadius`        | `double`            | `12`         | 圆形半径       |
| `enableChildOverflow` | `bool`              | `false`      | 允许子组件溢出 |
| `dismissType`         | `BezierDismissType` | `rectSpread` | 消失动画类型   |

#### BezierCircleType 枚举

| 值         | 说明         |
| ---------- | ------------ |
| `progress` | 进度指示器   |
| `raidal`   | 放射性指示器 |

#### TwoLevelHeader

用于二级刷新功能的 Header。

| 参数               | 类型                       | 默认值            | 说明           |
| ------------------ | -------------------------- | ----------------- | -------------- |
| `height`           | `double`                   | `80.0`            | 指示器高度     |
| `decoration`       | `BoxDecoration?`           | `null`            | 背景装饰       |
| `displayAlignment` | `TwoLevelDisplayAlignment` | `fromBottom`      | 对齐模式       |
| `completeDuration` | `Duration`                 | `600ms`           | 完成显示时长   |
| `textStyle`        | `TextStyle`                | `灰色`            | 文字样式       |
| `spacing`          | `double`                   | `15.0`            | 图标文字间距   |
| `iconPos`          | `IconPosition`             | `left`            | 图标位置       |
| `releaseText`      | `String?`                  | `null`            | 释放文字       |
| `refreshingText`   | `String?`                  | `null`            | 刷新中文字     |
| `completeText`     | `String?`                  | `null`            | 完成文字       |
| `failedText`       | `String?`                  | `null`            | 失败文字       |
| `idleText`         | `String?`                  | `null`            | 空闲文字       |
| `releaseIcon`      | `Widget?`                  | `refresh 图标`    | 释放状态图标   |
| `refreshingIcon`   | `Widget?`                  | `null`            | 刷新状态图标   |
| `completeIcon`     | `Widget?`                  | `done 图标`       | 完成状态图标   |
| `failedIcon`       | `Widget?`                  | `error 图标`      | 失败状态图标   |
| `idleIcon`         | `Widget?`                  | `arrow_down 图标` | 空闲状态图标   |
| `twoLevelWidget`   | `Widget?`                  | `null`            | 自定义二级内容 |

#### TwoLevelDisplayAlignment 枚举

| 值           | 说明                            |
| ------------ | ------------------------------- |
| `fromTop`    | 与 RefreshStyle.Behind 配合使用 |
| `fromBottom` | 与 RefreshStyle.Follow 配合使用 |
| `fromCenter` | 与 RefreshStyle.Follow 配合使用 |

#### CustomHeader / CustomFooter

使用回调构建自定义指示器。

```dart
CustomHeader(
  builder: (context, mode) => /* 你的组件 */,
  height: 60.0,
  refreshStyle: RefreshStyle.Follow,
)

// 回调参数类型:
typedef HeaderBuilder = Widget Function(BuildContext context, RefreshStatus? mode);
typedef FooterBuilder = Widget Function(BuildContext context, LoadStatus? mode);
typedef OffsetCallBack = void Function(double offset);
typedef ModeChangeCallBack<T> = void Function(T? mode);
typedef VoidFutureCallBack = Future<void> Function();
```

#### LinkHeader / LinkFooter

链接到视口外部的 header/footer。

```dart
LinkHeader(
  linkKey: _globalKey,  // 指向外部组件的 GlobalKey
  height: 60.0,
  refreshStyle: RefreshStyle.Follow,
)
```

---

### RefreshConfiguration

为子树中的所有 SmartRefresher 组件提供全局配置。

```dart
RefreshConfiguration(
  child: MaterialApp(
    home: MyApp(),
  ),
  // 配置参数...
)
```

#### 配置参数

| 参数                               | 类型                   | 默认值                                  | 说明                  |
| ---------------------------------- | ---------------------- | --------------------------------------- | --------------------- |
| `child`                            | `Widget`               | **必填**                                | 子组件                |
| `headerBuilder`                    | `IndicatorBuilder?`    | `null`                                  | 默认 header 构建器    |
| `footerBuilder`                    | `IndicatorBuilder?`    | `null`                                  | 默认 footer 构建器    |
| `dragSpeedRatio`                   | `double`               | `1.0`                                   | 拖拽速度比例          |
| `springDescription`                | `SpringDescription`    | `mass:1, stiffness:364.7, damping:35.2` | 弹簧动画配置          |
| `skipCanRefresh`                   | `bool`                 | `false`                                 | 跳过 canRefresh 状态  |
| `shouldFooterFollowWhenNotFull`    | `ShouldFollowContent?` | `null`                                  | Footer 跟随内容回调   |
| `hideFooterWhenNotFull`            | `bool`                 | `false`                                 | 内容不满时隐藏 footer |
| `enableScrollWhenTwoLevel`         | `bool`                 | `true`                                  | 二级模式下允许滚动    |
| `enableScrollWhenRefreshCompleted` | `bool`                 | `false`                                 | 刷新完成时允许滚动    |
| `enableBallisticRefresh`           | `bool`                 | `false`                                 | 通过弹跳滚动触发刷新  |
| `enableBallisticLoad`              | `bool`                 | `true`                                  | 通过弹跳滚动触发加载  |
| `enableLoadingWhenFailed`          | `bool`                 | `true`                                  | 失败时允许加载        |
| `enableLoadingWhenNoData`          | `bool`                 | `false`                                 | 无数据时允许加载      |
| `headerTriggerDistance`            | `double`               | `80.0`                                  | 刷新触发距离          |
| `twiceTriggerDistance`             | `double`               | `150.0`                                 | 二级触发距离          |
| `closeTwoLevelDistance`            | `double`               | `80.0`                                  | 关闭二级距离          |
| `footerTriggerDistance`            | `double`               | `15.0`                                  | 加载触发距离          |
| `maxOverScrollExtent`              | `double?`              | `null`                                  | 最大越界距离          |
| `maxUnderScrollExtent`             | `double?`              | `null`                                  | 最大反向越界距离      |
| `topHitBoundary`                   | `double?`              | `null`                                  | 顶部边界              |
| `bottomHitBoundary`                | `double?`              | `null`                                  | 底部边界              |
| `enableRefreshVibrate`             | `bool`                 | `false`                                 | 刷新时振动            |
| `enableLoadMoreVibrate`            | `bool`                 | `false`                                 | 加载更多时振动        |

---

### 国际化

flutter_smart_refresh 内置支持 15+ 种语言。

```dart
MaterialApp(
  localizationsDelegates: RefreshLocalizations.delegates,
  supportedLocales: [
    Locale('en'),
    Locale('zh'),
    // 添加更多语言
  ],
  home: MyApp(),
)
```

添加自定义语言：

```dart
class XXRefreshString implements RefreshString {
  @override
  String? idleRefreshText = "...";
  // 实现所有 10 个字符串属性
}

// 添加到 RefreshLocalizations.values map
```

---

## 开源协议

MIT License

版权所有 (c) 2024 flutter_smart_refresh 贡献者  
基于 [peng8350/flutter_pulltorefresh](https://github.com/peng8350/flutter_pulltorefresh)（已停止维护）

特此免费授予获得本软件及相关文档文件（"软件"）副本的任何人不受限制地处理本软件的权利，包括但不限于使用、复制、修改、合并、发布、分发、再许可和/或出售本软件副本的权利，并允许获得本软件的人这样做，但须遵守以下条件：

上述版权声明和本许可声明应包含在本软件的所有副本或主要部分中。

本软件按"原样"提供，不提供任何明示或暗示的保证，包括但不限于对适销性、特定用途适用性和非侵权性的保证。在任何情况下，作者或版权持有人均不对因本软件或使用或与本软件相关的其他交易而产生的任何索赔、损害或其他责任负责，无论是在合同诉讼、侵权诉讼或其他诉讼中。
