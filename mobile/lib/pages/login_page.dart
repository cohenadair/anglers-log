import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../app_manager.dart';
import '../auth_manager.dart';
import '../i18n/strings.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../widgets/button.dart';
import '../widgets/input_controller.dart';
import '../widgets/text.dart';
import '../widgets/text_input.dart';
import '../widgets/widget.dart';
import 'scroll_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = EmailInputController(required: true);
  final _passwordController = PasswordInputController();

  _Mode _mode = _Mode._loggingIn;
  String _errorText;
  bool _isLoading = false;

  AppManager get _appManager => AppManager.of(context);

  bool get _isLoggingIn => _mode == _Mode._loggingIn;

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
              TitleLabel(_mode.title(context)),
              VerticalSpace(paddingDefault),
              TextInput.email(
                context,
                controller: _emailController,
                onChanged: _clearError,
              ),
              TextInput.password(
                context,
                controller: _passwordController,
                onChanged: _clearError,
              ),
              _buildErrorRow(),
              VerticalSpace(paddingDefault),
              Button(
                text: _mode.buttonText(context),
                onPressed: _isInputValid() ? _handleLoginOrSignUp : null,
              ),
              VerticalSpace(paddingDefault),
              _buildInfoRow(),
              VerticalSpace(paddingDefault),
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
    if (isEmpty(_errorText)) {
      return Empty();
    }

    return Padding(
      padding: insetsTopDefault,
      child: Label.multiline(
        _errorText,
        style: styleError,
        align: TextAlign.center,
      ),
    );
  }

  Widget _buildInfoRow() {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: _mode.questionText(context),
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        TextSpan(text: " "),
        TextSpan(
          text: _mode.actionText(context),
          style: styleHyperlink,
          recognizer: TapGestureRecognizer()..onTap = _toggleMode,
        )
      ]),
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
        _formKey.currentState.reset();
      }

      _errorText = null;
    });
  }

  void _login() {
    _setIsLoading(true);
    _appManager.authManager
        .login(_emailController.value, _passwordController.value)
        .then(_onLoginOrSignUp);
  }

  void _signUp() {
    _setIsLoading(true);
    _appManager.authManager
        .signUp(_emailController.value, _passwordController.value)
        .then(_onLoginOrSignUp);
  }

  void _onLoginOrSignUp(AuthError error) {
    if (error == null) {
      return;
    }

    setState(() {
      _isLoading = false;
      _errorText = _authErrorToUserString(error);
    });
  }

  void _handleLoginOrSignUp() {
    if (_isLoggingIn) {
      _login();
    } else {
      _signUp();
    }
  }

  bool _isInputValid() =>
      _emailController.valid(context) && _passwordController.valid(context);

  void _clearError() => setState(() => _errorText = null);

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
    @required this.title,
    @required this.buttonText,
    @required this.questionText,
    @required this.actionText,
  });
}
