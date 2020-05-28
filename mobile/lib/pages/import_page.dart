import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class ImportPage extends StatefulWidget {
  @override
  _ImportPageState createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  final double _cloudIconSize = 150.0;
  final double _feedbackIconSize = 40.0;
  final Duration _feedbackAnimDuration = Duration(milliseconds: 150);

  _State _importState = _State.none;
  String _feedbackText = "";

  bool get _loading => _importState == _State.loading;

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
      body: Padding(
        padding: insetsDefault,
        child: ListView(
          children: [
            Icon(
              Icons.cloud_download,
              size: _cloudIconSize,
              color: Colors.black12,
            ),
            Text(Strings.of(context).importPageDescription,
              style: Theme.of(context).textTheme.subtitle1,
              textAlign: TextAlign.center,
            ),
            VerticalSpace(paddingWidget),
            Align(
              child: Button(
                text: Strings.of(context).importPageChooseFile,
                onPressed: _loading ? null : () { },
              ),
            ),
            VerticalSpace(paddingWidget),
            _buildFeedbackWidgets(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackWidgets() {
    List<Widget> children = [];

    _feedbackText = Strings.of(context).importPageImportingData;

    switch (_importState) {
      case _State.none:
        // Nothing to add here.
        break;
      case _State.loading:
        children.add(Loading.centered(padding: insetsBottomWidget));
        if (isNotEmpty(_feedbackText)) {
          children.add(Text(_feedbackText));
        }
        break;
      case _State.success:
        children.add(Icon(Icons.check_circle,
          color: styleSuccess.color,
          size: _feedbackIconSize,
        ));
        children.add(VerticalSpace(paddingWidgetSmall));
        children.add(Text(Strings.of(context).importPageSuccess,
          style: styleSuccess,
        ));
        break;
      case _State.error:
        children.add(Icon(Icons.error,
          color: styleError.color,
          size: _feedbackIconSize,
        ));
        children.add(VerticalSpace(paddingWidgetSmall));
        children.add(Text(Strings.of(context).importPageError,
          style: styleError,
          textAlign: TextAlign.center,
        ));
        children.add(VerticalSpace(paddingWidget));
        children.add(Button(
          text: Strings.of(context).importPageSendReport,
          onPressed: () => showWarningDialog(
            context: context,
            title: Strings.of(context).importPageErrorWarningTitle,
            description:
                Text(Strings.of(context).importPageErrorWarningMessage),
            onContinue: () {
              // TODO
            },
          ),
        ));
        break;
    }

    return AnimatedSwitcher(
      duration: _feedbackAnimDuration,
      child: Column(
        key: ValueKey<_State>(_importState),
        children: children,
      ),
    );
  }
}

enum _State {
  none, loading, error, success
}