package com.cohenadair.anglerslog.trips;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.database.QueryHelper;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.MoreDetailView;
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

    private LinearLayout mCatchesContainer;
    private LinearLayout mLocationsContainer;
    private TitleSubTitleView mTitleView;
    private PropertyDetailView mAnglersView;
    private TextView mNotesView;

    private TextView mCatchesTitle;
    private TextView mLocationsTitle;
    private TextView mTripDetailsTitle;
    private TextView mNotesTitle;

    public TripFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_trip, container, false);

        mCatchesContainer = (LinearLayout)view.findViewById(R.id.catches_container);
        mLocationsContainer = (LinearLayout)view.findViewById(R.id.locations_container);
        mTitleView = (TitleSubTitleView)view.findViewById(R.id.title_view);
        mAnglersView = (PropertyDetailView)view.findViewById(R.id.anglers_view);
        mNotesView = (TextView)view.findViewById(R.id.notes_text_view);

        mCatchesTitle = (TextView)view.findViewById(R.id.title_catches);
        mLocationsTitle = (TextView)view.findViewById(R.id.title_locations);
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

        if (Logbook.getTripCount() <= 0) {
            View container = getView();
            if (container != null)
                container.setVisibility(View.GONE);
            return;
        }

        setItemId(id);
        mTrip = Logbook.getTrip(id);

        if (mTrip == null)
            return;

        updateTitleView();
        updateCatchesView();
        updateLocationsView();
        updateAnglersView();
        updateNotesView();

        if (!mTrip.hasAnglers())
            mTripDetailsTitle.setVisibility(View.GONE);
    }

    private void updateTitleView() {
        String dateString = mTrip.getDateAsString(getContext());
        boolean nameIsNull = mTrip.getName() == null;

        mTitleView.setTitle(nameIsNull ? dateString : mTrip.getName());
        mTitleView.setSubtitle(nameIsNull ? "" : dateString);

        if (nameIsNull)
            mTitleView.hideSubtitle();
    }

    private interface OnUpdateMoreDetailInterface {
        String onGetTitle(UserDefineObject object);
        String onGetSubtitle(UserDefineObject object);
        View.OnClickListener onGetDetailButtonClickListener(UUID id);
    }

    private void updateMoreDetailViews(ArrayList<UserDefineObject> objects, View titleView, LinearLayout container, OnUpdateMoreDetailInterface callbacks) {
        boolean hasObjects = objects.size() > 0;
        Utils.toggleVisibility(titleView, hasObjects);
        Utils.toggleVisibility(container, hasObjects);

        for (UserDefineObject object : objects) {
            MoreDetailView catchView = new MoreDetailView(getContext());
            catchView.setTitle(callbacks.onGetTitle(object));
            catchView.useDefaultStyle();

            if (callbacks.onGetSubtitle(object) == null)
                catchView.hideSubtitle();
            else
                catchView.setSubtitle(callbacks.onGetSubtitle(object));

            if (objects.size() == 1)
                catchView.useNoSpacing();
            else
                catchView.useDefaultSpacing();

            catchView.setOnClickDetailButton(callbacks.onGetDetailButtonClickListener(object.getId()));
            container.addView(catchView);
        }
    }

    private void updateCatchesView() {
        updateMoreDetailViews(mTrip.getCatches(), mCatchesTitle, mCatchesContainer, new OnUpdateMoreDetailInterface() {
            @Override
            public String onGetTitle(UserDefineObject object) {
                return ((Catch)object).getSpeciesAsString();
            }

            @Override
            public String onGetSubtitle(UserDefineObject object) {
                return ((Catch)object).getDateTimeAsString();
            }

            @Override
            public View.OnClickListener onGetDetailButtonClickListener(final UUID id) {
                return new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        startDetailActivity(LayoutSpecManager.LAYOUT_CATCHES, id);
                    }
                };
            }
        });
    }

    private void updateLocationsView() {
        updateMoreDetailViews(mTrip.getLocations(), mLocationsTitle, mLocationsContainer, new OnUpdateMoreDetailInterface() {
            @Override
            public String onGetTitle(UserDefineObject object) {
                return object.getName();
            }

            @Override
            public String onGetSubtitle(UserDefineObject object) {
                return QueryHelper.queryTripsLocationCatchCount(mTrip, (Location)object) + " " + getResources().getString(R.string.trip_catches);
            }

            @Override
            public View.OnClickListener onGetDetailButtonClickListener(final UUID id) {
                return new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        startDetailActivity(LayoutSpecManager.LAYOUT_LOCATIONS, id);
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
        boolean hasNotes = mTrip.getNotes() != null;
        Utils.toggleVisibility(mNotesTitle, hasNotes);
        Utils.toggleVisibility(mNotesView, hasNotes);
        mNotesView.setText(mTrip.getNotesAsString());
    }
}
