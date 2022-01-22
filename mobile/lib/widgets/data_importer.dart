import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../app_manager.dart';
import '../database/legacy_importer.dart';
import '../i18n/strings.dart';
import '../pages/feedback_page.dart';
import '../pages/scroll_page.dart';
import '../res/dimen.dart';
import '../wrappers/file_picker_wrapper.dart';
import 'async_feedback.dart';
import 'widget.dart';

/// A widget that manages importing legacy data. This widget should be embedded
/// in a [ScrollPage].
class DataImporter extends StatefulWidget {
  /// If non-null, [DataImporter] will render a "start" button that will kick
  /// off importing. If null, a "choose file" button is rendered that allows
  /// users to choose an archive file to import. Once the file is chosen,
  /// importing begins.
  final LegacyImporter? importer;

  final IconData watermarkIcon;
  final String titleText;
  final String descriptionText;
  final String loadingText;
  final String errorText;
  final String successText;
  final String feedbackPageTitle;

  final void Function(bool success)? onFinish;

  const DataImporter({
    this.importer,
    required this.watermarkIcon,
    required this.titleText,
    required this.descriptionText,
    required this.loadingText,
    required this.errorText,
    required this.successText,
    required this.feedbackPageTitle,
    this.onFinish,
  });

  @override
  _DataImporterState createState() => _DataImporterState();
}

class _DataImporterState extends State<DataImporter> {
  var _progressState = AsyncFeedbackState.none;
  LegacyImporterError? _importError;
  String? _importErrorDescription;

  AppManager get _appManager => AppManager.of(context);

  FilePickerWrapper get _filePickerWrapper => _appManager.filePickerWrapper;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: WatermarkLogo(
            icon: widget.watermarkIcon,
            title: widget.titleText,
          ),
        ),
        const VerticalSpace(paddingDefault),
        Text(
          widget.descriptionText,
          style: Theme.of(context).textTheme.subtitle1,
          textAlign: TextAlign.center,
        ),
        const VerticalSpace(paddingDefault),
        _buildFeedbackWidgets(),
      ],
    );
  }

  Widget _buildFeedbackWidgets() {
    VoidCallback? action;
    if (_progressState != AsyncFeedbackState.loading &&
        widget.importer == null) {
      action = _chooseFile;
    } else if (_progressState == AsyncFeedbackState.loading &&
        widget.importer != null) {
      action = () => _startImport(widget.importer!);
    }

    return Center(
      child: AsyncFeedback(
        state: _progressState,
        description: widget.loadingText,
        actionText: widget.importer == null
            ? Strings.of(context).dataImporterChooseFile
            : Strings.of(context).dataImporterStart,
        action: action,
        feedbackPage: FeedbackPage(
          title: widget.feedbackPageTitle,
          error: _importError.toString(),
          warningMessage: Strings.of(context).importPageErrorWarningMessage,
          attachment: _importErrorDescription,
        ),
      ),
    );
  }

  void _chooseFile() async {
    var pickerResult = await _filePickerWrapper.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["zip"],
    );

    if (pickerResult == null) {
      _updateImportState(AsyncFeedbackState.none);
      return;
    }

    _startImport(
        LegacyImporter(_appManager, File(pickerResult.files.single.path!)));
  }

  void _startImport(LegacyImporter importer) {
    _updateImportState(AsyncFeedbackState.loading);

    importer.start().then((_) {
      widget.onFinish?.call(true);
      _updateImportState(AsyncFeedbackState.success);
    }).catchError((error, stacktrace) {
      _importError = error;
      _importErrorDescription = stacktrace.toString();
      _updateImportState(AsyncFeedbackState.error);
      widget.onFinish?.call(false);
    }, test: (error) => error is LegacyImporterError);
  }

  void _updateImportState(AsyncFeedbackState state) {
    setState(() => _progressState = state);
  }
}
