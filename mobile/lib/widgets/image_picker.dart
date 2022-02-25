import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../pages/image_picker_page.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/dialog_utils.dart';
import '../utils/page_utils.dart';
import '../widgets/widget.dart';
import 'button.dart';

/// An input widget that allows selection of one or more photos, as well as
/// taking a photo from the device's camera.
///
/// When used in an input form, consider using [ImageInput], which automatically
/// fetches images from [ImageManager].
class ImagePicker extends StatelessWidget {
  final bool isEnabled;
  final bool isMulti;
  final List<PickedImage> currentImages;
  final void Function(List<PickedImage>) onImagesPicked;
  final void Function(PickedImage) onImageDeleted;

  const ImagePicker({
    required this.onImagesPicked,
    required this.onImageDeleted,
    this.isEnabled = true,
    this.isMulti = true,
    List<PickedImage> initialImages = const [],
  }) : currentImages = initialImages;

  @override
  Widget build(BuildContext context) {
    return EnabledOpacity(
      isEnabled: isEnabled,
      child: InkWell(
        onTap: isEnabled
            ? () {
                push(
                  context,
                  ImagePickerPage(
                    allowsMultipleSelection: isMulti,
                    onImagesPicked: (_, images) => onImagesPicked(images),
                  ),
                );
              }
            : null,
        child: Padding(
          padding: insetsVerticalDefault,
          child: HorizontalSafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: insetsHorizontalDefault,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        isMulti
                            ? Strings.of(context).inputPhotosLabel
                            : Strings.of(context).inputPhotoLabel,
                        style: stylePrimary(context),
                      ),
                      RightChevronIcon(),
                    ],
                  ),
                ),
                _buildThumbnails(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnails() {
    if (currentImages.isEmpty) {
      return const Empty();
    }

    return Container(
      padding: insetsTopSmall,
      constraints: const BoxConstraints(maxHeight: galleryMaxThumbSize),
      child: ListView.separated(
        physics: isEnabled ? null : const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: currentImages.length,
        itemBuilder: (context, i) {
          var image = currentImages[i];
          var leftPadding = i == 0 ? paddingDefault : 0.0;
          var rightPadding =
              i == currentImages.length - 1 ? paddingDefault : 0.0;
          return Container(
            padding: EdgeInsets.only(
              left: leftPadding,
              right: rightPadding,
            ),
            width: galleryMaxThumbSize + leftPadding + rightPadding,
            child: ClipRRect(
              child: _buildImage(context, image),
              borderRadius: const BorderRadius.all(
                Radius.circular(floatingCornerRadius),
              ),
            ),
          );
        },
        separatorBuilder: (context, i) => Container(width: gallerySpacing),
      ),
    );
  }

  Widget _buildImage(BuildContext context, PickedImage image) {
    return Stack(
      fit: StackFit.expand,
      children: [
        image.thumbData == null
            ? Image.file(image.originalFile!, fit: BoxFit.cover)
            : Image.memory(image.thumbData!, fit: BoxFit.cover),
        Align(
          alignment: Alignment.topRight,
          child: FloatingButton.smallIcon(
            padding: insetsSmall,
            icon: Icons.close,
            onPressed: () {
              showDeleteDialog(
                context: context,
                description: Text(Strings.of(context).imagePickerConfirmDelete),
                onDelete: () => onImageDeleted(image),
              );
            },
          ),
        ),
      ],
    );
  }
}
