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
A flat structure, where data is managed by the mobile apps.
```
user : {
    <user-id> : {
        licenseUrl (#205) : string
    }, ...
}

trip {
    <user-id> : {
        <trip-id> {
            name : string,
            startDate : long,
            endDate : long,
            anglers : {
                <angler-id> : true, ...
            },
            locations : {
                <location-id> : true, ...
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

catch : {
    <user-id> : {
        <catch-id> : {
            date : long,
            generalizedTimeOfDay (#196) : int,
            photos : {
                <photo-url> : true, ...
            }
            speciesId : string,
            locationId : string,
            latLng : LatLng,
            baits : {
                <bait-id> : true, ...
            },
            fishingSpotId : string,
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
            rodId (#93) : string,
            chum (#249) : {
                name : string,
                size : string
            }
        }
    }, ...
}

location : {
    <user-id> : {
        <location-id> : {
            name : string
        }
    }, ...
}

fishing-spot : {
    <user-id> : {
        <fishing-spot-id> : {
            name : string,
            locationId : string,
            latLng : LatLng,
            photos (#199) : {
                <photo-url> : true, ...
            },
            notes (#289) : string
        }
    }, ...
}

species : {
    <user-id> : {
        <species-id> : {
            name : string
        }
    }, ...
}

bait-category : {
    <user-id> : {
        <bait-category-id> : {
            name : string
        }
    }, ...
}

bait {
    <user-id> : {
        <bait-id> : {
            name : string,
            photos : {
                <photo-url> : true, ...
            }
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

water-clarity : {
    <user-id> : {
        <water-clarity-id> : {
            name : string
        }
    }, ...
}

water-speed (#251) : {
    <user-id> : {
        <water-speed-id> : {
            name : string
        }
    }
}

fishing-method : {
    <user-id> : {
        <fishing-method-id> : {
            name : string
        }
    }, ...
}

angler : {
    <user-id> : {
        <angler-id> : {
            name : string
        }
    }, ...
}

rod (#93) : {
    <user-id> : {
        <gear-id> : {
            name : string,
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
```
error : {
    <file-name> : {
        <error-message> : <error-count>
    }
}
```
