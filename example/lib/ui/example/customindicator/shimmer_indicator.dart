import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../widget/sample_data.dart';
import '../../../l10n/app_localizations.dart';

class ShimmerIndicatorDemo extends StatefulWidget {
  const ShimmerIndicatorDemo({super.key});

  @override
  State<ShimmerIndicatorDemo> createState() => _ShimmerIndicatorDemoState();
}

class _ShimmerIndicatorDemoState extends State<ShimmerIndicatorDemo>
    with SingleTickerProviderStateMixin {
  final RefreshController _controller = RefreshController();
  List<String> _items = SampleData.generate(count: 20);
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  void _onRefresh() async {
    _shimmerController.repeat();
    await SampleData.simulateNetwork();
    setState(() => _items = SampleData.generate(count: 20));
    _controller.refreshCompleted();
    _shimmerController.stop();
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
    _shimmerController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!.current;
    return Scaffold(
      appBar: AppBar(title: Text(s.appBarShimmerIndicator)),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _controller,
        header: CustomHeader(
          builder: (context, mode) {
            if (mode == RefreshStatus.refreshing) {
              return AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Container(
                    height: 60,
                    color: Colors.grey[200],
                    child: Stack(
                      children: [
                        Positioned(
                          left: -100,
                          top: 0,
                          bottom: 0,
                          child: AnimatedBuilder(
                            animation: _shimmerAnimation,
                            builder: (_, __) => Container(
                              width: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(alpha: 0.5),
                                    Colors.transparent,
                                  ],
                                  stops: [
                                    _shimmerAnimation.value - 0.5,
                                    _shimmerAnimation.value,
                                    _shimmerAnimation.value + 0.5,
                                  ].map<double>((s) => s.clamp(0, 1)).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Center(child: Text('Loading shimmer...')),
                      ],
                    ),
                  );
                },
              );
            }
            return Container(
              height: 60,
              color: Colors.grey.withValues(alpha: 0.1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            );
          },
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
