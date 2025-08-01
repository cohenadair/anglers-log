import 'package:flutter/material.dart';
import 'package:mobile/utils/page_utils.dart';

import '../fishing_spot_manager.dart';
import '../model/gen/anglers_log.pb.dart';
import '../pages/image_picker_page.dart';
import '../pages/save_catch_page.dart';
import '../pages/species_list_page.dart';
import '../user_preference_manager.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/fishing_spot_map.dart';
import '../widgets/input_controller.dart';
import 'manageable_list_page.dart';

/// A workflow (journey) for adding a [Catch].
class AddCatchJourney extends StatefulWidget {
  /// An ID of a [FishingSpot] to be used for the catch added.
  final FishingSpot? fishingSpot;

  const AddCatchJourney({this.fishingSpot});

  @override
  AddCatchJourneyState createState() => AddCatchJourneyState();
}

class AddCatchJourneyState extends State<AddCatchJourney> {
  final _fishingSpotController = InputController<FishingSpot>();

  List<PickedImage> _images = [];
  Species? _species;

  bool get _isFishingSpotPrePicked => widget.fishingSpot != null;

  @override
  void initState() {
    super.initState();
    _fishingSpotController.value = widget.fishingSpot;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (context) => UserPreferenceManager.get.isTrackingImages
            ? _buildImagePicker(context)
            : _buildSpeciesPicker(context, true),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext navContext) {
    // Custom close button is required here because a nested
    // Navigator is used and this route is the initial route, which
    // has nowhere to go back to.
    return IconButton(
      icon: const Icon(Icons.close),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildImagePicker(BuildContext navContext) {
    return ImagePickerPage(
      actionText: Strings.of(context).next,
      requiresPick: false,
      popsOnFinish: false,
      backInvokesOnImagesPicked: false,
      onImagesPicked: (context, images) {
        _images = images;

        // If one of the attached images has location data, use it to
        // fetch an existing fishing spot, or to create a new one.
        //
        // Only do this if the user is interested in tracking fishing
        // spots.
        if (UserPreferenceManager.get.isTrackingFishingSpots &&
            !_isFishingSpotPrePicked) {
          for (var image in _images) {
            if (image.latLng == null) {
              continue;
            }

            var existingSpot = FishingSpotManager.of(
              context,
            ).withinPreferenceRadius(image.latLng);

            if (existingSpot == null) {
              _fishingSpotController.value = FishingSpot()
                ..id = randomId()
                ..lat = image.latLng!.latitude
                ..lng = image.latLng!.longitude;
            } else {
              _fishingSpotController.value = existingSpot;
            }

            break;
          }
        }

        push(navContext, _buildSpeciesPicker(navContext, false));
      },
      appBarLeading: _buildCloseButton(navContext),
    );
  }

  Widget _buildSpeciesPicker(BuildContext navContext, bool isInitialPage) {
    return SpeciesListPage(
      pickerSettings: ManageableListPagePickerSettings<Species>.single(
        onPicked: (context, species) {
          _species = species;

          // If the fishing spot already exists in the database, skip
          // the fishing spot picker page.
          var exists = FishingSpotManager.of(
            context,
          ).entityExists(_fishingSpotController.value?.id);

          if (exists || !UserPreferenceManager.get.isTrackingFishingSpots) {
            push(navContext, _buildSaveCatchPage(navContext));
          } else {
            push(navContext, _buildFishingSpotPicker(navContext));
          }

          return false;
        },
        isRequired: true,
      ),
      appBarLeading: isInitialPage ? _buildCloseButton(navContext) : null,
    );
  }

  Widget _buildFishingSpotPicker(BuildContext navContext) {
    return FishingSpotMap(
      pickerSettings: FishingSpotMapPickerSettings(
        controller: _fishingSpotController,
        onNext: () => push(navContext, _buildSaveCatchPage(navContext)),
      ),
    );
  }

  Widget _buildSaveCatchPage(BuildContext navContext) {
    return SaveCatchPage(
      images: _images,
      speciesId: _species!.id,
      fishingSpot: _fishingSpotController.value,
      popOverride: () => _popAll(navContext),
    );
  }

  void _popAll(BuildContext navContext) {
    Navigator.of(context).pop();
  }
}
