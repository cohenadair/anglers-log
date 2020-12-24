import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:photo_manager/photo_manager.dart';

import '../i18n/strings.dart';
import '../res/dimen.dart';
import '../utils/dialog_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/button.dart';
import '../widgets/empty_list_placeholder.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';
import '../wrappers/file_picker_wrapper.dart';
import '../wrappers/image_picker_wrapper.dart';
import '../wrappers/photo_manager_wrapper.dart';

enum _ImagePickerSource { gallery, camera, browse }

class PickedImage {
  /// The original image file. This may be null if the [PickedImage] represents
  /// only a thumbnail image.
  final File originalFile;

  /// The [AssetEntity.id] for the picked image. This can be `null` if the
  /// image was taken with the camera, or picked from a cloud source.
  final String originalFileId;

  /// May be `null`. For example, if a photo was taken with the camera, or
  /// selected from a cloud source.
  final Uint8List thumbData;

  /// The location the image was taken, or null if unknown.
  final maps.LatLng position;

  /// The date and time the photo was taken, or null if unknown.
  final DateTime dateTime;

  PickedImage({
    this.originalFile,
    this.thumbData,
    this.originalFileId,
    this.position,
    this.dateTime,
  });
}

/// [ImagePickerPage] is a custom image picking widget that allows the user to
/// select one or more photos from their library or cloud sources, as well as
/// take a picture with the device's camera.
///
/// Advantages of a custom solution over Flutter's image_picker plugin:
/// - Supports picking multiple photos
/// - Supports picking from cloud sources, such as Google Drive or iCloud Drive
/// - Consistent with the rest of the app's UI
/// - Complete control over how photos are presented to the user.
///
/// [ImagePickerPage] uses the photo_manager plugin to get a list of all images
/// available on the device.
/// - https://github.com/CaiJingLong/flutter_photo_manager
///
/// [ImagePickerPage] uses the file_picker plugin to allow users to select
/// images from cloud sources. Unfortunately, there's no way to get cloud
/// documents to present a custom UI, so the system default is used.
/// - https://pub.dev/packages/file_picker
///
/// [ImagePickerPage] uses the image_picker plugin for taking photos with the
/// device camera.
/// - https://pub.dev/packages/image_picker
class ImagePickerPage extends StatefulWidget {
  final void Function(BuildContext context, List<PickedImage>) onImagesPicked;
  final bool allowsMultipleSelection;

  /// A list of images to be selected when the page opens.
  final List<PickedImage> initialImages;

  /// Text for the "Done" button. If `null`, uses "Done".
  final String doneButtonText;

  /// If `true`, pops the navigation stack when images are picked. Defaults to
  /// true.
  final bool popsOnFinish;

  /// If `true`, an image must be picked for the "Done" button to be enabled.
  /// Defaults to true.
  final bool requiresPick;

  /// A [Widget] to override the default [AppBar] leading behaviour.
  final Widget appBarLeading;

  ImagePickerPage({
    @required this.onImagesPicked,
    this.allowsMultipleSelection = true,
    this.initialImages = const [],
    this.doneButtonText,
    this.popsOnFinish = true,
    this.requiresPick = true,
    this.appBarLeading,
  }) : assert(onImagesPicked != null);

  ImagePickerPage.single({
    @required Function(BuildContext, PickedImage) onImagePicked,
  }) : this(
          onImagesPicked: (context, files) =>
              onImagePicked(context, files.isEmpty ? null : files.first),
          allowsMultipleSelection: false,
        );

  @override
  _ImagePickerPageState createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  static const double _pickedImageOpacity = 0.6;
  static const double _normalImageOpacity = 1.0;

  static const double _selectedPadding = 2.0;

  /// A future that gets a list of all albums in the user's gallery.
  Future<List<AssetPathEntity>> _albumListFuture;

  /// A future that gets a list of all available assets.
  Future<List<AssetEntity>> _allAssetsFuture;

  /// A list of all assets available from the user's gallery.
  List<AssetEntity> _assets;

  /// Cache thumbnail futures so they're not recreated each time the widget
  /// tree is rebuilt.
  final Map<int, Future<Uint8List>> _thumbnailFutures = {};

  final Set<int> _selectedIndexes = {};
  _ImagePickerSource _currentSource = _ImagePickerSource.gallery;

  /// Images that are initially selected. Elements of this array are removed
  /// as that element is loaded into the picker.
  List<PickedImage> _initialImages;

  FilePickerWrapper get _filePicker => FilePickerWrapper.of(context);

  ImagePickerWrapper get _imagePicker => ImagePickerWrapper.of(context);

  PhotoManagerWrapper get _photoManager => PhotoManagerWrapper.of(context);

  @override
  void initState() {
    super.initState();

    _initialImages = List.of(widget.initialImages);
    _albumListFuture = _photoManager.getAssetPathList(RequestType.image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSourceDropdown(),
        actions: [
          _buildDoneButton(),
        ],
        leading: widget.appBarLeading,
      ),
      // First, get a list of all the available albums.
      body: EmptyFutureBuilder<List<AssetPathEntity>>(
        future: _albumListFuture,
        builder: (context, assets) {
          // Second, get a list of all assets in the "all" album.
          // Lazy initialize _allAssetsFuture.
          if (_allAssetsFuture == null) {
            // Create a future that waits for all assets.
            var entity =
                assets.firstWhere((album) => album.isAll, orElse: () => null);
            _allAssetsFuture =
                entity == null ? Future.value([]) : entity.assetList;
          }

          // Third, wait to get assets from each album.
          return EmptyFutureBuilder<List<AssetEntity>>(
            future: _allAssetsFuture,
            builder: (context, assets) {
              // Lazy initialize _assets.
              if (_assets == null) {
                _assets = assets ?? [];
                // Sort by most recent first.
                _assets.sort((lhs, rhs) =>
                    rhs.createDateTime.compareTo(lhs.createDateTime));

                for (var i = 0; i < _assets.length; i++) {
                  for (var image in _initialImages.reversed) {
                    if (image.originalFileId != null &&
                        image.originalFileId == _assets[i].id) {
                      _selectedIndexes.add(i);
                      _initialImages.remove(image);
                      break;
                    }
                  }
                }
              }

              return _assets.isEmpty ? _buildNoResults() : _buildImageGrid();
            },
          );
        },
      ),
    );
  }

  Widget _buildSourceDropdown() {
    return DropdownButton<_ImagePickerSource>(
      underline: Empty(),
      icon: DropdownIcon(),
      value: _currentSource,
      items: [
        AppBarDropdownItem<_ImagePickerSource>(
          context: context,
          text: Strings.of(context).imagePickerPageGalleryLabel,
          value: _ImagePickerSource.gallery,
        ),
        AppBarDropdownItem<_ImagePickerSource>(
          context: context,
          text: Strings.of(context).imagePickerPageCameraLabel,
          value: _ImagePickerSource.camera,
        ),
        AppBarDropdownItem<_ImagePickerSource>(
          context: context,
          text: Strings.of(context).imagePickerPageBrowseLabel,
          value: _ImagePickerSource.browse,
        ),
      ],
      onChanged: (value) {
        setState(() {
          switch (value) {
            case _ImagePickerSource.gallery:
              _currentSource = value;
              break;
            case _ImagePickerSource.camera:
              _openCamera();
              break;
            case _ImagePickerSource.browse:
              _openFilePicker();
              break;
          }
        });
      },
    );
  }

  Widget _buildDoneButton() {
    if (!widget.allowsMultipleSelection) {
      return Empty();
    }

    var enabled = !widget.requiresPick ||
        _selectedIndexes.isNotEmpty ||
        widget.initialImages.isNotEmpty;

    return ActionButton(
      text: widget.doneButtonText ?? Strings.of(context).done,
      onPressed: enabled
          ? () async {
              var result = <PickedImage>[];
              for (var i in _selectedIndexes) {
                result.add(await _pickedImageFromAsset(_assets[i]));
              }

              _pop(result);
            }
          : null,
    );
  }

  Widget _buildImageGrid() {
    return Column(
      children: <Widget>[
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: galleryMaxThumbSize,
              crossAxisSpacing: gallerySpacing,
              mainAxisSpacing: gallerySpacing,
            ),
            itemCount: _assets.length,
            itemBuilder: (context, i) {
              var future = _thumbnailFutures[i];
              if (future == null) {
                future = _assets[i].thumbData;
                _thumbnailFutures[i] = future;
              }

              var selected = _selectedIndexes.contains(i);

              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  FutureBuilder<Uint8List>(
                    future: future,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return _buildThumbnail(snapshot.data, i, selected);
                      } else {
                        return Empty();
                      }
                    },
                  ),
                  Visibility(
                    visible: selected,
                    child: Padding(
                      padding: const EdgeInsets.all(_selectedPadding),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Icon(Icons.check_circle),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Container(
          color: Theme.of(context).primaryColor,
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                widget.allowsMultipleSelection
                    ? Padding(
                        padding: insetsHorizontalDefault,
                        child: PrimaryLabel(
                          format(
                            Strings.of(context).imagePickerPageSelectedLabel,
                            [_selectedIndexes.length, _assets.length],
                          ),
                        ),
                      )
                    : Empty(),
                ActionButton(
                  text: Strings.of(context).clear,
                  onPressed: () {
                    setState(() {
                      _selectedIndexes.clear();
                      if (!widget.allowsMultipleSelection) {
                        _pop([]);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail(Uint8List data, int index, bool selected) {
    return GestureDetector(
      onTap: () async {
        if (widget.allowsMultipleSelection) {
          setState(() {
            if (selected) {
              _selectedIndexes.remove(index);
            } else {
              _selectedIndexes.add(index);
            }
          });
        } else {
          _pop([await _pickedImageFromAsset(_assets[index], thumbData: data)]);
        }
      },
      child: Container(
        color: Colors.black87,
        child: Opacity(
          opacity: selected ? _pickedImageOpacity : _normalImageOpacity,
          child: Image.memory(
            data,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return EmptyListPlaceholder(
      icon: Icons.image_search,
      title: Strings.of(context).imagePickerPageNoPhotosFoundTitle,
      description: Strings.of(context).imagePickerPageNoPhotosFound,
    );
  }

  void _openCamera() async {
    var image = await _imagePicker.pickImage(ImageSource.camera);
    if (image != null) {
      _pop([PickedImage(originalFile: image)]);
    }
  }

  void _openFilePicker() async {
    List<File> images;
    if (widget.allowsMultipleSelection) {
      images = await _filePicker.getMultiFile(FileType.ANY);
    } else {
      var image = await _filePicker.getFile(type: FileType.ANY);
      if (image != null) {
        images = [image];
      }
    }

    // No images were selected.
    if (images == null || images.isEmpty) {
      return;
    }

    // TODO: Don't allow selection of non-image files.
    // file_picker doesn't support multiple file extensions, so for now, check
    // the extension of each selected file.
    // https://github.com/miguelpruivo/flutter_file_picker/issues/99
    var supportedFileExtensions = <String>[
      ".jpg",
      ".jpeg",
      ".jpe",
      ".jif",
      ".jfif",
      ".jfi",
      ".png",
      ".gif",
      ".webp",
      ".tiff",
      ".tif",
      ".heif",
      ".heic",
    ];
    var invalidFiles = <String>[];
    for (var i = images.length - 1; i >= 0; i--) {
      var image = images[i];
      if (!supportedFileExtensions.contains(path.extension(image.path))) {
        invalidFiles.add(path.basename(image.path));
        images.removeAt(i);
        // TODO: Record metrics for invalid file extensions; may be legit.
      }
    }

    if (images.isEmpty) {
      var msg = Strings.of(context).imagePickerPageInvalidSelectionSingle;
      if (widget.allowsMultipleSelection) {
        msg = Strings.of(context).imagePickerPageInvalidSelectionPlural;
      }
      showErrorDialog(context: context, description: Text(msg));
    } else {
      // TODO #391: Extract EXIF data from image.
      _pop(images.map((image) => PickedImage(originalFile: image)).toList());
    }
  }

  void _pop(List<PickedImage> results) {
    widget.onImagesPicked(context, results);

    if (widget.popsOnFinish) {
      Navigator.pop(context);
    }
  }

  Future<PickedImage> _pickedImageFromAsset(
    AssetEntity entity, {
    Uint8List thumbData,
  }) async {
    var lat = entity.latitude;
    var lng = entity.longitude;
    maps.LatLng position;

    if (_coordinatesAreValid(lat, lng)) {
      position = maps.LatLng(lat, lng);
    } else {
      // Coordinates are invalid, attempt to retrieve from OS.
      var latLng = await entity.latlngAsync();
      if (latLng != null &&
          _coordinatesAreValid(latLng.latitude, latLng.longitude)) {
        position = maps.LatLng(latLng.latitude, latLng.longitude);
      }
    }

    return PickedImage(
      originalFile: await entity.originFile,
      originalFileId: entity.id,
      thumbData: thumbData ?? await entity.thumbData,
      position: position,
      dateTime: entity.createDateTime,
    );
  }

  bool _coordinatesAreValid(double lat, double lng) {
    return lat != null && lng != null && lat != 0 && lng != 0;
  }
}
