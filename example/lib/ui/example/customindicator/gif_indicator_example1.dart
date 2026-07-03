import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../widget/sample_data.dart';
import '../../../l10n/app_localizations.dart';

class GifIndicatorDemo extends StatefulWidget {
  const GifIndicatorDemo({super.key});

  @override
  State<GifIndicatorDemo> createState() => _GifIndicatorDemoState();
}

class _GifIndicatorDemoState extends State<GifIndicatorDemo> {
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
      appBar: AppBar(title: Text(s.appBarGifIndicator)),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _controller,
        header: CustomHeader(
          builder: (context, mode) {
            return Container(
              height: 80,
              color: Colors.grey.withValues(alpha: 0.1),
              child: Center(
                child: mode == RefreshStatus.refreshing
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('images/gifindicator1.gif', width: 40, height: 40),
                          const SizedBox(height: 4),
                          const Text('Refreshing...', style: TextStyle(fontSize: 12)),
                        ],
                      )
                    : mode == RefreshStatus.completed
                        ? const Text('✓ Refresh Complete')
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('images/custom_1.jpg', width: 30, height: 30),
                              const SizedBox(width: 8),
                              const Text('↓ Pull to refresh'),
                            ],
                          ),
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
