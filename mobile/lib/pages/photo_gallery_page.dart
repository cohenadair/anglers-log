import 'dart:io';

import 'package:flutter/material.dart';

/// A page that displays a collection of images in a full screen pager.
class PhotoGalleryPage extends StatefulWidget {
  final List<File> images;
  final File initialImage;

  PhotoGalleryPage({
    @required this.images,
    @required this.initialImage,
  }) : assert(initialImage != null),
       assert(images != null && images.isNotEmpty);

  @override
  _PhotoGalleryPageState createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: widget.images.indexOf(widget.initialImage),
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
        itemCount: widget.images.length,
        itemBuilder: (context, i) => Container(
          color: Colors.black,
          child: Center(
            child: Hero(
              tag: widget.images[i].path,
              child: Image.file(widget.images[i],
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}