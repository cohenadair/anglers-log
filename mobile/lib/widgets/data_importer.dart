import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../app_manager.dart';
import '../database/legacy_importer.dart';
import '../i18n/strings.dart';
import '../pages/feedback_page.dart';
import '../pages/scroll_page.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/page_utils.dart';
import '../wrappers/file_picker_wrapper.dart';
import 'button.dart';
import 'text.dart';
import 'widget.dart';

/// A widget that manages importing legacy data. This widget should be embedded
/// in a [ScrollPage].
class DataImporter extends StatefulWidget {
  /// If non-null, [DataImporter] will render a "start" button that will kick
  /// off importing. If null, a "choose file" button is rendered that allows
  /// users to choose an archive file to import. Once the file is chosen,
  /// importing begins.
  final LegacyImporter importer;

  final IconData watermarkIcon;
  final String titleText;
  final String descriptionText;
  final String loadingText;
  final String errorText;
  final String successText;
  final String feedbackPageTitle;

  final void Function(bool success) onFinish;

  DataImporter({
    this.importer,
    @required this.watermarkIcon,
    @required this.titleText,
    @required this.descriptionText,
    @required this.loadingText,
    @required this.errorText,
    @required this.successText,
    @required this.feedbackPageTitle,
    this.onFinish,
  })  : assert(watermarkIcon != null),
        assert(titleText != null),
        assert(descriptionText != null),
        assert(loadingText != null),
        assert(errorText != null),
        assert(successText != null),
        assert(feedbackPageTitle != null);

  @override
  _DataImporterState createState() => _DataImporterState();
}

class _DataImporterState extends State<DataImporter> {
  final double _feedbackIconSize = 40.0;

  _RenderState _renderState = _RenderState.none;
  LegacyImporterError _importError;
  String _importErrorDescription;

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
        VerticalSpace(paddingWidget),
        TitleLabel(
          widget.titleText,
          overflow: TextOverflow.visible,
          align: TextAlign.center,
        ),
        VerticalSpace(paddingWidget),
        Text(
          widget.descriptionText,
          style: Theme.of(context).textTheme.subtitle1,
          textAlign: TextAlign.center,
        ),
        VerticalSpace(paddingWidget),
        _buildStartButton(),
        _buildFeedbackWidgets(),
      ],
    );
  }

  Widget _buildStartButton() {
    VoidCallback onPressed;
    if (_renderState != _RenderState.loading) {
      onPressed = () {
        if (widget.importer == null) {
          _chooseFile();
        } else {
          _startImport(widget.importer);
        }
      };
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
        children.add(Icon(
          Icons.check_circle,
          color: styleSuccess.color,
          size: _feedbackIconSize,
        ));
        children.add(VerticalSpace(paddingWidgetSmall));
        children.add(Text(
          widget.successText,
          style: styleSuccess,
        ));
        break;
      case _RenderState.error:
        children.add(Icon(
          Icons.error,
          color: styleError.color,
          size: _feedbackIconSize,
        ));
        children.add(VerticalSpace(paddingWidgetSmall));
        children.add(Text(
          widget.errorText,
          style: styleError,
          textAlign: TextAlign.center,
        ));
        children.add(VerticalSpace(paddingWidget));
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
      padding: insetsTopWidget,
      child: AnimatedSwitcher(
        duration: defaultAnimationDuration,
        child: Column(
          key: ValueKey<_RenderState>(_renderState),
          children: children,
        ),
      ),
    );
  }

  void _chooseFile() async {
    var zipFile = await _filePickerWrapper.getFile(
      type: FileType.CUSTOM,
      fileExtension: "zip",
    );

    if (zipFile == null) {
      _updateImportState(_RenderState.none);
      return;
    }

    _startImport(LegacyImporter(_appManager, zipFile));
  }

  void _startImport(LegacyImporter importer) {
    _updateImportState(_RenderState.loading);

    importer.start().then((_) {
      widget.onFinish?.call(true);
      _updateImportState(_RenderState.success);
    }).catchError((error, stacktrace) {
      _importError = error;
      _importErrorDescription = stacktrace;
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
