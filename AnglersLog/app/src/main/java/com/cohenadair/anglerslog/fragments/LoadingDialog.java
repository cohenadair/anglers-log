package com.cohenadair.anglerslog.fragments;

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
 * A LoadingDialog is used to show loading throughout the application, such as when importing
 * or exporting data.
 *
 * @author Cohen Adair
 */
public class LoadingDialog extends DialogFragment {

    private static final String ARG_TITLE = "arg_title";
    private static final String ARG_POSITIVE_BUTTON = "arg_positive_button";
    private static final String ARG_MESSAGE = "arg_message";

    private AlertDialog mAlertDialog;
    private ProgressBar mProgressBar;

    private InteractionListener mCallbacks;

    public interface InteractionListener {
        void onConfirm();
        void onCancel();
    }

    public static LoadingDialog newInstance(int titleId, int positiveButtonId, int msgId) {
        LoadingDialog fragment = new LoadingDialog();

        Bundle args = new Bundle();
        args.putInt(ARG_TITLE, titleId);
        args.putInt(ARG_POSITIVE_BUTTON, positiveButtonId);
        args.putInt(ARG_MESSAGE, msgId);

        fragment.setArguments(args);
        return fragment;
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());

        builder.setView(getContentView(getArguments()));
        builder.setPositiveButton(getArguments().getInt(ARG_POSITIVE_BUTTON), null);
        builder.setNegativeButton(R.string.button_cancel, getOnClickCancel());

        mAlertDialog = builder.create();
        mAlertDialog.setOnShowListener(getOnShowListener());

        return mAlertDialog;
    }

    private View getContentView(Bundle args) {
        View view = View.inflate(getContext(), R.layout.dialog_loading, null);

        mProgressBar = (ProgressBar)view.findViewById(R.id.progress_bar);
        mProgressBar.setVisibility(View.GONE);

        TextView titleView = (TextView)view.findViewById(R.id.title_text_view);
        titleView.setText(getResources().getString(args.getInt(ARG_TITLE)));

        TextView messageView = (TextView)view.findViewById(R.id.text_view);
        messageView.setText(getResources().getString(args.getInt(ARG_MESSAGE)));

        return view;
    }

    @NonNull
    private View.OnClickListener getOnClickConfirm() {
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
                positive.setOnClickListener(getOnClickConfirm());
            }
        };
    }

    public void setCallbacks(InteractionListener callbacks) {
        mCallbacks = callbacks;
    }
}
