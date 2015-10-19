package com.cohenadair.anglerslog.fragments;

import android.support.v4.app.Fragment;

/**
 * The ManageContentFragment is the superclass of the content fragments used in ManageFragment
 * instances.
 *
 * Used as an instance variable type in ManageFragmentInfo.
 *
 * Created by Cohen Adair on 2015-09-30.
 */
public abstract class ManageContentFragment extends Fragment {

    private boolean mDidPause; // used for keeping data if the app is sent to the background
    private boolean mIsEditing;
    private int mEditingPosition;

    /**
     * Adds a UserDefineObject to the Logbook. This method must be implemented by all subclasses.
     * @return True if the object was successfully added to the Logbook, false otherwise.
     */
    public abstract boolean addObjectToLogbook();

    @Override
    public void onPause() {
        super.onPause();
        mDidPause = true;
    }

    public boolean isEditing() {
        return mIsEditing;
    }

    public void setIsEditing(boolean isEditing, int itemPosition) {
        mIsEditing = isEditing;
        mEditingPosition = itemPosition;
    }

    public int getEditingPosition() {
        return mEditingPosition;
    }

    public boolean getDidPause() {
        return mDidPause;
    }

    public void setDidPause(boolean didPause) {
        mDidPause = didPause;
    }
}
