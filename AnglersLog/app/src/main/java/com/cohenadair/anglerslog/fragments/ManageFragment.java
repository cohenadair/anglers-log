package com.cohenadair.anglerslog.fragments;

import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.fragment.LayoutController;

import java.util.List;

/**
 * The ManageFragment is used for add and edit views for the various user defines.
 */
public class ManageFragment extends DialogFragment {

    private static final String CONTENT_FRAGMENT = "content_fragment";

    //region Callback Interface
    private InteractionListener mCallbacks;

    /**
     * Must be implemented by the fragment's Activity.
     */
    public interface InteractionListener {
        void onManageCancel();
        void onManageConfirm();
    }
    //endregion

    // set by child fragments
    private OnChildCancelInterface mOnChildCancelInterface;

    public interface OnChildCancelInterface {
        void onCancel();
    }

    public ManageFragment() {

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage, container, false);

        Button cancelButton = (Button)view.findViewById(R.id.cancel_button);
        cancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mOnChildCancelInterface != null)
                    mOnChildCancelInterface.onCancel();

                mCallbacks.onManageCancel();
                closeDialog();
            }
        });

        Button saveButton = (Button)view.findViewById(R.id.confirm_button);
        saveButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ManageContentFragment fragment = LayoutController.getManageContentFragment();

                if (fragment.addObjectToLogbook()) {
                    mCallbacks.onManageConfirm();
                    closeDialog();
                }
            }
        });

        // add the actual content to the scroll view
        setDialogTitle(LayoutController.getViewTitle(getContext()));

        if (getChildFragmentManager().findFragmentByTag(CONTENT_FRAGMENT) == null)
            getChildFragmentManager().beginTransaction()
                    .replace(R.id.content_scroll_view, LayoutController.getManageContentFragment(), CONTENT_FRAGMENT)
                    .commit();

        return view;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);

        // make sure the container activity has implemented the callback interface
        try {
            mCallbacks = (InteractionListener)context;
        } catch (ClassCastException e) {
            throw new ClassCastException(context.toString() + " must implement ManageFragment.InteractionListener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mCallbacks = null;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        // pass the onActivityResult calls to the child fragments
        List<Fragment> fragments = getChildFragmentManager().getFragments();
        if (fragments != null)
            for (Fragment fragment : fragments)
                if (fragment != null)
                    fragment.onActivityResult(requestCode, resultCode, data);
    }

    public void setOnChildCancelInterface(OnChildCancelInterface onChildCancelInterface) {
        mOnChildCancelInterface = onChildCancelInterface;
    }

    private void setDialogTitle(String title) {
        Dialog dialog = getDialog();
        if (dialog != null)
            dialog.setTitle(title);
    }

    private void closeDialog() {
        Dialog dialog = getDialog();
        if (dialog != null)
            dialog.dismiss();
    }
}
