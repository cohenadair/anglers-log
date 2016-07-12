package com.cohenadair.anglerslog.locations;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.fragments.ManageFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.FishingSpot;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.AlertUtils;
import com.cohenadair.anglerslog.utilities.ViewUtils;
import com.cohenadair.anglerslog.views.InputButtonView;
import com.cohenadair.anglerslog.views.InputTextView;
import com.cohenadair.anglerslog.views.MoreDetailView;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * The ManageLocationFragment is used to add and edit locations.
 */
public class ManageLocationFragment extends ManageContentFragment {

    private LinearLayout mContainer;
    private InputTextView mNameView;

    private ArrayList<MoreDetailView> mFishingSpotViews;
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
        initAddFishingSpotView(view);
        initSubclassObject();

        if (mFishingSpots == null || !isEditing())
            mFishingSpots = new ArrayList<>();

        if (mFishingSpotViews == null)
            mFishingSpotViews = new ArrayList<>();

        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
        mNameView.addOnInputTextChangedListener(ViewUtils.onTextChangedListener(new ViewUtils.OnTextChangedListener() {
            @Override
            public void onTextChanged(String newText) {
                getNewLocation().setName(newText);
            }
        }));
    }

    @Override
    public ManageObjectSpec getManageObjectSpec() {
        return new ManageObjectSpec(R.string.error_location_add, R.string.success_location_add, R.string.error_location_edit, R.string.success_location_edit, new ManageInterface() {
            @Override
            public boolean onEdit() {
                if (Logbook.editLocation(getEditingId(), getNewLocation())) {
                    getNewLocation().setFishingSpots(mFishingSpots);
                    return true;
                }

                return false;
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

        // name
        if (loc.isNameNull()) {
            AlertUtils.showError(getActivity(), R.string.error_name);
            return false;
        }

        // duplicate name
        if (isNameDifferent() && Logbook.locationExists(loc)) {
            AlertUtils.showError(getActivity(), R.string.error_location_name);
            return false;
        }

        // fishing spots
        if (mFishingSpots.size() <= 0) {
            AlertUtils.showError(getActivity(), R.string.error_no_fishing_spots);
            return false;
        }

        return true;
    }

    @Override
    public void updateViews() {
        mNameView.setInputText(getNewLocation().getName() != null ? getNewLocation().getName() : "");
        updateAllFishingSpots();
    }

    private void updateAllFishingSpots() {
        // remove all old views
        for (MoreDetailView fishingSpotView : mFishingSpotViews) {
            ViewGroup parent = ((ViewGroup)fishingSpotView.getParent());
            if (parent != null)
                parent.removeView(fishingSpotView);
        }

        for (UserDefineObject spot : mFishingSpots)
            addFishingSpot((FishingSpot)spot);
    }

    private void initNameView(View view) {
        mNameView = (InputTextView)view.findViewById(R.id.name_view);
    }

    private void initAddFishingSpotView(View view) {
        InputButtonView addFishingSpotView = (InputButtonView)view.findViewById(R.id.add_fishing_spot_view);
        addFishingSpotView.setOnClickPrimaryButton(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                goToManageFishingSpot(null);
            }
        });
    }

    private void addFishingSpot(final FishingSpot spot) {
        final MoreDetailView fishingSpotView = new MoreDetailView(getContext());
        fishingSpotView.setTitle(spot.getName());
        fishingSpotView.setSubtitle(spot.getCoordinatesAsString());
        fishingSpotView.setDetailButtonImage(R.drawable.ic_remove);
        fishingSpotView.setTitleStyle(R.style.TextView_Small);
        fishingSpotView.setSubtitleStyle(R.style.TextView_SmallSubtitle);
        fishingSpotView.useNoLeftSpacing();
        fishingSpotView.useDefaultStyle();

        fishingSpotView.setOnClickDetailButton(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mFishingSpots.remove(spot);
                mContainer.removeView(fishingSpotView);
            }
        });

        fishingSpotView.setOnClickContent(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                goToManageFishingSpot(spot.getId());
            }
        });

        mFishingSpotViews.add(fishingSpotView);
        mContainer.addView(fishingSpotView);
    }

    /**
     * Opens a ManageFishingSpotFragment dialog.
     * @param editingId The editing id of the fishing spot, or null if a new spot is being added.
     */
    private void goToManageFishingSpot(UUID editingId) {
        final ManageFishingSpotFragment fragment = new ManageFishingSpotFragment();

        if (editingId != null)
            fragment.setIsEditing(true, editingId);

        // get all possible fishing spots to be used when adding a new spot
        // this is purely for user convenience
        List<UserDefineObject> allPossibleFishingSpots = mFishingSpots;
        mFishingSpots.addAll(getNewLocation().getFishingSpots());
        fragment.setFishingSpots(allPossibleFishingSpots);

        fragment.setOnVerifyInterface(new ManageFishingSpotFragment.OnVerifyInterface() {
            @Override
            public boolean isDuplicate(FishingSpot fishingSpot) {
                for (UserDefineObject obj : mFishingSpots)
                    if (obj.getName().equals(fishingSpot.getName()))
                        return true;

                return false;
            }
        });

        fragment.setManageObjectSpec(new ManageObjectSpec(R.string.error_fishing_spot_add, R.string.success_fishing_spot_add, R.string.error_fishing_spot_edit, R.string.success_fishing_spot_edit, new ManageInterface() {
            @Override
            public boolean onEdit() {
                for (int i = 0; i < mFishingSpots.size(); i++)
                    // update the fishing spot if this is the one we're editing
                    if (mFishingSpots.get(i).getId().equals(fragment.getNewFishingSpot().getId())) {
                        mFishingSpots.set(i, new FishingSpot(fragment.getNewFishingSpot(), true));
                        updateViews();
                        return true;
                    }

                return false;
            }

            @Override
            public boolean onAdd() {
                mFishingSpots.add(fragment.getNewFishingSpot());
                addFishingSpot(fragment.getNewFishingSpot());
                return true;
            }
        }));

        fragment.setInitializeInterface(new InitializeInterface() {
            @Override
            public UserDefineObject onGetOldObject() {
                return getFishingSpot(fragment.getEditingId());
            }

            @Override
            public UserDefineObject onGetNewEditObject(UserDefineObject oldObject) {
                return new FishingSpot((FishingSpot) oldObject, true);
            }

            @Override
            public UserDefineObject onGetNewBlankObject() {
                return new FishingSpot();
            }
        });

        ManageFragment manageFragment = new ManageFragment();
        manageFragment.setTitle(R.string.empty);
        manageFragment.setContentFragment(fragment);
        manageFragment.show(getChildFragmentManager(), null);
    }

    @Nullable
    private FishingSpot getFishingSpot(UUID id) {
        for (UserDefineObject fishingSpot : mFishingSpots)
            if (fishingSpot.getId().equals(id))
                return (FishingSpot)fishingSpot;

        return null;
    }

}
