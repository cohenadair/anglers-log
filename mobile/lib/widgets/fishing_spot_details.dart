import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/our_bottom_sheet.dart';
import 'package:quiver/strings.dart';

import '../body_of_water_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/add_catch_journey.dart';
import '../pages/save_fishing_spot_page.dart';
import '../utils/dialog_utils.dart';
import '../utils/page_utils.dart';
import '../utils/snackbar_utils.dart';
import '../utils/string_utils.dart';
import '../wrappers/io_wrapper.dart';
import '../wrappers/url_launcher_wrapper.dart';
import 'bottom_sheet_picker.dart';
import 'button.dart';
import 'chip_list.dart';
import 'floating_container.dart';
import 'list_item.dart';
import 'widget.dart';

/// A widget that shows [FishingSpot] details in either a floating container
/// (to be used on a map), or a list item.
class FishingSpotDetails extends StatelessWidget {
  final FishingSpot fishingSpot;

  /// When true, a "New Fishing Spot" text is shown as the title.
  final bool isNewFishingSpot;

  /// When true, displays [fishingSpot] details in a list item. When true,
  /// [showActionButtons] is ignored and action buttons are never shown. Also
  /// when true, the [fishingSpot.note] field is not shown.
  final bool isListItem;

  /// See [_FishingSpotActions.isPicking].
  final bool isPicking;

  /// When [isListItem] is false, this property is ignored.
  final VoidCallback? onTap;

  /// When true, the action buttons at the bottom are hidden. Defaults to false.
  final bool showActionButtons;

  /// When true, a [RightChevronIcon] is rendered on the right of the widget,
  /// regardless of the value of [onTap]. This value only applies when
  /// [isListItem] is true.
  final bool showRightChevron;

  /// The [Key] for the details [Container]. This value is ignored when
  /// [isListItem] is true.
  final Key? containerKey;

  const FishingSpotDetails(
    this.fishingSpot, {
    this.containerKey,
    this.isNewFishingSpot = false,
    this.isListItem = false,
    this.isPicking = false,
    this.showActionButtons = false,
    this.showRightChevron = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Always fetch latest fishing spot, if it exists; fallback on what was
    // passed in.
    var spot =
        FishingSpotManager.of(context).entity(fishingSpot.id) ?? fishingSpot;
    var bodyOfWater =
        BodyOfWaterManager.of(context).entity(spot.bodyOfWaterId)?.name;

    String? title;
    String? subtitle;
    if (isNotEmpty(spot.name)) {
      title = spot.name;
      subtitle = bodyOfWater;
    } else if (isNotEmpty(bodyOfWater)) {
      title = bodyOfWater;
    } else if (isNewFishingSpot) {
      title = Strings.of(context).mapPageDroppedPin;
    }

    var latLng = formatLatLng(
      context: context,
      lat: spot.lat,
      lng: spot.lng,
    );

    String? subtitle2 = latLng;
    if (isEmpty(title)) {
      title = latLng;
      subtitle2 = null;
    }

    var listItem = ImageListItem(
      title: title,
      subtitle: subtitle,
      subtitle2: subtitle2,
      subtitle3: isListItem ? null : fishingSpot.notes,
      imageName: fishingSpot.imageName,
      showPlaceholder: false,
      showFullImageOnTap: true,
      onTap: isListItem ? onTap : null,
      trailing: isListItem && (onTap != null || showRightChevron)
          ? RightChevronIcon()
          : null,
    );

    if (isListItem) {
      return listItem;
    }

    Widget actionButtons = const Empty();
    if (showActionButtons) {
      actionButtons = _FishingSpotActions(
        fishingSpot,
        isPicking: isPicking,
      );
    }

    return FloatingContainer(
      key: containerKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          listItem,
          actionButtons,
        ],
      ),
    );
  }
}

/// A widget that shows a [Row] of [ChipButtons] related to the given
/// [FishingSpot].
class _FishingSpotActions extends StatelessWidget {
  static const _log = Log("_FishingSpotActions");

  /// Note that an [Id] is not used here because the [FishingSpot] being shown
  /// hasn't necessarily been added to [FishingSpotManager] yet.
  final FishingSpot fishingSpot;

  /// When true, the following action buttons are hidden:
  ///   - Directions
  ///   - Add Catch
  ///   - Save
  final bool isPicking;

  const _FishingSpotActions(
    this.fishingSpot, {
    this.isPicking = false,
  });

  @override
  Widget build(BuildContext context) {
    var children = [
      _buildAddCatch(context),
      _buildSave(context),
      _buildSaveDetails(context),
      _buildDelete(context),
      _buildDirections(context),
    ];
    children.removeWhere((e) => e is Empty);

    if (children.isEmpty) {
      return const Empty();
    }

    return ChipList(
      children: children,
      containerPadding: insetsBottomDefault,
      listPadding: insetsHorizontalDefault,
    );
  }

  Widget _buildSave(BuildContext context) {
    if (_fishingSpotExists(context) || isPicking) {
      return const Empty();
    }

    return ChipButton(
      label: Strings.of(context).save,
      icon: Icons.save,
      onPressed: () => FishingSpotManager.of(context).addOrUpdate(fishingSpot),
    );
  }

  Widget _buildSaveDetails(BuildContext context) {
    var isEditing = _fishingSpotExists(context);
    return ChipButton(
      label: isEditing
          ? Strings.of(context).edit
          : Strings.of(context).fishingSpotDetailsAddDetails,
      icon: isEditing ? Icons.edit : Icons.add,
      onPressed: () => present(context, SaveFishingSpotPage.edit(fishingSpot)),
    );
  }

  Widget _buildAddCatch(BuildContext context) {
    if (!_fishingSpotExists(context) || isPicking) {
      return const Empty();
    }

    return ChipButton(
      label: Strings.of(context).mapPageAddCatch,
      icon: Icons.add,
      onPressed: () =>
          AddCatchJourney.presentIn(context, fishingSpot: fishingSpot),
    );
  }

  Widget _buildDelete(BuildContext context) {
    if (!_fishingSpotExists(context)) {
      return const Empty();
    }

    var fishingSpotManager = FishingSpotManager.of(context);
    return ChipButton(
      label: Strings.of(context).delete,
      icon: Icons.delete,
      onPressed: () {
        showDeleteDialog(
          context: context,
          description:
              Text(fishingSpotManager.deleteMessage(context, fishingSpot)),
          onDelete: () => fishingSpotManager.delete(fishingSpot.id),
        );
      },
    );
  }

  Widget _buildDirections(BuildContext context) {
    if (isPicking) {
      return const Empty();
    }

    return ChipButton(
      label: Strings.of(context).directions,
      icon: Icons.directions,
      onPressed: () => _launchDirections(context),
    );
  }

  bool _fishingSpotExists(BuildContext context) =>
      FishingSpotManager.of(context).entityExists(fishingSpot.id);

  Future<void> _launchDirections(BuildContext context) async {
    var navigationAppOptions = <String, String>{};
    var urlLauncher = UrlLauncherWrapper.of(context);
    var io = IoWrapper.of(context);
    var destination = "${fishingSpot.lat}%2C${fishingSpot.lng}";

    // Openable on Android as standard URL. Do not include as an option on
    // Android devices.
    var appleMapsUrl = "https://maps.apple.com/?daddr=$destination";
    if (io.isIOS && await urlLauncher.canLaunch(appleMapsUrl)) {
      navigationAppOptions[Strings.of(context).mapPageAppleMaps] = appleMapsUrl;
    }

    var googleMapsUrl = Platform.isAndroid
        ? "google.navigation:q=$destination"
        : "comgooglemaps://?daddr=$destination";
    if (await urlLauncher.canLaunch(googleMapsUrl)) {
      navigationAppOptions[Strings.of(context).mapPageGoogleMaps] =
          googleMapsUrl;
    }

    var wazeUrl = "waze://?ll=$destination&navigate=yes";
    if (await urlLauncher.canLaunch(wazeUrl)) {
      navigationAppOptions[Strings.of(context).mapPageWaze] = wazeUrl;
    }

    _log.d("Available navigation apps: ${navigationAppOptions.keys}");
    var launched = false;

    if (navigationAppOptions.isEmpty) {
      // Default to Google Maps in a browser.
      var defaultUrl = "https://www.google.com/maps/dir/?api=1&"
          "dir_action=preview&"
          "destination=$destination";
      if (await urlLauncher.canLaunch(defaultUrl) &&
          await urlLauncher.launch(defaultUrl)) {
        launched = true;
      }
    } else if (navigationAppOptions.length == 1) {
      // There's only one option, open it.
      var url = navigationAppOptions.values.first;
      if (await urlLauncher.canLaunch(url) && await urlLauncher.launch(url)) {
        launched = true;
      }
    } else {
      // There are multiple options, give the user a choice.
      String? url;
      await showOurBottomSheet(
        context,
        (context) => BottomSheetPicker<String>(
          onPicked: (pickedUrl) => url = pickedUrl,
          items: navigationAppOptions,
        ),
      ).then((_) async {
        // If empty, bottom sheet was dismissed.
        launched = isEmpty(url) || await urlLauncher.launch(url!);
      });
    }

    if (!launched) {
      showErrorSnackBar(
          context, Strings.of(context).mapPageErrorOpeningDirections);
    }
  }
}
