package com.cohenadair.anglerslog.fragments;

import android.app.Activity;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.FragmentTransaction;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ScrollView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.fragment.FragmentInfo;
import com.cohenadair.anglerslog.utilities.fragment.FragmentUtils;

/**
 * The ManageFragment is used for add and edit views for the various user defines.
 */
public class ManageFragment extends DialogFragment {

    private ScrollView mScrollView;
    private Button mCancelButton;
    private Button mManageButton; // either Add or Save

    //region Callback Interface
    OnManageFragmentInteractionListener mCallbacks;

    // callback interface for the fragment's activity
    public interface OnManageFragmentInteractionListener {
        void onClickCancel(View v);
        void onClickConfirm(View v);
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
        FragmentInfo info = FragmentUtils.fragmentInfo(getActivity(), fragmentId);

        mScrollView = (ScrollView)view.findViewById(R.id.content_scroll_view);

        mCancelButton = (Button)view.findViewById(R.id.cancel_button);
        mCancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mCallbacks.onClickCancel(v);
            }
        });

        mManageButton = (Button)view.findViewById(R.id.confirm_button);
        mManageButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mCallbacks.onClickConfirm(v);
            }
        });

        if (info != null) {
            FragmentTransaction transaction = getChildFragmentManager().beginTransaction();
            transaction.add(R.id.content_scroll_view, info.manageContentFragment());
            transaction.commit();
        }

        return view;
    }

    // required until issue resolved
    // https://code.google.com/p/android/issues/detail?id=183358
    // TODO update to onAttach(Context context)
    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);

        // make sure the container activity has implemented the callback interface
        try {
            mCallbacks = (OnManageFragmentInteractionListener)activity;
        } catch (ClassCastException e) {
            throw new ClassCastException(activity.toString() + " must implement OnManageFragmentInteractionListener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mCallbacks = null;
    }
}
