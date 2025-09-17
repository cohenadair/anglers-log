import 'package:flutter/material.dart';
import 'package:mobile/widgets/widget.dart';

import '../catch_manager.dart';
import '../entity_manager.dart';
import '../res/dimen.dart';
import '../utils/string_utils.dart';
import '../widgets/button.dart';
import '../widgets/empty_list_placeholder.dart';
import '../widgets/photo.dart';

class PhotosPage extends StatelessWidget {
  static const _aspectRatioThumb = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EntityListenerBuilder(
        managers: [CatchManager.get],
        builder: (context) {
          var fileNames = CatchManager.get.imageNamesSortedByTimestamp(context);
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
                          description: Strings.of(
                            context,
                          ).photosPageEmptyDescription,
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
