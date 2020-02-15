import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:photo_manager/photo_manager.dart';

/// An input widget that allows selection of one or more photos, as well as
/// taking a photo from the device's camera.
class PhotoInput extends StatelessWidget {
  final bool enabled;
  final bool allowsMultipleSelection;
  final List<PickedImage> currentImages;
  final Function(List<PickedImage>) onImagesPicked;

  PhotoInput({
    @required this.enabled,
    this.allowsMultipleSelection = true,
    List<PickedImage> initialImages = const [],
    @required this.onImagesPicked,
  }) : assert(onImagesPicked != null),
       assert(initialImages != null),
       currentImages = initialImages;

  PhotoInput.single({
    @required enabled,
    PickedImage currentImage,
    @required Function(PickedImage) onImagePicked,
  }) : this(
    enabled: enabled,
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
        onTap: enabled ? () async {
          if (!(await PhotoManager.requestPermission())) {
            return;
          }

          push(context, ImagePickerPage(
            allowsMultipleSelection: allowsMultipleSelection,
            initialImages: currentImages,
            onImagesPicked: (images) {
              onImagesPicked(images);
            },
          ));
        } : null,
        child: Padding(
          padding: EdgeInsets.only(
            left: paddingDefault,
            right: enabled ? paddingDefault : 0,
            top: paddingDefault,
            bottom: paddingDefault,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  LabelText(allowsMultipleSelection
                      ? Strings.of(context).inputPhotosLabel
                      : Strings.of(context).inputPhotoLabel
                  ),
                  RightChevronIcon(),
                ],
              ),
              _buildThumbnails(),
            ],
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
            child: image.thumbData == null
                ? Image.file(image.originalFile, fit: BoxFit.cover)
                : Image.memory(image.thumbData, fit: BoxFit.cover),
          );
        },
        separatorBuilder: (context, i) => Container(width: gallerySpacing),
      ),
    );
  }
}