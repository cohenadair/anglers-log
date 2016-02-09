package com.cohenadair.anglerslog.model.backup;

import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Angler;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.BaitCategory;
import com.cohenadair.anglerslog.model.user_defines.FishingMethod;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.WaterClarity;
import com.cohenadair.anglerslog.utilities.LogbookPreferences;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

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

    private interface InteractionListener {
        void onAddObject(JSONObject obj) throws JSONException;
    }

    public static void parse(JSONObject json) throws JSONException {
        JSONObject journalJson = json.getJSONObject(Json.JOURNAL);

        parseUserDefines(journalJson.getJSONArray(Json.USER_DEFINES));
        parseCatches(journalJson.getJSONArray(Json.ENTRIES));
        parseTrips(journalJson.getJSONArray(Json.TRIPS));

        LogbookPreferences.setUnits(json.getInt(Json.MEASUREMENT_SYSTEM));
    }

    private static void parseTrips(JSONArray tripsJson) throws JSONException {

    }

    private static void parseCatches(JSONArray catchesJson) throws JSONException {

    }

    private static void parseUserDefines(JSONArray userDefinesJson) throws JSONException {
        for (int i = 0; i < userDefinesJson.length(); i++) {
            JSONObject obj = userDefinesJson.getJSONObject(i);
            HashMap<String, UserDefineJson> userDefineJsonMap = getUserDefineJsonMap();

            for (Map.Entry<String, UserDefineJson> entry : userDefineJsonMap.entrySet()) {
                UserDefineJson userDefineJson = entry.getValue();

                try {
                    JSONArray arr = obj.getJSONArray(userDefineJson.getName());
                    for (int j = 0; j < arr.length(); j++)
                        userDefineJson.getCallbacks().onAddObject(arr.getJSONObject(j));
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private static HashMap<String, UserDefineJson> getUserDefineJsonMap() {
        HashMap<String, UserDefineJson> map = new HashMap<>();

        map.put(Json.NAME_FISHING_METHODS, new UserDefineJson(Json.FISHING_METHODS, new InteractionListener() {
            @Override
            public void onAddObject(JSONObject obj) throws JSONException {
                Logbook.addFishingMethod(new FishingMethod(obj));
            }
        }));

        map.put(Json.NAME_LOCATIONS, new UserDefineJson(Json.LOCATIONS, new InteractionListener() {
            @Override
            public void onAddObject(JSONObject obj) throws JSONException {
                Logbook.addLocation(new Location(obj));
            }
        }));

        map.put(Json.NAME_SPECIES, new UserDefineJson(Json.SPECIES, new InteractionListener() {
            @Override
            public void onAddObject(JSONObject obj) throws JSONException {
                Logbook.addSpecies(new Species(obj));
            }
        }));

        map.put(Json.NAME_BAITS, new UserDefineJson(Json.BAITS, new InteractionListener() {
            @Override
            public void onAddObject(JSONObject obj) throws JSONException {
                Logbook.addBait(new Bait(obj));
            }
        }));

        map.put(Json.NAME_WATER_CLARITIES, new UserDefineJson(Json.WATER_CLARITIES, new InteractionListener() {
            @Override
            public void onAddObject(JSONObject obj) throws JSONException {
                Logbook.addWaterClarity(new WaterClarity(obj));
            }
        }));

        map.put(Json.NAME_ANGLERS, new UserDefineJson(Json.ANGLERS, new InteractionListener() {
            @Override
            public void onAddObject(JSONObject obj) throws JSONException {
                Logbook.addAngler(new Angler(obj));
            }
        }));

        map.put(Json.NAME_BAIT_CATEGORIES, new UserDefineJson(Json.BAIT_CATEGORIES, new InteractionListener() {
            @Override
            public void onAddObject(JSONObject obj) throws JSONException {
                Logbook.addBaitCategory(new BaitCategory(obj));
            }
        }));

        return map;
    }

    private static class UserDefineJson {

        private String mName;
        private InteractionListener mCallbacks;

        public UserDefineJson(String name, InteractionListener callbacks) {
            mName = name;
            mCallbacks = callbacks;
        }

        public String getName() {
            return mName;
        }

        public void setName(String name) {
            mName = name;
        }

        public InteractionListener getCallbacks() {
            return mCallbacks;
        }

        public void setCallbacks(InteractionListener callbacks) {
            mCallbacks = callbacks;
        }
    }
}
