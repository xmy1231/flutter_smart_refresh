import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_string.dart';
import '../../../widget/sample_data.dart';

class RefreshStyleDemo extends StatefulWidget {
  const RefreshStyleDemo({super.key});

  @override
  State<RefreshStyleDemo> createState() => _RefreshStyleDemoState();
}

class _RefreshStyleDemoState extends State<RefreshStyleDemo> {
  final RefreshController _controller = RefreshController();
  List<String> _items = SampleData.generate(count: 20);
  RefreshStyle _currentStyle = RefreshStyle.Follow;

  Map<RefreshStyle, String> _buildDescriptions(AppString s) {
    return {
      RefreshStyle.Follow: s.refreshStyleFollowDesc,
      RefreshStyle.UnFollow: s.refreshStyleUnFollowDesc,
      RefreshStyle.Behind: s.refreshStyleBehindDesc,
      RefreshStyle.Front: s.refreshStyleFrontDesc,
    };
  }

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
    final descriptions = _buildDescriptions(s);
    return Scaffold(
      appBar: AppBar(title: Text(s.appBarRefreshStyle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<RefreshStyle>(
              segments: [
                ButtonSegment(value: RefreshStyle.Follow, label: Text(s.refreshStyleFollow)),
                ButtonSegment(value: RefreshStyle.UnFollow, label: Text(s.refreshStyleUnFollow)),
                ButtonSegment(value: RefreshStyle.Behind, label: Text(s.refreshStyleBehind)),
                ButtonSegment(value: RefreshStyle.Front, label: Text(s.refreshStyleFront)),
              ],
              selected: {_currentStyle},
              onSelectionChanged: (v) {
                setState(() => _currentStyle = v.first);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(descriptions[_currentStyle]!, style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              controller: _controller,
              header: ClassicHeader(refreshStyle: _currentStyle),
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
