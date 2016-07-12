package com.cohenadair.anglerslog.model.backup;

import android.util.Log;

import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Angler;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.BaitCategory;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.FishingMethod;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.model.user_defines.WaterClarity;
import com.cohenadair.anglerslog.utilities.LogbookPreferences;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

/**
 * The JsonImporter class is used to parse a given {@link JSONObject} and convert its properties
 * into Logbook model objects, and save them to the database.
 *
 * JsonImporter should be used in conjunction with {@link Importer}.
 *
 * @author Cohen Adair
 */
public class JsonImporter {

    private static final String TAG = "JsonImporter";

    /**
     * An interface used for adding different {@link UserDefineObject} subclasses to the current
     * {@link Logbook}.
     */
    private interface OnAddObject {
        void onAddObject(JSONObject obj) throws JSONException;
    }

    /**
     * An interface used for getting different {@link UserDefineObject} subclass instances from
     * the current {@link Logbook}.
     */
    public interface OnGetObject {
        UserDefineObject onGetObject(String name);
    }

    /**
     * Parses the given {@link JSONObject}, constructing and adding objects to the current
     * {@link Logbook} along the way.
     *
     * @param json The {@link JSONObject} to import.
     * @throws JSONException Throws JSONException if the input JSON couldn't be parsed.
     */
    public static void parse(JSONObject json) throws JSONException {
        JSONObject journalJson = json.getJSONObject(Json.JOURNAL);

        parseUserDefines(journalJson.getJSONArray(Json.USER_DEFINES));
        parseCatches(journalJson.getJSONArray(Json.ENTRIES));

        // there is no trips field when importing from iOS
        try {
            parseTrips(journalJson.getJSONArray(Json.TRIPS));
        } catch (JSONException e) {
            Log.e(TAG, "No value for " + Json.TRIPS);
        }

        LogbookPreferences.setUnits(journalJson.getInt(Json.MEASUREMENT_SYSTEM));
    }

    /**
     * Parses an input {@link JSONArray} of {@link Trip} objects.
     */
    private static void parseTrips(JSONArray tripsJson) throws JSONException {
        Log.d(TAG, "Importing trips...");

        parseUserDefineJson(tripsJson, new UserDefineJson(Json.NAME_TRIPS, new OnAddObject() {
            @Override
            public void onAddObject(JSONObject obj) throws JSONException {
                Logbook.addTrip(new Trip(obj));
            }
        }));
    }

    /**
     * Parses an input {@link JSONArray} of {@link Catch} objects.
     */
    private static void parseCatches(JSONArray catchesJson) {
        Log.d(TAG, "Importing catches...");

        parseUserDefineJson(catchesJson, new UserDefineJson(Json.NAME_CATCHES, new OnAddObject() {
            @Override
            public void onAddObject(JSONObject obj) throws JSONException {
                Logbook.addCatch(new Catch(obj));
            }
        }));
    }

    /**
     * Parses an input {@link JSONArray} of {@link UserDefineObject} subclass representations.
     * @see JsonExporter#getUserDefineJsonObject(String, String, ArrayList)
     */
    private static void parseUserDefines(JSONArray userDefinesJson) throws JSONException {
        for (int i = 0; i < userDefinesJson.length(); i++) {
            JSONObject obj = userDefinesJson.getJSONObject(i);
            HashMap<String, UserDefineJson> userDefineJsonMap = getUserDefineJsonMap();

            for (Map.Entry<String, UserDefineJson> entry : userDefineJsonMap.entrySet()) {
                UserDefineJson userDefineJson = entry.getValue();

                try {
                    JSONArray arr = obj.getJSONArray(userDefineJson.getName());
                    if (arr.length() <= 0)
                        continue;

                    Log.d(TAG, "Importing " + userDefineJson.getName() + "...");

                    for (int j = 0; j < arr.length(); j++)
                        userDefineJson.getCallbacks().onAddObject(arr.getJSONObject(j));

                } catch (JSONException e) {
                    Log.e(TAG, "No value for " + userDefineJson.getName());
                }
            }
        }
    }

    /**
     * Parses an input {@link JSONArray} of {@link UserDefineObject} objects based on the given
     * {@link com.cohenadair.anglerslog.model.backup.JsonImporter.UserDefineJson} specification.
     *
     * @see #getUserDefineJsonMap()
     */
    private static void parseUserDefineJson(JSONArray jsonArray, UserDefineJson userDefineJson) {
        for (int i = 0; i < jsonArray.length(); i++)
            try {
                userDefineJson.getCallbacks().onAddObject(jsonArray.getJSONObject(i));
            } catch (JSONException e) {
                e.printStackTrace();
            }
    }

    /**
     * Gets an array of {@link UserDefineObject} based on the given JSONArray and callbacks.
     * @see Trip constructor.
     *
     * @param jsonArray The JSONArray to parse.
     * @param callbacks The callbacks for getting objects from the {@link Logbook}.
     * @return An ArrayList of {@link UserDefineObject}.
     * @throws JSONException Throws JSONException if there is ah error reading elements of the
     *                       array.
     */
    public static ArrayList<UserDefineObject> parseUserDefineArray(JSONArray jsonArray, OnGetObject callbacks) throws JSONException {
        ArrayList<UserDefineObject> objects = new ArrayList<>();

        for (int i = 0; i < jsonArray.length(); i++)
            objects.add(callbacks.onGetObject(jsonArray.getString(i)));

        return objects;
    }

    /**
     * Gets a {@link Date} object from a given String.
     * @see Json for date format.
     *
     * @param jsonString The String to be parsed.
     * @return A {@link Date} object.
     */
    public static Date parseDate(String jsonString) {
        try {
            return new SimpleDateFormat(Json.DATE_FORMAT, Locale.US).parse(jsonString);
        } catch (ParseException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Rounds the given ounces value up a quarter decimal. In the iPhone version of Anglers'
     * Log, ounces are used for imperial rather than strictly decimal weights such as in the
     * Android version.
     *
     * An input of 3 will return 0.25. An input of 8 will return 0.5.
     *
     * @param ounces The ounces to be converted. Value should be between 0 and 16.
     * @return A decimal value close to the given ounce.
     */
    public static float ouncesToDecimal(int ounces) {
        if (ounces == 0)
            return 0;
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
            String baitCategoryId = jsonObject.getString(Json.BAIT_CATEGORY);
            if (!baitCategoryId.isEmpty())
                baitCategory = Logbook.getBaitCategory(UUID.fromString(baitCategoryId));
        } catch (JSONException e) {
            Log.e(TAG, "No value for " + Json.BAIT_CATEGORY);
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

    /**
     * Gets a Map for all UserDefineObject arrays that correspond to the JSON file. It is done this
     * way only for compatibility with iOS exporting.
     *
     * @return A map of user define object names as keys, and a
     * {@link com.cohenadair.anglerslog.model.backup.JsonImporter.UserDefineJson} as values.
     */
    private static LinkedHashMap<String, UserDefineJson> getUserDefineJsonMap() {
        LinkedHashMap<String, UserDefineJson> map = new LinkedHashMap<>();

        map.put(Json.NAME_FISHING_METHODS, new UserDefineJson(Json.FISHING_METHODS, new OnAddObject() {
            @Override
            public void onAddObject(JSONObject obj) throws JSONException {
                Logbook.addFishingMethod(new FishingMethod(obj));
            }
        }));

        map.put(Json.NAME_LOCATIONS, new UserDefineJson(Json.LOCATIONS, new OnAddObject() {
            @Override
            public void onAddObject(JSONObject obj) throws JSONException {
                Logbook.addLocation(new Location(obj));
            }
        }));

        map.put(Json.NAME_SPECIES, new UserDefineJson(Json.SPECIES, new OnAddObject() {
            @Override
            public void onAddObject(JSONObject obj) throws JSONException {
                Logbook.addSpecies(new Species(obj));
            }
        }));

        map.put(Json.NAME_BAIT_CATEGORIES, new UserDefineJson(Json.BAIT_CATEGORIES, new OnAddObject() {
            @Override
            public void onAddObject(JSONObject obj) throws JSONException {
                Logbook.addBaitCategory(new BaitCategory(obj));
            }
        }));

        map.put(Json.NAME_BAITS, new UserDefineJson(Json.BAITS, new OnAddObject() {
            @Override
            public void onAddObject(JSONObject obj) throws JSONException {
                Logbook.addBait(new Bait(obj));
            }
        }));

        map.put(Json.NAME_WATER_CLARITIES, new UserDefineJson(Json.WATER_CLARITIES, new OnAddObject() {
            @Override
            public void onAddObject(JSONObject obj) throws JSONException {
                Logbook.addWaterClarity(new WaterClarity(obj));
            }
        }));

        map.put(Json.NAME_ANGLERS, new UserDefineJson(Json.ANGLERS, new OnAddObject() {
            @Override
            public void onAddObject(JSONObject obj) throws JSONException {
                Logbook.addAngler(new Angler(obj));
            }
        }));

        return map;
    }

    /**
     * Used to easily iterate through the Json.USER_DEFINES property in a Logbook's data file.
     */
    private static class UserDefineJson {

        private String mName;
        private OnAddObject mCallbacks;

        public UserDefineJson(String name, OnAddObject callbacks) {
            mName = name;
            mCallbacks = callbacks;
        }

        public String getName() {
            return mName;
        }

        public void setName(String name) {
            mName = name;
        }

        public OnAddObject getCallbacks() {
            return mCallbacks;
        }

        public void setCallbacks(OnAddObject callbacks) {
            mCallbacks = callbacks;
        }
    }
}
