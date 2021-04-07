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
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.fileNames.length,
            itemBuilder: (context, i) => Container(
              color: Colors.black,
              child: Center(
                child: Photo(fileName: widget.fileNames[i]),
              ),
            ),
          ),
          SafeArea(child: FloatingButton.close()),
        ],
      ),
    );
  }
}
