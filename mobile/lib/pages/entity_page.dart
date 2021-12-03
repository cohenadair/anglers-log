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

  final _scrollController = ScrollController();
  late VoidCallback _scrollListener;

  var _imageIndex = 0;
  var _isImageShowing = false;
  late PageController _imageController;

  bool get _hasImages => widget.imageNames.isNotEmpty;

  double get _imageHeight =>
      MediaQuery.of(context).size.height / _imageHeightFactor;

  @override
  void initState() {
    super.initState();

    _imageController = PageController(
      initialPage: _imageIndex,
    );

    _isImageShowing = _hasImages;
    _scrollListener = _onScrollUpdated;
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_scrollListener);
  }

  @override
  void didUpdateWidget(EntityPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _calculateIsImageShowing();
  }

  @override
  Widget build(BuildContext context) {
    var children = List<Widget>.of(widget.children);
    if (widget.customEntityValues.isNotEmpty) {
      children.add(CustomEntityValues(
        title: Strings.of(context).entityNameCustomFields,
        padding: insetsBottomSmall,
        values: widget.customEntityValues,
      ));
    } else {
      children.add(const VerticalSpace(paddingDefault));
    }

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            leading: _buildBackButton(),
            actions: [
              _buildEditButton(),
              _buildDeleteButton(),
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
                delegate: SliverChildListDelegate(
                  children,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImages() {
    // TODO: Consider using Scrollbar instead of a carousel.
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
          carousel.add(const SizedBox(
            width: paddingSmall,
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
          children: [
            ...imageNames
                .map(
                  (fileName) => Photo(
                    fileName: fileName,
                    width: MediaQuery.of(context).size.width,
                    // Top padding adds status bar/safe area padding.
                    height: MediaQuery.of(context).padding.top + _imageHeight,
                    galleryImages: imageNames,
                  ),
                )
                .toList()
          ],
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
      ],
    );
  }

  Widget _buildBackButton() {
    return AnimatedSwitcher(
      duration: animDurationDefault,
      child: FloatingButton.back(
        key: ValueKey<bool>(_isImageShowing),
        padding: insetsTopSmall,
        transparentBackground: !_isImageShowing,
      ),
    );
  }

  Widget _buildEditButton() {
    if (widget.static) {
      return Empty();
    }

    return AnimatedSwitcher(
      duration: animDurationDefault,
      child: FloatingButton(
        key: ValueKey<bool>(_isImageShowing),
        icon: _isImageShowing ? Icons.edit : null,
        text: _isImageShowing ? null : Strings.of(context).edit,
        padding: const EdgeInsets.only(
          left: paddingDefault,
          right: paddingDefault,
          top: paddingSmall,
        ),
        transparentBackground: !_isImageShowing,
        onPressed: widget.onEdit,
      ),
    );
  }

  Widget _buildDeleteButton() {
    if (widget.static) {
      return Empty();
    }

    return AnimatedSwitcher(
      duration: animDurationDefault,
      child: FloatingButton.icon(
        key: ValueKey<bool>(_isImageShowing),
        icon: Icons.delete,
        padding: const EdgeInsets.only(
          right: paddingSmall,
          top: paddingSmall,
        ),
        transparentBackground: !_isImageShowing,
        onPressed: () {
          showDeleteDialog(
            context: context,
            description: Text(widget.deleteMessage!),
            onDelete: () {
              widget.onDelete?.call();
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  bool _calculateIsImageShowing() {
    if (!_hasImages) {
      return false;
    }

    // Images are showing if the page has scrolled enough to show a normal
    // AppBar instead of the entity's photos.
    var compressedAppBarHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight;
    return _scrollController.offset < _imageHeight - compressedAppBarHeight;
  }

  void _onScrollUpdated() {
    if (!_hasImages) {
      return;
    }

    // Only rebuild if the image becomes visible or hidden.
    var newIsImageShowing = _calculateIsImageShowing();
    if (newIsImageShowing == _isImageShowing) {
      return;
    }

    setState(() => _isImageShowing = newIsImageShowing);
  }
}
