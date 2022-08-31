import 'package:flutter/material.dart';
import 'package:mobile/subscription_manager.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/utils/page_utils.dart';

import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/image_picker_page.dart';
import '../pages/save_catch_page.dart';
import '../pages/species_list_page.dart';
import '../user_preference_manager.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/fishing_spot_map.dart';
import '../widgets/input_controller.dart';
import 'manageable_list_page.dart';
import 'pro_page.dart';

/// A workflow (journey) for adding a [Catch].
class AddCatchJourney extends StatefulWidget {
  /// The only entry point for adding a catch. When finished, the user may be
  /// shown a rate dialog or the pro page, depending on the current app state.
  static void presentIn(
    BuildContext context, {
    FishingSpot? fishingSpot,
  }) {
    present(context, AddCatchJourney._(fishingSpot: fishingSpot), onFinish: () {
      if (showRateDialogIfNeeded(context)) {
        // If the dialog is shown, don't show any other popups.
        return;
      }

      var subscriptionManager = SubscriptionManager.of(context);
      var userPreferenceManager = UserPreferenceManager.of(context);
      var timeManager = TimeManager.of(context);

      // Check if ProPage should be shown.
      if (subscriptionManager.isFree &&
          isFrequencyTimerReady(
            timeManager: timeManager,
            timerStartedAt: userPreferenceManager.proTimerStartedAt,
            setTimer: userPreferenceManager.setProTimerStartedAt,
            frequency: Duration.millisecondsPerDay * 7,
          )) {
        userPreferenceManager
            .setProTimerStartedAt(timeManager.currentTimestamp);
        present(context, const ProPage());
        return;
      }
    });
  }

  /// An ID of a [FishingSpot] to be used for the catch added.
  final FishingSpot? fishingSpot;

  const AddCatchJourney._({this.fishingSpot});

  @override
  AddCatchJourneyState createState() => AddCatchJourneyState();
}

class AddCatchJourneyState extends State<AddCatchJourney> {
  final String _rootRoute = "/";
  final String _pickSpeciesRoute = "pick_species";
  final String _pickFishingSpotRoute = "pick_fishing_spot";
  final String _saveCatchRoute = "save_catch";

  final _log = const Log("AddCatchJourney");
  final _fishingSpotController = InputController<FishingSpot>();

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

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
    var initialRoute = _rootRoute;
    if (!_userPreferenceManager.isTrackingImages) {
      initialRoute = _pickSpeciesRoute;
    }

    return Navigator(
      initialRoute: initialRoute,
      onGenerateRoute: (routeSettings) {
        var name = routeSettings.name;
        if (name == _rootRoute) {
          return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => ImagePickerPage(
              actionText: Strings.of(context).next,
              requiresPick: false,
              popsOnFinish: false,
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
                    if (image.position == null) {
                      continue;
                    }

                    var existingSpot = _fishingSpotManager
                        .withinPreferenceRadius(image.position);

                    if (existingSpot == null) {
                      _fishingSpotController.value = FishingSpot()
                        ..id = randomId()
                        ..lat = image.position!.latitude
                        ..lng = image.position!.longitude;
                    } else {
                      _fishingSpotController.value = existingSpot;
                    }

                    break;
                  }
                }

                Navigator.of(context).pushNamed(_pickSpeciesRoute);
              },
              appBarLeading: _buildCloseButton(),
            ),
          );
        } else if (name == _pickSpeciesRoute) {
          return MaterialPageRoute(
            builder: (context) => SpeciesListPage(
              pickerSettings: ManageableListPagePickerSettings<Species>.single(
                onPicked: (context, species) {
                  _species = species;

                  // If the fishing spot already exists in the database, skip
                  // the fishing spot picker page.
                  if (_fishingSpotManager
                          .entityExists(_fishingSpotController.value?.id) ||
                      !_userPreferenceManager.isTrackingFishingSpots) {
                    Navigator.of(context).pushNamed(_saveCatchRoute);
                  } else {
                    Navigator.of(context).pushNamed(_pickFishingSpotRoute);
                  }

                  return false;
                },
                isRequired: true,
              ),
              appBarLeading: initialRoute == _pickSpeciesRoute
                  ? _buildCloseButton()
                  : null,
            ),
          );
        } else if (name == _pickFishingSpotRoute) {
          return MaterialPageRoute(
            builder: (context) => FishingSpotMap(
              pickerSettings: FishingSpotMapPickerSettings(
                controller: _fishingSpotController,
                onNext: () => Navigator.of(context).pushNamed(_saveCatchRoute),
              ),
            ),
          );
        } else if (name == _saveCatchRoute) {
          return MaterialPageRoute(
            builder: (context) => SaveCatchPage(
              images: _images,
              speciesId: _species!.id,
              fishingSpot: _fishingSpotController.value,
              popOverride: () =>
                  Navigator.of(context, rootNavigator: true).pop(),
            ),
          );
        } else {
          _log.w("Unexpected route $name");
        }

        return null;
      },
    );
  }

  Widget _buildCloseButton() {
    // Custom close button is required here because a nested
    // Navigator is used and this route is the initial route, which
    // has nowhere to go back to.
    return IconButton(
      icon: const Icon(Icons.close),
      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
    );
  }
}
