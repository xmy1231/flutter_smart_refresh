import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';

import 'dataSource.dart';

/// Test that F11 viewport rebuild fix (no direct mutation of viewport.children)
/// continues to work correctly with different sliver configurations.
void main() {
  testWidgets("SmartRefresher rebuilds viewport when enablePullDown toggles", (tester) async {
    final RefreshController controller = RefreshController();

    await tester.pumpWidget(MaterialApp(
      home: SmartRefresher(
        header: ClassicHeader(),
        footer: ClassicFooter(),
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

    RenderViewport viewport = tester.renderObject(find.byType(Viewport));
    expect(viewport.childCount, 3); // header + list + footer

    // toggle enablePullDown off
    await tester.pumpWidget(MaterialApp(
      home: SmartRefresher(
        header: ClassicHeader(),
        footer: ClassicFooter(),
        enablePullDown: false,
        enablePullUp: true,
        controller: controller,
        child: ListView.builder(
          itemBuilder: (c, i) => Text(data[i]),
          itemCount: 20,
          itemExtent: 100,
        ),
      ),
    ));

    viewport = tester.renderObject(find.byType(Viewport));
    expect(viewport.childCount, 2); // list + footer only

    // toggle both off
    await tester.pumpWidget(MaterialApp(
      home: SmartRefresher(
        header: ClassicHeader(),
        footer: ClassicFooter(),
        enablePullDown: false,
        enablePullUp: false,
        controller: controller,
        child: ListView.builder(
          itemBuilder: (c, i) => Text(data[i]),
          itemCount: 20,
          itemExtent: 100,
        ),
      ),
    ));

    viewport = tester.renderObject(find.byType(Viewport));
    expect(viewport.childCount, 1); // list only

    // toggle both back on
    await tester.pumpWidget(MaterialApp(
      home: SmartRefresher(
        header: ClassicHeader(),
        footer: ClassicFooter(),
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

    viewport = tester.renderObject(find.byType(Viewport));
    expect(viewport.childCount, 3);
  });

  testWidgets("SmartRefresher rebuilds with CustomScrollView slivers", (tester) async {
    final RefreshController controller = RefreshController();

    await tester.pumpWidget(MaterialApp(
      home: SmartRefresher.builder(
        enablePullDown: true,
        enablePullUp: true,
        builder: (context, physics) {
          return CustomScrollView(
            physics: physics,
            slivers: [
              ClassicHeader(),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (c, i) => SizedBox(height: 100, child: Text(data[i])),
                  childCount: 5,
                ),
              ),
              ClassicFooter(),
            ],
          );
        },
        controller: controller,
      ),
    ));

    // Should render without crash
    expect(find.byType(SmartRefresher), findsOneWidget);
    expect(controller.headerStatus, RefreshStatus.idle);

    // Toggle enablePullDown
    await tester.pumpWidget(MaterialApp(
      home: SmartRefresher.builder(
        enablePullDown: false,
        enablePullUp: true,
        builder: (context, physics) {
          return CustomScrollView(
            physics: physics,
            slivers: [
              ClassicHeader(),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (c, i) => SizedBox(height: 100, child: Text(data[i])),
                  childCount: 5,
                ),
              ),
              ClassicFooter(),
            ],
          );
        },
        controller: controller,
      ),
    ));

    // No crash — viewport rebuild works
    expect(find.byType(SmartRefresher), findsOneWidget);
  });
}
