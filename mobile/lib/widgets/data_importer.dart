import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../app_manager.dart';
import '../database/legacy_importer.dart';
import '../i18n/strings.dart';
import '../pages/feedback_page.dart';
import '../pages/scroll_page.dart';
import '../res/dimen.dart';
import '../utils/page_utils.dart';
import '../wrappers/file_picker_wrapper.dart';
import 'button.dart';
import 'text.dart';
import 'widget.dart';
import 'work_result.dart';

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
  _RenderState _renderState = _RenderState.none;
  LegacyImporterError? _importError;
  String? _importErrorDescription;

  AppManager get _appManager => AppManager.of(context);

  FilePickerWrapper get _filePickerWrapper => _appManager.filePickerWrapper;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          child: WatermarkLogo(
            icon: widget.watermarkIcon,
          ),
        ),
        const VerticalSpace(paddingDefault),
        TitleLabel.style1(
          widget.titleText,
          overflow: TextOverflow.visible,
          align: TextAlign.center,
        ),
        const VerticalSpace(paddingDefault),
        Text(
          widget.descriptionText,
          style: Theme.of(context).textTheme.subtitle1,
          textAlign: TextAlign.center,
        ),
        const VerticalSpace(paddingDefault),
        _buildStartButton(),
        _buildFeedbackWidgets(),
      ],
    );
  }

  Widget _buildStartButton() {
    VoidCallback? onPressed;
    if (_renderState != _RenderState.loading && widget.importer == null) {
      onPressed = _chooseFile;
    } else if (_renderState == _RenderState.none && widget.importer != null) {
      onPressed = () => _startImport(widget.importer!);
    }

    return Align(
      child: Button(
        text: widget.importer == null
            ? Strings.of(context).dataImporterChooseFile
            : Strings.of(context).dataImporterStart,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildFeedbackWidgets() {
    var children = <Widget>[];

    switch (_renderState) {
      case _RenderState.none:
        return Empty();
      case _RenderState.loading:
        children.add(Loading(
          label: widget.loadingText,
        ));
        break;
      case _RenderState.success:
        children.add(WorkResult.success(widget.successText));
        break;
      case _RenderState.error:
        children.add(WorkResult.error(widget.errorText));
        children.add(const VerticalSpace(paddingDefault));
        children.add(Button(
          text: Strings.of(context).importPageSendReport,
          onPressed: () => present(
            context,
            FeedbackPage(
              title: widget.feedbackPageTitle,
              error: _importError.toString(),
              warningMessage: Strings.of(context).importPageErrorWarningMessage,
              attachment: _importErrorDescription,
            ),
          ),
        ));
        break;
    }

    return Padding(
      padding: insetsTopDefault,
      child: AnimatedSwitcher(
        duration: animDurationDefault,
        child: Column(
          key: ValueKey<_RenderState>(_renderState),
          children: children,
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
      _updateImportState(_RenderState.none);
      return;
    }

    _startImport(
        LegacyImporter(_appManager, File(pickerResult.files.single.path!)));
  }

  void _startImport(LegacyImporter importer) {
    _updateImportState(_RenderState.loading);

    importer.start().then((_) {
      widget.onFinish?.call(true);
      _updateImportState(_RenderState.success);
    }).catchError((error, stacktrace) {
      _importError = error;
      _importErrorDescription = stacktrace.toString();
      _updateImportState(_RenderState.error);
      widget.onFinish?.call(false);
    }, test: (error) => error is LegacyImporterError);
  }

  void _updateImportState(_RenderState state) {
    setState(() {
      _renderState = state;
    });
  }
}

enum _RenderState {
  none,
  loading,
  error,
  success,
}
