import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../widget/sample_data.dart';
import '../../../l10n/app_localizations.dart';

class GridViewExample extends StatefulWidget {
  const GridViewExample({super.key});

  @override
  State<GridViewExample> createState() => _GridViewExampleState();
}

class _GridViewExampleState extends State<GridViewExample> {
  final RefreshController _controller = RefreshController();
  List<String> _items = SampleData.generate(count: 20);

  void _onRefresh() async {
    await SampleData.simulateNetwork();
    if (SampleData.randomFailure(rate: 0.1)) {
      _controller.refreshFailed();
      return;
    }
    setState(() => _items = SampleData.generate(count: 20));
    _controller.refreshCompleted();
  }

  void _onLoading() async {
    await SampleData.simulateNetwork();
    if (_items.length >= 60) {
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
      appBar: AppBar(title: Text(s.appBarGridView)),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _controller,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _items.length,
          itemBuilder: (_, i) => Container(
            decoration: BoxDecoration(
              color: Colors.primaries[i % Colors.primaries.length].withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(_items[i])),
          ),
        ),
      ),
    );
  }
}
