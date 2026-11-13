import 'package:adair_flutter_lib/utils/dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/utils/string_utils.dart';

void showDiscardChangesDialog(BuildContext context, [VoidCallback? onDiscard]) {
  showDestructiveDialog(
    context: context,
    description: Text(Strings.of(context).formPageConfirmBackDesc),
    destroyText: Strings.of(context).formPageConfirmBackAction,
    onTapDestroy: () {
      if (onDiscard == null) {
        Navigator.of(context).pop();
      } else {
        onDiscard();
      }
    },
  );
}
