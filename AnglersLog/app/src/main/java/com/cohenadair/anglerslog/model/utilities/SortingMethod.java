package com.cohenadair.anglerslog.model.utilities;

import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.Comparator;

/**
 * The SortingMethod class is used for storing information about different sorting methods used
 * throughout the application.
 *
 * @author Cohen Adair
 */
public class SortingMethod {

    private String mDisplayText; // used in UI
    private Comparator<UserDefineObject> mComparator;

    public SortingMethod(String displayText, Comparator<UserDefineObject> comparator) {
        mDisplayText = displayText;
        mComparator = comparator;
    }

    //region Getters & Setters
    public String getDisplayText() {
        return mDisplayText;
    }

    public Comparator<UserDefineObject> getComparator() {
        return mComparator;
    }
    //endregion
}
