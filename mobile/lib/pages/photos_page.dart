import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/pages/photo_gallery_page.dart';
import 'package:mobile/utils/page_utils.dart';

class PhotosPage extends StatelessWidget {
  final _maxImageSize = 150.0;
  final _imageSpacing = 2.0;
  final _imageAspectRatio = 1.0;

  @override
  Widget build(BuildContext context) {
    CatchManager catchManager = CatchManager.of(context);
    ImageManager imageManager = ImageManager.of(context);

    return Scaffold(
      body: EntityListenerBuilder(
        managers: [
          catchManager,
        ],
        builder: (context) {
          List<File> catchImages = [];
          for (Catch cat in catchManager.catchesSortedByTimestamp(context)) {
            catchImages.addAll(imageManager.imageFiles(entityId: cat.id));
          }

          return CustomScrollView(
            slivers: [
              SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: _maxImageSize,
                  mainAxisSpacing: _imageSpacing,
                  crossAxisSpacing: _imageSpacing,
                  childAspectRatio: _imageAspectRatio,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildThumbnail(context, catchImages, i),
                  childCount: catchImages.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, List<File> allImages,
      int index)
  {
    return GestureDetector(
      onTap: () => fade(context, PhotoGalleryPage(
        images: allImages,
        initialImage: allImages[index],
      )),
      child: Hero(
        tag: allImages[index].path,
        child: Image.file(allImages[index],
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}