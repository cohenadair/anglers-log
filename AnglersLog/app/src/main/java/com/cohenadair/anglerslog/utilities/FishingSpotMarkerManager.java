package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.graphics.Point;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.user_defines.FishingSpot;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * FishingSpotMarkerManager is a class for managing a set of {@link Marker} objects for a given
 * {@link GoogleMap}. Each Marker is used to display a
 * {@link com.cohenadair.anglerslog.model.user_defines.FishingSpot}.
 *
 * Created by Cohen Adair on 2016-02-04.
 */
public class FishingSpotMarkerManager {

    private Context mContext;
    private LinearLayout mContainer;

    private InteractionListener mCallbacks;
    private ArrayList<Marker> mMarkers;
    private ArrayList<UserDefineObject> mFishingSpots;
    private HashMap<String, MarkerSpec> mMarkerSpecMap;
    private GoogleMap mMap;
    private boolean mShowFishingSpotLocation;

    public interface InteractionListener {
        void onMarkerClick(Marker marker, int index);
    }

    public FishingSpotMarkerManager(Context context, LinearLayout mapContainer, GoogleMap map, InteractionListener callbacks) {
        mContext = context;
        mContainer = mapContainer;
        mMap = map;
        mCallbacks = callbacks;

        if (mMarkers == null)
            mMarkers = new ArrayList<>();

        if (mMarkerSpecMap == null)
            mMarkerSpecMap = new HashMap<>();

        initMapListeners();
    }

    public FishingSpotMarkerManager(Context context, LinearLayout mapContainer, GoogleMap map) {
        this(context, mapContainer, map, null);
    }

    public void setFishingSpots(ArrayList<UserDefineObject> fishingSpots) {
        mFishingSpots = fishingSpots;
    }

    public void setShowFishingSpotLocation(boolean showFishingSpotLocation) {
        mShowFishingSpotLocation = showFishingSpotLocation;
    }

    public void updateMarkers() {
        if (mMap == null || mFishingSpots.size() <= 0)
            return;

        // remove all existing markers
        for (Marker marker : mMarkers)
            marker.remove();

        // reinitialize the markers
        mMarkers = new ArrayList<>();

        // add a marker for each fishing spot
        for (int i = 0; i < mFishingSpots.size(); i++) {
            FishingSpot spot = (FishingSpot)mFishingSpots.get(i);

            MarkerOptions options = new MarkerOptions()
                    .position(spot.getCoordinates())
                    .title(spot.getName())
                    .snippet(spot.getName());

            mMarkers.add(mMap.addMarker(options));

            // add fishing spot information to be accessed later
            MarkerSpec spec = new MarkerSpec(
                    mShowFishingSpotLocation ? spot.getDisplayName() : spot.getName(),
                    spot.getCoordinatesAsString(getString(R.string.lat), getString(R.string.lng)),
                    spot.getNumberOfCatches() + " " + getString(R.string.number_caught)
            );

            mMarkerSpecMap.put(spot.getName(), spec);
        }
    }

    public void showInfoWindowAtIndex(int index) {
        mMarkers.get(index).showInfoWindow();
    }

    public void showAllMarkers() {
        LatLngBounds.Builder builder = new LatLngBounds.Builder();
        for (Marker marker : mMarkers)
            builder.include(marker.getPosition());

        Point size = Utils.getScreenSize(mContext);
        LatLngBounds bounds = builder.build();
        CameraUpdate update = CameraUpdateFactory.newLatLngBounds(bounds, size.x, size.y, 100);
        mMap.animateCamera(update);
    }

    private void initMapListeners() {
        mMap.setInfoWindowAdapter(new InfoWindowAdapter());

        // hide all markers when somewhere on the map is clicked
        mMap.setOnMapClickListener(new GoogleMap.OnMapClickListener() {
            @Override
            public void onMapClick(LatLng latLng) {
                for (Marker marker : mMarkers)
                    marker.hideInfoWindow();
            }
        });

        // show InfoWindow when the marker is clicked
        mMap.setOnMarkerClickListener(new GoogleMap.OnMarkerClickListener() {
            @Override
            public boolean onMarkerClick(Marker marker) {
                marker.showInfoWindow();

                if (mCallbacks != null)
                    mCallbacks.onMarkerClick(marker, mMarkers.indexOf(marker));

                return true;
            }
        });
    }

    private String getString(int resId) {
        return mContext.getResources().getString(resId);
    }

    private class MarkerSpec {
        private String mTitle;
        private String mNumberCaught;
        private String mCoordinates;

        public MarkerSpec(String title, String numberCaught, String coordinates) {
            mTitle = title;
            mNumberCaught = numberCaught;
            mCoordinates = coordinates;
        }

        public String getTitle() {
            return mTitle;
        }

        public String getNumberCaught() {
            return mNumberCaught;
        }

        public String getCoordinates() {
            return mCoordinates;
        }
    }

    private class InfoWindowAdapter implements GoogleMap.InfoWindowAdapter {

        @Override
        public View getInfoWindow(Marker marker) {
            return null;
        }

        @Override
        public View getInfoContents(Marker marker) {
            View view = LayoutInflater.from(mContext).inflate(R.layout.view_location_info_window, mContainer, false);

            TextView name = (TextView)view.findViewById(R.id.location_name_text_view);
            TextView numberCaught = (TextView)view.findViewById(R.id.spots_text_view);
            TextView coordinates = (TextView)view.findViewById(R.id.coordinates_text_view);

            MarkerSpec spec = mMarkerSpecMap.get(marker.getTitle());

            name.setText(spec.getTitle());
            numberCaught.setText(spec.getNumberCaught());
            coordinates.setText(spec.getCoordinates());

            return view;
        }
    }

}