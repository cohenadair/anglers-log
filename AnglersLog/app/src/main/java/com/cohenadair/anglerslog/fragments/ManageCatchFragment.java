package com.cohenadair.anglerslog.fragments;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Spinner;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Logbook;

/**
 * The ManageCatchFragment is used to add and edit catches.
 */
public class ManageCatchFragment extends Fragment {

    private Spinner mSpeciesSpinner;

    public ManageCatchFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage_catch, container, false);

        ArrayAdapter<CharSequence> adapter = new ArrayAdapter<CharSequence>(getContext(), android.R.layout.simple_spinner_item, Logbook.getInstance().speciesNames());
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        mSpeciesSpinner = (Spinner)view.findViewById(R.id.species_spinner);
        mSpeciesSpinner.setAdapter(adapter);

        return view;
    }

}
