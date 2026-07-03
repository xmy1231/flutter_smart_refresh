import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../l10n/app_localizations.dart';
import '../widget/sample_data.dart';

class RefreshAnimatedListDemo extends StatefulWidget {
  const RefreshAnimatedListDemo({super.key});

  @override
  State<RefreshAnimatedListDemo> createState() => _RefreshAnimatedListDemoState();
}

class _RefreshAnimatedListDemoState extends State<RefreshAnimatedListDemo> {
  final RefreshController _controller = RefreshController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<String> _items = SampleData.generate(count: 10);

  Future<void> _onRefresh() async {
    await SampleData.simulateNetwork();

    final s = AppLocalizations.of(context)!.current;
    final oldCount = _items.length;
    _items = SampleData.generate(count: 10);
    final newCount = _items.length;

    if (newCount > oldCount) {
      for (var i = oldCount; i < newCount; i++) {
        _listKey.currentState?.insertItem(i);
      }
    } else if (newCount < oldCount) {
      for (var i = oldCount - 1; i >= newCount; i--) {
        _listKey.currentState?.removeItem(i, (_, animation) => SizeTransition(
          sizeFactor: animation,
          child: ListTile(title: Text(s.animatedListRemoved)),
        ));
      }
    } else {
      _listKey.currentState?.removeItem(0, (_, animation) => SizeTransition(
        sizeFactor: animation,
        child: const ListTile(title: Text('')),
      ));
      _listKey.currentState?.insertItem(0);
    }

    setState(() {});
    _controller.refreshCompleted();
  }

  void _addItem() {
    final index = _items.length;
    _items.add('新项目 ${index + 1}');
    _listKey.currentState?.insertItem(index);
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
        title: Text(s.appBarAnimatedListRefresh),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addItem),
        ],
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        controller: _controller,
        onRefresh: _onRefresh,
        child: AnimatedList(
          key: _listKey,
          initialItemCount: _items.length,
          itemBuilder: (_, i, animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: ListTile(title: Text(_items[i])),
            );
          },
        ),
      ),
    );
  }
}
