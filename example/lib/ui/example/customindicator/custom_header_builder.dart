import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../widget/sample_data.dart';
import '../../../l10n/app_localizations.dart';

class CustomHeaderBuilderDemo extends StatefulWidget {
  const CustomHeaderBuilderDemo({super.key});

  @override
  State<CustomHeaderBuilderDemo> createState() => _CustomHeaderBuilderDemoState();
}

class _CustomHeaderBuilderDemoState extends State<CustomHeaderBuilderDemo> {
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
      appBar: AppBar(title: Text(s.appBarCustomHeaderBuilder)),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _controller,
        header: CustomHeader(
          builder: (context, mode) {
            return Container(
              height: 60,
              color: Colors.blueAccent.withValues(alpha: 0.1),
              child: Center(
                child: mode == RefreshStatus.refreshing
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Refreshing...'),
                        ],
                      )
                    : mode == RefreshStatus.completed
                        ? const Text('✓ Refresh Complete')
                        : mode == RefreshStatus.failed
                            ? const Text('✗ Refresh Failed')
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
