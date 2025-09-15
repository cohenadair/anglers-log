import 'package:adair_flutter_lib/pages/scroll_page.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';

import '../utils/string_utils.dart';
import '../widgets/data_importer.dart';

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
