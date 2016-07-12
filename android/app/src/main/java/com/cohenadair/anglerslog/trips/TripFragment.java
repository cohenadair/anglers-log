package com.cohenadair.anglerslog.trips;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.PartialListActivity;
import com.cohenadair.anglerslog.baits.BaitListManager;
import com.cohenadair.anglerslog.catches.CatchListManager;
import com.cohenadair.anglerslog.database.QueryHelper;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.locations.LocationListManager;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.ListManager;
import com.cohenadair.anglerslog.utilities.ViewUtils;
import com.cohenadair.anglerslog.views.DisplayLabelView;
import com.cohenadair.anglerslog.views.PartialListView;

import java.util.ArrayList;
import java.util.UUID;

/**
 * A {@link DetailFragment} subclass used to show the details of a single
 * {@link com.cohenadair.anglerslog.model.user_defines.Trip}.
 *
 * @author Cohen Adair
 */
public class TripFragment extends DetailFragment {

    private Trip mTrip;

    private DisplayLabelView mNameView;
    private DisplayLabelView mStartDateView;
    private DisplayLabelView mEndDateView;
    private DisplayLabelView mAnglersView;
    private DisplayLabelView mNotesView;

    private PartialListView mCatchesContainer;
    private PartialListView mLocationsContainer;
    private PartialListView mBaitsContainer;

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
        mCatchesContainer = (PartialListView)view.findViewById(R.id.catches_container);
        mLocationsContainer = (PartialListView)view.findViewById(R.id.locations_container);
        mBaitsContainer = (PartialListView)view.findViewById(R.id.baits_container);
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
            ViewUtils.setVisibility(mNameView, false);
            return;
        }

        mNameView.setDetail(mTrip.getDisplayName());
    }

    private void updateDateView() {
        mStartDateView.setDetail(mTrip.getStartDateAsString());
        mEndDateView.setDetail(mTrip.getEndDateAsString());
    }

    private void startPartialListActivity(Intent intent) {
        startActivity(intent);
    }

    private void updateCatchesView() {
        mCatchesContainer.init(mTrip.getCatches(), new PartialListView.InteractionListener() {
            @Override
            public ListManager.Adapter onGetAdapter(ArrayList<UserDefineObject> items) {
                return getCatchesAdapter(items);
            }

            @Override
            public void onClickAllButton(ArrayList<UserDefineObject> items) {
                startPartialListActivity(PartialListActivity.getIntent(getContext(), mTrip.getDisplayName(), LayoutSpecManager.LAYOUT_CATCHES, items));
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
        mLocationsContainer.init(mTrip.getLocations(), new PartialListView.InteractionListener() {
            @Override
            public ListManager.Adapter onGetAdapter(ArrayList<UserDefineObject> items) {
                return getLocationsAdapter(items);
            }

            @Override
            public void onClickAllButton(ArrayList<UserDefineObject> items) {
                startPartialListActivity(PartialListActivity.getIntent(getContext(), mTrip.getDisplayName(), LayoutSpecManager.LAYOUT_LOCATIONS, items));
            }
        });

        mLocationsContainer.setButtonText(R.string.all_locations);
    }

    @NonNull
    private ListManager.Adapter getLocationsAdapter(ArrayList<UserDefineObject> items) {
        return new LocationListManager.Adapter(
                getContext(),
                items,
                true,
                new OnClickInterface() {
                    @Override
                    public void onClick(View view, UUID id) {
                        startDetailActivity(LayoutSpecManager.LAYOUT_LOCATIONS, id);
                    }
                },
                new LocationListManager.Adapter.GetContentListener() {
                    @Override
                    public String onGetSubtitle(Location location) {
                        int count = QueryHelper.queryTripsLocationCatchCount(mTrip, location);
                        String catchesOnTrip = getContext().getResources().getString(R.string.catches_on_trip);
                        return String.format("%d " + catchesOnTrip, count);
                    }
                }
        );
    }

    private void updateBaitsView() {
        mBaitsContainer.init(mTrip.getBaits(), new PartialListView.InteractionListener() {
            @Override
            public ListManager.Adapter onGetAdapter(ArrayList<UserDefineObject> items) {
                return getBaitsAdapter(items);
            }

            @Override
            public void onClickAllButton(ArrayList<UserDefineObject> items) {
                startPartialListActivity(PartialListActivity.getIntent(getContext(), mTrip.getDisplayName(), LayoutSpecManager.LAYOUT_BAITS, items));
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
        ViewUtils.setVisibility(mAnglersView, mTrip.hasAnglers());
        mAnglersView.setDetail(mTrip.getAnglersAsString());
    }

    private void updateNotesView() {
        ViewUtils.setVisibility(mNotesView, mTrip.hasNotes());
        mNotesView.setDetail(mTrip.getNotesAsString());
    }
}
