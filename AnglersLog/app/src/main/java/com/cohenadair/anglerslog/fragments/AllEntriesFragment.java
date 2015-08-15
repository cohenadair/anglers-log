package com.cohenadair.anglerslog.fragments;

import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;

/**
 * A placeholder fragment containing a simple view.
 */
public class AllEntriesFragment extends Fragment {

    public AllEntriesFragment() {
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_main, container, false);
    }

    public void clickListItem() {

    }
}
