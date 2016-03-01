package com.cohenadair.anglerslog.fragments;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.Menu;
import android.view.MenuInflater;

import com.cohenadair.anglerslog.activities.LayoutSpecActivity;

/**
 * An abstract class for master fragments used throughout the application.
 * @author Cohen Adair
 */
public abstract class MasterFragment extends Fragment {

    private boolean mClearMenuOnCreate;

    public abstract void updateInterface();

    public LayoutSpecActivity getRealActivity() {
        return (LayoutSpecActivity)getActivity();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);

        if (mClearMenuOnCreate)
            menu.clear();
    }

    public void setClearMenuOnCreate(boolean clearMenuOnCreate) {
        mClearMenuOnCreate = clearMenuOnCreate;
    }
}
