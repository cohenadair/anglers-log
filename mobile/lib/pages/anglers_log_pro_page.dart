import 'package:adair_flutter_lib/l10n/l10n.dart';
import 'package:adair_flutter_lib/pages/pro_page.dart';
import 'package:adair_flutter_lib/res/style.dart';
import 'package:flutter/material.dart';
import 'package:mobile/l10n/l10n_extension.dart';

import '../utils/string_utils.dart';

class AnglersLogProPage extends StatelessWidget {
  final bool embedInScrollPage;

  const AnglersLogProPage({
    this.embedInScrollPage = true,
  });

  @override
  Widget build(BuildContext context) {
    return ProPage(
      features: [
        ProPageFeatureRow("*${Strings.of(context).proPageBackup}"),
        ProPageFeatureRow(Strings.of(context).proPageCsv),
        ProPageFeatureRow(Strings.of(context).proPageAtmosphere),
        ProPageFeatureRow(Strings.of(context).proPageReports),
        ProPageFeatureRow(Strings.of(context).proPageCustomFields),
        ProPageFeatureRow(Strings.of(context).proPageGpsTrails),
        ProPageFeatureRow(Strings.of(context).proPageCopyCatch),
        ProPageFeatureRow(Strings.of(context).proPageSpeciesCounter),
      ],
      embedInScrollPage: embedInScrollPage,
      footnote: _buildBackupWarning(),
    );
  }

  Widget _buildBackupWarning() {
    return Text(
      "*${L10n.get.app.proPageBackupWarning}",
      style: styleSubtext,
    );
  }
}
