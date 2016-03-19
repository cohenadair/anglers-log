package com.cohenadair.anglerslog.locations;

import android.graphics.Color;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.DraggableMapFragment;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.model.user_defines.FishingSpot;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.GoogleMapLayout;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.TextInputView;
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
    private TextInputView mLatitudeView;
    private TextInputView mLongitudeView;
    private DraggableMapFragment mMapFragment;
    private ImageView mCrosshairs;
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

        mCrosshairs = (ImageView)view.findViewById(R.id.crosshairs);

        initNameView(view);
        initCoordinatesView(view);
        initMapFragment();
        initSubclassObject();
        initToolbar();

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

        updateCrosshairs(mMap.getMapType());

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

    /**
     * Adds an icon to the toolbar that allows users to change the map type.
     */
    private void initToolbar() {
        // find the toolbar layout
        LinearLayout toolbar = null;

        View parent = getParentFragment().getView();
        if (parent != null)
            toolbar = (LinearLayout)parent.findViewById(R.id.toolbar_view);

        // create the icon
        ImageButton mapType = new ImageButton(getContext());

        mapType.setImageResource(R.drawable.ic_map);
        mapType.setBackgroundResource(Utils.resIdFromAttr(getContext(), android.R.attr.selectableItemBackground));
        mapType.setContentDescription(getResources().getString(R.string.select_map_type));
        mapType.setColorFilter(Color.BLACK);
        mapType.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mMapFragment.onClickMapTypeOption(true);
            }
        });

        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(
                getResources().getDimensionPixelOffset(R.dimen.image_button_size),
                getResources().getDimensionPixelOffset(R.dimen.image_button_size)
        );

        params.setMargins(
                0,
                getResources().getDimensionPixelOffset(R.dimen.margin_default),
                getResources().getDimensionPixelOffset(R.dimen.margin_default),
                getResources().getDimensionPixelOffset(R.dimen.margin_default)
        );

        mapType.setLayoutParams(params);

        // add the icon
        if (toolbar != null)
            toolbar.addView(mapType);
    }

    private void initNameView(View view) {
        mNameView = (TextInputView)view.findViewById(R.id.name_view);
    }

    private void initCoordinatesView(View view) {
        mLatitudeView = (TextInputView)view.findViewById(R.id.latitude_layout);
        mLatitudeView.addOnInputTextChangedListener(getCoordinateTextWatcher());

        mLongitudeView = (TextInputView)view.findViewById(R.id.longitude_layout);
        mLongitudeView.addOnInputTextChangedListener(getCoordinateTextWatcher());
    }

    private void updateCoordinateViews(LatLng coordinates) {
        mLatitudeView.setInputText(String.format("%.6f", coordinates.latitude));
        mLongitudeView.setInputText(String.format("%.6f", coordinates.longitude));
    }

    @NonNull
    private TextWatcher getCoordinateTextWatcher() {
        return new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (mLatitudeView.getInputText() == null || mLongitudeView.getInputText() == null)
                    return;

                double lat = Double.parseDouble(mLatitudeView.getInputText());
                double lng = Double.parseDouble(mLongitudeView.getInputText());
                LatLng latLng = new LatLng(lat, lng);

                if (Utils.isValid(latLng))
                    updateCameraOnly(latLng);
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        };
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

        mMapFragment.setOnUpdateMapType(new DraggableMapFragment.OnUpdateMapType() {
            @Override
            public void onUpdate(int mapType) {
                updateCrosshairs(mapType);
            }
        });
    }

    private void updateCamera(LatLng loc) {
        mMapFragment.updateCamera(loc);
        updateCoordinateViews(loc);
    }

    private void updateCameraOnly(LatLng loc) {
        mMapFragment.updateCamera(loc);
    }

    private void updateCrosshairs(int mapType) {
        boolean isDark = mapType == GoogleMap.MAP_TYPE_SATELLITE || mapType == GoogleMap.MAP_TYPE_HYBRID;
        mCrosshairs.setColorFilter(isDark ? Color.WHITE : Color.BLACK);
    }
}
