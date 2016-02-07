package com.cohenadair.anglerslog.backup;

import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.DialogFragment;
import android.support.v7.app.AlertDialog;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;

/**
 * An ImportFragment is used as a confirmation and progress dialog for importing data from other
 * device platforms.
 *
 * Created by Cohen Adair on 2016-02-07.
 */
public class ImportFragment extends DialogFragment {

    private AlertDialog mAlertDialog;
    private TextView mMessageView;
    private ProgressBar mProgressBar;

    private InteractionListener mCallbacks;

    public interface InteractionListener {
        void onConfirm();
        void onCancel();
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());

        builder.setTitle(R.string.import_confirm);
        builder.setView(getContentView());
        builder.setPositiveButton(R.string.import_name, null);
        builder.setNegativeButton(R.string.button_cancel, getOnClickCancel());

        mAlertDialog = builder.create();
        mAlertDialog.setOnShowListener(getOnShowListener());

        return mAlertDialog;
    }

    private View getContentView() {
        View view = getActivity().getLayoutInflater().inflate(R.layout.dialog_import, null);

        mMessageView = (TextView)view.findViewById(R.id.text_view);
        mMessageView.setText(R.string.import_dialog_message);

        mProgressBar = (ProgressBar)view.findViewById(R.id.progress_bar);
        mProgressBar.setVisibility(View.GONE);

        return view;
    }

    @NonNull
    private View.OnClickListener getOnClickImport() {
        return new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                view.setEnabled(false);
                mProgressBar.setVisibility(View.VISIBLE);

                if (mCallbacks != null)
                    mCallbacks.onConfirm();
            }
        };
    }

    @NonNull
    private DialogInterface.OnClickListener getOnClickCancel() {
        return new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if (mCallbacks != null)
                    mCallbacks.onCancel();
            }
        };
    }

    /**
     * Overrides the default positive button click behavior so the dialog doesn't close until
     * the progress bar is finished.
     *
     * @return The new DialogInterface.OnShowListener.
     */
    @NonNull
    private DialogInterface.OnShowListener getOnShowListener() {
        return new DialogInterface.OnShowListener() {
            @Override
            public void onShow(DialogInterface dialogInterface) {
                Button positive = mAlertDialog.getButton(AlertDialog.BUTTON_POSITIVE);
                positive.setOnClickListener(getOnClickImport());
            }
        };
    }

    public void setCallbacks(InteractionListener callbacks) {
        mCallbacks = callbacks;
    }
}
