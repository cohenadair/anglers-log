package com.cohenadair.anglerslog.model.backup;

import android.util.Log;

import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.BaitCategory;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * The Json class is a wrapper for all JSON Strings used for importing and exporting Logbook data.
 * @author Cohen Adair
 */
public class Json {
    private static final String TAG = "Json";

    public static final String DATE_FORMAT = "MM-dd-yyyy_K-mm_a";

    public static final String JOURNAL = "journal";
    public static final String NAME = "name";
    public static final String USER_DEFINES = "userDefines";
    public static final String ENTRIES = "entries";
    public static final String TRIPS = "trips";
    public static final String MEASUREMENT_SYSTEM = "measurementSystem";

    public static final String DATE = "date";
    public static final String IMAGES = "images";
    public static final String FISH_SPECIES = "fishSpecies";
    public static final String FISH_LENGTH = "fishLength";
    public static final String FISH_WEIGHT = "fishWeight";
    public static final String FISH_OUNCES = "fishOunces";
    public static final String FISH_QUANTITY = "fishQuantity";
    public static final String FISH_RESULT = "fishResult";
    public static final String BAIT_USED = "baitUsed";
    public static final String FISHING_METHOD_NAMES = "fishingMethodNames";
    public static final String LOCATION = "location";
    public static final String FISHING_SPOT = "fishingSpot";
    public static final String WEATHER_DATA = "weatherData";
    public static final String WATER_TEMPERATURE = "waterTemperature";
    public static final String WATER_CLARITY = "waterClarity";
    public static final String WATER_DEPTH = "waterDepth";
    public static final String NOTES = "notes";

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
    public static final String OTHER = "Other";

    public static final String FISHING_SPOTS = "fishingSpots";
    public static final String COORDINATES = "coordinates";
    public static final String LATITUDE = "latitude";
    public static final String LONGITUDE = "longitude";

    public static final String TEMPERATURE = "temperature";
    public static final String WIND_SPEED = "windSpeed";
    public static final String SKY_CONDITIONS = "skyConditions";

    public static String stringOrNull(String jsonString) {
        return (jsonString == null || jsonString.isEmpty()) ? null : jsonString;
    }

    public static Date parseDate(String jsonString) {
        try {
            return new SimpleDateFormat(DATE_FORMAT, Locale.US).parse(jsonString);
        } catch (ParseException e) {
            e.printStackTrace();
        }

        return null;
    }

    public static float ouncesToDecimal(int ounces) {
        if (ounces <= 4)
            return (float)0.25;
        else if (ounces <= 8)
            return (float)0.5;
        else if (ounces <= 12)
            return (float)0.75;
        else
            return 1;
    }

    /**
     * Used for importing from iOS where there may not be a {@link BaitCategory} associated with
     * a {@link com.cohenadair.anglerslog.model.user_defines.Bait} or
     * {@link com.cohenadair.anglerslog.model.user_defines.Catch}.
     *
     * @param jsonObject The JSONObject used to look for the bait category field.
     * @return The associated {@link BaitCategory} or the "other" category if one doesn't exist.
     */
    public static BaitCategory baitCategoryOrOther(JSONObject jsonObject) {
        // importing from iOS will have no associated BaitCategory
        BaitCategory baitCategory = null;
        try {
            String baitCategoryName = jsonObject.getString(Json.BAIT_CATEGORY);
            baitCategory = Logbook.getBaitCategory(baitCategoryName);
        } catch (JSONException e) {
            Log.d(TAG, "No " + Json.BAIT_CATEGORY + " field.");
        }

        // if there is no import category use "Other"
        // create "Other" if it doesn't already exist
        if (baitCategory == null) {
            baitCategory = Logbook.getBaitCategory(Json.OTHER);
            if (baitCategory == null) {
                baitCategory = new BaitCategory(Json.OTHER);
                Logbook.addBaitCategory(baitCategory);
            }
        }

        return baitCategory;
    }
}
