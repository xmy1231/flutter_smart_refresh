import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';

import 'l10n/app_localizations.dart';
import 'ui/example/useStage/basic.dart';
import 'ui/example/useStage/grid_view_example.dart';
import 'ui/example/useStage/custom_scroll_view_example.dart';
import 'ui/example/styles/refresh_style_demo.dart';
import 'ui/example/styles/load_style_demo.dart';
import 'ui/example/indicators/classic_indicator_demo.dart';
import 'ui/example/indicators/waterdrop_header_demo.dart';
import 'ui/example/indicators/material_classic_demo.dart';
import 'ui/example/indicators/waterdrop_material_demo.dart';
import 'ui/example/indicators/bezier_circle_demo.dart';
import 'ui/example/customindicator/custom_header_builder.dart';
import 'ui/example/customindicator/custom_footer_builder.dart';
import 'ui/example/customindicator/spinkit_header.dart';
import 'ui/example/customindicator/gif_indicator_example1.dart';
import 'ui/example/customindicator/shimmer_indicator.dart';
import 'ui/example/customindicator/link_header_example.dart';
import 'ui/example/useStage/twolevel_refresh.dart';
import 'ui/example/useStage/horizontal_reverse.dart';
import 'ui/example/useStage/qq_chat_list.dart';
import 'ui/example/configuration/global_config_demo.dart';
import 'ui/example/configuration/physics_and_behavior_demo.dart';
import 'ui/example/configuration/special_toggles_demo.dart';
import 'ui/example/otherwidget/draggable_bottomsheet_loadmore.dart';
import 'other/refresh_animatedlist.dart';
import 'other/refresh_recordable_listview.dart';
import 'ui/example/localization/language_switch_demo.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>();
  }
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartRefresher Demo',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: [
        ...GlobalMaterialLocalizations.delegates,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        RefreshLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
        Locale('zh', 'CN'),
        Locale('zh', 'HK'),
        Locale('zh', 'TW'),
        Locale('ja'),
        Locale('ko'),
        Locale('de'),
        Locale('fr'),
        Locale('es'),
        Locale('pt'),
        Locale('ar'),
        Locale('th'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: RefreshConfiguration(
        springDescription: SpringDescription(
            mass: 1.0, stiffness: 364.718677686, damping: 35.2),
        headerTriggerDistance: 80.0,
        footerTriggerDistance: 80.0,
        hideFooterWhenNotFull: true,
        maxOverScrollExtent: 100.0,
        enableLoadingWhenFailed: false,
        child: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!.current;
    return Scaffold(
      appBar: AppBar(title: Text(s.homeTitle)),
      body: ListView(
        children: [
          _buildSection(context, s.homeBasicUsage, [
            _item(context, s.homeBasicListView, const BasicExample()),
            _item(context, s.homeGridView, const GridViewExample()),
            _item(context, s.homeCustomScrollView,
                const CustomScrollViewExample()),
          ]),
          _buildSection(context, s.homeStyle, [
            _item(context, s.homeRefreshStyle, const RefreshStyleDemo()),
            _item(context, s.homeLoadStyle, const LoadStyleDemo()),
          ]),
          _buildSection(context, s.homeIndicators, [
            _item(context, s.homeClassicHeader, const ClassicIndicatorDemo()),
            _item(context, s.homeWaterDropHeader, const WaterDropHeaderDemo()),
            _item(context, s.homeMaterialClassic, const MaterialClassicDemo()),
            _item(context, s.homeWaterDropMaterial,
                const WaterDropMaterialDemo()),
            _item(context, s.homeBezierCircle, const BezierCircleDemo()),
          ]),
          _buildSection(context, s.homeCustomIndicators, [
            _item(context, s.homeCustomHeaderBuilder,
                const CustomHeaderBuilderDemo()),
            _item(context, s.homeCustomFooterBuilder,
                const CustomFooterBuilderDemo()),
            _item(context, s.homeSpinkitHeader, const SpinkitHeaderDemo()),
            _item(context, s.homeGifIndicator, const GifIndicatorDemo()),
            _item(
                context, s.homeShimmerIndicator, const ShimmerIndicatorDemo()),
            _item(context, s.homeLinkHeaderFooter, const LinkHeaderDemo()),
          ]),
          _buildSection(context, s.homeAdvanced, [
            _item(context, s.homeTwoLevel, const TwoLevelDemo()),
            _item(context, s.homeHorizontalReverse,
                const HorizontalReverseDemo()),
            _item(context, s.homeQqChat, const QQChatListDemo()),
          ]),
          _buildSection(context, s.homeConfiguration, [
            _item(context, s.homeGlobalConfig, const GlobalConfigDemo()),
            _item(context, s.homePhysicsBehavior, const PhysicsBehaviorDemo()),
            _item(context, s.homeSpecialToggles, const SpecialTogglesDemo()),
          ]),
          _buildSection(context, s.homeCompatibility, [
            _item(context, s.homeDraggableSheet,
                const DraggableBottomSheetDemo()),
            _item(
                context, s.homeAnimatedList, const RefreshAnimatedListDemo()),
            _item(context, s.homeRecordableListView,
                const RefreshRecordableListDemo()),
          ]),
          _buildSection(context, s.homeOther, [
            _item(context, s.homeLanguageSwitch, const LanguageSwitchDemo()),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        ...items,
        const Divider(),
      ],
    );
  }

  Widget _item(BuildContext context, String label, Widget page) {
    return ListTile(
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
    );
  }
}
