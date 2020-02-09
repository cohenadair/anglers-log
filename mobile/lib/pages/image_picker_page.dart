import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/no_results.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:path/path.dart' as Path;
import 'package:photo_manager/photo_manager.dart';

enum _ImagePickerSource {
  gallery, camera, browse
}

class ImagePickerPageResult {
  final File originalFile;

  /// May be `null`. For example, if a photo was taken with the camera, or
  /// selected from a cloud source.
  final Uint8List thumbData;

  ImagePickerPageResult(this.originalFile, this.thumbData);
}

/// [ImagePickerPage] is a custom image picking widget that allows the user to
/// select one or more photos from their library or cloud sources, as well as
/// take a picture with the device's camera.
///
/// Advantages of a custom solution over Flutter's image_picker plugin:
/// - Supports picking multiple photos
/// - Supports picking from cloud sources, such as Google Drive or iCloud Drive
/// - Consistent app UI
/// - Complete control over how photos are presented to the user.
///
/// [ImagePickerPage] uses the photo_manager plugin to get a list of all images
/// available on the device.
/// - https://github.com/CaiJingLong/flutter_photo_manager
///
/// [ImagePickerPage] uses the file_picker plugin to allow users to select
/// images from cloud sources. Unfortunately, there's no way to get cloud
/// documents to present a custom UI.
/// - https://pub.dev/packages/file_picker
///
/// [ImagePickerPage] uses the image_picker plugin for taking photos with the
/// device camera.
class ImagePickerPage extends StatefulWidget {
  final Function(List<ImagePickerPageResult>) onImagesPicked;
  final bool allowsMultipleSelection;

  ImagePickerPage({
    @required this.onImagesPicked,
    this.allowsMultipleSelection = true,
  }) : assert(onImagesPicked != null);

  ImagePickerPage.single({
    @required Function(ImagePickerPageResult) onImagePicked,
  }) : this(
    onImagesPicked: (files) => onImagePicked(files.first),
    allowsMultipleSelection: false,
  );

  @override
  _ImagePickerPageState createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  static const double _selectedPadding = 2.0;

  Future<List<AssetPathEntity>> _albumListFuture;
  Future<List<List<AssetEntity>>> _allAssetsFuture;

  // Use a map here so we don't get duplicate images, from the same image
  // existing in multiple albums.
  List<AssetEntity> _assets;

  // Cache thumb futures so they're not recreated each time the widget tree is
  // rebuilt.
  Map<int, Future<Uint8List>> _thumbFutures = {};

  Set<int> _selectedIndexes = {};
  _ImagePickerSource _currentSource = _ImagePickerSource.gallery;

  @override
  void initState() {
    super.initState();
    _albumListFuture = PhotoManager.getAssetPathList(type: RequestType.image);
  }

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        titleWidget: _buildSourceDropdown(),
        actions: [
          _buildDoneButton(),
        ],
      ),
      // First, get a list of all the asset packages, called albums in this
      // case.
      child: FutureBuilder<List<AssetPathEntity>>(
        future: _albumListFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Empty();
          }

          // Second, get a list of all assets in each album.
          // Only initialize _allAssetsFuture once.
          if (_allAssetsFuture == null) {
            // Futures to get assets from each album.
            List<Future<List<AssetEntity>>> albumAssetFutures = [];
            List<AssetPathEntity> albums = snapshot.data;
            for (var album in albums) {
              albumAssetFutures.add(album.assetList);
            }
            // Create a future that waits for all assets.
            _allAssetsFuture = Future.wait(albumAssetFutures);
          }

          // Third, wait to get assets from each album.
          return FutureBuilder<List<List<AssetEntity>>>(
            future: _allAssetsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Empty();
              }

              // Only initialize _assets once.
              if (_assets == null) {
                // Collect assets in a map to avoid duplicate assets that
                // appear in multiple albums.
                Map<String, AssetEntity> assetMap = {};
                List<List<AssetEntity>> albumAssets = snapshot.data;
                for (var assets in albumAssets) {
                  for (var asset in assets) {
                    assetMap[asset.id] = asset;
                  }
                }
                _assets = assetMap.values.toList();
                // Sort by most recent first.
                _assets.sort((lhs, rhs) =>
                    rhs.createDateTime.compareTo(lhs.createDateTime));
              }

              if (_assets.isEmpty) {
                return _buildNoPhotosFound();
              } else {
                return _buildImageGrid();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildSourceDropdown() {
    return DropdownButton(
      underline: Empty(),
      icon: DropdownIcon(),
      value: _currentSource,
      items: <DropdownMenuItem>[
        _buildSourceDropdownItem(
            Strings.of(context).imagePickerPageGalleryLabel,
            _ImagePickerSource.gallery),
        _buildSourceDropdownItem(
            Strings.of(context).imagePickerPageCameraLabel,
            _ImagePickerSource.camera),
        _buildSourceDropdownItem(
            Strings.of(context).imagePickerPageBrowseLabel,
            _ImagePickerSource.browse),
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

  DropdownMenuItem _buildSourceDropdownItem(String text,
      _ImagePickerSource value)
  {
    return DropdownMenuItem<_ImagePickerSource>(
      child: Text(text,
        style: Theme.of(context).textTheme.headline6,
      ),
      value: value,
    );
  }

  Widget _buildDoneButton() {
    if (!widget.allowsMultipleSelection) {
      return Empty();
    }

    return ActionButton(
      text: Strings.of(context).done,
      onPressed: () async {
        List<ImagePickerPageResult> result = [];
        for (var i in _selectedIndexes) {
          File file = await _assets[i].originFile;
          Uint8List thumb = await _assets[i].thumbData;
          result.add(ImagePickerPageResult(file, thumb));
        }

        _pop(result);
      },
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: galleryMaxThumbSize,
        crossAxisSpacing: gallerySpacing,
        mainAxisSpacing: gallerySpacing,
      ),
      itemCount: _assets.length,
      itemBuilder: (context, i) {
        var future = _thumbFutures[i];
        if (future == null) {
          future = _assets[i].thumbData;
          _thumbFutures[i] = future;
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
          File file = await _assets[index].originFile;
          _pop([ImagePickerPageResult(file, data)]);
        }
      },
      child: Container(
        color: Colors.black87,
        child: Opacity(
          opacity: selected ? 0.6 : 1.0,
          child: Image.memory(
            data,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildNoPhotosFound() {
    return Column(
      children: <Widget>[
        NoResults(Strings.of(context).imagePickerPageNoPhotosFound),
        Button(
          text: Strings.of(context).imagePickerPageOpenCameraLabel,
          onPressed: _openCamera,
        ),
      ],
    );
  }

  void _openCamera() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _pop([ImagePickerPageResult(image, null)]);
    }
  }

  void _openFilePicker() async {
    List<File> images;
    if (widget.allowsMultipleSelection) {
      images = await FilePicker.getMultiFile(type: FileType.ANY);
    } else {
      File image = await FilePicker.getFile(type: FileType.ANY);
      if (image != null) {
        images = [image];
      }
    }

    // No images were selected.
    if (images == null) {
      return;
    }

    // TODO: Don't allow selection of non-image files.
    // file_picker doesn't support multiple file extensions, so for now, check
    // the extension of each selected file.
    // https://github.com/miguelpruivo/flutter_file_picker/issues/99
    List<String> supportedFileExtensions = [
      ".jpg", ".jpeg", ".jpe", ".jif", ".jfif", ".jfi",
      ".png",
      ".gif",
      ".webp",
      ".tiff", ".tif",
      ".heif", ".heic",
    ];
    List<String> invalidFiles = [];
    for (File image in images.reversed) {
      if (!supportedFileExtensions.contains(Path.extension(image.path))) {
        invalidFiles.add(Path.basename(image.path));
        images.remove(image);
      }
    }

    _pop(images.map((image) => ImagePickerPageResult(image, null)).toList());
  }

  void _pop(List<ImagePickerPageResult> results) {
    widget.onImagesPicked(results);
    Navigator.pop(context);
  }
}