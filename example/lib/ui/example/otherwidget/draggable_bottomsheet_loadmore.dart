import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widget/sample_data.dart';

class DraggableBottomSheetDemo extends StatefulWidget {
  const DraggableBottomSheetDemo({super.key});

  @override
  State<DraggableBottomSheetDemo> createState() => _DraggableBottomSheetDemoState();
}

class _DraggableBottomSheetDemoState extends State<DraggableBottomSheetDemo> {
  final RefreshController _controller = RefreshController();
  List<String> _items = SampleData.generate(count: 10);

  Future<void> _onLoading() async {
    await SampleData.simulateNetwork();
    if (_items.length >= 30) { _controller.loadNoData(); return; }
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
      appBar: AppBar(title: Text(s.appBarDraggableSheetLoadMore)),
      body: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: true,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
              ],
            ),
            child: SmartRefresher(
              enablePullDown: false,
              enablePullUp: true,
              controller: _controller,
              onLoading: _onLoading,
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _items.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Center(
                        child: Text(s.draggableSheetHint,
                            style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  }
                  return ListTile(title: Text(_items[i - 1]));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
