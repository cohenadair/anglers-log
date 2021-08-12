import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../image_manager.dart';
import '../pages/image_picker_page.dart';
import '../res/dimen.dart';
import 'image_picker.dart';
import 'input_controller.dart';
import 'widget.dart';

/// A form input widget that allows picking of images from a user's device.
/// For picking a single image, consider using [SingleImageInput].
class ImageInput extends StatefulWidget {
  final List<String> initialImageNames;
  final ListInputController<PickedImage> controller;
  final bool isMulti;

  ImageInput({
    required this.initialImageNames,
    required this.controller,
    this.isMulti = true,
  });

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  Future<List<PickedImage>> _imagesFuture = Future.value([]);

  ListInputController<PickedImage> get _controller => widget.controller;

  ImageManager get _imageManager => ImageManager.of(context);

  @override
  void initState() {
    super.initState();
    _imagesFuture = _fetchInitialImage();
  }

  @override
  Widget build(BuildContext context) {
    return EmptyFutureBuilder<List<PickedImage>>(
      future: _imagesFuture,
      builder: (context, images) {
        return ImagePicker(
          initialImages: _controller.value,
          isMulti: widget.isMulti,
          onImagesPicked: (pickedImage) {
            setState(() {
              _controller.value = pickedImage;
              _imagesFuture = Future.value(_controller.value);
            });
          },
        );
      },
    );
  }

  Future<List<PickedImage>> _fetchInitialImage() async {
    if (widget.initialImageNames.isEmpty) {
      return Future.value([]);
    }

    var imageMap = await _imageManager.images(
      context,
      imageNames: widget.initialImageNames,
      size: galleryMaxThumbSize,
    );

    if (imageMap.isEmpty) {
      return Future.value(null);
    }

    var result = <PickedImage>[];
    imageMap.forEach(
      (file, bytes) => result.add(
        PickedImage(
          originalFile: file,
          thumbData: bytes,
        ),
      ),
    );

    _controller.value = result;
    return result;
  }
}

class SingleImageInput extends StatefulWidget {
  final String? initialImageName;
  final InputController<PickedImage> controller;

  SingleImageInput({
    required this.initialImageName,
    required this.controller,
  });

  @override
  _SingleImageInputState createState() => _SingleImageInputState();
}

class _SingleImageInputState extends State<SingleImageInput> {
  final _multiController = ListInputController<PickedImage>();
  late final _multiControllerListener;

  @override
  void initState() {
    super.initState();

    _multiControllerListener = _onUpdate;
    _multiController.addListener(_multiControllerListener);
  }

  @override
  void dispose() {
    super.dispose();
    _multiController.removeListener(_multiControllerListener);
  }

  @override
  Widget build(BuildContext context) {
    return ImageInput(
      initialImageNames:
          isEmpty(widget.initialImageName) ? [] : [widget.initialImageName!],
      controller: _multiController,
      isMulti: false,
    );
  }

  void _onUpdate() {
    widget.controller.value =
        _multiController.value.isNotEmpty ? _multiController.value.first : null;
  }
}
