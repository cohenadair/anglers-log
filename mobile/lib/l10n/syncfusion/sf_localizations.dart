import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/localizations.dart';

import 'sf_localizations_en_override.dart';
import 'sf_localizations_es_override.dart';

class SfLocalizationsOverrideDelegate
    extends LocalizationsDelegate<SfLocalizations> {
  const SfLocalizationsOverrideDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<SfLocalizations> load(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return SynchronousFuture<SfLocalizations>(SfLocalizationsEnOverride());
      case 'es':
        return SynchronousFuture<SfLocalizations>(SfLocalizationsEsOverride());
    }
    throw FlutterError('Unsupported locale "$locale".');
  }

  @override
  bool shouldReload(LocalizationsDelegate<SfLocalizations> old) => false;
}
