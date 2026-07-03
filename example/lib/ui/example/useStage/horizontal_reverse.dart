import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../l10n/app_localizations.dart';

class HorizontalReverseDemo extends StatefulWidget {
  const HorizontalReverseDemo({super.key});

  @override
  State<HorizontalReverseDemo> createState() => _HorizontalReverseDemoState();
}

class _HorizontalReverseDemoState extends State<HorizontalReverseDemo> {
  final RefreshController _controller = RefreshController();
  List<int> _items = List.generate(15, (i) => i + 1);

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _items = List.generate(15, (i) => i + 1));
    _controller.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (_items.length >= 40) {
      _controller.loadNoData();
      return;
    }
    final start = _items.length;
    setState(() => _items = [..._items, ...List.generate(5, (i) => start + i + 1)]);
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
      appBar: AppBar(title: Text(s.appBarHorizontalReverse)),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        scrollDirection: Axis.horizontal,
        reverse: true,
        controller: _controller,
        header: const ClassicHeader(),
        footer: const ClassicFooter(),
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _items.length,
          itemBuilder: (_, i) => Container(
            width: 100,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.primaries[i % Colors.primaries.length].withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text('Item ${_items[i]}')),
          ),
        ),
      ),
    );
  }
}
