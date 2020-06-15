import 'package:flutter/material.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/pages/photo_gallery_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/photo.dart';

class PhotosPage extends StatelessWidget {
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
          List<String> fileNames = [];
          for (Catch cat in catchManager.catchesSortedByTimestamp(context)) {
            fileNames.addAll(imageManager.imageNames(entityId: cat.id));
          }

          return CustomScrollView(
            slivers: [
              SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: galleryMaxThumbSize,
                  crossAxisSpacing: gallerySpacing,
                  mainAxisSpacing: gallerySpacing,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildThumbnail(context, fileNames, i),
                  childCount: fileNames.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, List<String> allFileNames,
      int index)
  {
    return GestureDetector(
      onTap: () => fade(context, PhotoGalleryPage(
        fileNames: allFileNames,
        initialFileName: allFileNames[index],
      )),
      child: Photo(
        fileName: allFileNames[index],
        cacheSize: galleryMaxThumbSize,
      ),
    );
  }
}