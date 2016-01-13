package com.cohenadair.anglerslog.utilities;

import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.ArrayList;
import java.util.Iterator;

/**
 * A collection of utility methods for interacting with UserDefineObject arrays.
 * Created by Cohen Adair on 2016-01-12.
 */
public class UserDefineArrays {

    /**
     * Creates a concatenated String of the give array of UserDefineObject instances.
     * @return A concatenated String.
     */
    public static String namesAsString(ArrayList<UserDefineObject> arr) {
        String str = "";

        if (arr.size() <= 0)
            return str;

        for (int i = 0; i < arr.size() - 1; i++)
            str += arr.get(i).getName() + ", ";

        return str + arr.get(arr.size() - 1).getName();
    }

    public static boolean hasObjectNamed(ArrayList<UserDefineObject> arr, String name) {
        for (UserDefineObject obj : arr)
            if (obj.getName().equals(name))
                return true;

        return false;
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

}
