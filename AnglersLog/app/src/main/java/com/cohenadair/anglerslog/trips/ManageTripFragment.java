package com.cohenadair.anglerslog.trips;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.fragments.ManagePrimitiveFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.PrimitiveSpecManager;
import com.cohenadair.anglerslog.utilities.UserDefineArrays;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.TextInputView;
import com.cohenadair.anglerslog.views.TitleSubTitleView;

import java.util.ArrayList;
import java.util.Date;

/**
 * The ManageTripFragment is used to add and edit trips.
 * Created by Cohen Adair on 2016-01-20.
 */
public class ManageTripFragment extends ManageContentFragment {

    private TextInputView mNameView;
    private TextInputView mNotesView;
    private TitleSubTitleView mStartDateView;
    private TitleSubTitleView mEndDateView;
    private TitleSubTitleView mCatchesView;
    private TitleSubTitleView mLocationsView;
    private TitleSubTitleView mAnglersView;

    /**
     * Used so there is no database interaction until the user saves their changes.
     */
    private ArrayList<UserDefineObject> mSelectedAnglers;
    private ArrayList<UserDefineObject> mSelectedCatches;
    private ArrayList<UserDefineObject> mSelectedLocations;

    private ArrayList<View> mCatchesViews;
    private ArrayList<View> mLocationsViews;

    private boolean mDateChanged = false;

    public ManageTripFragment() {
        // Required empty public constructor
    }

    private Trip getNewTrip() {
        return (Trip)getNewObject();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage_trip, container, false);

        initNameView(view);
        initNotesView(view);
        initStartDateView(view);
        initEndDateView(view);
        initCatchesView(view);
        initLocationsView(view);
        initAnglersView(view);

        initSelectedAnglers();
        initSelectedCatches();
        initSelectedLocations();

        return view;
    }

    @Override
    public ManageObjectSpec getManageObjectSpec() {
        return new ManageObjectSpec(R.string.error_trip, R.string.success_trip, R.string.error_trip_edit, R.string.success_trip_edit, new ManageInterface() {
            @Override
            public boolean onEdit() {
                return Logbook.editTrip(getEditingId(), getNewTrip());
            }

            @Override
            public boolean onAdd() {
                return Logbook.addTrip(getNewTrip());
            }
        });
    }

    @Override
    public void initSubclassObject() {
        initObject(new InitializeInterface() {
            @Override
            public UserDefineObject onGetOldObject() {
                return Logbook.getTrip(getEditingId());
            }

            @Override
            public UserDefineObject onGetNewEditObject(UserDefineObject oldObject) {
                Trip trip = new Trip((Trip) oldObject, true);
                mSelectedLocations = trip.getLocations();
                mSelectedAnglers = trip.getAnglers();
                mSelectedCatches = trip.getCatches();
                return trip;
            }

            @Override
            public UserDefineObject onGetNewBlankObject() {
                return new Trip();
            }
        });
    }

    @Override
    public boolean verifyUserInput() {
        // make sure the new trip doesn't overlap any existing trips
        if ((mDateChanged || !isEditing()) && Logbook.tripExists(getNewTrip())) {
            Utils.showErrorAlert(getActivity(), R.string.error_trip_date);
            return false;
        }

        // start and end dates are set after the DatePickerFragment is closed

        // input properties
        getNewTrip().setName(mNameView.isInputEmpty() ? null : mNameView.getInputText());
        getNewTrip().setNotes(mNotesView.isInputEmpty() ? null : mNotesView.getInputText());

        // update properties that interact directly with the database
        getNewTrip().setAnglers(mSelectedAnglers);
        getNewTrip().setCatches(mSelectedCatches);
        getNewTrip().setLocations(mSelectedLocations);

        return true;
    }

    //region View Updating
    @Override
    public void updateViews() {
        mNameView.setInputText(getNewTrip().getNameAsString());
        mStartDateView.setSubtitle(getNewTrip().getStartDateAsString());
        mEndDateView.setSubtitle(getNewTrip().getEndDateAsString());
        mAnglersView.setSubtitle(UserDefineArrays.namesAsString(mSelectedAnglers));
        mNotesView.setInputText(getNewTrip().getNotesAsString());

        updateCatchesViews();
        updateLocationsViews();
    }

    private void updateCatchesViews() {
        removeViews(mCatchesViews);
        for (UserDefineObject object : mSelectedCatches) {
            Catch aCatch = (Catch)object;
            // TODO create and add view here
        }
    }

    private void updateLocationsViews() {
        removeViews(mLocationsViews);
        for (UserDefineObject object : mSelectedLocations) {
            Location location = (Location)object;
            // TODO create and add view here
        }
    }

    /**
     * Removes the given View objects from their parent.
     * @param views The View objects to remove.
     */
    private void removeViews(ArrayList<View> views) {
        for (View view : views) {
            ViewGroup parent = ((ViewGroup)view.getParent());
            if (parent != null)
                parent.removeView(view);
        }
    }
    //endregion

    //region View Initializing
    public void initNameView(View view) {
        mNameView = (TextInputView)view.findViewById(R.id.name_view);
    }

    public void initNotesView(View view) {
        mNotesView = (TextInputView)view.findViewById(R.id.notes_view);
    }

    public void initAnglersView(View view) {
        final ManagePrimitiveFragment.OnDismissInterface onDismissInterface = new ManagePrimitiveFragment.OnDismissInterface() {
            @Override
            public void onDismiss(ArrayList<UserDefineObject> selectedItems) {
                mSelectedAnglers = selectedItems;
                mAnglersView.setSubtitle(UserDefineArrays.namesAsString(mSelectedAnglers));
            }
        };

        mAnglersView = (TitleSubTitleView)view.findViewById(R.id.anglers_view);
        mAnglersView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showPrimitiveDialog(PrimitiveSpecManager.ANGLERS, true, mSelectedAnglers, onDismissInterface);
            }
        });
    }

    public void initStartDateView(View view) {
        mStartDateView = (TitleSubTitleView)view.findViewById(R.id.start_date_view);
        mStartDateView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showDatePickerFragment(getNewTrip().getStartDate(), new DateTimePickerInterface() {
                    @Override
                    public void onFinish(Date date) {
                        if (date.after(getNewTrip().getEndDate())) {
                            Utils.showErrorAlert(getActivity(), R.string.error_trip_date_start);
                            return;
                        }

                        getNewTrip().setStartDate(date);
                        mStartDateView.setSubtitle(getNewTrip().getStartDateAsString());
                        mDateChanged = isEditing();
                    }
                });
            }
        });
    }

    public void initEndDateView(View view) {
        mEndDateView = (TitleSubTitleView)view.findViewById(R.id.end_date_view);
        mEndDateView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showDatePickerFragment(getNewTrip().getEndDate(), new DateTimePickerInterface() {
                    @Override
                    public void onFinish(Date date) {
                        if (date.before(getNewTrip().getStartDate())) {
                            Utils.showErrorAlert(getActivity(), R.string.error_trip_date_end);
                            return;
                        }

                        getNewTrip().setEndDate(date);
                        mEndDateView.setSubtitle(getNewTrip().getEndDateAsString());
                        mDateChanged = isEditing();
                    }
                });
            }
        });
    }

    public void initCatchesView(View view) {
        mCatchesView = (TitleSubTitleView)view.findViewById(R.id.catches_view);
        // TODO catches selection
    }

    public void initLocationsView(View view) {
        mLocationsView = (TitleSubTitleView)view.findViewById(R.id.locations_view);
        // TODO locations selection
    }
    //endregion

    //region Temporary Variable Initializing
    private void initSelectedAnglers() {
        if (mSelectedAnglers == null || !isEditing())
            mSelectedAnglers = new ArrayList<>();
    }

    private void initSelectedCatches() {
        if (mSelectedCatches == null || !isEditing())
            mSelectedCatches = new ArrayList<>();

        if (mCatchesViews == null)
            mCatchesViews = new ArrayList<>();
    }

    private void initSelectedLocations() {
        if (mSelectedLocations == null || !isEditing())
            mSelectedLocations = new ArrayList<>();

        if (mLocationsViews == null)
            mLocationsViews = new ArrayList<>();
    }
    //endregion

}
