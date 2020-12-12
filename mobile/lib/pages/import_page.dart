import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../app_manager.dart';
import '../database/legacy_importer.dart';
import '../i18n/strings.dart';
import '../pages/feedback_page.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/page_utils.dart';
import '../widgets/button.dart';
import '../widgets/widget.dart';
import '../wrappers/file_picker_wrapper.dart';

class ImportPage extends StatefulWidget {
  @override
  _ImportPageState createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  final double _feedbackIconSize = 40.0;

  _State _importState = _State.none;
  LegacyImporterError _importError;
  String _importErrorJson;

  bool get _loading => _importState == _State.loading;

  AppManager get _appManager => AppManager.of(context);
  FilePickerWrapper get _filePickerWrapper => _appManager.filePickerWrapper;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: CloseButton(
          color: Theme.of(context).primaryColor,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: HorizontalSafeArea(
        child: Padding(
          padding: insetsDefault,
          child: ListView(
            children: [
              WatermarkLogo(
                icon: Icons.cloud_download,
              ),
              Text(
                Strings.of(context).importPageDescription,
                style: Theme.of(context).textTheme.subtitle1,
                textAlign: TextAlign.center,
              ),
              VerticalSpace(paddingWidget),
              // Using align will minimize button width. Without it, button
              // takes up entire width of parent.
              Align(
                child: Button(
                  text: Strings.of(context).importPageChooseFile,
                  onPressed: _loading
                      ? null
                      : () {
                          _updateImportState(_State.loading);
                          _chooseFile();
                        },
                ),
              ),
              VerticalSpace(paddingWidget),
              _buildFeedbackWidgets(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackWidgets() {
    var children = <Widget>[];

    switch (_importState) {
      case _State.none:
        // Nothing to add here.
        break;
      case _State.loading:
        children.add(Loading.centered(padding: insetsBottomWidget));
        children.add(Text(Strings.of(context).importPageImportingData));
        break;
      case _State.success:
        children.add(Icon(
          Icons.check_circle,
          color: styleSuccess.color,
          size: _feedbackIconSize,
        ));
        children.add(VerticalSpace(paddingWidgetSmall));
        children.add(Text(
          Strings.of(context).importPageSuccess,
          style: styleSuccess,
        ));
        break;
      case _State.error:
        children.add(Icon(
          Icons.error,
          color: styleError.color,
          size: _feedbackIconSize,
        ));
        children.add(VerticalSpace(paddingWidgetSmall));
        children.add(Text(
          Strings.of(context).importPageError,
          style: styleError,
          textAlign: TextAlign.center,
        ));
        children.add(VerticalSpace(paddingWidget));
        children.add(Button(
          text: Strings.of(context).importPageSendReport,
          onPressed: () => present(
            context,
            FeedbackPage(
              title: Strings.of(context).importPageErrorTitle,
              error: _importError.toString(),
              warningMessage: Strings.of(context).importPageErrorWarningMessage,
              attachment: _importErrorJson,
            ),
          ),
        ));
        break;
    }

    return AnimatedSwitcher(
      duration: defaultAnimationDuration,
      child: Column(
        key: ValueKey<_State>(_importState),
        children: children,
      ),
    );
  }

  void _chooseFile() async {
    var zipFile = await _filePickerWrapper.getFile(
      type: FileType.CUSTOM,
      fileExtension: "zip",
    );

    if (zipFile == null) {
      _updateImportState(_State.none);
      return;
    }

    var importer = LegacyImporter(_appManager, zipFile);
    importer.start().then((_) {
      _updateImportState(_State.success);
    }).catchError((error) {
      _importError = error;
      _importErrorJson = importer.jsonString;
      _updateImportState(_State.error);
    }, test: (error) => error is LegacyImporterError);
  }

  void _updateImportState(_State state) {
    setState(() {
      _importState = state;
    });
  }
}

enum _State { none, loading, error, success }
