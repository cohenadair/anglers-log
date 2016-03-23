package com.cohenadair.anglerslog.trips;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.CatchListPortionActivity;
import com.cohenadair.anglerslog.baits.BaitListManager;
import com.cohenadair.anglerslog.catches.CatchListManager;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.locations.LocationListManager;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.ListManager;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.DisplayLabelView;
import com.cohenadair.anglerslog.views.ListPortionLayout;

import java.util.ArrayList;
import java.util.UUID;

/**
 * A {@link DetailFragment} subclass used to show the details of a single
 * {@link com.cohenadair.anglerslog.model.user_defines.Trip}.
 */
public class TripFragment extends DetailFragment {

    private Trip mTrip;

    private DisplayLabelView mNameView;
    private DisplayLabelView mStartDateView;
    private DisplayLabelView mEndDateView;
    private DisplayLabelView mAnglersView;
    private DisplayLabelView mNotesView;

    private ListPortionLayout mCatchesContainer;
    private ListPortionLayout mLocationsContainer;
    private ListPortionLayout mBaitsContainer;

    public TripFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_trip, container, false);

        setContainer((LinearLayout) view.findViewById(R.id.trip_container));

        mNameView = (DisplayLabelView)view.findViewById(R.id.name_view);
        mStartDateView = (DisplayLabelView)view.findViewById(R.id.start_date_view);
        mEndDateView = (DisplayLabelView)view.findViewById(R.id.end_date_view);
        mCatchesContainer = (ListPortionLayout)view.findViewById(R.id.catches_container);
        mLocationsContainer = (ListPortionLayout)view.findViewById(R.id.locations_container);
        mBaitsContainer = (ListPortionLayout)view.findViewById(R.id.baits_container);
        mAnglersView = (DisplayLabelView)view.findViewById(R.id.anglers_view);
        mNotesView = (DisplayLabelView)view.findViewById(R.id.notes_view);

        update(getActivity());

        // Inflate the layout for this fragment
        return view;
    }

    @Override
    public void update(UUID id) {
        if (!isAttached())
            return;

        clearActionBarTitle();

        // id can be null if in two-pane view and there are no baits
        if (id == null) {
            hide();
            return;
        }

        setItemId(id);
        mTrip = Logbook.getTrip(id);

        // mBait can be null if in tw-pane view and a bait was removed
        if (mTrip == null) {
            hide();
            return;
        }

        show();

        updateNameView();
        updateDateView();
        updateCatchesView();
        updateLocationsView();
        updateBaitsView();
        updateAnglersView();
        updateNotesView();
    }

    private void updateNameView() {
        if (mTrip.isNameNull()) {
            Utils.toggleVisibility(mNameView, false);
            return;
        }

        mNameView.setLabel(mTrip.getDisplayName());
    }

    private void updateDateView() {
        mStartDateView.setLabel(mTrip.getStartDateAsString());
        mEndDateView.setLabel(mTrip.getEndDateAsString());
    }

    private void startListPortionActivity(Intent intent) {
        startActivity(intent);
    }

    private void updateCatchesView() {
        mCatchesContainer.init(mTrip.getCatches(), new ListPortionLayout.InteractionListener() {
            @Override
            public ListManager.Adapter onGetAdapter(ArrayList<UserDefineObject> items) {
                return getCatchesAdapter(items);
            }

            @Override
            public void onClickAllButton(ArrayList<UserDefineObject> items) {
                startListPortionActivity(CatchListPortionActivity.getIntent(getContext(), mTrip.getDisplayName(), LayoutSpecManager.LAYOUT_CATCHES, items));
            }
        });

        mCatchesContainer.setButtonText(R.string.all_catches);
    }

    @NonNull
    private ListManager.Adapter getCatchesAdapter(ArrayList<UserDefineObject> items) {
        return new CatchListManager.Adapter(getContext(), items, true, new OnClickInterface() {
            @Override
            public void onClick(View view, UUID id) {
                startDetailActivity(LayoutSpecManager.LAYOUT_CATCHES, id);
            }
        });
    }

    private void updateLocationsView() {
        mLocationsContainer.init(mTrip.getLocations(), new ListPortionLayout.InteractionListener() {
            @Override
            public ListManager.Adapter onGetAdapter(ArrayList<UserDefineObject> items) {
                return getLocationsAdapter(items);
            }

            @Override
            public void onClickAllButton(ArrayList<UserDefineObject> items) {
                startListPortionActivity(CatchListPortionActivity.getIntent(getContext(), mTrip.getDisplayName(), LayoutSpecManager.LAYOUT_LOCATIONS, items));
            }
        });

        mLocationsContainer.setButtonText(R.string.all_locations);
    }

    @NonNull
    private ListManager.Adapter getLocationsAdapter(ArrayList<UserDefineObject> items) {
        return new LocationListManager.Adapter(getContext(), items, true, new OnClickInterface() {
            @Override
            public void onClick(View view, UUID id) {
                startDetailActivity(LayoutSpecManager.LAYOUT_LOCATIONS, id);
            }
        });
    }

    private void updateBaitsView() {
        mBaitsContainer.init(mTrip.getBaits(), new ListPortionLayout.InteractionListener() {
            @Override
            public ListManager.Adapter onGetAdapter(ArrayList<UserDefineObject> items) {
                return getBaitsAdapter(items);
            }

            @Override
            public void onClickAllButton(ArrayList<UserDefineObject> items) {
                startListPortionActivity(CatchListPortionActivity.getIntent(getContext(), mTrip.getDisplayName(), LayoutSpecManager.LAYOUT_BAITS, items));
            }
        });

        mBaitsContainer.setButtonText(R.string.all_baits);
    }

    @NonNull
    private ListManager.Adapter getBaitsAdapter(ArrayList<UserDefineObject> items) {
        return new BaitListManager.Adapter(getContext(), items, true, new OnClickInterface() {
            @Override
            public void onClick(View view, UUID id) {
                startDetailActivity(LayoutSpecManager.LAYOUT_BAITS, id);
            }
        });
    }

    private void updateAnglersView() {
        Utils.toggleVisibility(mAnglersView, mTrip.hasAnglers());
        mAnglersView.setLabel(mTrip.getAnglersAsString());
    }

    private void updateNotesView() {
        Utils.toggleVisibility(mNotesView, mTrip.hasNotes());
        mNotesView.setLabel(mTrip.getNotesAsString());
    }
}
