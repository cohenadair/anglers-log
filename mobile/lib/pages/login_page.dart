import 'package:flutter/material.dart';

import '../auth_manager.dart';
import '../i18n/strings.dart';
import '../res/dimen.dart';
import '../res/gen/custom_icons.dart';
import '../res/style.dart';
import '../utils/dialog_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/button.dart';
import '../widgets/input_controller.dart';
import '../widgets/question_answer_link.dart';
import '../widgets/text.dart';
import '../widgets/text_input.dart';
import '../widgets/widget.dart';
import 'scroll_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _logoSize = 200.0;

  final _formKey = GlobalKey<FormState>();
  final _emailController = EmailInputController(required: true);
  final _passwordController = PasswordInputController();

  _Mode _mode = _Mode._loggingIn;
  AuthError? _error;
  bool _isLoading = false;

  AuthManager get _authManager => AuthManager.of(context);

  bool get _isLoggingIn => _mode == _Mode._loggingIn;

  FormState get _formState {
    assert(_formKey.currentState != null);
    return _formKey.currentState!;
  }

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      padding: insetsDefault,
      centerContent: true,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                CustomIcons.catches,
                size: _logoSize,
              ),
              VerticalSpace(paddingWidget),
              TitleLabel(Strings.of(context).appName),
              VerticalSpace(paddingWidget),
              TextInput.email(
                context,
                controller: _emailController,
                onChanged: _clearError,
                textInputAction: TextInputAction.next,
              ),
              VerticalSpace(paddingWidgetTiny),
              TextInput.password(
                context,
                controller: _passwordController,
                onChanged: _clearError,
                onSubmitted: _handleLoginOrSignUp(),
              ),
              _buildErrorRow(),
              VerticalSpace(paddingWidget),
              Button(
                text: _mode.buttonText(context),
                onPressed: _handleLoginOrSignUp(),
              ),
              VerticalSpace(paddingWidget),
              _buildInfoRow(),
              VerticalSpace(paddingWidget),
              AnimatedVisibility(
                child: Loading(isCentered: false),
                visible: _isLoading,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorRow() {
    if (_error == null) {
      return Empty();
    }

    return Padding(
      padding: insetsTopDefault,
      child: Label.multiline(
        _authErrorToUserString(_error!),
        style: styleError,
        align: TextAlign.center,
      ),
    );
  }

  Widget _buildInfoRow() {
    var question = _mode.questionText(context);
    var action = _mode.actionText(context);
    var onActionTapped = _toggleMode;

    if (_error == AuthError.wrongPassword) {
      question = Strings.of(context).loginPagePasswordResetQuestion;
      action = Strings.of(context).loginPagePasswordResetAction;
      onActionTapped = () {
        _authManager.sendResetPasswordEmail(_emailController.value!);
        showOkDialog(
          context: context,
          description: Text(format(
              Strings.of(context).loginPageResetPasswordMessage,
              [_emailController.value])),
        );
      };
    }

    return QuestionAnswerLink(
      question: question,
      actionText: action,
      action: onActionTapped,
    );
  }

  void _setIsLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void _toggleMode() {
    setState(() {
      if (_isLoggingIn) {
        _mode = _Mode._signingUp;
      } else {
        _mode = _Mode._loggingIn;
        _formState.reset();
      }

      _error = null;
    });
  }

  void _login() {
    _setIsLoading(true);
    _authManager
        .login(_emailController.value!, _passwordController.value!)
        .then(_onLoginOrSignUp);
  }

  void _signUp() {
    _setIsLoading(true);
    _authManager
        .signUp(_emailController.value!, _passwordController.value!)
        .then(_onLoginOrSignUp);
  }

  void _onLoginOrSignUp(AuthError? error) {
    if (error == null) {
      return;
    }

    setState(() {
      _isLoading = false;
      _error = error;
    });
  }

  VoidCallback? _handleLoginOrSignUp() {
    if (!_isInputValid()) {
      return null;
    }

    if (_isLoggingIn) {
      return _login;
    } else {
      return _signUp;
    }
  }

  bool _isInputValid() =>
      _emailController.valid(context) && _passwordController.valid(context);

  void _clearError() => setState(() => _error = null);

  String _authErrorToUserString(AuthError error) {
    switch (error) {
      case AuthError.invalidUserId:
        return Strings.of(context).loginPageErrorUnknown;
      case AuthError.unknownFirebaseException:
        return Strings.of(context).loginPageErrorUnknownServer;
      case AuthError.noConnection:
        return Strings.of(context).loginPageErrorNoConnection;
      case AuthError.invalidEmail:
        return Strings.of(context).loginPageErrorInvalidEmail;
      case AuthError.userDisabled:
        return Strings.of(context).loginPageErrorUserDisabled;
      case AuthError.userNotFound:
        return Strings.of(context).loginPageErrorUserNotFound;
      case AuthError.wrongPassword:
        return Strings.of(context).loginPageErrorWrongPassword;
      case AuthError.emailInUse:
        return Strings.of(context).loginPageErrorEmailInUse;

      // These cases shouldn't be possible.
      case AuthError.operationNotAllowed:
      case AuthError.weakPassword:
        break;
    }

    return Strings.of(context).loginPageErrorUnknown;
  }
}

class _Mode {
  static final _loggingIn = _Mode(
    title: (context) => Strings.of(context).loginPageLoginTitle,
    buttonText: (context) => Strings.of(context).loginPageLoginButtonText,
    questionText: (context) => Strings.of(context).loginPageLoginQuestionText,
    actionText: (context) => Strings.of(context).loginPageLoginActionText,
  );

  static final _signingUp = _Mode(
    title: (context) => Strings.of(context).loginPageSignUpTitle,
    buttonText: (context) => Strings.of(context).loginPageSignUpButtonText,
    questionText: (context) => Strings.of(context).loginPageSignUpQuestionText,
    actionText: (context) => Strings.of(context).loginPageSignUpActionText,
  );

  final String Function(BuildContext) title;
  final String Function(BuildContext) buttonText;
  final String Function(BuildContext) questionText;
  final String Function(BuildContext) actionText;

  _Mode({
    required this.title,
    required this.buttonText,
    required this.questionText,
    required this.actionText,
  });
}
