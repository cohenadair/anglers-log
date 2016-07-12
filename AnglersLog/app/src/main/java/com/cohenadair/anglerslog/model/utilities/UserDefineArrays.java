package com.cohenadair.anglerslog.model.utilities;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.UUID;

/**
 * A collection of utility methods for interacting with UserDefineObject arrays.
 * @author Cohen Adair
 */
public class UserDefineArrays {

    /**
     * Used to get a {@link UserDefineObject} subclass when converting from a String array.
     */
    public interface OnConvertInterface {
        UserDefineObject onGetObject(String idStr);
    }

    /**
     * Used for getting a concatenated String of the property values of a given
     * {@link UserDefineObject} array.
     */
    public interface OnGetPropertyInterface {
        String onGetProperty(UserDefineObject object);
    }

    /**
     * Creates a concatenated String of the give array of UserDefineObject instances.
     * @return A concatenated String.
     */
    public static String namesAsString(ArrayList<UserDefineObject> arr) {
        return propertiesAsString(arr, new OnGetPropertyInterface() {
            @Override
            public String onGetProperty(UserDefineObject object) {
                return object.getName();
            }
        });
    }

    /**
     * Gets a concatenated String of a certain property of an object.
     *
     * @param arr The array of objects who's properties will be combined.
     * @param token The separating token of the resulting String.
     * @param callbacks The callback used to get a String representation of a property.
     * @return A String representation of each property in the given array.
     */
    public static String propertiesAsString(ArrayList<UserDefineObject> arr, String token, OnGetPropertyInterface callbacks) {
        String str = "";

        if (arr.size() <= 0)
            return str;

        for (int i = 0; i < arr.size() - 1; i++)
            str += callbacks.onGetProperty(arr.get(i)) + token;

        return str + callbacks.onGetProperty(arr.get(arr.size() - 1));
    }

    /**
     * @see #propertiesAsString(ArrayList, String, OnGetPropertyInterface)
     */
    public static String propertiesAsString(ArrayList<UserDefineObject> arr, OnGetPropertyInterface callbacks) {
        return propertiesAsString(arr, ", ", callbacks);
    }

    /**
     * @return A String representation of the keywords for each object in the given array. This is
     *         normally used for searching a list of objects.
     */
    @NonNull
    public static String keywordsAsString(Context context, ArrayList<UserDefineObject> arr) {
        StringBuilder builder = new StringBuilder();

        for (UserDefineObject obj : arr)
            builder.append(obj.toKeywordsString(context));

        return builder.toString();
    }

    /**
     * @return A {@link UserDefineObject} with the given id, or null if one doesn't exist.
     */
    @Nullable
    public static UserDefineObject getObjectWithId(ArrayList<UserDefineObject> arr, UUID id) {
        for (UserDefineObject obj : arr)
            if (obj.getId().equals(id))
                return obj;

        return null;
    }

    /**
     * @return An array of {@link UUID} objects associated with the given {@link UserDefineObject}
     *         array.
     */
    public static ArrayList<UUID> asIdArray(ArrayList<UserDefineObject> arr) {
        ArrayList<UUID> ids = new ArrayList<>();

        if (arr != null)
            for (UserDefineObject obj : arr)
                ids.add(obj.getId());

        return ids;
    }

    /**
     * @return An array of {@link String} object representing the ids associated with the given
     *         {@link UserDefineObject} array.
     */
    public static ArrayList<String> asIdStringArray(ArrayList<UserDefineObject> arr) {
        ArrayList<String> ids = new ArrayList<>();

        if (arr != null)
            for (UserDefineObject object : arr)
                ids.add(object.getIdAsString());

        return ids;
    }

    /**
     * @return An array of String representations of the given ids.
     */
    public static ArrayList<String> idsAsStrings(ArrayList<UUID> ids) {
        ArrayList<String> strings = new ArrayList<>();

        if (ids != null)
            for (UUID id : ids)
                strings.add(id.toString());

        return strings;
    }

    /**
     * @return An array of UUID representations of the given Strings.
     */
    public static ArrayList<UUID> stringsAsIds(ArrayList<String> strings) {
        ArrayList<UUID> ids = new ArrayList<>();

        if (strings != null)
            for (String string : strings)
                ids.add(UUID.fromString(string));

        return ids;
    }

    /**
     * Gets a list of {@link UserDefineObject} objects based on the given array of String ids.
     *
     * @param arr The {@link UserDefineObject} array to convert.
     * @param callbacks Callbacks used to get the object from the Logbook.
     * @return An array of {@link UserDefineObject} objects.
     */
    public static ArrayList<UserDefineObject> objectsFromStringIds(ArrayList<String> arr, OnConvertInterface callbacks) {
        ArrayList<UserDefineObject> objects = new ArrayList<>();

        if (arr != null)
            for (String str : arr)
                objects.add(callbacks.onGetObject(str));

        return objects;
    }

    /**
     * Gets a list of {@link UserDefineObject} objects based on the given array of ids.
     *
     * @param arr The {@link UserDefineObject} array to convert.
     * @param callbacks Callbacks used to get the object from the Logbook.
     * @return An array of {@link UserDefineObject} objects.
     */
    public static ArrayList<UserDefineObject> objectsFromIds(ArrayList<UUID> arr, OnConvertInterface callbacks) {
        ArrayList<UserDefineObject> objects = new ArrayList<>();

        if (arr != null)
            for (UUID id : arr)
                objects.add(callbacks.onGetObject(id.toString()));

        return objects;
    }

    /**
     * Searches the given array for the given query.
     *
     * @param arr The array of {@link UserDefineObject} objects to search.
     * @param query The text to search for.
     * @return An array of {@link UserDefineObject} objects that match the query.
     */
    public static ArrayList<UserDefineObject> search(Context context, ArrayList<UserDefineObject> arr, String query) {
        if (Utils.stringOrNull(query) == null)
            return arr;

        String[] keywords = query.split(" ");
        ArrayList<UserDefineObject> matches = new ArrayList<>();

        for (UserDefineObject obj : arr) {
            String keywordString = obj.toKeywordsString(context);

            for (String keyword : keywords)
                if (keywordString.toLowerCase().contains(keyword.toLowerCase())) {
                    matches.add(obj);
                    break;
                }
        }

        return matches;
    }

    /**
     * Sorts the given array.
     *
     * @param sortingMethod The method by which to sort the array.
     * @return A sorted array of {@link UserDefineObject} objects.
     */
    public static ArrayList<UserDefineObject> sort(ArrayList<UserDefineObject> arr, SortingMethod sortingMethod) {
        Collections.sort(arr, sortingMethod.getComparator());
        return arr;
    }

    /**
     * @see #search(Context, ArrayList, String)
     * @see #sort(ArrayList, SortingMethod)
     */
    public static ArrayList<UserDefineObject> searchAndSort(Context context, ArrayList<UserDefineObject> arr, String searchQuery, SortingMethod sortingMethod) {
        ArrayList<UserDefineObject> result = search(context, arr, searchQuery);

        if (sortingMethod != null)
            result = sort(result, sortingMethod);

        return result;
    }
}
