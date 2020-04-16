import 'package:flutter/material.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/pages/fishing_spot_picker_page.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/pages/save_catch_page.dart';
import 'package:mobile/pages/species_picker_page.dart';

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

  /// If an image is picked with a location within [_existingFishingSpotMeters]
  /// of an existing [FishingSpot], the existing [FishingSpot] will be used.
  final int _existingFishingSpotMeters = 30;

  final _log = Log("AddCatchJourney");

  CatchJourneyHelper _journeyHelper = CatchJourneyHelper();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (routeSettings) {
        var name = routeSettings.name;
        if (name == _rootRoute) {
          return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => ImagePickerPage(
              doneButtonText: Strings.of(context).next,
              requiresPick: false,
              popsOnFinish: false,
              onImagesPicked: (context, images) async {
                _journeyHelper.images = images;

                // If one of the attached images has location data, use it to
                // fetch an existing fishing spot, or to create a new one.
                for (var image in _journeyHelper.images) {
                  if (image.position == null) {
                    continue;
                  }

                  FishingSpot existingSpot = await
                      FishingSpotManager.of(context).withinRadius(
                        latLng: image.position,
                        meters: _existingFishingSpotMeters,
                      );

                  if (existingSpot == null) {
                    _journeyHelper.fishingSpot = FishingSpot(
                      lat: image.position.latitude,
                      lng: image.position.longitude,
                    );
                  } else {
                    _journeyHelper.fishingSpot = existingSpot;
                  }

                  break;
                }

                Navigator.of(context).pushNamed(_pickSpeciesRoute);
              },
              // Custom close button is required here because a nested
              // Navigator is used and this route is the initial route, which
              // has nowhere to go back to.
              appBarLeading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
              ),
            ),
          );
        } else if (name == _pickSpeciesRoute) {
          return MaterialPageRoute(
            builder: (context) => SpeciesPickerPage(
              onPicked: (context, species) {
                _journeyHelper.species = species;

                // If a fishing spot already exists, skip the fishing spot
                // picker page.
                if (_journeyHelper.fishingSpot == null) {
                  Navigator.of(context).pushNamed(_pickFishingSpotRoute);
                } else {
                  Navigator.of(context).pushNamed(_saveCatchRoute);
                }
              },
            ),
          );
        } else if (name == _pickFishingSpotRoute) {
          return MaterialPageRoute(
            builder: (context) => FishingSpotPickerPage(
              onPicked: (context, fishingSpot) async {
                FishingSpot existingSpot = await FishingSpotManager.of(context)
                    .withLatLng(fishingSpot.latLng);
                _journeyHelper.fishingSpot = existingSpot ?? fishingSpot;
                Navigator.of(context).pushNamed(_saveCatchRoute);
              },
              doneButtonText: Strings.of(context).next,
            ),
          );
        } else if (name == _saveCatchRoute) {
          return MaterialPageRoute(
            builder: (context) => SaveCatchPage.fromJourney(
              popOverride: () =>
                  Navigator.of(context, rootNavigator: true).pop(),
              journeyHelper: _journeyHelper,
            ),
          );
        } else {
          _log.w("Unexpected route $name");
        }

        return null;
      },
    );
  }
}