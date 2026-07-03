import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widget/sample_data.dart';

class GlobalConfigDemo extends StatefulWidget {
  const GlobalConfigDemo({super.key});

  @override
  State<GlobalConfigDemo> createState() => _GlobalConfigDemoState();
}

class _GlobalConfigDemoState extends State<GlobalConfigDemo> {
  final RefreshController _ctrl1 = RefreshController();
  final RefreshController _ctrl2 = RefreshController();
  List<String> _items1 = SampleData.generate(count: 10);
  List<String> _items2 = SampleData.generate(count: 10);
  bool _useCopyAncestor = false;

  Future<void> _onRefresh1() async {
    await SampleData.simulateNetwork();
    setState(() => _items1 = SampleData.generate(count: 10));
    _ctrl1.refreshCompleted();
  }

  Future<void> _onRefresh2() async {
    await SampleData.simulateNetwork();
    setState(() => _items2 = SampleData.generate(count: 10));
    _ctrl2.refreshCompleted();
  }

  Future<void> _onLoad1() async {
    await SampleData.simulateNetwork();
    if (_items1.length >= 40) { _ctrl1.loadNoData(); return; }
    setState(() => _items1 = SampleData.appendMore(_items1));
    _ctrl1.loadComplete();
  }

  Future<void> _onLoad2() async {
    await SampleData.simulateNetwork();
    if (_items2.length >= 40) { _ctrl2.loadNoData(); return; }
    setState(() => _items2 = SampleData.appendMore(_items2));
    _ctrl2.loadComplete();
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!.current;
    return Scaffold(
      appBar: AppBar(title: Text(s.appBarConfigCopyAncestor)),
      body: Column(
        children: [
          SwitchListTile(
            title: Text(s.configCopyAncestor),
            subtitle: Text(s.configTab2Override),
            value: _useCopyAncestor,
            onChanged: (v) => setState(() => _useCopyAncestor = v),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _smartPanel(s.configGlobalConfig, _ctrl1, _items1, _onRefresh1, _onLoad1)),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _useCopyAncestor
                      ? RefreshConfiguration(
                          headerBuilder: () => const WaterDropHeader(),
                          headerTriggerDistance: 120.0,
                          child: _smartPanel(s.configCopyAncestorTitle, _ctrl2, _items2, _onRefresh2, _onLoad2),
                        )
                      : _smartPanel('Global Config', _ctrl2, _items2, _onRefresh2, _onLoad2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smartPanel(String title, RefreshController ctrl, List<String> items,
      Future<void> Function() onRefresh, Future<void> Function() onLoading) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey[200],
          width: double.infinity,
          child: Text(title, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            controller: ctrl,
            onRefresh: onRefresh,
            onLoading: onLoading,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) => ListTile(dense: true,
                  title: Text(items[i], style: const TextStyle(fontSize: 12))),
            ),
          ),
        ),
      ],
    );
  }
}
