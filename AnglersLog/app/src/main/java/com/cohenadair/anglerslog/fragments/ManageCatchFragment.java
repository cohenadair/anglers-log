package com.cohenadair.anglerslog.fragments;

import android.support.v4.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;

/**
 * The ManageCatchFragment is used to add and edit catches.
 */
public class ManageCatchFragment extends Fragment {

    public ManageCatchFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_manage_catch, container, false);
    }

}
