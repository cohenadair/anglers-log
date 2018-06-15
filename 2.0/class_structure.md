Anglers' Log 2.0 Class Structure
================================

## Testing
Unit tests aren't necessary for getters, but there will be unit tests in place for converting to and from Firestore documents and collections, as well importing from legacy JSON data strings.

## Bases
```Dart
abstract class LogItem {
    String id;
    String name;

    LogItem(this.id);
}

// `LogItem` subclasses that can have multiple photos.
abstract class PhotosLogItem extends LogItem {
    List<String> photoUrls;
}

// `LogItem` subclasses that can have a single photos.
abstract class PhotoLogItem extends LogItem {
    String photoUrl;
}
```

## Primitive Log Items
A primitive log items is one with no additional properties to those defined in `LogItem`.
```Dart
class Species extends LogItem {}
class BaitCategory extends LogItem {}
class WaterClarity extends LogItem {}
class WaterSpeed extends LogItem {}
class FishingMethod extends LogItem {}
class Angler extends LogItem {}
class Chum extends LogItem {}
```

## Complex Log Items
A complex log items is one that has additional properties to those defined in `LogItem`.

> Note: These definitions do not include properties; only methods and constructors. Properties will be derived from Firestore documents and/or collections.

```Dart
class Trip extends LogItem {
    Trip(this.startDate, this.endDate);
    List<Angler> getAnglers() {}
    List<BodyOfWater> getBodiesOfWater() {}
    List<Catches> getCatches() {}
}

class Catch extends PhotosLogItem {
    Catch(this.createdAt, this.speciesId);
    List<Bait> getBaits() {}
    List<FishingMethod> getFishingMethods() {}
    Species getSpecies() {}
    BodyOfWater getBodyOfWater() {}
    FishingSpot getFishingSpot() {}
    WaterClarity getWaterClarity() {}
    WaterSpeed getWaterSpeed() {}
    Angler getAngler() {}
    Gear getGear() {}
    Chum getChum() {}
}

class BodyOfWater extends LogItem {
    class FishingSpot extends PhotoLogItem {
        FishingSpot(this.latLng);
    }

    BodyOfWater(this.name);
    List<FishingSpot> getFishingSpots() {}
    List<LatLng> getCoordinates() {}

    // Returns a list of all coordinates (both fishing spots and exact coordinates) 
    // associated with the BodyOfWater.
    List<LatLng> getAllLocations() {}
}

class Bait extends PhotoLogItem {
    Bait(this.name);
    BaitCategory getBaitCategory() {}
}

class Gear extends PhotoLogItem {
    Gear(this.name);
}
```

## Other
Non-entity model objects.
```Dart
// The `Atmosphere` class includes include everything to do with atmosphere - weather, 
// tide, pressure, moon, etc. It is used in multiple log items. All properties are optional.
class Atmosphere {}
```
