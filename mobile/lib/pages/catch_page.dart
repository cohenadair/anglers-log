import 'package:flutter/material.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/pages/entity_page.dart';
import 'package:mobile/pages/save_catch_page.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class CatchPage extends StatefulWidget {
  final String catchId;

  CatchPage(this.catchId) : assert(isNotEmpty(catchId));

  @override
  _CatchPageState createState() => _CatchPageState();
}

class _CatchPageState extends State<CatchPage> {
  CatchManager get _catchManager => CatchManager.of(context);
  ImageManager get _imageManager => ImageManager.of(context);

  Catch get _catch => _catchManager.entity(id: widget.catchId);

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder<Catch>(
      manager: _catchManager,
      // When deleted, we pop immediately. Don't reload; bait will be null.
      onDeleteEnabled: false,
      builder: (context) => EntityPage(
        onEdit: () => present(context, SaveCatchPage()),
        onDelete: () => CatchManager.of(context).delete(_catch),
        deleteMessage: Strings.of(context).catchPageDeleteMessage,
        images: _imageManager.imageFiles(entityId: widget.catchId),
        children: <Widget>[
          Container(
            height: 200,
            color: Colors.red,
            child: Empty(),
          ),
          Container(
            height: 200,
            color: Colors.blue,
            child: Empty(),
          ),
          Container(
            height: 200,
            color: Colors.green,
            child: Empty(),
          ),
          Container(
            height: 200,
            color: Colors.orange,
            child: Empty(),
          ),
          Container(
            height: 200,
            color: Colors.purple,
            child: Empty(),
          ),
        ],
      ),
    );
  }
}