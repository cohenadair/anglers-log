import 'package:flutter/material.dart';
import 'package:mobile/widgets/widget.dart';

import '../catch_manager.dart';
import '../entity_manager.dart';
import '../i18n/strings.dart';
import '../res/dimen.dart';
import '../widgets/button.dart';
import '../widgets/empty_list_placeholder.dart';
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
                  SliverVisibility(
                    visible: fileNames.isNotEmpty,
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: galleryMaxThumbSize,
                        crossAxisSpacing: gallerySpacing,
                        mainAxisSpacing: gallerySpacing,
                        childAspectRatio: _aspectRatioThumb,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Photo(
                          fileName: fileNames[i],
                          cacheSize: galleryMaxThumbSize,
                          galleryImages: fileNames,
                        ),
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
                          descriptionIcon: iconBottomBarAdd,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: FloatingButton.back(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
