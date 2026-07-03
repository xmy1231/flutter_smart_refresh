import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../widget/sample_data.dart';
import '../../../l10n/app_localizations.dart';

class ClassicIndicatorDemo extends StatefulWidget {
  const ClassicIndicatorDemo({super.key});

  @override
  State<ClassicIndicatorDemo> createState() => _ClassicIndicatorDemoState();
}

class _ClassicIndicatorDemoState extends State<ClassicIndicatorDemo> {
  final RefreshController _controller = RefreshController();
  List<String> _items = SampleData.generate(count: 20);
  IconPosition _iconPosition = IconPosition.left;

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
      appBar: AppBar(title: Text(s.appBarClassicIndicator)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<IconPosition>(
              segments: const [
                ButtonSegment(value: IconPosition.left, label: Text('Left')),
                ButtonSegment(value: IconPosition.right, label: Text('Right')),
                ButtonSegment(value: IconPosition.top, label: Text('Top')),
                ButtonSegment(value: IconPosition.bottom, label: Text('Bottom')),
              ],
              selected: {_iconPosition},
              onSelectionChanged: (v) => setState(() => _iconPosition = v.first),
            ),
          ),
          Expanded(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              controller: _controller,
              header: ClassicHeader(iconPos: _iconPosition),
              footer: const ClassicFooter(),
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (_, i) => ListTile(title: Text(_items[i])),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
