import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class LoginPage extends StatefulWidget {
  final AppManager _app;

  LoginPage(this._app);

  @override
  State<StatefulWidget> createState() => _LoginPageState(_app);
}

class _LoginPageMode {
  static var loggingIn = _LoginPageMode(
    getTitle: (context) => Strings.of(context).loginPageLoginTitle,
    getButtonText: (context) => Strings.of(context).loginPageLoginButtonText,
    getQuestionText: (context) =>
        Strings.of(context).loginPageLoginQuestionText,
    getActionText: (context) => Strings.of(context).loginPageLoginActionText,
  );

  static var signingUp = _LoginPageMode(
    getTitle: (context) => Strings.of(context).loginPageSignUpTitle,
    getButtonText: (context) => Strings.of(context).loginPageSignUpButtonText,
    getQuestionText: (context) =>
        Strings.of(context).loginPageSignUpQuestionText,
    getActionText: (context) => Strings.of(context).loginPageSignUpActionText,
  );

  final String Function(BuildContext) getTitle;
  final String Function(BuildContext) getButtonText;
  final String Function(BuildContext) getQuestionText;
  final String Function(BuildContext) getActionText;

  _LoginPageMode({
    @required this.getTitle,
    @required this.getButtonText,
    @required this.getQuestionText,
    @required this.getActionText,
  });
}

class _LoginPageState extends State<LoginPage> {
  final minPasswordLength = 6;

  final AppManager _app;
  final _formKey = GlobalKey<FormState>();
  _LoginPageMode _mode = _LoginPageMode.loggingIn;

  String _errorText;
  bool _isLoading = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  _LoginPageState(this._app);

  @override
  Widget build(BuildContext context) {
    return Page(
      padding: insetsDefault,
      child: Form(
        key: _formKey,
        autovalidate: !_isLoggingIn,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _mode.getTitle(context),
              style: Theme.of(context).textTheme.display2,
            ),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: Strings.of(context).loginPageEmailLabel,
              ),
              validator: _validateEmail,
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: Strings.of(context).loginPagePasswordLabel,
              ),
              validator: _validatePassword,
            ),
            _errorText == null ? Container() : Padding(
              padding: insetsTopDefault,
              child: Text(
                _errorText,
                style: styleError,
              ),
            ),
            Padding(
              padding: insetsVerticalDefault,
              child: Row(
                children: <Widget>[
                  Button(
                    text: _mode.getButtonText(context),
                    onPressed: _handleLoginOrSignUp,
                  ),
                  _isLoading ? Loading(
                    padding: insetsLeftDefault
                  ) : Container(),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _mode.getQuestionText(context),
                    style: TextStyle(
                      color: Colors.black,
                    )
                  ),
                  TextSpan(text: ' '),
                  TextSpan(
                    text: _mode.getActionText(context),
                    style: styleHyperlink,
                    recognizer: TapGestureRecognizer()..onTap = () {
                      _toggleMode();
                    }
                  )
                ]
              ),
            ),
          ],
        )
      )
    );
  }

  bool get _isLoggingIn => _mode == _LoginPageMode.loggingIn;

  void _setIsLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void _toggleMode() {
    setState(() {
      if (_isLoggingIn) {
        _mode = _LoginPageMode.signingUp;
      } else {
        _mode = _LoginPageMode.loggingIn;
        _formKey.currentState.reset();
      }

      _errorText = null;
    });
  }

  void _login() {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _setIsLoading(true);

    _app.authManager.login(_emailController.text, _passwordController.text)
      .then((AuthError error) {
        setState(() {
          _isLoading = false;
          if (error == null) {
            return;
          }

          switch (error) {
            case AuthError.unknown:
              _errorText = Strings.of(context).loginPageErrorLoginUnknown;
              break;
            case AuthError.invalidCredentials:
              _errorText = Strings.of(context).loginPageErrorCredentials;
              break;
          }
        });
      });
  }

  void _signUp() {
    _setIsLoading(true);

    _app.authManager.signUp(_emailController.text, _passwordController.text)
      .then((AuthError error) {
        setState(() {
          _isLoading = false;
          if (error == null) {
            return;
          }

          _errorText = Strings.of(context).loginPageErrorSignUpUnknown;
        });
      });
  }

  void _handleLoginOrSignUp() {
    if (_isLoggingIn) {
      _login();
    } else {
      _signUp();
    }
  }

  String _validateEmail(String email) {
    if (isEmpty(_emailController.text)) {
      return Strings.of(context).loginPageEmailRequired;
    }

    // Validation isn't necessary when logging in.
    if (_isLoggingIn) {
      return null;
    }

    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(email)) {
      return Strings.of(context).loginPageEmailInvalidFormat;
    }

    return null;
  }

  String _validatePassword(String password) {
    if (isEmpty(_passwordController.text)) {
      return Strings.of(context).loginPagePasswordRequired;
    }

    // Validation isn't necessary when logging in.
    if (_isLoggingIn) {
      return null;
    }

    if (password.length < minPasswordLength) {
      return Strings.of(context).loginPagePasswordInvalidLength;
    }

    return null;
  }
}