import 'package:flutter/material.dart';

import '../catch_manager.dart';
import '../entity_manager.dart';
import '../pages/photo_gallery_page.dart';
import '../res/dimen.dart';
import '../utils/page_utils.dart';
import '../widgets/app_bar_gradient.dart';
import '../widgets/photo.dart';

class PhotosPage extends StatelessWidget {
  static const _aspectRatioThumb = 1.0;

  @override
  Widget build(BuildContext context) {
    var catchManager = CatchManager.of(context);

    return Scaffold(
      body: EntityListenerBuilder(
        managers: [
          catchManager,
        ],
        builder: (context) {
          var fileNames = catchManager.imageNamesSortedByTimestamp(context);
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: galleryMaxThumbSize,
                      crossAxisSpacing: gallerySpacing,
                      mainAxisSpacing: gallerySpacing,
                      childAspectRatio: _aspectRatioThumb,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _buildThumbnail(context, fileNames, i),
                      childCount: fileNames.length,
                    ),
                  ),
                ],
              ),
              IgnorePointer(
                child: AppBarGradient(),
              ),
              SafeArea(
                top: true,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: BackButton(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThumbnail(
    BuildContext context,
    List<String> allFileNames,
    int index,
  ) {
    return GestureDetector(
      onTap: () => fade(
        context,
        PhotoGalleryPage(
          fileNames: allFileNames,
          initialFileName: allFileNames[index],
        ),
      ),
      child: Photo(
        fileName: allFileNames[index],
        cacheSize: galleryMaxThumbSize,
      ),
    );
  }
}
