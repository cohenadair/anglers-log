package com.cohenadair.mobile.legacy.database;

/**
 * The SQLite database schema for a Logbook.
 * @author Cohen Adair
 */
public class LogbookSchema {
    /**
     * An actual table isn't create here; this is used to get ContentValues from objects; however,
     * a column in each <UserDefine>Table will be created for these columns.
     */
    public static class UserDefineTable {
        public static class Columns {
            public static final String ID = "id";
            public static final String NAME = "name";
            public static final String SELECTED = "selected";
        }
    }

    public static final class CatchTable extends UserDefineTable {
        public static final String NAME = "Catch";

        public static final class Columns extends UserDefineTable.Columns {
            public static final String DATE = "date";
            public static final String SPECIES_ID = "speciesId";
            public static final String IS_FAVORITE = "isFavorite";
            public static final String BAIT_ID = "baitId";
            public static final String FISHING_SPOT_ID = "fishingSpotId";
            public static final String CATCH_RESULT = "catchResult";
            public static final String CLARITY_ID = "waterClarityId";
            public static final String WATER_DEPTH = "waterDepth";
            public static final String WATER_TEMPERATURE = "waterTemperature";
            public static final String QUANTITY = "quantity";
            public static final String LENGTH = "length";
            public static final String WEIGHT = "weight";
            public static final String NOTES = "notes";
        }
    }

    public static final class SpeciesTable extends UserDefineTable {
        public static final String NAME = "Species";
    }

    public static final class BaitCategoryTable extends UserDefineTable {
        public static final String NAME = "BaitCategory";
    }

    public static final class BaitTable extends UserDefineTable {
        public static final String NAME = "Bait";

        public static final class Columns extends UserDefineTable.Columns {
            public static final String CATEGORY_ID = "categoryId";
            public static final String COLOR = "color";
            public static final String SIZE = "size";
            public static final String DESCRIPTION = "description";
            public static final String TYPE = "type";
        }
    }

    public static final class LocationTable extends UserDefineTable {
        public static final String NAME = "Location";
    }

    public static final class FishingSpotTable extends UserDefineTable {
        public static final String NAME = "FishingSpot";

        public static final class Columns extends UserDefineTable.Columns {
            public static final String LOCATION_ID = "locationId";
            public static final String LATITUDE = "latitude";
            public static final String LONGITUDE = "longitude";
        }
    }

    public static final class WaterClarityTable extends UserDefineTable {
        public static final String NAME = "WaterClarity";
    }

    public static final class FishingMethodTable extends UserDefineTable {
        public static final String NAME = "FishingMethod";
    }

    public static final class AnglerTable extends UserDefineTable {
        public static final String NAME = "Angler";
    }

    public static final class TripTable extends UserDefineTable {
        public static final String NAME = "Trip";

        public static final class Columns extends UserDefineTable.Columns {
            public static final String START_DATE = "startDate";
            public static final String END_DATE = "endDate";
            public static final String NOTES = "notes";
        }
    }

    /**
     * An actual table isn't created here; used as a superclass to specific photo tables.
     */
    public static class PhotoTable {
        public static class Columns {
            public static final String USER_DEFINE_ID = "objectId";
            public static final String NAME = "name";
        }
    }

    public static final class CatchPhotoTable extends PhotoTable {
        public static final String NAME = "CatchPhoto";
    }

    public static final class BaitPhotoTable extends PhotoTable {
        public static final String NAME = "BaitPhoto";
    }

    /**
     * Stores Catch to FishingMethod pairs. There can be multiple fishing methods per catch.
     */
    public static final class UsedFishingMethodTable {
        public static final String NAME = "UsedFishingMethod";

        public static final class Columns {
            public static final String CATCH_ID = "catchId";
            public static final String FISHING_METHOD_ID = "fishingMethodId";
        }
    }

    public static final class WeatherTable {
        public static final String NAME = "WeatherTable";

        public static final class Columns {
            public static final String CATCH_ID = "catchId";
            public static final String TEMPERATURE = "temperature";
            public static final String WIND_SPEED = "windSpeed";
            public static final String SKY_CONDITIONS = "skyConditions";
        }
    }

    /**
     * Stores Trip to Angler pairs. There can be multiple anglers per trip.
     */
    public static final class UsedAnglerTable {
        public static final String NAME = "UsedAngler";

        public static final class Columns {
            public static final String TRIP_ID = "tripId";
            public static final String ANGLER_ID = "anglerId";
        }
    }

    /**
     * Stores Trip to Location pairs. There can be multiple locations per trip.
     */
    public static final class UsedLocationTable {
        public static final String NAME = "UsedLocation";

        public static final class Columns {
            public static final String TRIP_ID = "tripId";
            public static final String LOCATION_ID = "locationId";
        }
    }

    /**
     * Stores Trip to Catch pairs. There can be multiple catches per trip.
     */
    public static final class UsedCatchTable {
        public static final String NAME = "UsedCatch";

        public static final class Columns {
            public static final String TRIP_ID = "tripId";
            public static final String CATCH_ID = "catchId";
        }
    }
}
