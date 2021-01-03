import 'package:flutter/material.dart';

import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../location_monitor.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/fishing_spot_picker_page.dart';
import '../pages/image_picker_page.dart';
import '../pages/save_catch_page.dart';
import '../pages/species_list_page.dart';
import '../preferences_manager.dart';
import '../utils/catch_utils.dart';
import '../utils/protobuf_utils.dart';
import 'manageable_list_page.dart';

/// Presents a workflow (journey) for adding a [Catch].
class AddCatchJourney extends StatefulWidget {
  @override
  _AddCatchJourneyState createState() => _AddCatchJourneyState();
}

class _AddCatchJourneyState extends State<AddCatchJourney> {
  final String _rootRoute = "/";
  final String _pickSpeciesRoute = "pick_species";
  final String _pickFishingSpotRoute = "pick_fishing_spot";
  final String _saveCatchRoute = "save_catch";

  final _log = Log("AddCatchJourney");

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  LocationMonitor get _locationMonitor => LocationMonitor.of(context);

  PreferencesManager get _preferencesManager => PreferencesManager.of(context);

  List<PickedImage> _images = [];
  Species _species;
  FishingSpot _fishingSpot;

  @override
  Widget build(BuildContext context) {
    var initialRoute = _rootRoute;
    if (!_isTrackingImages()) {
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
              doneButtonText: Strings.of(context).next,
              requiresPick: false,
              popsOnFinish: false,
              onImagesPicked: (context, images) {
                _images = images;

                // If one of the attached images has location data, use it to
                // fetch an existing fishing spot, or to create a new one.
                //
                // Only do this if the user is interested in tracking fishing
                // spots.
                if (_isTrackingFishingSpots()) {
                  for (var image in _images) {
                    if (image.position == null) {
                      continue;
                    }

                    var existingSpot =
                        _fishingSpotManager.withinRadius(image.position);

                    if (existingSpot == null) {
                      _fishingSpot = FishingSpot()
                        ..id = randomId()
                        ..lat = image.position.latitude
                        ..lng = image.position.longitude;
                      _fishingSpotManager.addOrUpdate(_fishingSpot);
                    } else {
                      _fishingSpot = existingSpot;
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

                  // If a fishing spot already exists, skip the fishing spot
                  // picker page.
                  if (_fishingSpot != null || !_isTrackingFishingSpots()) {
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
            builder: (context) => FishingSpotPickerPage(
              fishingSpotId: _fishingSpotManager
                  .withinRadius(_locationMonitor.currentLocation)
                  ?.id,
              onPicked: (context, fishingSpot) {
                _fishingSpot =
                    _fishingSpotManager.withLatLng(fishingSpot) ?? fishingSpot;
                Navigator.of(context).pushNamed(_saveCatchRoute);
              },
              actionButtonText: Strings.of(context).next,
            ),
          );
        } else if (name == _saveCatchRoute) {
          return MaterialPageRoute(
            builder: (context) => SaveCatchPage(
              images: _images,
              speciesId: _species.id,
              fishingSpotId: _fishingSpot?.id,
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
      icon: Icon(Icons.close),
      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
    );
  }

  bool _isTrackingImages() {
    var catchFieldIds = _preferencesManager.catchFieldIds;
    return catchFieldIds.isEmpty ||
        catchFieldIds.contains(catchFieldIdImages());
  }

  bool _isTrackingFishingSpots() {
    var catchFieldIds = _preferencesManager.catchFieldIds;
    return catchFieldIds.isEmpty ||
        catchFieldIds.contains(catchFieldIdFishingSpot());
  }
}
