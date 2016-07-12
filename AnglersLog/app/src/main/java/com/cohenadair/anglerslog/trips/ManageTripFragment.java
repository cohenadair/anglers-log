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
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.model.utilities.UserDefineArrays;
import com.cohenadair.anglerslog.utilities.AlertUtils;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.PrimitiveSpecManager;
import com.cohenadair.anglerslog.utilities.ViewUtils;
import com.cohenadair.anglerslog.views.InputButtonView;
import com.cohenadair.anglerslog.views.InputTextView;

import java.util.ArrayList;
import java.util.Date;
import java.util.UUID;

/**
 * The ManageTripFragment is used to add and edit trips.
 * @author Cohen Adair
 */
public class ManageTripFragment extends ManageContentFragment {

    private InputTextView mNameView;
    private InputTextView mNotesView;
    private InputButtonView mStartDateView;
    private InputButtonView mEndDateView;
    private InputButtonView mCatchesView;
    private InputButtonView mLocationsView;
    private InputButtonView mAnglersView;

    /**
     * Used so there is no database interaction until the user saves their changes.
     */
    private ArrayList<UUID> mSelectedAnglersIds;
    private ArrayList<UUID> mSelectedCatchesIds;
    private ArrayList<UUID> mSelectedLocationsIds;

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
    public void onResume() {
        super.onResume();
        initInputListeners(); // this MUST be called in onResume()
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
                mSelectedLocationsIds = UserDefineArrays.asIdArray(trip.getLocations());
                mSelectedAnglersIds = UserDefineArrays.asIdArray(trip.getAnglers());
                mSelectedCatchesIds = UserDefineArrays.asIdArray(trip.getCatches());
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
            AlertUtils.showError(getActivity(), R.string.error_trip_date);
            return false;
        }

        // start and end dates are set after the DatePickerFragment is closed
        // input properties are set in a onTextChanged listener

        // update properties that interact directly with the database
        getNewTrip().setAnglers(getSelectedAnglers());
        getNewTrip().setCatches(getSelectedCatches());
        getNewTrip().setLocations(getSelectedLocations());

        return true;
    }

    //region View Updating
    @Override
    public void updateViews() {
        mNameView.setInputText(getNewTrip().getNameAsString());
        mStartDateView.setPrimaryButtonText(getNewTrip().getStartDateAsString());
        mEndDateView.setPrimaryButtonText(getNewTrip().getEndDateAsString());
        mAnglersView.setPrimaryButtonText(UserDefineArrays.namesAsString(getSelectedAnglers()));
        mNotesView.setInputText(getNewTrip().getNotesAsString());

        updateCatchesViews();
        updateLocationsViews();
    }

    private void updateCatchesViews() {
        removeViews(mCatchesViews);
        mCatchesView.setPrimaryButtonText(UserDefineArrays.propertiesAsString(getSelectedCatches(), new UserDefineArrays.OnGetPropertyInterface() {
            @Override
            public String onGetProperty(UserDefineObject object) {
                return ((Catch) object).getSpeciesAsString();
            }
        }));
    }

    private void updateLocationsViews() {
        removeViews(mLocationsViews);
        mLocationsView.setPrimaryButtonText(UserDefineArrays.namesAsString(getSelectedLocations()));
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
        mNameView = (InputTextView)view.findViewById(R.id.name_view);
    }

    public void initNotesView(View view) {
        mNotesView = (InputTextView)view.findViewById(R.id.notes_view);
    }

    public void initAnglersView(View view) {
        final ManagePrimitiveFragment.OnDismissInterface onDismissInterface = new ManagePrimitiveFragment.OnDismissInterface() {
            @Override
            public void onDismiss(ArrayList<UUID> selectedIds) {
                mSelectedAnglersIds = selectedIds;
                mAnglersView.setPrimaryButtonText(UserDefineArrays.namesAsString(getSelectedAnglers()));
            }
        };

        mAnglersView = (InputButtonView)view.findViewById(R.id.anglers_view);
        mAnglersView.setOnClickPrimaryButton(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showPrimitiveDialog(PrimitiveSpecManager.ANGLERS, true, mSelectedAnglersIds, onDismissInterface);
            }
        });
    }

    public void initStartDateView(View view) {
        mStartDateView = (InputButtonView)view.findViewById(R.id.start_date_view);
        mStartDateView.setOnClickPrimaryButton(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showDatePickerFragment(getNewTrip().getStartDate(), new DateTimePickerInterface() {
                    @Override
                    public void onFinish(Date date) {
                        if (date.after(getNewTrip().getEndDate())) {
                            AlertUtils.showError(getActivity(), R.string.error_trip_date_start);
                            return;
                        }

                        getNewTrip().setStartDate(date);
                        mStartDateView.setPrimaryButtonText(getNewTrip().getStartDateAsString());
                        mDateChanged = isEditing();
                    }
                });
            }
        });
    }

    public void initEndDateView(View view) {
        mEndDateView = (InputButtonView)view.findViewById(R.id.end_date_view);
        mEndDateView.setOnClickPrimaryButton(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showDatePickerFragment(getNewTrip().getEndDate(), new DateTimePickerInterface() {
                    @Override
                    public void onFinish(Date date) {
                        if (date.before(getNewTrip().getStartDate())) {
                            AlertUtils.showError(getActivity(), R.string.error_trip_date_end);
                            return;
                        }

                        getNewTrip().setEndDate(date);
                        mEndDateView.setPrimaryButtonText(getNewTrip().getEndDateAsString());
                        mDateChanged = isEditing();
                    }
                });
            }
        });
    }

    public void initCatchesView(View view) {
        mCatchesView = (InputButtonView)view.findViewById(R.id.catches_view);
        mCatchesView.setOnClickPrimaryButton(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startSelectionActivity(LayoutSpecManager.LAYOUT_CATCHES, false, true, UserDefineArrays.idsAsStrings(mSelectedCatchesIds), new OnSelectionActivityResult() {
                    @Override
                    public void onSelect(ArrayList<String> ids) {
                        mSelectedCatchesIds = UserDefineArrays.stringsAsIds(ids);
                    }
                });
            }
        });
    }

    public void initLocationsView(View view) {
        mLocationsView = (InputButtonView)view.findViewById(R.id.locations_view);
        mLocationsView.setOnClickPrimaryButton(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startSelectionActivity(LayoutSpecManager.LAYOUT_LOCATIONS, true, true, UserDefineArrays.idsAsStrings(mSelectedLocationsIds), new OnSelectionActivityResult() {
                    @Override
                    public void onSelect(ArrayList<String> ids) {
                        mSelectedLocationsIds = UserDefineArrays.stringsAsIds(ids);
                    }
                });
            }
        });
    }

    /**
     * {@link android.text.TextWatcher} interfaces must be added to EditText views in onResume().
     * Android tries to restore Fragment states if possible which causes the onTextChanged event
     * to fire and will likely result in a Runtime Exception.
     */
    private void initInputListeners() {
        mNameView.addOnInputTextChangedListener(ViewUtils.onTextChangedListener(new ViewUtils.OnTextChangedListener() {
            @Override
            public void onTextChanged(String newText) {
                getNewTrip().setName(newText);
            }
        }));

        mNotesView.addOnInputTextChangedListener(ViewUtils.onTextChangedListener(new ViewUtils.OnTextChangedListener() {
            @Override
            public void onTextChanged(String newText) {
                getNewTrip().setNotes(newText);
            }
        }));
    }
    //endregion

    //region Temporary Variable Initializing
    private void initSelectedAnglers() {
        if (mSelectedAnglersIds == null || !isEditing())
            mSelectedAnglersIds = new ArrayList<>();
    }

    private void initSelectedCatches() {
        if (mSelectedCatchesIds == null || !isEditing())
            mSelectedCatchesIds = new ArrayList<>();

        if (mCatchesViews == null)
            mCatchesViews = new ArrayList<>();
    }

    private void initSelectedLocations() {
        if (mSelectedLocationsIds == null || !isEditing())
            mSelectedLocationsIds = new ArrayList<>();

        if (mLocationsViews == null)
            mLocationsViews = new ArrayList<>();
    }
    //endregion

    private ArrayList<UserDefineObject> getSelectedAnglers() {
        return UserDefineArrays.objectsFromIds(mSelectedAnglersIds, new UserDefineArrays.OnConvertInterface() {
            @Override
            public UserDefineObject onGetObject(String idStr) {
                return Logbook.getAngler(UUID.fromString(idStr));
            }
        });
    }

    private ArrayList<UserDefineObject> getSelectedCatches() {
        return UserDefineArrays.objectsFromIds(mSelectedCatchesIds, new UserDefineArrays.OnConvertInterface() {
            @Override
            public UserDefineObject onGetObject(String idStr) {
                return Logbook.getCatch(UUID.fromString(idStr));
            }
        });
    }

    private ArrayList<UserDefineObject> getSelectedLocations() {
        return UserDefineArrays.objectsFromIds(mSelectedLocationsIds, new UserDefineArrays.OnConvertInterface() {
            @Override
            public UserDefineObject onGetObject(String idStr) {
                return Logbook.getLocation(UUID.fromString(idStr));
            }
        });
    }

}
