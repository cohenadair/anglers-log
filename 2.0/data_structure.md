Anglers' Log 2.0 Data Structure
===============================

In JSON, because Firebase Realtime Database uses JSON.

## Common
Common structures that may appear in multiple database trees.
```
Weather {
    temperature : float,
    windSpeed : float,
    windDirection (#25) : string,
    skyConditions : string,
    airPressure (#25) : string,
    description (#25) : string
}

LatLng {
    lat : float,
    lng : float
}
```

## User
Structures that are user-specific.

### Users
A flat structure, where data is managed by the mobile apps.
```
users : {
    <user-id> : {
        licenseUrl (#205) : string
    }, ...
}
```

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
errors : {
    <file-name> : {
        <error-message> : <error-count>
    }
}
```
