/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime: 2019-07-21 12:29
 */

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';

import 'dataSource.dart';
import 'test_indicator.dart';

Widget buildIntegrationRefresher(RefreshController controller, {int count = 20}) {
  return RefreshConfiguration(
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: 375.0,
        height: 690.0,
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          enableTwoLevel: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Text(data[i]),
            itemCount: count,
            itemExtent: 100,
          ),
          controller: controller,
        ),
      ),
    ),
    maxOverScrollExtent: 180,
  );
}

void main() {
  testWidgets("full refresh cycle: idle → canRefresh → refreshing → completed → idle", (tester) async {
    final RefreshController controller = RefreshController();
    await tester.pumpWidget(buildIntegrationRefresher(controller));

    expect(controller.headerStatus, RefreshStatus.idle);

    // drag down beyond triggerDistance (80), positive Y = finger moves DOWN = overscroll at top
    await tester.drag(find.byType(Scrollable), const Offset(0, 120.0), touchSlopY: 0.0);
    await tester.pump();
    expect(controller.headerStatus, RefreshStatus.canRefresh);

    // release — should trigger refresh
    // Use default pumpAndSettle (100ms steps) so the ballistic simulation advances
    // incrementally, allowing _dispatchModeByOffset to reach the BallisticScrollActivity
    // block and set floating=true before settling back to offset=0.
    await tester.pumpAndSettle();
    expect(controller.headerStatus, RefreshStatus.refreshing);

    // complete refresh
    controller.refreshCompleted();
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
    expect(controller.headerStatus, RefreshStatus.idle);
  });

  testWidgets("load cycle: idle → loading (trigger by drag)", (tester) async {
    final RefreshController controller = RefreshController();
    await tester.pumpWidget(buildIntegrationRefresher(controller));

    // scroll to near bottom
    controller.position!.jumpTo(controller.position!.maxScrollExtent - 30);
    expect(controller.footerStatus, LoadStatus.idle);

    // drag up (negative Y) beyond triggerDistance to trigger load more
    await tester.drag(find.byType(Scrollable), const Offset(0, -100.0), touchSlopY: 0.0);
    await tester.pumpAndSettle();
    expect(controller.footerStatus, LoadStatus.loading);
  });

  testWidgets("twoLevel cycle: idle → canTwoLevel → twoLevelOpening → twoLeveling → idle", (tester) async {
    final RefreshController controller = RefreshController();
    await tester.pumpWidget(buildIntegrationRefresher(controller));

    // drag far beyond twiceTriggerDistance (150)
    await tester.drag(find.byType(Scrollable), const Offset(0, 200.0), touchSlopY: 0.0);
    await tester.pump();
    expect(controller.headerStatus, RefreshStatus.canTwoLevel);

    // release — enter twoLevel
    await tester.pumpAndSettle();
    expect(controller.headerStatus, RefreshStatus.twoLeveling);

    // close twoLevel programmatically
    controller.twoLevelComplete();
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
    expect(controller.headerStatus, RefreshStatus.idle);
  });

  testWidgets("failed state and retry", (tester) async {
    final RefreshController controller = RefreshController();
    await tester.pumpWidget(buildIntegrationRefresher(controller));

    // trigger refresh
    await tester.drag(find.byType(Scrollable), const Offset(0, 120.0), touchSlopY: 0.0);
    await tester.pump();
    expect(controller.headerStatus, RefreshStatus.canRefresh);
    await tester.pumpAndSettle();
    expect(controller.headerStatus, RefreshStatus.refreshing);

    // fail — should transition to completed then idle
    controller.refreshFailed();
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
    expect(controller.headerStatus, RefreshStatus.idle);
  });

  testWidgets("noMore state blocks loading", (tester) async {
    final RefreshController controller = RefreshController();
    await tester.pumpWidget(buildIntegrationRefresher(controller));

    // set noMore
    controller.loadNoData();
    await tester.pump();

    // scroll to bottom
    controller.position!.jumpTo(controller.position!.maxScrollExtent - 30);

    // try to trigger loading — should stay noMore
    await tester.drag(find.byType(Scrollable), const Offset(0, -100.0), touchSlopY: 0.0);
    await tester.pump();
    expect(controller.footerStatus, LoadStatus.noMore);
  });

  testWidgets("enablePullDown=false disables refresh", (tester) async {
    final RefreshController controller = RefreshController();
    await tester.pumpWidget(RefreshConfiguration(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          width: 375.0,
          height: 690.0,
          child: SmartRefresher(
            header: TestHeader(),
            enablePullDown: false,
            child: ListView.builder(
              itemBuilder: (c, i) => Text(data[i]),
              itemCount: 20,
              itemExtent: 100,
            ),
            controller: controller,
          ),
        ),
      ),
      maxOverScrollExtent: 180,
    ));

    // drag down — should not trigger canRefresh
    await tester.drag(find.byType(Scrollable), const Offset(0, 120.0), touchSlopY: 0.0);
    await tester.pump();
    expect(controller.headerStatus, RefreshStatus.idle);
  });
}
