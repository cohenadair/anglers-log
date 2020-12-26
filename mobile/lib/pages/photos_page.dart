import 'package:flutter/material.dart';

import '../catch_manager.dart';
import '../entity_manager.dart';
import '../i18n/strings.dart';
import '../pages/photo_gallery_page.dart';
import '../res/dimen.dart';
import '../utils/page_utils.dart';
import '../widgets/app_bar_gradient.dart';
import '../widgets/empty_list_placeholder.dart';
import '../widgets/photo.dart';
import '../widgets/widget.dart';

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
                  SliverVisibility(
                    visible: fileNames.isNotEmpty,
                    sliver: SliverGrid(
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
                    replacementSliver: SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: EmptyListPlaceholder.static(
                          icon: Icons.photo_library,
                          title: Strings.of(context).photosPageEmptyTitle,
                          description:
                              Strings.of(context).photosPageEmptyDescription,
                          descriptionIcon: Icons.add_box_rounded,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              fileNames.isNotEmpty
                  ? IgnorePointer(
                      child: AppBarGradient(),
                    )
                  : Empty(),
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: insetsSmall,
                    child: BackButton(
                      color: Colors.black,
                    ),
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
