package com.cohenadair.anglerslog.locations;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.FishingSpot;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.FishingSpotView;
import com.cohenadair.anglerslog.views.TextInputView;

import java.util.ArrayList;

/**
 * The ManageLocationFragment is used to add and edit locations.
 */
public class ManageLocationFragment extends ManageContentFragment {

    private LinearLayout mContainer;
    private TextInputView mNameView;
    private ImageButton mAddFishingSpotButton;

    private ArrayList<UserDefineObject> mFishingSpots;

    public ManageLocationFragment() {
        // Required empty public constructor
    }

    private Location getNewLocation() {
        return (Location)getNewObject();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage_location, container, false);

        mContainer = (LinearLayout)view.findViewById(R.id.container);
        initNameView(view);
        initAddFishingSpotButton(view);
        initSubclassObject();

        if (mFishingSpots == null)
            mFishingSpots = new ArrayList<>();

        return view;
    }

    @Override
    public ManageObjectSpec getManageObjectSpec() {
        return new ManageObjectSpec(R.string.error_location_add, R.string.success_location_add, R.string.error_location_edit, R.string.success_location_edit, new ManageInterface() {
            @Override
            public boolean onEdit() {
                return Logbook.editLocation(getEditingId(), getNewLocation());
            }

            @Override
            public boolean onAdd() {
                if (Logbook.addLocation(getNewLocation())) {
                    getNewLocation().setFishingSpots(mFishingSpots);
                    return true;
                }

                return false;
            }
        });
    }

    @Override
    public void initSubclassObject() {
        initObject(new InitializeInterface() {
            @Override
            public UserDefineObject onGetOldObject() {
                return Logbook.getLocation(getEditingId());
            }

            @Override
            public UserDefineObject onGetNewEditObject(UserDefineObject oldObject) {
                Location loc = new Location((Location)oldObject, true);
                mFishingSpots = loc.getFishingSpots();
                return loc;
            }

            @Override
            public UserDefineObject onGetNewBlankObject() {
                return new Location();
            }
        });
    }

    @Override
    public boolean verifyUserInput() {
        Location loc = getNewLocation();

        loc.setName(mNameView.getInputText());

        // name
        if (loc.isNameNull()) {
            Utils.showErrorAlert(getActivity(), R.string.error_bait_name);
            return false;
        }

        // duplicate name
        if (!isEditing() && Logbook.locationExists(loc)) {
            Utils.showErrorAlert(getActivity(), R.string.error_location_name);
            return false;
        }

        // fishing spots
        if (mFishingSpots.size() <= 0) {
            Utils.showErrorAlert(getActivity(), R.string.error_no_fishing_spots);
            return false;
        }

        return true;
    }

    @Override
    public void updateViews() {
        mNameView.setInputText(getNewLocation().getName() != null ? getNewLocation().getName() : "");
        updateFishingSpots();
    }

    private void updateFishingSpots() {
        for (UserDefineObject spot : getNewLocation().getFishingSpots())
            addFishingSpot((FishingSpot)spot);
    }

    private void initNameView(View view) {
        mNameView = (TextInputView)view.findViewById(R.id.name_view);
    }

    private void initAddFishingSpotButton(View view) {
        mAddFishingSpotButton = (ImageButton)view.findViewById(R.id.add_button);
        mAddFishingSpotButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                addFishingSpot(new FishingSpot("Fishing Spot Name"));
            }
        });
    }

    private void addFishingSpot(FishingSpot spot) {
        mFishingSpots.add(spot);

        FishingSpotView fishingSpotView = new FishingSpotView(getContext());
        fishingSpotView.setTitle(spot.getName());
        fishingSpotView.setSubtitle("0.000000, 0.000000");

        mContainer.addView(fishingSpotView);
    }

}
