import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_string.dart';
import '../../../widget/sample_data.dart';

class LoadStyleDemo extends StatefulWidget {
  const LoadStyleDemo({super.key});

  @override
  State<LoadStyleDemo> createState() => _LoadStyleDemoState();
}

class _LoadStyleDemoState extends State<LoadStyleDemo> {
  final RefreshController _controller = RefreshController();
  List<String> _items = SampleData.generate(count: 5);
  LoadStyle _currentStyle = LoadStyle.ShowAlways;

  Map<LoadStyle, String> _buildDescriptions(AppString s) {
    return {
      LoadStyle.ShowAlways: s.loadStyleShowAlwaysDesc,
      LoadStyle.HideAlways: s.loadStyleHideAlwaysDesc,
      LoadStyle.ShowWhenLoading: s.loadStyleShowWhenLoadingDesc,
    };
  }

  void _onRefresh() async {
    await SampleData.simulateNetwork();
    setState(() => _items = SampleData.generate(count: 5));
    _controller.refreshCompleted();
  }

  void _onLoading() async {
    await SampleData.simulateNetwork();
    if (_items.length >= 30) {
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
      appBar: AppBar(title: Text(s.appBarLoadStyle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<LoadStyle>(
              segments: [
                ButtonSegment(value: LoadStyle.ShowAlways, label: Text(s.loadStyleShowAlways)),
                ButtonSegment(value: LoadStyle.HideAlways, label: Text(s.loadStyleHideAlways)),
                ButtonSegment(value: LoadStyle.ShowWhenLoading, label: Text(s.loadStyleShowWhenLoading)),
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
              footer: ClassicFooter(loadStyle: _currentStyle),
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
