package com.cohenadair.anglerslog.locations;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.content.ContextCompat;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.LayoutSpecActivity;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.FishingSpot;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.SelectionSpinnerView;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.UUID;

/**
 * A {@link DetailFragment} subclass used to show the details of a single location.
 */
public class LocationFragment extends DetailFragment implements OnMapReadyCallback {

    private static final int REQUEST_LOCATION = 0;
    private static final String TAG_MAP = "fragment_map";

    private Location mLocation;

    private TextView mTitleTextView;
    private SelectionSpinnerView mFishingSpotSelection;
    private ArrayList<Marker> mMarkers;
    private HashMap<String, MarkerInfo> mMarkerInfo;
    private GoogleMap mMap;

    public LocationFragment() {
        // Required empty public constructor
    }

    public class MarkerInfo {
        public String title;
        public String numberCaught;
        public String coordinates;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_location, container, false);

        initTitle(view);
        initFishingSpotSelection(view);
        initMapFragment();

        if (mMarkers == null)
            mMarkers = new ArrayList<>();

        if (mMarkerInfo == null)
            mMarkerInfo = new HashMap<>();

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

            // update title
            if (getRealActivity().isTwoPane())
                mTitleTextView.setText(mLocation.getName());
            else
                getRealActivity().setActionBarTitle(mLocation.getName());
            
            // update map
            updateMap();
        }
    }

    @Override
    public void update(LayoutSpecActivity activity) {
        update(activity, activity.getSelectionId());
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == REQUEST_LOCATION) {
            if (permissions.length == 1 && permissions[0].equals(Manifest.permission.ACCESS_FINE_LOCATION) && grantResults[0] == PackageManager.PERMISSION_GRANTED)
                mMap.setMyLocationEnabled(true);
        } else
            Utils.showErrorAlert(getContext(), R.string.error_location_permission);
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        mMap = googleMap;
        mMap.setInfoWindowAdapter(new LocationInfoWindowAdapter());

        // update the Spinner if one of the fishing spot markers was selected
        mMap.setOnMarkerClickListener(new GoogleMap.OnMarkerClickListener() {
            @Override
            public boolean onMarkerClick(Marker marker) {
                marker.showInfoWindow();
                mFishingSpotSelection.setSelection(mMarkers.indexOf(marker));
                return true;
            }
        });

        mMap.setOnMapClickListener(new GoogleMap.OnMapClickListener() {
            @Override
            public void onMapClick(LatLng latLng) {
                for (Marker marker : mMarkers)
                    marker.hideInfoWindow();
            }
        });

        if (ContextCompat.checkSelfPermission(getContext(), Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED)
            mMap.setMyLocationEnabled(true);
        else
            requestPermissions(new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, REQUEST_LOCATION);

        updateMap();
    }

    private void updateMap() {
        if (mMap == null)
            return;

        // remove all existing markers
        for (Marker marker : mMarkers)
            marker.remove();

        final int selectedIndex = mFishingSpotSelection.getSelectedIndex();
        ArrayList<UserDefineObject> fishingSpots = mLocation.getFishingSpots();
        mMarkers = new ArrayList<>();

        // add a marker for each fishing spot
        for (int i = 0; i < fishingSpots.size(); i++) {
            FishingSpot spot = (FishingSpot)fishingSpots.get(i);

            MarkerOptions options = new MarkerOptions()
                    .position(spot.getCoordinates())
                    .title(spot.getName())
                    .snippet(spot.getName());

            mMarkers.add(mMap.addMarker(options));

            // add fishing spot info to be accessed later
            String lat = getContext().getResources().getString(R.string.lat);
            String lng = getContext().getResources().getString(R.string.lng);
            String caught = getContext().getResources().getString(R.string.number_caught);

            MarkerInfo info = new MarkerInfo();
            info.title = spot.getName();
            info.coordinates = spot.getCoordinatesAsString(lat, lng);
            info.numberCaught = spot.getNumberOfCatches() + " " + caught;

            mMarkerInfo.put(spot.getName(), info);
        }

        // move the camera to the current fishing spot
        // TODO calculate actual zoom depending on fishing spots
        float zoom = 15;
        mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(((FishingSpot) fishingSpots.get(selectedIndex)).getCoordinates(), zoom), 2000, new GoogleMap.CancelableCallback() {
            @Override
            public void onFinish() {
                // show the info window for the selected fishing spot
                mMarkers.get(selectedIndex).showInfoWindow();
            }

            @Override
            public void onCancel() {

            }
        });
    }

    private void initTitle(View view) {
        mTitleTextView = (TextView)view.findViewById(R.id.title_text_view);
        mTitleTextView.setVisibility(getRealActivity().isTwoPane() ? View.VISIBLE : View.GONE);
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

    private void initMapFragment() {
        // check to see if the map fragment already exists
        SupportMapFragment mapFragment = (SupportMapFragment)getChildFragmentManager().findFragmentByTag(TAG_MAP);
        if (mapFragment != null)
            return;

        // obtain the SupportMapFragment and get notified when the map is ready to be used.
        mapFragment = new SupportMapFragment();
        mapFragment.getMapAsync(this);

        getChildFragmentManager()
                .beginTransaction()
                .add(R.id.location_container, mapFragment, TAG_MAP)
                .commit();
    }

    private void selectFishingSpot(int position) {
        mFishingSpotSelection.setSelection(position);
        updateMap();
    }

    private class LocationInfoWindowAdapter implements GoogleMap.InfoWindowAdapter {

        @Override
        public View getInfoWindow(Marker marker) {
            return null;
        }

        @Override
        public View getInfoContents(Marker marker) {
            View view = LayoutInflater.from(getContext()).inflate(R.layout.view_location_info_window, null);

            TextView name = (TextView)view.findViewById(R.id.location_name_text_view);
            TextView numberCaught = (TextView)view.findViewById(R.id.spots_text_view);
            TextView coordinates = (TextView)view.findViewById(R.id.coordinates_text_view);

            MarkerInfo info = mMarkerInfo.get(marker.getTitle());

            name.setText(info.title);
            numberCaught.setText(info.numberCaught);
            coordinates.setText(info.coordinates);

            return view;
        }
    }
}
