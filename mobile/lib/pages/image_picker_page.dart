import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as maps;
import 'package:image_picker/image_picker.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/wrappers/device_info_wrapper.dart';
import 'package:mobile/wrappers/exif_wrapper.dart';
import 'package:mobile/wrappers/io_wrapper.dart';
import 'package:path/path.dart' as path;
import 'package:photo_manager/photo_manager.dart';
import 'package:quiver/core.dart';
import 'package:quiver/strings.dart';
import 'package:timezone/timezone.dart';

import '../i18n/strings.dart';
import '../log.dart';
import '../res/dimen.dart';
import '../res/gen/custom_icons.dart';
import '../res/style.dart';
import '../utils/snackbar_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/button.dart';
import '../widgets/empty_list_placeholder.dart';
import '../widgets/safe_image.dart';
import '../widgets/widget.dart';
import '../wrappers/file_picker_wrapper.dart';
import '../wrappers/image_picker_wrapper.dart';
import '../wrappers/permission_handler_wrapper.dart';
import '../wrappers/photo_manager_wrapper.dart';

enum _ImagePickerSource { gallery, camera, browse }

class PickedImage {
  /// The original image file. This may be null if the [PickedImage] represents
  /// only a thumbnail image.
  final File? originalFile;

  /// The [AssetEntity.id] for the picked image. This can be null if the
  /// image was taken with the camera, or picked from a cloud source.
  final String? originalFileId;

  /// May be null. For example, if a photo was taken with the camera, or
  /// selected from a cloud source.
  final Uint8List? thumbData;

  /// The location the image was taken, or null if unknown.
  final maps.LatLng? latLng;

  /// The UTC date time the photo was taken, or null if unknown.
  final TZDateTime? dateTime;

  PickedImage({
    this.originalFile,
    this.thumbData,
    this.originalFileId,
    this.latLng,
    this.dateTime,
  });

  String get fileName => path.basename(originalFile?.path ?? "");

  @override
  String toString() => "originalFile=$fileName; "
      "originalFileId=$originalFileId; "
      "thumbData=${thumbData?.length}; "
      "latLng=$latLng; "
      "dateTime=$dateTime";

  @override
  bool operator ==(Object other) =>
      other is PickedImage &&
      fileName == other.fileName &&
      originalFileId == other.originalFileId &&
      listEquals(thumbData?.toList(), other.thumbData?.toList()) &&
      latLng == other.latLng &&
      dateTime == other.dateTime;

  @override
  int get hashCode => hashObjects([
        fileName.hashCode,
        originalFileId?.hashCode ?? 0,
        thumbData?.hashCode ?? 0,
        latLng?.hashCode ?? 0,
        dateTime?.hashCode ?? 0,
      ]);
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
///
/// [ImagePickerPage] should never handle initially selected images for the
/// following reasons:
/// - The photo grid is paginated so there's no way to link initial images to
///   images on page X, unless the user scrolls to them.
/// - When editing entities, such as trips, [PickedImage.originalFileId] will
///   always be null because they were not picked from the gallery; they were
///   attached from the app.
/// There's no known way to solve both problems in a user-friendly way.
class ImagePickerPage extends StatefulWidget {
  /// Invoked when the user presses the back button (if
  /// [backInvokesOnImagesPicked] is true), and all images have been loaded from
  /// the device's gallery.
  final void Function(BuildContext context, List<PickedImage>) onImagesPicked;

  /// When true (default), [onImagesPicked] is invoked when the back button is
  /// pressed. If false, [onImagesPicked] is not invoked.
  final bool backInvokesOnImagesPicked;

  final bool allowsMultipleSelection;

  /// Optional custom text for the trailing [AppBar] action. If null (default),
  /// no button is rendered, and [onImagesPicked] is invoked when the user
  /// presses the back button.
  final String? actionText;

  /// If true, pops the navigation stack when images are picked. Defaults to
  /// true.
  final bool popsOnFinish;

  /// If true, an image must be picked for the [actionText] button to be
  /// enabled. Defaults to true.
  final bool requiresPick;

  /// A [Widget] to override the default [AppBar] leading behaviour.
  final Widget? appBarLeading;

  const ImagePickerPage({
    required this.onImagesPicked,
    this.backInvokesOnImagesPicked = true,
    this.allowsMultipleSelection = true,
    this.actionText,
    this.popsOnFinish = true,
    this.requiresPick = true,
    this.appBarLeading,
  });

  ImagePickerPage.single({
    required Function(BuildContext, PickedImage?) onImagePicked,
  }) : this(
          onImagesPicked: (context, files) =>
              onImagePicked(context, files.isEmpty ? null : files.first),
          allowsMultipleSelection: false,
        );

  @override
  ImagePickerPageState createState() => ImagePickerPageState();
}

class ImagePickerPageState extends State<ImagePickerPage> {
  static const double _pickedImageOpacity = 0.6;
  static const double _normalImageOpacity = 1.0;
  static const double _selectedPadding = 2.0;

  /// A new page (in image grid pagination) is loaded when the grid's scroll
  /// position reaches its max - thumbnail size * _loadNextPageFactor.
  static const int _loadNextPageFactor = 3;

  final _log = const Log("ImagePickerPage");

  /// A future that gets an [AssetPathEntity] containing all of a users photos.
  Future<AssetPathEntity?>? _galleryFuture;

  /// The data retrieved from [_galleryFuture].
  AssetPathEntity? _galleryAsset;

  /// A future that gets a list of assets.
  Future<List<AssetEntity>>? _assetsFuture;

  /// A list of all loaded assets. Retrieved from [_assetsFuture]. Note that a
  /// [LinkedHashSet] is used here for two reasons:
  ///   1. So duplicate assets aren't added on subsequent builds, and
  ///   2. Because indexes are used to track "selected" images.
  final LinkedHashSet<AssetEntity> _assets = LinkedHashSet<AssetEntity>();

  /// The current page of the image grid pagination.
  int _currentPage = 0;

  bool _isLoadingPage = false;
  bool _isLoadingGalleryImages = false;

  /// Cache thumbnail futures so they're not recreated each time the widget
  /// tree is rebuilt.
  final Map<int, Future<Uint8List?>> _thumbnailFutures = {};

  final Set<int> _selectedIndexes = {};
  _ImagePickerSource _currentSource = _ImagePickerSource.gallery;

  late Future<bool> _isPermissionGrantedFuture;

  DeviceInfoWrapper get _deviceInfoWrapper => DeviceInfoWrapper.of(context);

  FilePickerWrapper get _filePicker => FilePickerWrapper.of(context);

  ImagePickerWrapper get _imagePicker => ImagePickerWrapper.of(context);

  IoWrapper get _ioWrapper => IoWrapper.of(context);

  PermissionHandlerWrapper get _permissionHandlerWrapper =>
      PermissionHandlerWrapper.of(context);

  PhotoManagerWrapper get _photoManager => PhotoManagerWrapper.of(context);

  TimeManager get _timeManager => TimeManager.of(context);

  @override
  void initState() {
    super.initState();
    _isPermissionGrantedFuture =
        _permissionHandlerWrapper.requestPhotos(_deviceInfoWrapper, _ioWrapper);
  }

  @override
  Widget build(BuildContext context) {
    var child = Scaffold(
      appBar: AppBar(
        title: _buildSourceDropdown(),
        actions: [
          _buildAction(),
        ],
        leading: widget.appBarLeading,
      ),
      body: FutureBuilder<bool>(
        future: _isPermissionGrantedFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _buildPlaceholderGrid();
          }

          // User didn't grant photos permission.
          if (!snapshot.data!) {
            return _buildNoPermission();
          }

          _galleryFuture ??=
              _photoManager.getAllAssetPathEntity(RequestType.image);

          return FutureBuilder<AssetPathEntity?>(
            future: _galleryFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return _buildPlaceholderGrid();
              }

              _galleryAsset = snapshot.data;

              // If there's no "all" don't bother trying to fetch them.
              if (_galleryAsset == null) {
                return _buildNoResults();
              }

              // Get a list of all assets. Lazy initialize so a new future isn't
              // created each build.
              if (_assetsFuture == null) {
                _loadNextPage();
              }

              // Get assets.
              return FutureBuilder<List<AssetEntity>>(
                future: _assetsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return _buildPlaceholderGrid();
                  }

                  // Device has no photos to choose from.
                  if (_assets.isEmpty && snapshot.data!.isEmpty) {
                    return _buildNoResults();
                  }

                  var oldLength = _assets.length;
                  _assets.addAll(snapshot.data!);

                  // If we're loading a new page, wait for the assets size to
                  // change before resetting the flag.
                  if (_isLoadingPage) {
                    _isLoadingPage = oldLength == _assets.length;
                  }

                  return _buildImageGrid();
                },
              );
            },
          );
        },
      ),
    );

    return WillPopScope(
      onWillPop: () {
        if (widget.backInvokesOnImagesPicked) {
          _finishPickingImagesFromGallery();
          // Always return false here. The page will be popped manually after
          // picked images are fetched.
          return Future.value(false);
        } else {
          // Pop the page, since there will be no manual pop since the finished
          // callback is not invoked.
          return Future.value(true);
        }
      },
      child: child,
    );
  }

  Widget _buildSourceDropdown() {
    return DropdownButton<_ImagePickerSource>(
      underline: const Empty(),
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
        if (value == null) {
          return;
        }

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

  Widget _buildAction() {
    if (_isLoadingGalleryImages) {
      return const Loading.appBar();
    }

    if (!widget.allowsMultipleSelection || isEmpty(widget.actionText)) {
      return const Empty();
    }

    VoidCallback? onPressed;
    if (!widget.requiresPick || _selectedIndexes.isNotEmpty) {
      onPressed = () => _finishPickingImagesFromGallery();
    }

    return ActionButton(
      text: widget.actionText,
      onPressed: onPressed,
    );
  }

  Widget _buildGrid({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return Column(
      children: <Widget>[
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            // Remove default safe area padding added to GridView.
            removeBottom: true,
            removeTop: true,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: galleryMaxThumbSize,
                crossAxisSpacing: gallerySpacing,
                mainAxisSpacing: gallerySpacing,
              ),
              itemCount: itemCount,
              itemBuilder: itemBuilder,
            ),
          ),
        ),
        Container(
          color: Theme.of(context).primaryColor,
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                widget.allowsMultipleSelection
                    ? _buildSelectedText()
                    : const Empty(),
                ActionButton(
                  text: Strings.of(context).clear,
                  onPressed: () {
                    setState(() {
                      _isLoadingGalleryImages = false;
                      _selectedIndexes.clear();
                      if (!widget.allowsMultipleSelection) {
                        _pop([], showError: false);
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

  Widget _buildSelectedText() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: FutureBuilder<int>(
        future: _galleryAsset?.assetCountAsync ?? Future.value(0),
        builder: (context, snapshot) => Text(
          format(
            Strings.of(context).imagePickerPageSelectedLabel,
            [_selectedIndexes.length, snapshot.hasData ? snapshot.data : 0],
          ),
          style: stylePrimary(context),
        ),
      ),
    );
  }

  Widget _buildPlaceholderGrid() {
    return _buildGrid(
      itemCount: _approxThumbsOnScreen(),
      itemBuilder: (context, i) => _buildImagePlaceholder(),
    );
  }

  Widget _buildImageGrid() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (_isLoadingPage) {
          return false;
        }

        // Load the next page when we're
        // galleryMaxThumbSize * _loadNextPageFactor from the bottom of the
        // scrollable area.
        var metrics = notification.metrics;
        if (metrics.pixels >=
            metrics.maxScrollExtent -
                galleryMaxThumbSize * _loadNextPageFactor) {
          _isLoadingPage = true;
          setState(_loadNextPage);
        }

        return false;
      },
      child: _buildGrid(
        itemCount: _assets.length,
        itemBuilder: (context, i) {
          var future = _thumbnailFutures[i];
          if (future == null) {
            future = _assets.elementAt(i).thumbnailData;
            _thumbnailFutures[i] = future;
          }

          var selected = _selectedIndexes.contains(i);

          return FutureBuilder<Uint8List?>(
            future: future,
            builder: (context, snapshot) {
              Widget child;

              if (snapshot.hasData) {
                child = Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    _buildThumbnail(snapshot.data!, i, selected),
                    _buildSelectedCover(selected),
                  ],
                );
              } else {
                child = _buildImagePlaceholder();
              }

              return AnimatedSwitcher(
                duration: animDurationDefault,
                child: child,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: const BoxConstraints.expand(), // Fill parent.
          decoration: BoxDecoration(
            color: context.colorDefault,
          ),
          child: Icon(
            CustomIcons.catches,
            color: Colors.white,
            size: min<double>(constraints.maxWidth, constraints.maxHeight) / 2,
          ),
        );
      },
    );
  }

  Widget _buildThumbnail(Uint8List data, int index, bool selected) {
    return GestureDetector(
      onTap: () {
        if (widget.allowsMultipleSelection) {
          setState(() {
            if (selected) {
              _selectedIndexes.remove(index);
            } else {
              _selectedIndexes.add(index);
            }
          });
        } else {
          _finishPickingImageFromGallery(data, index);
        }
      },
      child: Opacity(
        opacity: selected ? _pickedImageOpacity : _normalImageOpacity,
        child: SafeImage.memory(
          data,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSelectedCover(bool selected) {
    return Visibility(
      visible: selected,
      child: const Padding(
        padding: EdgeInsets.all(_selectedPadding),
        child: Align(
          alignment: Alignment.topRight,
          child: Icon(Icons.check_circle),
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

  Widget _buildNoPermission() {
    return Center(
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              EmptyListPlaceholder(
                icon: Icons.image_not_supported,
                title: Strings.of(context).imagePickerPageNoPermissionTitle,
                description:
                    Strings.of(context).imagePickerPageNoPermissionMessage,
                scrollable: false,
              ),
              const VerticalSpace(paddingDefault),
              Button(
                text: Strings.of(context).imagePickerPageOpenSettings,
                onPressed: () => _permissionHandlerWrapper.openSettings(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCamera() async {
    var image = await _imagePicker.pickImage(ImageSource.camera);
    if (image == null) {
      return;
    }

    var file = File(image.path);
    var exif = await _exifFromFile(file);
    var pickedImage = PickedImage(
      originalFile: file,
      dateTime: exif.dateTime,
      latLng: exif.latLng,
    );

    _pop([pickedImage], showError: false);
  }

  void _openFilePicker() async {
    var pickerResult = await _filePicker.pickFiles(
      type: FileType.image,
      allowMultiple: widget.allowsMultipleSelection,
    );

    // User cancelled picker.
    if (pickerResult == null) {
      return;
    }

    var images = pickerResult.files
        .where((f) => isNotEmpty(f.path))
        .map((f) => File(f.path!))
        .toList();

    // No images were selected.
    if (images.isEmpty) {
      return;
    }

    var pickedImages = <PickedImage>[];
    for (var image in images) {
      var exif = await _exifFromFile(image);
      pickedImages.add(PickedImage(
        originalFile: image,
        dateTime: exif.dateTime,
        latLng: exif.latLng,
      ));
    }

    _pop(pickedImages, showError: false);
  }

  Future<void> _finishPickingImageFromGallery(Uint8List data, int index) async {
    setState(() => _isLoadingGalleryImages = true);

    var pickedImage = await _pickedImageFromAsset(
      _assets.elementAt(index),
      thumbData: data,
    );

    if (pickedImage == null) {
      _pop([], showError: true);
    } else {
      _pop([pickedImage], showError: false);
    }
  }

  Future<void> _finishPickingImagesFromGallery() async {
    setState(() => _isLoadingGalleryImages = true);

    var showError = false;

    // Copy the list to prevent concurrent modification exceptions due to user
    // action, such as clearing the selected images or scrolling.
    var result = <PickedImage>[];
    for (var i in List.of(_selectedIndexes)) {
      var pickedImage = await _pickedImageFromAsset(_assets.elementAt(i));
      if (pickedImage == null) {
        showError = true;
      } else {
        result.add(pickedImage);
      }
    }

    _pop(result, showError: showError);
  }

  void _pop(
    List<PickedImage> results, {
    required bool showError,
  }) {
    widget.onImagesPicked(context, results);

    if (widget.popsOnFinish) {
      Navigator.pop(context);
    } else {
      // Ensure that if the user comes back to this page, the loading widget
      // isn't still shown.
      setState(() => _isLoadingGalleryImages = false);
    }

    if (showError) {
      // Show error in a post frame callback so the SnackBar animation is
      // correct. This must be done after the navigation, plus any setState
      // calls from onImagesPicked.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorSnackBar(
          context,
          widget.allowsMultipleSelection
              ? Strings.of(context).imagePickerPageImagesDownloadError
              : Strings.of(context).imagePickerPageImageDownloadError,
        );
      });
    }
  }

  Future<PickedImage?> _pickedImageFromAsset(
    AssetEntity entity, {
    Uint8List? thumbData,
  }) async {
    var lat = entity.latitude;
    var lng = entity.longitude;
    maps.LatLng? latLng;

    if (_coordinatesAreValid(lat, lng)) {
      latLng = maps.LatLng(lat!, lng!);
    } else {
      // Coordinates are invalid, attempt to retrieve from OS.
      var osLatLng = await entity.latlngAsync();
      if (_coordinatesAreValid(osLatLng.latitude, osLatLng.longitude)) {
        latLng = maps.LatLng(osLatLng.latitude!, osLatLng.longitude!);
      }
    }

    // If there is no origin file to copy to Anglers' Log sandbox, there's no
    // point in using it. This should be propagated to the UI to inform the
    // user of an error. This can happen if the full image doesn't exist on the
    // phone. For example, if it is in iCloud.
    var originFile = await entity.originFile;
    if (originFile == null) {
      return null;
    }

    TZDateTime? dateTime = entity.createDateSecond == null
        ? null
        : _timeManager.dateTimeFromSeconds(entity.createDateSecond!);

    // If position and timestamp aren't included, try extracting them from the
    // data.
    if (latLng == null || dateTime == null) {
      var exif = await _exifFromFile(originFile);
      latLng = latLng ?? exif.latLng;
      dateTime = dateTime ?? exif.dateTime;
    }

    return PickedImage(
      originalFile: originFile,
      originalFileId: entity.id,
      thumbData: thumbData ?? await entity.thumbnailData,
      latLng: latLng,
      dateTime: dateTime,
    );
  }

  bool _coordinatesAreValid(double? lat, double? lng) {
    return lat != null && lng != null && lat != 0 && lng != 0;
  }

  /// Returns an estimate of the number of thumbnails that are rendered on the
  /// screen at one time. This is used for creating "placeholder" grids without
  /// rendering too many image placeholders.
  int _approxThumbsOnScreen() {
    var size = MediaQuery.of(context).size;
    return ((size.width / galleryMaxThumbSize).ceil() *
            (size.height / galleryMaxThumbSize).ceil())
        .toInt();
  }

  void _loadNextPage() {
    if (_galleryAsset == null) {
      _log.w("Can't load next page with null _galleryAsset");
      return;
    }

    _assetsFuture = _galleryAsset!.getAssetListPaged(
      page: _currentPage++,
      size: _approxThumbsOnScreen() * 2,
    );
  }

  Future<_Exif> _exifFromFile(File file) {
    return _Exif.fromFile(
        file, ExifWrapper.of(context), TimeManager.of(context));
  }
}

class _Exif {
  static Future<_Exif> fromFile(
    File file,
    ExifWrapper exifWrapper,
    TimeManager timeManager,
  ) async {
    var exif = await exifWrapper.fromPath(file.path);

    // NOTE: Observed apps that do _not_ include EXIF data:
    //   - Google Photos (Android), sometimes. Works on my Pixel 6a.

    var timestamp = await exif.getOriginalDate();
    var latLng = await exif.getLatLong();

    return _Exif._(
      latLng == null ? null : maps.LatLng(latLng.latitude, latLng.longitude),
      timestamp == null ? null : timeManager.toTZDateTime(timestamp),
    );
  }

  final _log = const Log("_Exif");

  late final maps.LatLng? latLng;
  late final TZDateTime? dateTime;

  _Exif._(this.latLng, this.dateTime) {
    _log.d("latLng=$latLng; dateTime:$dateTime");
  }
}
