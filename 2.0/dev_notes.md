Anglers' Log 2.0 Dev Notes
==========================

## Development
* Use the [json_serialization](https://flutter.io/json/#code-generation) package to automatically generate JSON serialization code for model objects.
* Use [Platform Channels](https://flutter.io/platform-channels/) to get legacy JSON user data.
* Possibly use [Sketch](https://www.sketchapp.com/) to disign UI mockups.

## Trips
* `anglers` can be inferred from selected catches.

## Catches
* When adding a location to a Catch, give the option to select a body of water and fishing spot, use current coordinates, or enter coordinates.
* In the Catch summary screen:
  * Consider showing the location as a map snapshot, rather than just a name and/or coordinates.
  * When showing weather data, consider using a `GridView` since there will be a lot of information to show.

## Bodies of Water
* Combine Bodies of Water and Map pages.
* Default view will be a map view, but provide an alternative list view.