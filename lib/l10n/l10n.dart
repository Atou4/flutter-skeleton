import 'package:flutter/widgets.dart';
import 'package:flutter_skeleton/l10n/l10n.dart';

export 'package:flutter_skeleton/l10n/generated/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get appLocalizations => AppLocalizations.of(this)!;
}
