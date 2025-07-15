import 'package:flutter/material.dart';
import 'package:mobile/utils/share_utils.dart';
import 'package:mobile/utils/widget_utils.dart';

import '../widgets/button.dart';
import '../widgets/photo.dart';

/// A page that displays a collection of images in a full screen pager.
class PhotoGalleryPage extends StatefulWidget {
  final List<String> fileNames;
  final String initialFileName;

  PhotoGalleryPage({required this.fileNames, required this.initialFileName})
    : assert(fileNames.isNotEmpty);

  @override
  PhotoGalleryPageState createState() => PhotoGalleryPageState();
}

class PhotoGalleryPageState extends State<PhotoGalleryPage> {
  static const _minScale = 1.0;
  static const _maxScale = 5.0;
  static const _swipeDownVelocity = 500.0;

  final _shareButtonKey = GlobalKey();
  final _transformationController = TransformationController();
  late PageController _controller;
  late String _currentImageName;

  /// Tracks number of current touches (i.e. pointers) on the screen. Used to
  /// add/remove the swipe down dismiss gesture detector so it doesn't interfere
  /// with the photo's pinch and zoom.
  int _pointerCount = 0;

  @override
  void initState() {
    super.initState();

    var initialIndex = widget.fileNames.indexOf(widget.initialFileName);
    _controller = PageController(initialPage: initialIndex);
    _currentImageName = widget.fileNames[initialIndex];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pointerCount++),
      onPointerUp: (_) => setState(() => _pointerCount--),
      child: GestureDetector(
        onVerticalDragEnd: _isDismissible
            ? (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! > _swipeDownVelocity) {
                  Navigator.of(context).pop();
                }
              }
            : null,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                physics: _isDismissible
                    ? null
                    : const NeverScrollableScrollPhysics(),
                itemCount: widget.fileNames.length,
                itemBuilder: (context, i) {
                  _currentImageName = widget.fileNames[i];

                  return Center(
                    child: InteractiveViewer(
                      minScale: _minScale,
                      maxScale: _maxScale,
                      onInteractionEnd: (_) => setState(() {}),
                      transformationController: _transformationController,
                      clipBehavior: Clip.none,
                      child: Container(
                        color: Colors.black,
                        constraints: const BoxConstraints.expand(),
                        child: Photo(
                          fileName: _currentImageName,
                          boxFit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const FloatingButton.close(),
                    FloatingButton.share(
                      key: _shareButtonKey,
                      context: context,
                      onPressed: () => share(context, [
                        _currentImageName,
                      ], _shareButtonKey.globalPosition()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Don't allow navigating away from the current photo if it's already zoomed
  /// in, or the user is in the process of zooming (2+ fingers down).
  bool get _isDismissible =>
      _transformationController.value.getMaxScaleOnAxis() <= 1 &&
      _pointerCount <= 1;
}
