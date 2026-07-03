import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../widget/sample_data.dart';
import '../../../l10n/app_localizations.dart';

class CustomFooterBuilderDemo extends StatefulWidget {
  const CustomFooterBuilderDemo({super.key});

  @override
  State<CustomFooterBuilderDemo> createState() => _CustomFooterBuilderDemoState();
}

class _CustomFooterBuilderDemoState extends State<CustomFooterBuilderDemo> {
  final RefreshController _controller = RefreshController();
  List<String> _items = SampleData.generate(count: 15);

  void _onRefresh() async {
    await SampleData.simulateNetwork();
    setState(() => _items = SampleData.generate(count: 15));
    _controller.refreshCompleted();
  }

  void _onLoading() async {
    await SampleData.simulateNetwork();
    if (_items.length >= 40) {
      _controller.loadNoData();
      return;
    }
    setState(() => _items = SampleData.appendMore(_items));
    _controller.loadComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!.current;
    return Scaffold(
      appBar: AppBar(title: Text(s.appBarCustomFooterBuilder)),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _controller,
        header: const ClassicHeader(),
        footer: CustomFooter(
          builder: (context, mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = const Text('Pull up to load more');
            } else if (mode == LoadStatus.loading) {
              body = const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CupertinoActivityIndicator(),
                  ),
                  SizedBox(width: 8),
                  Text('Loading...'),
                ],
              );
            } else if (mode == LoadStatus.failed) {
              body = const Text('Load failed. Tap to retry.');
            } else if (mode == LoadStatus.canLoading) {
              body = const Text('Release to load more');
            } else {
              body = const Text('No more data');
            }
            return Container(
              height: 55,
              child: Center(child: body),
            );
          },
        ),
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (_, i) => ListTile(title: Text(_items[i])),
        ),
      ),
    );
  }
}
