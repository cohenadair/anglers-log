Anglers' Log 2.0 Data Structure
===============================

Anglers' Log 2.0 will use Firebase Cloud Firestore (CF) database instead of Firebase Realtime Database. CF stores data in "documents" and "collections". This structure is always flat and allows for a logical object tree, unlike the Realtime Database where you need to "flatten" data trees in order to lessen the data downloaded by the client.

Note that the fields described in this document will be what Anglers' Log provides, and most fields will be optional.  In addition to the fields in this document, users will be able to create "custom" fields to keep track of any data Anglers' Log does not include.

## Terms
* COL: Firestore collection of documents.
* DOC: Firestore document.
* ARR: Firestore array.

## Common
Common structures that may appear in multiple documents.
```
DOC: atmosphere
    temperature : float
    windSpeed : float
    windDirection (#25) : string
    skyConditions : string
    airPressure (#25) : string
    tide (#25) : int
    moonPhase (#25) : int
    season (#158) : int
    description (#25) : string
```

## User
Documents and collections that are user-specific. All this data is managed by the mobile app. Under no circumstances should it be necessary for data to be managed from the Firebase web portal.

The idea here is that CF will store the least amount of data possible. For example, although a `Catch` has many fields, most anglers will only use a few of them. CF should only store values for fields that are set by the angler; every other value should be `null` and therefore non-existent in CF.

```
COL: users
    DOC: <user-id>
        licenseFrontUrl (#205) : string
        licenseBackUrl (#205) : string
        COL: trips
        COL: catches
        COL: bodiesOfWater
        COL: species
        COL: baitCategories
        COL: baits
        COL: waterClarities
        COL: waterSpeeds (#251)
        COL: fishingMethods
        COL: anglers
        COL: chum (#249)
        COL: gear (#93)
    ...
```

### Trips
A fishing "trip" is a length of time for which an angler is actually fishing. It can be spread over a few hours, a few days, or even a few weeks; it is totally customizable.  A fishing trip will include information such as anglers involved, catches made, and bodies of water visited. 

Trips are especially useful for tracking when you get "skunked" (when no fish are caught). Using this information, the angler may want to avoid fishing in the same location or under similar atmospheric conditions.
```
DOC: <trip-id>
    name : string
    startDate : required long
    endDate : required long
    ARR: anglers : [<angler-id>]
    ARR: bodiesOfWater : [<body-of-water-id>]
    ARR: catches : [<catch-id>]
    notes : string
    rating (#209) : int
    skunked (#23) : "true" or null
    atmosphere (#239) : atmosphere
    isFavorite : "true" or null
```

### Catches
A "catch" normally represents a _single_ fish caught; however, there are cases where one "catch" entry could represent multiple fish. A good example of this is catching perch. People often limit out on perch (the limit is usually around 20-50), and they're not going to create a new "catch" entry for every single one.

Similarly, someone might catch a dozen bass in a given day, but not want to create a new entry for each one.
```
DOC: <catch-id>
    caughtAt : long
    generalizedTimeOfDay (#196) : int
    ARR: photos  : [<photo-url>]
    speciesId : string
    bodyOfWaterId : string
    fishingSpotId : string
    coordinatesId (#255) : string
    ARR: baits : [<bait-id>]
    isFavourite : "true" or null
    result : int
    ARR: fishingMethods : [<fishing-method-id>]
    waterClarityId : string
    waterDepth : float
    waterTempterature : float
    waterLevel (#25) : float
    waterSpeedId (#251) : string
    quantity : int
    length : float
    weight : float
    atmosphere : atmosphere
    notes : string,
    anglerId (#213) : string
    gearId (#93) : string
    floatDepth (user requested) : float
    chumId (#249) : string
```

### Bodies of Water
A "body of water" can be a lake, pond, river, stream, etc.; basically, anywhere that can be fished. A "fishing spot" is a specific area within a "body of water" that may include more detail, such as a name, photo, and notes.  A "coordinate", on the other hand, is exact coordinates within a "body of water", and doesn't include any information other than latitude and longitude.

Using exact coordinates in this way is desirable in many contexts. For example, when fishing a river, an angler may walk up and down a river bank several times, catching fish in several different areas. It is much easier to use exact coordinates automatically obtained by the app, rather than creating a new "fishing spot" for each area from which a fish was caught.

A "body of water" can have multiple fishing spots and multiple coordinates.

> Note: Coordinates are managed automatically when catches are managed. Fishing Spots can be managed at any time by the user.
```
DOC: <body-of-water-id>
    name : string
    COL: fishingSpots
        DOC: <fishing-spot-id>
            name : string
            latLng : required Location
            ARR: photos (#199) : [<photo-url>]
            notes (#289) : string
        ...
    COL: coordinates
        DOC: <coordinate-id>
            latLng : required Location
        ...
```

### Species
Simply, a "species" is a type of fish, such as "Pike" or "Rainbow Trout".
```
DOC: <species-id>
    name : string
```

### Bait Categories
A "bait category" is a tool meant to easily organize a user's baits. Categories can be very generic like "Lure" and "Fly", or be specific like "Wooly Bugger", "Rapala", "Stone Fly", etc.

Bait categories are completely controlled by the user, and are "parents" of baits.
```
DOC: <bait-category-id>
    name : string
```

### Baits
Simply, a "bait" is anything an angler uses to catch a fish. Baits can be artificial, real (something dead or non-alive food, such as dough balls), or live.

Users can create bait "variants" - variations of existing baits.  For example, suppose a user uses Wooly Buggers often, but doesn't always use the same colour.  It would be very repetitive/cluttered if the user has 5 different bait entires for each colour.

Each bait has an optional "baseId" property that can be used to determine whether or not the bait is the original bait, or a variant.  Variant baits will not appear in the main baits list, but appear as a list in the bait details view.
```
DOC: <bait-id>
    baseId (#319) : <bait-id>
    name : required string
    photoUrl : string
    categoryId : string
    colour : string
    modelNumber (#214) : string
    size : string
    type : int
    diveDepth (#214) : float
    description: string
```

### Water Clarities
How clear the water is, such as "clear", "muddy", or "chocolate milk".
```
DOC: <water-clarity-id>
    name : string
```

### Water Speeds (#251)
How fast the water is running. This is more applicable to rivers and streams, rather than lakes or oceans.
```
DOC: <water-speed-id>
    name : string
```

### Fishing Methods
A "fishing method" is the technique an angler used to catch a fish. Fishing Methods can be thought of as "tags" attached to a Catch. Examples are "Boat", "Casting", "Ice", and "Shore".
```
DOC: <fishing-method-id>
    name : string
```

### Anglers
The persion who caught a fish. This gives the user's log a personal feel, and allows them to keep track of all fish caught on a trip, regardless if it was them who made the catch.
```
DOC: <angler-id>
    name : string
```

### Chum (#249)
A "chum" is an amount of fish attractant, such as a handful of corn, that an angler throws into the water to attract fish to a certain location.
```
DOC: <chum-id>
    name : string
    size : string
```

### Gear (#93)
```
DOC: <gear-id>
    name : string
    photoUrl : string
    make : string
    model : string
    serialNumber : string
    length : float
    action : int
    reelMake : string
    reelModel : string
    reelSize : float
    line : string
    lineNumberRating : string
    lineColour : string
```

## Development
Data is managed manually as errors are resolved. This data is in addition to Crashlytics.

### Errors
```
COL: errors
    DOC: <dart-file-name>
        <error-message> : <error-count>
    ...
```
