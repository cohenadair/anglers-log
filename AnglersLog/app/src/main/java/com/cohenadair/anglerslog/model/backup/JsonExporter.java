package com.cohenadair.anglerslog.model.backup;

import android.support.annotation.NonNull;

import com.cohenadair.anglerslog.model.Logbook;
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

    /**
     * An interface to be used on different {@link UserDefineObject} subclasses.
     */
    private interface OnGetJsonObject {
        Object get(UserDefineObject obj) throws JSONException;
    }

    public static JSONObject getJson() throws JSONException {
        JSONObject json = new JSONObject();

        json.put(Json.TRIPS, getJsonUserDefineArray(Logbook.getTrips()));
        json.put(Json.ENTRIES, getJsonUserDefineArray(Logbook.getCatches()));
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
     * @see #getUserDefineJsonArray(ArrayList, OnGetJsonObject)
     */
    public static JSONArray getJsonIdArray(ArrayList<UserDefineObject> arr) throws JSONException {
        return getUserDefineJsonArray(arr, new OnGetJsonObject() {
            @Override
            public String get(UserDefineObject obj) throws JSONException {
                return obj.getIdAsString();
            }
        });
    }

    /**
     * Gets a JSONArray of the names of the given UserDefineObject array.
     * @see #getUserDefineJsonArray(ArrayList, OnGetJsonObject)
     */
    public static JSONArray getJsonNameArray(ArrayList<UserDefineObject> arr) throws JSONException {
        return getUserDefineJsonArray(arr, new OnGetJsonObject() {
            @Override
            public String get(UserDefineObject obj) throws JSONException {
                return obj.getName();
            }
        });
    }

    /**
     * Gets a JSONArray of the JSONObject associated with eact item in the given array of
     * {@link UserDefineObject} instances.
     *
     * @see #getUserDefineJsonArray(ArrayList, OnGetJsonObject)
     */
    private static JSONArray getJsonUserDefineArray(ArrayList<UserDefineObject> arr) throws JSONException {
        return getUserDefineJsonArray(arr, new OnGetJsonObject() {
            @Override
            public Object get(UserDefineObject obj) throws JSONException {
                return obj.toJson();
            }
        });
    }

    private static JSONArray getUserDefinesJson() throws JSONException {
        return null;
    }

    /**
     * A helper method that takes in an array of {@link UserDefineObject} and outputs a
     * {@link JSONArray}.
     *
     * @param arr The {@link UserDefineObject} array.
     * @param callbacks The {@link OnGetJsonObject} interface used to get the object to add to the
     *                  resulting {@link JSONArray}.
     * @return A {@link JSONArray} representation of the input {@link UserDefineObject} array.
     * @throws JSONException Throws JSONException if the result cannot be constructed.
     */
    private static JSONArray getUserDefineJsonArray(ArrayList<UserDefineObject> arr, OnGetJsonObject callbacks) throws JSONException {
        JSONArray jsonArray = new JSONArray();

        for (UserDefineObject obj : arr)
            jsonArray.put(callbacks.get(obj));

        return jsonArray;
    }
}
