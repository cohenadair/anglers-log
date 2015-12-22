package com.cohenadair.anglerslog.fragments;

import android.support.v4.app.Fragment;

import com.cohenadair.anglerslog.activities.LayoutSpecActivity;

/**
 * An abstract class for master fragments used throughout the application.
 *
 * Created by Cohen Adair on 2015-10-25.
 */
public abstract class MasterFragment extends Fragment {

    /**
     * Updates the fragment's UI.
     */
    public abstract void update(LayoutSpecActivity activity);

    public LayoutSpecActivity getRealActivity() {
        return (LayoutSpecActivity)getActivity();
    }
}
