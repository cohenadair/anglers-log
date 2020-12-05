import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/form_page.dart';
import '../properties_manager.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/protobuf_utils.dart';
import '../utils/snackbar_utils.dart';
import '../utils/string_utils.dart';
import '../utils/validator.dart';
import '../widgets/input_controller.dart';
import '../widgets/input_data.dart';
import '../widgets/radio_input.dart';
import '../widgets/text_input.dart';
import '../widgets/widget.dart';
import '../wrappers/io_wrapper.dart';
import '../wrappers/mail_sender_wrapper.dart';
import '../wrappers/package_info_wrapper.dart';

class FeedbackPage extends StatefulWidget {
  /// An optional page title.
  final String title;

  /// An error string to be sent with the feedback message, if applicable.
  final String error;

  /// A warning message to display to the user, such as when they're about to
  /// send their fishing data.
  final String warningMessage;

  /// If set, will be sent with the feedback message as an attachment.
  final String attachment;

  FeedbackPage({
    this.title,
    this.error,
    this.warningMessage,
    this.attachment,
  });

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  static final _idWarning = randomId();
  static final _idName = randomId();
  static final _idEmail = randomId();
  static final _idType = randomId();
  static final _idMessage = randomId();

  final Log _log = Log("FeedbackPage");

  final Map<Id, Field> _fields = {};

  IoWrapper get _io => IoWrapper.of(context);
  MailSenderWrapper get _mailSender => MailSenderWrapper.of(context);
  PackageInfoWrapper get _packageInfo => PackageInfoWrapper.of(context);
  PropertiesManager get _propertiesManager => PropertiesManager.of(context);

  TextInputController get _nameController => _fields[_idName].controller;
  TextInputController get _emailController => _fields[_idEmail].controller;
  InputController<_FeedbackType> get _typeController =>
      _fields[_idType].controller;
  TextInputController get _messageController => _fields[_idMessage].controller;

  bool get _error => isNotEmpty(widget.error);

  @override
  void initState() {
    super.initState();

    _fields[_idWarning] = Field(
      id: _idWarning,
      controller: InputController(),
    );

    _fields[_idName] = Field(
      id: _idName,
      controller: TextInputController(),
    );

    _fields[_idEmail] = Field(
      id: _idEmail,
      controller: EmailInputController(),
    );

    _fields[_idType] = Field(
      id: _idType,
      controller: InputController<_FeedbackType>(
        value: _FeedbackType.bug,
      ),
    );

    _fields[_idMessage] = Field(
      id: _idMessage,
      controller: TextInputController(
        // Message field is only required if an error isn't being sent.
        validator: _error ? null : EmptyValidator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      title: Text(widget.title ?? Strings.of(context).feedbackPageTitle),
      isInputValid:
          _emailController.valid(context) && _messageController.valid(context),
      saveButtonText: Strings.of(context).feedbackPageSend,
      fieldBuilder: (context) => {
        _idWarning: _error && isNotEmpty(widget.warningMessage)
            ? Padding(
                padding: insetsTopDefault,
                child: Text(
                  widget.warningMessage,
                  style: styleWarning,
                ),
              )
            : Empty(),
        _idName: TextInput.name(
          context,
          controller: _nameController,
          autofocus: true,
        ),
        _idEmail: TextInput.email(
          context,
          controller: _emailController,
          // To update "Send" button state.
          onChanged: () => setState(() {}),
        ),
        _idType: _error
            ? Empty()
            : RadioInput(
                initialSelectedIndex:
                    _FeedbackType.values.indexOf(_typeController.value),
                optionCount: _FeedbackType.values.length,
                optionBuilder: (context, i) =>
                    _feedbackTypeToString(_FeedbackType.values[i]),
                onSelect: (i) => setState(() {
                  _typeController.value = _FeedbackType.values[i];
                }),
              ),
        _idMessage: TextInput(
          label: Strings.of(context).feedbackPageMessage,
          controller: _messageController,
          capitalization: TextCapitalization.sentences,
          maxLength: null,
          // To update "Send" button state.
          onChanged: () => setState(() {}),
        ),
      },
      onSave: (context) async {
        if (!await _io.isConnected()) {
          showErrorSnackBar(
            context,
            Strings.of(context).feedbackPageConnectionError,
          );
          return false;
        }

        showPermanentSnackBar(context, Strings.of(context).feedbackPageSending);

        var name = _nameController.value;
        var email = _emailController.value;
        var type = _feedbackTypeToString(_typeController.value);
        var message = _messageController.value;

        var appVersion = (await _packageInfo.fromPlatform()).version;
        String osVersion;
        String deviceModel;

        var deviceInfo = DeviceInfoPlugin();
        if (Platform.isIOS) {
          var info = await deviceInfo.iosInfo;
          osVersion = "${info.systemName} (${info.systemVersion})";
          deviceModel = info.utsname.machine;
        } else if (Platform.isAndroid) {
          var info = await deviceInfo.androidInfo;
          osVersion = "Android (${info.version.sdkInt})";
          deviceModel = info.model;
        }

        var server = _mailSender.gmail(_propertiesManager.clientSenderEmail,
            _propertiesManager.clientSenderPassword);

        Attachment attachment;
        if (widget.attachment != null) {
          attachment = StringAttachment(widget.attachment);
        }

        var content = Message()
          ..from = Address(
            _propertiesManager.clientSenderEmail,
            "Anglers' Log Client",
          )
          ..recipients.add(_propertiesManager.supportEmail)
          ..attachments = attachment == null ? null : [attachment]
          ..subject = "Feedback from Anglers' Log"
          ..text = format(_propertiesManager.feedbackTemplate, [
            appVersion,
            isNotEmpty(osVersion) ? osVersion : "Unknown",
            isNotEmpty(deviceModel) ? deviceModel : "Unknown",
            type,
            _error ? widget.error : "N/A",
            isNotEmpty(name) ? name : "Unknown",
            isNotEmpty(email) ? email : "Unknown",
            isNotEmpty(message) ? message : "N/A",
          ]);

        try {
          await _mailSender.send(content, server);
        } on MailerException catch (e) {
          for (var p in e.problems) {
            _log.e("Error sending feedback: ${p.code}: ${p.msg}");
          }

          // Hide "sending" SnackBar and show error.
          Scaffold.of(context).hideCurrentSnackBar();
          showErrorSnackBar(
            context,
            Strings.of(context).feedbackPageErrorSending,
          );

          return false;
        }

        return true;
      },
    );
  }

  String _feedbackTypeToString(_FeedbackType type) {
    switch (type) {
      case _FeedbackType.bug:
        return Strings.of(context).feedbackPageBugType;
      case _FeedbackType.feedback:
        return Strings.of(context).feedbackPageFeedbackType;
      case _FeedbackType.suggestion:
        return Strings.of(context).feedbackPageSuggestionType;
    }
    return null;
  }
}

enum _FeedbackType { suggestion, feedback, bug }
