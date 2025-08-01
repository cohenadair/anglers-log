import 'dart:convert';
import 'dart:io';

import 'package:adair_flutter_lib/managers/properties_manager.dart';
import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/io.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/utils/string.dart';
import 'package:adair_flutter_lib/utils/widget.dart';
import 'package:adair_flutter_lib/wrappers/io_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/wrappers/device_info_wrapper.dart';
import 'package:quiver/strings.dart';

import '../pages/form_page.dart';
import '../res/style.dart';
import '../utils/snackbar_utils.dart';
import '../utils/string_utils.dart';
import '../utils/validator.dart';
import '../widgets/input_controller.dart';
import '../widgets/radio_input.dart';
import '../widgets/text_input.dart';
import '../wrappers/http_wrapper.dart';
import '../wrappers/package_info_wrapper.dart';

class FeedbackPage extends StatefulWidget {
  /// An optional page title.
  final String? title;

  /// An error string to be sent with the feedback message, if applicable.
  final String? error;

  /// A warning message to display to the user, such as when they're about to
  /// send their fishing data.
  final String? warningMessage;

  /// If set, will be sent with the feedback message as an attachment.
  final String? attachment;

  const FeedbackPage({
    this.title,
    this.error,
    this.warningMessage,
    this.attachment,
  });

  @override
  FeedbackPageState createState() => FeedbackPageState();
}

class FeedbackPageState extends State<FeedbackPage> {
  static const _urlSendGrid = "https://api.sendgrid.com/v3/mail/send";

  final _log = const Log("FeedbackPage");
  final FocusNode _messageNode = FocusNode();

  final _nameController = TextInputController();
  final _emailController = EmailInputController(required: true);
  final _typeController = InputController<_FeedbackType>();
  late final TextInputController _messageController;

  var _isSending = false;

  HttpWrapper get _http => HttpWrapper.of(context);

  PackageInfoWrapper get _packageInfo => PackageInfoWrapper.of(context);

  bool get _error => isNotEmpty(widget.error);

  _FeedbackType get _typeValue {
    assert(_typeController.value != null);
    return _typeController.value!;
  }

  @override
  void initState() {
    super.initState();

    _messageController = TextInputController(
      // Message field is only required if an error isn't being sent.
      validator: _error ? null : EmptyValidator(),
    );

    _typeController.value = _FeedbackType.bug;
    _nameController.value = UserPreferenceManager.get.userName;
    _emailController.value = UserPreferenceManager.get.userEmail;
  }

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      title: Text(widget.title ?? Strings.of(context).feedbackPageTitle),
      isInputValid:
          _emailController.isValid(context) &&
          _messageController.isValid(context),
      saveButtonText: Strings.of(context).feedbackPageSend,
      showLoadingOverSave: _isSending,
      fieldBuilder: (context) => [
        _error && isNotEmpty(widget.warningMessage)
            ? Padding(
                padding: insetsTopDefault,
                child: Text(
                  widget.warningMessage!,
                  style: styleWarning(context),
                ),
              )
            : const SizedBox(),
        TextInput.name(
          context,
          controller: _nameController,
          autofocus: isEmpty(_nameController.value),
          textInputAction: TextInputAction.next,
        ),
        TextInput.email(
          context,
          controller: _emailController,
          textInputAction: TextInputAction.next,
          autofocus:
              isNotEmpty(_nameController.value) &&
              isEmpty(_emailController.value),
          onSubmitted: () => FocusScope.of(context).requestFocus(_messageNode),
          // To update "Send" button state.
          onChanged: (_) => setState(() {}),
        ),
        _error
            ? const SizedBox()
            : RadioInput(
                initialSelectedIndex: _FeedbackType.values.indexOf(_typeValue),
                optionCount: _FeedbackType.values.length,
                optionBuilder: (context, i) =>
                    _feedbackTypeToString(_FeedbackType.values[i]),
                onSelect: (i) => setState(() {
                  _typeController.value = _FeedbackType.values[i];
                }),
              ),
        TextInput(
          label: Strings.of(context).feedbackPageMessage,
          controller: _messageController,
          capitalization: TextCapitalization.sentences,
          maxLength: null,
          focusNode: _messageNode,
          autofocus:
              isNotEmpty(_nameController.value) &&
              isNotEmpty(_emailController.value),
          // To update "Send" button state.
          onChanged: (_) => setState(() {}),
        ),
      ],
      onSave: _send,
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
  }

  Future<bool> _send() async {
    if (_isSending) {
      return false;
    }

    if (!await isConnected()) {
      safeUseContext(
        this,
        () => showErrorSnackBar(
          context,
          Strings.of(context).feedbackPageConnectionError,
        ),
      );
      return false;
    }

    safeUseContext(this, () => setState(() => _isSending = true));

    var name = _nameController.value;
    var email = _emailController.value;
    var type = _feedbackTypeToString(_typeValue);
    var message = _messageController.value;

    var appVersion = (await _packageInfo.fromPlatform()).version;
    String? osVersion;
    String? deviceModel;
    String? deviceId;

    if (IoWrapper.get.isIOS) {
      var info = await DeviceInfoWrapper.get.iosInfo;
      osVersion = "${info.systemName} (${info.systemVersion})";
      deviceModel = info.utsname.machine;
      deviceId = info.identifierForVendor;
    } else if (IoWrapper.get.isAndroid) {
      var info = await DeviceInfoWrapper.get.androidInfo;
      osVersion = "Android (${info.version.sdkInt})";
      deviceModel = info.model;
      deviceId = info.id;
    }

    // API data, per https://sendgrid.com/docs/api-reference/.
    var body = <String, dynamic>{
      "personalizations": [
        {
          "to": [
            {"email": PropertiesManager.get.supportEmail},
          ],
        },
      ],
      "from": {
        "name":
            "Anglers' Log ${IoWrapper.get.isAndroid ? "Android" : "iOS"} App",
        "email": PropertiesManager.get.clientSenderEmail,
      },
      "reply_to": {"email": email, "name": name},
      "subject": type,
      "content": [
        {
          "type": "text/plain",
          "value": format(PropertiesManager.get.feedbackTemplate, [
            appVersion,
            isNotEmpty(osVersion) ? osVersion : "Unknown",
            isNotEmpty(deviceModel) ? deviceModel : "Unknown",
            isNotEmpty(deviceId) ? deviceId : "Unknown",
            WidgetsBinding.instance.platformDispatcher.locale,
            await SubscriptionManager.get.userId,
            SubscriptionManager.get.isPro ? "Pro" : "Free",
            type,
            _error ? widget.error : "N/A",
            isNotEmpty(name) ? name : "Unknown",
            isNotEmpty(email) ? email : "Unknown",
            isNotEmpty(message) ? message : "N/A",
            isNotEmpty(widget.attachment) ? widget.attachment : "N/A",
          ]),
        },
      ],
    };

    var response = await _http.post(
      Uri.parse(_urlSendGrid),
      headers: <String, String>{
        "Content-Type": "application/json; charset=UTF-8",
        "Authorization": "Bearer ${PropertiesManager.get.sendGridApiKey}",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != HttpStatus.accepted) {
      _log.e(
        "Error sending feedback: ${response.statusCode} - ${response.body}",
      );

      safeUseContext(this, () {
        showErrorSnackBar(
          context,
          Strings.of(context).feedbackPageErrorSending,
        );

        setState(() => _isSending = false);
      });

      return false;
    }

    UserPreferenceManager.get.setUserName(_nameController.value);
    UserPreferenceManager.get.setUserEmail(_emailController.value);
    return true;
  }
}

enum _FeedbackType { suggestion, feedback, bug }
