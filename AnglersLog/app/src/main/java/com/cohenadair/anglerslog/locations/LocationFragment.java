package com.cohenadair.anglerslog.locations;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.LayoutSpecActivity;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.FishingSpot;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.views.SelectionSpinnerView;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;

import java.util.UUID;

/**
 * A {@link DetailFragment} subclass used to show the details of a single location.
 */
public class LocationFragment extends DetailFragment implements OnMapReadyCallback {

    private Location mLocation;

    private SelectionSpinnerView mFishingSpotSelection;
    private GoogleMap mMap;

    public LocationFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_location, container, false);

        initFishingSpotSelection(view);

        // Obtain the SupportMapFragment and get notified when the map is ready to be used.
        SupportMapFragment mapFragment = (SupportMapFragment)getChildFragmentManager().findFragmentById(R.id.map);
        mapFragment.getMapAsync(this);

        update(getRealActivity());

        // Inflate the layout for this fragment
        return view;
    }

    @Override
    public void update(LayoutSpecActivity activity, UUID id) {
        if (isAttached()) {
            setItemId(id);
            mLocation = Logbook.getLocation(id);

            if (mLocation == null)
                return;

            // update spinner adapter
            ArrayAdapter<UserDefineObject> adapter = new ArrayAdapter<>(getContext(), R.layout.list_item_spinner, mLocation.getFishingSpots());
            adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
            mFishingSpotSelection.setAdapter(adapter);

            updateMap();
        }
    }

    @Override
    public void update(LayoutSpecActivity activity) {
        update(activity, activity.getSelectionId());
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        mMap = googleMap;
        updateMap();
    }

    private void updateMap() {
        if (mMap == null)
            return;

        int selectedIndex = mFishingSpotSelection.getSelectedIndex();
        FishingSpot selectedFishingSpot = (FishingSpot)mLocation.getFishingSpots().get(selectedIndex);

        // Add a marker in Sydney and move the camera
        LatLng sydney = new LatLng(-34, 151);
        mMap.addMarker(new MarkerOptions().position(sydney).title(selectedFishingSpot.getName()));
        mMap.moveCamera(CameraUpdateFactory.newLatLng(sydney));
    }

    private void initFishingSpotSelection(View view) {
        mFishingSpotSelection = (SelectionSpinnerView)view.findViewById(R.id.fishing_spot_spinner);
        mFishingSpotSelection.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                selectFishingSpot(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        selectFishingSpot(0);
    }

    private void selectFishingSpot(int position) {
        mFishingSpotSelection.setSelection(position);
        updateMap();
    }
}
