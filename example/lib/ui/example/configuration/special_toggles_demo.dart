import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widget/sample_data.dart';

class SpecialTogglesDemo extends StatefulWidget {
  const SpecialTogglesDemo({super.key});

  @override
  State<SpecialTogglesDemo> createState() => _SpecialTogglesDemoState();
}

class _SpecialTogglesDemoState extends State<SpecialTogglesDemo> {
  final RefreshController _controller = RefreshController();
  List<String> _items = SampleData.generate(count: 12);

  bool _enableBallisticRefresh = false;
  bool _enableBallisticLoad = true;
  bool _enableRefreshVibrate = false;
  bool _enableLoadMoreVibrate = false;
  bool _hideFooterWhenNotFull = false;
  bool _skipCanRefresh = false;
  bool _enableLoadingWhenFailed = true;

  Future<void> _onRefresh() async {
    await SampleData.simulateNetwork();
    setState(() => _items = SampleData.generate(count: 12));
    _controller.refreshCompleted();
  }

  Future<void> _onLoading() async {
    await SampleData.simulateNetwork();
    if (_items.length >= 40) { _controller.loadNoData(); return; }
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
      appBar: AppBar(title: Text(s.appBarSpecialToggles)),
      body: RefreshConfiguration(
        enableBallisticRefresh: _enableBallisticRefresh,
        enableBallisticLoad: _enableBallisticLoad,
        enableRefreshVibrate: _enableRefreshVibrate,
        enableLoadMoreVibrate: _enableLoadMoreVibrate,
        hideFooterWhenNotFull: _hideFooterWhenNotFull,
        skipCanRefresh: _skipCanRefresh,
        enableLoadingWhenFailed: _enableLoadingWhenFailed,
        child: Column(
          children: [
            Expanded(
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                controller: _controller,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (_, i) => ListTile(title: Text(_items[i])),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: Colors.grey[100],
              child: Column(
                children: [
                  _switch(s.toggleBallisticRefresh, _enableBallisticRefresh, (v) => setState(() => _enableBallisticRefresh = v)),
                  _switch(s.toggleBallisticLoad, _enableBallisticLoad, (v) => setState(() => _enableBallisticLoad = v)),
                  _switch(s.toggleRefreshVibrate, _enableRefreshVibrate, (v) => setState(() => _enableRefreshVibrate = v)),
                  _switch(s.toggleLoadMoreVibrate, _enableLoadMoreVibrate, (v) => setState(() => _enableLoadMoreVibrate = v)),
                  _switch(s.toggleHideFooterWhenNotFull, _hideFooterWhenNotFull, (v) => setState(() => _hideFooterWhenNotFull = v)),
                  _switch(s.toggleSkipCanRefresh, _skipCanRefresh, (v) => setState(() => _skipCanRefresh = v)),
                  _switch(s.toggleEnableLoadingWhenFailed, _enableLoadingWhenFailed, (v) => setState(() => _enableLoadingWhenFailed = v)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switch(String label, bool value, ValueChanged<bool> onChange) {
    return SwitchListTile(
      dense: true,
      title: Text(label, style: const TextStyle(fontSize: 13)),
      value: value,
      onChanged: onChange,
    );
  }
}
