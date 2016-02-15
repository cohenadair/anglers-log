package com.cohenadair.anglerslog.model.backup;

import android.support.annotation.NonNull;

import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Locale;

/**
 * The JsonEporter class is used to create a JSONObject of the user's
 * {@link com.cohenadair.anglerslog.model.Logbook}.
 *
 * @author Cohen Adair
 */
public class JsonExporter {

    private interface OnGetUserDefineJson {
        JSONObject getJson(UserDefineObject obj) throws JSONException;
    }

    public static JSONObject getJson() throws JSONException {
        JSONObject json = new JSONObject();

        json.put(Json.TRIPS, getTripsJson());
        json.put(Json.ENTRIES, getCatchesJson());
        json.put(Json.USER_DEFINES, getUserDefinesJson());

        return new JSONObject().put(Json.JOURNAL, json);
    }

    /**
     * Formats a given date to be used for importing and exporting.
     * @param date The Date object to format.
     * @return A String representing the given date.
     */
    @NonNull
    public static String dateToString(Date date) {
        return new SimpleDateFormat(Json.DATE_FORMAT, Locale.US).format(date);
    }

    /**
     * Gets a JSONArray of the UUID's of the given UserDefineObject array.
     * @param arr The UserDefineObject array.
     * @return A JSONArray of UUID String objects.
     */
    public static JSONArray getJsonIdArray(ArrayList<UserDefineObject> arr) {
        JSONArray result = new JSONArray();

        for (UserDefineObject obj : arr)
            result.put(obj.getIdAsString());

        return result;
    }

    public static JSONArray getJsonStringArray(ArrayList<String> arr) {
        JSONArray result = new JSONArray();

        for (String str : arr)
            result.put(str);

        return result;
    }

    private static JSONArray getTripsJson() throws JSONException {
        return getUserDefineJson(Logbook.getTrips(), new OnGetUserDefineJson() {
            @Override
            public JSONObject getJson(UserDefineObject obj) throws JSONException {
                return ((Trip)obj).toJson();
            }
        });
    }

    private static JSONArray getCatchesJson() throws JSONException {
        return getUserDefineJson(Logbook.getCatches(), new OnGetUserDefineJson() {
            @Override
            public JSONObject getJson(UserDefineObject obj) throws JSONException {
                return ((Catch)obj).toJson();
            }
        });
    }

    private static JSONArray getUserDefinesJson() throws JSONException {
        return null;
    }

    private static JSONArray getUserDefineJson(ArrayList<UserDefineObject> arr, OnGetUserDefineJson callbacks) throws JSONException {
        JSONArray jsonArray = new JSONArray();
        ArrayList<UserDefineObject> trips = Logbook.getTrips();

        for (UserDefineObject obj : trips)
            jsonArray.put(callbacks.getJson(obj));

        return jsonArray;
    }
}
