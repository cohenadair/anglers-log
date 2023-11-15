import 'package:flutter/material.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/utils/share_utils.dart';
import 'package:mobile/widgets/blurred_background_photo.dart';
import 'package:mobile/wrappers/io_wrapper.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../utils/dialog_utils.dart';
import '../widgets/button.dart';
import '../widgets/custom_entity_values.dart';
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

  /// When non-null, a share button is shown in the app bar that allows users
  /// to share this entity.
  final VoidCallback? onShare;

  final EdgeInsets padding;

  /// When true, the underlying [Entity] cannot be modified.
  final bool isStatic;

  final List<CustomEntityValue> customEntityValues;

  EntityPage({
    required this.children,
    this.customEntityValues = const [],
    this.imageNames = const [],
    this.deleteMessage,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.padding = insetsDefault,
    this.isStatic = false,
  })  : assert(isStatic || (isNotEmpty(deleteMessage) && onEdit != null)),
        assert(isStatic || onDelete != null);

  @override
  EntityPageState createState() => EntityPageState();
}

class EntityPageState extends State<EntityPage> {
  final double _androidShareOffset = -1.5;
  final double _imageHeightFactor = 3;
  final double _carouselDotSize = 8.0;
  final double _carouselOpacity = 0.5;

  final _scrollController = ScrollController();
  late VoidCallback _scrollListener;

  var _imageIndex = 0;
  var _isImageShowing = false;
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

    _isImageShowing = _hasImages;
    _scrollListener = _onScrollUpdated;
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  void didUpdateWidget(EntityPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isImageShowing = _calculateIsImageShowing();
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
              _buildShareButton(),
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
    var carousel = <Widget>[];
    var imageNames = widget.imageNames;

    if (imageNames.length > 1) {
      for (var i = 0; i < imageNames.length; i++) {
        carousel.add(Container(
          width: _carouselDotSize,
          height: _carouselDotSize,
          decoration: BoxDecoration(
            color: imageNames.indexOf(imageNames[i]) == _imageIndex
                ? context.colorDefault
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
                  (fileName) => BlurredBackgroundPhoto(
                    imageName: fileName,
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
    if (widget.isStatic) {
      return const Empty();
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
    if (widget.isStatic) {
      return const Empty();
    }

    return AnimatedSwitcher(
      duration: animDurationDefault,
      child: FloatingButton.icon(
        key: ValueKey<bool>(_isImageShowing),
        icon: Icons.delete,
        padding: EdgeInsets.only(
          right: widget.onShare == null ? paddingSmall : paddingDefault,
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

  Widget _buildShareButton() {
    if (widget.onShare == null) {
      return const Empty();
    }

    return AnimatedSwitcher(
      duration: animDurationDefault,
      child: FloatingButton(
        key: ValueKey<bool>(_isImageShowing),
        icon: shareIconData(context),
        iconOffsetX: _ioWrapper.isAndroid ? _androidShareOffset : 0,
        padding: const EdgeInsets.only(
          right: paddingSmall,
          top: paddingSmall,
        ),
        transparentBackground: !_isImageShowing,
        onPressed: widget.onShare,
        tooltip: Strings.of(context).share,
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
