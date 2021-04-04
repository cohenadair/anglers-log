import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../utils/dialog_utils.dart';
import '../widgets/button.dart';
import '../widgets/custom_entity_values.dart';
import '../widgets/photo.dart';
import '../widgets/widget.dart';
import '../wrappers/io_wrapper.dart';

/// A page for displaying details of an [Entity]. This page includes a delete
/// and edit button in the [AppBar], as well as an optional image carousel
/// within a [SliverAppBar.flexibleSpace].
class EntityPage extends StatefulWidget {
  final List<Widget> children;
  final List<String> imageNames;
  final String? deleteMessage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final EdgeInsets padding;

  /// When true, the underlying [Entity] cannot be modified.
  final bool static;

  final List<CustomEntityValue> customEntityValues;

  EntityPage({
    required this.children,
    this.customEntityValues = const [],
    this.imageNames = const [],
    this.deleteMessage,
    this.onEdit,
    this.onDelete,
    this.padding = insetsDefault,
    this.static = false,
  })  : assert(static || (isNotEmpty(deleteMessage) && onEdit != null)),
        assert(static || onDelete != null);

  @override
  _EntityPageState createState() => _EntityPageState();
}

class _EntityPageState extends State<EntityPage> {
  final double _imageHeightFactor = 3;
  final double _carouselDotSize = 8.0;
  final double _carouselOpacity = 0.5;

  int _imageIndex = 0;
  late PageController _imageController;

  IoWrapper get _ioWrapper => IoWrapper.of(context);

  bool get _hasImages => widget.imageNames.isNotEmpty;

  double get _imageHeight =>
      MediaQuery.of(context).size.height / _imageHeightFactor;

  @override
  void initState() {
    super.initState();
    _imageController = PageController(
      initialPage: _imageIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    var children = widget.children;
    if (widget.customEntityValues.isNotEmpty) {
      children.addAll([
        Padding(
          padding: insetsVerticalWidget,
          child: HeadingDivider(Strings.of(context).customFields),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: paddingDefault,
            right: paddingDefault,
            bottom: paddingSmall,
          ),
          child: CustomEntityValues(widget.customEntityValues),
        ),
      ]);
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: _hasImages ? Empty() : null,
            actions: [
              _hasImages ? Empty() : _buildEditButton(false),
              _hasImages ? Empty() : _buildDeleteButton(false),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _hasImages ? _buildImages() : null,
            ),
            floating: false,
            pinned: true,
            snap: false,
            expandedHeight: _hasImages ? _imageHeight : null,
            forceElevated: true,
          ),
          SliverSafeArea(
            top: false,
            bottom: false,
            sliver: SliverPadding(
              padding: widget.padding,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => children[i],
                  childCount: children.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImages() {
    var carousel = <Widget>[];
    var imageNames = widget.imageNames;

    if (imageNames.length > 1) {
      for (var i = 0; i < imageNames.length; i++) {
        carousel.add(Container(
          width: _carouselDotSize,
          height: _carouselDotSize,
          decoration: BoxDecoration(
            color: imageNames.indexOf(imageNames[i]) == _imageIndex
                ? Theme.of(context).primaryColor
                : Colors.white.withOpacity(_carouselOpacity),
            shape: BoxShape.circle,
          ),
        ));

        if (i < imageNames.length - 1) {
          carousel.add(Container(
            width: paddingWidgetSmall,
            height: 0,
          ));
        }
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView(
          controller: _imageController,
          children: []..addAll(imageNames
              .map(
                (fileName) => Photo(
                  fileName: fileName,
                  width: MediaQuery.of(context).size.width,
                  // Top padding adds status bar/safe area padding.
                  height: MediaQuery.of(context).padding.top + _imageHeight,
                ),
              )
              .toList()),
          onPageChanged: (newPage) => setState(() {
            _imageIndex = newPage;
          }),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: insetsBottomSmall,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: carousel,
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: insetsHorizontalDefault,
              child: Row(
                children: [
                  _buildBackButton(),
                  // Push the rest of the buttons to the right.
                  Expanded(
                    child: Empty(),
                  ),
                  _buildEditButton(true),
                  _buildDeleteButton(true),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    Widget icon;

    if (_ioWrapper.isAndroid) {
      icon = BackButtonIcon();
    } else {
      // The iOS back button icon is not centered, so add some padding.
      icon = Padding(
        padding: insetsLeftWidgetSmall,
        child: BackButtonIcon(),
      );
    }

    return FloatingActionButton(
      child: icon,
      backgroundColor: Colors.white,
      mini: true,
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildEditButton(bool floating) {
    if (widget.static) {
      return Empty();
    }

    return ActionButton.edit(
      onPressed: widget.onEdit,
      floating: floating,
    );
  }

  Widget _buildDeleteButton(bool floating) {
    if (widget.static) {
      return Empty();
    }

    void onPressed() => showDeleteDialog(
          context: context,
          description: Text(widget.deleteMessage!),
          onDelete: () {
            widget.onDelete?.call();
            Navigator.pop(context);
          },
        );

    if (floating) {
      return FloatingActionButton(
        child: Icon(Icons.delete),
        backgroundColor: Colors.white,
        mini: true,
        onPressed: onPressed,
      );
    } else {
      return IconButton(
        icon: Icon(Icons.delete),
        onPressed: onPressed,
      );
    }
  }
}
