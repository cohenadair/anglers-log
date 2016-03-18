package com.cohenadair.anglerslog.trips;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.CatchListPortionActivity;
import com.cohenadair.anglerslog.catches.CatchListManager;
import com.cohenadair.anglerslog.database.QueryHelper;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.ListManager;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.ListPortionLayout;
import com.cohenadair.anglerslog.views.MoreDetailLayout;
import com.cohenadair.anglerslog.views.PropertyDetailView;
import com.cohenadair.anglerslog.views.TitleSubTitleView;

import java.util.ArrayList;
import java.util.UUID;

/**
 * A {@link DetailFragment} subclass used to show the details of a single
 * {@link com.cohenadair.anglerslog.model.user_defines.Trip}.
 */
public class TripFragment extends DetailFragment {

    private Trip mTrip;

    private LinearLayout mContainer;
    private ListPortionLayout mCatchesContainer;
    private MoreDetailLayout mLocationsContainer;
    private MoreDetailLayout mBaitsContainer;
    private TitleSubTitleView mTitleView;
    private PropertyDetailView mAnglersView;
    private TextView mNotesView;

    private TextView mLocationsTitle;
    private TextView mBaitsTitle;
    private TextView mTripDetailsTitle;
    private TextView mNotesTitle;

    public TripFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_trip, container, false);

        mContainer = (LinearLayout)view.findViewById(R.id.trip_container);

        mCatchesContainer = (ListPortionLayout)view.findViewById(R.id.catches_container);
        mLocationsContainer = (MoreDetailLayout)view.findViewById(R.id.locations_container);
        mBaitsContainer = (MoreDetailLayout)view.findViewById(R.id.baits_container);
        mTitleView = (TitleSubTitleView)view.findViewById(R.id.title_view);
        mAnglersView = (PropertyDetailView)view.findViewById(R.id.anglers_view);
        mNotesView = (TextView)view.findViewById(R.id.notes_text_view);

        mLocationsTitle = (TextView)view.findViewById(R.id.title_locations);
        mBaitsTitle= (TextView)view.findViewById(R.id.title_baits);
        mTripDetailsTitle = (TextView)view.findViewById(R.id.title_trip_details);
        mNotesTitle = (TextView)view.findViewById(R.id.title_notes);

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
            mContainer.setVisibility(View.GONE);
            return;
        }

        setItemId(id);
        mTrip = Logbook.getTrip(id);

        // mBait can be null if in tw-pane view and a bait was removed
        if (mTrip == null) {
            mContainer.setVisibility(View.GONE);
            return;
        }

        mContainer.setVisibility(View.VISIBLE);

        updateTitleView();
        updateCatchesView();
        updateLocationsView();
        updateBaitsView();
        updateAnglersView();
        updateNotesView();

        mTripDetailsTitle.setVisibility(mTrip.hasAnglers() ? View.VISIBLE : View.GONE);
    }

    private void updateTitleView() {
        String dateString = mTrip.getDateAsString(getContext());

        mTitleView.setTitle(mTrip.isNameNull() ? dateString : mTrip.getName());
        mTitleView.setSubtitle(mTrip.isNameNull() ? "" : dateString);

        if (mTrip.isNameNull())
            mTitleView.hideSubtitle();
    }

    private void updateCatchesView() {
        mCatchesContainer.init(null, mTrip.getCatches(), new ListPortionLayout.InteractionListener() {
            @Override
            public ListManager.Adapter onGetAdapter(ArrayList<UserDefineObject> items) {
                return getCatchesAdapter(items);
            }

            @Override
            public void onClickAllButton(ArrayList<UserDefineObject> items) {
                Intent intent = CatchListPortionActivity.getIntent(getContext(), mTrip.getDisplayName(), items);
                startActivity(intent);
            }
        });
    }

    @NonNull
    private ListManager.Adapter getCatchesAdapter(ArrayList<UserDefineObject> items) {
        return new CatchListManager.Adapter(getContext(), items, new OnClickInterface() {
            @Override
            public void onClick(View view, UUID id) {
                startDetailActivity(LayoutSpecManager.LAYOUT_CATCHES, id);
            }
        });
    }

    private void updateLocationsView() {
        mLocationsContainer.init(mLocationsTitle, mTrip.getLocations(), new MoreDetailLayout.OnUpdateItemInterface() {
            @Override
            public String getTitle(UserDefineObject object) {
                return object.getName();
            }

            @Override
            public String getSubtitle(UserDefineObject object) {
                return QueryHelper.queryTripsLocationCatchCount(mTrip, (Location) object) + " " + getResources().getString(R.string.trip_catches);
            }

            @Override
            public View.OnClickListener onClickItemButton(final UUID id) {
                return new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        startDetailActivity(LayoutSpecManager.LAYOUT_LOCATIONS, id);
                    }
                };
            }
        });
    }

    private void updateBaitsView() {
        mBaitsContainer.init(mBaitsTitle, mTrip.getBaits(), new MoreDetailLayout.OnUpdateItemInterface() {
            @Override
            public String getTitle(UserDefineObject object) {
                return object.getName();
            }

            @Override
            public String getSubtitle(UserDefineObject object) {
                return ((Bait)object).getCategoryName();
            }

            @Override
            public View.OnClickListener onClickItemButton(final UUID id) {
                return new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        startDetailActivity(LayoutSpecManager.LAYOUT_BAITS, id);
                    }
                };
            }
        });
    }

    private void updateAnglersView() {
        Utils.toggleVisibility(mAnglersView, mTrip.hasAnglers());
        mAnglersView.setDetail(mTrip.getAnglersAsString());
    }

    private void updateNotesView() {
        boolean hasNotes = mTrip.hasNotes();
        Utils.toggleVisibility(mNotesTitle, hasNotes);
        Utils.toggleVisibility(mNotesView, hasNotes);
        mNotesView.setText(mTrip.getNotesAsString());
    }
}
