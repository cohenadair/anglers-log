import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';

import '../backup_restore_manager.dart';
import '../user_preference_manager.dart';
import 'button.dart';
import 'widget.dart';

/// A widget that allows users to authenticate via cloud solution such as
/// Google Drive.
class CloudAuth extends StatefulWidget {
  final EdgeInsets? padding;

  const CloudAuth({
    this.padding,
  });

  @override
  State<CloudAuth> createState() => _CloudAuthState();
}

class _CloudAuthState extends State<CloudAuth> {
  late final StreamSubscription _authSubscription;

  BackupRestoreAuthState? _authState;

  BackupRestoreManager get _backupRestoreManager =>
      BackupRestoreManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  @override
  void initState() {
    super.initState();
    _authSubscription = _backupRestoreManager.authStream
        .listen((authState) => setState(() => _authState = authState));
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var child = _backupRestoreManager.isSignedIn
        ? _buildSignedInWidget(const ValueKey(1))
        : _buildSignInWidget(const ValueKey(2));

    return Padding(
      padding: widget.padding ?? insetsZero,
      child: AnimatedSwitcher(
        duration: animDurationDefault,
        child: child,
      ),
    );
  }

  Widget _buildSignInWidget(Key key) {
    Widget errorText = const Empty();
    if (_authState == BackupRestoreAuthState.error ||
        _authState == BackupRestoreAuthState.networkError) {
      errorText = Padding(
        padding: insetsTopDefault,
        child: Text(
          _authState == BackupRestoreAuthState.error
              ? Strings.of(context).cloudAuthError
              : Strings.of(context).cloudAuthNetworkError,
          style: styleError(context),
        ),
      );
    }

    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Strings.of(context).cloudAuthDescription,
          style: stylePrimary(context),
        ),
        const VerticalSpace(paddingDefault),
        Center(
          child: _GoogleButton(
            () => _userPreferenceManager.setDidSetupBackup(true),
          ),
        ),
        Center(child: errorText),
      ],
    );
  }

  Widget _buildSignedInWidget(Key key) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Strings.of(context).cloudAuthSignedInAs,
          style: styleListHeading(context),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _backupRestoreManager.currentUser!.email,
              style: stylePrimary(context),
            ),
            Button(
              text: Strings.of(context).cloudAuthSignOut,
              onPressed: () => _userPreferenceManager.setDidSetupBackup(false),
            ),
          ],
        ),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  // Spec made to match Google's sign in brand guidelines as closely as
  // possible: https://developers.google.com/identity/branding-guidelines.
  static const _backgroundColor = 0xFF4285F4;
  static const _borderRadiusButton = 3.0;
  static const _borderRadiusLogo = 2.0;
  static const _height = 40.0;
  static const _iconSize = 18.0;
  static const _paddingLeft = 1.0;
  static const _paddingRight = 8.0;
  static const _paddingBetweenLogoAndText = 16.0;
  static const _paddingLogo = 10.0;

  final VoidCallback onTap;

  const _GoogleButton(this.onTap);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(_backgroundColor),
        boxShadow: boxShadowDefault(context),
        borderRadius:
            const BorderRadius.all(Radius.circular(_borderRadiusButton)),
      ),
      height: _height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HorizontalSpace(_paddingLeft),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.all(Radius.circular(_borderRadiusLogo)),
                ),
                padding: const EdgeInsets.all(_paddingLogo),
                child: SvgPicture.asset(
                  "assets/google-logo.svg",
                  width: _iconSize,
                  height: _iconSize,
                ),
              ),
              const HorizontalSpace(_paddingBetweenLogoAndText),
              Text(
                Strings.of(context).cloudAuthSignInWithGoogle,
                style: const TextStyle(
                  fontFamily: "RobotoMedium",
                  color: Colors.white,
                ),
              ),
              const HorizontalSpace(_paddingRight),
            ],
          ),
        ),
      ),
    );
  }
}
