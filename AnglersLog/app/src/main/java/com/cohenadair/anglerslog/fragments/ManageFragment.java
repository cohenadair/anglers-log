package com.cohenadair.anglerslog.fragments;

import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.LayoutSpecActivity;

import java.util.List;

/**
 * The ManageFragment is used for add and edit views for the various user defines.
 */
public class ManageFragment extends DialogFragment {

    private static final String TAG_CONTENT_FRAGMENT = "content_fragment";

    private boolean mNoTitle;
    private InteractionListener mCallbacks;
    private ManageContentFragment mContentFragment;

    /**
     * Must be implemented by the fragment's Activity.
     */
    public interface InteractionListener {
        void onManageDismiss(boolean isDialog);
    }

    public ManageFragment() {

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage, container, false);
        setHasOptionsMenu(true);

        if (mNoTitle && getDialog() != null)
            getDialog().getWindow().requestFeature(Window.FEATURE_NO_TITLE);

        Button saveButton = (Button)view.findViewById(R.id.confirm_button);
        saveButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mContentFragment.addObjectToLogbook()) {
                    mCallbacks.onManageDismiss(closeDialog());
                    mContentFragment.onDismiss();
                }
            }
        });

        // add the actual content to the scroll view
        setDialogTitle(getRealActivity().getViewTitle());

        if (getChildFragmentManager().findFragmentByTag(TAG_CONTENT_FRAGMENT) == null)
            getChildFragmentManager().beginTransaction()
                    .replace(R.id.content_scroll_view, mContentFragment, TAG_CONTENT_FRAGMENT)
                    .commit();

        return view;
    }

    public void setNoTitle(boolean noTitle) {
        mNoTitle = noTitle;
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

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);

        if (isVisible())
            menu.clear();
    }

    public void setContentFragment(ManageContentFragment contentFragment) {
        mContentFragment = contentFragment;
    }

    public ManageContentFragment getContentFragment() {
        return mContentFragment;
    }

    public LayoutSpecActivity getRealActivity() {
        return (LayoutSpecActivity)getActivity();
    }

    private void setDialogTitle(String title) {
        Dialog dialog = getDialog();
        if (dialog != null)
            dialog.setTitle(title);
    }

    private boolean closeDialog() {
        Dialog dialog = getDialog();
        if (dialog != null) {
            dialog.dismiss();
            return true;
        }
        return false;
    }
}
