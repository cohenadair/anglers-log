package com.cohenadair.anglerslog.utilities;

import android.app.Dialog;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.DialogFragment;
import android.support.v7.app.AlertDialog;

/**
 * The AlertFragment class is a class that wraps an {@link AlertDialog} in a {@link DialogFragment}
 * to prevent closing on device rotation.
 *
 * <pre>{@code
 * new AlertFragment().initWithBuilder(builder).show(manager, null);
 * }</pre>
 *
 * @author Cohen Adair
 */
public class AlertFragment extends DialogFragment {

    private AlertDialog.Builder mBuilder;

    public AlertFragment() {
        // suggested empty Fragment constructor
    }

    public AlertFragment initWithBuilder(AlertDialog.Builder builder) {
        mBuilder = builder;
        return this;
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        if (mBuilder == null)
            throw new RuntimeException("AlertFragment instances must call initWithBuilder(Builder)");

        return mBuilder.create();
    }
}
