import 'package:flutter/material.dart';
import 'package:mobile/widgets/photo.dart';

/// A page that displays a collection of images in a full screen pager.
class PhotoGalleryPage extends StatefulWidget {
  final List<String> fileNames;
  final String initialFileName;

  PhotoGalleryPage({
    @required this.fileNames,
    @required this.initialFileName,
  }) : assert(fileNames != null && fileNames.isNotEmpty),
       assert(initialFileName != null);

  @override
  _PhotoGalleryPageState createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  PageController _controller;

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
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: BackButton(
          color: Colors.white,
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.fileNames.length,
        itemBuilder: (context, i) => Container(
          color: Colors.black,
          child: Center(
            child: Hero(
              tag: widget.fileNames[i],
              child: Photo(fileName: widget.fileNames[i]),
            ),
          ),
        ),
      ),
    );
  }
}