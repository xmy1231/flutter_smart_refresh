import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widget/sample_data.dart';

class LinkHeaderDemo extends StatefulWidget {
  const LinkHeaderDemo({super.key});

  @override
  State<LinkHeaderDemo> createState() => _LinkHeaderDemoState();
}

class _LinkHeaderDemoState extends State<LinkHeaderDemo> {
  final RefreshController _controller = RefreshController();
  final GlobalKey<ExternalHeaderState> _externalKey = GlobalKey<ExternalHeaderState>();
  List<String> _items = SampleData.generate(count: 20);

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
      appBar: AppBar(
        title: Text(s.appBarLinkHeader),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: ExternalHeader(key: _externalKey),
        ),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _controller,
        header: LinkHeader(linkKey: _externalKey),
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

class ExternalHeader extends StatefulWidget {
  const ExternalHeader({super.key});

  @override
  State<ExternalHeader> createState() => ExternalHeaderState();
}

class ExternalHeaderState extends State<ExternalHeader> with RefreshProcessor {
  RefreshStatus? _mode;
  double _offset = 0;

  @override
  void onModeChange(RefreshStatus? mode) {
    setState(() => _mode = mode);
  }

  @override
  void onOffsetChange(double offset) {
    setState(() => _offset = offset);
  }

  @override
  void resetValue() {
    setState(() {
      _mode = null;
      _offset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!.current;
    return Container(
      height: 40,
      color: Colors.blueAccent.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Text(
        _mode == RefreshStatus.refreshing
            ? s.linkHeaderRefreshing(_offset.toStringAsFixed(0))
            : _mode == RefreshStatus.completed
                ? s.linkHeaderComplete
                : _mode == RefreshStatus.failed
                    ? s.linkHeaderFailed
                    : s.linkHeaderExternalArea,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
