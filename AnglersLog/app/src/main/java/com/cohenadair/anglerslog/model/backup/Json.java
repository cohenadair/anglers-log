package com.cohenadair.anglerslog.model.backup;

/**
 * The Json class is a wrapper for all JSON Strings used for importing and exporting.
 * Created by Cohen Adair on 2016-02-07.
 */
public class Json {

    public static final String JOURNAL = "journal";
    public static final String NAME = "name";
    public static final String USER_DEFINES = "userDefines";
    public static final String MEASUREMENT_SYSTEM = "measurementSystem";

    public static final String NAME_FISHING_METHODS = "Fishing Methods";
    public static final String NAME_LOCATIONS = "Locations";
    public static final String NAME_SPECIES = "Species";
    public static final String NAME_BAITS = "Baits";
    public static final String NAME_WATER_CLARITIES = "Water Clarities";
    public static final String NAME_BAIT_CATEGORIES = "Bait Categories";
    public static final String NAME_ANGLERS = "Anglers";

    public static final String FISHING_METHODS = "fishingMethods";
    public static final String LOCATIONS = "locations";
    public static final String SPECIES = "species";
    public static final String BAITS = "baits";
    public static final String WATER_CLARITIES = "waterClarities";
    public static final String BAIT_CATEGORIES = "baitCategories";
    public static final String ANGLERS = "anglers";

    public static final String BAIT_DESCRIPTION = "baitDescription";
    public static final String BAIT_TYPE = "baitType";
    public static final String BAIT_CATEGORY = "baitCategory";
    public static final String SIZE = "size";
    public static final String COLOR = "color";
    public static final String IMAGE = "image";
    public static final String IMAGE_PATH = "imagePath";

    public static final String FISHING_SPOTS = "fishingSpots";
    public static final String COORDINATES = "coordinates";
    public static final String LATITUDE = "latitude";
    public static final String LONGITUDE = "longitude";

    public static String stringOrNull(String jsonString) {
        return (jsonString == null || jsonString.isEmpty()) ? null : jsonString;
    }
}
