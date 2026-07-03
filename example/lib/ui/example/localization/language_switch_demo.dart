import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../widget/sample_data.dart';
import '../../../main.dart';
import '../../../l10n/app_localizations.dart';

class LanguageSwitchDemo extends StatefulWidget {
  const LanguageSwitchDemo({super.key});

  @override
  State<LanguageSwitchDemo> createState() => _LanguageSwitchDemoState();
}

class _LanguageSwitchDemoState extends State<LanguageSwitchDemo> {
  final RefreshController _controller = RefreshController();
  List<String> _items = SampleData.generate(count: 15);
  Locale _selectedLocale = const Locale('en');

  static const List<Map<String, dynamic>> _languages = [
    {'label': 'English', 'locale': Locale('en')},
    {'label': '中文', 'locale': Locale('zh')},
    {'label': 'Français', 'locale': Locale('fr')},
    {'label': 'Русский', 'locale': Locale('ru')},
    {'label': 'Українська', 'locale': Locale('uk')},
    {'label': 'Italiano', 'locale': Locale('it')},
    {'label': '日本語', 'locale': Locale('ja')},
    {'label': 'Deutsch', 'locale': Locale('de')},
    {'label': 'Español', 'locale': Locale('es')},
    {'label': 'Nederlands', 'locale': Locale('nl')},
    {'label': 'Svenska', 'locale': Locale('sv')},
    {'label': 'Português', 'locale': Locale('pt')},
    {'label': '한국어', 'locale': Locale('ko')},
  ];

  Future<void> _onRefresh() async {
    await SampleData.simulateNetwork();
    setState(() => _items = SampleData.generate(count: 15));
    _controller.refreshCompleted();
  }

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
      appBar: AppBar(title: Text(s.appBarLanguageSwitcher)),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              controller: _controller,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (_, i) => ListTile(title: Text(_items[i])),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 2,
            child: ListView(
              children: _languages.map((lang) {
                final locale = lang['locale'] as Locale;
                final selected = locale == _selectedLocale;
                return ListTile(
                  title: Text(lang['label'] as String),
                  subtitle: Text(locale.languageCode),
                  trailing: selected ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    setState(() => _selectedLocale = locale);
                    MyApp.of(context)?.setLocale(locale);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
