/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime: 2019-07-20 20:58
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';

import 'dataSource.dart';

void main() {
  group('ClassicFooter Widget Tests', () {
    testWidgets('ClassicFooter builds without crashing', (tester) async {
      final RefreshController controller = RefreshController();

      await tester.pumpWidget(MaterialApp(
        home: SmartRefresher(
          header: const ClassicHeader(),
          footer: const ClassicFooter(),
          enablePullUp: true,
          controller: controller,
          child: ListView.builder(
            itemBuilder: (c, i) => Text(data[i]),
            itemCount: 20,
            itemExtent: 100,
          ),
        ),
      ));

      expect(find.byType(ClassicFooter), findsOneWidget);
    });

    testWidgets('ClassicFooter renders idleText when LoadStatus is idle', (tester) async {
      final RefreshController controller = RefreshController();

      await tester.pumpWidget(MaterialApp(
        home: SmartRefresher(
          header: const ClassicHeader(),
          footer: const ClassicFooter(
            idleText: 'Pull up to load more',
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

      await tester.pump();
      expect(find.text('Pull up to load more'), findsOneWidget);
    });

    testWidgets('ClassicFooter renders loadingText when loading', (tester) async {
      final RefreshController controller = RefreshController();

      await tester.pumpWidget(MaterialApp(
        home: SmartRefresher(
          header: const ClassicHeader(),
          footer: const ClassicFooter(
            loadingText: 'Loading...',
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

      await tester.pump();

      controller.footerMode?.value = LoadStatus.loading;
      await tester.pump();

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('ClassicFooter renders noDataText when no more data', (tester) async {
      final RefreshController controller = RefreshController();

      await tester.pumpWidget(MaterialApp(
        home: SmartRefresher(
          header: const ClassicHeader(),
          footer: const ClassicFooter(
            noDataText: 'No more data',
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

      await tester.pump();

      controller.footerMode?.value = LoadStatus.noMore;
      await tester.pump();

      expect(find.text('No more data'), findsOneWidget);
    });

    testWidgets('ClassicFooter renders failedText when loading failed', (tester) async {
      final RefreshController controller = RefreshController();

      await tester.pumpWidget(MaterialApp(
        home: SmartRefresher(
          header: const ClassicHeader(),
          footer: const ClassicFooter(
            failedText: 'Load failed',
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

      await tester.pump();

      controller.footerMode?.value = LoadStatus.failed;
      await tester.pump();

      expect(find.text('Load failed'), findsOneWidget);
    });

    testWidgets('ClassicFooter renders canLoadingText when can load', (tester) async {
      final RefreshController controller = RefreshController();

      await tester.pumpWidget(MaterialApp(
        home: SmartRefresher(
          header: const ClassicHeader(),
          footer: const ClassicFooter(
            canLoadingText: 'Release to load more',
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

      await tester.pump();

      controller.footerMode?.value = LoadStatus.canLoading;
      await tester.pump();

      expect(find.text('Release to load more'), findsOneWidget);
    });
  });
}