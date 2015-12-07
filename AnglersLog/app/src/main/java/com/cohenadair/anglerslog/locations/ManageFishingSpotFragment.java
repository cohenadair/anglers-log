package com.cohenadair.anglerslog.locations;

import android.Manifest;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.content.ContextCompat;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.DraggableMapFragment;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.model.user_defines.FishingSpot;
import com.cohenadair.anglerslog.utilities.GoogleMapLayout;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.SelectionView;
import com.cohenadair.anglerslog.views.TextInputView;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.model.LatLng;

/**
 * The ManageFishingSpotFragment is used to add and edit fishing spots. This ManageContentFragment
 * subclass works slightly different than others. It doesn't interact with the backend database
 * directly. This is so FishingSpot objects aren't manipulated in the database before the user
 * saves the location.
 */
public class ManageFishingSpotFragment extends ManageContentFragment implements OnMapReadyCallback {

    private static final int REQUEST_LOCATION = 0;
    private static final float ZOOM = 15;

    private TextInputView mNameView;
    private SelectionView mLatitudeView;
    private SelectionView mLongitudeView;
    private GoogleMap mMap;

    private ManageObjectSpec mManageObjectSpec;
    private InitializeInterface mInitializeInterface;
    private OnVerifyInterface mOnVerifyInterface;

    public interface OnVerifyInterface {
        boolean isDuplicate(FishingSpot fishingSpot);
    }

    public ManageFishingSpotFragment() {
        // Required empty public constructor
    }

    public FishingSpot getNewFishingSpot() {
        return (FishingSpot)getNewObject();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage_fishing_spot, container, false);

        initNameView(view);
        initCoordinatesView(view);
        initMapFragment();
        initSubclassObject();

        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
        Utils.requestLocationServices(getContext());
    }

    @Override
    public ManageObjectSpec getManageObjectSpec() {
        return mManageObjectSpec;
    }

    public void setManageObjectSpec(ManageObjectSpec manageObjectSpec) {
        mManageObjectSpec = manageObjectSpec;
    }

    public void setInitializeInterface(InitializeInterface initializeInterface) {
        mInitializeInterface = initializeInterface;
    }

    public void setOnVerifyInterface(OnVerifyInterface onVerifyInterface) {
        mOnVerifyInterface = onVerifyInterface;
    }

    @Override
    public void initSubclassObject() {
        initObject(mInitializeInterface);
    }

    @Override
    public boolean verifyUserInput() {
        FishingSpot fishingSpot = getNewFishingSpot();

        fishingSpot.setName(mNameView.getInputText());
        fishingSpot.setLatitude(mMap.getCameraPosition().target.latitude);
        fishingSpot.setLongitude(mMap.getCameraPosition().target.longitude);

        // name
        if (fishingSpot.isNameNull()) {
            Utils.showErrorAlert(getActivity(), R.string.error_name);
            return false;
        }

        // duplicate name
        if (!isEditing() && mOnVerifyInterface.isDuplicate(fishingSpot)) {
            Utils.showErrorAlert(getActivity(), R.string.error_fishing_spot_name);
            return false;
        }

        return true;
    }

    @Override
    public void updateViews() {
        mNameView.setInputText(getNewFishingSpot().getName() != null ? getNewFishingSpot().getName() : "");
        updateMap();
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

        if (!isEditing())
            mMap.setOnMyLocationChangeListener(new GoogleMap.OnMyLocationChangeListener() {
            @Override
            public void onMyLocationChange(Location location) {
                LatLng coordinates = new LatLng(location.getLatitude(), location.getLongitude());
                mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(coordinates, ZOOM), 2000, null);
                mMap.setOnMyLocationChangeListener(null);
                updateCoordinateViews(coordinates);
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

        // move the camera to the current fishing spot
        if (isEditing()) {
            LatLng current = new LatLng(getNewFishingSpot().getLatitude(), getNewFishingSpot().getLongitude());
            mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(current, ZOOM), 2000, null);
            updateCoordinateViews(current);
        }
    }

    private void initNameView(View view) {
        mNameView = (TextInputView)view.findViewById(R.id.name_view);
    }

    private void initCoordinatesView(View view) {
        mLatitudeView = (SelectionView)view.findViewById(R.id.latitude_layout);
        mLongitudeView = (SelectionView)view.findViewById(R.id.longitude_layout);
    }

    private void updateCoordinateViews(LatLng coordinates) {
        mLatitudeView.setSubtitle(String.format("%.6f", coordinates.latitude));
        mLongitudeView.setSubtitle(String.format("%.6f", coordinates.longitude));
    }

    private void initMapFragment() {
        DraggableMapFragment map = (DraggableMapFragment)getChildFragmentManager().findFragmentById(R.id.map);
        map.getMapAsync(this);
        map.setOnDragListener(new GoogleMapLayout.OnDragListener() {
            @Override
            public void onDrag(MotionEvent motionEvent) {
                if (mMap != null)
                    updateCoordinateViews(mMap.getCameraPosition().target);
            }
        });
    }
}
