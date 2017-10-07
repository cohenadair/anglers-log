package com.cohenadair.anglerslog.fragments;

import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.LayoutSpecActivity;

import java.util.List;

/**
 * The ManageFragment is used for add and edit views for the various user defines.
 * @author Cohen Adair
 */
public class ManageFragment extends DialogFragment {

    private static final String TAG_CONTENT_FRAGMENT = "content_fragment";

    private int mTitleId = -1;
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

        // for tablet layouts - shown as a dialog
        Dialog dialog = getDialog();
        if (dialog != null) {
            Window window = dialog.getWindow();
            if (window != null) {
                window.requestFeature(Window.FEATURE_NO_TITLE);
                window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
            }
        }

        // add the actual content to the scroll view
        setDialogTitle(getRealActivity().getViewTitle());

        if (getChildFragmentManager().findFragmentByTag(TAG_CONTENT_FRAGMENT) == null)
            getChildFragmentManager().beginTransaction()
                    .replace(R.id.content_scroll_view, mContentFragment, TAG_CONTENT_FRAGMENT)
                    .commit();

        initToolbar(view);

        return view;
    }

    public void setTitle(int resId) {
        mTitleId = resId;
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
    public void onStart() {
        super.onStart();

        Dialog dialog = getDialog();
        if (dialog != null) {
            Window window = dialog.getWindow();
            if (window != null) {
                dialog.getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT);
            }
        }
    }

    /**
     * Iterates over all children fragments.
     */
    private interface ChildFragmentIterationListener {
        void callMethod(Fragment fragment);
    }

    private void iterateChildFragments(ChildFragmentIterationListener callbacks) {
        List<Fragment> fragments = getChildFragmentManager().getFragments();
        if (fragments != null)
            for (Fragment fragment : fragments)
                if (fragment != null)
                    callbacks.callMethod(fragment);
    }

    /**
     * Required as an Android bug workaround. {@link Fragment#onRequestPermissionsResult(int, String[], int[])}
     * calls aren't passed to child fragments.
     */
    @Override
    public void onRequestPermissionsResult(final int requestCode, @NonNull final String[] permissions, @NonNull final int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        iterateChildFragments(new ChildFragmentIterationListener() {
            @Override
            public void callMethod(Fragment fragment) {
                fragment.onRequestPermissionsResult(requestCode, permissions, grantResults);
            }
        });
    }

    /**
     * Required as an Android bug workaround. {@link Fragment#onActivityResult(int, int, Intent)}
     * calls aren't passed to child fragments.
     */
    @Override
    public void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        iterateChildFragments(new ChildFragmentIterationListener() {
            @Override
            public void callMethod(Fragment fragment) {
                fragment.onActivityResult(requestCode, resultCode, data);
            }
        });
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);

        if (isVisible()) {
            menu.clear();
            inflater.inflate(R.menu.menu_done, menu);
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == R.id.action_confirm) {
            onClickSave();
            return true;
        }

        return super.onOptionsItemSelected(item);
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

    public boolean onClickSave() {
        if (mContentFragment.addObjectToLogbook()) {
            mCallbacks.onManageDismiss(closeDialog());
            mContentFragment.onDismiss();
            return true;
        }

        return false;
    }

    private void initToolbar(View view) {
        LinearLayout toolbar = (LinearLayout)view.findViewById(R.id.toolbar_view);

        // if not shown as a dialog, hide the toolbar as the actual activity's toolbar is used
        if (getDialog() == null) {
            toolbar.setVisibility(View.GONE);
            return;
        }

        TextView title = (TextView)view.findViewById(R.id.title_text_view);
        title.setText(mTitleId == -1 ? getRealActivity().getViewTitle() : getResources().getString(mTitleId));

        ImageButton saveButton = (ImageButton)view.findViewById(R.id.done_button);
        saveButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onClickSave();
            }
        });

        ImageButton backButton = (ImageButton)view.findViewById(R.id.back_button);
        backButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                closeDialog();
            }
        });
    }
}
