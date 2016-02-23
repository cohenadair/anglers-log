package com.cohenadair.anglerslog.model.utilities;

import android.content.Context;
import android.support.annotation.NonNull;
import android.util.Log;

import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.ArrayList;
import java.util.Iterator;

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

        for (UserDefineObject obj : arr) {
            builder.append(obj.toKeywordsString(context));
            builder.append(" ");
        }

        return builder.toString();
    }

    public static boolean hasObjectNamed(ArrayList<UserDefineObject> arr, String name) {
        for (UserDefineObject obj : arr)
            if (obj.getName().equals(name))
                return true;

        return false;
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

    public static ArrayList<String> asIdStringArray(ArrayList<UserDefineObject> arr) {
        ArrayList<String> ids = new ArrayList<>();
        for (UserDefineObject object : arr)
            ids.add(object.getIdAsString());
        return ids;
    }

    public static ArrayList<String> asNameStringArray(ArrayList<UserDefineObject> arr) {
        ArrayList<String> names = new ArrayList<>();
        for (UserDefineObject object : arr)
            names.add(object.getName());
        return names;
    }

    public static ArrayList<UserDefineObject> asObjectArray(ArrayList<String> arr, OnConvertInterface callbacks) {
        ArrayList<UserDefineObject> objects = new ArrayList<>();
        for (String str : arr)
            objects.add(callbacks.onGetObject(str));
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
                    Log.d("UserDefineArrays#search", "Found keyword '" + keyword + "' in '" + keywordString + "'");
                    matches.add(obj);
                }
        }

        return matches;
    }

}
