import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_string.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const AppLocalizationsDelegate delegate = AppLocalizationsDelegate();

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static final Map<String, AppString> _values = {
    'en': EnStrings(),
    'zh': ChStrings(),
  };

  AppString get current {
    return _values[locale.languageCode] ?? _values['en']!;
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
