import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';

import 'dataSource.dart';

void main() {
  testWidgets("CustomHeader onInit is called on mount", (tester) async {
    bool initCalled = false;
    final RefreshController controller = RefreshController();

    await tester.pumpWidget(MaterialApp(
      home: SmartRefresher(
        header: CustomHeader(
          builder: (c, m) => Container(height: 60),
          onInit: () => initCalled = true,
        ),
        footer: ClassicFooter(),
        controller: controller,
        child: ListView.builder(
          itemBuilder: (c, i) => Text(data[i]),
          itemCount: 20,
          itemExtent: 100,
        ),
      ),
    ));

    expect(initCalled, isTrue);
  });

  testWidgets("CustomHeader onDispose is called on unmount", (tester) async {
    bool disposeCalled = false;
    final RefreshController controller = RefreshController();

    await tester.pumpWidget(MaterialApp(
      home: SmartRefresher(
        header: CustomHeader(
          builder: (c, m) => Container(height: 60),
          onDispose: () => disposeCalled = true,
        ),
        footer: ClassicFooter(),
        controller: controller,
        child: ListView.builder(
          itemBuilder: (c, i) => Text(data[i]),
          itemCount: 20,
          itemExtent: 100,
        ),
      ),
    ));

    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();

    expect(disposeCalled, isTrue);
  });

  testWidgets("CustomFooter onInit is called on mount", (tester) async {
    bool initCalled = false;
    final RefreshController controller = RefreshController();

    await tester.pumpWidget(MaterialApp(
      home: SmartRefresher(
        header: ClassicHeader(),
        footer: CustomFooter(
          builder: (c, m) => Container(height: 60),
          onInit: () => initCalled = true,
        ),
        enablePullUp: true,
        controller: controller,
        child: ListView.builder(
          itemBuilder: (c, i) => Text(data[i]),
          itemCount: 20,
          itemExtent: 100,
        ),
      ),
    ));

    expect(initCalled, isTrue);
  });

  testWidgets("ClassicHeader onInit/onDispose hooks", (tester) async {
    bool initCalled = false;
    bool disposeCalled = false;
    final RefreshController controller = RefreshController();

    await tester.pumpWidget(MaterialApp(
      home: SmartRefresher(
        header: ClassicHeader(
          onInit: () => initCalled = true,
          onDispose: () => disposeCalled = true,
        ),
        footer: ClassicFooter(),
        controller: controller,
        child: ListView.builder(
          itemBuilder: (c, i) => Text(data[i]),
          itemCount: 20,
          itemExtent: 100,
        ),
      ),
    ));

    expect(initCalled, isTrue);

    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();

    expect(disposeCalled, isTrue);
  });
}
