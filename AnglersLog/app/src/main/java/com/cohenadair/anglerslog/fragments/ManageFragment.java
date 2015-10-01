package com.cohenadair.anglerslog.fragments;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.FragmentTransaction;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.fragment.FragmentData;
import com.cohenadair.anglerslog.utilities.fragment.FragmentInfo;

/**
 * The ManageFragment is used for add and edit views for the various user defines.
 */
public class ManageFragment extends DialogFragment {

    //region Callback Interface
    InteractionListener mCallbacks;

    // callback interface for the fragment's activity
    public interface InteractionListener {
        void onManageCancel();
        void onManageConfirm();
    }
    //endregion

    // used to keep fragment state through attach/detach
    private static final String ARG_FRAGMENT_ID = "arg_fragment_id";

    public static ManageFragment newInstance(int fragmentId) {
        ManageFragment fragment = new ManageFragment();

        // add data id to bundle so save through orientation changes
        Bundle args = new Bundle();
        args.putInt(ManageFragment.ARG_FRAGMENT_ID, fragmentId);

        fragment.setArguments(args);
        return fragment;
    }

    public ManageFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage, container, false);

        int fragmentId = getArguments().getInt(ARG_FRAGMENT_ID);
        final FragmentInfo info = FragmentData.fragmentInfo(getActivity(), fragmentId);

        Button cancelButton = (Button)view.findViewById(R.id.cancel_button);
        cancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mCallbacks.onManageCancel();
            }
        });

        Button manageButton = (Button)view.findViewById(R.id.confirm_button);
        manageButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (info != null) {
                    ManageContentFragment fragment = info.manageContentFragment();
                    if (fragment.addObjectToLogbook())
                        mCallbacks.onManageConfirm();
                }
            }
        });

        // add the actual content to the scroll view
        if (info != null) {
            setDialogTitle(getString(R.string.new_text) + " " + info.getName());

            FragmentTransaction transaction = getChildFragmentManager().beginTransaction();
            transaction.add(R.id.content_scroll_view, info.manageContentFragment());
            transaction.commit();
        }

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

    private void setDialogTitle(String title) {
        Dialog dialog = getDialog();
        if (dialog != null)
            dialog.setTitle(title);
    }
}
