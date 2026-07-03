import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';

import 'dataSource.dart';

void main() {
  testWidgets("LinkHeader renders without crash", (tester) async {
    final GlobalKey linkKey = GlobalKey();
    final RefreshController controller = RefreshController();

    await tester.pumpWidget(MaterialApp(
      home: SmartRefresher(
        header: LinkHeader(linkKey: linkKey),
        footer: ClassicFooter(),
        enablePullDown: true,
        controller: controller,
        child: ListView.builder(
          itemBuilder: (c, i) => Text(data[i]),
          itemCount: 20,
          itemExtent: 100,
        ),
      ),
    ));

    // LinkHeader should not crash — it renders an empty Container
    expect(controller.headerStatus, RefreshStatus.idle);
  });

  testWidgets("LinkFooter renders without crash", (tester) async {
    final GlobalKey linkKey = GlobalKey();
    final RefreshController controller = RefreshController();

    await tester.pumpWidget(MaterialApp(
      home: SmartRefresher(
        header: ClassicHeader(),
        footer: LinkFooter(linkKey: linkKey),
        enablePullUp: true,
        controller: controller,
        child: ListView.builder(
          itemBuilder: (c, i) => Text(data[i]),
          itemCount: 20,
          itemExtent: 100,
        ),
      ),
    ));

    expect(controller.footerStatus, LoadStatus.idle);
  });

  testWidgets("LinkHeader does not crash on drag", (tester) async {
    final GlobalKey linkKey = GlobalKey();
    final RefreshController controller = RefreshController();

    await tester.pumpWidget(MaterialApp(
      home: SmartRefresher(
        header: LinkHeader(linkKey: linkKey),
        footer: ClassicFooter(),
        enablePullDown: true,
        controller: controller,
        child: ListView.builder(
          itemBuilder: (c, i) => Text(data[i]),
          itemCount: 20,
          itemExtent: 100,
        ),
      ),
    ));

    // Pull down — should not throw
    await tester.drag(find.byType(Scrollable), const Offset(0, 80));
    await tester.pump();
    // At minimum, no crash occurs on offset change
  });
}
