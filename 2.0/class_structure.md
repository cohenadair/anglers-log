Anglers' Log 2.0 Class Structure
================================

## Testing
Unit tests aren't necessary for getters, but there will be unit tests in place for converting to and from Firestore documents and collections, as well importing from legacy JSON data strings.

## Fields
Fields represent individual properties of a `LogItem`. There are predefined fields, such as for species, location, and photos, and there are custom fields that can be added by the user.
```Dart
abstract class Field {
    final String jsonKey;       // JSON key sent to Firebase.
    final String displayName;   // Displayed to the user.
    Field(this.jsonKey, this.displayName)
    isEqual(Field field) {}
}

class SingleField {
    final String value;
    SingleField(this.jsonKey, this.displayName, this.value);
    isEqual(Field field) {}
}

class MultiField {
    final List<String> values;
    SingleField(this.jsonKey, this.displayName, this.values);
    isEqual(Field field) {}
}

class PhotoField extends SingleField {
    PhotoField() : super("photoUrl", "Photo", this.value)
}

class PhotosField extends MultiField {
    PhotosField() : super("photoUrls", "Photos", this.values)
}

class CustomField extends SingleField {
    // Note: jsonKey and displayName will need to be the same here to allow for multiple custom fields and handle duplication keys gracefully.
    CustomField(this.displayName) : super(this.displayName, this.displayName, this.value)
}
```

## Bases Log Items
```Dart
abstract class LogItem {
    class DuplicateFieldException implements Exception {}

    class Builder {
        List<Field> fields;

        Builder.withFields(List<Fields> fields) {}
        Builder.withLogItem(LogItem logItem) {}

        // Throws DuplicateFieldException if the field already exists.
        Builder addField(Field field) {}
        
        LogItem build() {}
    }

    final UUID id;
    final List<Field> fields;

    LogItem.withFields(List<Fields> fields) {}
    LogItem.withDefaultFields();

    List<Field> getAllFields();
    List<Field> getAvailableFields();
    
    // Returns a JSON representation of the receiver.
    String toJson() {}
}
```

## Log Items
A complex log items is one that has additional properties to those defined in `LogItem`.

> Note: These definitions do not include properties; only methods and constructors. Properties will be derived from Firestore documents and/or collections.

```Dart
class Species extends LogItem {}
class BaitCategory extends LogItem {}
class WaterClarity extends LogItem {}
class WaterSpeed extends LogItem {}
class FishingMethod extends LogItem {}
class Angler extends LogItem {}

class Trip extends LogItem {
    Trip(this.startDate, this.endDate);
    List<Angler> getAnglers() {}
    List<BodyOfWater> getBodiesOfWater() {}
    List<Catches> getCatches() {}
}

class Catch extends LogItem {
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

class Bait extends LogItem {
    Bait(this.name);
    BaitCategory getBaitCategory() {}
}

class Gear extends LogItem {
    Gear(this.name);
}

class Chum extends LogItem {
    String size;
    Chum(this.name, this.size)
}
```

## Other
Non-entity model objects.
```Dart
// The `Atmosphere` class includes include everything to do with atmosphere - weather, 
// tide, pressure, moon, etc. It is used in multiple log items. All properties are optional.
class Atmosphere {}
```
