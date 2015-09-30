package com.cohenadair.anglerslog.fragments;

import android.app.DatePickerDialog;
import android.app.Dialog;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.DialogFragment;

import java.util.Calendar;

/**
 * The DatePickerFragment is used for date selection.
 * Created by Cohen Adair on 2015-09-30.
 */
public class DatePickerFragment extends DialogFragment {

    private DatePickerDialog.OnDateSetListener mCallback;

    @Override
    @NonNull
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        final Calendar cal = Calendar.getInstance();
        int year = cal.get(Calendar.YEAR);
        int month = cal.get(Calendar.MONTH);
        int day = cal.get(Calendar.DAY_OF_MONTH);

        return new DatePickerDialog(getActivity(), mCallback, year, month, day);
    }

    public void setOnDateSetListener(DatePickerDialog.OnDateSetListener callback) {
        mCallback = callback;
    }
}
