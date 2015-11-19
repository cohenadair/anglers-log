package com.cohenadair.anglerslog.catches;

import android.app.DatePickerDialog;
import android.app.TimePickerDialog;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.DatePicker;
import android.widget.TimePicker;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.DatePickerFragment;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.fragments.ManagePrimitiveFragment;
import com.cohenadair.anglerslog.fragments.TimePickerFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.PrimitiveSpecManager;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.SelectionView;

import java.util.Calendar;
import java.util.Date;

/**
 * The ManageBaitFragment is used to add and edit catches.
 */
public class ManageCatchFragment extends ManageContentFragment {

    private SelectionView mDateView;
    private SelectionView mTimeView;
    private SelectionView mSpeciesView;
    private SelectionView mBaitView;

    public ManageCatchFragment() {
        // Required empty public constructor
    }

    private Catch getNewCatch() {
        return (Catch)getNewObject();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage_catch, container, false);

        initDateTimeView(view);
        initSpeciesView(view);
        initBaitView(view);
        initSelectPhotosView(view);

        initSubclassObject();

        return view;
    }

    @Override
    public ManageObjectSpec getManageObjectSpec() {
        return new ManageObjectSpec(R.string.error_catch, R.string.success_catch, R.string.error_catch_edit, R.string.success_catch_edit, new ManageInterface() {
            @Override
            public boolean onEdit() {
                return Logbook.editCatch(getEditingId(), getNewCatch());
            }

            @Override
            public boolean onAdd() {
                return Logbook.addCatch(getNewCatch());
            }
        });
    }

    @Override
    public void initSubclassObject() {
        initObject(new InitializeInterface() {
            @Override
            public UserDefineObject onGetOldObject() {
                return Logbook.getCatch(getEditingId());
            }

            @Override
            public UserDefineObject onGetNewEditObject(UserDefineObject oldObject) {
                return new Catch((Catch)oldObject, true);
            }

            @Override
            public UserDefineObject onGetNewBlankObject() {
                return new Catch(new Date());
            }
        });
    }

    @Override
    public boolean verifyUserInput() {
        // species
        if (getNewCatch().getSpecies() == null) {
            Utils.showErrorAlert(getActivity(), R.string.error_catch_species);
            return false;
        }

        return true;
    }

    @Override
    public void updateViews() {
        mDateView.setSubtitle(getNewCatch().getDateAsString());
        mTimeView.setSubtitle(getNewCatch().getTimeAsString());
        mSpeciesView.setSubtitle(getNewCatch().getSpecies() != null ? getNewCatch().getSpeciesAsString() : "");
    }

    //region Date & Time
    private void initDateTimeView(View view) {
        mDateView = (SelectionView)view.findViewById(R.id.date_layout);
        mDateView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                DatePickerFragment datePicker = new DatePickerFragment();
                datePicker.setOnDateSetListener(new DatePickerDialog.OnDateSetListener() {
                    @Override
                    public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                        updateCalendar();
                        Calendar c = Calendar.getInstance();
                        int hours = c.get(Calendar.HOUR_OF_DAY);
                        int minutes = c.get(Calendar.MINUTE);
                        c.set(year, monthOfYear, dayOfMonth, hours, minutes);
                        updateDateView(c.getTime());
                    }
                });
                datePicker.show(getFragmentManager(), "datePicker");
            }
        });

        mTimeView = (SelectionView)view.findViewById(R.id.time_layout);
        mTimeView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                TimePickerFragment timePicker = new TimePickerFragment();
                timePicker.setOnTimeSetListener(new TimePickerDialog.OnTimeSetListener() {
                    @Override
                    public void onTimeSet(TimePicker view, int hourOfDay, int minute) {
                        updateCalendar();
                        Calendar c = Calendar.getInstance();
                        int year = c.get(Calendar.YEAR);
                        int month = c.get(Calendar.MONTH);
                        int day = c.get(Calendar.DAY_OF_MONTH);
                        c.set(year, month, day, hourOfDay, minute);
                        updateTimeView(c.getTime());
                    }
                });
                timePicker.show(getFragmentManager(), "timePicker");
            }
        });
    }

    /**
     * Updates the date view's text.
     * @param date The date to display in the view. Only looks at the date portion.
     */
    private void updateDateView(Date date) {
        getNewCatch().setDate(date);
        mDateView.setSubtitle(getNewCatch().getDateAsString());
    }

    /**
     * Updates the time view's text.
     * @param date The date to display in the view. Only looks at the time portion.
     */
    private void updateTimeView(Date date) {
        getNewCatch().setDate(date);
        mTimeView.setSubtitle(getNewCatch().getTimeAsString());
    }

    /**
     * Resets the calendar's time to the current catch's time.
     */
    private void updateCalendar() {
        Calendar.getInstance().setTime(getNewCatch().getDate());
    }
    //endregion

    private void initSpeciesView(View view) {
        mSpeciesView = (SelectionView)view.findViewById(R.id.species_layout);
        mSpeciesView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final ManagePrimitiveFragment fragment = ManagePrimitiveFragment.newInstance(PrimitiveSpecManager.SPECIES);

                fragment.setOnDismissInterface(new ManagePrimitiveFragment.OnDismissInterface() {
                    @Override
                    public void onDismiss(UserDefineObject selectedItem) {
                        getNewCatch().setSpecies((Species) selectedItem);
                        mSpeciesView.setSubtitle(getNewCatch().getSpeciesAsString());
                    }
                });

                fragment.show(getFragmentManager(), "dialog");
            }
        });
    }

    private void initBaitView(View view) {
        mBaitView = (SelectionView)view.findViewById(R.id.bait_layout);
        mBaitView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startSelectionActivity(LayoutSpecManager.LAYOUT_BAITS);
            }
        });
    }

}
