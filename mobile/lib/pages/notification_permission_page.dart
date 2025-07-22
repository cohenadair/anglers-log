import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/pages/scroll_page.dart';
import 'package:adair_flutter_lib/res/anim.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/widget.dart';
import 'package:adair_flutter_lib/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mobile/wrappers/permission_handler_wrapper.dart';

import '../res/style.dart';
import '../utils/string_utils.dart';
import '../widgets/button.dart';

class NotificationPermissionPage extends StatefulWidget {
  @override
  State<NotificationPermissionPage> createState() =>
      _NotificationPermissionPageState();
}

class _NotificationPermissionPageState
    extends State<NotificationPermissionPage> {
  var _isPendingPermission = false;

  PermissionHandlerWrapper get _permissionHandlerWrapper =>
      PermissionHandlerWrapper.of(context);

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      appBar: TransparentAppBar(
        context,
        leading: CloseButton(color: AppConfig.get.colorAppTheme),
      ),
      children: [
        WatermarkLogo(
          icon: Icons.notifications,
          title: Strings.of(context).notificationPermissionPageTitle,
        ),
        Container(height: paddingDefault),
        Padding(
          padding: insetsHorizontalDefault,
          child: Text(
            Strings.of(context).notificationPermissionPageDesc,
            textAlign: TextAlign.center,
            style: stylePrimary(context),
          ),
        ),
        Container(height: paddingDefault),
        AnimatedSwitcher(
          duration: animDurationDefault,
          child: _isPendingPermission
              ? const Loading(padding: insetsTopDefault)
              : _buildSetPermissionButton(),
        ),
        Container(height: paddingDefault),
      ],
    );
  }

  Widget _buildSetPermissionButton() {
    return Button(
      text: Strings.of(context).setPermissionButton,
      onPressed: () async {
        setState(() => _isPendingPermission = true);
        await _permissionHandlerWrapper.requestNotification();
        setState(() => _isPendingPermission = false);
        safeUseContext(this, () => Navigator.pop(context));
      },
    );
  }
}
