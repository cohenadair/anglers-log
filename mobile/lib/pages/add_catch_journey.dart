import 'package:flutter/material.dart';
import 'package:mobile/utils/page_utils.dart';

import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/image_picker_page.dart';
import '../pages/save_catch_page.dart';
import '../pages/species_list_page.dart';
import '../user_preference_manager.dart';
import '../utils/protobuf_utils.dart';
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

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

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
    if (_userPreferenceManager.isTrackingImages) {
      return _buildImagePicker();
    } else {
      return _buildSpeciesPicker(true);
    }
  }

  Widget _buildCloseButton() {
    // Custom close button is required here because a nested
    // Navigator is used and this route is the initial route, which
    // has nowhere to go back to.
    return IconButton(
      icon: const Icon(Icons.close),
      onPressed: _popAll,
    );
  }

  Widget _buildImagePicker() {
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
        if (_userPreferenceManager.isTrackingFishingSpots &&
            !_isFishingSpotPrePicked) {
          for (var image in _images) {
            if (image.latLng == null) {
              continue;
            }

            var existingSpot = FishingSpotManager.of(context)
                .withinPreferenceRadius(image.latLng);

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

        push(context, _buildSpeciesPicker(false));
      },
      appBarLeading: _buildCloseButton(),
    );
  }

  Widget _buildSpeciesPicker(bool isInitialPage) {
    return SpeciesListPage(
      pickerSettings: ManageableListPagePickerSettings<Species>.single(
        onPicked: (context, species) {
          _species = species;

          // If the fishing spot already exists in the database, skip
          // the fishing spot picker page.
          if (FishingSpotManager.of(context)
                  .entityExists(_fishingSpotController.value?.id) ||
              !_userPreferenceManager.isTrackingFishingSpots) {
            push(context, _buildSaveCatchPage());
          } else {
            push(context, _buildFishingSpotPicker());
          }

          return false;
        },
        isRequired: true,
      ),
      appBarLeading: isInitialPage ? _buildCloseButton() : null,
    );
  }

  Widget _buildFishingSpotPicker() {
    return FishingSpotMap(
      pickerSettings: FishingSpotMapPickerSettings(
        controller: _fishingSpotController,
        onNext: () => push(context, _buildSaveCatchPage()),
      ),
    );
  }

  Widget _buildSaveCatchPage() {
    return SaveCatchPage(
      images: _images,
      speciesId: _species!.id,
      fishingSpot: _fishingSpotController.value,
      popOverride: _popAll,
    );
  }

  void _popAll() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
