import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../widget/sample_data.dart';
import '../../../l10n/app_localizations.dart';

class CustomScrollViewExample extends StatefulWidget {
  const CustomScrollViewExample({super.key});

  @override
  State<CustomScrollViewExample> createState() => _CustomScrollViewExampleState();
}

class _CustomScrollViewExampleState extends State<CustomScrollViewExample> {
  final RefreshController _controller = RefreshController();
  List<String> _items = SampleData.generate(count: 20);

  void _onRefresh() async {
    await SampleData.simulateNetwork();
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
      appBar: AppBar(title: Text(s.appBarCustomScrollView)),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _controller,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blueAccent.withValues(alpha: 0.1),
                child: const Text('Header Section', style: TextStyle(fontSize: 18)),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => ListTile(title: Text(_items[i])),
                childCount: _items.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
