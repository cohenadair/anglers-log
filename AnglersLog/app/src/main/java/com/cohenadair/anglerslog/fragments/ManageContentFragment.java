package com.cohenadair.anglerslog.fragments;

import android.support.v4.app.Fragment;

import java.util.UUID;

/**
 * The ManageContentFragment is the superclass of the content fragments used in ManageFragment
 * instances.
 *
 * Created by Cohen Adair on 2015-09-30.
 */
public abstract class ManageContentFragment extends Fragment {

    public static final int REQUEST_PHOTO = 0;
    public static final int REQUEST_SELECTION = 1;

    private boolean mIsEditing;
    private UUID mEditingId;

    /**
     * Adds a UserDefineObject to the Logbook. This method must be implemented by all subclasses.
     * @return True if the object was successfully added to the Logbook, false otherwise.
     */
    public abstract boolean addObjectToLogbook();

    /**
     * Anything that needs to be cleaned up when the fragment is dismissed.
     */
    public abstract void onDismiss();

    @Override
    public void onPause() {
        super.onPause();
    }

    public boolean isEditing() {
        return mIsEditing;
    }

    public void setIsEditing(boolean isEditing, UUID itemId) {
        mIsEditing = isEditing;
        mEditingId = itemId;
    }

    public UUID getEditingId() {
        return mEditingId;
    }
}
