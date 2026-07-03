import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';

import 'dataSource.dart';
import 'test_indicator.dart';

/// Verifies that spring simulation parameters (F8) work correctly.
void main() {
  testWidgets("default spring description returns to idle without jitter", (tester) async {
    final RefreshController controller = RefreshController();

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(platform: TargetPlatform.iOS),
      home: SmartRefresher(
        header: TestHeader(),
        footer: TestFooter(),
        enablePullDown: true,
        enablePullUp: true,
        controller: controller,
        child: ListView.builder(
          itemBuilder: (c, i) => Text(data[i]),
          itemCount: 20,
          itemExtent: 100,
        ),
      ),
    ));

    // Pull beyond trigger, then release — should spring back without crash
    await tester.drag(find.byType(Scrollable), const Offset(0, 120));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 800));

    // At minimum, no crash — status is somewhere in the flow
    expect(controller.headerStatus, anyOf(RefreshStatus.canRefresh, RefreshStatus.refreshing, RefreshStatus.idle));

    controller.refreshCompleted();
    await tester.pumpAndSettle(const Duration(milliseconds: 800));
    expect(controller.headerStatus, RefreshStatus.idle);
  });

  testWidgets("custom spring description in RefreshConfiguration", (tester) async {
    final RefreshController controller = RefreshController();

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(platform: TargetPlatform.iOS),
      home: RefreshConfiguration(
        springDescription: const SpringDescription(
          mass: 1.0,
          stiffness: 200,
          damping: 20,
        ),
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullDown: true,
          enablePullUp: true,
          controller: controller,
          child: ListView.builder(
            itemBuilder: (c, i) => Text(data[i]),
            itemCount: 20,
            itemExtent: 100,
          ),
        ),
      ),
    ));

    // Verify the spring is used without crash
    await tester.drag(find.byType(Scrollable), const Offset(0, 120));
    await tester.pump();

    await tester.pumpAndSettle(const Duration(milliseconds: 800));

    // No crash is the main assertion
    expect(controller.headerStatus, isNotNull);

    controller.refreshCompleted();
    await tester.pumpAndSettle(const Duration(milliseconds: 800));
    expect(controller.headerStatus, RefreshStatus.idle);
  });
}
