import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../widget/sample_data.dart';
import '../../../l10n/app_localizations.dart';

class SpinkitHeaderDemo extends StatefulWidget {
  const SpinkitHeaderDemo({super.key});

  @override
  State<SpinkitHeaderDemo> createState() => _SpinkitHeaderDemoState();
}

class _SpinkitHeaderDemoState extends State<SpinkitHeaderDemo> {
  final RefreshController _controller = RefreshController();
  List<String> _items = SampleData.generate(count: 20);

  void _onRefresh() async {
    await SampleData.simulateNetwork();
    setState(() => _items = SampleData.generate(count: 20));
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
      appBar: AppBar(title: Text(s.appBarSpinkitHeader)),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _controller,
        header: CustomHeader(
          builder: (context, mode) {
            return Container(
              height: 60,
              color: Colors.grey.withValues(alpha: 0.1),
              child: Center(
                child: mode == RefreshStatus.refreshing
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SpinKitFadingCircle(color: Colors.blue, size: 30),
                          SizedBox(width: 12),
                          Text('Refreshing...'),
                        ],
                      )
                    : const Text('↓ Pull to refresh'),
              ),
            );
          },
        ),
        footer: const ClassicFooter(),
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
