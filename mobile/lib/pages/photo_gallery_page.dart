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

  ScrollPhysics? _scrollPhysics;

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            physics: _scrollPhysics,
            itemCount: widget.fileNames.length,
            itemBuilder: (context, i) => Container(
              color: Colors.black,
              child: Center(
                child: InteractiveViewer(
                  minScale: _minScale,
                  maxScale: _maxScale,
                  onInteractionEnd: _onInteractionEnd,
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
    );
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    // Don't allow scrolling in the PageView if the image is zoomed in. This is
    // required for panning to work property.
    setState(() {
      _scrollPhysics = _transformationController.value.getMaxScaleOnAxis() > 1
          ? const NeverScrollableScrollPhysics()
          : null;
    });
  }
}
