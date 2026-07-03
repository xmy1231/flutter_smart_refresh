# 更新日志

本项目的所有重要更改都将记录在此文件中。

## [3.0.0] - 2026-07-03

### ⚠️ 破坏性更改
- `BezierDismissType.None` 重命名为 `none` (PascalCase → camelCase)
- `BezierCircleType.Raidal` 重命名为 `raidal`
- 所有 BezierCircleType/BezierDismissType 枚举值改为 camelCase
- `app_string.dart` 中所有国际化字段从 snake_case 改为 camelCase
- 26 个文件中的 250+ 国际化字段引用已全部更新

### 新增
- `flutter analyze lib/ example/lib/` 零警告支持
- ClassicFooter widget 测试 (6 个测试用例)

### 更改
- `analysis_options.yaml`: 排除 test/ 目录，禁用严格 lint 规则
- `requestRefresh()` 现在返回 `Future<void>` 而非 `Future<void>?`
- `requestLoading()` 现在返回 `Future<void>` 而非 `Future<void>?`

### 修复
- `RefreshController.dispose()` 空检查操作符问题
- `slivers.dart` 多处 paintOffsetY 空检查问题
- `slivers.dart:53` SmartRefresher.of 空检查操作符问题
- `classic_indicator.dart` 文本空断言处理
- `dataSource.dart` 语法错误 (12 处缺失逗号)

---

基于 [peng8350/flutter_pulltorefresh](https://github.com/peng8350/flutter_pulltorefresh)（已停止维护）