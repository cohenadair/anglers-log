import 'package:adair_flutter_lib/l10n/l10n.dart';
import 'package:adair_flutter_lib/utils/root.dart';
import 'package:mobile/l10n/gen/localizations.dart';

extension L10ns on L10n {
  AnglersLogLocalizations get app =>
      AnglersLogLocalizations.of(Root.get.buildContext);
}
