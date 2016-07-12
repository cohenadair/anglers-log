package com.cohenadair.anglerslog.fragments;

import android.content.DialogInterface;
import android.location.Location;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.app.AlertDialog;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.AlertUtils;
import com.cohenadair.anglerslog.utilities.GoogleMapLayout;
import com.cohenadair.anglerslog.utilities.LogbookPreferences;
import com.cohenadair.anglerslog.utilities.PermissionUtils;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationListener;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;

/**
 * A SupportMapFragment wrapper class to handle map drag events. It also handles optional user
 * location support and integration with the Google FusedLocationProviderApi.
 *
 * @author Cohen Adair
 */
public class DraggableMapFragment extends SupportMapFragment implements OnMapReadyCallback, GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener {

    private static final float ZOOM = 15;

    private static final String ARG_ENABLE_LOCATION = "arg_enable_location";
    private static final String ARG_ENABLE_UPDATES = "arg_enable_updates";

    private GoogleApiClient mGoogleApiClient;
    private View mOriginalView;
    private GoogleMap mGoogleMap;

    private GoogleMapLayout.OnDragListener mOnDragListener;
    private InteractionListener mCallbacks;
    private OnUpdateMapType mOnUpdateMapType;
    private boolean mLocationEnabled = false;
    private boolean mLocationUpdatesEnabled = false;

    public interface InteractionListener {
        void onMapReady(GoogleMap map);
        void onLocationUpdate(Location location);
    }

    /**
     * A callback for when the user changes the map type.
     */
    public interface OnUpdateMapType {
        void onUpdate(int mapType);
    }

    public static DraggableMapFragment newInstance(boolean enableLocation, boolean enableLocationUpdates) {
        DraggableMapFragment fragment = new DraggableMapFragment();

        // add primitive id to bundle so save through orientation changes
        Bundle args = new Bundle();
        args.putBoolean(ARG_ENABLE_LOCATION, enableLocation);
        args.putBoolean(ARG_ENABLE_UPDATES, enableLocationUpdates);

        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (getArguments() != null) {
            mLocationEnabled = getArguments().getBoolean(ARG_ENABLE_LOCATION);
            mLocationUpdatesEnabled = getArguments().getBoolean(ARG_ENABLE_UPDATES);
        }

        if (mGoogleApiClient == null)
            mGoogleApiClient = new GoogleApiClient.Builder(getContext())
                    .addApi(LocationServices.API)
                    .addConnectionCallbacks(this)
                    .addOnConnectionFailedListener(this)
                    .build();

        setHasOptionsMenu(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        mOriginalView = super.onCreateView(inflater, container, savedInstanceState);

        GoogleMapLayout mapLayout = new GoogleMapLayout(getActivity());
        mapLayout.addView(mOriginalView);

        // nested inner class used here in case mOnDragListener is set after onCreateView is called
        mapLayout.setOnDragListener(new GoogleMapLayout.OnDragListener() {
            @Override
            public void onDrag(MotionEvent motionEvent) {
                if (mOnDragListener != null)
                    mOnDragListener.onDrag(motionEvent);
            }
        });

        return mapLayout;
    }

    @Override
    public void onStart() {
        connectToGoogleClient();
        super.onStart();
    }

    @Override
    public void onStop() {
        disconnectFromGoogleClient();
        super.onStop();
    }

    @Override
    public View getView() {
        return mOriginalView;
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        inflater.inflate(R.menu.menu_draggable_map, menu);
        super.onCreateOptionsMenu(menu, inflater);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        if (id == R.id.action_map_type) {
            onClickMapTypeOption();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode != PermissionUtils.REQUEST_LOCATION || permissions.length != 1)
            return;

        if (permissions[0].equals(PermissionUtils.LOCATION) && grantResults[0] == PermissionUtils.GRANTED)
            enableMyLocation();
        else
            AlertUtils.showError(getContext(), R.string.location_permissions_denied);
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        mGoogleMap = googleMap;
        mGoogleMap.setMapType(LogbookPreferences.getMapType());

        if (isLocationPermissionGranted())
            enableMyLocation();
        else
            requestLocationPermission();

        if (mCallbacks != null)
            mCallbacks.onMapReady(googleMap);
    }

    @Override
    public void onConnected(Bundle bundle) {
        if (mLocationUpdatesEnabled)
            startLocationUpdates();
        else
            disconnectFromGoogleClient();
    }

    @Override
    public void onConnectionSuspended(int i) {

    }

    @Override
    public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {

    }

    public void getMapAsync(InteractionListener callbacks) {
        mCallbacks = callbacks;
        getMapAsync(this);
    }

    public GoogleMap getGoogleMap() {
        return mGoogleMap;
    }

    public void setLocationEnabled(boolean locationEnabled) {
        mLocationEnabled = locationEnabled;
    }

    public void setLocationUpdatesEnabled(boolean locationUpdatesEnabled) {
        mLocationUpdatesEnabled = locationUpdatesEnabled;
    }

    public void setOnDragListener(GoogleMapLayout.OnDragListener onDragListener) {
        mOnDragListener = onDragListener;
    }

    public void setOnUpdateMapType(OnUpdateMapType onUpdateMapType) {
        mOnUpdateMapType = onUpdateMapType;
    }

    /**
     * Updates the map camera to the give location.
     *
     * @param loc The {@link LatLng} from which to update the camera.
     * @param time The animation time, in milliseconds.
     * @param callback Callbacks.
     */
    public void updateCamera(LatLng loc, int time, GoogleMap.CancelableCallback callback) {
        try {
            mGoogleMap.animateCamera(CameraUpdateFactory.newLatLngZoom(loc, ZOOM), time, callback);
        } catch (NullPointerException e) {
            e.printStackTrace();
        }
    }

    /**
     * Performs a two second animation to the given location.
     * @see #updateCamera(LatLng, int, GoogleMap.CancelableCallback)
     */
    public void updateCamera(LatLng loc) {
        updateCamera(loc, 2000, null);
    }

    /**
     * Updates the camera to the given location. Camera's zoom isn't doesn't change.
     * @see #updateCamera(LatLng, int, GoogleMap.CancelableCallback)
     */
    public void updateCameraNoZoom(LatLng loc, int time, GoogleMap.CancelableCallback callback) {
        try {
            mGoogleMap.animateCamera(CameraUpdateFactory.newLatLng(loc), time, callback);
        } catch (NullPointerException e) {
            e.printStackTrace();
        }
    }

    /**
     * Performs a two second animation to the given location. The camera's zoom remains unchanged.
     * @see #updateCameraNoZoom(LatLng, int, GoogleMap.CancelableCallback)
     */
    public void updateCameraNoZoom(LatLng loc) {
        updateCameraNoZoom(loc, 2000, null);
    }

    /**
     * Takes a screenshot of the map.
     */
    public void takeSnapshot(GoogleMap.SnapshotReadyCallback callback) {
        mGoogleMap.snapshot(callback);
    }

    /**
     * @return True if the given {@link LatLng} object is valid; false otherwise.
     */
    public boolean isValid(LatLng latLng) {
        return (latLng.latitude >= -90 && latLng.latitude <= 90) && (latLng.longitude >= -180 && latLng.longitude <= 180);
    }

    /**
     * @return True if this instance uses user location and we have permission to access the
     *         device's location; false otherwise.
     */
    private boolean isLocationPermissionGranted() {
        return mLocationEnabled && PermissionUtils.isLocationGranted(getContext());
    }

    /**
     * Requests device location permission from the user if this instance is tracking user location.
     */
    private void requestLocationPermission() {
        if (!mLocationEnabled)
            return;

        PermissionUtils.requestLocation(this);
    }

    private void connectToGoogleClient() {
        if (mGoogleApiClient != null && !mGoogleApiClient.isConnected())
            mGoogleApiClient.connect();
    }

    private void disconnectFromGoogleClient() {
        if (mGoogleApiClient != null && mGoogleApiClient.isConnected())
            mGoogleApiClient.disconnect();
    }

    /**
     * The {@link #isLocationPermissionGranted()} should always be called before calling this
     * method, unless this method is called in
     * {@link #onRequestPermissionsResult(int, String[], int[])}.
     */
    @SuppressWarnings("ResourceType")
    private void enableMyLocation() {
        if (!mLocationEnabled)
            return;

        mGoogleMap.setMyLocationEnabled(true);
        startLocationUpdates();
    }

    /**
     * @see {@link #enableMyLocation()}
     */
    @SuppressWarnings("ResourceType")
    private void startLocationUpdates() {
        if (mGoogleApiClient == null || !mGoogleApiClient.isConnected())
            return;

        if (!isLocationPermissionGranted())
            return;

        LocationRequest request =
                new LocationRequest().setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);

        LocationServices.FusedLocationApi.requestLocationUpdates(mGoogleApiClient, request, new LocationListener() {
            @Override
            public void onLocationChanged(Location location) {
                if (!mLocationUpdatesEnabled) {
                    LocationServices.FusedLocationApi.removeLocationUpdates(mGoogleApiClient, mDummyListener);
                    return;
                }

                if (mCallbacks != null)
                    mCallbacks.onLocationUpdate(location);
            }
        });
    }

    // used to remove ambiguity in a FusedLocationApi.removeLocationUpdates call
    LocationListener mDummyListener = new LocationListener() {
        @Override
        public void onLocationChanged(Location location) {

        }
    };

    public void onClickMapTypeOption(boolean showTitle) {
        if (mGoogleMap == null)
            return;

        AlertDialog.Builder builder = new AlertDialog.Builder(getContext());

        builder.setSingleChoiceItems(R.array.map_types, mGoogleMap.getMapType() - 1, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                mGoogleMap.setMapType(which + 1);
                LogbookPreferences.setMapType(mGoogleMap.getMapType());

                if (mOnUpdateMapType != null)
                    mOnUpdateMapType.onUpdate(mGoogleMap.getMapType());

                dialog.dismiss();
            }
        });

        if (showTitle)
            builder.setTitle(R.string.select_map_type);

        builder.show();
    }

    public void onClickMapTypeOption() {
        onClickMapTypeOption(false);
    }
}
