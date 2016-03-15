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
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.GoogleMapLayout;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.TextInputView;
import com.cohenadair.anglerslog.views.TitleSubTitleView;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.LatLng;

import java.util.ArrayList;

/**
 * The ManageFishingSpotFragment is used to add and edit fishing spots. This
 * {@link ManageContentFragment} subclass works slightly different than others. It doesn't interact
 * with the backend database directly. This is so {@link FishingSpot} objects aren't manipulated in
 * the database before the user saves the location.
 *
 * @author Cohen Adair
 */
public class ManageFishingSpotFragment extends ManageContentFragment {

    private TextInputView mNameView;
    private TitleSubTitleView mLatitudeView;
    private TitleSubTitleView mLongitudeView;
    private DraggableMapFragment mMapFragment;
    private GoogleMap mMap;

    private Location mLocation;
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
    }

    @Override
    public ManageObjectSpec getManageObjectSpec() {
        return mManageObjectSpec;
    }

    public void setLocation(Location location) {
        mLocation = location;
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

        if (mMap != null) {
            fishingSpot.setLatitude(mMap.getCameraPosition().target.latitude);
            fishingSpot.setLongitude(mMap.getCameraPosition().target.longitude);
        } else {
            // in case Google Play Services isn't available, fishing spots can still be added and updated later
            fishingSpot.setLatitude(0.0);
            fishingSpot.setLongitude(0.0);
        }

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

    private void updateMap() {
        if (mMap == null)
            return;

        // move the camera to the current fishing spot
        if (isEditing())
            updateCamera(getNewFishingSpot().getCoordinates());
        else if (mLocation != null) {
            // if the location already has fishing spots, move the camera to one
            // this is simply for user convenience
            ArrayList<UserDefineObject> fishingSpots = mLocation.getFishingSpots();
            if (fishingSpots.size() > 0)
                updateCamera(((FishingSpot)fishingSpots.get(0)).getCoordinates());
        }
    }

    private void initNameView(View view) {
        mNameView = (TextInputView)view.findViewById(R.id.name_view);
    }

    private void initCoordinatesView(View view) {
        mLatitudeView = (TitleSubTitleView)view.findViewById(R.id.latitude_layout);
        mLongitudeView = (TitleSubTitleView)view.findViewById(R.id.longitude_layout);
    }

    private void updateCoordinateViews(LatLng coordinates) {
        mLatitudeView.setSubtitle(String.format("%.6f", coordinates.latitude));
        mLongitudeView.setSubtitle(String.format("%.6f", coordinates.longitude));
    }

    private void initMapFragment() {
        mMapFragment = (DraggableMapFragment)getChildFragmentManager().findFragmentById(R.id.fishing_spot_map);

        mMapFragment.setLocationEnabled(true);
        mMapFragment.setLocationUpdatesEnabled(true);
        mMapFragment.setHasOptionsMenu(false);

        mMapFragment.getMapAsync(new DraggableMapFragment.InteractionListener() {
            @Override
            public void onMapReady(GoogleMap map) {
                mMap = map;
                updateMap();
            }

            @Override
            public void onLocationUpdate(android.location.Location location) {
                if (isEditing())
                    return;

                updateCamera(new LatLng(location.getLatitude(), location.getLongitude()));
                mMapFragment.setLocationUpdatesEnabled(false);
            }
        });

        mMapFragment.setOnDragListener(new GoogleMapLayout.OnDragListener() {
            @Override
            public void onDrag(MotionEvent motionEvent) {
                if (mMap != null)
                    updateCoordinateViews(mMap.getCameraPosition().target);
            }
        });
    }

    private void updateCamera(LatLng loc) {
        mMapFragment.updateCamera(loc);
        updateCoordinateViews(loc);
    }
}
