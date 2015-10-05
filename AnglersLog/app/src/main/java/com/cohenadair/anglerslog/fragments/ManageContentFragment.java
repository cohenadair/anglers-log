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
    /**
     * Adds a UserDefineObject to the Logbook. This method must be implemented by all subclasses.
     * @return True if the object was successfully added to the Logbook, false otherwise.
     */
    public abstract boolean addObjectToLogbook();
}
