import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widget/sample_data.dart';

class TwoLevelDemo extends StatefulWidget {
  const TwoLevelDemo({super.key});

  @override
  State<TwoLevelDemo> createState() => _TwoLevelDemoState();
}

class _TwoLevelDemoState extends State<TwoLevelDemo> {
  final RefreshController _controller = RefreshController();
  List<String> _items = SampleData.generate(count: 20);
  bool _enableTwoLevel = true;

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

  void _onTwoLevel(bool isOpen) {
    if (isOpen) {
      Future.delayed(const Duration(seconds: 2), () {
        _controller.twoLevelComplete();
      });
    }
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
      appBar: AppBar(
        title: Text(s.appBarTwoLevel),
        actions: [
          TextButton(
            onPressed: () => _controller.requestTwoLevel(),
            child: Text(s.twoLevelOpenSecondFloor),
          ),
        ],
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        enableTwoLevel: _enableTwoLevel,
        onTwoLevel: _onTwoLevel,
        controller: _controller,
        header: TwoLevelHeader(
          twoLevelWidget: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/secondfloor.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Text(
                s.twoLevelSecondFloorContent,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        footer: const ClassicFooter(),
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (_, i) => ListTile(title: Text(_items[i])),
        ),
      ),
    );
  }
}
