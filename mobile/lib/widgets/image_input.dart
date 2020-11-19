import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

/// An input widget that allows selection of one or more photos, as well as
/// taking a photo from the device's camera.
class ImageInput extends StatelessWidget {
  final bool enabled;
  final bool allowsMultipleSelection;
  final List<PickedImage> currentImages;
  final void Function(List<PickedImage>) onImagesPicked;
  final Future<bool> Function() requestPhotoPermission;

  ImageInput({
    @required this.onImagesPicked,
    @required this.requestPhotoPermission,
    this.enabled = true,
    this.allowsMultipleSelection = true,
    List<PickedImage> initialImages = const [],
  })  : assert(onImagesPicked != null),
        assert(initialImages != null),
        assert(requestPhotoPermission != null),
        currentImages = initialImages;

  ImageInput.single({
    @required Future<bool> Function() requestPhotoPermission,
    bool enabled,
    PickedImage currentImage,
    @required Function(PickedImage) onImagePicked,
  }) : this(
          requestPhotoPermission: requestPhotoPermission,
          enabled: enabled ?? true,
          allowsMultipleSelection: false,
          initialImages: currentImage == null ? [] : [currentImage],
          onImagesPicked: (images) =>
              onImagePicked(images.isNotEmpty ? images.first : null),
        );

  @override
  Widget build(BuildContext context) {
    return EnabledOpacity(
      enabled: enabled,
      child: InkWell(
        onTap: enabled
            ? () async {
                if (!(await requestPhotoPermission())) {
                  return;
                }

                push(
                  context,
                  ImagePickerPage(
                    allowsMultipleSelection: allowsMultipleSelection,
                    initialImages: currentImages,
                    onImagesPicked: (_, images) => onImagesPicked(images),
                  ),
                );
              }
            : null,
        child: Padding(
          padding: insetsDefault,
          child: HorizontalSafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    PrimaryLabel(allowsMultipleSelection
                        ? Strings.of(context).inputPhotosLabel
                        : Strings.of(context).inputPhotoLabel),
                    RightChevronIcon(),
                  ],
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
      return Empty();
    }

    return Container(
      padding: insetsTopWidgetSmall,
      constraints: BoxConstraints(maxHeight: galleryMaxThumbSize),
      child: ListView.separated(
        physics: enabled ? null : NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: currentImages.length,
        itemBuilder: (context, i) {
          PickedImage image = currentImages[i];
          return Container(
            width: galleryMaxThumbSize,
            child: ClipRRect(
              child: image.thumbData == null
                  ? Image.file(image.originalFile, fit: BoxFit.cover)
                  : Image.memory(image.thumbData, fit: BoxFit.cover),
              borderRadius: BorderRadius.all(
                Radius.circular(floatingCornerRadius),
              ),
            ),
          );
        },
        separatorBuilder: (context, i) => Container(width: gallerySpacing),
      ),
    );
  }
}
