import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../widget/sample_data.dart';
import '../../../l10n/app_localizations.dart';

class BezierCircleDemo extends StatefulWidget {
  const BezierCircleDemo({super.key});

  @override
  State<BezierCircleDemo> createState() => _BezierCircleDemoState();
}

class _BezierCircleDemoState extends State<BezierCircleDemo> {
  final RefreshController _controller = RefreshController();
  List<String> _items = SampleData.generate(count: 20);
  BezierCircleType _circleType = BezierCircleType.raidal;
  BezierDismissType _dismissType = BezierDismissType.none;

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
      appBar: AppBar(title: Text(s.appBarBezierCircleHeader)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Circle Type:'),
                SegmentedButton<BezierCircleType>(
                  segments: const [
                    ButtonSegment(value: BezierCircleType.raidal, label: Text('Radial')),
                    ButtonSegment(value: BezierCircleType.progress, label: Text('Progress')),
                  ],
                  selected: {_circleType},
                  onSelectionChanged: (v) => setState(() => _circleType = v.first),
                ),
                const SizedBox(height: 8),
                const Text('Dismiss Type:'),
                SegmentedButton<BezierDismissType>(
                  segments: const [
                    ButtonSegment(value: BezierDismissType.none, label: Text('None')),
                    ButtonSegment(value: BezierDismissType.rectSpread, label: Text('RectSpread')),
                    ButtonSegment(value: BezierDismissType.scaleToCenter, label: Text('Scale')),
                  ],
                  selected: {_dismissType},
                  onSelectionChanged: (v) => setState(() => _dismissType = v.first),
                ),
              ],
            ),
          ),
          Expanded(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              controller: _controller,
              header: BezierCircleHeader(
                circleType: _circleType,
                dismissType: _dismissType,
              ),
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
