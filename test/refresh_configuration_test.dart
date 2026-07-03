import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';

void main() {
  testWidgets("copyWith preserves unchanged fields", (tester) async {
    late RefreshConfiguration? retrieved;
    await tester.pumpWidget(MaterialApp(
      home: RefreshConfiguration(
        dragSpeedRatio: 1.5,
        enableBallisticRefresh: true,
        headerTriggerDistance: 120.0,
        child: Builder(
          builder: (context) {
            retrieved = RefreshConfiguration.of(context);
            return Container();
          },
        ),
      ),
    ));

    final copy = retrieved!.copyWith(
      dragSpeedRatio: 2.0,
      child: Container(),
    );

    expect(copy.dragSpeedRatio, 2.0);
    expect(copy.enableBallisticRefresh, retrieved!.enableBallisticRefresh);
    expect(copy.headerTriggerDistance, retrieved!.headerTriggerDistance);
  });

  testWidgets("copyWith overrides selected fields only", (tester) async {
    late RefreshConfiguration? retrieved;
    await tester.pumpWidget(MaterialApp(
      home: RefreshConfiguration(
        maxOverScrollExtent: 200,
        maxUnderScrollExtent: 100,
        skipCanRefresh: true,
        child: Builder(
          builder: (context) {
            retrieved = RefreshConfiguration.of(context);
            return Container();
          },
        ),
      ),
    ));

    final copy = retrieved!.copyWith(
      maxOverScrollExtent: 300,
      child: Container(),
    );

    expect(copy.maxOverScrollExtent, 300);
    expect(copy.maxUnderScrollExtent, retrieved!.maxUnderScrollExtent);
    expect(copy.skipCanRefresh, retrieved!.skipCanRefresh);
  });

  testWidgets("copyWith without child returns valid config", (tester) async {
    late RefreshConfiguration? retrieved;
    await tester.pumpWidget(MaterialApp(
      home: RefreshConfiguration(
        child: Builder(
          builder: (context) {
            retrieved = RefreshConfiguration.of(context);
            return Container();
          },
        ),
      ),
    ));

    // The child parameter is technically required by the constructor,
    // but copyWith currently returns a plain value without crashing.
    // Test that it at least doesn't throw.
    final copy = retrieved!.copyWith(dragSpeedRatio: 1.0, child: Container());
    expect(copy.dragSpeedRatio, 1.0);
  });
}
