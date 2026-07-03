import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../widget/sample_data.dart';
import '../../../l10n/app_localizations.dart';

class BasicExample extends StatefulWidget {
  const BasicExample({super.key});

  @override
  State<BasicExample> createState() => _BasicExampleState();
}

class _BasicExampleState extends State<BasicExample> {
  final RefreshController _controller = RefreshController();
  List<String> _items = SampleData.generate(count: 30);

  void _onRefresh() async {
    await SampleData.simulateNetwork();
    if (SampleData.randomFailure(rate: 0.1)) {
      _controller.refreshFailed();
      return;
    }
    setState(() => _items = SampleData.generate(count: 30));
    _controller.refreshCompleted();
  }

  void _onLoading() async {
    await SampleData.simulateNetwork();
    if (_items.length >= 60) {
      _controller.loadNoData();
      return;
    }
    if (SampleData.randomFailure(rate: 0.2)) {
      _controller.loadFailed();
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
      appBar: AppBar(title: Text(s.appBarBasicListView)),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _controller,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.builder(
          itemCount: _items.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (_, i) => Card(
            child: ListTile(title: Text(_items[i])),
          ),
        ),
      ),
    );
  }
}
