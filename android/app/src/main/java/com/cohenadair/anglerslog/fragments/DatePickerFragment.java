package com.cohenadair.anglerslog.fragments;

import android.app.DatePickerDialog;
import android.app.Dialog;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.DialogFragment;

import java.util.Calendar;
import java.util.Date;

/**
 * The DatePickerFragment is used for date selection.
 * @author Cohen Adair
 */
public class DatePickerFragment extends DialogFragment {

    private DatePickerDialog.OnDateSetListener mCallback;
    private Date mInitialDate;

    @Override
    @NonNull
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        final Calendar cal = Calendar.getInstance();

        if (mInitialDate != null)
            cal.setTime(mInitialDate);

        int year = cal.get(Calendar.YEAR);
        int month = cal.get(Calendar.MONTH);
        int day = cal.get(Calendar.DAY_OF_MONTH);

        return new DatePickerDialog(getActivity(), mCallback, year, month, day);
    }

    public void setOnDateSetListener(DatePickerDialog.OnDateSetListener callback) {
        mCallback = callback;
    }

    public void setInitialDate(Date initialDate) {
        mInitialDate = initialDate;
    }
}
