import 'package:flutter/widgets.dart';

typedef ContextCallback = void Function(BuildContext);

extension GlobalKeys on GlobalKey {
  Rect? globalPosition() {
    var obj = currentContext?.findRenderObject();
    if (obj is RenderBox) {
      return obj.localToGlobal(Offset.zero) & obj.size;
    }
    return null;
  }
}
