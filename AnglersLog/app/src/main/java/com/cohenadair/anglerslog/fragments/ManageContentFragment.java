package com.cohenadair.anglerslog.fragments;

import android.support.v4.app.Fragment;
import android.util.Log;

/**
 * The ManageContentFragment is the superclass of the content fragments used in ManageFragment
 * instances.
 *
 * Used as an instance variable type in ManageFragmentInfo.
 *
 * Created by Cohen Adair on 2015-09-30.
 */
public abstract class ManageContentFragment extends Fragment {

    public boolean mIsEditing;
    public int mEditingPosition;

    /**
     * Adds a UserDefineObject to the Logbook. This method must be implemented by all subclasses.
     * @return True if the object was successfully added to the Logbook, false otherwise.
     */
    public abstract boolean addObjectToLogbook();

    @Override
    public void onResume() {
        super.onResume();

        if (isEditing())
            Log.d("", "We are editing!");
        else
            Log.d("", "We are not editing!");
    }

    public boolean isEditing() {
        return mIsEditing;
    }

    public void setIsEditing(boolean isEditing, int itemPosition) {
        mIsEditing = isEditing;
        mEditingPosition = itemPosition;
    }
}
