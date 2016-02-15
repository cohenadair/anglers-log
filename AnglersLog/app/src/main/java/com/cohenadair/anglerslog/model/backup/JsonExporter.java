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

    private interface OnGetUserDefineString {
        String getString(UserDefineObject obj) throws JSONException;
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
     * @see #getUserDefineJsonArray(ArrayList, OnGetUserDefineString)
     */
    public static JSONArray getJsonIdArray(ArrayList<UserDefineObject> arr) throws JSONException {
        return getUserDefineJsonArray(arr, new OnGetUserDefineString() {
            @Override
            public String getString(UserDefineObject obj) throws JSONException {
                return obj.getIdAsString();
            }
        });
    }

    /**
     * Gets a JSONArray of the names of the given UserDefineObject array.
     * @see #getUserDefineJsonArray(ArrayList, OnGetUserDefineString)
     */
    public static JSONArray getJsonNameArray(ArrayList<UserDefineObject> arr) throws JSONException {
        return getUserDefineJsonArray(arr, new OnGetUserDefineString() {
            @Override
            public String getString(UserDefineObject obj) throws JSONException {
                return obj.getName();
            }
        });
    }

    private static JSONArray getTripsJson() throws JSONException {
        return getUserDefineJsonArray(Logbook.getTrips(), new OnGetUserDefineJson() {
            @Override
            public JSONObject getJson(UserDefineObject obj) throws JSONException {
                return ((Trip) obj).toJson();
            }
        });
    }

    private static JSONArray getCatchesJson() throws JSONException {
        return getUserDefineJsonArray(Logbook.getCatches(), new OnGetUserDefineJson() {
            @Override
            public JSONObject getJson(UserDefineObject obj) throws JSONException {
                return ((Catch) obj).toJson();
            }
        });
    }

    private static JSONArray getUserDefinesJson() throws JSONException {
        return null;
    }

    private static JSONArray getUserDefineJsonArray(ArrayList<UserDefineObject> arr, OnGetUserDefineJson callbacks) throws JSONException {
        JSONArray jsonArray = new JSONArray();

        for (UserDefineObject obj : arr)
            jsonArray.put(callbacks.getJson(obj));

        return jsonArray;
    }

    private static JSONArray getUserDefineJsonArray(ArrayList<UserDefineObject> arr, OnGetUserDefineString callbacks) throws JSONException {
        JSONArray jsonArray = new JSONArray();

        for (UserDefineObject obj : arr)
            jsonArray.put(callbacks.getString(obj));

        return jsonArray;
    }
}
