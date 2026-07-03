/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-26 13:17
*/
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import 'package:flutter/widgets.dart';

/// enable header link other header place outside the viewport
class LinkHeader extends RefreshIndicator {
  /// the key that widget outside viewport indicator
  final GlobalKey linkKey;

  const LinkHeader({super.key, required this.linkKey, double height = 0.0, RefreshStyle? refreshStyle, Duration completeDuration = const Duration(milliseconds: 200)})
      : super(height: height, refreshStyle: refreshStyle, completeDuration: completeDuration);

  @override
  State<StatefulWidget> createState() {
    return _LinkHeaderState();
  }
}

class _LinkHeaderState extends RefreshIndicatorState<LinkHeader> {
  RefreshProcessor? get _processor {
    final state = widget.linkKey.currentState;
    if (state is RefreshProcessor) {
      return state as RefreshProcessor;
    }
    return null;
  }

  @override
  void resetValue() {
    _processor?.resetValue();
  }

  @override
  Future<void> endRefresh() {
    final p = _processor;
    return p != null ? p.endRefresh() : Future.value();
  }

  @override
  void onModeChange(RefreshStatus? mode) {
    _processor?.onModeChange(mode);
  }

  @override
  void onOffsetChange(double offset) {
    _processor?.onOffsetChange(offset);
  }

  @override
  Future<void> readyToRefresh() {
    final p = _processor;
    return p != null ? p.readyToRefresh() : Future.value();
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    return Container();
  }
}

/// enable footer link other footer place outside the viewport
class LinkFooter extends LoadIndicator {
  /// the key that widget outside viewport indicator
  final GlobalKey linkKey;

  const LinkFooter({super.key, required this.linkKey, double height = 0.0, LoadStyle loadStyle = LoadStyle.ShowAlways}) : super(height: height, loadStyle: loadStyle);

  @override
  State<StatefulWidget> createState() {
    return _LinkFooterState();
  }
}

class _LinkFooterState extends LoadIndicatorState<LinkFooter> {
  LoadingProcessor? get _processor {
    final state = widget.linkKey.currentState;
    if (state is LoadingProcessor) {
      return state as LoadingProcessor;
    }
    return null;
  }

  @override
  void onModeChange(LoadStatus? mode) {
    _processor?.onModeChange(mode);
  }

  @override
  void onOffsetChange(double offset) {
    _processor?.onOffsetChange(offset);
  }

  @override
  Widget buildContent(BuildContext context, LoadStatus? mode) {
    return Container();
  }
}
