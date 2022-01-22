import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../res/dimen.dart';
import '../widgets/data_importer.dart';
import '../widgets/widget.dart';
import 'scroll_page.dart';

class ImportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      appBar: TransparentAppBar(context),
      extendBodyBehindAppBar: true,
      padding: insetsHorizontalDefaultBottomDefault,
      children: [
        DataImporter(
          watermarkIcon: Icons.cloud_download,
          titleText: Strings.of(context).importPageTitle,
          descriptionText: Strings.of(context).importPageDescription,
          errorText: Strings.of(context).importPageError,
          loadingText: Strings.of(context).importPageImportingData,
          successText: Strings.of(context).importPageSuccess,
          feedbackPageTitle: Strings.of(context).importPageErrorTitle,
        ),
      ],
    );
  }
}
