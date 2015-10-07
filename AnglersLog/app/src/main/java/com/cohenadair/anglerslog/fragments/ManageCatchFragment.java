package com.cohenadair.anglerslog.fragments;

import android.app.DatePickerDialog;
import android.app.TimePickerDialog;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.DatePicker;
import android.widget.TimePicker;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.utilities.fragment.FragmentData;
import com.cohenadair.anglerslog.views.SelectionView;

import java.util.Calendar;
import java.util.Date;

/**
 * The ManageCatchFragment is used to add and edit catches.
 */
public class ManageCatchFragment extends ManageContentFragment {

    private Catch mNewCatch;
    private Catch mOldCatch;

    private SelectionView mDateView;
    private SelectionView mTimeView;
    private SelectionView mSpeciesView;

    public ManageCatchFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage_catch, container, false);

        initDateTimeView(view);
        initSpeciesView(view);

        return view;
    }

    /**
     * Needed to initialize Catch and editing settings because there is ever only one instance of
     * this fragment that is reused throughout the application's lifecycle.
     */
    @Override
    public void onResume() {
        super.onResume();

        if (isEditing()) {
            mOldCatch = Logbook.catchAtPos(getEditingPosition());
            mNewCatch = mOldCatch.clone();
        } else {
            mOldCatch = null;
            mNewCatch = new Catch(new Date());
        }

        updateViews();
    }

    @Override
    public boolean addObjectToLogbook() {
        if (verifyUserInput()) {
            if (isEditing()) {
                Logbook.editCatchAtPos(getEditingPosition(), mNewCatch);
                Utils.showToast(getActivity(), R.string.success_catch_edit);
                return true;
            } else {
                // add catch
                boolean success = Logbook.addCatch(mNewCatch);
                int msgId = success ? R.string.success_catch : R.string.error_catch;
                Utils.showToast(getActivity(), msgId);
                return success;
            }
        }
        return false;
    }

    /**
     * Validates the user's input.
     * @return True if the input is valid, false otherwise.
     */
    private boolean verifyUserInput() {
        // date and time
        if (Logbook.catchDated(mNewCatch.getDate()) != null && !isEditing()) {
            Utils.showErrorAlert(getActivity(), R.string.error_catch_date);
            return false;
        }

        // species
        if (mNewCatch.getSpecies() == null) {
            Utils.showErrorAlert(getActivity(), R.string.error_catch_species);
            return false;
        }

        return true;
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

    private void initSpeciesView(View view) {
        mSpeciesView = (SelectionView)view.findViewById(R.id.species_layout);
        mSpeciesView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final ManagePrimitiveFragment fragment = ManagePrimitiveFragment.newInstance(FragmentData.PRIMITIVE_SPECIES);

                fragment.setOnDismissInterface(new ManagePrimitiveFragment.OnDismissInterface() {
                    @Override
                    public void onDismiss(UserDefineObject selectedItem) {
                        mNewCatch.setSpecies((Species) selectedItem);
                        mSpeciesView.setSubtitle(mNewCatch.speciesAsString());
                    }
                });

                fragment.show(getFragmentManager(), "dialog");
            }
        });
    }

    /**
     * Updates the date view's text.
     * @param date The date to display in the view. Only looks at the date portion.
     */
    private void updateDateView(Date date) {
        mNewCatch.setDate(date);
        mDateView.setSubtitle(mNewCatch.dateAsString());
    }

    /**
     * Updates the time view's text.
     * @param date The date to display in the view. Only looks at the time portion.
     */
    private void updateTimeView(Date date) {
        mNewCatch.setDate(date);
        mTimeView.setSubtitle(mNewCatch.timeAsString());
    }

    /**
     * Update the different views based on the current Catch object to display.
     */
    private void updateViews() {
        mDateView.setSubtitle(mNewCatch.dateAsString());
        mTimeView.setSubtitle(mNewCatch.timeAsString());

        if (mNewCatch.getSpecies() != null)
            mSpeciesView.setSubtitle(mNewCatch.speciesAsString());
    }

    /**
     * Resets the calendar's time to the current catch's time.
     */
    private void updateCalendar() {
        Calendar.getInstance().setTime(mNewCatch.getDate());
    }
    //endregion

}
