package com.cohenadair.anglerslog.model.utilities;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.UUID;

/**
 * A collection of utility methods for interacting with UserDefineObject arrays.
 * Created by Cohen Adair on 2016-01-12.
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

    public static String namesAsString(ArrayList<UserDefineObject> arr, String token) {
        return propertiesAsString(arr, token, new OnGetPropertyInterface() {
            @Override
            public String onGetProperty(UserDefineObject object) {
                return object.getName();
            }
        });
    }

    public static String propertiesAsString(ArrayList<UserDefineObject> arr, OnGetPropertyInterface callbacks) {
        return propertiesAsString(arr, ", ", callbacks);
    }

    public static String propertiesAsString(ArrayList<UserDefineObject> arr, String token, OnGetPropertyInterface callbacks) {
        String str = "";

        if (arr.size() <= 0)
            return str;

        for (int i = 0; i < arr.size() - 1; i++)
            str += callbacks.onGetProperty(arr.get(i)) + token;

        return str + callbacks.onGetProperty(arr.get(arr.size() - 1));
    }

    @NonNull
    public static String keywordsAsString(Context context, ArrayList<UserDefineObject> arr) {
        StringBuilder builder = new StringBuilder();

        for (UserDefineObject obj : arr)
            builder.append(obj.toKeywordsString(context));

        return builder.toString();
    }

    @Nullable
    public static UserDefineObject getObjectNamed(ArrayList<UserDefineObject> arr, String name) {
        for (UserDefineObject obj : arr)
            if (obj.getName().equals(name))
                return obj;

        return null;
    }

    public static boolean hasObjectNamed(ArrayList<UserDefineObject> arr, String name) {
        return getObjectNamed(arr, name) != null;
    }

    @Nullable
    public static UserDefineObject getObjectWithId(ArrayList<UserDefineObject> arr, UUID id) {
        for (UserDefineObject obj : arr)
            if (obj.getId().equals(id))
                return obj;

        return null;
    }

    public static boolean hasObjectWithId(ArrayList<UserDefineObject> arr, UUID id) {
        return getObjectWithId(arr, id) != null;
    }

    public static int indexOfName(ArrayList<UserDefineObject> arr, String name) {
        for (int i = 0; i < arr.size(); i++)
            if (arr.get(i).getName().equals(name))
                return i;

        return -1;
    }

    public static ArrayList<UserDefineObject> removeObjectNamed(ArrayList<UserDefineObject> arr, String name) {
        Iterator<UserDefineObject> it = arr.iterator();
        while (it.hasNext()) {
            UserDefineObject obj = it.next();
            if (obj.getName().equals(name)) {
                it.remove();
                break;
            }
        }

        return arr;
    }

    public static ArrayList<UUID> asIdArray(ArrayList<UserDefineObject> arr) {
        ArrayList<UUID> ids = new ArrayList<>();

        if (arr != null)
            for (UserDefineObject obj : arr)
                ids.add(obj.getId());

        return ids;
    }

    public static ArrayList<String> asIdStringArray(ArrayList<UserDefineObject> arr) {
        ArrayList<String> ids = new ArrayList<>();

        if (arr != null)
            for (UserDefineObject object : arr)
                ids.add(object.getIdAsString());

        return ids;
    }

    public static ArrayList<String> idsAsStrings(ArrayList<UUID> ids) {
        ArrayList<String> strings = new ArrayList<>();

        if (ids != null)
            for (UUID id : ids)
                strings.add(id.toString());

        return strings;
    }

    public static ArrayList<UUID> stringsAsIds(ArrayList<String> strings) {
        ArrayList<UUID> ids = new ArrayList<>();

        if (strings != null)
            for (String string : strings)
                ids.add(UUID.fromString(string));

        return ids;
    }

    public static ArrayList<String> asNameStringArray(ArrayList<UserDefineObject> arr) {
        ArrayList<String> names = new ArrayList<>();

        if (arr != null)
            for (UserDefineObject object : arr)
                names.add(object.getName());

        return names;
    }

    public static ArrayList<UserDefineObject> objectsFromStringIds(ArrayList<String> arr, OnConvertInterface callbacks) {
        ArrayList<UserDefineObject> objects = new ArrayList<>();

        if (arr != null)
            for (String str : arr)
                objects.add(callbacks.onGetObject(str));

        return objects;
    }

    public static ArrayList<UserDefineObject> objectsFromIds(ArrayList<UUID> arr, OnConvertInterface callbacks) {
        ArrayList<UserDefineObject> objects = new ArrayList<>();

        if (arr != null)
            for (UUID id : arr)
                objects.add(callbacks.onGetObject(id.toString()));

        return objects;
    }

    public static ArrayList<UserDefineObject> search(Context context, ArrayList<UserDefineObject> arr, String query) {
        if (Utils.stringOrNull(query) == null)
            return arr;

        String[] keywords = query.split(" ");
        ArrayList<UserDefineObject> matches = new ArrayList<>();

        for (UserDefineObject obj : arr) {
            String keywordString = obj.toKeywordsString(context);

            for (String keyword : keywords)
                if (keywordString.toLowerCase().contains(keyword.toLowerCase())) {
                    //Log.d("UserDefineArrays#search", "Found keyword '" + keyword + "' in '" + keywordString + "'");
                    matches.add(obj);
                    break;
                }
        }

        return matches;
    }

    public static ArrayList<UserDefineObject> sort(ArrayList<UserDefineObject> arr, SortingMethod sortingMethod) {
        Collections.sort(arr, sortingMethod.getComparator());
        return arr;
    }

    public static ArrayList<UserDefineObject> searchAndSort(Context context, ArrayList<UserDefineObject> arr, String searchQuery, SortingMethod sortingMethod) {
        ArrayList<UserDefineObject> result = search(context, arr, searchQuery);

        if (sortingMethod != null)
            result = sort(result, sortingMethod);

        return result;
    }
}
