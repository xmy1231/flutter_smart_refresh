import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../l10n/app_localizations.dart';
import '../widget/sample_data.dart';

class RefreshRecordableListDemo extends StatefulWidget {
  const RefreshRecordableListDemo({super.key});

  @override
  State<RefreshRecordableListDemo> createState() => _RefreshRecordableListDemoState();
}

class _RefreshRecordableListDemoState extends State<RefreshRecordableListDemo> {
  final RefreshController _controller = RefreshController();
  final List<_Record> _records = List.generate(10, (i) => _Record('记录 ${i + 1}', false));

  Future<void> _onRefresh() async {
    await SampleData.simulateNetwork();
    setState(() {
      _records.insertAll(0, List.generate(3, (i) => _Record('新记录 ${i + 1}', false)));
    });
    _controller.refreshCompleted();
  }

  void _toggleRecord(int index) {
    setState(() => _records[index].isPlaying = !_records[index].isPlaying);
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
      appBar: AppBar(title: Text(s.appBarRecordableListView)),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        controller: _controller,
        onRefresh: _onRefresh,
        child: ListView.builder(
          itemCount: _records.length,
          itemBuilder: (_, i) {
            final record = _records[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                leading: Icon(
                  record.isPlaying ? Icons.pause_circle : Icons.play_circle,
                  color: record.isPlaying ? Colors.orange : Colors.green,
                  size: 36,
                ),
                title: Text(record.title),
                subtitle: Text(record.isPlaying ? s.recordablePlaying : s.recordablePaused,
                    style: TextStyle(color: record.isPlaying ? Colors.orange : Colors.grey)),
                trailing: IconButton(
                  icon: Icon(record.isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () => _toggleRecord(i),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Record {
  final String title;
  bool isPlaying;
  _Record(this.title, this.isPlaying);
}
