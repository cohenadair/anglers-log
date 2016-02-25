package com.cohenadair.anglerslog.map;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.LayoutSpecActivity;
import com.cohenadair.anglerslog.fragments.DraggableMapFragment;
import com.cohenadair.anglerslog.fragments.MasterFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.FishingSpotMarkerManager;
import com.google.android.gms.maps.GoogleMap;

import java.util.ArrayList;

/**
 * A LocationMapFragment displays an interactive map of all the user's fishing spots.
 * Created by Cohen Adair on 2016-02-03.
 */
public class LocationMapFragment extends MasterFragment {

    private static final String TAG_MAP = "LocationMapMap";

    private LinearLayout mContainer;
    private DraggableMapFragment mMapFragment;

    private FishingSpotMarkerManager mMarkerManager;
    private ArrayList<UserDefineObject> mFishingSpots;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setClearMenuOnCreate(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_map, container, false);

        mContainer = (LinearLayout)view.findViewById(R.id.location_map_container);
        mFishingSpots = Logbook.getAllFishingSpots();
        initMapFragment();

        return view;
    }

    @Override
    public void update(LayoutSpecActivity activity) {
        updateMap();
    }

    private void initMapFragment() {
        // check to see if the map fragment already exists
        mMapFragment = (DraggableMapFragment)getChildFragmentManager().findFragmentByTag(TAG_MAP);
        if (mMapFragment != null)
            return;

        mMapFragment = DraggableMapFragment.newInstance(true, false);
        mMapFragment.getMapAsync(new DraggableMapFragment.InteractionListener() {
            @Override
            public void onMapReady(GoogleMap map) {
                LocationMapFragment.this.onMapReady();
            }

            @Override
            public void onLocationUpdate(android.location.Location location) {

            }
        });

        getChildFragmentManager()
                .beginTransaction()
                .add(R.id.location_map_container, mMapFragment, TAG_MAP)
                .commit();
    }

    private void onMapReady() {
        mMarkerManager = new FishingSpotMarkerManager(getContext(), mContainer, mMapFragment.getGoogleMap());
        mMarkerManager.setShowFishingSpotLocation(true);
        updateMap();
    }

    private void updateMap() {
        if (mMapFragment.getGoogleMap() == null || mFishingSpots.size() <= 0)
            return;

        mMarkerManager.setFishingSpots(mFishingSpots);
        mMarkerManager.updateMarkers();
        mMarkerManager.showAllMarkers();
    }
}
