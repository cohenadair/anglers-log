package com.cohenadair.anglerslog.fragments;

import android.app.Dialog;
import android.app.TimePickerDialog;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.DialogFragment;
import android.text.format.DateFormat;

import java.util.Calendar;
import java.util.Date;

/**
 * The TimePickerFragment is used for selecting time.
 * Created by Cohen Adair on 2015-09-30.
 */
public class TimePickerFragment extends DialogFragment {

    private TimePickerDialog.OnTimeSetListener mCallback;
    private Date mInitialDate;

    @Override
    @NonNull
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        final Calendar cal = Calendar.getInstance();

        if (mInitialDate != null)
            cal.setTime(mInitialDate);

        int hour = cal.get(Calendar.HOUR_OF_DAY);
        int minute = cal.get(Calendar.MINUTE);

        return new TimePickerDialog(getActivity(), mCallback, hour, minute, DateFormat.is24HourFormat(getActivity()));
    }

    public void setOnTimeSetListener(TimePickerDialog.OnTimeSetListener callback) {
        mCallback = callback;
    }

    public void setInitialDate(Date initialDate) {
        mInitialDate = initialDate;
    }
}
