import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoInput extends StatelessWidget {
  final bool enabled;
  final bool allowsMultipleSelection;
  final List<ImagePickerPageResult> currentImages;
  final Function(List<ImagePickerPageResult>) onImagesPicked;
  final EdgeInsets padding;

  PhotoInput({
    @required this.enabled,
    this.allowsMultipleSelection = true,
    this.currentImages = const [],
    @required this.onImagesPicked,
    this.padding = insetsZero,
  }) : assert(onImagesPicked != null),
       assert(currentImages != null);

  PhotoInput.single({
    @required enabled,
    ImagePickerPageResult currentImage,
    @required Function(ImagePickerPageResult) onImagePicked,
    EdgeInsets padding = insetsZero,
  }) : this(
    enabled: enabled,
    allowsMultipleSelection: false,
    currentImages: currentImage == null ? [] : [currentImage],
    onImagesPicked: (images) =>
        onImagePicked(images.isNotEmpty ? images.first : null),
    padding: padding,
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
            onImagesPicked: (images) {
              onImagesPicked(images);
            },
          ));
        } : null,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  LabelText(text: allowsMultipleSelection
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
          ImagePickerPageResult image = currentImages[i];
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