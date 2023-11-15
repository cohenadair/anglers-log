import 'package:flutter/material.dart';
import 'package:mobile/utils/share_utils.dart';

import '../widgets/button.dart';
import '../widgets/photo.dart';

/// A page that displays a collection of images in a full screen pager.
class PhotoGalleryPage extends StatefulWidget {
  final List<String> fileNames;
  final String initialFileName;

  PhotoGalleryPage({
    required this.fileNames,
    required this.initialFileName,
  }) : assert(fileNames.isNotEmpty);

  @override
  PhotoGalleryPageState createState() => PhotoGalleryPageState();
}

class PhotoGalleryPageState extends State<PhotoGalleryPage> {
  static const _minScale = 1.0;
  static const _maxScale = 5.0;
  static const _swipeDownVelocity = 500.0;

  final _transformationController = TransformationController();
  late PageController _controller;
  late String _currentImageName;

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
    return GestureDetector(
      // Don't allow swipe to dismiss when zoomed in on photo.
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
              // Don't allow page view navigation when zoomed in on photo.
              physics:
                  _isDismissible ? null : const NeverScrollableScrollPhysics(),
              itemCount: widget.fileNames.length,
              itemBuilder: (context, i) {
                _currentImageName = widget.fileNames[i];

                return Container(
                  color: Colors.black,
                  child: Center(
                    child: InteractiveViewer(
                      minScale: _minScale,
                      maxScale: _maxScale,
                      onInteractionEnd: (_) => setState(() {}),
                      transformationController: _transformationController,
                      clipBehavior: Clip.none,
                      child: Photo(fileName: _currentImageName),
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
                  FloatingButton.icon(
                    icon: shareIconData(context),
                    onPressed: () => share(context, [_currentImageName]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isDismissible =>
      _transformationController.value.getMaxScaleOnAxis() <= 1;
}
