import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:quiver/strings.dart';

/// A page for displaying details of an [Entity]. This page includes a delete
/// and edit button in the [AppBar], as well as an optional image carousel
/// within a [SliverAppBar.flexibleSpace].
class EntityPage extends StatefulWidget {
  final List<Widget> children;
  final List<File> images;
  final String deleteMessage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  EntityPage({
    @required this.children,
    this.images,
    @required this.deleteMessage,
    this.onEdit,
    this.onDelete,
  }) : assert(children != null),
       assert(isNotEmpty(deleteMessage));

  @override
  _EntityPageState createState() => _EntityPageState();
}

class _EntityPageState extends State<EntityPage> {
  final double _imageHeightFactor = 3;
  final double _expandedOpacityHeightFactor = 2.5;
  final double _expandedStartOpacity = 0.7;
  final double _expandedEndOpacity = 0.0;
  final double _carouselDotSize = 8.0;
  final double _carouselOpacity = 0.5;

  int _imageIndex = 0;
  PageController _imageController;

  bool get _hasImages => widget.images != null && widget.images.isNotEmpty;
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            actions: [
              ActionButton.edit(
                condensed: true,
                onPressed: widget.onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => showDeleteDialog(
                  context: context,
                  description: Text(widget.deleteMessage),
                  onDelete: () {
                    widget.onDelete?.call();
                    Navigator.pop(context);
                  },
                ),
              ),
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
          SliverPadding(
            padding: insetsDefault,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => widget.children[i],
                childCount: widget.children.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImages() {
    List<Widget> carousel = [];
    if (widget.images.length > 1) {
      for (var i = 0; i < widget.images.length; i++) {
        carousel.add(Container(
          width: _carouselDotSize,
          height: _carouselDotSize,
          decoration: BoxDecoration(
            color: widget.images.indexOf(widget.images[i]) == _imageIndex
                ? Theme.of(context).primaryColor
                : Colors.white.withOpacity(_carouselOpacity),
            shape: BoxShape.circle,
          ),
        ));

        if (i < widget.images.length - 1) {
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
          children: []..addAll(widget.images.map((file) => Image.file(
            file,
            fit: BoxFit.cover,
          )).toList()),
          onPageChanged: (newPage) => setState(() {
            _imageIndex = newPage;
          }),
        ),
        // Add a gradient background behind app bar buttons so they're always
        // visible, no matter the color of the background image.
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(_expandedStartOpacity),
                  Colors.white.withOpacity(_expandedEndOpacity),
                ],
              ),
            ),
            width: MediaQuery.of(context).size.width,
            height: _imageHeight / _expandedOpacityHeightFactor,
            alignment: Alignment.topCenter,
          ),
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
      ],
    );
  }
}