import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../widget/sample_data.dart';
import '../../../l10n/app_localizations.dart';

class WaterDropHeaderDemo extends StatefulWidget {
  const WaterDropHeaderDemo({super.key});

  @override
  State<WaterDropHeaderDemo> createState() => _WaterDropHeaderDemoState();
}

class _WaterDropHeaderDemoState extends State<WaterDropHeaderDemo> {
  final RefreshController _controller = RefreshController();
  List<String> _items = SampleData.generate(count: 20);
  Color _waterDropColor = Colors.blue;

  final List<Color> _colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];

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
      appBar: AppBar(title: Text(s.appBarWaterDropHeader)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text('WaterDrop Color: '),
                ..._colors.map((c) => GestureDetector(
                      onTap: () => setState(() => _waterDropColor = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _waterDropColor == c ? Colors.black : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              controller: _controller,
              header: WaterDropHeader(waterDropColor: _waterDropColor),
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
