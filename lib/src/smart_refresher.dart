/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-01 11:39
*/

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import 'package:flutter_smart_refresh/src/internals/slivers.dart';

// ignore_for_file: INVALID_USE_OF_PROTECTED_MEMBER
// ignore_for_file: INVALID_USE_OF_VISIBLE_FOR_TESTING_MEMBER
// ignore_for_file: deprecated_member_use

/// Offset delta for NestedScrollView compatibility
const double _nestedScrollOffsetDelta = 0.0001;

/// Callback when the two-level (二楼) state is toggled.
/// [isOpen] is `true` when entering two-level, `false` when closing.
typedef void OnTwoLevel(bool isOpen);

/// Whether the footer should follow content when the viewport is not full.
typedef bool ShouldFollowContent(LoadStatus? status);

/// Builder for creating a default header or footer indicator.
typedef IndicatorBuilder = Widget Function();

/// Builder that exposes a custom [RefreshPhysics] for advanced scroll behavior.
typedef Widget RefresherBuilder(BuildContext context, RefreshPhysics physics);

/// header state
sealed class RefreshStatus {
  const RefreshStatus();

  /// Initial state, when not being overscrolled into, or after the overscroll
  /// is canceled or after done and the sliver retracted away.
  static const RefreshStatus idle = _RefreshIdle();

  /// Dragged far enough that the onRefresh callback will callback
  static const RefreshStatus canRefresh = _RefreshCanRefresh();

  /// the indicator is refreshing,waiting for the finish callback
  static const RefreshStatus refreshing = _RefreshRefreshing();

  /// the indicator refresh completed
  static const RefreshStatus completed = _RefreshCompleted();

  /// the indicator refresh failed
  static const RefreshStatus failed = _RefreshFailed();

  ///  Dragged far enough that the onTwoLevel callback will callback
  static const RefreshStatus canTwoLevel = _RefreshCanTwoLevel();

  ///  indicator is opening twoLevel
  static const RefreshStatus twoLevelOpening = _RefreshTwoLevelOpening();

  /// indicator is in twoLevel
  static const RefreshStatus twoLeveling = _RefreshTwoLeveling();

  ///  indicator is closing twoLevel
  static const RefreshStatus twoLevelClosing = _RefreshTwoLevelClosing();
}

final class _RefreshIdle extends RefreshStatus {
  const _RefreshIdle();
}

final class _RefreshCanRefresh extends RefreshStatus {
  const _RefreshCanRefresh();
}

final class _RefreshRefreshing extends RefreshStatus {
  const _RefreshRefreshing();
}

final class _RefreshCompleted extends RefreshStatus {
  const _RefreshCompleted();
}

final class _RefreshFailed extends RefreshStatus {
  const _RefreshFailed();
}

final class _RefreshCanTwoLevel extends RefreshStatus {
  const _RefreshCanTwoLevel();
}

final class _RefreshTwoLevelOpening extends RefreshStatus {
  const _RefreshTwoLevelOpening();
}

final class _RefreshTwoLeveling extends RefreshStatus {
  const _RefreshTwoLeveling();
}

final class _RefreshTwoLevelClosing extends RefreshStatus {
  const _RefreshTwoLevelClosing();
}

///  footer state
sealed class LoadStatus {
  const LoadStatus();

  /// Initial state, which can be triggered loading more by gesture pull up
  static const LoadStatus idle = _LoadIdle();

  static const LoadStatus canLoading = _LoadCanLoading();

  /// indicator is loading more data
  static const LoadStatus loading = _LoadLoading();

  /// indicator is no more data to loading,this state doesn't allow to load more whatever
  static const LoadStatus noMore = _LoadNoMore();

  /// indicator load failed,Initial state, which can be click retry,If you need to pull up trigger load more,you should set enableLoadingWhenFailed = true in RefreshConfiguration
  static const LoadStatus failed = _LoadFailed();
}

final class _LoadIdle extends LoadStatus {
  const _LoadIdle();
}

final class _LoadCanLoading extends LoadStatus {
  const _LoadCanLoading();
}

final class _LoadLoading extends LoadStatus {
  const _LoadLoading();
}

final class _LoadNoMore extends LoadStatus {
  const _LoadNoMore();
}

final class _LoadFailed extends LoadStatus {
  const _LoadFailed();
}

/// header indicator display style
enum RefreshStyle {
  // indicator box always follow content
  Follow,
  // indicator box follow content,When the box reaches the top and is fully visible, it does not follow content.
  UnFollow,

  /// Let the indicator size zoom in with the boundary distance,look like showing behind the content
  Behind,

  /// this style just like flutter RefreshIndicator,showing above the content
  Front
}

/// footer indicator display style
enum LoadStyle {
  /// indicator always own layoutExtent whatever the state
  ShowAlways,

  /// indicator always own 0.0 layoutExtent whatever the state
  HideAlways,

  /// indicator always own layoutExtent when loading state, the other state is 0.0 layoutExtent
  ShowWhenLoading
}

/// This is the most important component that provides drop-down refresh and up loading.
/// [RefreshController] must not be null,Only one controller to one SmartRefresher
///
/// header,I have finished a lot indicators,you can checkout [ClassicHeader],[WaterDropMaterialHeader],[MaterialClassicHeader],[WaterDropHeader],[BezierCircleHeader]
/// footer,[ClassicFooter]
///If you need to custom header or footer,You should check out [CustomHeader] or [CustomFooter]
///
/// See also:
///
/// * [RefreshConfiguration], A global configuration for all SmartRefresher in subtrees
///
/// * [RefreshController], A controller controll header and footer  indicators state
class SmartRefresher extends StatefulWidget {
  /// Refresh Content
  ///
  /// notice that: If child is  extends ScrollView,It will help you get the internal slivers and add footer and header in it.
  /// else it will put child into SliverToBoxAdapter and add footer and header
  final Widget? child;

  /// header indicator displace before content
  ///
  /// If reverse is false,header displace at the top of content.
  /// If reverse is true,header displace at the bottom of content.
  /// if scrollDirection = Axis.horizontal,it will display at left or right
  ///
  /// from 1.5.2,it has been change RefreshIndicator to Widget,but remember only pass sliver widget,
  /// if you pass not a sliver,it will throw error
  final Widget? header;

  /// footer indicator display after content
  ///
  /// If reverse is true,header displace at the top of content.
  /// If reverse is false,header displace at the bottom of content.
  /// if scrollDirection = Axis.horizontal,it will display at left or right
  ///
  /// from 1.5.2,it has been change LoadIndicator to Widget,but remember only pass sliver widget,
  //  if you pass not a sliver,it will throw error
  final Widget? footer;
  // This bool will affect whether or not to have the function of drop-up load.
  final bool enablePullUp;

  /// controll whether open the second floor function
  final bool enableTwoLevel;

  /// This bool will affect whether or not to have the function of drop-down refresh.
  final bool enablePullDown;

  /// callback when header refresh
  ///
  /// when the callback is happening,you should use [RefreshController]
  /// to end refreshing state,else it will keep refreshing state
  final VoidCallback? onRefresh;

  /// callback when footer loading more data
  ///
  /// when the callback is happening,you should use [RefreshController]
  /// to end loading state,else it will keep loading state
  final VoidCallback? onLoading;

  /// callback when header ready to twoLevel
  ///
  /// If you want to close twoLevel,you should use [RefreshController.closeTwoLevel]
  final OnTwoLevel? onTwoLevel;

  /// Controll inner state
  final RefreshController controller;

  /// child content builder
  final RefresherBuilder? builder;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final Axis? scrollDirection;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final bool? reverse;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final ScrollController? scrollController;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final bool? primary;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final ScrollPhysics? physics;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final double? cacheExtent;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final int? semanticChildCount;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final DragStartBehavior? dragStartBehavior;

  /// creates a widget help attach the refresh and load more function
  /// controller must not be null,
  /// child is your refresh content,Note that there's a big difference between children inheriting from ScrollView or not.
  /// If child is extends ScrollView,inner will get the slivers from ScrollView,if not,inner will wrap child into SliverToBoxAdapter.
  /// If your child inner container Scrollable,please consider about converting to Sliver,and use CustomScrollView,or use [builder] constructor
  /// such as AnimatedList,RecordableList,doesn't allow to put into child,it will wrap it into SliverToBoxAdapter
  /// If you don't need pull down refresh ,just enablePullDown = false,
  /// If you  need pull up load ,just enablePullUp = true
  SmartRefresher(
      {Key? key,
      required this.controller,
      this.child,
      this.header,
      this.footer,
      this.enablePullDown = true,
      this.enablePullUp = false,
      this.enableTwoLevel = false,
      this.onRefresh,
      this.onLoading,
      this.onTwoLevel,
      this.dragStartBehavior,
      this.primary,
      this.cacheExtent,
      this.semanticChildCount,
      this.reverse,
      this.physics,
      this.scrollDirection,
      this.scrollController})
      : builder = null,
        super(key: key);

  /// creates a widget help attach the refresh and load more function
  /// controller must not be null,builder must not be null
  /// this constructor use to handle some special third party widgets,this widget need to pass slivers ,but they are
  /// not extends ScrollView,so my widget inner will wrap child to SliverToBoxAdapter,which cause scrollable wrapping scrollable.
  /// for example,NestedScrollView is a StalessWidget,it's headerSliversbuilder can return a slivers array,So if we want to do
  /// refresh above NestedScrollVIew,we must use this constrctor to implements refresh above NestedScrollView,but for now,NestedScrollView
  /// can not support overscroll out of edge
  SmartRefresher.builder({
    Key? key,
    required this.controller,
    required this.builder,
    this.enablePullDown = true,
    this.enablePullUp = false,
    this.enableTwoLevel = false,
    this.onRefresh,
    this.onLoading,
    this.onTwoLevel,
  })  : header = null,
        footer = null,
        child = null,
        scrollController = null,
        scrollDirection = null,
        physics = null,
        reverse = null,
        semanticChildCount = null,
        dragStartBehavior = null,
        cacheExtent = null,
        primary = null,
        super(key: key);

  static SmartRefresher? of(BuildContext? context) {
    if (context == null) return null;
    return context.findAncestorWidgetOfExactType<SmartRefresher>();
  }

  static SmartRefresherState? ofState(BuildContext? context) {
    if (context == null) return null;
    return context.findAncestorStateOfType<SmartRefresherState>();
  }

  @override
  State<StatefulWidget> createState() {
    return SmartRefresherState();
  }
}

class SmartRefresherState extends State<SmartRefresher> {
  RefreshPhysics? _physics;
  bool _updatePhysics = false;
  double viewportExtent = 0;
  bool _canDrag = true;

  final RefreshIndicator defaultHeader = defaultTargetPlatform == TargetPlatform.iOS ? ClassicHeader() : MaterialClassicHeader();

  final LoadIndicator defaultFooter = ClassicFooter();

  //build slivers from child Widget
  List<Widget>? _buildSliversByChild(BuildContext context, Widget? child, RefreshConfiguration? configuration) {
    List<Widget>? slivers;
    if (child is ScrollView) {
      if (child is BoxScrollView) {
        //avoid system inject padding when own indicator top or bottom
        Widget sliver = child.buildChildLayout(context);
        if (child.padding != null) {
          slivers = [SliverPadding(sliver: sliver, padding: child.padding!)];
        } else {
          slivers = [sliver];
        }
      } else {
        slivers = List.from(child.buildSlivers(context), growable: true);
      }
    } else if (child is! Scrollable) {
      slivers = [
        SliverRefreshBody(
          child: child ?? Container(),
        )
      ];
    }
    if (widget.enablePullDown || widget.enableTwoLevel) {
      slivers?.insert(0, widget.header ?? (configuration?.headerBuilder != null ? configuration?.headerBuilder!() : null) ?? defaultHeader);
    }
    //insert header or footer
    if (widget.enablePullUp) {
      slivers?.add(widget.footer ?? (configuration?.footerBuilder != null ? configuration?.footerBuilder!() : null) ?? defaultFooter);
    }

    return slivers;
  }

  ScrollPhysics _getScrollPhysics(RefreshConfiguration? conf, ScrollPhysics physics) {
    final bool isBouncingPhysics = physics is BouncingScrollPhysics ||
        (physics is AlwaysScrollableScrollPhysics && ScrollConfiguration.of(context).getScrollPhysics(context).runtimeType == BouncingScrollPhysics);
    return _physics = RefreshPhysics(
            dragSpeedRatio: conf?.dragSpeedRatio ?? 1,
            springDescription: conf?.springDescription ??
                const SpringDescription(
                  mass: 1.0,
                  stiffness: 364.718677686,
                  damping: 35.2,
                ),
            controller: widget.controller,
            enableScrollWhenTwoLevel: conf?.enableScrollWhenTwoLevel ?? true,
            updateFlag: _updatePhysics ? 0 : 1,
            enableScrollWhenRefreshCompleted: conf?.enableScrollWhenRefreshCompleted ?? false,
            maxUnderScrollExtent: conf?.maxUnderScrollExtent ?? (isBouncingPhysics ? double.infinity : 0.0),
            maxOverScrollExtent: conf?.maxOverScrollExtent ?? (isBouncingPhysics ? double.infinity : 60.0),
            topHitBoundary: conf?.topHitBoundary ?? (isBouncingPhysics ? double.infinity : 0.0),
            bottomHitBoundary: conf?.bottomHitBoundary ?? (isBouncingPhysics ? double.infinity : 0.0))
        .applyTo(!_canDrag ? NeverScrollableScrollPhysics() : physics);
  }

  // build the customScrollView
  Widget? _buildBodyBySlivers(Widget? childView, List<Widget>? slivers, RefreshConfiguration? conf) {
    Widget? body;
    if (childView is! Scrollable) {
      bool? primary = widget.primary;
      Key? key;
      double? cacheExtent = widget.cacheExtent;

      Axis? scrollDirection = widget.scrollDirection;
      int? semanticChildCount = widget.semanticChildCount;
      bool? reverse = widget.reverse;
      ScrollController? scrollController = widget.scrollController;
      DragStartBehavior? dragStartBehavior = widget.dragStartBehavior;
      ScrollPhysics? physics = widget.physics;
      Key? center;
      double? anchor;
      ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;
      String? restorationId;
      Clip? clipBehavior;

      if (childView is ScrollView) {
        primary = primary ?? childView.primary;
        cacheExtent = cacheExtent ?? childView.cacheExtent;
        key = key ?? childView.key;
        semanticChildCount = semanticChildCount ?? childView.semanticChildCount;
        reverse = reverse ?? childView.reverse;
        dragStartBehavior = dragStartBehavior ?? childView.dragStartBehavior;
        scrollDirection = scrollDirection ?? childView.scrollDirection;
        physics = physics ?? childView.physics;
        center = center ?? childView.center;
        anchor = anchor ?? childView.anchor;
        keyboardDismissBehavior = keyboardDismissBehavior ?? childView.keyboardDismissBehavior;
        restorationId = restorationId ?? childView.restorationId;
        clipBehavior = clipBehavior ?? childView.clipBehavior;
        scrollController = scrollController ?? childView.controller;
      }
      body = CustomScrollView(
        controller: scrollController,
        cacheExtent: cacheExtent,
        key: key,
        scrollDirection: scrollDirection ?? Axis.vertical,
        semanticChildCount: semanticChildCount,
        primary: primary,
        clipBehavior: clipBehavior ?? Clip.hardEdge,
        keyboardDismissBehavior: keyboardDismissBehavior ?? ScrollViewKeyboardDismissBehavior.manual,
        anchor: anchor ?? 0.0,
        restorationId: restorationId,
        center: center,
        physics: _getScrollPhysics(conf, physics ?? AlwaysScrollableScrollPhysics()),
        slivers: slivers!,
        dragStartBehavior: dragStartBehavior ?? DragStartBehavior.start,
        reverse: reverse ?? false,
      );
    } else {
      body = Scrollable(
        physics: _getScrollPhysics(conf, childView.physics ?? AlwaysScrollableScrollPhysics()),
        controller: childView.controller,
        axisDirection: childView.axisDirection,
        semanticChildCount: childView.semanticChildCount,
        dragStartBehavior: childView.dragStartBehavior,
        viewportBuilder: (context, offset) {
          Viewport viewport = childView.viewportBuilder(context, offset) as Viewport;
          final slivers = <Widget>[...viewport.children];
          if (widget.enablePullDown) {
            slivers.insert(0, widget.header ?? (conf?.headerBuilder != null ? conf?.headerBuilder!() : null) ?? defaultHeader);
          }
          if (widget.enablePullUp) {
            slivers.add(widget.footer ?? (conf?.footerBuilder != null ? conf?.footerBuilder!() : null) ?? defaultFooter);
          }
          return Viewport(
            key: viewport.key,
            axisDirection: viewport.axisDirection,
            offset: viewport.offset,
            anchor: viewport.anchor,
            slivers: slivers,
          );
        },
      );
    }
    return body;
  }

  bool _ifNeedUpdatePhysics() {
    RefreshConfiguration? conf = RefreshConfiguration.of(context);
    if (conf == null || _physics == null) {
      return false;
    }

    if (conf.topHitBoundary != _physics!.topHitBoundary ||
        _physics!.bottomHitBoundary != conf.bottomHitBoundary ||
        conf.maxOverScrollExtent != _physics!.maxOverScrollExtent ||
        _physics!.maxUnderScrollExtent != conf.maxUnderScrollExtent ||
        _physics!.dragSpeedRatio != conf.dragSpeedRatio ||
        _physics!.enableScrollWhenTwoLevel != conf.enableScrollWhenTwoLevel ||
        _physics!.enableScrollWhenRefreshCompleted != conf.enableScrollWhenRefreshCompleted) {
      return true;
    }
    return false;
  }

  void setCanDrag(bool canDrag) {
    if (_canDrag == canDrag) {
      return;
    }
    setState(() {
      _canDrag = canDrag;
    });
  }

  @override
  void didUpdateWidget(SmartRefresher oldWidget) {
    if (widget.controller != oldWidget.controller) {
      widget.controller.headerMode!.value = oldWidget.controller.headerMode!.value;
      widget.controller.footerMode!.value = oldWidget.controller.footerMode!.value;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ifNeedUpdatePhysics()) {
      _updatePhysics = !_updatePhysics;
    }
  }

  @override
  void initState() {
    if (widget.controller.initialRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //  if mounted,it avoid one situation: when init done,then dispose the widget before build.
        //  this   situation mostly TabBarView
        if (mounted) widget.controller.requestRefresh();
      });
    }
    widget.controller._bindState(this);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller._detachPosition();
    if (widget.controller.autoCleanup) {
      widget.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RefreshConfiguration? configuration = RefreshConfiguration.of(context);
    Widget? body;
    if (widget.builder != null)
      body = widget.builder!(context, _getScrollPhysics(configuration, AlwaysScrollableScrollPhysics()) as RefreshPhysics);
    else {
      List<Widget>? slivers = _buildSliversByChild(context, widget.child, configuration);
      body = _buildBodyBySlivers(widget.child, slivers, configuration);
    }
    if (configuration == null) {
      body = RefreshConfiguration(child: body!);
    }
    return LayoutBuilder(
      builder: (c2, cons) {
        viewportExtent = cons.biggest.height;
        return body!;
      },
    );
  }
}

/// A controller controll header and footer state,
/// it  can trigger  driving request Refresh ,set the initalRefresh,status if needed
///
/// See also:
///
/// * [SmartRefresher],a widget help you attach refresh and load more function easily
class RefreshController {
  SmartRefresherState? _refresherState;

  /// header status mode controll
  RefreshNotifier<RefreshStatus>? headerMode;

  /// footer status mode controll
  RefreshNotifier<LoadStatus>? footerMode;

  /// the scrollable inner's position
  ///
  /// notice that: position is null before build,
  /// the value is get when the header or footer callback onPositionUpdated
  ScrollPosition? position;

  RefreshStatus? get headerStatus => headerMode?.value;

  LoadStatus? get footerStatus => footerMode?.value;

  bool get isRefresh => headerMode?.value == RefreshStatus.refreshing;

  bool get isTwoLevel => headerMode?.value == RefreshStatus.twoLeveling || headerMode?.value == RefreshStatus.twoLevelOpening || headerMode?.value == RefreshStatus.twoLevelClosing;

  bool get isLoading => footerMode?.value == LoadStatus.loading;

  /// A broadcast stream that emits header status changes
  Stream<RefreshStatus?> get headerStatusStream => headerMode?.stream ?? const Stream.empty();

  /// A broadcast stream that emits footer status changes
  Stream<LoadStatus?> get footerStatusStream => footerMode?.stream ?? const Stream.empty();

  final bool initialRefresh;

  /// when true,controller resources are automatically disposed when SmartRefresher is destroyed
  final bool autoCleanup;

  /// initialRefresh:When SmartRefresher is init,it will call requestRefresh at once
  ///
  /// initialRefreshStatus: headerMode default value
  ///
  /// initialLoadStatus: footerMode default value
  ///
  /// autoCleanup: when true,controller resources are automatically disposed when SmartRefresher is destroyed
  RefreshController({this.initialRefresh = false, this.autoCleanup = true, RefreshStatus? initialRefreshStatus, LoadStatus? initialLoadStatus}) {
    headerMode = RefreshNotifier(initialRefreshStatus ?? RefreshStatus.idle);
    footerMode = RefreshNotifier(initialLoadStatus ?? LoadStatus.idle);
  }

  void _bindState(SmartRefresherState state) {
    assert(_refresherState == null, "Don't use one refreshController to multiple SmartRefresher,It will cause some unexpected bugs mostly in TabBarView");
    _refresherState = state;
  }

  /// callback when the indicator is builded,and catch the scrollable's inner position
  void onPositionUpdated(ScrollPosition newPosition) {
    position?.isScrollingNotifier.removeListener(_listenScrollEnd);
    position = newPosition;
    position!.isScrollingNotifier.addListener(_listenScrollEnd);
  }

  void _detachPosition() {
    _refresherState = null;
    position?.isScrollingNotifier.removeListener(_listenScrollEnd);
  }

  StatefulElement? _findIndicator(BuildContext context, Type elementType) {
    StatefulElement? result;
    context.visitChildElements((Element e) {
      if (elementType == RefreshIndicator) {
        if (e.widget is RefreshIndicator) {
          result = e as StatefulElement?;
        }
      } else {
        if (e.widget is LoadIndicator) {
          result = e as StatefulElement?;
        }
      }

      result ??= _findIndicator(e, elementType);
    });
    return result;
  }

  /// when bounce out of edge and stopped by overScroll or underScroll, it should be SpringBack to 0.0
  /// but ScrollPhysics didn't provide one way to spring back when outOfEdge(stopped by applyBouncingCondition return != 0.0)
  /// so for making it spring back, it should be trigger goBallistic make it spring back
  void _listenScrollEnd() {
    if (position != null && position!.outOfRange) {
      position?.activity?.applyNewDimensions();
    }
  }

  /// make the header enter refreshing state,and callback onRefresh
  Future<void> requestRefresh({bool needMove = true, bool needCallback = true, Duration duration = const Duration(milliseconds: 500), Curve curve = Curves.linear}) {
    assert(position != null, 'Try not to call requestRefresh() before build,please call after the ui was rendered');
    if (isRefresh) return Future.value();
    StatefulElement? indicatorElement = _findIndicator(position!.context.storageContext, RefreshIndicator);

    if (indicatorElement == null || _refresherState == null) return Future.value();
    (indicatorElement.state as RefreshIndicatorState).floating = true;

    if (needMove && _refresherState!.mounted) _refresherState!.setCanDrag(false);
    if (needMove) {
      return Future.delayed(const Duration(milliseconds: 50)).then((_) async {
        // NestedScrollView compatibility offset
        await position?.animateTo(position!.minScrollExtent - _nestedScrollOffsetDelta, duration: duration, curve: curve).then((_) {
          if (_refresherState != null && _refresherState!.mounted) {
            _refresherState!.setCanDrag(true);
            if (needCallback) {
              headerMode!.value = RefreshStatus.refreshing;
            } else {
              headerMode!.setValueWithNoNotify(RefreshStatus.refreshing);
              if (indicatorElement.state.mounted) (indicatorElement.state as RefreshIndicatorState).setState(() {});
            }
          }
        });
      });
    } else {
      Future.value().then((_) {
        headerMode!.value = RefreshStatus.refreshing;
      });
    }
    return Future.value();
  }

  /// make the header enter refreshing state,and callback onRefresh
  Future<void> requestTwoLevel({Duration duration = const Duration(milliseconds: 300), Curve curve = Curves.linear}) {
    assert(position != null, 'Try not to call requestRefresh() before build,please call after the ui was rendered');
    headerMode!.value = RefreshStatus.twoLevelOpening;
    return Future.delayed(const Duration(milliseconds: 50)).then((_) async {
      await position?.animateTo(position!.minScrollExtent, duration: duration, curve: curve);
    });
  }

  /// make the footer enter loading state,and callback onLoading
  Future<void> requestLoading({bool needMove = true, bool needCallback = true, Duration duration = const Duration(milliseconds: 300), Curve curve = Curves.linear}) {
    assert(position != null, 'Try not to call requestLoading() before build,please call after the ui was rendered');
    if (isLoading) return Future.value();
    StatefulElement? indicatorElement = _findIndicator(position!.context.storageContext, LoadIndicator);

    if (indicatorElement == null || _refresherState == null) return Future.value();
    (indicatorElement.state as LoadIndicatorState).floating = true;
    final bool notFull = position!.minScrollExtent == position!.maxScrollExtent;
    if (needMove && !notFull && _refresherState!.mounted) _refresherState!.setCanDrag(false);
    if (needMove && !notFull) {
      return Future.delayed(const Duration(milliseconds: 50)).then((_) async {
        await position?.animateTo(position!.maxScrollExtent, duration: duration, curve: curve).then((_) {
          if (_refresherState != null && _refresherState!.mounted) {
            _refresherState!.setCanDrag(true);
            if (needCallback) {
              footerMode!.value = LoadStatus.loading;
            } else {
              footerMode!.setValueWithNoNotify(LoadStatus.loading);
              if (indicatorElement.state.mounted) (indicatorElement.state as LoadIndicatorState).setState(() {});
            }
          }
        });
      });
    } else {
      return Future.value().then((_) {
        footerMode!.value = LoadStatus.loading;
      });
    }
  }

  /// request complete,the header will enter complete state,
  ///
  /// resetFooterState : it will set the footer state from noData to idle
  void refreshCompleted({bool resetFooterState = false}) {
    headerMode?.value = RefreshStatus.completed;
    if (resetFooterState) {
      resetNoData();
    }
  }

  /// end twoLeveling,will return back first floor
  Future<void>? twoLevelComplete({Duration duration = const Duration(milliseconds: 500), Curve curve = Curves.linear}) {
    headerMode?.value = RefreshStatus.twoLevelClosing;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pos = position;
      if (pos == null) return;
      pos.animateTo(0.0, duration: duration, curve: curve).whenComplete(() {
        headerMode?.value = RefreshStatus.idle;
      });
    });
    return null;
  }

  /// request failed,the header display failed state
  void refreshFailed() {
    headerMode?.value = RefreshStatus.failed;
  }

  /// not show success or failed, it will set header state to idle and spring back at once
  void refreshToIdle() {
    headerMode?.value = RefreshStatus.idle;
  }

  /// after data returned,set the footer state to idle
  void loadComplete() {
    // change state after ui update,else it will have a bug:twice loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      footerMode?.value = LoadStatus.idle;
    });
  }

  /// If catchError happen,you may call loadFailed indicate fetch data from network failed
  void loadFailed() {
    // change state after ui update,else it will have a bug:twice loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      footerMode?.value = LoadStatus.failed;
    });
  }

  /// load more success without error,but no data returned
  void loadNoData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      footerMode?.value = LoadStatus.noMore;
    });
  }

  /// reset footer noData state  to idle
  void resetNoData() {
    if (footerMode?.value == LoadStatus.noMore) {
      footerMode!.value = LoadStatus.idle;
    }
  }

  /// for some special situation, you should call dispose() for safe,it may throw errors after parent widget dispose
  void dispose() {
    headerMode?.dispose();
    footerMode?.dispose();
    headerMode = null;
    footerMode = null;
  }
}

/// Controls how SmartRefresher widgets behave in a subtree.the usage just like [ScrollConfiguration]
///
/// The refresh configuration determines smartRefresher some behaviours,global setting default indicator
///
/// see also:
///
/// * [SmartRefresher], a widget help attach the refresh and load more function
class RefreshConfiguration extends InheritedWidget {
  final Widget child;

  /// global default header builder
  final IndicatorBuilder? headerBuilder;

  /// global default footer builder
  final IndicatorBuilder? footerBuilder;

  /// custom spring animate
  final SpringDescription springDescription;

  /// If need to refreshing now when reaching triggerDistance
  final bool skipCanRefresh;

  /// if it should follow content for different state
  final ShouldFollowContent? shouldFooterFollowWhenNotFull;

  /// when listView data small(not enough one page) , it should be hide
  final bool hideFooterWhenNotFull;

  /// whether user can drag viewport when twoLeveling
  final bool enableScrollWhenTwoLevel;

  /// whether user can drag viewport when refresh complete and spring back
  final bool enableScrollWhenRefreshCompleted;

  /// whether trigger refresh by  BallisticScrollActivity
  final bool enableBallisticRefresh;

  /// whether trigger loading by  BallisticScrollActivity
  final bool enableBallisticLoad;

  /// whether footer can trigger load by reaching footerDistance when failed state
  final bool enableLoadingWhenFailed;

  /// whether footer can trigger load by reaching footerDistance when inNoMore state
  final bool enableLoadingWhenNoData;

  /// overScroll distance of trigger refresh
  final double headerTriggerDistance;

  ///	the overScroll distance of trigger twoLevel
  final double twiceTriggerDistance;

  /// Close the bottom crossing distance on the second floor, premise:enableScrollWhenTwoLevel is true
  final double closeTwoLevelDistance;

  /// the extentAfter distance of trigger loading
  final double footerTriggerDistance;

  /// the speed ratio when dragging overscroll ,compute=origin physics dragging speed *dragSpeedRatio
  final double dragSpeedRatio;

  /// max overScroll distance when out of edge
  final double? maxOverScrollExtent;

  /// 	max underScroll distance when out of edge
  final double? maxUnderScrollExtent;

  /// The boundary is located at the top edge and stops when inertia rolls over the boundary distance
  final double? topHitBoundary;

  /// The boundary is located at the bottom edge and stops when inertia rolls under the boundary distance
  final double? bottomHitBoundary;

  /// toggle of  refresh vibrate
  final bool enableRefreshVibrate;

  /// toggle of  loadmore vibrate
  final bool enableLoadMoreVibrate;

  RefreshConfiguration(
      {Key? key,
      required this.child,
      this.headerBuilder,
      this.footerBuilder,
      this.dragSpeedRatio = 1.0,
      this.shouldFooterFollowWhenNotFull,
      this.enableScrollWhenTwoLevel = true,
      this.enableLoadingWhenNoData = false,
      this.enableBallisticRefresh = false,
      this.springDescription = const SpringDescription(
        mass: 1.0,
        stiffness: 364.718677686,
        damping: 35.2,
      ),
      this.enableScrollWhenRefreshCompleted = false,
      this.enableLoadingWhenFailed = true,
      this.twiceTriggerDistance = 150.0,
      this.closeTwoLevelDistance = 80.0,
      this.skipCanRefresh = false,
      this.maxOverScrollExtent,
      this.enableBallisticLoad = true,
      this.maxUnderScrollExtent,
      this.headerTriggerDistance = 80.0,
      this.footerTriggerDistance = 15.0,
      this.hideFooterWhenNotFull = false,
      this.enableRefreshVibrate = false,
      this.enableLoadMoreVibrate = false,
      this.topHitBoundary,
      this.bottomHitBoundary})
      : assert(headerTriggerDistance > 0),
        assert(twiceTriggerDistance > 0),
        assert(closeTwoLevelDistance > 0),
        assert(dragSpeedRatio > 0),
        super(key: key, child: child);

  RefreshConfiguration copyWith({
    Widget? child,
    IndicatorBuilder? headerBuilder,
    IndicatorBuilder? footerBuilder,
    double? dragSpeedRatio,
    ShouldFollowContent? shouldFooterFollowWhenNotFull,
    bool? enableScrollWhenTwoLevel,
    bool? enableBallisticRefresh,
    bool? enableBallisticLoad,
    bool? enableLoadingWhenNoData,
    SpringDescription? springDescription,
    bool? enableScrollWhenRefreshCompleted,
    bool? enableLoadingWhenFailed,
    double? twiceTriggerDistance,
    double? closeTwoLevelDistance,
    bool? skipCanRefresh,
    double? maxOverScrollExtent,
    double? maxUnderScrollExtent,
    double? topHitBoundary,
    double? bottomHitBoundary,
    double? headerTriggerDistance,
    double? footerTriggerDistance,
    bool? enableRefreshVibrate,
    bool? enableLoadMoreVibrate,
    bool? hideFooterWhenNotFull,
  }) {
    return RefreshConfiguration(
      key: this.key,
      child: child ?? this.child,
      headerBuilder: headerBuilder ?? this.headerBuilder,
      footerBuilder: footerBuilder ?? this.footerBuilder,
      dragSpeedRatio: dragSpeedRatio ?? this.dragSpeedRatio,
      shouldFooterFollowWhenNotFull: shouldFooterFollowWhenNotFull ?? this.shouldFooterFollowWhenNotFull,
      enableScrollWhenTwoLevel: enableScrollWhenTwoLevel ?? this.enableScrollWhenTwoLevel,
      enableBallisticRefresh: enableBallisticRefresh ?? this.enableBallisticRefresh,
      enableBallisticLoad: enableBallisticLoad ?? this.enableBallisticLoad,
      enableLoadingWhenNoData: enableLoadingWhenNoData ?? this.enableLoadingWhenNoData,
      springDescription: springDescription ?? this.springDescription,
      enableScrollWhenRefreshCompleted: enableScrollWhenRefreshCompleted ?? this.enableScrollWhenRefreshCompleted,
      enableLoadingWhenFailed: enableLoadingWhenFailed ?? this.enableLoadingWhenFailed,
      twiceTriggerDistance: twiceTriggerDistance ?? this.twiceTriggerDistance,
      closeTwoLevelDistance: closeTwoLevelDistance ?? this.closeTwoLevelDistance,
      skipCanRefresh: skipCanRefresh ?? this.skipCanRefresh,
      maxOverScrollExtent: maxOverScrollExtent ?? this.maxOverScrollExtent,
      maxUnderScrollExtent: maxUnderScrollExtent ?? this.maxUnderScrollExtent,
      topHitBoundary: topHitBoundary ?? this.topHitBoundary,
      bottomHitBoundary: bottomHitBoundary ?? this.bottomHitBoundary,
      headerTriggerDistance: headerTriggerDistance ?? this.headerTriggerDistance,
      footerTriggerDistance: footerTriggerDistance ?? this.footerTriggerDistance,
      enableRefreshVibrate: enableRefreshVibrate ?? this.enableRefreshVibrate,
      enableLoadMoreVibrate: enableLoadMoreVibrate ?? this.enableLoadMoreVibrate,
      hideFooterWhenNotFull: hideFooterWhenNotFull ?? this.hideFooterWhenNotFull,
    );
  }

  /// Construct RefreshConfiguration to copy attributes from ancestor nodes
  /// If the parameter is null, it will automatically help you to absorb the attributes of your ancestor Refresh Configuration, instead of having to copy them manually by yourself.
  ///
  /// it mostly use in some stiuation is different the other SmartRefresher in App
  @Deprecated('Use RefreshConfiguration.copyWith() instead. This will be removed in v4.0.')
  RefreshConfiguration.copyAncestor({
    Key? key,
    required BuildContext context,
    required this.child,
    IndicatorBuilder? headerBuilder,
    IndicatorBuilder? footerBuilder,
    double? dragSpeedRatio,
    ShouldFollowContent? shouldFooterFollowWhenNotFull,
    bool? enableScrollWhenTwoLevel,
    bool? enableBallisticRefresh,
    bool? enableBallisticLoad,
    bool? enableLoadingWhenNoData,
    SpringDescription? springDescription,
    bool? enableScrollWhenRefreshCompleted,
    bool? enableLoadingWhenFailed,
    double? twiceTriggerDistance,
    double? closeTwoLevelDistance,
    bool? skipCanRefresh,
    double? maxOverScrollExtent,
    double? maxUnderScrollExtent,
    double? topHitBoundary,
    double? bottomHitBoundary,
    double? headerTriggerDistance,
    double? footerTriggerDistance,
    bool? enableRefreshVibrate,
    bool? enableLoadMoreVibrate,
    bool? hideFooterWhenNotFull,
  })  : assert(RefreshConfiguration.of(context) != null,
            "search RefreshConfiguration anscestor return null,please  Make sure that RefreshConfiguration is the ancestor of that element"),
        headerBuilder = headerBuilder ?? RefreshConfiguration.of(context)!.headerBuilder,
        footerBuilder = footerBuilder ?? RefreshConfiguration.of(context)!.footerBuilder,
        dragSpeedRatio = dragSpeedRatio ?? RefreshConfiguration.of(context)!.dragSpeedRatio,
        twiceTriggerDistance = twiceTriggerDistance ?? RefreshConfiguration.of(context)!.twiceTriggerDistance,
        headerTriggerDistance = headerTriggerDistance ?? RefreshConfiguration.of(context)!.headerTriggerDistance,
        footerTriggerDistance = footerTriggerDistance ?? RefreshConfiguration.of(context)!.footerTriggerDistance,
        springDescription = springDescription ?? RefreshConfiguration.of(context)!.springDescription,
        hideFooterWhenNotFull = hideFooterWhenNotFull ?? RefreshConfiguration.of(context)!.hideFooterWhenNotFull,
        maxOverScrollExtent = maxOverScrollExtent ?? RefreshConfiguration.of(context)!.maxOverScrollExtent,
        maxUnderScrollExtent = maxUnderScrollExtent ?? RefreshConfiguration.of(context)!.maxUnderScrollExtent,
        topHitBoundary = topHitBoundary ?? RefreshConfiguration.of(context)!.topHitBoundary,
        bottomHitBoundary = bottomHitBoundary ?? RefreshConfiguration.of(context)!.bottomHitBoundary,
        skipCanRefresh = skipCanRefresh ?? RefreshConfiguration.of(context)!.skipCanRefresh,
        enableScrollWhenRefreshCompleted = enableScrollWhenRefreshCompleted ?? RefreshConfiguration.of(context)!.enableScrollWhenRefreshCompleted,
        enableScrollWhenTwoLevel = enableScrollWhenTwoLevel ?? RefreshConfiguration.of(context)!.enableScrollWhenTwoLevel,
        enableBallisticRefresh = enableBallisticRefresh ?? RefreshConfiguration.of(context)!.enableBallisticRefresh,
        enableBallisticLoad = enableBallisticLoad ?? RefreshConfiguration.of(context)!.enableBallisticLoad,
        enableLoadingWhenNoData = enableLoadingWhenNoData ?? RefreshConfiguration.of(context)!.enableLoadingWhenNoData,
        enableLoadingWhenFailed = enableLoadingWhenFailed ?? RefreshConfiguration.of(context)!.enableLoadingWhenFailed,
        closeTwoLevelDistance = closeTwoLevelDistance ?? RefreshConfiguration.of(context)!.closeTwoLevelDistance,
        enableRefreshVibrate = enableRefreshVibrate ?? RefreshConfiguration.of(context)!.enableRefreshVibrate,
        enableLoadMoreVibrate = enableLoadMoreVibrate ?? RefreshConfiguration.of(context)!.enableLoadMoreVibrate,
        shouldFooterFollowWhenNotFull = shouldFooterFollowWhenNotFull ?? RefreshConfiguration.of(context)!.shouldFooterFollowWhenNotFull,
        super(key: key, child: child);

  static RefreshConfiguration? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RefreshConfiguration>();
  }

  @override
  bool updateShouldNotify(RefreshConfiguration oldWidget) {
    return skipCanRefresh != oldWidget.skipCanRefresh ||
        hideFooterWhenNotFull != oldWidget.hideFooterWhenNotFull ||
        dragSpeedRatio != oldWidget.dragSpeedRatio ||
        enableScrollWhenRefreshCompleted != oldWidget.enableScrollWhenRefreshCompleted ||
        enableBallisticRefresh != oldWidget.enableBallisticRefresh ||
        enableScrollWhenTwoLevel != oldWidget.enableScrollWhenTwoLevel ||
        closeTwoLevelDistance != oldWidget.closeTwoLevelDistance ||
        footerTriggerDistance != oldWidget.footerTriggerDistance ||
        headerTriggerDistance != oldWidget.headerTriggerDistance ||
        twiceTriggerDistance != oldWidget.twiceTriggerDistance ||
        maxUnderScrollExtent != oldWidget.maxUnderScrollExtent ||
        oldWidget.maxOverScrollExtent != maxOverScrollExtent ||
        enableBallisticRefresh != oldWidget.enableBallisticRefresh ||
        enableLoadingWhenFailed != oldWidget.enableLoadingWhenFailed ||
        topHitBoundary != oldWidget.topHitBoundary ||
        enableRefreshVibrate != oldWidget.enableRefreshVibrate ||
        enableLoadMoreVibrate != oldWidget.enableLoadMoreVibrate ||
        bottomHitBoundary != oldWidget.bottomHitBoundary;
  }
}

class RefreshNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  /// Creates a [ChangeNotifier] that wraps this value.
  RefreshNotifier(this._value);
  T _value;

  @override
  T get value => _value;

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifyListeners();
  }

  void setValueWithNoNotify(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
  }

  /// A broadcast stream that emits the current value and all subsequent changes.
  Stream<T> get stream {
    return Stream<T>.multi((controller) {
      controller.add(value);
      final listener = () => controller.add(value);
      addListener(listener);
      controller.onCancel = () => removeListener(listener);
    });
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}
