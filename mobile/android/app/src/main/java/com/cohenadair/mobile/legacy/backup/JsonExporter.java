package com.cohenadair.mobile.legacy.backup;

import static com.cohenadair.anglerslog.utilities.LogbookPreferences.*;

import android.content.Context;
import androidx.annotation.NonNull;

import com.cohenadair.mobile.legacy.Logbook;
import com.cohenadair.mobile.legacy.user_defines.UserDefineObject;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Locale;

/**
 * The JsonExporter class is used to create a JSONObject of the user's {@link Logbook}.
 * @author Cohen Adair
 */
public class JsonExporter {
    /**
     * An interface to be used on different {@link UserDefineObject} subclasses.
     */
    private interface OnGetJsonObject {
        Object get(UserDefineObject obj) throws JSONException;
    }

    /**
     * Returns a {@link JSONObject} representation of the current {@link Logbook}.
     * @throws JSONException Throws a JSONException if the object could not be  constructed.
     */
    public static JSONObject getJson(Context context) throws JSONException {
        JSONObject json = new JSONObject();

        json.put(Json.NAME, Logbook.getName());
        json.put(Json.TRIPS, getJsonArray(Logbook.getTrips()));
        json.put(Json.ENTRIES, getJsonArray(Logbook.getCatches()));
        json.put(Json.USER_DEFINES, getUserDefinesJson());
        json.put(Json.MEASUREMENT_SYSTEM, getUnits(context));
        json.put(Json.WEATHER_MEASUREMENT_SYSTEM, getWeatherUnits(context));

        return new JSONObject().put(Json.JOURNAL, json);
    }

    /**
     * Formats a given date to be used for importing and exporting.
     * @param date The Date object to format.
     * @return A String representing the given date.
     */
    @NonNull
    public static String dateToString(Date date) {
        return new SimpleDateFormat(Json.DATE_FORMAT_MS, Locale.US).format(date);
    }

    /**
     * Gets a JSONArray of the UUID's of the given UserDefineObject array.
     * @see #getUserDefineJsonArray(ArrayList, OnGetJsonObject)
     */
    public static JSONArray getIdJsonArray(ArrayList<UserDefineObject> arr) throws JSONException {
        return getUserDefineJsonArray(arr, UserDefineObject::getIdAsString);
    }

    /**
     * Gets a JSONArray of the names of the given UserDefineObject array.
     * @see #getUserDefineJsonArray(ArrayList, OnGetJsonObject)
     */
    public static JSONArray getNameJsonArray(ArrayList<UserDefineObject> arr) throws JSONException {
        return getUserDefineJsonArray(arr, UserDefineObject::getName);
    }

    /**
     * Gets a JSONArray of the JSONObject associated with eact item in the given array of
     * {@link UserDefineObject} instances.
     *
     * @see #getUserDefineJsonArray(ArrayList, OnGetJsonObject)
     */
    public static JSONArray getJsonArray(ArrayList<UserDefineObject> arr) throws JSONException {
        return getUserDefineJsonArray(arr, UserDefineObject::toJson);
    }

    /**
     * Gets the JSON entry for Json.USER_DEFINES.
     * @see #getUserDefineJsonObject(String, String, ArrayList)
     */
    private static JSONArray getUserDefinesJson() throws JSONException {
        JSONArray json = new JSONArray();

        json.put(getUserDefineJsonObject(Json.NAME_BAIT_CATEGORIES, Json.BAIT_CATEGORIES, Logbook.getBaitCategories()));
        json.put(getUserDefineJsonObject(Json.NAME_BAITS, Json.BAITS, Logbook.getBaits()));
        json.put(getUserDefineJsonObject(Json.NAME_FISHING_METHODS, Json.FISHING_METHODS, Logbook.getFishingMethods()));
        json.put(getUserDefineJsonObject(Json.NAME_LOCATIONS, Json.LOCATIONS, Logbook.getLocations()));
        json.put(getUserDefineJsonObject(Json.NAME_SPECIES, Json.SPECIES, Logbook.getSpecies()));
        json.put(getUserDefineJsonObject(Json.NAME_WATER_CLARITIES, Json.WATER_CLARITIES, Logbook.getWaterClarities()));
        json.put(getUserDefineJsonObject(Json.NAME_ANGLERS, Json.ANGLERS, Logbook.getAnglers()));

        return json;
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

    /**
     * A helper method for creating a Json.USER_DEFINES entry. Each entry contains a name, journal
     * name, and an array for each {@link UserDefineObject} subclass. Most of these arrays will be
     * empty. It is done this way to keep compatibility with iOS.
     *
     * @see #getUserDefinesJson()
     *
     * @param name The display name of the entry.
     * @param arrName The name of the JSON property for the input array.
     * @param arr The {@link UserDefineObject} array to convert to JSON.
     * @return A {@link JSONObject} representation of a Json.USER_DEFINES entry.
     * @throws JSONException Throws JSONException if the {@link JSONObject} cannot be constructed.
     */
    private static JSONObject getUserDefineJsonObject(String name, String arrName, ArrayList<UserDefineObject> arr) throws JSONException {
        JSONObject json = new JSONObject();

        json.put(Json.NAME, name);
        json.put(Json.JOURNAL, Logbook.getName());

        // empty arrays are used here to keep iOS compatibility
        json.put(Json.BAIT_CATEGORIES, new JSONArray());
        json.put(Json.BAITS, new JSONArray());
        json.put(Json.FISHING_METHODS, new JSONArray());
        json.put(Json.LOCATIONS, new JSONArray());
        json.put(Json.SPECIES, new JSONArray());
        json.put(Json.WATER_CLARITIES, new JSONArray());
        json.put(Json.ANGLERS, new JSONArray());

        // add the actual JSON array
        json.put(arrName, getJsonArray(arr));

        return json;
    }
}
