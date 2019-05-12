Anglers' Log 2.0 Dev Notes
==========================

## Build Size
* iOS: 8 MB
  * This would likely be closer to Android if Instabug was removed.
* Android: 3.68 MB

## Development
* Use the [json_serialization](https://flutter.io/json/#code-generation) package to automatically generate JSON serialization code for model objects.
* Use [Platform Channels](https://flutter.io/platform-channels/) to get legacy JSON user data.
* Possibly use [Sketch](https://www.sketchapp.com/) to disign UI mockups.

## Log Item Database
Consider having a pre-filled database for some log items. We want to minimize data stored in the database (to minimize cost). Certain log items such as "Smallmouth Bass" will be used by multiple users. We should only store one version of this in the database.

Log items that should be considered for database:
  * Species
  * Fishing methods
  * Water clarities
  * Water speeds
  * Bait categories

Their respective screen lists should have two sections, one for "Recently Used" and one for "Other".

### Baits
A baits database would be great, but would require a lot more work either manually gathering all data or somehow scraping the internet for data. This might have to be marked as a "future" feature.

### Public User Data
Consider adding a feature that allows users to make some of their data public. If allowed, their public data can be added to the log item database.

### Considerations
* Multiple languages - may need a collection for each language.

## Trips
* `anglers` can be inferred from selected catches.
* If "skunked", use a stamp-like graphic on top of the views.
* For catches, consider a "dumbed" down version, allowing users to select several species without actually adding a new catch for each one.

## Catches
* When adding a location to a Catch, give the option to select a body of water and fishing spot, use current coordinates, or enter coordinates.
* In the Catch summary screen:
  * Consider showing the location as a map snapshot, rather than just a name and/or coordinates.
  * When showing weather data, consider using a `GridView` with icons, since there will be a lot of information to show.

## Bodies of Water
* Combine Bodies of Water and Map pages.
* Default view will be a map view, but provide an alternative list view.

## Anglers
* Consider using "Me" as a default value.

## Settings
* Add a changelog item. On the first time running a new version, consider showing the changelog, or at least a dialog asking if the user wants to review the changelog.

## Atmospheric Data
* We should get as much atmospheric data as possible automatically.
* Exactly which data is retrived can be determined in Settings. Not everyone will want to know the lunar tables, or air pressure, for example. We don't want to clutter users' logs with unwanted data.
* Tide selection should be something like "Low|High on its way in|out".

## Custom Fields
* We should consider keeping track of when custom fields are created.