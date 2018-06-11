Anglers' Log 2.0 Data Structure
===============================

The structures below look like JSON, but Anglers' Log 2.0 will use Firebase Cloud Firestore (CF) database instead of Firebase Realtime Database. CF stores data in "documents" and "collections". This structure is always flat and allows for a logical object tree, unlike the Realtime Database where you need to "flatten" data trees in order to lessen the data downloaded by the client.

## Common
Common structures that may appear in multiple documents.
```
Weather {
    temperature : float,
    windSpeed : float,
    windDirection (#25) : string,
    skyConditions : string,
    airPressure (#25) : string,
    description (#25) : string
}
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
            DOC: <trip-id>
            ...
        COL: catches
            DOC: <catch-id>
            ...
        COL: bodiesOfWater
            DOC: <body-of-water-id>
            ...
        COL: species
            DOC: <species-id>
            ...
        COL: baitCategories
            DOC: <bait-category-id>
            ...
        COL: baits
            DOC: <bait-id>
            ...
        COL: waterClarities
            DOC: <water-clarity-id>
            ...
        COL: waterSpeeds
            DOC: <water-speed-id>
            ...
        COL: fishingMethods
            DOC: <fishing-method-id>
            ...
        COL: anglers
            DOC: <angler-id>
            ...
        COL: chums (#249)
            DOC: <chum-id>
            ...
        COL: gear (#93)
            DOC: <gear-id>
            ...
    ...

### Trips
```
trips : {
    <user-id> : {
        <trip-id> {
            name : string,
            startDate : required long,
            endDate : required long,
            anglers : {
                <angler-id> : true, ...
            },
            bodiesOfWater : {
                <body-of-water-id> : true, ...
            },
            catches : {
                <catch-id> : true, ...
            },
            notes : string,
            rating (#209) : int,
            skunked (#23) : boolean,
            weather (#239) : Weather
        }
    }, ...
}
```

### Catches
```
catches : {
    <user-id> : {
        <catch-id> : {
            createdAt : required long,
            caughtAt : long,
            generalizedTimeOfDay (#196) : int,
            photos : {
                <photo-url> : true, ...
            }
            speciesId : required string,
            bodyOfWaterId : string,
            fishingSpotId : string,
            coordinateId : string,
            baits : {
                <bait-id> : true, ...
            },
            isFavourite : boolean,
            result : int,
            fishingMethods : {
                <fishing-method-id> : true, ...
            },
            waterClarityId : string,
            waterDepth : float,
            waterTempterature : float,
            waterLevel (#25) : float,
            waterSpeedId (#251) : string,
            quantity : int,
            length : float,
            weight : float,
            weather : Weather,
            tide (#25) : int,
            moonPhase (#25) : int,
            notes : string,
            anglerId (#213) : string,
            season (#158) : int,
            GearId (#93) : string,
            chumId (#249) : string
        }
    }, ...
}
```

### Bodies of Water
A "body of water" can be a lake, pond, river, stream, etc.; basically, anywhere that can be fished. A "fishing spot" is a specific area within a "body of water" that may include more detail, such as a name, photo, and notes.  A "coordinate", on the other hand, is exact coordinates within a "body of water", and doesn't include any information other than latitude and longitude.

Using exact coordinates in this way is desirable in many contexts. For example, when fishing a river, an angler may walk up and down a river bank several times, catching fish in several different areas. It is much easier to use exact coordinates automatically obtained by the app, rather than creating a new "fishing spot" for each area from which a fish was caught.

A "body of water" can have multiple fishing spots and multiple coordinates.

> Note: Coordinates are managed automatically when catches are managed. Fishing Spots can be managed at any time by the user.
```
bodies-of-water : {
    <user-id> : {
        <body-of-water-id> : {
            name : string
            fishingSpots : {
                <fishing-spot-id> : {
                    name : string,
                    latLng : required LatLng,
                    photos (#199) : {
                        <photo-url> : true, ...
                    },
                    notes (#289) : string
                }
            },
            coordinates : {
                <coordinate-id> : {
                    latLng : required LatLng
                }
            }
        }
    }, ...
}
```

### Species
```
species : {
    <user-id> : {
        <species-id> : {
            name : string
        }
    }, ...
}
```

### Bait Categories
```
bait-categories : {
    <user-id> : {
        <bait-category-id> : {
            name : string
        }
    }, ...
}
```

### Baits
```
baits {
    <user-id> : {
        <bait-id> : {
            name : required string,
            photoUrl : string,
            categoryId : string,
            colour : string,
            modelNumber (#214) : string,
            size : string,
            type : int,
            diveDepth (#214) : float,
            description: string,
        }
    }, ...
}
```

### Water Clarities
```
water-clarities : {
    <user-id> : {
        <water-clarity-id> : {
            name : string
        }
    }, ...
}
```

### Water Speeds
```
water-speeds (#251) : {
    <user-id> : {
        <water-speed-id> : {
            name : string
        }
    }
}
```

### Fishing Methods
```
fishing-methods : {
    <user-id> : {
        <fishing-method-id> : {
            name : string
        }
    }, ...
}
```

### Anglers
```
anglers : {
    <user-id> : {
        <angler-id> : {
            name : string
        }
    }, ...
}
```

### Chums
```
chums : {
    <user-id> : {
        <chum-id> : {
            name : string,
            size : string
        }
    }
}
```

### Gear
```
gear (#93) : {
    <user-id> : {
        <gear-id> : {
            name : string,
            photoUrl : string,
            make : string,
            model : string,
            serialNumber : string,
            length : float,
            action : int,
            reelMake : string,
            reelModel : string,
            reelSize : float,
            line : string,
            lineNumberRating : string,
            lineColour : string
        }
    }
}
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
