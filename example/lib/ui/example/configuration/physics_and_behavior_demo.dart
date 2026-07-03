import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widget/sample_data.dart';

class PhysicsBehaviorDemo extends StatefulWidget {
  const PhysicsBehaviorDemo({super.key});

  @override
  State<PhysicsBehaviorDemo> createState() => _PhysicsBehaviorDemoState();
}

class _PhysicsBehaviorDemoState extends State<PhysicsBehaviorDemo> {
  final RefreshController _controller = RefreshController();
  List<String> _items = SampleData.generate(count: 20);

  double _mass = 2.0;
  double _stiffness = 150.0;
  double _damping = 16.0;
  double _dragSpeedRatio = 1.0;
  double _maxOverScroll = 100.0;

  Future<void> _onRefresh() async {
    await SampleData.simulateNetwork();
    setState(() => _items = SampleData.generate(count: 20));
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
      appBar: AppBar(title: Text(s.appBarPhysicsBehavior)),
      body: RefreshConfiguration(
        dragSpeedRatio: _dragSpeedRatio,
        maxOverScrollExtent: _maxOverScroll,
        springDescription: SpringDescription(
          mass: _mass,
          stiffness: _stiffness,
          damping: _damping,
        ),
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
              padding: const EdgeInsets.all(12),
              color: Colors.grey[100],
              child: Column(
                children: [
                  _slider(s.physicsSpringMass, _mass, 0.5, 5.0, (v) => setState(() => _mass = v)),
                  _slider(s.physicsSpringStiffness, _stiffness, 50, 300, (v) => setState(() => _stiffness = v)),
                  _slider(s.physicsSpringDamping, _damping, 5, 30, (v) => setState(() => _damping = v)),
                  _slider(s.physicsDragSpeedRatio, _dragSpeedRatio, 0.5, 3.0, (v) => setState(() => _dragSpeedRatio = v)),
                  _slider(s.physicsMaxOverScroll, _maxOverScroll, 30, 200, (v) => setState(() => _maxOverScroll = v)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slider(String label, double value, double min, double max, ValueChanged<double> onChange) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontSize: 12))),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChange,
          ),
        ),
        SizedBox(width: 40, child: Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 12))),
      ],
    );
  }
}
