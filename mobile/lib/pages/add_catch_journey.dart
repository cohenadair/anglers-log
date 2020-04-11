import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/species.dart';
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

  final _log = Log("AddCatchJourney");

  List<PickedImage> _images = [];
  Species _species;
  FishingSpot _fishingSpot;

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
              onImagesPicked: (context, images) {
                _images = images;
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
                _species = species;
                Navigator.of(context).pushNamed(_pickFishingSpotRoute);
              },
            ),
          );
        } else if (name == _pickFishingSpotRoute) {
          return MaterialPageRoute(
            builder: (context) => FishingSpotPickerPage(
              onPicked: (context, fishingSpot) {
                _fishingSpot = fishingSpot;
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
              journeyHelper: CatchPageJourneyHelper(
                images: _images,
                species: _species,
                fishingSpot: _fishingSpot,
              ),
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