import 'package:flutter/material.dart';

import '../../res/dimen.dart';
import '../../res/style.dart';
import '../../widgets/widget.dart';

/// A widget that renders a "page" as a smaller, floating container. This is
/// meant to be used in onboarding pages to show users different features of
/// the app.
class EmbeddedPage extends StatelessWidget {
  static const _routeRoot = "/";
  static const _routeNotRoot = "not_root";

  static const _width = 300.0;
  static const _height = 285.0;

  final bool showBackButton;
  final Widget Function(BuildContext) childBuilder;

  const EmbeddedPage({
    this.showBackButton = true,
    required this.childBuilder,
  });

  @override
  Widget build(BuildContext context) {
    var routes = <Route>[];
    if (showBackButton) {
      routes.add(MaterialPageRoute(
        settings: const RouteSettings(
          name: _routeRoot,
        ),
        builder: (_) => const Empty(),
      ));
    }
    routes.add(MaterialPageRoute(
      settings: const RouteSettings(
        name: _routeNotRoot,
      ),
      builder: (context) => MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: childBuilder(context),
      ),
    ));

    return Container(
      decoration: BoxDecoration(
        boxShadow: boxShadowDefault(context),
        borderRadius:
            const BorderRadius.all(Radius.circular(floatingCornerRadius)),
      ),
      width: _width,
      height: _height,
      clipBehavior: Clip.antiAlias,
      // IgnorePointer in combination with Navigator ensures that the showing
      // and hiding of the popup menu can only be controlled by the timer, and
      // not external clicks by the user.
      child: IgnorePointer(
        child: Navigator(
          // Set a "not_root" route as initial route so the child page renders
          // a back button.
          initialRoute: _routeNotRoot,
          onGenerateInitialRoutes: (_, __) => routes,
        ),
      ),
    );
  }
}
