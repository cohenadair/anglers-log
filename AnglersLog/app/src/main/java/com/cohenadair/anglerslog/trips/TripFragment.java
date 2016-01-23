package com.cohenadair.anglerslog.trips;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.UserDefineArrays;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.PropertyDetailView;
import com.cohenadair.anglerslog.views.TitleSubTitleView;

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

    private void updateCatchesView() {
        boolean hasCatches = mTrip.hasCatches();
        Utils.toggleVisibility(mCatchesTitle, hasCatches);
        Utils.toggleVisibility(mCatchesContainer, hasCatches);

        // TODO create and add catch views to mCatchesContainer

        TextView temp = new TextView(getContext());
        temp.setText(UserDefineArrays.propertiesAsString(mTrip.getCatches(), new UserDefineArrays.OnGetPropertyInterface() {
            @Override
            public String onGetProperty(UserDefineObject object) {
                return ((Catch)object).getSpeciesAsString();
            }
        }));
        mCatchesContainer.addView(temp);
    }

    private void updateLocationsView() {
        boolean hasLocations = mTrip.hasLocations();
        Utils.toggleVisibility(mLocationsTitle, hasLocations);
        Utils.toggleVisibility(mLocationsContainer, hasLocations);

        // TODO create and add catch views to mLocationsContainer

        TextView temp = new TextView(getContext());
        temp.setText(UserDefineArrays.namesAsString(mTrip.getLocations()));
        mLocationsContainer.addView(temp);
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
