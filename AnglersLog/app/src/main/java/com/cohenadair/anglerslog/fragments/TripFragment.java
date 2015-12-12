package com.cohenadair.anglerslog.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Logbook;

import java.util.UUID;

/**
 * A simple {@link DetailFragment} subclass used to show details of a single trip.
 */
public class TripFragment extends DetailFragment {

    TextView mNameTextView;

    public TripFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_trip, container, false);

        mNameTextView = (TextView)view.findViewById(R.id.name_text_view);

        if (Logbook.getCatchCount() <= 0) {
            mNameTextView.setText("There are 0 trips in your log.");
        } else
            update(getRealActivity());

        // Inflate the layout for this fragment
        return view;
    }

    @Override
    public void update(UUID position) {
        mNameTextView.setText("Trip");
    }
}
