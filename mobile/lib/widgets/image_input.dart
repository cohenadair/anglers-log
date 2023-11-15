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
  final SetInputController<PickedImage> controller;
  final bool isMulti;

  const ImageInput({
    required this.controller,
    this.initialImageNames = const [],
    this.isMulti = true,
  });

  @override
  ImageInputState createState() => ImageInputState();
}

class ImageInputState extends State<ImageInput> {
  Future<Set<PickedImage>>? _imagesFuture;

  SetInputController<PickedImage> get _controller => widget.controller;

  ImageManager get _imageManager => ImageManager.of(context);

  MediaQueryData get _mediaQuery => MediaQuery.of(context);

  @override
  void didUpdateWidget(ImageInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialImageNames != widget.initialImageNames) {
      _imagesFuture = _fetchInitialImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Need access to MediaQuery, so initialize future in the build method.
    _imagesFuture ??= _fetchInitialImage();

    return EmptyFutureBuilder<Set<PickedImage>>(
      future: _imagesFuture!,
      builder: (context, images) {
        return ImagePicker(
          initialImages: _controller.value,
          isMulti: widget.isMulti,
          onImagesPicked: (pickedImages) {
            setState(() {
              if (widget.isMulti) {
                _controller.addAll(pickedImages);
              } else {
                _controller.value = pickedImages;
              }
            });

            _imagesFuture = Future.value(_controller.value);
          },
          onImageDeleted: (image) {
            setState(() => _controller.remove(image));
            _imagesFuture = Future.value(_controller.value);
          },
        );
      },
    );
  }

  Future<Set<PickedImage>> _fetchInitialImage() async {
    if (widget.initialImageNames.isEmpty) {
      return Future.value({});
    }

    var imageMap = await _imageManager.images(
      imageNames: widget.initialImageNames,
      size: galleryMaxThumbSize,
      devicePixelRatio: _mediaQuery.devicePixelRatio,
    );

    if (imageMap.isEmpty) {
      return Future.value({});
    }

    var result = <PickedImage>{};
    imageMap.forEach(
      (file, bytes) => result.add(
        PickedImage(
          originalFile: file,
          thumbData: bytes,
        ),
      ),
    );

    _controller.addAll(result);
    return _controller.value;
  }
}

class SingleImageInput extends StatefulWidget {
  final String? initialImageName;
  final InputController<PickedImage> controller;

  const SingleImageInput({
    required this.controller,
    this.initialImageName,
  });

  @override
  SingleImageInputState createState() => SingleImageInputState();
}

class SingleImageInputState extends State<SingleImageInput> {
  final _multiController = ImagesInputController();
  late final VoidCallback _multiControllerListener;

  @override
  void initState() {
    super.initState();

    _multiControllerListener = _onUpdate;
    _multiController.addListener(_multiControllerListener);
  }

  @override
  void dispose() {
    _multiController.removeListener(_multiControllerListener);
    super.dispose();
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
