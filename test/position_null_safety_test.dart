import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';

import 'dataSource.dart';
import 'test_indicator.dart';

/// Test that the _position nullable safety (F4 + F7) doesn't break normal flow.
void main() {
  testWidgets("normal pull-to-refresh completes without crash", (tester) async {
    final RefreshController controller = RefreshController();

    await tester.pumpWidget(MaterialApp(
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

    // Pull down to refresh (use same pattern as existing tests)
    await tester.drag(find.byType(Scrollable), const Offset(0, 100));
    await tester.pump();
    // may or may not reach canRefresh depending on drag distance;
    // at minimum, no crash occurs
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    // Verify we reached refreshing or somewhere in the flow
    expect(controller.headerStatus, anyOf(RefreshStatus.canRefresh, RefreshStatus.refreshing, RefreshStatus.idle));

    if (controller.headerStatus == RefreshStatus.canRefresh || controller.headerStatus == RefreshStatus.refreshing) {
      controller.refreshCompleted();
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
    }
  });

  testWidgets("pull-to-load completes without crash", (tester) async {
    final RefreshController controller = RefreshController();

    await tester.pumpWidget(MaterialApp(
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

    // Scroll to bottom and load
    controller.position!.jumpTo(controller.position!.maxScrollExtent - 100);
    await tester.drag(find.byType(Scrollable), const Offset(0, -100));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(controller.footerStatus, LoadStatus.loading);
  });

  testWidgets("rapid enable/disable does not crash", (tester) async {
    final RefreshController controller = RefreshController();

    await tester.pumpWidget(MaterialApp(
      home: SmartRefresher(
        header: TestHeader(),
        footer: TestFooter(),
        enablePullDown: true,
        enablePullUp: true,
        controller: controller,
        child: ListView.builder(
          itemBuilder: (c, i) => Text(data[i]),
          itemCount: 5,
          itemExtent: 100,
        ),
      ),
    ));

    // Rapidly rebuild with different configurations
    for (int i = 0; i < 5; i++) {
      await tester.pumpWidget(MaterialApp(
        home: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullDown: i.isEven,
          enablePullUp: i.isOdd,
          controller: controller,
          child: ListView.builder(
            itemBuilder: (c, i) => Text(data[i]),
            itemCount: 5,
            itemExtent: 100,
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 50));
    }

    // No crash during rapid rebuilds
    expect(controller.headerStatus, isNotNull);
  });
}
