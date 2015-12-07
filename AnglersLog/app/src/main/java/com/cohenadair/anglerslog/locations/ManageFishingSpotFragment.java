package com.cohenadair.anglerslog.locations;

import android.os.Bundle;
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

    private TextInputView mNameView;
    private TextInputView mLatitudeView;
    private TextInputView mLongitudeView;
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
        initMapFragment(view);
        initSubclassObject();

        return view;
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
    public void onMapReady(GoogleMap googleMap) {
        mMap = googleMap;
        updateMap();
    }

    private void updateMap() {
        if (mMap == null)
            return;

        // move the camera to the current fishing spot
        if (isEditing()) {
            LatLng current = new LatLng(getNewFishingSpot().getLatitude(), getNewFishingSpot().getLongitude());
            mMap.moveCamera(CameraUpdateFactory.newLatLng(current));
        }
    }

    private void initNameView(View view) {
        mNameView = (TextInputView)view.findViewById(R.id.name_view);
    }

    private void initCoordinatesView(View view) {
        mLatitudeView = (TextInputView)view.findViewById(R.id.latitude_layout);
        mLongitudeView = (TextInputView)view.findViewById(R.id.longitude_layout);
    }

    private void initMapFragment(View view) {
        DraggableMapFragment map = (DraggableMapFragment)getChildFragmentManager().findFragmentById(R.id.map);
        map.getMapAsync(this);
        map.setOnDragListener(new GoogleMapLayout.OnDragListener() {
            @Override
            public void onDrag(MotionEvent motionEvent) {
                if (mMap != null) {
                    LatLng coords = mMap.getCameraPosition().target;
                    mLatitudeView.setInputText(String.format("%.6f", coords.latitude));
                    mLongitudeView.setInputText(String.format("%.6f", coords.longitude));
                }
            }
        });
    }

}
