package com.cohenadair.anglerslog.trips;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Trip;

import java.util.UUID;

/**
 * A {@link DetailFragment} subclass used to show the details of a single
 * {@link com.cohenadair.anglerslog.model.user_defines.Trip}.
 */
public class TripFragment extends DetailFragment {

    private Trip mTrip;

    private LinearLayout mContainer;

    public TripFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_trip, container, false);

        mContainer = (LinearLayout)view.findViewById(R.id.trip_container);

        update(getActivity());

        // Inflate the layout for this fragment
        return view;
    }

    @Override
    public void update(UUID id) {
        if (!isAttached())
            return;

        setItemId(id);
        mTrip = Logbook.getTrip(id);

        if (mTrip == null) {
            mContainer.setVisibility(View.GONE);
            return;
        }

        mContainer.setVisibility(View.VISIBLE);
    }
}
