import 'package:flutter/material.dart';

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
  _PhotoGalleryPageState createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  static const _minScale = 1.0;
  static const _maxScale = 5.0;

  final _transformationController = TransformationController();
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: widget.fileNames.indexOf(widget.initialFileName),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Don't allow swipe to dismiss when zoomed in on photo.
      onVerticalDragEnd:
          _isDismissible ? (_) => Navigator.of(context).pop() : null,
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
              itemBuilder: (context, i) => Container(
                color: Colors.black,
                child: Center(
                  child: InteractiveViewer(
                    minScale: _minScale,
                    maxScale: _maxScale,
                    onInteractionEnd: (_) => setState(() {}),
                    transformationController: _transformationController,
                    clipBehavior: Clip.none,
                    child: Photo(fileName: widget.fileNames[i]),
                  ),
                ),
              ),
            ),
            const SafeArea(child: FloatingButton.close()),
          ],
        ),
      ),
    );
  }

  bool get _isDismissible =>
      _transformationController.value.getMaxScaleOnAxis() <= 1;
}
