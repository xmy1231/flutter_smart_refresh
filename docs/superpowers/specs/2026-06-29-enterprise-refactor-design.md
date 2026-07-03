# SmartRefresher 企业级重构设计文档

> **Version:** 3.0.0 (breaking change)
> **Date:** 2026-06-29
> **Target:** flutter_smart_refresh / flutter_smart_refresh v2.0.3 → v3.0.0

---

## 1. 背景与目标

### 现状分析
- v2.0.3 存在 **15+ identified bugs**，涵盖 crash、边界 case、技术债务
- `RefreshController` 单例约束导致 TabBarView/PageView 场景不稳定
- `runtimeType` workaround 依赖 Flutter 内部行为，升级后可能 break
- `copyAncestor` 模式脆弱，新增 property 易遗漏
- Indicator 生命周期管理不完整，部分动画未正确 dispose

### 重构目标
1. **稳定性**：消除所有 identified crash 和边界 case
2. **可维护性**：解决技术债务，降低未来开发风险
3. **扩展性**：改善 API 设计，便于 future feature
4. **兼容性**：为 Flutter 3.x+ 和未来版本做好准备

---

## 2. 核心原则

- **Minimal breaking change**：仅必要处做破坏性变更，提供 migration guide
- **Zero crash policy**：所有已知 crash 必须修复
- **Test coverage > 80%**：所有 public API 必须有测试
- **No internal Flutter API reliance**：移除 `runtimeType` workaround

---

## 3. 破坏性变更清单

### BC1: `RefreshController` 重构

**变更：**
- `RefreshController` 不再强制单例，改为多实例支持
- 每个 `SmartRefresher` 独立 `RefreshController`，内部自动绑定
- `controller` 参数从 required 改为 optional（SmartRefresher 内部创建）
- `RefreshController.of(context)` 方法替代全局 find

**Migration：**
```dart
// Before (v2.x)
final controller = RefreshController();
SmartRefresher(
  controller: controller,  // required
  ...
)

// After (v3.0)
SmartRefresher(
  controller: RefreshController(autoCleanup: true),  // optional, internal creation
  ...
)
// 或显式创建
final controller = RefreshController();
SmartRefresher(controller: controller, ...);
```

### BC2: `RefreshConfiguration.copyAncestor()` 重构

**变更：**
- 移除手动 copy 模式，改为 `copyWith` chain
- 新增 `RefreshConfiguration.child` 必需（替代 null child 处理）

**Migration：**
```dart
// Before (v2.x)
RefreshConfiguration.copyAncestor(
  context: context,
  headerBuilder: () => WaterDropHeader(),
  ...
)

// After (v3.0)
RefreshConfiguration.of(context)?.copyWith(
  headerBuilder: () => WaterDropHeader(),
) ?? RefreshConfiguration(
  headerBuilder: () => WaterDropHeader(),
  child: child,
);
```

### BC3: `RefreshPhysics` 重构

**变更：**
- 移除 `runtimeType` workaround
- 使用 `ScrollPhysics.createDelegate()` 模式

### BC4: Indicator 生命周期

**变更：**
- `RefreshIndicator` / `LoadIndicator` 基类添加 `void dispose()`
- 所有子类实现正确 dispose
- `IndicatorStateMixin` 添加 `onDispose` callback

### BC5: `LinkHeader` / `LinkFooter` 安全增强

**变更：**
- 所有 `linkKey.currentState` 调用前添加 null check
- 失败时优雅降级（不 crash）

---

## 4. 问题修复详细方案

### F1: LinkHeader null check crash（`link_indicator.dart:28`）
```dart
// Before
((widget.linkKey as GlobalKey).currentState as RefreshProcessor).resetValue();

// After
final state = widget.linkKey.currentState;
if (state is RefreshProcessor) {
  state.resetValue();
}
// 添加 warn log 如果 state == null
```

### F2: CustomFooter unsafe cast（`custom_indicator.dart:160`）
```dart
// Before
onClick as void Function()?,

// After
// 移除 cast，改为 VoidCallback? 类型，直接赋值
final void Function()? clickCallback;
if (widget.onClick is void Function()?) {
  clickCallback = widget.onClick as void Function()?;
}
```

### F3: ClassicHeader._buildIcon duplicate case（`classic_indicator.dart:110-113`）
```dart
// Before (has canTwoLevel twice in switch)
case RefreshStatus.canTwoLevel:
  return widget.canTwoLevelIcon ?? const Icon(...);
case RefreshStatus.canTwoLevel:  // duplicate!
  return widget.twoLevelView ?? const Icon(...);

// After
case RefreshStatus.canTwoLevel:
  return widget.twoLevelView ?? widget.canTwoLevelIcon ?? const Icon(...);
```

### F4: _position null access（`indicator_wrap.dart:551`）
```dart
// Before
_position?.removeListener(...);

// After
// 重构为 late 初始化，在 _updateListener 中保证顺序
late final ScrollPosition _position;
void _updateListener() {
  _position = Scrollable.of(context).position;
  _position.addListener(_handleOffsetChange);
}
```

### F5: _showWater animation 未 dispose（`material_indicator.dart:257`）
```dart
// After
@override
void dispose() {
  _bezierController?.dispose();
  _positionController?.dispose();
  _valueAni?.dispose();
  _scaleFactor?.dispose();
  super.dispose();
}
```

### F6: viewportExtent=0 早期访问（`twolevel_indicator.dart:146`）
```dart
// Before
viewportExtent: SmartRefresher.ofState(context)!.viewportExtent

// After
// 使用 LayoutBuilder 延迟获取，或在 didLayout 后读取
viewportExtent: RefreshConfiguration.of(context)?.viewportExtent ?? 80.0
// 添加默认值 fallback
```

### F7: _isHide flicker（`indicator_wrap.dart:515`）
```dart
// Before
_isHide = constraints.biggest.height == 0;

// After
// 改为依赖 layoutExtent 而非 constraint
// 使用 didChangeLayout 或 setState 二次确认
_isHide = layoutExtent == 0 && constraints.biggest.height == 0;
```

### F8: SpringSimulation jitter（`bezier_indicator.dart:95`）
```dart
// Before
SpringDescription(mass: 3.4, stiffness: 10000.5, damping: 6)

// After
SpringDescription(mass: 2.0, stiffness: 4000.0, damping: 30)
// 降低 stiffness，增加 damping，减少低端设备抖动
```

### F9: copyAncestor 重构（`smart_refresher.dart:853-905`）
```dart
// Before: 手动复制 30+ property

// After: 使用 copyWith
RefreshConfiguration copyWith({
  HeaderBuilder? headerBuilder,
  FooterBuilder? footerBuilder,
  double? headerTriggerDistance,
  // ...选择性覆盖，非 null 覆盖
}) {
  return RefreshConfiguration(
    headerBuilder: headerBuilder ?? this.headerBuilder,
    footerBuilder: footerBuilder ?? this.footerBuilder,
    // ...
  );
}
```

### F10: runtimeType workaround（`refresh_physics.dart:99-107`）
```dart
// 移除 runtimeType deception，改为 proper ScrollPhysics delegate
class RefreshScrollPhysics extends ScrollPhysics {
  ScrollPhysicsDelegate? _delegate;

  @override
  ScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return RefreshScrollPhysics(
      parent: parent?.applyTo(ancestor),
      delegate: _delegate,
    );
  }
}
```

### F11: viewport.children 直接操纵（`smart_refresher.dart:400-408`）
```dart
// Before
viewport.children.insert(0, widget.header);
viewport.children.add(widget.footer);

// After
// 使用 MultiChildRenderObjectElement 或 SliverList 替代
// 或标记 deprecated，保留 backward compatibility
```

---

## 5. 新增 API（Enterprise Features）

### E1: RefreshController autoCleanup
```dart
class RefreshController {
  final bool autoCleanup;  // default: false (backward compatible)
  // 当 autoCleanup=true 且 SmartRefresher dispose 时，自动 dispose controller
}
```

### E2: RefreshConfiguration copyWith chain
```dart
RefreshConfiguration config = RefreshConfiguration.of(context)!;
config = config.copyWith(
  headerBuilder: () => WaterDropHeader(),
  springDescription: newSpring,
);
```

### E3: Indicator lifecycle hooks
```dart
abstract class RefreshIndicator {
  void onInitialized(RefreshIndicatorState state);
  void onDisposed();
}
```

### E4: RefreshStatus/LoadStatus listener API
```dart
RefreshController controller = ...;
controller.headerStatusStream.listen(...);  // Stream-based
controller.footerStatusStream.listen(...);
```

### E5: TwoLevel header/footer configuration
```dart
SmartRefresher(
  enableTwoLevel: true,
  twoLevelHeader: TwoLevelHeader(...),  // 直接传 header widget
  twoLevelFooter: TwoLevelFooter(...),    // 可选的 footer
  onTwoLevel: (isOpen) { ... },
);
```

---

## 6. Migration Guide

| v2.x → v3.0 Breaking Change | Migration |
|:---|:---|
| `controller` parameter now optional | Remove explicit controller if not needed |
| `RefreshConfiguration.copyAncestor` removed | Use `copyWith` chain |
| `LinkHeader.linkKey` now nullable-safe | No action needed, graceful fallback |
| `RefreshPhysics.runtimeType` changed | No action needed, internal only |
| `CustomFooter.onClick` type changed | Cast to `VoidCallback` explicitly |
| Deprecated `withOpacity` removed | Already using `withValues` in v2.0.3 |

---

## 7. 实施计划（Phase by Phase）

**Phase 1 - Foundation（1-2 days）**
- Create v3.0 branch
- Set up new test infrastructure
- Implement F1-F3 (crash fixes)

**Phase 2 - Stability（2-3 days）**
- Implement F4-F8 (boundary fixes)
- Add null-safety fixes
- Deprecation warnings added

**Phase 3 - Tech Debt（3-4 days）**
- Refactor F9 (copyAncestor → copyWith)
- Remove F10 (runtimeType workaround)
- Fix F11 (viewport manipulation)

**Phase 4 - Enterprise API（2-3 days）**
- Implement E1-E5 (new APIs)
- AutoDispose mixin
- Stream-based listeners

**Phase 5 - Testing & Polish（2-3 days）**
- Achieve >80% test coverage
- Integration tests
- Migration guide doc
- CHANGELOG.md 更新

**Total: ~12-15 days**

---

## 8. 测试策略

### 8.1 单元测试
- 所有 public API 方法的 null-safety 测试
- State machine 转换完整性测试
- Configuration copyWith 测试

### 8.2 集成测试
- TabBarView + SmartRefresher 场景
- PageView + SmartRefresher 场景
- NestedScrollView 场景（已知 limitation 需标注）
- TwoLevel complete flow 测试

### 8.3 性能测试
- 1000+ items ListView scroll performance
- Animation frame rate 监控
- Memory leak detection